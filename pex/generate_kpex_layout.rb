# Generate kpex_demo.gds — sky130A li1 sidewall CC GOOD/BAD for KLayout-PEX.
#
#   klayout -b -r generate_kpex_layout.rb -rd output=kpex_demo.gds
#   ./run_kpex.sh --gen-only
#
# Layers (sky130A):
#   67/20  li1 drawing
#   67/16  li1 pin
#   67/5   li1 net label (A / B)
#   90/0   annotation (screenshots)
#   100/0  BAD marker
#
# CC_GOOD — parallel li1 strips, gap = 0.2 µm → large C_AB (sidewall)
# CC_BAD  — same strips, gap = 5.0 µm → small C_AB
# C_PLATE — 100×100 µm li1 plate over substrate (C to VSUBS)

include RBA

OUTPUT = ($output || File.join(__dir__, "kpex_demo.gds")).to_s

LENGTH_UM = 20.0
WIDTH_UM  = 1.0
GAP_GOOD  = 0.20   # µm
GAP_BAD   = 5.00   # µm
PIN_UM    = 1.0

layout = Layout.new
layout.dbu = 0.001

ly_li   = layout.layer(67, 20)
ly_pin  = layout.layer(67, 16)
ly_lab  = layout.layer(67, 5)
ly_ann  = layout.layer(90, 0)
ly_mark = layout.layer(100, 0)

def dbu(layout, um)
  (um / layout.dbu).round
end

def add_box(cell, layer, layout, x, y, w, h)
  cell.shapes(layer).insert(Box.new(
    dbu(layout, x), dbu(layout, y),
    dbu(layout, x + w), dbu(layout, y + h)
  ))
end

def add_label(cell, layer, layout, x, y, text, height_um = 0.0)
  t = Text.new(text, dbu(layout, x), dbu(layout, y))
  t.size = dbu(layout, height_um)
  cell.shapes(layer).insert(t)
end

# Two parallel li1 strips along X; lower = B, upper = A.
def draw_sidewall_cc(cell, layout, ly_li, ly_pin, ly_lab, ly_ann,
                     length:, width:, gap:, note:)
  y_b = 0.0
  y_a = width + gap

  add_box(cell, ly_li, layout, 0.0, y_b, length, width)
  add_box(cell, ly_li, layout, 0.0, y_a, length, width)

  add_box(cell, ly_pin, layout, 0.0, y_b, PIN_UM, width)
  add_box(cell, ly_pin, layout, 0.0, y_a, PIN_UM, width)

  # Net labels on 67/5 — required for kpex LVS connectivity
  add_label(cell, ly_lab, layout, 0.0, y_b, "B", 0.0)
  add_label(cell, ly_lab, layout, 0.0, y_a, "A", 0.0)

  add_label(cell, ly_ann, layout, 0.2, y_a + width + 0.15, note, 0.12)
  add_label(cell, ly_ann, layout, length * 0.35, y_b + width + gap * 0.35,
            sprintf("gap=%.2f um", gap), 0.10)
end

# --- CC_GOOD ---
cc_good = layout.create_cell("CC_GOOD")
draw_sidewall_cc(cc_good, layout, ly_li, ly_pin, ly_lab, ly_ann,
                 length: LENGTH_UM, width: WIDTH_UM, gap: GAP_GOOD,
                 note: "CC_GOOD  close sidewall")

# --- CC_BAD ---
cc_bad = layout.create_cell("CC_BAD")
draw_sidewall_cc(cc_bad, layout, ly_li, ly_pin, ly_lab, ly_ann,
                 length: LENGTH_UM, width: WIDTH_UM, gap: GAP_BAD,
                 note: "CC_BAD  far sidewall")
# Magenta highlight around upper strip for screenshots
add_box(cc_bad, ly_mark, layout, -0.15, WIDTH_UM + GAP_BAD - 0.15,
        LENGTH_UM + 0.30, WIDTH_UM + 0.30)

# --- C_PLATE (optional plate-to-substrate) ---
c_plate = layout.create_cell("C_PLATE")
add_box(c_plate, ly_li, layout, 0.0, 0.0, 100.0, 100.0)
add_box(c_plate, ly_pin, layout, 0.0, 0.0, 20.0, 20.0)
add_label(c_plate, ly_lab, layout, 0.2, 0.2, "PLATE", 0.0)
add_label(c_plate, ly_ann, layout, 2.0, 102.0, "C_PLATE  li1 over substrate", 0.40)

# --- CC_DEMO (side-by-side for screenshots) ---
demo = layout.create_cell("CC_DEMO")
demo.insert(CellInstArray.new(cc_good.cell_index, Trans.new(dbu(layout, 0), dbu(layout, 0))))
demo.insert(CellInstArray.new(cc_bad.cell_index, Trans.new(dbu(layout, 0), dbu(layout, 12))))
add_label(demo, ly_ann, layout, 0.0, 3.0, "GOOD  gap=0.20 um", 0.25)
add_label(demo, ly_ann, layout, 0.0, 19.5, "BAD  gap=5.00 um", 0.25)

layout.write(OUTPUT)
puts "Wrote #{OUTPUT}"
puts "  CC_GOOD  L=#{LENGTH_UM} W=#{WIDTH_UM} gap=#{GAP_GOOD} um"
puts "  CC_BAD   L=#{LENGTH_UM} W=#{WIDTH_UM} gap=#{GAP_BAD} um"
puts "  C_PLATE  100 x 100 um"
puts "  CC_DEMO  overview"
