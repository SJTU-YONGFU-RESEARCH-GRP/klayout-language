# Generate spiral / transformer inductor GDS from JSON config.
#
# Axis-aligned ribbon BOXES keep exact turn spacing (no Path corner bridges).
# Critical: never route a lead through the spiral body — that creates parallel
# short-circuit paths. Inner end exits via intentional M2 underpass.
#
# Centerline Path on 31/2 / 32/2 for SHORTS cut-test.
#
#   klayout -b -r generate_inductor.rb -rd config=path.json -rd output=out.gds

include RBA
require "json"

CFG_PATH = ($config || "").to_s
OUT_PATH = ($output || "inductor.gds").to_s
abort("missing -rd config=") if CFG_PATH.empty?

cfg = JSON.parse(File.read(CFG_PATH))

CELL  = (cfg["cell"] || "IND").to_s
SHAPE = (cfg["shape"] || "square").to_s
PORTS = (cfg["ports"] || 2).to_i
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
  sp = RBA::Path.new(pts.map { |x, y| RBA::Point.new(um(layout, x), um(layout, y)) }, 1)
  cell.shapes(layer).insert(sp)
end

def add_ribbon_boxes(cell, layer, layout, pts, width)
  return if pts.size < 2
  hw = width / 2.0
  (0...pts.size - 1).each do |i|
    x0, y0 = pts[i]
    x1, y1 = pts[i + 1]
    if (x1 - x0).abs >= (y1 - y0).abs
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

# Centerline: starts INNER, grows OUTWARD (last point = outer).
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

def bbox_of(pts)
  xs = pts.map { |x, _| x }
  ys = pts.map { |_, y| y }
  [xs.min, ys.min, xs.max, ys.max]
end

# Outer lead only — extends AWAY from spiral bbox (never through turns).
def add_outer_lead(pts, lead = 15.0)
  return pts if pts.size < 2
  x1, y1 = pts.last
  xmin, ymin, xmax, ymax = bbox_of(pts)
  # Prefer +X if outer is on right half, else -X; similarly Y
  cx = 0.5 * (xmin + xmax)
  cy = 0.5 * (ymin + ymax)
  if (x1 - cx).abs >= (y1 - cy).abs
    x2 = x1 >= cx ? x1 + lead : x1 - lead
    pts + [[x2, y1]]
  else
    y2 = y1 >= cy ? y1 + lead : y1 - lead
    pts + [[x1, y2]]
  end
end

def draw_series(cell, metal, cline, layout, pts, width)
  add_ribbon_boxes(cell, metal, layout, pts, width)
  add_centerline(cell, cline, layout, pts)
end

# Underpass: from inner point under the spiral to a clear pad outside (left).
# Exactly 2 vias. M2 runs in a channel BELOW ymin so it does not need to
# weave between turns — clear of M1 except at the two via pads.
def add_inner_exit_underpass(cell, m1, m2, via, m2c, layout, inner_pt, spiral_pts, width, via_w, via_e)
  x0, y0 = inner_pt
  xmin, ymin, xmax, ymax = bbox_of(spiral_pts)
  # Outside pad to the left of spiral, below the body
  y_chan = ymin - (width + 8.0)
  x_pad = xmin - 15.0
  # Via1 at inner; short M1 stub already part of spiral. Via2 at outside.
  add_via(cell, via, m1, m2, layout, x0, y0, via_w, via_e)
  # M2: inner → down to channel → left to pad → up not needed
  m2_pts = [[x0, y0], [x0, y_chan], [x_pad, y_chan]]
  add_ribbon_boxes(cell, m2, layout, m2_pts, width)
  add_centerline(cell, m2c, layout, m2_pts)
  add_via(cell, via, m1, m2, layout, x_pad, y_chan, via_w, via_e)
  # M1 exit lead further left for P2 label clearance
  add_box_um(cell, m1, layout, x_pad - 12.0, y_chan - width / 2.0, x_pad, y_chan + width / 2.0)
  [x_pad - 12.0, y_chan]
end

p = pitch(W, SP)
geom = SHAPE == "figure8" ? "figure8" : "square"

if geom == "figure8"
  # Series figure-8: P1 → left(outer→inner) → M2 channel bridge → right(inner→outer) → P2
  # Bridge stays BELOW both spirals so M1 never routes through turns.
  sep = RIN + TURNS * p + 12.0
  left = square_spiral(RIN, TURNS, p).map { |x, y| [x - sep, y] }
  right = square_spiral(RIN, TURNS, p).map { |x, y| [-x + sep, y] }
  lo, li = left.last, left.first
  ro, ri = right.last, right.first
  y_chan = [bbox_of(left)[1], bbox_of(right)[1]].min - (W + 10.0)
  p1 = [lo[0] - 12.0, lo[1]]
  left_pts = [p1] + left.reverse
  draw_series(top, m1, m1c, layout, left_pts, W)
  # Underpass bridge: via at left inner → M2 along channel → via at right inner
  add_via(top, via, m1, m2, layout, li[0], li[1], VIA_W, VIA_E)
  add_via(top, via, m1, m2, layout, ri[0], ri[1], VIA_W, VIA_E)
  bridge = [[li[0], li[1]], [li[0], y_chan], [ri[0], y_chan], [ri[0], ri[1]]]
  add_ribbon_boxes(top, m2, layout, bridge, W)
  add_centerline(top, m2c, layout, bridge)
  p2 = [ro[0] + 12.0, ro[1]]
  right_pts = right + [p2]
  draw_series(top, m1, m1c, layout, right_pts, W)
  # Combined centerline for cut-test (M1 pieces + virtual bridge via M2)
  add_centerline(top, m1c, layout, left_pts + [[li[0], y_chan], [ri[0], y_chan]] + right_pts)
  add_label(top, m1t, layout, p1[0], p1[1], "P1")
  add_label(top, m1t, layout, p2[0], p2[1], "P2")

elsif PORTS <= 2
  core = square_spiral(RIN, TURNS, p)  # inner → outer
  pts = add_outer_lead(core, 15.0)     # extend OUTER only
  draw_series(top, m1, m1c, layout, pts, W)
  p2 = add_inner_exit_underpass(top, m1, m2, via, m2c, layout, core.first, core, W, VIA_W, VIA_E)
  add_label(top, m1t, layout, pts.last[0], pts.last[1], "P1")
  add_label(top, m1t, layout, p2[0], p2[1], "P2")

elsif PORTS == 3
  core = square_spiral(RIN, TURNS, p)
  pts = add_outer_lead(core, 15.0)
  draw_series(top, m1, m1c, layout, pts, W)
  # P2 via underpass from inner; CT via on outer lead (away from body)
  p2 = add_inner_exit_underpass(top, m1, m2, via, m2c, layout, core.first, core, W, VIA_W, VIA_E)
  # CT on outer lead segment
  tap = [pts[-2][0], pts[-2][1]]
  # nudge tap onto lead between pts[-2] and pts[-1]
  tap = [(pts[-2][0] + pts[-1][0]) / 2.0, (pts[-2][1] + pts[-1][1]) / 2.0]
  xmin, ymin, _, _ = bbox_of(core)
  ct_pad = [tap[0], ymin - 14.0]
  # If CT pad would hit underpass channel, place above instead
  ct_pad = [tap[0], bbox_of(core)[3] + 14.0] if (ct_pad[1] - (ymin - (W + 8.0))).abs < 6.0
  add_via(top, via, m1, m2, layout, tap[0], tap[1], VIA_W, VIA_E)
  add_ribbon_boxes(top, m2, layout, [tap, ct_pad], W)
  add_centerline(top, m2c, layout, [tap, ct_pad])
  add_box_um(top, m2, layout, ct_pad[0] - 2, ct_pad[1] - 2, ct_pad[0] + 2, ct_pad[1] + 2)
  add_label(top, m1t, layout, pts.last[0], pts.last[1], "P1")
  add_label(top, m1t, layout, p2[0], p2[1], "P2")
  add_label(top, m2t, layout, ct_pad[0], ct_pad[1], "CT")

else
  pri = add_outer_lead(square_spiral(RIN, TURNS, p), 15.0)
  # Primary: for 4-port keep both ends on M1 without underpass by labeling
  # outer as P1 and using underpass for P2 (same as 2-port primary)
  core = square_spiral(RIN, TURNS, p)
  pri = add_outer_lead(core, 15.0)
  draw_series(top, m1, m1c, layout, pri, W)
  p2 = add_inner_exit_underpass(top, m1, m2, via, m2c, layout, core.first, core, W, VIA_W, VIA_E)
  # Secondary on M2, shifted down — both ends outer by using lead on M2 only
  # For secondary, wind and put both leads outside without crossing: reverse
  # so we draw outer-to-inner then underpass on M1? Simpler: same spiral on M2
  # fully, leads outward only on outer end; inner labeled at center (S2).
  sec_core = square_spiral(RIN, TURNS, p).map { |x, y| [x, y - (RIN + TURNS * p + 25)] }
  sec = add_outer_lead(sec_core, 15.0)
  draw_series(top, m2, m2c, layout, sec, W)
  add_label(top, m1t, layout, pri.last[0], pri.last[1], "P1")
  add_label(top, m1t, layout, p2[0], p2[1], "P2")
  add_label(top, m2t, layout, sec.last[0], sec.last[1], "S1")
  add_label(top, m2t, layout, sec_core.first[0], sec_core.first[1], "S2")
end

opt = RBA::SaveLayoutOptions.new
opt.format = "GDS2"
layout.write(OUT_PATH, opt)
puts "Wrote #{OUT_PATH} cell=#{CELL} shape=#{SHAPE}->#{geom} ports=#{PORTS} W=#{W} S=#{SP} role=#{ROLE} (box ribbons, no lead-through)"
