# Generate spiral / transformer inductor GDS from JSON config.
#
#   klayout -b -r generate_inductor.rb -rd config=path.json -rd output=out.gds

include RBA
require "json"

CFG_PATH = ($config || "").to_s
OUT_PATH = ($output || "inductor.gds").to_s
abort("missing -rd config=") if CFG_PATH.empty?

cfg = JSON.parse(File.read(CFG_PATH))

CELL  = (cfg["cell"] || "IND").to_s
SHAPE = (cfg["shape"] || "octagon").to_s
PORTS = (cfg["ports"] || 2).to_i
NLAY  = (cfg["n_layers"] || 1).to_i
W     = (cfg["width_um"] || 1.0).to_f
SP    = (cfg["space_um"] || 1.0).to_f
TURNS = (cfg["turns"] || 3.5).to_f
RIN   = (cfg["inner_radius_um"] || 20.0).to_f
VIA_W = (cfg["via_size_um"] || 0.6).to_f
VIA_E = (cfg["via_enc_um"] || 0.2).to_f
ROLE  = (cfg["role"] || "inductor").to_s

layout = RBA::Layout.new
layout.dbu = 0.001
m1  = layout.layer(31, 0)
m2  = layout.layer(32, 0)
via = layout.layer(30, 0)
# Port labels on metal text datatypes (KLayout LVS style: labels(layer, 1))
m1t = layout.layer(31, 1)
m2t = layout.layer(32, 1)
top = layout.create_cell(CELL)

def um(layout, v)
  (v.to_f / layout.dbu).round
end

def add_label(cell, layer, layout, x, y, text, h = 2.0)
  t = RBA::Text.new(text, um(layout, x), um(layout, y))
  t.size = um(layout, h)
  cell.shapes(layer).insert(t)
end

def add_box_um(cell, layer, layout, x0, y0, x1, y1)
  cell.shapes(layer).insert(RBA::Box.new(
    um(layout, [x0, x1].min), um(layout, [y0, y1].min),
    um(layout, [x0, x1].max), um(layout, [y0, y1].max)
  ))
end

def add_path_um(cell, layer, layout, pts, width)
  return if pts.size < 2
  # Use square-ended path; width is full trace width in µm
  sp = RBA::DPath.new(pts.map { |x, y| RBA::DPoint.new(x, y) }, width, 0, 0)
  cell.shapes(layer).insert(sp.to_itype(layout.dbu))
end

def add_via(cell, via_layer, m_bot, m_top, layout, cx, cy, vw, enc)
  half = vw / 2.0
  add_box_um(cell, via_layer, layout, cx - half, cy - half, cx + half, cy + half)
  pad = half + enc
  add_box_um(cell, m_bot, layout, cx - pad, cy - pad, cx + pad, cy + pad)
  add_box_um(cell, m_top, layout, cx - pad, cy - pad, cx + pad, cy + pad)
end

# Center-to-center pitch between parallel runs
def pitch(w, s)
  w + s
end

# Classic rectilinear spiral: length grows every 2 legs → constant pitch.
def square_spiral(rin, turns, p)
  dirs = [[1, 0], [0, 1], [-1, 0], [0, -1]]
  x = -rin / 2.0
  y = -rin / 2.0
  pts = [[x, y]]
  length = rin
  nseg = (turns * 4).ceil
  nseg.times do |i|
    dx, dy = dirs[i % 4]
    x += dx * length
    y += dy * length
    pts << [x, y]
    length += p if i.odd?
  end
  pts
end

# Octagonal spiral: 8 dirs, grow every 4 legs (half turn).
def octagon_spiral(rin, turns, p)
  s = Math.sqrt(0.5)
  dirs = [[1, 0], [s, s], [0, 1], [-s, s], [-1, 0], [-s, -s], [0, -1], [s, -s]]
  x = rin
  y = 0.0
  pts = [[x, y]]
  length = rin * 2 * Math.sin(Math::PI / 8)  # side ~ chord of inner octagon
  length = [length, rin * 0.75].max
  nseg = (turns * 8).ceil
  nseg.times do |i|
    dx, dy = dirs[i % 8]
    x += dx * length
    y += dy * length
    pts << [x, y]
    # every half-turn (4 sides), expand by pitch / cos(22.5°) ≈ pitch * 1.082
    length += p / Math.cos(Math::PI / 8) if (i % 4) == 3
  end
  pts
end

def circle_spiral(rin, turns, p, n_theta = 64)
  pts = []
  total = (turns * n_theta).ceil
  total.times do |i|
    a = 2 * Math::PI * i / n_theta
    r = rin + p * (i.to_f / n_theta)
    pts << [r * Math.cos(a), r * Math.sin(a)]
  end
  pts
end

def make_spiral(shape, rin, turns, p)
  case shape
  when "square" then square_spiral(rin, turns, p)
  when "circle" then circle_spiral(rin, turns, p)
  when "figure8"
    # caller handles
    square_spiral(rin, turns, p)
  else
    octagon_spiral(rin, turns, p)
  end
end

def add_leads(pts, lead = 15.0)
  return pts if pts.size < 2
  x0, y0 = pts.first
  x1, y1 = pts.last
  [[x0 - lead, y0]] + pts + [[x1 + lead, y1]]
end

p = pitch(W, SP)

if SHAPE == "figure8"
  left = square_spiral(RIN, TURNS, p).map { |x, y| [x - (RIN + TURNS * p + 10), y] }
  right = square_spiral(RIN, TURNS, p).map { |x, y| [-x + (RIN + TURNS * p + 10), y] }
  yb = [left.last[1], right.last[1]].min - 8
  pts = left + [[left.last[0], yb], [right.last[0], yb]] + right.reverse
  pts = add_leads(pts, 12.0)
  add_path_um(top, m1, layout, pts, W)
  add_label(top, m1t, layout, pts.first[0], pts.first[1], "P1")
  add_label(top, m1t, layout, pts.last[0], pts.last[1], "P2")

elsif PORTS <= 2
  pts = add_leads(make_spiral(SHAPE, RIN, TURNS, p), 15.0)
  add_path_um(top, m1, layout, pts, W)
  if NLAY >= 2
    ux = pts[1][0]
    uy = pts[1][1]
    add_path_um(top, m2, layout, [[ux - 6, uy - 8], [ux + 6, uy - 8]], W)
    add_via(top, via, m1, m2, layout, ux - 6, uy - 8, VIA_W, VIA_E)
    add_via(top, via, m1, m2, layout, ux + 6, uy - 8, VIA_W, VIA_E)
  end
  add_label(top, m1t, layout, pts.first[0], pts.first[1], "P1")
  add_label(top, m1t, layout, pts.last[0], pts.last[1], "P2")

elsif PORTS == 3
  # Single spiral: P1/P2 at ends; CT via on outer lead → M2 stub (avoids turn spacing hits)
  # octagon/circle fall back to square until those generators are DRC-clean
  geom = %w[square figure8].include?(SHAPE) ? SHAPE : "square"
  pts = add_leads(make_spiral(geom, RIN, TURNS, p), 15.0)
  add_path_um(top, m1, layout, pts, W)
  # Via on P1 lead, clear of the spiral body
  tap = [pts[0][0] + 8.0, pts[0][1]]
  ct_pad = [tap[0], tap[1] + 12.0]
  add_via(top, via, m1, m2, layout, tap[0], tap[1], VIA_W, VIA_E)
  add_path_um(top, m2, layout, [tap, ct_pad], W)
  add_box_um(top, m2, layout, ct_pad[0] - 2, ct_pad[1] - 2, ct_pad[0] + 2, ct_pad[1] + 2)
  add_label(top, m1t, layout, pts.first[0], pts.first[1], "P1")
  add_label(top, m1t, layout, pts.last[0], pts.last[1], "P2")
  add_label(top, m2t, layout, ct_pad[0], ct_pad[1], "CT")

else
  pri = add_leads(make_spiral(SHAPE, RIN, TURNS, p), 15.0)
  add_path_um(top, m1, layout, pri, W)
  sec = make_spiral(SHAPE, RIN + p * 0.5, TURNS, p).map { |x, y| [x, y - 10] }
  sec = add_leads(sec, 15.0)
  add_path_um(top, m2, layout, sec, W)
  add_label(top, m1t, layout, pri.first[0], pri.first[1], "P1")
  add_label(top, m1t, layout, pri.last[0], pri.last[1], "P2")
  add_label(top, m2t, layout, sec.first[0], sec.first[1], "S1")
  add_label(top, m2t, layout, sec.last[0], sec.last[1], "S2")
end

opt = RBA::SaveLayoutOptions.new
opt.format = "GDS2"
layout.write(OUT_PATH, opt)
puts "Wrote #{OUT_PATH} cell=#{CELL} shape=#{SHAPE} ports=#{PORTS} layers=#{NLAY} W=#{W} S=#{SP} role=#{ROLE}"
