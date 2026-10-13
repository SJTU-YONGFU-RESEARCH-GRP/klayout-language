# Generate r_demo.gds — R_GOOD / R_BAD / R_DEMO for KLayout PEX (R extraction).
#
#   klayout -b -r generate_layout.rb -rd output=r_demo.gds
#   ./run_pex.sh --gen-only
#
# Layers: 31/0 M1   90/0 labels
#
# GOOD — short, wide M1 → few squares → low R
# BAD  — long, narrow M1 → many squares → high R

include RBA

OUTPUT = ($output || File.join(__dir__, "r_demo.gds")).to_s

# Educational sheet resistance used by extract_r.rb (ohm / square)
SHEET_R = 0.08

layout = Layout.new
layout.dbu = 0.001

ly_m1  = layout.layer(31, 0)
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

# Draw an M1 resistor: pad_a — body — pad_b along +x.
# Returns [pad_a_box_um, pad_b_box_um, body_l, body_w] for extract script metadata.
def draw_resistor(cell, layout, ly_m1, ly_lbl, body_l:, body_w:, pad: 0.40, y0: 0.0)
  # Center body on pads vertically
  pad_y = y0 + (body_w - pad).abs / 2.0
  body_y = y0
  if pad > body_w
    body_y = y0 + (pad - body_w) / 2.0
    pad_y = y0
  end

  # Pad A (port 0)
  add_box(cell, ly_m1, layout, 0.0, pad_y, pad, pad)
  add_label(cell, ly_lbl, layout, 0.08, pad_y + pad + 0.05, "A")

  # Resistor body
  add_box(cell, ly_m1, layout, pad, body_y, body_l, body_w)

  # Pad B (port 1)
  bx = pad + body_l
  add_box(cell, ly_m1, layout, bx, pad_y, pad, pad)
  add_label(cell, ly_lbl, layout, bx + 0.08, pad_y + pad + 0.05, "B")

  nsq = body_l / body_w
  add_label(cell, ly_lbl, layout, pad + 0.05, body_y + body_w + 0.08,
            sprintf("L=%.2f W=%.2f  ~%.1f sq", body_l, body_w, nsq), 0.08)

  [
    [0.0, pad_y, pad, pad],
    [bx, pad_y, pad, pad],
    body_l,
    body_w
  ]
end

# ---------------------------------------------------------------------------
# GOOD — L=2.0 µm, W=1.0 µm → 2 squares → R ≈ 0.16 Ω @ 0.08 Ω/□
# ---------------------------------------------------------------------------
good = layout.create_cell("R_GOOD")
draw_resistor(good, layout, ly_m1, ly_lbl, body_l: 2.0, body_w: 1.0, pad: 0.50)
add_label(good, ly_lbl, layout, 0.0, 1.4, "R_GOOD — expect low R (PASS)", 0.12)

# ---------------------------------------------------------------------------
# BAD — L=16.0 µm, W=0.20 µm → 80 squares → R ≈ 6.4 Ω @ 0.08 Ω/□
# ---------------------------------------------------------------------------
bad = layout.create_cell("R_BAD")
draw_resistor(bad, layout, ly_m1, ly_lbl, body_l: 16.0, body_w: 0.20, pad: 0.40)
add_label(bad, ly_lbl, layout, 0.0, 0.9, "R_BAD — expect high R (FAIL)", 0.12)

# ---------------------------------------------------------------------------
# DEMO — GOOD (top) + BAD (bottom)
# ---------------------------------------------------------------------------
top = layout.create_cell("R_DEMO")
top.insert(CellInstArray.new(good.cell_index, Trans.new(0, 0)))
top.insert(CellInstArray.new(bad.cell_index, Trans.new(0, dbu(layout, -2.5))))
add_label(top, ly_lbl, layout, 0.0, 1.7, "PEX R extraction — GOOD vs BAD", 0.14)
add_label(top, ly_lbl, layout, 0.0, 1.45, "M1=31/0  sheet=#{SHEET_R} ohm/sq", 0.10)
add_label(top, ly_lbl, layout, 0.0, -1.3, "GOOD", 0.14)
add_label(top, ly_lbl, layout, 0.0, -3.6, "BAD", 0.14)

layout.write(OUTPUT)
puts "Wrote #{OUTPUT}"
puts "  Cells: R_GOOD (low R / PASS), R_BAD (high R / FAIL), R_DEMO"
puts "  Sheet R used by extract: #{SHEET_R} ohm/sq"
