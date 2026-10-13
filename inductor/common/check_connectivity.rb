# Connectivity check for inductor ports (standalone RBA).
#
#   klayout -b -r check_connectivity.rb \
#     -rd input=...gds -rd cell=IND -rd ports=2 -rd log=out.log

include RBA

IN = ($input || "").to_s
CELL = ($cell || "").to_s
NPORTS = ($ports || "2").to_s.to_i
LOG = ($log || "").to_s

abort("need -rd input=") if IN.empty?

layout = Layout.new
layout.read(IN)
cell = CELL.empty? ? layout.top_cell : layout.cell(CELL)
abort("cell not found: #{CELL}") unless cell

m1 = layout.layer(31, 0)
m2 = layout.layer(32, 0)
via = layout.layer(30, 0)
m1t = layout.layer(31, 1)
m2t = layout.layer(32, 1)

labels = {}
[m1t, m2t].each do |li|
  cell.shapes(li).each do |s|
    next unless s.is_text?
    t = s.text
    labels[t.string] = [t.trans.disp.x, t.trans.disp.y]
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

# 2D connectivity including vias as bridges between M1/M2
stack = Region.new
stack.insert(collect_polygons(cell, m1))
stack.insert(collect_polygons(cell, m2))
stack.insert(collect_polygons(cell, via))
stack.merge

TOL = 200 # dbu @ 0.001 µm/dbu → 0.2 µm

def find_poly(region, x, y, tol)
  box = Box.new(x - tol, y - tol, x + tol, y + tol)
  region.each do |p|
    return p if p.touches(box) || p.inside(Point.new(x, y))
  end
  nil
end

def same_net?(stack, lab, a, b, tol)
  return false unless lab[a] && lab[b]
  xa, ya = lab[a]
  xb, yb = lab[b]
  pa = find_poly(stack, xa, ya, tol)
  pb = find_poly(stack, xb, yb, tol)
  return false if pa.nil? || pb.nil?
  pa.bbox == pb.bbox && (pa.area - pb.area).abs < 1.0
end

ok = true
msgs = []

needed =
  case NPORTS
  when 2 then %w[P1 P2]
  when 3 then %w[P1 P2 CT]
  else %w[P1 P2 S1 S2]
  end

needed.each do |n|
  unless labels[n]
    ok = false
    msgs << "missing label #{n}"
  end
end

if ok
  case NPORTS
  when 2
    unless same_net?(stack, labels, "P1", "P2", TOL)
      ok = false
      msgs << "P1 not DC-connected to P2"
    end
  when 3
    unless same_net?(stack, labels, "P1", "CT", TOL) && same_net?(stack, labels, "CT", "P2", TOL)
      ok = false
      msgs << "P1/CT/P2 not on one net"
    end
  else
    unless same_net?(stack, labels, "P1", "P2", TOL)
      ok = false
      msgs << "P1-P2 open"
    end
    unless same_net?(stack, labels, "S1", "S2", TOL)
      ok = false
      msgs << "S1-S2 open"
    end
    if same_net?(stack, labels, "P1", "S1", TOL)
      ok = false
      msgs << "primary shorted to secondary"
    end
  end
end

msg = ok ? "LVS PASS — #{CELL} ports=#{NPORTS} (connectivity)" : "LVS FAIL — #{CELL}: #{msgs.join('; ')}"
puts "labels=#{labels.keys.sort.join(',')}"
puts msg

File.write(LOG, "#{msg}\nlabels=#{labels.keys.sort.join(',')}\n") unless LOG.empty?
exit(ok ? 0 : 1)
