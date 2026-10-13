# Generate spiral / transformer inductor GDS from JSON config.
#
# Uses axis-aligned ribbon BOXES (not fat Path corners) so parallel turns
# keep exact `space_um` and do not form parallel short-circuit bridges.
# A 1-dbu centerline Path is stored on 31/2 (M1) / 32/2 (M2) for cut-tests.
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
m1t = layout.layer(31, 1)
m2t = layout.layer(32, 1)
# Centerline for SHORTS cut-test (not drawn as metal width)
m1c = layout.layer(31, 2)
m2c = layout.layer(32, 2)
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

def add_centerline(cell, layer, layout, pts)
  return if pts.size < 2
  # 1 dbu wide — geometry marker only
  sp = RBA::Path.new(pts.map { |x, y| RBA::Point.new(um(layout, x), um(layout, y)) }, 1)
  cell.shapes(layer).insert(sp)
end

# Manhattan ribbon: each segment is an axis-aligned box of width W.
# Corners meet in a W×W overlap (same net). Parallel runs stay exactly SP apart.
def add_ribbon_boxes(cell, layer, layout, pts, width)
  return if pts.size < 2
  hw = width / 2.0
  (0...pts.size - 1).each do |i|
    x0, y0 = pts[i]
    x1, y1 = pts[i + 1]
    dx = x1 - x0
    dy = y1 - y0
    if dx.abs >= dy.abs
      # horizontal (allow tiny numeric dy)
      y = y0
      add_box_um(cell, layer, layout, [x0, x1].min, y - hw, [x0, x1].max, y + hw)
    else
      x = x0
      add_box_um(cell, layer, layout, x - hw, [y0, y1].min, x + hw, [y0, y1].max)
    end
  end
end

def add_via(cell, via_layer, m_bot, m_top, layout, cx, cy, vw, enc)
  half = vw / 2.0
  add_box_um(cell, via_layer, layout, cx - half, cy - half, cx + half, cy + half)
  pad = half + enc
  add_box_um(cell, m_bot, layout, cx - pad, cy - pad, cx + pad, cy + pad)
  add_box_um(cell, m_top, layout, cx - pad, cy - pad, cx + pad, cy + pad)
end

def pitch(w, s)
  w + s
end

# Rectilinear spiral centerline; length grows every 2 legs → constant pitch.
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

def add_leads(pts, lead = 15.0)
  return pts if pts.size < 2
  x0, y0 = pts.first
  x1, y1 = pts.last
  [[x0 - lead, y0]] + pts + [[x1 + lead, y1]]
end

def draw_series(cell, metal, cline, layout, pts, width)
  add_ribbon_boxes(cell, metal, layout, pts, width)
  add_centerline(cell, cline, layout, pts)
end

p = pitch(W, SP)

# Non-square shapes currently map to square ribbon geometry (DRC + no corner shorts).
# figure8 keeps dual-loop topology.
geom = SHAPE == "figure8" ? "figure8" : "square"

if geom == "figure8"
  left = square_spiral(RIN, TURNS, p).map { |x, y| [x - (RIN + TURNS * p + 10), y] }
  right = square_spiral(RIN, TURNS, p).map { |x, y| [-x + (RIN + TURNS * p + 10), y] }
  yb = [left.last[1], right.last[1]].min - (W + SP + 2.0)
  # Bridge on a clear channel below both spirals (no turn crossing)
  pts = left + [[left.last[0], yb], [right.last[0], yb]] + right.reverse
  pts = add_leads(pts, 12.0)
  draw_series(top, m1, m1c, layout, pts, W)
  add_label(top, m1t, layout, pts.first[0], pts.first[1], "P1")
  add_label(top, m1t, layout, pts.last[0], pts.last[1], "P2")

elsif PORTS <= 2
  pts = add_leads(square_spiral(RIN, TURNS, p), 15.0)
  draw_series(top, m1, m1c, layout, pts, W)
  add_label(top, m1t, layout, pts.first[0], pts.first[1], "P1")
  add_label(top, m1t, layout, pts.last[0], pts.last[1], "P2")

elsif PORTS == 3
  pts = add_leads(square_spiral(RIN, TURNS, p), 15.0)
  draw_series(top, m1, m1c, layout, pts, W)
  tap = [pts[0][0] + 6.0, pts[0][1]]
  spiral_cy = pts.map { |_, y| y }.sum / pts.size
  dir = tap[1] >= spiral_cy ? -1.0 : 1.0
  ct_pad = [tap[0], tap[1] + dir * 14.0]
  add_via(top, via, m1, m2, layout, tap[0], tap[1], VIA_W, VIA_E)
  add_ribbon_boxes(top, m2, layout, [tap, ct_pad], W)
  add_centerline(top, m2c, layout, [tap, ct_pad])
  add_box_um(top, m2, layout, ct_pad[0] - 2, ct_pad[1] - 2, ct_pad[0] + 2, ct_pad[1] + 2)
  add_label(top, m1t, layout, pts.first[0], pts.first[1], "P1")
  add_label(top, m1t, layout, pts.last[0], pts.last[1], "P2")
  add_label(top, m2t, layout, ct_pad[0], ct_pad[1], "CT")

else
  # 4-port stacked transformer — no vias between windings
  pri = add_leads(square_spiral(RIN, TURNS, p), 15.0)
  draw_series(top, m1, m1c, layout, pri, W)
  sec = square_spiral(RIN, TURNS, p).map { |x, y| [x, y - (RIN + TURNS * p + 20)] }
  sec = add_leads(sec, 15.0)
  draw_series(top, m2, m2c, layout, sec, W)
  add_label(top, m1t, layout, pri.first[0], pri.first[1], "P1")
  add_label(top, m1t, layout, pri.last[0], pri.last[1], "P2")
  add_label(top, m2t, layout, sec.first[0], sec.first[1], "S1")
  add_label(top, m2t, layout, sec.last[0], sec.last[1], "S2")
end

opt = RBA::SaveLayoutOptions.new
opt.format = "GDS2"
layout.write(OUT_PATH, opt)
puts "Wrote #{OUT_PATH} cell=#{CELL} shape=#{SHAPE}->#{geom} ports=#{PORTS} layers=#{NLAY} W=#{W} S=#{SP} role=#{ROLE} (box ribbons)"
