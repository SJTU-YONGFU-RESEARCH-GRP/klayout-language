# Generate m1_contact_demo.gds — M1_CT_GOOD / M1_CT_BAD / M1_CT_DRC_DEMO.
#
#   klayout -b -r generate_layout.rb -rd output=m1_contact_demo.gds
#   ./run_klayout_drc.sh --gen-only
#
# GOOD → expect 0 DRC violations; BAD → expect violations; DEMO = both (viewing).

include RBA

OUTPUT = ($output || File.join(__dir__, "m1_contact_demo.gds")).to_s

M1_LAYER = 31
CT_LAYER = 30
LBL_LAYER = 90

layout = RBA::Layout.new
layout.dbu = 0.001

m1 = layout.layer(M1_LAYER, 0)
ct = layout.layer(CT_LAYER, 0)
lbl = layout.layer(LBL_LAYER, 0)

def dbu(layout, um)
  (um / layout.dbu).round
end

def add_box(cell, layer, layout, x, y, w, h)
  cell.shapes(layer).insert(RBA::Box.new(
    dbu(layout, x), dbu(layout, y),
    dbu(layout, x + w), dbu(layout, y + h)
  ))
end

def add_label(cell, layer, layout, x, y, text, height_um = 0.12)
  t = RBA::Text.new(text, dbu(layout, x), dbu(layout, y))
  t.size = dbu(layout, height_um)
  cell.shapes(layer).insert(t)
end

def add_m1_pad(cell, m1_layer, layout, cx, cy, ct_w, ct_h, enc)
  add_box(cell, m1_layer, layout, cx - enc, cy - enc, ct_w + 2.0 * enc, ct_h + 2.0 * enc)
end

def add_contact(cell, ct_layer, layout, x, y, w, h)
  add_box(cell, ct_layer, layout, x, y, w, h)
end

def add_m1_slab(cell, m1_layer, layout, x, y, w, h, enc = 0.08)
  add_box(cell, m1_layer, layout, x - enc, y - enc, w + 2.0 * enc, h + 2.0 * enc)
end

# Draw rows into cell. Each entry: [y, label, draw_lambda]
def draw_rows(cell, layout, layers, rows, title:)
  m1, ct, lbl = layers
  rows.each do |y, text, draw|
    draw.call(cell, m1, ct, layout)
    add_label(cell, lbl, layout, 0.2, y + 0.35, text)
  end
  add_label(cell, lbl, layout, 0.2, rows.first[0] + 2.5, title, 0.14)
end

layers = [m1, ct, lbl]

# ---------------------------------------------------------------------------
# GOOD — all structures pass the demo rules
# ---------------------------------------------------------------------------
good_rows = [
  [12.0, "GOOD M1 width 0.20um", lambda { |cell, m1, _ct, layout|
    add_box(cell, m1, layout, 8.0, 12.0, 0.20, 1.5)
  }],
  [9.0, "GOOD M1 space 0.20um", lambda { |cell, m1, _ct, layout|
    add_box(cell, m1, layout, 8.0, 9.0, 0.30, 1.5)
    add_box(cell, m1, layout, 8.0 + 0.30 + 0.20, 9.0, 0.30, 1.5)
  }],
  [6.0, "GOOD CT 0.20 + M1 enc 0.08", lambda { |cell, m1, ct, layout|
    cx, cy, cw, ch = 8.5, 6.2, 0.20, 0.20
    add_m1_pad(cell, m1, layout, cx, cy, cw, ch, 0.08)
    add_contact(cell, ct, layout, cx, cy, cw, ch)
  }],
  [3.0, "GOOD CT space 0.25um", lambda { |cell, m1, ct, layout|
    x0, y0, cw, ch, gap = 8.0, 3.2, 0.20, 0.20, 0.25
    add_m1_slab(cell, m1, layout, x0, y0, cw + gap + cw, ch)
    add_contact(cell, ct, layout, x0, y0, cw, ch)
    add_contact(cell, ct, layout, x0 + cw + gap, y0, cw, ch)
  }]
]

good = layout.create_cell("M1_CT_GOOD")
draw_rows(good, layout, layers, good_rows, title: "M1_CT_GOOD — expect DRC PASS")

# ---------------------------------------------------------------------------
# BAD — one intentional violation per rule
# ---------------------------------------------------------------------------
bad_rows = [
  [12.0, "BAD M1 width 0.10um", lambda { |cell, m1, _ct, layout|
    add_box(cell, m1, layout, 8.0, 12.0, 0.10, 1.5)
  }],
  [9.0, "BAD M1 space 0.08um", lambda { |cell, m1, _ct, layout|
    add_box(cell, m1, layout, 8.0, 9.0, 0.30, 1.5)
    add_box(cell, m1, layout, 8.0 + 0.30 + 0.08, 9.0, 0.30, 1.5)
  }],
  [6.0, "BAD M1 enc 0.03 (<0.055)", lambda { |cell, m1, ct, layout|
    cx, cy, cw, ch = 8.5, 6.2, 0.20, 0.20
    add_m1_pad(cell, m1, layout, cx, cy, cw, ch, 0.03)
    add_contact(cell, ct, layout, cx, cy, cw, ch)
  }],
  [3.0, "BAD CT space 0.12um", lambda { |cell, m1, ct, layout|
    x0, y0, cw, ch, gap = 8.0, 3.2, 0.20, 0.20, 0.12
    add_m1_slab(cell, m1, layout, x0, y0, cw + gap + cw, ch)
    add_contact(cell, ct, layout, x0, y0, cw, ch)
    add_contact(cell, ct, layout, x0 + cw + gap, y0, cw, ch)
  }],
  [0.0, "BAD CT width 0.12um", lambda { |cell, m1, ct, layout|
    x0, y0, cw, ch = 8.0, 0.2, 0.12, 0.20
    add_m1_pad(cell, m1, layout, x0, y0, cw, ch, 0.08)
    add_contact(cell, ct, layout, x0, y0, cw, ch)
  }]
]

bad = layout.create_cell("M1_CT_BAD")
draw_rows(bad, layout, layers, bad_rows, title: "M1_CT_BAD — expect DRC FAIL")

# ---------------------------------------------------------------------------
# DEMO — GOOD (left) + BAD (right) for screenshots / Calibre topcell
# ---------------------------------------------------------------------------
top = layout.create_cell("M1_CT_DRC_DEMO")
top.insert(RBA::CellInstArray.new(good.cell_index, RBA::Trans.new(0, 0)))
top.insert(RBA::CellInstArray.new(bad.cell_index, RBA::Trans.new(dbu(layout, 18.0), 0)))
add_label(top, lbl, layout, 0.2, 15.5, "GOOD", 0.18)
add_label(top, lbl, layout, 18.2, 15.5, "BAD", 0.18)
add_label(top, lbl, layout, 0.2, 16.3, "M1/Contact DRC — GOOD vs BAD", 0.16)
add_label(top, lbl, layout, 0.2, -1.2, "Layers: M1=31/0  CT=30/0  Labels=90/0", 0.10)

layout.write(OUTPUT)
puts "Wrote #{OUTPUT}"
puts "  Cells: M1_CT_GOOD (expect PASS), M1_CT_BAD (expect FAIL), M1_CT_DRC_DEMO"
