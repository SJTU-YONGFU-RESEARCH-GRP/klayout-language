# Capture PNG screenshots for drc/ and lvs/ README images.
#
#   ./scripts/run_capture_screenshots.sh
#   # or:
#   xvfb-run -a klayout -z -x -r scripts/capture_demo_screenshots.rb
#
# Needs a display (Xvfb is fine). Do not use -b/-zz — MainWindow is required.

include RBA

REPO = File.expand_path("..", __dir__)
SHOT = File.join(REPO, "screenshots")
Dir.mkdir(SHOT) unless File.directory?(SHOT)

# Distinct colors for README screenshots (0xRRGGBB)
COLORS = {
  # DRC
  "31/0" => [0x4169E1, "M1"],      # royal blue
  "30/0" => [0xDC143C, "CT"],      # crimson
  "90/0" => [0x2F4F4F, "LABEL"],  # dark slate
  # LVS
  "1/0"  => [0xE07070, "DIFF"],
  "2/0"  => [0x7070E0, "POLY"],
  "3/0"  => [0x202020, "CONT"],
  "4/0"  => [0x40A0FF, "METAL1"],
  "4/1"  => [0x104080, "LABEL"],
  "6/0"  => [0xC04000, "PTIE"],
  # synthetic DRC error markers
  "100/0" => [0xFF0000, "DRC_ERR"]
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
      props.dither_pattern = 1
      props.visible = true
      view.set_layer_properties(iter, props)
    end
    iter.next
  end
end

def capture(path, gds, cell_name:, width:, height:)
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
  view.zoom_fit
  view.update_content
  view.save_image(path, width, height)
  puts "Wrote #{path} (#{File.size(path)} bytes)"
end

# Build a temporary GDS with DRC error markers (from .lyrdb) for a clear "with markers" shot.
def capture_drc_with_markers(path, gds, lyrdb, cell_name:, width:, height:)
  layout = Layout.new
  layout.read(gds)
  cell = layout.cell(cell_name)
  raise "missing #{cell_name}" unless cell

  err = layout.layer(100, 0)
  # Parse edge-pair markers from lyrdb XML
  text = File.read(lyrdb)
  text.scan(/edge-pair:\s*\(([^)]+)\)\|\(([^)]+)\)/) do |a, b|
    pts = (a + ";" + b).split(";").map { |p| p.split(",").map(&:to_f) }
    xs = pts.map { |x, _| x }
    ys = pts.map { |_, y| y }
    # Enlarge slightly so markers show at screenshot scale (µm → dbu)
    pad = 0.02
    x0 = ((xs.min - pad) / layout.dbu).round
    y0 = ((ys.min - pad) / layout.dbu).round
    x1 = ((xs.max + pad) / layout.dbu).round
    y1 = ((ys.max + pad) / layout.dbu).round
    cell.shapes(err).insert(Box.new(x0, y0, x1, y1))
  end

  tmp = File.join(SHOT, "_drc_with_markers_tmp.gds")
  layout.write(tmp)
  capture(path, tmp, cell_name: cell_name, width: width, height: height)
  File.delete(tmp) if File.exist?(tmp)
end

drc = File.join(REPO, "drc")
lvs = File.join(REPO, "lvs")

capture(File.join(SHOT, "drc_m1_contact_layout.png"),
        File.join(drc, "m1_contact_demo.gds"),
        cell_name: "M1_CT_DRC_DEMO", width: 1600, height: 1100)

lyrdb = File.join(drc, "m1_contact.lyrdb")
if File.file?(lyrdb)
  capture_drc_with_markers(
    File.join(SHOT, "drc_m1_contact_with_markers.png"),
    File.join(drc, "m1_contact_demo.gds"),
    lyrdb,
    cell_name: "M1_CT_DRC_DEMO", width: 1600, height: 1100
  )
end

capture(File.join(SHOT, "lvs_nmos_demo.png"),
        File.join(lvs, "nmos_demo.gds"),
        cell_name: "NMOS_DEMO", width: 1400, height: 700)

capture(File.join(SHOT, "lvs_nmos_good.png"),
        File.join(lvs, "nmos_demo.gds"),
        cell_name: "NMOS_GOOD", width: 1000, height: 700)

capture(File.join(SHOT, "lvs_nmos_bad.png"),
        File.join(lvs, "nmos_demo.gds"),
        cell_name: "NMOS_BAD", width: 1000, height: 700)

puts "Done → #{SHOT}"
Application.instance.exit(0)
