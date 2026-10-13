# Generate spiral / transformer inductor GDS from JSON config.
#
#   klayout -b -r generate_inductor.rb -rd config=path.json -rd output=out.gds
#
# Config keys: cell, shape, ports, n_layers, width_um, space_um, turns,
#              inner_radius_um, via_size_um, via_enc_um

include RBA
require "json"

CFG_PATH = ($config || "").to_s
OUT_PATH = ($output || "inductor.gds").to_s
abort("missing -rd config=") if CFG_PATH.empty?

cfg = JSON.parse(File.read(CFG_PATH))

CELL   = (cfg["cell"] || "IND").to_s
SHAPE  = (cfg["shape"] || "octagon").to_s
PORTS  = (cfg["ports"] || 2).to_i
NLAY   = (cfg["n_layers"] || 1).to_i
W      = (cfg["width_um"] || 1.0).to_f
SP     = (cfg["space_um"] || 1.0).to_f
TURNS  = (cfg["turns"] || 3.5).to_f
RIN    = (cfg["inner_radius_um"] || 20.0).to_f
VIA_W  = (cfg["via_size_um"] || 0.6).to_f
VIA_E  = (cfg["via_enc_um"] || 0.2).to_f
ROLE   = (cfg["role"] || "inductor").to_s

M1_L, M2_L, VIA_L, LBL_L = 31, 32, 30, 90

layout = RBA::Layout.new
layout.dbu = 0.001
m1  = layout.layer(M1_L, 0)
m2  = layout.layer(M2_L, 0)
via = layout.layer(VIA_L, 0)
lbl = layout.layer(LBL_L, 0)
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
  sp = RBA::DPath.new(pts.map { |x, y| RBA::DPoint.new(x, y) }, width)
  cell.shapes(layer).insert(sp.to_itype(layout.dbu))
end

def add_via(cell, via_layer, m1, m2, layout, cx, cy, vw, enc)
  half = vw / 2.0
  add_box_um(cell, via_layer, layout, cx - half, cy - half, cx + half, cy + half)
  pad = half + enc
  add_box_um(cell, m1, layout, cx - pad, cy - pad, cx + pad, cy + pad)
  add_box_um(cell, m2, layout, cx - pad, cy - pad, cx + pad, cy + pad)
end

# Direction unit vectors for shape
def dirs_for(shape)
  case shape
  when "square"
    [[1, 0], [0, 1], [-1, 0], [0, -1]]
  when "octagon"
    s = Math.sqrt(0.5)
    [[1, 0], [s, s], [0, 1], [-s, s], [-1, 0], [-s, -s], [0, -1], [s, -s]]
  when "circle"
    n = 32
    (0...n).map { |i|
      a = 2 * Math::PI * i / n
      [Math.cos(a), Math.sin(a)]
    }
  else
    # figure8 uses square dirs on two centers
    [[1, 0], [0, 1], [-1, 0], [0, -1]]
  end
end

# Build spiral centerline points (µm). pitch = width + space.
def spiral_points(shape, rin, turns, pitch, mirror_x: false)
  dirs = dirs_for(shape)
  nd = dirs.size
  pts = []
  x, y = rin, 0.0
  pts << [x, y]
  seg_len = rin
  n_seg = (turns * nd).floor
  frac = (turns * nd) - n_seg
  (0...n_seg).each do |i|
    dx, dy = dirs[i % nd]
    # grow every full revolution
    seg_len = rin + pitch * (i / nd)
    x += dx * seg_len
    y += dy * seg_len
    pts << [mirror_x ? -x : x, y]
  end
  if frac > 1e-6
    dx, dy = dirs[n_seg % nd]
    seg_len = rin + pitch * (n_seg / nd)
    x += dx * seg_len * frac
    y += dy * seg_len * frac
    pts << [mirror_x ? -x : x, y]
  end
  pts
end

def lead_out(pts, side, lead = 10.0)
  return pts if pts.empty?
  x, y = pts.last
  case side
  when :left  then pts + [[x - lead, y]]
  when :right then pts + [[x + lead, y]]
  when :up    then pts + [[x, y + lead]]
  when :down  then pts + [[x, y - lead]]
  else pts
  end
end

pitch = W + SP

if SHAPE == "figure8"
  left = spiral_points("square", RIN, TURNS, pitch, mirror_x: false).map { |x, y| [x - (RIN + TURNS * pitch + 5), y] }
  right = spiral_points("square", RIN, TURNS, pitch, mirror_x: true).map { |x, y| [x + (RIN + TURNS * pitch + 5), y] }
  # bridge at bottom
  bridge = [left.last, [0, left.last[1] - 5], right.last]
  pts_pri = left + bridge[1..] + right.reverse
  add_path_um(top, m1, layout, pts_pri, W)
  p1 = pts_pri.first
  p2 = pts_pri.last
  add_label(top, lbl, layout, p1[0], p1[1] + 3, "P1")
  add_label(top, lbl, layout, p2[0], p2[1] + 3, "P2")
elsif PORTS <= 2
  pts = spiral_points(SHAPE, RIN, TURNS, pitch)
  pts = lead_out(pts, :right, 12.0)
  # start lead
  pts = [[pts.first[0] - 12.0, pts.first[1]]] + pts
  add_path_um(top, m1, layout, pts, W)
  if NLAY >= 2
    # underpass stub near start for optional crossover demo
    ux, uy = pts[2]
    add_path_um(top, m2, layout, [[ux - 5, uy], [ux + 5, uy]], W)
    add_via(top, via, m1, m2, layout, ux - 5, uy, VIA_W, VIA_E)
    add_via(top, via, m1, m2, layout, ux + 5, uy, VIA_W, VIA_E)
  end
  add_label(top, lbl, layout, pts.first[0], pts.first[1] + 3, "P1")
  add_label(top, lbl, layout, pts.last[0], pts.last[1] + 3, "P2")
elsif PORTS == 3
  # center-tap: two half-spirals on M1 meeting at CT via M2 bridge
  half = TURNS / 2.0
  a = spiral_points(SHAPE, RIN, half, pitch)
  b = spiral_points(SHAPE, RIN, half, pitch, mirror_x: true)
  a = [[a.first[0] - 12, a.first[1]]] + a
  b = [[b.first[0] + 12, b.first[1]]] + b
  add_path_um(top, m1, layout, a, W)
  add_path_um(top, m1, layout, b, W)
  cx = 0.0
  cy = a.last[1]
  add_path_um(top, m2, layout, [a.last, [cx, cy], b.last], W)
  add_via(top, via, m1, m2, layout, a.last[0], a.last[1], VIA_W, VIA_E)
  add_via(top, via, m1, m2, layout, b.last[0], b.last[1], VIA_W, VIA_E)
  add_label(top, lbl, layout, a.first[0], a.first[1] + 3, "P1")
  add_label(top, lbl, layout, b.first[0], b.first[1] + 3, "P2")
  add_label(top, lbl, layout, cx, cy + 5, "CT")
else
  # 4-port: stacked transformer — primary M1, secondary M2
  pri = spiral_points(SHAPE, RIN, TURNS, pitch)
  pri = [[pri.first[0] - 12, pri.first[1]]] + pri
  pri = lead_out(pri, :right, 12.0)
  add_path_um(top, m1, layout, pri, W)
  sec = spiral_points(SHAPE, RIN + (W + SP) * 0.5, TURNS, pitch)
  sec = [[sec.first[0] - 12, sec.first[1] - 8]] + sec.map { |x, y| [x, y - 8] }
  sec = lead_out(sec, :right, 12.0)
  add_path_um(top, m2, layout, sec, W)
  # no vias between windings (galvanic isolation)
  add_label(top, lbl, layout, pri.first[0], pri.first[1] + 3, "P1")
  add_label(top, lbl, layout, pri.last[0], pri.last[1] + 3, "P2")
  add_label(top, lbl, layout, sec.first[0], sec.first[1] - 3, "S1")
  add_label(top, lbl, layout, sec.last[0], sec.last[1] - 3, "S2")
end

opt = RBA::SaveLayoutOptions.new
opt.format = "GDS2"
layout.write(OUT_PATH, opt)
puts "Wrote #{OUT_PATH} cell=#{CELL} shape=#{SHAPE} ports=#{PORTS} layers=#{NLAY} W=#{W} S=#{SP} role=#{ROLE}"
