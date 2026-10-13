# Detect unintended parallel DC paths (turn-to-turn / multi-path shorts).
#
# Method: cut the series trace at midpoints along the design centerline.
# After each cut, P1 and P2 must become disconnected on the metal stack.
# If they stay connected, a bypass short exists.
#
#   klayout -b -r check_shorts.rb \
#     -rd input=...gds -rd cell=IND -rd ports=2 \
#     -rd config=.../config.yaml -rd log=out.log
#
# Optional: -rd width_um= -rd space_um= -rd turns= -rd inner_radius_um= -rd shape=

include RBA
require "json"

IN = ($input || "").to_s
CELL = ($cell || "").to_s
NPORTS = ($ports || "2").to_s.to_i
LOG = ($log || "").to_s
CFG = ($config || "").to_s

abort("need -rd input=") if IN.empty?

def load_cfg(path)
  return {} if path.nil? || path.empty? || !File.file?(path)
  txt = File.read(path)
  if path.end_with?(".json")
    JSON.parse(txt)
  else
    # minimal YAML subset: key: value
    h = {}
    txt.each_line do |line|
      next if line =~ /^\s*#/ || line.strip.empty? || line =~ /^\s/
      if line =~ /^([A-Za-z0-9_]+):\s*(.+)$/
        key, val = $1, $2.strip
        val = $1 if val =~ /^["'](.*)["']$/
        if val =~ /^-?\d+\.\d+$/
          h[key] = val.to_f
        elsif val =~ /^-?\d+$/
          h[key] = val.to_i
        else
          h[key] = val
        end
      end
    end
    h
  end
end

cfg = load_cfg(CFG)
SHAPE = ($shape || cfg["shape"] || "square").to_s
W = ($width_um || cfg["width_um"] || 1.0).to_s.to_f
SP = ($space_um || cfg["space_um"] || 1.0).to_s.to_f
TURNS = ($turns || cfg["turns"] || 3.5).to_s.to_f
RIN = ($inner_radius_um || cfg["inner_radius_um"] || 20.0).to_s.to_f
P = W + SP

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

def figure8_pts(rin, turns, p)
  left = square_spiral(rin, turns, p).map { |x, y| [x - (rin + turns * p + 10), y] }
  right = square_spiral(rin, turns, p).map { |x, y| [-x + (rin + turns * p + 10), y] }
  yb = [left.last[1], right.last[1]].min - 8
  add_leads(left + [[left.last[0], yb], [right.last[0], yb]] + right.reverse, 12.0)
end

def centerline(shape, rin, turns, p)
  case shape
  when "figure8" then figure8_pts(rin, turns, p)
  else add_leads(square_spiral(rin, turns, p), 15.0)
  end
end

def collect_polygons(cell, layer)
  r = Region.new
  cell.begin_shapes_rec(layer).each do |i|
    sh = i.shape
    next unless sh.is_box? || sh.is_polygon? || sh.is_path?
    r.insert(sh.polygon.transformed(i.trans))
  end
  r.merge
  r
end

layout = Layout.new
layout.read(IN)
cell = CELL.empty? ? layout.top_cell : layout.cell(CELL)
abort("cell not found: #{CELL}") unless cell
dbu = layout.dbu

m1 = collect_polygons(cell, layout.layer(31, 0))
m2 = collect_polygons(cell, layout.layer(32, 0))
via = collect_polygons(cell, layout.layer(30, 0))

stack = Region.new
stack.insert(m1)
stack.insert(m2)
stack.insert(via)
stack.merge

# Labels
labels = {}
[layout.layer(31, 1), layout.layer(32, 1)].each do |li|
  cell.shapes(li).each do |s|
    next unless s.is_text?
    t = s.text
    labels[t.string] = [t.trans.disp.x, t.trans.disp.y]
  end
end

def find_poly(region, x, y, tol)
  box = Box.new(x - tol, y - tol, x + tol, y + tol)
  region.each do |p|
    return p if p.touches(box) || p.inside(Point.new(x, y))
  end
  nil
end

def connected?(region, lab, a, b, tol)
  return false unless lab[a] && lab[b]
  pa = find_poly(region, lab[a][0], lab[a][1], tol)
  pb = find_poly(region, lab[b][0], lab[b][1], tol)
  return false if pa.nil? || pb.nil?
  pa.bbox == pb.bbox && (pa.area - pb.area).abs < 1.0
end

TOL = 200
ok = true
msgs = []

# --- Rule A: transformer isolation (no primary↔secondary short) ---
if NPORTS >= 4
  if connected?(stack, labels, "P1", "S1", TOL)
    ok = false
    msgs << "primary shorted to secondary (galvanic)"
  end
end

# --- Rule B: via pads must not create extra M1 islands that merge turns ---
# Expect at most one M1 polygon for single-winding layouts (2p/3p).
if NPORTS <= 3 && m1.count > 1
  ok = false
  msgs << "M1 has #{m1.count} disjoint pieces (possible via-pad islands / broken path)"
end

# --- Rule C: cut-test for single series path (2-port and 3-port) ---
if NPORTS <= 3 && labels["P1"] && labels["P2"]
  pts = centerline(SHAPE, RIN, TURNS, P)
  if pts.size < 4
    ok = false
    msgs << "centerline too short for cut-test"
  else
    # Fractions along polyline (avoid ends / leads)
    fracs = [0.35, 0.50, 0.65]
    cut_half = um = (W * 0.65 / dbu).round  # cut taller than half-width
    cut_along = (0.4 / dbu).round           # thin cut along path (~0.4 µm)

    still_shorted = []
    fracs.each do |frac|
      # index along segments by length
      lengths = []
      total = 0.0
      (0...pts.size - 1).each do |i|
        dx = pts[i + 1][0] - pts[i][0]
        dy = pts[i + 1][1] - pts[i][1]
        len = Math.sqrt(dx * dx + dy * dy)
        lengths << len
        total += len
      end
      target = total * frac
      acc = 0.0
      cx = cy = tx = ty = nil
      lengths.each_with_index do |len, i|
        if acc + len >= target && len > 1e-9
          t = (target - acc) / len
          x0, y0 = pts[i]
          x1, y1 = pts[i + 1]
          cx = x0 + t * (x1 - x0)
          cy = y0 + t * (y1 - y0)
          tx = (x1 - x0) / len
          ty = (y1 - y0) / len
          break
        end
        acc += len
      end
      next if cx.nil?

      # Perpendicular unit
      px, py = -ty, tx
      # Cut box centered on point, spanning across the trace
      # Corners of rectangle in µm → dbu
      hw = W * 0.75  # half-span across trace
      hl = 0.35      # half-thickness along trace
      corners = [
        [cx + px * hw + tx * hl, cy + py * hw + ty * hl],
        [cx - px * hw + tx * hl, cy - py * hw + ty * hl],
        [cx - px * hw - tx * hl, cy - py * hw - ty * hl],
        [cx + px * hw - tx * hl, cy + py * hw - ty * hl]
      ]
      dpts = corners.map { |x, y| Point.new((x / dbu).round, (y / dbu).round) }
      cut = Region.new(Polygon.new(dpts))

      # Cut M1 only (series winding lives on M1 for 2p/3p). Keep M2/via out so
      # CT underpass cannot re-bridge the intentional series cut.
      m1_cut = Region.new
      m1_cut.insert(m1)
      m1_cut -= cut
      m1_cut.merge

      if connected?(m1_cut, labels, "P1", "P2", TOL)
        still_shorted << format("frac=%.2f@(%.1f,%.1f)", frac, cx, cy)
      end
    end

    if still_shorted.any?
      ok = false
      msgs << "parallel short path(s) survive cut-test: #{still_shorted.join(', ')}"
    end
  end
end

# --- Rule D: no M2↔M1 via forest (limit vias by topology) ---
max_vias =
  case NPORTS
  when 2 then (cfg["n_layers"].to_i >= 2 ? 2 : 0)
  when 3 then 1
  else 0  # stacked transformer: no galvanic vias
  end
# cfg n_layers may be int already
max_vias = 2 if NPORTS == 2 && (cfg["n_layers"] || 1).to_i >= 2
max_vias = 1 if NPORTS == 3
max_vias = 0 if NPORTS >= 4

if via.count > max_vias
  ok = false
  msgs << "too many vias (#{via.count} > max #{max_vias}) — risk of multi-path shorts"
end

msg = if ok
        "SHORTS PASS — #{CELL} (single series path / isolation OK)"
      else
        "SHORTS FAIL — #{CELL}: #{msgs.join('; ')}"
      end
puts msg
puts "detail M1_polys=#{m1.count} vias=#{via.count} shape=#{SHAPE}"

unless LOG.empty?
  File.write(LOG, "#{msg}\n#{msgs.join("\n")}\n")
end
exit(ok ? 0 : 1)
