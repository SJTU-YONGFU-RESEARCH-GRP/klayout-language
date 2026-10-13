# KLayout PEX — M1 resistor extraction (built-in RNetExtractor)
#
# Layers (see generate_layout.rb):
#   M1 31/0   labels 90/0
#
# Ports A / B = leftmost / rightmost M1 polygons (pads) as polygon ports.
# Sheet resistance: 0.08 ohm/square (educational).
#
# Run: ./run_pex.sh
# Optional -rd: input, cell, report, spice, sheet_r, r_limit

include RBA

SHEET_R = ($sheet_r || 0.08).to_f
R_LIMIT = ($r_limit || 1.0).to_f
CELL    = ($cell || "R_GOOD").to_s
GDS     = ($input || File.join(__dir__, "r_demo.gds")).to_s
REPORT  = ($report || File.join(__dir__, "r_extract.txt")).to_s
SPICE   = ($spice || File.join(__dir__, "r_extracted.cir")).to_s

layout = Layout.new
layout.read(GDS)
cell = layout.cell(CELL)
raise "missing cell #{CELL} in #{GDS}" unless cell

dbu = layout.dbu
li_m1 = layout.layer(31, 0)

raw = Region.new(cell.begin_shapes_rec(li_m1))
raise "no M1 geometry in #{CELL}" if raw.is_empty?

polys = []
raw.each { |p| polys << p.dup }
polys.sort_by! { |p| [p.bbox.left, p.bbox.bottom] }
raise "need at least 2 M1 shapes (pad A, pad B)" if polys.size < 2

pad_a = polys.first
pad_b = polys.last

# Body = remaining shapes (or full net if only 2 shapes)
body = polys.size >= 3 ? polys[1..-2] : []
if body.empty?
  est_l = (pad_b.bbox.left - pad_a.bbox.right) * dbu
  est_w = [pad_a.bbox.height, pad_b.bbox.height].min * dbu
else
  bb = body[0].bbox
  body[1..-1].each { |p| bb += p.bbox }
  est_l = bb.width * dbu
  est_w = body.map { |p| p.bbox.height * dbu }.min
end
est_sq = est_w > 0 ? est_l / est_w : 0.0
est_r  = est_sq * SHEET_R

merged = raw.dup
merged.merge

tech = RExtractorTech.new
cond = RExtractorTechConductor.new
cond.layer = 31
cond.resistance = SHEET_R
cond.algorithm = RExtractorTechConductor::SquareCounting
tech.add_conductor(cond)

geo = { 31 => merged }
vertex_ports = {}
polygon_ports = { 31 => [pad_a, pad_b] }

rex = RNetExtractor.new(dbu)
network = rex.extract(tech, geo, vertex_ports, polygon_ports)
network.simplify

r_total = 0.0
elements = []
network.each_element do |e|
  r_total += e.resistance
  elements << e
end

n_nodes = 0
network.each_node { n_nodes += 1 }

ok = r_total < R_LIMIT
status = ok ? "PASS" : "FAIL"

lines = []
lines << "KLayout PEX — M1 resistor extraction"
lines << "  cell:          #{CELL}"
lines << "  gds:           #{GDS}"
lines << "  sheet_r:       #{SHEET_R} ohm/sq"
lines << "  r_limit:       #{R_LIMIT} ohm  (PASS if R < limit)"
lines << "  geometry:      L=#{sprintf('%.3f', est_l)} um  W=#{sprintf('%.3f', est_w)} um  (#{sprintf('%.2f', est_sq)} sq)"
lines << "  expected_R:    #{sprintf('%.4f', est_r)} ohm  (L/W * sheet)"
lines << "  extracted_R:   #{sprintf('%.6f', r_total)} ohm  (#{elements.size} element(s), #{n_nodes} nodes)"
elements.each_with_index do |e, i|
  lines << "    R#{i}: #{sprintf('%.6f', e.resistance)} ohm   #{e}"
end
lines << "  network:       #{network}"
lines << "PEX #{status} — #{CELL}  R=#{sprintf('%.4f', r_total)} ohm  (limit #{R_LIMIT})"

text = lines.join("\n") + "\n"
File.write(REPORT, text)
puts text

spice = []
spice << "* Extracted by KLayout PEX demo (RNetExtractor / SquareCounting)"
spice << "* cell=#{CELL}  sheet=#{SHEET_R} ohm/sq  R=#{sprintf('%.6f', r_total)}"
spice << ".SUBCKT #{CELL} A B"
spice << sprintf("R1 A B %.6g", r_total)
spice << ".ENDS"
spice << ""
File.write(SPICE, spice.join("\n"))
puts "Wrote #{SPICE}"
puts "Wrote #{REPORT}"
