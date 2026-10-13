# Dump inductor centerline + metal bbox from GDS → JSON for EM.
#
#   klayout -b -r extract_geometry.rb \
#     -rd input=...gds -rd cell=IND -rd output=geometry.json \
#     -rd width_um=1.0

include RBA
require "json"

IN = ($input || "").to_s
OUT = ($output || "geometry.json").to_s
CELL = ($cell || "").to_s
W = ($width_um || "1.0").to_s.to_f

abort("need -rd input= -rd output=") if IN.empty? || OUT.empty?

ly = Layout.new
ly.read(IN)
cell = CELL.empty? ? ly.top_cell : ly.cell(CELL)
abort("missing cell") unless cell
dbu = ly.dbu

def paths_on(cell, layer)
  out = []
  cell.begin_shapes_rec(layer).each do |i|
    sh = i.shape
    next unless sh.is_path?
    pts = sh.path.each_point.to_a.map { |p|
      q = i.trans * p
      [q.x * cell.layout.dbu, q.y * cell.layout.dbu] # µm — need layout
    }
    # fix: use outer dbu
    out << pts if pts.size >= 2
  end
  out
end

# Correct µm conversion with layout.dbu
def paths_um(cell, layer, dbu)
  out = []
  cell.begin_shapes_rec(layer).each do |i|
    sh = i.shape
    next unless sh.is_path?
    pts = sh.path.each_point.to_a.map { |p|
      q = i.trans * p
      [q.x * dbu, q.y * dbu]
    }
    out << pts if pts.size >= 2
  end
  out
end

def metal_bbox_um(cell, layer, dbu)
  r = Region.new
  cell.begin_shapes_rec(layer).each do |i|
    sh = i.shape
    next unless sh.is_box? || sh.is_polygon? || sh.is_path?
    r.insert(sh.polygon.transformed(i.trans))
  end
  return nil if r.is_empty?
  b = r.bbox
  {
    "xmin_um" => b.left * dbu,
    "ymin_um" => b.bottom * dbu,
    "xmax_um" => b.right * dbu,
    "ymax_um" => b.top * dbu
  }
end

clines = paths_um(cell, ly.layer(31, 2), dbu)
# Fallback: synthesize from boxes midlines not available — require centerline
m1_bb = metal_bbox_um(cell, ly.layer(31, 0), dbu)
m2_bb = metal_bbox_um(cell, ly.layer(32, 0), dbu)

# Labels
labs = {}
[ly.layer(31, 1), ly.layer(32, 1)].each do |li|
  cell.shapes(li).each do |s|
    next unless s.is_text?
    t = s.text
    labs[t.string] = [t.trans.disp.x * dbu, t.trans.disp.y * dbu]
  end
end

# Pick longest centerline as primary winding
primary = clines.max_by { |p|
  len = 0.0
  (0...p.size - 1).each do |i|
    dx = p[i + 1][0] - p[i][0]
    dy = p[i + 1][1] - p[i][1]
    len += Math.sqrt(dx * dx + dy * dy)
  end
  len
} || []

data = {
  "cell" => cell.name,
  "width_um" => W,
  "dbu" => dbu,
  "centerlines_um" => clines,
  "primary_centerline_um" => primary,
  "m1_bbox_um" => m1_bb,
  "m2_bbox_um" => m2_bb,
  "labels_um" => labs
}

File.write(OUT, JSON.pretty_generate(data))
puts "Wrote #{OUT} centerlines=#{clines.size} primary_pts=#{primary.size}"
