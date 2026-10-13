# Capture PNG screenshots for drc/ and lvs/ README images.
#
#   ./scripts/run_capture_screenshots.sh
#
# Needs a display (Xvfb is fine). Do not use -b/-zz — MainWindow is required.
#
# Per-testcase zoom shots include drawn dimension rulers and DRC error highlights.

include RBA

REPO = File.expand_path("..", __dir__)
SHOT = File.join(REPO, "screenshots")
Dir.mkdir(SHOT) unless File.directory?(SHOT)

# High-contrast hues (0xRRGGBB)
COLORS = {
  "31/0"  => [0x1E6AFF, "M1",   { transparent: true, dither: 1 }],   # blue outline+tint
  "30/0"  => [0xE63900, "CT",   { transparent: false, dither: 0 }],  # solid red-orange
  "90/0"  => [0x5B2C6F, "LABEL",{ transparent: false, dither: 0 }],  # purple
  "1/0"   => [0xE74C3C, "DIFF", { transparent: true, dither: 1 }],   # red
  "2/0"   => [0x27AE60, "POLY", { transparent: false, dither: 0 }],  # green
  "3/0"   => [0xF1C40F, "CONT", { transparent: false, dither: 0 }],  # yellow
  "4/0"   => [0x2980B9, "METAL1",{ transparent: true, dither: 1 }],  # blue
  "4/1"   => [0x8E44AD, "LABEL",{ transparent: false, dither: 0 }],  # purple
  "6/0"   => [0xD35400, "PTIE", { transparent: false, dither: 0 }],  # orange
  "100/0" => [0xFF00AA, "DRC_ERR",{ transparent: false, dither: 5 }],# magenta
  "101/0" => [0x111111, "DIM",  { transparent: false, dither: 0 }],  # black rulers
  "102/0" => [0x8E44AD, "DIMTXT",{ transparent: false, dither: 0 }]  # purple labels
}

def layer_key(source_str)
  m = source_str.to_s.match(/(\d+)\s*\/\s*(\d+)/)
  m ? "#{m[1]}/#{m[2]}" : nil
end

def apply_colors(view)
  begin
    view.add_missing_layers
  rescue
  end
  iter = view.begin_layers
  while !iter.at_end?
    node = iter.current
    key = layer_key(node.source.to_s)
    if key && COLORS[key]
      color, name, opts = COLORS[key]
      props = node.dup
      props.name = name
      props.fill_color = color
      props.frame_color = color
      props.dither_pattern = opts[:dither]
      props.transparent = !!opts[:transparent]
      props.visible = true
      begin
        props.width = (key == "30/0" || key == "3/0" || key == "100/0" || key == "101/0") ? 2 : 1
      rescue
      end
      view.set_layer_properties(iter, props)
    end
    iter.next
  end
end

def dbu(layout, um)
  (um / layout.dbu).round
end

def add_box(cell, layer, layout, x, y, w, h)
  cell.shapes(layer).insert(Box.new(
    dbu(layout, x), dbu(layout, y),
    dbu(layout, x + w), dbu(layout, y + h)
  ))
end

def add_text(cell, layer, layout, x, y, text, height_um)
  t = Text.new(text, dbu(layout, x), dbu(layout, y))
  t.size = dbu(layout, height_um)
  cell.shapes(layer).insert(t)
end

# Draw a dimension: ticks + bar + label (µm coords).
def draw_dim(cell, layout, ly_line, ly_txt, x1, y1, x2, y2, label, text_h: 0.045)
  # tick length
  dx = x2 - x1
  dy = y2 - y1
  len = Math.sqrt(dx * dx + dy * dy)
  return if len < 1e-9
  # perpendicular unit for ticks
  px = -dy / len
  py = dx / len
  tick = [len * 0.12, 0.025].max
  tw = [len * 0.02, 0.008].max  # stroke width

  # main bar as thin box along the segment
  if dx.abs >= dy.abs
    # mostly horizontal
    y = 0.5 * (y1 + y2)
    add_box(cell, ly_line, layout, [x1, x2].min, y - tw * 0.5, dx.abs, tw)
    add_box(cell, ly_line, layout, x1 - tw * 0.5, y1 - tick * 0.5, tw, tick)
    add_box(cell, ly_line, layout, x2 - tw * 0.5, y2 - tick * 0.5, tw, tick)
    add_text(cell, ly_txt, layout, 0.5 * (x1 + x2) - label.length * text_h * 0.22,
             y + tick * 0.55, label, text_h)
  else
    # mostly vertical
    x = 0.5 * (x1 + x2)
    add_box(cell, ly_line, layout, x - tw * 0.5, [y1, y2].min, tw, dy.abs)
    add_box(cell, ly_line, layout, x1 - tick * 0.5, y1 - tw * 0.5, tick, tw)
    add_box(cell, ly_line, layout, x2 - tick * 0.5, y2 - tw * 0.5, tick, tw)
    add_text(cell, ly_txt, layout, x + tick * 0.55,
             0.5 * (y1 + y2), label, text_h)
  end
end

def prepare_case_gds(gds, cell_name, markers:, rulers:)
  layout = Layout.new
  layout.read(gds)
  cell = layout.cell(cell_name)
  raise "missing #{cell_name}" unless cell

  ly_err = layout.layer(100, 0)
  ly_dim = layout.layer(101, 0)
  ly_txt = layout.layer(102, 0)

  (markers || []).each do |mx0, my0, mx1, my1|
    cell.shapes(ly_err).insert(Box.new(
      dbu(layout, mx0), dbu(layout, my0),
      dbu(layout, mx1), dbu(layout, my1)
    ))
  end

  (rulers || []).each do |rx1, ry1, rx2, ry2, label|
    draw_dim(cell, layout, ly_dim, ly_txt, rx1, ry1, rx2, ry2, label.to_s)
  end

  tmp = File.join(SHOT, "_case_#{cell_name}_#{Process.pid}_#{rand(10000)}.gds")
  layout.write(tmp)
  tmp
end

def load_cell(gds, cell_name)
  mw = Application.instance.main_window
  mw.load_layout(gds, 0)
  view = mw.current_view
  raise "no view for #{gds}" unless view
  cv = view.active_cellview
  cell = cv.layout.cell(cell_name)
  raise "missing cell #{cell_name}" unless cell
  cv.cell = cell
  apply_colors(view)
  view.max_hier
  view
end

def capture(path, gds, cell_name:, width:, height:)
  view = load_cell(gds, cell_name)
  view.zoom_fit
  view.update_content
  view.save_image(path, width, height)
  puts "Wrote #{path} (#{File.size(path)} bytes)"
end

def capture_zoom(path, gds, cell_name:, box:, rulers: [], markers: [],
                 width: 1000, height: 750, pad: 0.18)
  x0, y0, x1, y1 = box
  tmp = prepare_case_gds(gds, cell_name, markers: markers, rulers: rulers)
  begin
    view = load_cell(tmp, cell_name)
    view.zoom_box(DBox.new(x0 - pad, y0 - pad, x1 + pad, y1 + pad))
    view.update_content
    view.save_image(path, width, height)
    puts "Wrote #{path} (#{File.size(path)} bytes)"
  ensure
    File.delete(tmp) if File.exist?(tmp)
  end
end

def lyrdb_marker_boxes(lyrdb, pad: 0.015)
  return [] unless lyrdb && File.file?(lyrdb)
  boxes = []
  File.read(lyrdb).scan(/edge-pair:\s*\(([^)]+)\)\|\(([^)]+)\)/) do |a, b|
    pts = (a + ";" + b).split(";").map { |p| p.split(",").map(&:to_f) }
    xs = pts.map { |x, _| x }
    ys = pts.map { |_, y| y }
    boxes << [xs.min - pad, ys.min - pad, xs.max + pad, ys.max + pad]
  end
  boxes
end

def markers_in_box(all, box, slack: 0.08)
  x0, y0, x1, y1 = box
  all.select do |mx0, my0, mx1, my1|
    cx = 0.5 * (mx0 + mx1)
    cy = 0.5 * (my0 + my1)
    cx >= x0 - slack && cx <= x1 + slack && cy >= y0 - slack && cy <= y1 + slack
  end
end

def capture_drc_with_markers(path, gds, lyrdb, cell_name:, width:, height:)
  tmp = prepare_case_gds(gds, cell_name,
                         markers: lyrdb_marker_boxes(lyrdb, pad: 0.02),
                         rulers: [])
  begin
    capture(path, tmp, cell_name: cell_name, width: width, height: height)
  ensure
    File.delete(tmp) if File.exist?(tmp)
  end
end

# Per-testcase zooms (µm in M1_CT_GOOD / M1_CT_BAD)
DRC_CASES = [
  {
    file: "drc_case_m1_width_good.png", cell: "M1_CT_GOOD",
    box: [7.85, 11.9, 8.45, 13.6],
    rulers: [[8.0, 13.55, 8.20, 13.55, "0.20 um"]],
    markers: []
  },
  {
    file: "drc_case_m1_width_bad.png", cell: "M1_CT_BAD",
    box: [7.85, 11.9, 8.35, 13.6],
    rulers: [[8.0, 13.55, 8.10, 13.55, "0.10 um (<0.14)"]],
    mark_box: [7.95, 12.0, 8.15, 13.5]
  },
  {
    file: "drc_case_m1_space_good.png", cell: "M1_CT_GOOD",
    box: [7.70, 8.85, 9.15, 10.65],
    rulers: [[8.30, 10.55, 8.50, 10.55, "0.20 um space"]],
    markers: []
  },
  {
    file: "drc_case_m1_space_bad.png", cell: "M1_CT_BAD",
    box: [7.70, 8.85, 9.05, 10.65],
    rulers: [[8.30, 10.55, 8.38, 10.55, "0.08 um (<0.14)"]],
    mark_box: [8.30, 9.15, 8.38, 10.35]
  },
  {
    file: "drc_case_m1_enc_good.png", cell: "M1_CT_GOOD",
    box: [8.35, 6.05, 8.85, 6.55],
    rulers: [
      [8.42, 6.52, 8.50, 6.52, "enc 0.08 um"],
      [8.70, 6.12, 8.70, 6.20, "0.08 um"]
    ],
    markers: []
  },
  {
    file: "drc_case_m1_enc_bad.png", cell: "M1_CT_BAD",
    box: [8.40, 6.10, 8.80, 6.50],
    rulers: [[8.47, 6.48, 8.50, 6.48, "enc 0.03 um (<0.055)"]],
    mark_box: [8.45, 6.15, 8.75, 6.45]
  },
  {
    file: "drc_case_ct_space_good.png", cell: "M1_CT_GOOD",
    box: [7.85, 3.05, 8.85, 3.65],
    rulers: [[8.20, 3.58, 8.45, 3.58, "0.25 um space"]],
    markers: []
  },
  {
    file: "drc_case_ct_space_bad.png", cell: "M1_CT_BAD",
    box: [7.85, 3.05, 8.65, 3.65],
    rulers: [[8.20, 3.58, 8.32, 3.58, "0.12 um (<0.18)"]],
    mark_box: [8.15, 3.15, 8.40, 3.45]
  },
  {
    file: "drc_case_ct_width_bad.png", cell: "M1_CT_BAD",
    box: [7.90, 0.10, 8.35, 0.55],
    rulers: [[8.0, 0.50, 8.12, 0.50, "0.12 um (<0.16)"]],
    mark_box: [7.95, 0.15, 8.20, 0.45]
  }
]

drc = File.join(REPO, "drc")
lvs = File.join(REPO, "lvs")
drc_gds = File.join(drc, "m1_contact_demo.gds")
lvs_gds = File.join(lvs, "nmos_demo.gds")

capture(File.join(SHOT, "drc_m1_contact_layout.png"),
        drc_gds, cell_name: "M1_CT_DRC_DEMO", width: 1600, height: 900)
capture(File.join(SHOT, "drc_m1_contact_good.png"),
        drc_gds, cell_name: "M1_CT_GOOD", width: 1000, height: 900)
capture(File.join(SHOT, "drc_m1_contact_bad.png"),
        drc_gds, cell_name: "M1_CT_BAD", width: 1000, height: 900)

lyrdb_demo = File.join(drc, "m1_contact_demo.lyrdb")
lyrdb_demo = File.join(drc, "m1_contact.lyrdb") unless File.file?(lyrdb_demo)
lyrdb_bad  = File.join(drc, "m1_contact_bad.lyrdb")

if File.file?(lyrdb_demo)
  capture_drc_with_markers(
    File.join(SHOT, "drc_m1_contact_with_markers.png"),
    drc_gds, lyrdb_demo,
    cell_name: "M1_CT_DRC_DEMO", width: 1600, height: 900
  )
end

bad_markers = lyrdb_marker_boxes(lyrdb_bad)

DRC_CASES.each do |c|
  markers = c[:markers] || []
  if c[:mark_box]
    found = markers_in_box(bad_markers, c[:mark_box])
    markers = found.empty? ? [c[:mark_box]] : found
  end
  capture_zoom(
    File.join(SHOT, c[:file]),
    drc_gds,
    cell_name: c[:cell],
    box: c[:box],
    rulers: c[:rulers],
    markers: markers,
    width: 1100, height: 800, pad: 0.12
  )
end

capture(File.join(SHOT, "lvs_nmos_demo.png"),
        lvs_gds, cell_name: "NMOS_DEMO", width: 1400, height: 700)
capture(File.join(SHOT, "lvs_nmos_good.png"),
        lvs_gds, cell_name: "NMOS_GOOD", width: 1000, height: 700)
capture(File.join(SHOT, "lvs_nmos_bad.png"),
        lvs_gds, cell_name: "NMOS_BAD", width: 1000, height: 700)

# Geometry from lvs/generate_layout.rb (µm)
# L=0.18 W=0.50 SD=0.40 poly@0.40  S@0.12/0.17  D@0.70/0.17  G@0.41/0.52  B@1.28/0.17
LVS_CASES = [
  {
    file: "lvs_case_channel_lw.png", cell: "NMOS_GOOD",
    # channel = poly ∩ diff: x=0.40..0.58, y=0..0.50
    box: [0.25, -0.05, 0.75, 0.60],
    rulers: [
      [0.40, 0.55, 0.58, 0.55, "L = 0.18 um"],
      [0.62, 0.00, 0.62, 0.50, "W = 0.50 um"]
    ],
    markers: []
  },
  {
    file: "lvs_case_gate.png", cell: "NMOS_GOOD",
    box: [0.30, 0.35, 0.70, 0.85],
    rulers: [
      [0.41, 0.78, 0.57, 0.78, "G contact"],
      [0.40, 0.45, 0.58, 0.45, "poly L=0.18"]
    ],
    markers: []
  },
  {
    file: "lvs_case_source.png", cell: "NMOS_GOOD",
    box: [-0.05, 0.00, 0.45, 0.55],
    rulers: [
      [0.12, 0.42, 0.28, 0.42, "S contact 0.16"],
      [0.07, 0.12, 0.33, 0.12, "M1 pad"]
    ],
    markers: []
  },
  {
    file: "lvs_case_drain.png", cell: "NMOS_GOOD",
    box: [0.50, 0.00, 1.00, 0.55],
    rulers: [
      [0.70, 0.42, 0.86, 0.42, "D contact 0.16"],
      [0.65, 0.12, 0.91, 0.12, "M1 pad"]
    ],
    markers: []
  },
  {
    file: "lvs_case_bulk.png", cell: "NMOS_GOOD",
    box: [1.15, 0.00, 1.60, 0.55],
    rulers: [
      [1.33, 0.42, 1.49, 0.42, "B contact"],
      [1.28, 0.12, 1.54, 0.12, "PTIE tap"]
    ],
    markers: []
  },
  {
    file: "lvs_case_sd_separate.png", cell: "NMOS_GOOD",
    # S and D pads with open gap under poly — no metal bridge
    box: [-0.05, -0.05, 1.05, 0.55],
    rulers: [
      [0.33, -0.02, 0.65, -0.02, "S/D open (no short)"]
    ],
    markers: []
  },
  {
    file: "lvs_case_sd_short.png", cell: "NMOS_BAD",
    box: [-0.08, -0.30, 1.10, 0.55],
    rulers: [
      [0.07, -0.22, 0.91, -0.22, "S-D short bridge"]
    ],
    markers: [[0.05, -0.18, 0.95, -0.02]]
  },
  {
    file: "lvs_case_terminals_good.png", cell: "NMOS_GOOD",
    box: [-0.15, -0.15, 1.70, 0.95],
    rulers: [
      [0.40, 0.58, 0.58, 0.58, "L=0.18"],
      [0.00, 0.00, 0.00, 0.50, "W=0.50"]
    ],
    markers: []
  },
  {
    file: "lvs_case_terminals_bad.png", cell: "NMOS_BAD",
    box: [-0.15, -0.30, 1.70, 0.95],
    rulers: [
      [0.07, -0.22, 0.91, -0.22, "FAIL: S shorted to D"]
    ],
    markers: [[0.05, -0.18, 0.95, -0.02]]
  }
]

LVS_CASES.each do |c|
  capture_zoom(
    File.join(SHOT, c[:file]),
    lvs_gds,
    cell_name: c[:cell],
    box: c[:box],
    rulers: c[:rulers],
    markers: c[:markers] || [],
    width: 1100, height: 800, pad: 0.06
  )
end

puts "Done → #{SHOT}"
Application.instance.exit(0)
