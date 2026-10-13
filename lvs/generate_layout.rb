# Generate nmos_demo.gds — good and bad NMOS layouts for KLayout LVS.
#
# Batch: klayout -b -r generate_layout.rb -rd output=nmos_demo.gds
#
# Layers:
#   1/0 DIFF (n-active)  2/0 POLY  3/0 CONT  4/0 METAL1  4/1 labels
#   6/0 PTIE (p-substrate tap for bulk)

include RBA

OUTPUT = ($output || File.join(__dir__, "nmos_demo.gds")).to_s

L_UM = 0.18
W_UM = 0.50
SD_UM = 0.40
POLY_OVER = 0.20
CONT = 0.16
ENC = 0.05

layout = RBA::Layout.new
layout.dbu = 0.001

ly_diff = layout.layer(1, 0)
ly_poly = layout.layer(2, 0)
ly_cont = layout.layer(3, 0)
ly_m1   = layout.layer(4, 0)
ly_lbl  = layout.layer(4, 1)
ly_ptie = layout.layer(6, 0)

def dbu(layout, um)
  (um / layout.dbu).round
end

def add_box(cell, layer, layout, x, y, w, h)
  cell.shapes(layer).insert(RBA::Box.new(
    dbu(layout, x), dbu(layout, y),
    dbu(layout, x + w), dbu(layout, y + h)
  ))
end

def add_label(cell, layer, layout, x, y, text)
  t = RBA::Text.new(text, dbu(layout, x), dbu(layout, y))
  t.size = dbu(layout, 0.12)
  cell.shapes(layer).insert(t)
end

def draw_nmos(cell, layout, layers, short_sd:)
  ly_diff, ly_poly, ly_cont, ly_m1, ly_lbl, ly_ptie = layers

  act_w = SD_UM + L_UM + SD_UM
  poly_x = SD_UM

  # Active (diff) + poly gate → L=0.18, W=0.50
  add_box(cell, ly_diff, layout, 0.0, 0.0, act_w, W_UM)
  add_box(cell, ly_poly, layout, poly_x, -POLY_OVER, L_UM, W_UM + 2.0 * POLY_OVER)

  # Source
  sx = (SD_UM - CONT) / 2.0
  sy = (W_UM - CONT) / 2.0
  add_box(cell, ly_cont, layout, sx, sy, CONT, CONT)
  add_box(cell, ly_m1, layout, sx - ENC, sy - ENC, CONT + 2.0 * ENC, CONT + 2.0 * ENC)
  add_label(cell, ly_lbl, layout, sx, sy + CONT + 0.05, "S")

  # Drain
  dx = SD_UM + L_UM + (SD_UM - CONT) / 2.0
  add_box(cell, ly_cont, layout, dx, sy, CONT, CONT)
  add_box(cell, ly_m1, layout, dx - ENC, sy - ENC, CONT + 2.0 * ENC, CONT + 2.0 * ENC)
  add_label(cell, ly_lbl, layout, dx, sy + CONT + 0.05, "D")

  # Gate contact on poly overhang (above active)
  gx = poly_x + (L_UM - CONT) / 2.0
  gy = W_UM + 0.02
  add_box(cell, ly_cont, layout, gx, gy, CONT, CONT)
  add_box(cell, ly_m1, layout, gx - ENC, gy - ENC, CONT + 2.0 * ENC, CONT + 2.0 * ENC)
  add_label(cell, ly_lbl, layout, gx, gy + CONT + 0.05, "G")

  # Bulk / substrate tap (PTIE) — not overlapping transistor contacts
  bx = act_w + 0.30
  by = (W_UM - CONT) / 2.0
  add_box(cell, ly_ptie, layout, bx, by - 0.05, CONT + 0.10, CONT + 0.10)
  add_box(cell, ly_cont, layout, bx + 0.05, by, CONT, CONT)
  add_box(cell, ly_m1, layout, bx + 0.05 - ENC, by - ENC, CONT + 2.0 * ENC, CONT + 2.0 * ENC)
  add_label(cell, ly_lbl, layout, bx + 0.05, by + CONT + 0.05, "B")

  if short_sd
    # BAD: metal strap shorts S to D
    x0 = sx - ENC
    y0 = sy - ENC - 0.25
    w = (dx + CONT + ENC) - x0
    add_box(cell, ly_m1, layout, x0, y0, w, 0.18)
    add_label(cell, ly_lbl, layout, x0 + w * 0.4, y0 - 0.12, "SHORT")
  end
end

layers = [ly_diff, ly_poly, ly_cont, ly_m1, ly_lbl, ly_ptie]

good = layout.create_cell("NMOS_GOOD")
draw_nmos(good, layout, layers, short_sd: false)

bad = layout.create_cell("NMOS_BAD")
draw_nmos(bad, layout, layers, short_sd: true)

top = layout.create_cell("NMOS_DEMO")
top.insert(RBA::CellInstArray.new(good.cell_index, RBA::Trans.new(0, 0)))
top.insert(RBA::CellInstArray.new(bad.cell_index, RBA::Trans.new(dbu(layout, 4.0), 0)))
add_label(top, ly_lbl, layout, 0.0, 1.2, "GOOD")
add_label(top, ly_lbl, layout, 4.0, 1.2, "BAD (S-D short)")

layout.write(OUTPUT)
puts "Wrote #{OUTPUT}"
puts "  Cells: NMOS_GOOD (expect LVS PASS), NMOS_BAD (expect LVS FAIL), NMOS_DEMO"
