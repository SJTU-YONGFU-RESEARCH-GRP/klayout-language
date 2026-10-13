# Detect unintended parallel DC paths (turn-to-turn / multi-path shorts).
#
# Cut-test: read the real M1 Path centerline from GDS, notch it at mid
# fractions. After each single-trace cut, P1 and P2 must disconnect on M1.
# If they stay connected, a bypass short exists.
#
#   klayout -b -r check_shorts.rb \
#     -rd input=...gds -rd cell=IND -rd ports=2 \
#     -rd config=.../config.yaml -rd log=out.log

include RBA

IN = ($input || "").to_s
CELL = ($cell || "").to_s
NPORTS = ($ports || "2").to_s.to_i
LOG = ($log || "").to_s
CFG = ($config || "").to_s

abort("need -rd input=") if IN.empty?

def load_simple_yaml(path)
  return {} if path.nil? || path.empty? || !File.file?(path)
  h = {}
  File.read(path).each_line do |line|
    next if line =~ /^\s*#/ || line.strip.empty? || line =~ /^\s/
    next unless line =~ /^([A-Za-z0-9_]+):\s*(.+)$/
    key, val = $1, $2.strip
    val = $1 if val =~ /^["'](.*)["']$/
    h[key] =
      if val =~ /^-?\d+\.\d+$/ then val.to_f
      elsif val =~ /^-?\d+$/ then val.to_i
      else val
      end
  end
  h
end

cfg = load_simple_yaml(CFG)
W = ($width_um || cfg["width_um"] || 1.0).to_s.to_f

layout = Layout.new
layout.read(IN)
cell = CELL.empty? ? layout.top_cell : layout.cell(CELL)
abort("cell not found: #{CELL}") unless cell
dbu = layout.dbu

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

# Extract Path centerlines (dbu points). Prefer datatype 2 marker paths.
def extract_paths(cell, layer)
  paths = []
  cell.begin_shapes_rec(layer).each do |i|
    sh = i.shape
    next unless sh.is_path?
    tr = i.trans
    pts = sh.path.each_point.to_a.map { |p| tr * p }
    paths << pts if pts.size >= 2
  end
  paths
end

m1_layer = layout.layer(31, 0)
m2_layer = layout.layer(32, 0)
via_layer = layout.layer(30, 0)
m1c_layer = layout.layer(31, 2)

m1 = collect_polygons(cell, m1_layer)
m2 = collect_polygons(cell, m2_layer)
via = collect_polygons(cell, via_layer)

stack = Region.new
stack.insert(m1)
stack.insert(m2)
stack.insert(via)
stack.merge

labels = {}
[layout.layer(31, 1), layout.layer(32, 1)].each do |li|
  cell.shapes(li).each do |s|
    next unless s.is_text?
    t = s.text
    labels[t.string] = [t.trans.disp.x, t.trans.disp.y]
  end
end

TOL = 200

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

ok = true
msgs = []

# Rule A: transformer isolation
if NPORTS >= 4
  if labels["P1"] && labels["S1"] && connected?(stack, labels, "P1", "S1", TOL)
    ok = false
    msgs << "primary shorted to secondary (galvanic)"
  end
end

# Rule B: single M1 piece for 2p/3p
if NPORTS <= 3 && m1.count > 1
  ok = false
  msgs << "M1 has #{m1.count} disjoint pieces (via-pad islands / broken path)"
end

# Rule C: cut-test using real GDS path(s)
if NPORTS <= 3 && labels["P1"] && labels["P2"]
  paths = extract_paths(cell, m1c_layer)
  paths = extract_paths(cell, m1_layer) if paths.empty?
  if paths.empty?
    ok = false
    msgs << "no centerline Path (31/2) found for cut-test"
  else
    # Use longest path as the series winding
    pts = paths.max_by(&:size)
    # Polyline length + sample points
    seglen = []
    total = 0.0
    (0...pts.size - 1).each do |i|
      dx = (pts[i + 1].x - pts[i].x).to_f
      dy = (pts[i + 1].y - pts[i].y).to_f
      len = Math.sqrt(dx * dx + dy * dy)
      seglen << len
      total += len
    end

    still = []
    [0.35, 0.50, 0.65].each do |frac|
      target = total * frac
      acc = 0.0
      cx = cy = nil
      tx = ty = 1.0
      seglen.each_with_index do |len, i|
        if acc + len >= target && len > 1e-9
          t = (target - acc) / len
          cx = pts[i].x + t * (pts[i + 1].x - pts[i].x)
          cy = pts[i].y + t * (pts[i + 1].y - pts[i].y)
          tx = (pts[i + 1].x - pts[i].x) / len
          ty = (pts[i + 1].y - pts[i].y) / len
          break
        end
        acc += len
      end
      next if cx.nil?

      px, py = -ty, tx
      # Cut must fully cross the ribbon (axis-aligned boxes of width W)
      hw = (W * 1.05 / dbu).round  # across-trace half-span (> W/2)
      hl = (W * 0.75 / dbu).round  # along-trace half-thickness
      corners = [
        Point.new((cx + px * hw + tx * hl).round, (cy + py * hw + ty * hl).round),
        Point.new((cx - px * hw + tx * hl).round, (cy - py * hw + ty * hl).round),
        Point.new((cx - px * hw - tx * hl).round, (cy - py * hw - ty * hl).round),
        Point.new((cx + px * hw - tx * hl).round, (cy + py * hw - ty * hl).round)
      ]
      cut = Region.new(Polygon.new(corners))
      m1_cut = m1 - cut

      if connected?(m1_cut, labels, "P1", "P2", TOL)
        still << format("frac=%.2f@(%d,%d) pieces=%d", frac, cx.round, cy.round, m1_cut.count)
      end
    end

    if still.any?
      ok = false
      msgs << "parallel short path(s) survive cut-test: #{still.join(', ')}"
    end
  end
end

# Rule D: via count caps (intentional underpass / CT only)
shape = (cfg["shape"] || "square").to_s
max_vias =
  if shape == "figure8"
    2   # series bridge underpass
  else
    case NPORTS
    when 2 then 2   # inner-exit underpass
    when 3 then 3   # underpass (2) + CT (1)
    else 2          # primary underpass; secondary isolated (no P↔S vias)
    end
  end

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
puts "detail M1_polys=#{m1.count} vias=#{via.count} paths=#{extract_paths(cell, m1_layer).size}"

File.write(LOG, "#{msg}\n#{msgs.join("\n")}\n") unless LOG.empty?
exit(ok ? 0 : 1)
