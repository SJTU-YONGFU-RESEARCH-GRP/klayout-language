# Capture PNG screenshots for drc/ and lvs/ README images.
#
#   ./scripts/run_capture_screenshots.sh
#
# Needs a display (Xvfb is fine). Do not use -b/-zz — MainWindow is required.
#
# Per-testcase zoom shots include dimension rulers and (for BAD) DRC error markers.

include RBA

REPO = File.expand_path("..", __dir__)
SHOT = File.join(REPO, "screenshots")
Dir.mkdir(SHOT) unless File.directory?(SHOT)

# High-contrast, distinct hues (0xRRGGBB)
COLORS = {
  # DRC
  "31/0"  => [0x1E6AFF, "M1"],       # bright blue
  "30/0"  => [0xE63900, "CT"],       # vivid red-orange
  "90/0"  => [0x5B2C6F, "LABEL"],   # purple
  # LVS
  "1/0"   => [0xE74C3C, "DIFF"],    # red
  "2/0"   => [0x27AE60, "POLY"],    # green
  "3/0"   => [0xF1C40F, "CONT"],    # yellow
  "4/0"   => [0x2980B9, "METAL1"],  # blue
  "4/1"   => [0x8E44AD, "LABEL"],   # purple
  "6/0"   => [0xD35400, "PTIE"],    # orange
  # synthetic DRC error markers
  "100/0" => [0xFF00AA, "DRC_ERR"]  # magenta hotspot
}

def apply_colors(view)
  iter = view.begin_layers
  while !iter.at_end?
    node = iter.current
    src = node.source.to_s
    key = src.split("@").first
    if COLORS[key]
      color, name = COLORS[key]
      props = node.dup
      props.name = name
      props.fill_color = color
      props.frame_color = color
      # Contacts / plugs: hatch so they stay visible over metal
      props.dither_pattern = (key == "30/0" || key == "3/0" || key == "100/0") ? 5 : 0
      props.visible = true
      # Thicker frames on tiny plugs / markers
      begin
        props.width = (key == "30/0" || key == "3/0" || key == "100/0") ? 2 : 1
      rescue
      end
      view.set_layer_properties(iter, props)
    end
    iter.next
  end
end

def clear_rulers(view)
  view.clear_annotations
end

# Horizontal or vertical dimension ruler (µm coords in the active cell).
def add_ruler(view, x1, y1, x2, y2, label: nil)
  a = Annotation.new
  a.p1 = DPoint.new(x1, y1)
  a.p2 = DPoint.new(x2, y2)
  a.style = Annotation::StyleArrowBoth
  a.outline = Annotation::OutlineXY
  a.fmt = label ? label : "$D µm"
  a.fmt_x = ""
  a.fmt_y = ""
  view.insert_annotation(a)
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
  [view, cv]
end

def capture(path, gds, cell_name:, width:, height:)
  view, _cv = load_cell(gds, cell_name)
  clear_rulers(view)
  view.zoom_fit
  view.update_content
  view.save_image(path, width, height)
  puts "Wrote #{path} (#{File.size(path)} bytes)"
end

# Zoom to a µm box, draw rulers, optionally overlay error marker boxes (µm).
def capture_zoom(path, gds, cell_name:, box:, rulers: [], markers: [],
                 width: 900, height: 700, pad: 0.25)
  x0, y0, x1, y1 = box
  src = gds

  if markers && !markers.empty?
    layout = Layout.new
    layout.read(gds)
    cell = layout.cell(cell_name)
    err = layout.layer(100, 0)
    markers.each do |mx0, my0, mx1, my1|
      cell.shapes(err).insert(Box.new(
        (mx0 / layout.dbu).round, (my0 / layout.dbu).round,
        (mx1 / layout.dbu).round, (my1 / layout.dbu).round
      ))
    end
    src = File.join(SHOT, "_zoom_tmp.gds")
    layout.write(src)
  end

  view, _cv = load_cell(src, cell_name)
  begin
    view.add_missing_layers
  rescue
  end
  apply_colors(view)
  clear_rulers(view)

  rulers.each do |rx1, ry1, rx2, ry2, *rest|
    add_ruler(view, rx1, ry1, rx2, ry2, label: rest[0])
  end

  view.zoom_box(DBox.new(x0 - pad, y0 - pad, x1 + pad, y1 + pad))
  view.update_content
  view.save_image(path, width, height)
  puts "Wrote #{path} (#{File.size(path)} bytes)"
  clear_rulers(view)
  File.delete(src) if src != gds && File.exist?(src)
end

# Parse edge-pair markers from lyrdb → list of [x0,y0,x1,y1] µm boxes (padded).
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

def markers_in_box(all, box, slack: 0.05)
  x0, y0, x1, y1 = box
  all.select do |mx0, my0, mx1, my1|
    cx = 0.5 * (mx0 + mx1)
    cy = 0.5 * (my0 + my1)
    cx >= x0 - slack && cx <= x1 + slack && cy >= y0 - slack && cy <= y1 + slack
  end
end

def capture_drc_with_markers(path, gds, lyrdb, cell_name:, width:, height:)
  layout = Layout.new
  layout.read(gds)
  cell = layout.cell(cell_name)
  raise "missing #{cell_name}" unless cell

  err = layout.layer(100, 0)
  lyrdb_marker_boxes(lyrdb, pad: 0.02).each do |x0, y0, x1, y1|
    cell.shapes(err).insert(Box.new(
      (x0 / layout.dbu).round, (y0 / layout.dbu).round,
      (x1 / layout.dbu).round, (y1 / layout.dbu).round
    ))
  end

  tmp = File.join(SHOT, "_drc_with_markers_tmp.gds")
  layout.write(tmp)
  capture(path, tmp, cell_name: cell_name, width: width, height: height)
  File.delete(tmp) if File.exist?(tmp)
end

# ---------------------------------------------------------------------------
# DRC per-testcase zoom definitions (µm, in M1_CT_GOOD / M1_CT_BAD)
# Each: name, cell, view box [x0,y0,x1,y1], rulers [[x1,y1,x2,y2,label?], ...]
# ---------------------------------------------------------------------------
DRC_CASES = [
  {
    file: "drc_case_m1_width_good.png",
    cell: "M1_CT_GOOD", title: "GOOD M1 width 0.20 µm",
    box: [7.7, 11.8, 8.6, 13.7],
    rulers: [[8.0, 13.6, 8.20, 13.6, "0.20 µm width"]]
  },
  {
    file: "drc_case_m1_width_bad.png",
    cell: "M1_CT_BAD", title: "BAD M1 width 0.10 µm",
    box: [7.7, 11.8, 8.5, 13.7],
    rulers: [[8.0, 13.6, 8.10, 13.6, "0.10 µm (<0.14)"]],
    mark_box: [7.9, 12.0, 8.2, 13.5]
  },
  {
    file: "drc_case_m1_space_good.png",
    cell: "M1_CT_GOOD", title: "GOOD M1 space 0.20 µm",
    box: [7.7, 8.8, 9.2, 10.7],
    rulers: [[8.30, 10.6, 8.50, 10.6, "0.20 µm space"]]
  },
  {
    file: "drc_case_m1_space_bad.png",
    cell: "M1_CT_BAD", title: "BAD M1 space 0.08 µm",
    box: [7.7, 8.8, 9.1, 10.7],
    rulers: [[8.30, 10.6, 8.38, 10.6, "0.08 µm (<0.14)"]],
    mark_box: [8.25, 9.0, 8.45, 10.5]
  },
  {
    file: "drc_case_m1_enc_good.png",
    cell: "M1_CT_GOOD", title: "GOOD M1 enclosure 0.08 µm",
    # pad: CT at 8.5,6.2 size 0.20 → M1 8.42..8.78 / 6.12..6.48
    box: [8.35, 6.05, 8.85, 6.55],
    rulers: [
      [8.42, 6.50, 8.50, 6.50, "0.08 µm enc"],  # left enclosure
      [8.50, 6.12, 8.50, 6.20, "0.08 µm"]       # bottom
    ]
  },
  {
    file: "drc_case_m1_enc_bad.png",
    cell: "M1_CT_BAD", title: "BAD M1 enclosure 0.03 µm",
    box: [8.40, 6.10, 8.80, 6.50],
    rulers: [
      [8.47, 6.45, 8.50, 6.45, "0.03 µm (<0.055)"]
    ],
    mark_box: [8.45, 6.15, 8.75, 6.45]
  },
  {
    file: "drc_case_ct_space_good.png",
    cell: "M1_CT_GOOD", title: "GOOD CT space 0.25 µm",
    box: [7.8, 3.0, 9.0, 3.7],
    rulers: [[8.20, 3.55, 8.45, 3.55, "0.25 µm space"]]
  },
  {
    file: "drc_case_ct_space_bad.png",
    cell: "M1_CT_BAD", title: "BAD CT space 0.12 µm",
    box: [7.8, 3.0, 8.8, 3.7],
    rulers: [[8.20, 3.55, 8.32, 3.55, "0.12 µm (<0.18)"]],
    mark_box: [8.15, 3.15, 8.40, 3.45]
  },
  {
    file: "drc_case_ct_width_bad.png",
    cell: "M1_CT_BAD", title: "BAD CT width 0.12 µm",
    box: [7.85, 0.05, 8.40, 0.55],
    rulers: [[8.0, 0.48, 8.12, 0.48, "0.12 µm (<0.16)"]],
    mark_box: [7.95, 0.15, 8.20, 0.45]
  }
]

# ---------------------------------------------------------------------------
drc = File.join(REPO, "drc")
lvs = File.join(REPO, "lvs")
drc_gds = File.join(drc, "m1_contact_demo.gds")

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
  markers = []
  if c[:mark_box]
    markers = markers_in_box(bad_markers, c[:mark_box])
    # Always show at least the intended highlight region
    markers = [c[:mark_box]] if markers.empty?
  end
  capture_zoom(
    File.join(SHOT, c[:file]),
    drc_gds,
    cell_name: c[:cell],
    box: c[:box],
    rulers: c[:rulers],
    markers: markers,
    width: 1000, height: 750, pad: 0.15
  )
end

# LVS overview + GOOD/BAD (distinct colors) + zoomed SHORT
lvs_gds = File.join(lvs, "nmos_demo.gds")

capture(File.join(SHOT, "lvs_nmos_demo.png"),
        lvs_gds, cell_name: "NMOS_DEMO", width: 1400, height: 700)

capture(File.join(SHOT, "lvs_nmos_good.png"),
        lvs_gds, cell_name: "NMOS_GOOD", width: 1000, height: 700)

capture(File.join(SHOT, "lvs_nmos_bad.png"),
        lvs_gds, cell_name: "NMOS_BAD", width: 1000, height: 700)

# Zoom on S–D short bridge with length ruler
capture_zoom(
  File.join(SHOT, "lvs_case_sd_short.png"),
  lvs_gds,
  cell_name: "NMOS_BAD",
  box: [-0.05, -0.25, 1.15, 0.55],
  rulers: [
    [0.05 - 0.05, -0.12, 0.58 + 0.16 + 0.05, -0.12, "S–D short bridge"]
  ],
  markers: [[0.0, -0.18, 0.98, -0.02]],
  width: 1100, height: 700, pad: 0.08
)

puts "Done → #{SHOT}"
Application.instance.exit(0)
