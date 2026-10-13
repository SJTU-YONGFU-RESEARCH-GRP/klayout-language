# Detect unintended parallel DC paths (turn-to-turn / multi-path shorts).
#
# Connectivity is layer-aware: M1↔M2 only through VIA overlaps (not 2D projection).
# Cut-test: notch M1 along centerline 31/2; after cut, P1–P2 must open.
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

# Union-Find
class UF
  def initialize
    @p = {}
  end

  def add(x)
    @p[x] = x unless @p.key?(x)
  end

  def find(x)
    add(x)
    @p[x] = find(@p[x]) if @p[x] != x
    @p[x]
  end

  def union(a, b)
    ra, rb = find(a), find(b)
    @p[ra] = rb if ra != rb
  end

  def same?(a, b)
    return false unless @p.key?(a) && @p.key?(b)
    find(a) == find(b)
  end
end

# Build nets: each polygon is a node; vias bridge M1↔M2 when overlapping both.
def build_nets(m1, m2, via)
  uf = UF.new
  m1_polys = []
  m2_polys = []
  i = 0
  m1.each { |p| id = "M1_#{i}"; uf.add(id); m1_polys << [id, p]; i += 1 }
  i = 0
  m2.each { |p| id = "M2_#{i}"; uf.add(id); m2_polys << [id, p]; i += 1 }

  via.each do |v|
    vr = Region.new(v)
    touch_m1 = m1_polys.select { |_, p| (Region.new(p) & vr).area > 0 }
    touch_m2 = m2_polys.select { |_, p| (Region.new(p) & vr).area > 0 }
    # Bridge all touched M1/M2 pieces through this via
    ids = touch_m1.map(&:first) + touch_m2.map(&:first)
    ids.each_cons(2) { |a, b| uf.union(a, b) }
  end
  [uf, m1_polys, m2_polys]
end

def poly_id_at(polys, x, y, tol)
  box = Box.new(x - tol, y - tol, x + tol, y + tol)
  polys.each do |id, p|
    return id if p.touches(box) || p.inside(Point.new(x, y))
  end
  nil
end

def ports_connected?(uf, m1_polys, m2_polys, lab, a, b, tol)
  return false unless lab[a] && lab[b]
  ida = poly_id_at(m1_polys, lab[a][0], lab[a][1], tol) ||
        poly_id_at(m2_polys, lab[a][0], lab[a][1], tol)
  idb = poly_id_at(m1_polys, lab[b][0], lab[b][1], tol) ||
        poly_id_at(m2_polys, lab[b][0], lab[b][1], tol)
  return false if ida.nil? || idb.nil?
  uf.same?(ida, idb)
end

m1 = collect_polygons(cell, layout.layer(31, 0))
m2 = collect_polygons(cell, layout.layer(32, 0))
via = collect_polygons(cell, layout.layer(30, 0))
m1c_layer = layout.layer(31, 2)

labels = {}
[layout.layer(31, 1), layout.layer(32, 1)].each do |li|
  cell.shapes(li).each do |s|
    next unless s.is_text?
    t = s.text
    labels[t.string] = [t.trans.disp.x, t.trans.disp.y]
  end
end

TOL = 200
ok = true
msgs = []

uf, m1_polys, m2_polys = build_nets(m1, m2, via)

# Rule A: transformer isolation (P1 must not net to S1)
if NPORTS >= 4
  if labels["P1"] && labels["S1"] && ports_connected?(uf, m1_polys, m2_polys, labels, "P1", "S1", TOL)
    ok = false
    msgs << "primary shorted to secondary (galvanic)"
  end
end

# Rule B: M1 island count (allow exit pad when vias present)
if NPORTS <= 3
  max_m1 = via.count >= 1 ? 2 : 1
  # figure8: two spiral bodies on M1 + optional extras
  max_m1 = 2 if (cfg["shape"] || "") == "figure8"
  if m1.count > max_m1
    ok = false
    msgs << "M1 has #{m1.count} pieces (max #{max_m1})"
  end
end

# Rule C: cut-test
if NPORTS <= 3 && labels["P1"] && labels["P2"]
  unless ports_connected?(uf, m1_polys, m2_polys, labels, "P1", "P2", TOL)
    ok = false
    msgs << "baseline: P1 not connected to P2"
  else
    paths = extract_paths(cell, m1c_layer).select { |p| p.size >= 4 }
    if paths.empty?
      ok = false
      msgs << "no centerline Path on 31/2 for cut-test"
    else
      pts = paths.max_by { |p|
        len = 0.0
        (0...p.size - 1).each do |i|
          dx = (p[i + 1].x - p[i].x).to_f
          dy = (p[i + 1].y - p[i].y).to_f
          len += Math.sqrt(dx * dx + dy * dy)
        end
        len
      }

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
        hw = (W * 1.05 / dbu).round
        hl = (W * 0.75 / dbu).round
        cut = Region.new(Polygon.new([
          Point.new((cx + px * hw + tx * hl).round, (cy + py * hw + ty * hl).round),
          Point.new((cx - px * hw + tx * hl).round, (cy - py * hw + ty * hl).round),
          Point.new((cx - px * hw - tx * hl).round, (cy - py * hw - ty * hl).round),
          Point.new((cx + px * hw - tx * hl).round, (cy + py * hw - ty * hl).round)
        ]))
        m1_cut = m1 - cut
        uf_c, m1p_c, m2p_c = build_nets(m1_cut, m2, via)
        if ports_connected?(uf_c, m1p_c, m2p_c, labels, "P1", "P2", TOL)
          still << format("frac=%.2f@(%d,%d)", frac, cx.round, cy.round)
        end
      end

      if still.any?
        ok = false
        msgs << "parallel short path(s) survive cut-test: #{still.join(', ')}"
      end
    end
  end
end

# Rule D: via caps
shape = (cfg["shape"] || "square").to_s
max_vias =
  if shape == "figure8"
    2
  else
    case NPORTS
    when 2 then 2
    when 3 then 3
    else 2
    end
  end

if via.count > max_vias
  ok = false
  msgs << "too many vias (#{via.count} > max #{max_vias})"
end

msg = if ok
        "SHORTS PASS — #{CELL} (single series path / isolation OK)"
      else
        "SHORTS FAIL — #{CELL}: #{msgs.join('; ')}"
      end
puts msg
puts "detail M1_polys=#{m1.count} vias=#{via.count} centerlines=#{extract_paths(cell, m1c_layer).size}"

File.write(LOG, "#{msg}\n#{msgs.join("\n")}\n") unless LOG.empty?
exit(ok ? 0 : 1)
