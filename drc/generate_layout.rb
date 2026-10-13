# Generate m1_contact_demo.gds — labeled GOOD/BAD rows for M1 + Contact DRC.
#
#   klayout -b -r generate_layout.rb -rd output=m1_contact_demo.gds
#   ./run_klayout_drc.sh --gen-only

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

cell = layout.create_cell("M1_CT_DRC_DEMO")

def dbu(layout, um)
  (um / layout.dbu).round
end

def add_box(cell, layer, layout, x, y, w, h)
  x0 = dbu(layout, x)
  y0 = dbu(layout, y)
  x1 = dbu(layout, x + w)
  y1 = dbu(layout, y + h)
  cell.shapes(layer).insert(RBA::Box.new(x0, y0, x1, y1))
end

def add_label(cell, layer, layout, x, y, text, height_um = 0.12)
  t = RBA::Text.new(text, dbu(layout, x), dbu(layout, y))
  t.size = dbu(layout, height_um)
  cell.shapes(layer).insert(t)
end

def add_m1_pad(cell, m1_layer, layout, cx, cy, ct_w, ct_h, enc)
  pad_w = ct_w + 2.0 * enc
  pad_h = ct_h + 2.0 * enc
  add_box(cell, m1_layer, layout, cx - enc, cy - enc, pad_w, pad_h)
end

def add_contact(cell, ct_layer, layout, x, y, w, h)
  add_box(cell, ct_layer, layout, x, y, w, h)
end

# M1 slab covering a contact array region (keeps enclosure checks clean).
def add_m1_slab(cell, m1_layer, layout, x, y, w, h, enc = 0.08)
  add_box(cell, m1_layer, layout, x - enc, y - enc, w + 2.0 * enc, h + 2.0 * enc)
end

# ---------------------------------------------------------------------------
# Row layout (µm). Each row is ~2.5 µm tall; labels sit to the left.
# ---------------------------------------------------------------------------
rows = [
  # [y, label, :good | :bad, block]
  [22.0, "GOOD M1 width 0.20um", :good, lambda {
    add_box(cell, m1, layout, 8.0, 22.0, 0.20, 1.5)
  }],
  [19.0, "BAD  M1 width 0.10um", :bad, lambda {
    add_box(cell, m1, layout, 8.0, 19.0, 0.10, 1.5)
  }],
  [16.0, "GOOD M1 space 0.20um", :good, lambda {
    add_box(cell, m1, layout, 8.0, 16.0, 0.30, 1.5)
    add_box(cell, m1, layout, 8.0 + 0.30 + 0.20, 16.0, 0.30, 1.5)
  }],
  [13.0, "BAD  M1 space 0.08um", :bad, lambda {
    add_box(cell, m1, layout, 8.0, 13.0, 0.30, 1.5)
    add_box(cell, m1, layout, 8.0 + 0.30 + 0.08, 13.0, 0.30, 1.5)
  }],
  [10.0, "GOOD CT 0.20 + M1 enc 0.08", :good, lambda {
    cx, cy, cw, ch = 8.5, 10.2, 0.20, 0.20
    add_m1_pad(cell, m1, layout, cx, cy, cw, ch, 0.08)
    add_contact(cell, ct, layout, cx, cy, cw, ch)
  }],
  [7.0, "BAD  M1 enc 0.03 (<0.055)", :bad, lambda {
    cx, cy, cw, ch = 8.5, 7.2, 0.20, 0.20
    add_m1_pad(cell, m1, layout, cx, cy, cw, ch, 0.03)
    add_contact(cell, ct, layout, cx, cy, cw, ch)
  }],
  [4.0, "GOOD CT space 0.25um", :good, lambda {
    x0, y0, cw, ch, gap = 8.0, 4.2, 0.20, 0.20, 0.25
    add_m1_slab(cell, m1, layout, x0, y0, cw + gap + cw, ch)
    add_contact(cell, ct, layout, x0, y0, cw, ch)
    add_contact(cell, ct, layout, x0 + cw + gap, y0, cw, ch)
  }],
  [1.0, "BAD  CT space 0.12um", :bad, lambda {
    x0, y0, cw, ch, gap = 8.0, 1.2, 0.20, 0.20, 0.12
    add_m1_slab(cell, m1, layout, x0, y0, cw + gap + cw, ch)
    add_contact(cell, ct, layout, x0, y0, cw, ch)
    add_contact(cell, ct, layout, x0 + cw + gap, y0, cw, ch)
  }],
  [-2.0, "BAD  CT width 0.12um", :bad, lambda {
    x0, y0, cw, ch = 8.0, -1.8, 0.12, 0.20
    add_m1_pad(cell, m1, layout, x0, y0, cw, ch, 0.08)
    add_contact(cell, ct, layout, x0, y0, cw, ch)
  }]
]

rows.each do |y, text, _kind, draw|
  draw.call
  add_label(cell, lbl, layout, 0.2, y + 0.35, text)
end

add_label(cell, lbl, layout, 0.2, 24.5, "M1/Contact DRC demo — GOOD vs BAD rows", 0.15)
add_label(cell, lbl, layout, 0.2, 23.8, "Layers: M1=31/0  CT=30/0  Labels=90/0", 0.10)
layout.write(OUTPUT)
puts "Wrote #{OUTPUT}"
