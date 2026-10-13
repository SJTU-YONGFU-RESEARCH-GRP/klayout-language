# Capture inductor layout PNG with high-contrast layer colors.
#
#   klayout -z -x -r capture_screenshot.rb \
#     -rd input=.../inductor.gds -rd cell=IND_SQ_2P \
#     -rd output=.../layout/inductor.png
#
# Needs a display (xvfb-run is fine). Do not use -b.

include RBA

IN  = ($input || "").to_s
OUT = ($output || "").to_s
CELL = ($cell || "").to_s
W = ($width || "1400").to_s.to_i
H = ($height || "1000").to_s.to_i

abort("need -rd input= and -rd output=") if IN.empty? || OUT.empty?

# Distinct hues (0xRRGGBB) — solid blue / red / yellow / green / magenta
COLORS = {
  "31/0" => [0x1565C0, "M1",      { transparent: false, dither: 0, width: 2 }],  # blue
  "32/0" => [0xD50000, "M2",      { transparent: false, dither: 0, width: 2 }],  # red
  "30/0" => [0xFFD600, "VIA",     { transparent: false, dither: 0, width: 2 }],  # yellow
  "31/1" => [0x00C853, "M1_LABEL",{ transparent: false, dither: 0, width: 1 }],  # green
  "32/1" => [0xAA00FF, "M2_LABEL",{ transparent: false, dither: 0, width: 1 }]   # magenta
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
        props.width = opts[:width] || 1
      rescue
      end
      view.set_layer_properties(iter, props)
    end
    iter.next
  end
end

mw = Application.instance.main_window
mw.load_layout(IN, 0)
view = mw.current_view
raise "no view for #{IN}" unless view

cv = view.active_cellview
cell_name = CELL.empty? ? cv.cell.name : CELL
cell = cv.layout.cell(cell_name)
raise "missing cell #{cell_name}" unless cell
cv.cell = cell

apply_colors(view)
view.max_hier
view.zoom_fit
view.update_content

Dir.mkdir(File.dirname(OUT)) unless File.directory?(File.dirname(OUT))
view.save_image(OUT, W, H)
puts "Wrote #{OUT} (#{File.size(OUT)} bytes) cell=#{cell_name}"
