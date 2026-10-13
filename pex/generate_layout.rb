# Generate pex_demo.gds — R and C GOOD/BAD cells for KLayout PEX demos.
#
#   klayout -b -r generate_layout.rb -rd output=pex_demo.gds
#   ./run_pex.sh --gen-only
#
# Layers: 31/0 M1   32/0 M2   90/0 labels
#
# R_GOOD — short, wide M1 → few squares → low R
# R_BAD  — long, narrow M1 → many squares → high R
# C_GOOD — large M1∩M2 overlap → high C
# C_BAD  — tiny overlap (misaligned plates) → low C

include RBA

OUTPUT = ($output || File.join(__dir__, "pex_demo.gds")).to_s

SHEET_R  = 0.08      # ohm / square (R demo)
AREA_CAP = 1.0e-15   # F / µm² (C demo)

layout = Layout.new
layout.dbu = 0.001

ly_m1  = layout.layer(31, 0)
ly_m2  = layout.layer(32, 0)
ly_lbl = layout.layer(90, 0)

def dbu(layout, um)
  (um / layout.dbu).round
end

def add_box(cell, layer, layout, x, y, w, h)
  cell.shapes(layer).insert(Box.new(
    dbu(layout, x), dbu(layout, y),
    dbu(layout, x + w), dbu(layout, y + h)
  ))
end

def add_label(cell, layer, layout, x, y, text, height_um = 0.12)
  t = Text.new(text, dbu(layout, x), dbu(layout, y))
  t.size = dbu(layout, height_um)
  cell.shapes(layer).insert(t)
end

def draw_resistor(cell, layout, ly_m1, ly_lbl, body_l:, body_w:, pad: 0.40, y0: 0.0)
  pad_y = y0
  body_y = y0
  if pad > body_w
    body_y = y0 + (pad - body_w) / 2.0
  else
    pad_y = y0 + (body_w - pad) / 2.0
  end

  add_box(cell, ly_m1, layout, 0.0, pad_y, pad, pad)
  add_label(cell, ly_lbl, layout, 0.08, pad_y + pad + 0.05, "A")

  add_box(cell, ly_m1, layout, pad, body_y, body_l, body_w)

  bx = pad + body_l
  add_box(cell, ly_m1, layout, bx, pad_y, pad, pad)
  add_label(cell, ly_lbl, layout, bx + 0.08, pad_y + pad + 0.05, "B")

  nsq = body_l / body_w
  add_label(cell, ly_lbl, layout, pad + 0.05, [pad_y + pad, body_y + body_w].max + 0.08,
            sprintf("L=%.2f W=%.2f  ~%.1f sq", body_l, body_w, nsq), 0.08)
end

# Parallel-plate capacitor: bottom M1, top M2. Overlap area → C = A * AREA_CAP.
def draw_capacitor(cell, layout, ly_m1, ly_m2, ly_lbl, m1:, m2:, note:)
  x1, y1, w1, h1 = m1
  x2, y2, w2, h2 = m2
  add_box(cell, ly_m1, layout, x1, y1, w1, h1)
  add_box(cell, ly_m2, layout, x2, y2, w2, h2)
  add_label(cell, ly_lbl, layout, x1, y1 + h1 + 0.08, "M1", 0.10)
  add_label(cell, ly_lbl, layout, x2, y2 + h2 + 0.08, "M2", 0.10)

  # Overlap bbox (axis-aligned)
  ox0 = [x1, x2].max
  oy0 = [y1, y2].max
  ox1 = [x1 + w1, x2 + w2].min
  oy1 = [y1 + h1, y2 + h2].min
  ow = [ox1 - ox0, 0.0].max
  oh = [oy1 - oy0, 0.0].max
  area = ow * oh
  add_label(cell, ly_lbl, layout, ox0, oy0 - 0.20,
            sprintf("overlap=%.2f um^2  C~%.2ffF", area, area * AREA_CAP * 1e15), 0.09)
  add_label(cell, ly_lbl, layout, x1, [y1, y2].min - 0.45, note, 0.11)
end

# ---------------------------------------------------------------------------
# R cells
# ---------------------------------------------------------------------------
r_good = layout.create_cell("R_GOOD")
draw_resistor(r_good, layout, ly_m1, ly_lbl, body_l: 2.0, body_w: 1.0, pad: 0.50)
add_label(r_good, ly_lbl, layout, 0.0, 1.55, "R_GOOD — expect low R (PASS)", 0.12)

r_bad = layout.create_cell("R_BAD")
draw_resistor(r_bad, layout, ly_m1, ly_lbl, body_l: 16.0, body_w: 0.20, pad: 0.40)
add_label(r_bad, ly_lbl, layout, 0.0, 0.95, "R_BAD — expect high R (FAIL)", 0.12)

# ---------------------------------------------------------------------------
# C cells — M1 / M2 plates
# ---------------------------------------------------------------------------
# GOOD: identical 3×3 plates → A=9 µm² → C=9 fF
c_good = layout.create_cell("C_GOOD")
draw_capacitor(c_good, layout, ly_m1, ly_m2, ly_lbl,
               m1: [0.0, 0.0, 3.0, 3.0],
               m2: [0.0, 0.0, 3.0, 3.0],
               note: "C_GOOD — large overlap (PASS)")

# BAD: M2 shifted → only 0.5×0.5 overlap → A=0.25 → C=0.25 fF
c_bad = layout.create_cell("C_BAD")
draw_capacitor(c_bad, layout, ly_m1, ly_m2, ly_lbl,
               m1: [0.0, 0.0, 3.0, 3.0],
               m2: [2.5, 2.5, 3.0, 3.0],
               note: "C_BAD — tiny overlap (FAIL)")

# ---------------------------------------------------------------------------
# DEMO topcells
# ---------------------------------------------------------------------------
r_demo = layout.create_cell("R_DEMO")
r_demo.insert(CellInstArray.new(r_good.cell_index, Trans.new(0, 0)))
r_demo.insert(CellInstArray.new(r_bad.cell_index, Trans.new(0, dbu(layout, -2.5))))
add_label(r_demo, ly_lbl, layout, 0.0, 1.75, "PEX R — GOOD vs BAD", 0.14)
add_label(r_demo, ly_lbl, layout, 0.0, 1.50, "M1=31/0  sheet=#{SHEET_R} ohm/sq", 0.10)

c_demo = layout.create_cell("C_DEMO")
c_demo.insert(CellInstArray.new(c_good.cell_index, Trans.new(0, 0)))
c_demo.insert(CellInstArray.new(c_bad.cell_index, Trans.new(dbu(layout, 7.0), 0)))
add_label(c_demo, ly_lbl, layout, 0.0, 3.6, "PEX C — GOOD vs BAD", 0.14)
add_label(c_demo, ly_lbl, layout, 0.0, 3.35, "M1=31/0  M2=32/0  area_cap=#{AREA_CAP} F/um^2", 0.10)
add_label(c_demo, ly_lbl, layout, 0.5, -0.7, "GOOD", 0.14)
add_label(c_demo, ly_lbl, layout, 7.5, -0.7, "BAD", 0.14)

top = layout.create_cell("PEX_DEMO")
top.insert(CellInstArray.new(r_demo.cell_index, Trans.new(0, 0)))
top.insert(CellInstArray.new(c_demo.cell_index, Trans.new(0, dbu(layout, -8.0))))
add_label(top, ly_lbl, layout, 0.0, 2.1, "PEX demo — R (top) + C (bottom)", 0.16)

layout.write(OUTPUT)
# Keep legacy alias for older scripts / screenshots
legacy = File.join(File.dirname(OUTPUT), "r_demo.gds")
layout.write(legacy) if OUTPUT != legacy

puts "Wrote #{OUTPUT}"
puts "  R: R_GOOD (0.16 ohm PASS), R_BAD (6.40 ohm FAIL), R_DEMO"
puts "  C: C_GOOD (9 fF PASS), C_BAD (0.25 fF FAIL), C_DEMO"
puts "  Top: PEX_DEMO"
puts "  sheet_r=#{SHEET_R} ohm/sq   area_cap=#{AREA_CAP} F/um^2"
