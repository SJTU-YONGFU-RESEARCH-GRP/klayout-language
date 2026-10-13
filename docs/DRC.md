# KLayout DRC Commands

Extracted from KLayout official DRC/LVS reference HTML and built-in macros (KLayout 0.30.2+). Every command includes Usage plus an Example (preferring official doc samples; otherwise a minimal illustrative snippet).

DRC scripts use a Ruby DSL (`.drc` / `.lydrc`). Run under **Tools → DRC**, or batch:

```bash
klayout -b -r script.drc
```

**Command counts:** global 135 · Layer 175 · Source 18 · Netter 17 · universal `drc` 49

LVS scripts include all DRC commands below; see `LVS.md` for LVS-only additions.

---

## Global functions

| Command | Description |
|---|---|
| `angle` | In universal DRC context: selects edges based on their orientation |
| `antenna_check` | Performs an antenna check |
| `area` | Computes the total area or in universal DRC context: selects the primary shape if the area is meeting the condition |
| `area_ratio` | Selects primary shapes based on the ratio of bounding box and polygon area |
| `bbox_aspect_ratio` | Selects primary shapes based on the aspect ratio of their bounding boxes |
| `bbox_height` | Selects primary shapes based on their bounding box height |
| `bbox_max` | Selects primary shapes based on their bounding box height or width, whichever is larger |
| `bbox_min` | Selects primary shapes based on their bounding box height or width, whichever is smaller |
| `bbox_width` | Selects primary shapes based on their bounding box width |
| `bjt3` | Supplies the BJT3 transistor extractor class |
| `bjt4` | Supplies the BJT4 transistor extractor class |
| `box` | Creates a box object |
| `capacitor` | Supplies the capacitor extractor class |
| `capacitor_with_bulk` | Supplies the capacitor extractor class that includes a bulk terminal |
| `cell` | Selects a cell for input on the default source |
| `cheat` | Hierarchy cheats |
| `clear_connections` | Clears all connections stored so far |
| `clip` | Specifies clipped input on the default source |
| `connect` | Specifies a connection between two layers |
| `connect_explicit` | Specifies explicit net connections |
| `connect_global` | Specifies a connection to a global net |
| `connect_implicit` | Specifies a label pattern for implicit net connections |
| `corners` | Selects corners of polygons |
| `covering` | Selects shapes entirely covering other shapes |
| `dbu` | Gets or sets the database unit to use |
| `deep` | Enters deep (hierarchical) mode |
| `deep_reject_odd_polygons` | Gets or sets a value indicating whether the reject odd polygons in deep mode |
| `def_output` | Gets an object describing the default output channel |
| `device_scaling` | Specifies a dimension scale factor for the geometrical device properties |
| `diode` | Supplies the diode extractor class |
| `dmos3` | Supplies the DMOS3 transistor extractor class |
| `dmos4` | Supplies the MOS4 transistor extractor class |
| `edge` | Creates an edge object |
| `edge_layer` | Creates an empty edge layer |
| `edge_pairs` | Gets the edges from an original layer |
| `edges` | Gets the edges from an original layer |
| `enc` | Synonym for "enclosing" |
| `enclosed` | Performs an enclosing check (other enclosing layer) |
| `enclosing` | Performs an enclosing check |
| `error` | Prints an error |
| `evaluate_nets` | Evaluates expressions on nets |
| `extent` | Creates a new layer with the bounding box of the default source or cell bounding boxes |
| `extent_refs` | Returns partial references to the boundings boxes of the polygons |
| `extents` | Returns the bounding box of each input object |
| `extract_devices` | Extracts devices for a given device extractor and device layer selection |
| `flat` | Disables tiling mode |
| `foreign` | Represents all other polygons from primary except the current one |
| `global_transform` | Gets or sets a global transformation |
| `holes` | Selects all holes from the input polygons |
| `hulls` | Selects all hulls from the input polygons |
| `if_all` | Evaluates to the primary shape when all condition expression results are non-empty |
| `if_any` | Evaluates to the primary shape when any condition expression results is non-empty |
| `if_none` | Evaluates to the primary shape when all of the condition expression results are empty |
| `ignore_extraction_errors` | Specifies whether to ignore extraction errors |
| `info` | Outputs as message to the logger or progress window |
| `input` | Fetches the shapes from the specified input from the default source |
| `inside` | Selects shapes entirely inside other shapes |
| `interacting` | Selects shapes interacting with other shapes |
| `is_deep?` | Returns true, if in deep mode |
| `is_tiled?` | Returns true, if in tiled mode |
| `iso` | Synonym for "isolated" |
| `isolated` | Performs an isolation (inter-polygon space) check |
| `l2n_data` | Gets the internal LayoutToNetlist object for the default Netter |
| `labels` | Gets the labels (text) from an original layer |
| `layers` | Gets the layers contained in the default source |
| `layout` | Specifies an additional layout for the input source. |
| `length` | Computes the total edge length of an edge layer or in universal DRC context: selects edges based on a length condition |
| `log` | Outputs as message to the logger window |
| `log_file` | Specify the log file where to send to log to |
| `make_layer` | Creates an empty polygon layer based on the hierarchical scheme selected |
| `max_area_ratio` | Gets or sets the maximum bounding box to polygon area ratio for deep mode fragmentation |
| `max_vertex_count` | Gets or sets the maximum vertex count for deep mode fragmentation |
| `middle` | Returns the centers of polygon bounding boxes |
| `mos3` | Supplies the MOS3 transistor extractor class |
| `mos4` | Supplies the MOS4 transistor extractor class |
| `name` | Assigns a name to a layer for reference in the LVS database |
| `name_prefix` | Specifies the layer name prefix for auto-generated layer names |
| `netlist` | Obtains the extracted netlist from the default Netter |
| `netter` | Creates a new netter object |
| `new_report` | Creates a new report database object for use in "output" |
| `new_target` | Creates a new layout target object for use in "output" |
| `no_borders` | Reset the tile borders |
| `notch` | Performs a notch (intra-polygon space) check |
| `output` | Outputs a layer to the report database or output layout |
| `output_cell` | Specifies a target cell, but does not change the target layout |
| `outside` | Selects shapes entirely outside other shapes |
| `overlap` | Performs an overlap check |
| `overlapping` | Selects shapes overlapping with other shapes |
| `p` | Creates a point object |
| `path` | Creates a path object |
| `perimeter` | Computes the total perimeter or in universal DRC context: selects the primary shape if the perimeter is meeting the condition |
| `polygon` | Creates a polygon object |
| `polygon_layer` | Creates an empty polygon layer |
| `polygons` | Fetches the polygons (or shapes that can be converted to polygons) from the specified input from the default source |
| `primary` | Represents the primary input of the universal DRC function |
| `profile` | Profiles the script and provides a runtime + memory statistics |
| `props_copy` | Specifies "copy properties" on operations supporting user properties constraints |
| `props_eq` | Specifies "same properties" for operations supporting user properties constraints |
| `props_ne` | Specifies "different properties" for operations supporting user properties constraints |
| `rectangles` | Selects all polygons which are rectangles |
| `rectilinear` | Selects all polygons which are rectilinear |
| `region_overlap` | Specifies region selected input in "overlap mode" |
| `region_touch` | Specifies region selected input in "touch mode" |
| `relative_height` | Selects primary shapes based on the ratio of height and width of their bounding boxes |
| `report` | Specifies a report database for output |
| `report_netlist` | Specifies an extracted netlist report for output |
| `resistor` | Supplies the resistor extractor class |
| `resistor_with_bulk` | Supplies the resistor extractor class that includes a bulk terminal |
| `rounded_corners` | Applies corner rounding |
| `secondary` | Provides secondary input for the "drc" universal DRC function |
| `select` | Specifies cell filters on the default source |
| `sep` | Synonym for "separation" |
| `separation` | Performs a separation check |
| `silent` | Resets verbose mode |
| `sized` | Returns the sized version of the input |
| `smoothed` | Applies smoothing |
| `soft_connect` | Specifies a soft connection between two layers |
| `soft_connect_global` | Specifies a soft connection to a global net |
| `source` | Specifies a source layout |
| `space` | Performs a space check |
| `sparse_array_limit` | Gets or sets the sparse array singularization limit |
| `squares` | Selects all polygons which are squares |
| `switch` | A conditional selector for the "drc" universal DRC function |
| `target` | Specify the target layout |
| `target_netlist` | With this statement, an extracted netlist is finally written to a file |
| `threads` | Specifies the number of CPU cores to use in tiling mode |
| `tile_borders` | Specifies a minimum tile border |
| `tiles` | Specifies tiling |
| `top_level` | Specifies that the circuit is a chip top level circuit |
| `verbose` | Sets or resets verbose mode |
| `verbose?` | Returns true, if verbose mode is enabled |
| `warn` | Prints a warning |
| `width` | Performs a width check |
| `with_holes` | Selects all input polygons according to their number of holes in DRC expressions |
| `write_spice` | Defines SPICE output format (with options) |

### Global function details

### `angle`

In universal DRC context: selects edges based on their orientation

"angle" represents the edge orientation filter on the primary shape edges in DRC expressions (see Layer#drc and DRC#angle for more details). In this context, the operation acts similar to Layer#with_angle.

Usage:

- `angle (in condition)`

Example:

```ruby
# usage: angle (in condition)
angle (in condition)
```

### `antenna_check`

Performs an antenna check

Usage:

- `antenna_check(gate, metal, ratio, [ diode_specs ... ])`

Example:

```ruby
# usage: antenna_check(gate, metal, ratio, [ diode_specs ... ])
antenna_check(gate, metal, ratio, )
```

### `area`

Computes the total area or in universal DRC context: selects the primary shape if the area is meeting the condition

This function can be used with a layer argument. In this case it is equivalent to "layer.area" (see Layer#area) and returns the total area of the polygons in the layer.

Without a layer argument, "area" represents an area filter for primary shapes in global expressions (see Layer#drc and DRC#area for more details).

Usage:

- `area (in condition)`
- `area(layer)`

Example:

```ruby
# usage: area (in condition)
area (in condition)
```

### `area_ratio`

Selects primary shapes based on the ratio of bounding box and polygon area

Usage:

- `area_ratio (in condition)`

Example:

```ruby
# usage: area_ratio (in condition)
area_ratio (in condition)
```

### `bbox_aspect_ratio`

Selects primary shapes based on the aspect ratio of their bounding boxes

Usage:

- `bbox_aspect_ratio (in condition)`

Example:

```ruby
# usage: bbox_aspect_ratio (in condition)
bbox_aspect_ratio (in condition)
```

### `bbox_height`

Selects primary shapes based on their bounding box height

This method creates a universal DRC expression (see Layer#drc) to select primary shapes whose bounding box height satisfies the condition. Conditions may be written as arithmetic comparisons against numeric values. For example, "bbox_height Layer#drc for more details about comparison specs. Plain "bbox_min" is equivalent to "primary.bbox_min" - i.e. it is used on the primary shape. Also see DRC#bbox_min.

Usage:

- `bbox_height (in condition)`

Example:

```ruby
# usage: bbox_height (in condition)
bbox_height (in condition)
```

### `bbox_max`

Selects primary shapes based on their bounding box height or width, whichever is larger

Usage:

- `bbox_max (in condition)`

Example:

```ruby
# usage: bbox_max (in condition)
bbox_max (in condition)
```

### `bbox_min`

Selects primary shapes based on their bounding box height or width, whichever is smaller

Usage:

- `bbox_max (in condition)`

Example:

```ruby
# usage: bbox_max (in condition)
bbox_max (in condition)
```

### `bbox_width`

Selects primary shapes based on their bounding box width

Usage:

- `bbox_max (in condition)`

Example:

```ruby
# usage: bbox_max (in condition)
bbox_max (in condition)
```

### `bjt3`

Supplies the BJT3 transistor extractor class

Use this class with extract_devices to specify extraction of a bipolar junction transistor

Usage:

- `bjt3(name)`
- `bjt3(name, class)`

Example:

```ruby
extract_devices(bjt3("DEV"), { "A" => input(1, 0), "B" => input(2, 0) })
```

### `bjt4`

Supplies the BJT4 transistor extractor class

Use this class with extract_devices to specify extraction of a bipolar junction transistor with a substrate terminal

Usage:

- `bjt4(name)`
- `bjt4(name, class)`

Example:

```ruby
extract_devices(bjt4("DEV"), { "A" => input(1, 0), "B" => input(2, 0) })
```

### `box`

Creates a box object

This function creates a box object. The arguments are the same than for the DBox constructors.

Usage:

- `box(...)`

Example:

```ruby
# usage: box(...)
box(...)
```

### `capacitor`

Supplies the capacitor extractor class

Use this class with extract_devices to specify extraction of a capacitor. The area_cap argument is the capacitance in Farad per square micrometer.

Usage:

- `capacitor(name, area_cap)`
- `capacitor(name, area_cap, class)`

Example:

```ruby
extract_devices(capacitor("DEV"), { "A" => input(1, 0), "B" => input(2, 0) })
```

### `capacitor_with_bulk`

Supplies the capacitor extractor class that includes a bulk terminal

Use this class with extract_devices to specify extraction of a capacitor with a bulk terminal. The area_cap argument is the capacitance in Farad per square micrometer.

Usage:

- `capacitor_with_bulk(name, area_cap)`
- `capacitor_with_bulk(name, area_cap, class)`

Example:

```ruby
extract_devices(capacitor_with_bulk("DEV"), { "A" => input(1, 0), "B" => input(2, 0) })
```

### `cell`

Selects a cell for input on the default source

See Source#cell for a description of that function. In addition to the functionality described there, the global function will also send the output to the specified cell.

The following code will select cell "MACRO" from the input layout:

Usage:

- `cell(args)`

Example:

```ruby
cell("MACRO")
# shapes now will be taken from cell "MACRO"
l1 = input(1, 0)
```

### `cheat`

Hierarchy cheats

Hierarchy cheats can be used in deep mode to shortcut hierarchy evaluation for certain cells and consider their local configuration only. Cheats are useful for example when dealing with memory arrays. Often such arrays are build from unit cells and those often overlap with their neighbors. Now, if the hierarchical engine encounters such a situation, it will first analyse all these interactions (which can be expensive) and then it may come to the conclusion that boundary instances need to be hand…

The solution is to cheat: provided the unit cell is fully fledged and neighbors do not disturb the unit cell's configuration in critical ways, the unit cell can be treated as being isolated and results are put together in the usual way.

Usage:

- `cheat(args) { block }`

Example:

```ruby
deep

l1 = input(1, 0)
l2 = input(2, 0)

# usual booleans
l1and2 = l1 & l2

# will compute "UNIT_CELL" isolated and everything else in normal hierarchical mode:
l1minus2 = cheat("UNIT_CELL) { l1 - l2 }
```

```ruby
deep

l1 = input(1, 0)
l2 = input(2, 0)

# computes both AND and NOT of l1 and l2 with cheating for "UNIT_CELL"
l1and2, l1minus2 = cheat("UNIT_CELL) do
[ l1 & l2, l1 - l2 ]
end
```

```ruby
deep

poly = input(1, 0)
active = input(2, 0)

sd = active - poly
gate = active & poly

# device extraction with cheating for "UNIT_CELL":
cheat("UNIT_CELL") do
extract_devices(mos3("NMOS"), { "SD" => sd, "G" => gate, "tS" => sd, "tD" => sd, "tG" => poly }
end
```

### `clear_connections`

Clears all connections stored so far

Usage:

- `clear_connections`

Example:

```ruby
# usage: clear_connections
clear_connections
```

### `clip`

Specifies clipped input on the default source

The following code will select shapes within a 500x600 micron rectangle (lower left corner at 0,0) from the input layout. The shapes will be clipped to that rectangle:

clip(0.mm, 0.mm, 0.5.mm, 0.6.mm) # shapes now will be taken from the given rectangle and clipped to it l1 = input(1, 0)

Usage:

- `clip(args)`

Example:

```ruby
clip(0.mm, 0.mm, 0.5.mm, 0.6.mm)
# shapes now will be taken from the given rectangle and clipped to it
l1 = input(1, 0)
```

### `connect`

Specifies a connection between two layers

Usage:

- `connect(a, b)`

Example:

```ruby
# usage: connect(a, b)
connect(a, b)
```

### `connect_explicit`

Specifies explicit net connections

See Netter#connect_explicit for a description of that function. Net names is an array (use square brackets to list the net names).

Usage:

- `connect_explicit(net_names)`
- `connect_explicit(cell_pattern, net_names)`

Example:

```ruby
# usage: connect_explicit(net_names)
connect_explicit(net_names)
```

### `connect_global`

Specifies a connection to a global net

Usage:

- `connect_global(l, name)`

Example:

```ruby
# usage: connect_global(l, name)
connect_global(l, name)
```

### `connect_implicit`

Specifies a label pattern for implicit net connections

Usage:

- `connect_implicit(label_pattern)`
- `connect_implicit(cell_pattern, label_pattern)`

Example:

```ruby
# usage: connect_implicit(label_pattern)
connect_implicit(label_pattern)
```

### `corners`

Selects corners of polygons

This function can be used with a layer argument. In this case it is equivalent to "layer.corners" (see Layer#corners). Without a layer argument, "corners" represents the corner generator/filter in primary shapes for DRC expressions (see Layer#drc and corners for more details).

Like the layer-based version, the "corners" operator accepts the output type option: "as_dots" for dot-like edges, "as_boxes" for small (2x2 DBU) box markers and "as_edge_pairs" for edge pairs. The default output type is "as_boxes".

Usage:

- `corners([ options ]) (in condition)`
- `corners(layer [, options ])`

Example:

```ruby
# usage: corners([ options ]) (in condition)
corners() (in condition)
```

### `covering`

Selects shapes entirely covering other shapes

This operator represents the selector of primary shapes which entirely cover shapes from the other layer. This version can be put into a condition indicating how many shapes of the other layer need to be covered. Use this operator within DRC expressions (also see Layer#drc). If can be used as method to an expression. See there for more details: covering.

Usage:

- `covering(other) (optionally in condition)`

Example:

```ruby
layer = input(1, 0)
errors = covering(layer, 0.2.um)
errors.output("covering_violations")
```

### `dbu`

Gets or sets the database unit to use

Without any argument, this method gets the database unit used inside the DRC engine.

With an argument, sets the database unit used internally in the DRC engine. Without using that method, the database unit is automatically taken as the database unit of the last input. A specific database unit can be set in order to optimize for two layouts (i.e. take the largest common denominator). When the database unit is set, it must be set at the beginning of the script and before any operation that uses it.

Usage:

- `dbu(dbu_value)`
- `dbu`

Example:

```ruby
# usage: dbu(dbu_value)
dbu(dbu_value)
```

### `deep`

Enters deep (hierarchical) mode

In deep mode, the operations will be performed in a hierarchical fashion. Sometimes this reduces the time and memory required for an operation, but this will also add some overhead for the hierarchical analysis.

"deepness" is a property of layers. Layers created with "input" while in deep mode carry hierarchy. Operations involving such layers at the only or the first argument are carried out in hierarchical mode.

Usage:

- `deep`

Example:

```ruby
deep
metal = input(1, 0)
```

### `deep_reject_odd_polygons`

Gets or sets a value indicating whether the reject odd polygons in deep mode

In deep mode, non-orientable (e.g. "8"-shaped) polygons may not be resolved properly. By default the interpretation of such polygons is undefined - they may even vanish entirely. By setting this flag to true, the deep mode layout processor will reject such polygons with an error.

Usage:

- `deep_reject_odd_polygons(flag)`
- `deep_reject_odd_polygons`

Example:

```ruby
# usage: deep_reject_odd_polygons(flag)
deep_reject_odd_polygons(flag)
```

### `def_output`

Gets an object describing the default output channel

The function returns an object describing the current output channel. This channel object can be used like the channels delivered by new_target or new_report.

These readonly attributes are supported by the channel object:

Usage:

- `def_output`

Example:

```ruby
# usage: def_output
def_output
```

### `device_scaling`

Specifies a dimension scale factor for the geometrical device properties

Usage:

- `device_scaling(factor)`

Example:

```ruby
# usage: device_scaling(factor)
device_scaling(factor)
```

### `diode`

Supplies the diode extractor class

Use this class with extract_devices to specify extraction of a planar diode

Usage:

- `diode(name)`
- `diode(name, class)`

Example:

```ruby
extract_devices(diode("DEV"), { "A" => input(1, 0), "B" => input(2, 0) })
```

### `dmos3`

Supplies the DMOS3 transistor extractor class

Use this class with extract_devices to specify extraction of a three-terminal DMOS transistor. A DMOS transistor is essentially the same than a MOS transistor, but source and drain are separated.

See DeviceExtractorMOS3Transistor for more details about this extractor (strict mode applies for 'dmos3').

Usage:

- `dmos3(name)`
- `dmos3(name, class)`

Example:

```ruby
extract_devices(dmos3("NMOS"), {
  "SD" => input(11, 0),
  "G"  => input(12, 0),
  "P"  => input(14, 0),
  "B"  => input(13, 0)
})
```

### `dmos4`

Supplies the MOS4 transistor extractor class

Use this class with extract_devices to specify extraction of a four-terminal DMOS transistor. A DMOS transistor is essentially the same than a MOS transistor, but source and drain are separated.

See DeviceExtractorMOS4Transistor for more details about this extractor (strict mode applies for 'dmos4').

Usage:

- `dmos4(name)`
- `dmos4(name, class)`

Example:

```ruby
extract_devices(dmos4("NMOS"), {
  "SD" => input(11, 0),
  "G"  => input(12, 0),
  "P"  => input(14, 0),
  "B"  => input(13, 0)
})
```

### `edge`

Creates an edge object

This function creates an edge object. The arguments are the same than for the DEdge constructors.

Usage:

- `edge(...)`

Example:

```ruby
# usage: edge(...)
edge(...)
```

### `edge_layer`

Creates an empty edge layer

The intention of that method is to create an empty layer which can be filled with edge objects using Layer#insert.

Usage:

- `edge_layer`

Example:

```ruby
l = edge_layer
l.insert(box(0, 0, 1.um, 1.um))
```

### `edge_pairs`

Gets the edges from an original layer

Usage:

- `edge_pairs(args)`

Example:

```ruby
# usage: edge_pairs(args)
edge_pairs(args)
```

### `edges`

Gets the edges from an original layer

Usage:

- `edges(args)`

Example:

```ruby
# usage: edges(args)
edges(args)
```

### `enc`

Synonym for "enclosing"

"enc" is the short form for enclosing.

Usage:

- `enc(...)`

Example:

```ruby
layer = input(1, 0)
errors = enc(layer, 0.2.um)
errors.output("enc_violations")
```

### `enclosed`

Performs an enclosing check (other enclosing layer)

This check verifies if the polygons of the input layer are enclosed by shapes of the other input layer by a certain distance. It has manifold options. See Layer#width for the basic options such as metrics, projection and angle constraints etc. This check also features opposite and rectangle filtering. See Layer#separation for details about opposite and rectangle error filtering.

This function is essentially the reverse of enclosing. In case of "enclosed", the other layer must be bigger than the primary layer.

Usage:

- `enclosed(other [, options ]) (in conditions)`
- `enclosed(layer, other [, options ])`

Example:

```ruby
# classic "enclosed" check for < 0.2 um
in = layer(1, 0)
other = layer(2, 0)
errors = enclosed(in, other, 0.2.um)
```

```ruby
# universal DRC "enclosed" check for < 0.2 um
in = layer(1, 0)
other = layer(2, 0)
errors = in.drc(enclosed(other) < 0.2.um)
```

```ruby
out = in.drc(enclosed(other)  0.2.um)
out = in.drc(enclosed(other) >= 0.2.um)
out = in.drc(enclosed(other) == 0.2.um)
out = in.drc(enclosed(other) != 0.2.um)
out = in.drc(0.1.um <= enclosed(other) < 0.2.um)
```

### `enclosing`

Performs an enclosing check

This check verifies if the polygons of the input layer are enclosing the shapes of the other input layer by a certain distance. It has manifold options. See Layer#width for the basic options such as metrics, projection and angle constraints etc. This check also features opposite and rectangle filtering. See Layer#separation for details about opposite and rectangle error filtering.

This function can be used in classic mode with a layer argument. In this case it is equivalent to "layer.enclosing" (see Layer#enclosing).

Usage:

- `enclosing(other [, options ]) (in conditions)`
- `enclosing(layer, other [, options ])`

Example:

```ruby
# classic "enclosing" check for < 0.2 um
in = layer(1, 0)
other = layer(2, 0)
errors = enclosing(in, other, 0.2.um)
```

```ruby
# universal DRC "enclosing" check for < 0.2 um
in = layer(1, 0)
other = layer(2, 0)
errors = in.drc(enclosing(other) < 0.2.um)
```

```ruby
out = in.drc(enclosing(other)  0.2.um)
out = in.drc(enclosing(other) >= 0.2.um)
out = in.drc(enclosing(other) == 0.2.um)
out = in.drc(enclosing(other) != 0.2.um)
out = in.drc(0.1.um <= enclosing(other) < 0.2.um)
```

### `error`

Prints an error

Similar to log, but the message is printed formatted as an error

Usage:

- `error(message)`

Example:

```ruby
# usage: error(message)
error(message)
```

### `evaluate_nets`

Evaluates expressions on nets

Usage:

- `evaluate_nets(primary_layer, secondary_layers, expression [, variables])`

Example:

```ruby
# usage: evaluate_nets(primary_layer, secondary_layers, expression [, variables])
evaluate_nets(primary_layer, secondary_layers, expression )
```

### `extent`

Creates a new layer with the bounding box of the default source or cell bounding boxes

Usage:

- `extent`
- `extent(cell_filter)`

Example:

```ruby
# usage: extent
extent
```

### `extent_refs`

Returns partial references to the boundings boxes of the polygons

This function can be used with a layer argument. In this case it is equivalent to "layer.extent_refs" (see Layer#extent_refs). Without a layer argument, "extent_refs" represents the partial extents extractor on primary shapes within DRC expressions (see Layer#drc and extent_refs for more details).

Usage:

- `extent_refs([ options ])`
- `extent_refs(layer, [ options ])`

Example:

```ruby
# usage: extent_refs([ options ])
extent_refs()
```

### `extents`

Returns the bounding box of each input object

This function can be used with a layer argument. In this case it is equivalent to "layer.extents" (see Layer#extents). Without a layer argument, "extents" represents the extents generator on primary shapes within DRC expressions (see Layer#drc and extents for more details).

Usage:

- `extents([ enlargement ])`
- `extents(layer, [ enlargement ])`

Example:

```ruby
# usage: extents([ enlargement ])
extents()
```

### `extract_devices`

Extracts devices for a given device extractor and device layer selection

Usage:

- `extract_devices(extractor, layer_hash)`
- `extract_devices(extractor_class, name, layer_hash)`

Example:

```ruby
# usage: extract_devices(extractor, layer_hash)
extract_devices(extractor, layer_hash)
```

### `flat`

Disables tiling mode

Disables tiling mode. Tiling mode can be enabled again with tiles later.

Usage:

- `flat`

Example:

```ruby
flat
metal = input(1, 0)
```

### `foreign`

Represents all other polygons from primary except the current one

The primary input of the universal DRC function is the layer the Layer#drc function is called on. This operation represents all "other" primary polygons while primary represents the current polygon.

This feature opens new options for processing layouts beyond the abilities of the classical DRC concept. For classic DRC, intra-layer interactions are always symmetric: a polygon cannot be considered separated from its neighbors on the same layer.

Usage:

- `foreign`

Example:

```ruby
out = in.drc(primary & foreign.sized(0.5.um))
```

### `global_transform`

Gets or sets a global transformation

Applies a global transformation to the default source layout. See Source#global_transform for a description of this feature.

Usage:

- `global_transform`
- `global_transform([ transformations ])`

Example:

```ruby
# usage: global_transform
global_transform
```

### `holes`

Selects all holes from the input polygons

This function can be used with a layer argument. In this case it is equivalent to "layer.holes" (see Layer#hulls). Without a layer argument, "holes" represents a hole extractor for primary shapes in DRC expressions (see Layer#drc and DRC#hulls for more details).

Usage:

- `holes`
- `holes(layer)`

Example:

```ruby
# usage: holes
holes
```

### `hulls`

Selects all hulls from the input polygons

This function can be used with a layer argument. In this case it is equivalent to "layer.hulls" (see Layer#hulls). Without a layer argument, "hulls" represents a hull contour extractor for primary shapes in DRC expressions (see Layer#drc and hulls for more details).

Usage:

- `hulls`
- `hulls(layer)`

Example:

```ruby
# usage: hulls
hulls
```

### `if_all`

Evaluates to the primary shape when all condition expression results are non-empty

This function will evaluate the conditions c1 to cn and return the current primary shape if all conditions render a non-empty result. The following example selects all shapes which are rectangles and whose area is larger than 0.5 square micrometers:

out = in.drc(if_all(area > 0.5, rectangles))

Usage:

- `if_all(c1, ... cn)`

Example:

```ruby
out = in.drc(if_all(area > 0.5, rectangles))
```

### `if_any`

Evaluates to the primary shape when any condition expression results is non-empty

This function will evaluate the conditions c1 to cn and return the current primary shape if at least one condition renders a non-empty result. See if_all for an example how to use the if_... functions.

Usage:

- `if_any(c1, ... cn)`

Example:

```ruby
# usage: if_any(c1, ... cn)
if_any(c1, ... cn)
```

### `if_none`

Evaluates to the primary shape when all of the condition expression results are empty

This function will evaluate the conditions c1 to cn and return the current primary shape if all conditions renders an empty result. See if_all for an example how to use the if_... functions.

Usage:

- `if_none(c1, ... cn)`

Example:

```ruby
# usage: if_none(c1, ... cn)
if_none(c1, ... cn)
```

### `ignore_extraction_errors`

Specifies whether to ignore extraction errors

Usage:

- `ignore_extraction_errors(value)`

Example:

```ruby
# usage: ignore_extraction_errors(value)
ignore_extraction_errors(value)
```

### `info`

Outputs as message to the logger or progress window

Prints the message to the log window in verbose mode. In non-verbose more, nothing is printed but a statement is put into the progress window. log is a function that always prints a message.

Usage:

- `info(message)`
- `info(message, indent)`

Example:

```ruby
# usage: info(message)
info(message)
```

### `input`

Fetches the shapes from the specified input from the default source

See Source#input for a description of that function. This method will fetch polygons and labels. See polygons and labels for more specific versions of this method.

Usage:

- `input(args)`

Example:

```ruby
metal1 = input(1, 0)
via1   = input(2, 0)
metal2 = input(3, 0)
```

### `inside`

Selects shapes entirely inside other shapes

This operator represents the selector of primary shapes which are inside shapes from the other layer. Use this operator within DRC expressions (also see Layer#drc). If can be used as method to an expression. See there for more details: inside.

Usage:

- `inside(other)`

Example:

```ruby
layer = input(1, 0)
errors = inside(layer, 0.2.um)
errors.output("inside_violations")
```

### `interacting`

Selects shapes interacting with other shapes

This operator represents the selector of primary shapes which interact with shapes from the other layer. This version can be put into a condition indicating how many shapes of the other layer need to be covered. Use this operator within DRC expressions (also see Layer#drc). If can be used as method to an expression. See there for more details: interacting.

Usage:

- `interacting(other) (optionally in condition)`

Example:

```ruby
layer = input(1, 0)
errors = interacting(layer, 0.2.um)
errors.output("interacting_violations")
```

### `is_deep?`

Returns true, if in deep mode

Usage:

- `is_deep?`

Example:

```ruby
# usage: is_deep?
is_deep?
```

### `is_tiled?`

Returns true, if in tiled mode

Usage:

- `is_tiled?`

Example:

```ruby
# usage: is_tiled?
is_tiled?
```

### `iso`

Synonym for "isolated"

"iso" is the short form for isolated.

Usage:

- `iso(...)`

Example:

```ruby
layer = input(1, 0)
errors = iso(layer, 0.2.um)
errors.output("iso_violations")
```

### `isolated`

Performs an isolation (inter-polygon space) check

Provides a intra-polygon space check for polygons. It is similar to space, but checks inter-polygon space only. "iso" is a synonym for "isolated". This check has manifold options. See Layer#width for the basic options such as metrics, projection and angle constraints etc. This check also features opposite and rectangle filtering. See Layer#separation for details about opposite and rectangle error filtering.

This function can be used in classic mode with a layer argument. In this case it is equivalent to "layer.isolated" (see Layer#isolated).

Usage:

- `isolated([ options ]) (in conditions)`
- `iso([ options ]) (in conditions)`
- `isolated(layer [, options ])`
- `iso(layer [, options ])`

Example:

```ruby
# classic "isolated" check for space < 1.2 um
in = layer(1, 0)
errors = isolated(in, 1.2.um)
```

```ruby
# universal DRC "isolated" check for space < 1.2.um
in = layer(1, 0)
errors = in.drc(isolated < 1.2.um)
```

### `l2n_data`

Gets the internal LayoutToNetlist object for the default Netter

Usage:

- `l2n_data`

Example:

```ruby
# usage: l2n_data
l2n_data
```

### `labels`

Gets the labels (text) from an original layer

Usage:

- `labels(args)`

Example:

```ruby
# usage: labels(args)
labels(args)
```

### `layers`

Gets the layers contained in the default source

Usage:

- `layers`

Example:

```ruby
# usage: layers
layers
```

### `layout`

Specifies an additional layout for the input source.

This function can be used to specify a new layout for input. It returns an Source object representing that layout. The "input" method of that object can be used to get input layers for that layout.

"what" specifies what input to use. "what" be either

Usage:

- `layout`
- `layout(what)`

Example:

```ruby
# XOR between layers 1 or the default input and "second_layout.gds":
l2 = layout("second_layout.gds")
(input(1, 0) ^ l2.input(1, 0)).output(100, 0)
```

### `length`

Computes the total edge length of an edge layer or in universal DRC context: selects edges based on a length condition

This function can be used with a layer argument. In this case it is equivalent to "layer.length" (see Layer#length). Without a layer argument, "length" represents the edge length filter on the primary shape edges in DRC expressions (see Layer#drc and DRC#length for more details). In this context, the operation acts similar to Layer#with_length.

Usage:

- `length (in condition)`
- `length(layer)`

Example:

```ruby
# usage: length (in condition)
length (in condition)
```

### `log`

Outputs as message to the logger window

Prints the message to the log window. info is a function that prints a message only if verbose mode is enabled.

Usage:

- `log(message)`
- `log(message, indent)`

Example:

```ruby
# usage: log(message)
log(message)
```

### `log_file`

Specify the log file where to send to log to

After using that method, the log output is sent to the given file instead of the logger window or the terminal.

Usage:

- `log_file(filename)`

Example:

```ruby
# usage: log_file(filename)
log_file(filename)
```

### `make_layer`

Creates an empty polygon layer based on the hierarchical scheme selected

The intention of this method is to provide an empty polygon layer based on the hierarchical scheme selected. This will create a new layer with the hierarchy of the current layout in deep mode and a flat layer in flat mode. This method is similar to polygon_layer, but the latter does not create a hierarchical layer. Hence the layer created by make_layer is suitable for use in device extraction for example, while the one delivered by polygon_layer is not.

On the other hand, a layer created by the make_layer method is not intended to be filled with Layer#insert.

Usage:

- `make_layer`

Example:

```ruby
l = make_layer
l.insert(box(0, 0, 1.um, 1.um))
```

### `max_area_ratio`

Gets or sets the maximum bounding box to polygon area ratio for deep mode fragmentation

In deep mode, polygons with a bounding box to polygon area ratio bigger than the given number will be split into smaller chunks to optimize performance. Performance gets better if the polygon's bounding boxes do not cover too much of empty space.

The area ratio is a signed value. Negative values indicate to use the outer manhattan approximation of the polygons for the area ratio. Positive values indicate to take the polygons as they are. The sign of the value indicates the mode - the actual area ratio checked is the absolute value.

Usage:

- `max_area_ratio(ratio)`
- `max_area_ratio`

Example:

```ruby
# usage: max_area_ratio(ratio)
max_area_ratio(ratio)
```

### `max_vertex_count`

Gets or sets the maximum vertex count for deep mode fragmentation

In deep mode, polygons with more than the given number of vertexes will be split into smaller chunks to optimize performance (which is better or less complex polygons). The default threshold is 16 vertexes. Use this method with a vertex count to set the value and without an argument to get the current maximum vertex count. Set the value to zero to disable splitting by vertex count.

Usage:

- `max_vertex_count(count)`
- `max_vertex_count`

Example:

```ruby
# usage: max_vertex_count(count)
max_vertex_count(count)
```

### `middle`

Returns the centers of polygon bounding boxes

This function can be used with a layer argument. In this case it is equivalent to "layer.middle" (see Layer#middle). Without a layer argument, "middle" represents the bounding box center marker generator on primary shapes within DRC expressions (see Layer#drc and middle for more details).

Usage:

- `middle([ options ])`
- `middle(layer, [ options ])`

Example:

```ruby
# usage: middle([ options ])
middle()
```

### `mos3`

Supplies the MOS3 transistor extractor class

Use this class with extract_devices to specify extraction of a three-terminal MOS transistor.

See DeviceExtractorMOS3Transistor for more details about this extractor (non-strict mode applies for 'mos3').

Usage:

- `mos3(name)`
- `mos3(name, class)`

Example:

```ruby
extract_devices(mos3("NMOS"), {
  "SD" => input(11, 0),
  "G"  => input(12, 0),
  "P"  => input(14, 0),
  "B"  => input(13, 0)
})
```

### `mos4`

Supplies the MOS4 transistor extractor class

Use this class with extract_devices to specify extraction of a four-terminal MOS transistor.

See DeviceExtractorMOS4Transistor for more details about this extractor (non-strict mode applies for 'mos4').

Usage:

- `mos4(name)`
- `mos4(name, class)`

Example:

```ruby
extract_devices(mos4("NMOS"), {
  "SD" => input(11, 0),
  "G"  => input(12, 0),
  "P"  => input(14, 0),
  "B"  => input(13, 0)
})
```

### `name`

Assigns a name to a layer for reference in the LVS database

Usage:

- `name(layer, name)`

Example:

```ruby
# usage: name(layer, name)
name(layer, name)
```

### `name_prefix`

Specifies the layer name prefix for auto-generated layer names

Usage:

- `name_prefix(prefix)`

Example:

```ruby
# usage: name_prefix(prefix)
name_prefix(prefix)
```

### `netlist`

Obtains the extracted netlist from the default Netter

The netlist is a Netlist object. If no netlist is extracted yet, this method will trigger the extraction process. See Netter#netlist for a description of this function.

Example:

```ruby
# netlist
```

### `netter`

Creates a new netter object

Usage:

- `netter`

Example:

```ruby
# usage: netter
netter
```

### `new_report`

Creates a new report database object for use in "output"

This method creates an independent report object. This object can be used in "output" to send a layer to a different report than the default report or target.

Arguments are the same than for report.

Usage:

- `new_report(description [, filename [, cellname ] ])`

Example:

```ruby
# usage: new_report(description [, filename [, cellname ] ])
new_report(description ])
```

### `new_target`

Creates a new layout target object for use in "output"

This method creates an independent target object. This object can be used in "output" to send a layer to a different layout file than the default report or target.

Arguments are the same than for target.

Usage:

- `new_target(what [, cellname])`

Example:

```ruby
# usage: new_target(what [, cellname])
new_target(what )
```

### `no_borders`

Reset the tile borders

Resets the tile borders - see tile_borders for a description of tile borders.

Usage:

- `no_borders`

Example:

```ruby
# usage: no_borders
no_borders
```

### `notch`

Performs a notch (intra-polygon space) check

Provides a intra-polygon space check for polygons. It is similar to space, but checks intra-polygon space only. It has manifold options. See Layer#width for the basic options such as metrics, projection and angle constraints etc.

This function can be used in classic mode with a layer argument. In this case it is equivalent to "layer.notch" (see Layer#notch).

Usage:

- `notch([ options ]) (in conditions)`
- `notch(layer [, options ])`

Example:

```ruby
# classic "notch" check for space < 1.2 um
in = layer(1, 0)
errors = notch(in, 1.2.um)
```

```ruby
# universal DRC "notch" check for space < 1.2.um
in = layer(1, 0)
errors = in.drc(notch < 1.2.um)
```

### `output`

Outputs a layer to the report database or output layout

This function is equivalent to "layer.output(args)". See Layer#output for details about this function.

Usage:

- `output(layer, args)`

Example:

```ruby
markers = metal.width(0.2.um)
output(markers, "width_errors")
```

### `output_cell`

Specifies a target cell, but does not change the target layout

This method switches output to the specified cell, but does not change the target layout nor does it switch the output channel to layout if is report database.

Usage:

- `output_cell(cellname)`

Example:

```ruby
# usage: output_cell(cellname)
output_cell(cellname)
```

### `outside`

Selects shapes entirely outside other shapes

This operator represents the selector of primary shapes which are outside shapes from the other layer. Use this operator within DRC expressions (also see Layer#drc). If can be used as method to an expression. See there for more details: outside.

Usage:

- `outside(other)`

Example:

```ruby
layer = input(1, 0)
errors = outside(layer, 0.2.um)
errors.output("outside_violations")
```

### `overlap`

Performs an overlap check

Provides an overlap check (primary layer vs. another layer). This check has manifold options. See Layer#width for the basic options such as metrics, projection and angle constraints etc. This check also features opposite and rectangle filtering. See Layer#separation for details about opposite and rectangle error filtering.

Like other checks, this function is available as a classic DRC function with a layer as the first argument and as an DRC expression operator for use with Layer#drc.

Usage:

- `overlap(other [, options ]) (in conditions)`
- `overlap(layer, other [, options ])`

Example:

```ruby
# classic "overlap" check for < 0.2 um
in = layer(1, 0)
other = layer(2, 0)
errors = overlap(in, other, 0.2.um)
```

```ruby
# universal DRC "overlap" check for < 0.2 um
in = layer(1, 0)
other = layer(2, 0)
errors = in.drc(overlap(other) < 0.2.um)
```

### `overlapping`

Selects shapes overlapping with other shapes

This operator represents the selector of primary shapes which overlap shapes from the other layer. This version can be put into a condition indicating how many shapes of the other layer need to be covered. Use this operator within DRC expressions (also see Layer#drc). If can be used as method to an expression. See there for more details: overlapping.

Usage:

- `overlapping(other) (optionally in condition)`

Example:

```ruby
# usage: overlapping(other) (optionally in condition)
overlapping(other) (optionally in condition)
```

### `p`

Creates a point object

A point is not a valid object by itself, but it is useful for creating paths for polygons:

x = polygon_layer x.insert(polygon([ p(0, 0), p(16.0, 0), p(8.0, 8.0) ]))

Usage:

- `p(x, y)`

Example:

```ruby
x = polygon_layer
x.insert(polygon([ p(0, 0), p(16.0, 0), p(8.0, 8.0) ]))
```

### `path`

Creates a path object

This function creates a path object. The arguments are the same than for the DPath constructors.

Usage:

- `path(...)`

Example:

```ruby
# usage: path(...)
path(...)
```

### `perimeter`

Computes the total perimeter or in universal DRC context: selects the primary shape if the perimeter is meeting the condition

This function can be used with a layer argument. In this case it is equivalent to "layer.perimeter" (see Layer#perimeter) and returns the total perimeter of all polygons in the layer.

Without a layer argument, "perimeter" represents a perimeter filter for primary shapes in DRC expressions (see Layer#drc and DRC#perimeter for more details).

Usage:

- `perimeter (in condition)`
- `perimeter(layer)`

Example:

```ruby
# usage: perimeter (in condition)
perimeter (in condition)
```

### `polygon`

Creates a polygon object

This function creates a polygon object. The arguments are the same than for the DPolygon constructors.

Usage:

- `polygon(...)`

Example:

```ruby
# usage: polygon(...)
polygon(...)
```

### `polygon_layer`

Creates an empty polygon layer

The intention of that method is to create an empty layer which can be filled with polygon-like objects using Layer#insert. A similar method which creates a hierarchical layer in deep mode is make_layer. This other layer is better suited for use with device extraction.

Usage:

- `polygon_layer`

Example:

```ruby
l = polygon_layer
l.insert(box(0, 0, 1.um, 1.um))
```

### `polygons`

Fetches the polygons (or shapes that can be converted to polygons) from the specified input from the default source

Usage:

- `polygons(args)`

Example:

```ruby
# usage: polygons(args)
polygons(args)
```

### `primary`

Represents the primary input of the universal DRC function

The primary input of the universal DRC function is the layer the Layer#drc function is called on.

Usage:

- `primary`

Example:

```ruby
# usage: primary
primary
```

### `profile`

Profiles the script and provides a runtime + memory statistics

Turns profiling on or off (default). In profiling mode, the system will collect statistics about rules executed, their execution time and memory information. The argument specifies how many operations to print at the end of the run. Without an argument or when passing "true", all operations are printed. Passing "false" for the argument will disable profiling. This is the default.

Usage:

- `profile`
- `profile(n)`

Example:

```ruby
# usage: profile
profile
```

### `props_copy`

Specifies "copy properties" on operations supporting user properties constraints

This properties constraint does not constrain the operation, but instructs it to attach the properties from the primary input to the output objects.

Example:

```ruby
# props_copy
```

### `props_eq`

Specifies "same properties" for operations supporting user properties constraints

Some operations such as boolean AND support properties constraints. By giving a "props_eq" constraint, the operation is performed only on shapes with the same properties, where "properties" stands for the full set of key/value pairs.

Note that you have to enable properties explicitly or generate properties (e.g. with the DRCLayer#nets method).

Example:

```ruby
connect(metal1, via1)
connect(via1, metal2)
... further connect statements

m1m2_overlap_connected = metal1.nets.and(metal2, props_eq)
```

```ruby
m1m2_overlap_connected = metal1.nets.and(metal2, props_eq + props_copy)
```

### `props_ne`

Specifies "different properties" for operations supporting user properties constraints

Some operations such as boolean AND support properties constraints. By giving a "props_ne" constraint, the operation is performed only on shapes with different properties, where "properties" stands for the full set of key/value pairs.

Note that you have to enable properties explicitly or generate properties (e.g. with the DRCLayer#nets method).

Example:

```ruby
connect(metal1, via1)
connect(via1, metal2)
... further connect statements

m1m2_overlap_not_connected = metal1.nets.and(metal2, props_ne)
```

```ruby
m1m2_overlap_connected = metal1.nets.and(metal2, props_ne + props_copy)
```

### `rectangles`

Selects all polygons which are rectangles

This function can be used with a layer argument. In this case it is equivalent to "layer.rectangles" (see Layer#rectangles). Without a layer argument, "rectangles" represents the rectangles filter for primary shapes in DRC expressions (see Layer#drc and rectangles for more details).

Usage:

- `rectangles`
- `rectangles(layer)`

Example:

```ruby
# usage: rectangles
rectangles
```

### `rectilinear`

Selects all polygons which are rectilinear

This function can be used with a layer argument. In this case it is equivalent to "layer.rectilinear" (see Layer#rectilinear). Without a layer argument, "rectilinear" represents the rectilinear polygons filter for primary shapes in DRC expressions (see Layer#drc and rectilinear for more details).

Usage:

- `rectilinear`
- `rectilinear(layer)`

Example:

```ruby
# usage: rectilinear
rectilinear
```

### `region_overlap`

Specifies region selected input in "overlap mode"

The following code will select shapes overlapping a 500x600 micron rectangle (lower left corner at 0,0) from the input layout. The shapes will not be clipped:

region_overlapping(0.mm, 0.mm, 0.5.mm, 0.6.mm) # shapes will now be the ones overlapping the rectangular region l1 = input(1, 0)

Usage:

- `region_overlap(args)`

Example:

```ruby
region_overlapping(0.mm, 0.mm, 0.5.mm, 0.6.mm)
# shapes will now be the ones overlapping the rectangular region
l1 = input(1, 0)
```

### `region_touch`

Specifies region selected input in "touch mode"

The following code will select shapes touching a 500x600 micron rectangle (lower left corner at 0,0) from the input layout. The shapes will not be clipped:

region_touch(0.mm, 0.mm, 0.5.mm, 0.6.mm) # shapes will now be the ones touching the rectangular region l1 = input(1, 0)

Usage:

- `region_touch(args)`

Example:

```ruby
region_touch(0.mm, 0.mm, 0.5.mm, 0.6.mm)
# shapes will now be the ones touching the rectangular region
l1 = input(1, 0)
```

### `relative_height`

Selects primary shapes based on the ratio of height and width of their bounding boxes

Usage:

- `relative_height (in condition)`

Example:

```ruby
# usage: relative_height (in condition)
relative_height (in condition)
```

### `report`

Specifies a report database for output

After specifying a report database for output, output method calls are redirected to the report database. The format of the output calls changes and a category name plus description can be specified rather than a layer/datatype number of layer name. See the description of the output method for details.

If a filename is given, the report database will be written to the specified file name. Otherwise it will be shown but not written.

Usage:

- `report(description [, filename [, cellname ] ])`

Example:

```ruby
report("My DRC", "drc.lyrdb")
```

### `report_netlist`

Specifies an extracted netlist report for output

This method applies to runsets creating a netlist through extraction. Extraction happens when connections and/or device extractions are made. If this statement is used, the extracted netlist plus the net and device shapes are turned into a layout-to-netlist report (L2N database) and shown in the netlist browser window. If a file name is given, the report will also be written to the given file. If a file name is given and "long" is true, a verbose version of the L2N DB format will be used.

Usage:

- `report_netlist([ filename [, long ] ])`

Example:

```ruby
# usage: report_netlist([ filename [, long ] ])
report_netlist( ])
```

### `resistor`

Supplies the resistor extractor class

Use this class with extract_devices to specify extraction of a resistor.

The sheet_rho value is the sheet resistance in ohms/square. It is used to compute the resistance from the geometry.

Usage:

- `resistor(name, sheet_rho)`
- `resistor(name, sheet_rho, class)`

Example:

```ruby
extract_devices(resistor("DEV"), { "A" => input(1, 0), "B" => input(2, 0) })
```

### `resistor_with_bulk`

Supplies the resistor extractor class that includes a bulk terminal

Use this class with extract_devices to specify extraction of a resistor with a bulk terminal. The sheet_rho value is the sheet resistance in ohms/square.

Usage:

- `resistor_with_bulk(name, sheet_rho)`
- `resistor_with_bulk(name, sheet_rho, class)`

Example:

```ruby
extract_devices(resistor_with_bulk("DEV"), { "A" => input(1, 0), "B" => input(2, 0) })
```

### `rounded_corners`

Applies corner rounding

This function can be used with a layer argument. In this case it is equivalent to "layer.rounded_corners" (see Layer#rounded_corners). Without a layer argument, "rounded_corners" represents the corner rounding algorithm on primary shapes within DRC expressions (see Layer#drc and rounded_corners for more details).

Usage:

- `rounded_corners(inner, outer, n)`
- `rounded_corners(layer, inner, outer, n)`

Example:

```ruby
# usage: rounded_corners(inner, outer, n)
rounded_corners(inner, outer, n)
```

### `secondary`

Provides secondary input for the "drc" universal DRC function

To supply additional input for the universal DRC expressions (see Layer#drc), use "secondary" with a layer argument. This example provides a boolean AND between l1 and l2:

l1 = layer(1, 0) l2 = layer(2, 0) out = l1.drc(primary & secondary(l2))

Usage:

- `secondary(layer)`

Example:

```ruby
l1 = layer(1, 0)
l2 = layer(2, 0)
out = l1.drc(primary & secondary(l2))
```

### `select`

Specifies cell filters on the default source

See Source#select for a description of that function. Using the global version does not create a new source, but modifies the default source.

# Selects only B cell instances below the top cell select("-", "+B*") l1 = input(1, 0)

Usage:

- `select(args)`

Example:

```ruby
# Selects only B cell instances below the top cell
select("-", "+B*")
l1 = input(1, 0)
```

### `sep`

Synonym for "separation"

"sep" is the short form for separation.

Usage:

- `sep(...)`

Example:

```ruby
layer = input(1, 0)
errors = sep(layer, 0.2.um)
errors.output("sep_violations")
```

### `separation`

Performs a separation check

Provides a separation check (primary layer vs. another layer). Like enclosing this function provides a two-layer check, but checking the distance rather than the overlap. This check has manifold options. See Layer#width for the basic options such as metrics, projection and angle constraints etc. This check also features opposite and rectangle filtering. See Layer#separation for details about opposite and rectangle error filtering.

Like enclosing, this function is available as a classic DRC function with a layer as the first argument and as an DRC expression operator for use with Layer#drc.

Usage:

- `separation(other [, options ]) (in conditions)`
- `separation(layer, other [, options ])`

Example:

```ruby
# classic "separation" check for distance < 0.2 um
in = layer(1, 0)
other = layer(2, 0)
errors = separation(in, other, 0.2.um)
```

```ruby
# universal DRC "separation" check for distance < 0.2 um
in = layer(1, 0)
other = layer(2, 0)
errors = in.drc(separation(other) < 0.2.um)
```

```ruby
l1_edges_without_l2 = l1.drc((separation(l2) >= 1.0).first_edges)
```

### `silent`

Resets verbose mode

This function is equivalent to "verbose(false)" (see verbose)

Usage:

- `silent`

Example:

```ruby
silent
metal = input(1, 0)
```

### `sized`

Returns the sized version of the input

This function can be used with a layer argument. In this case it is equivalent to "layer.sized" (see Layer#sized). Without a layer argument, "sized" represents the polygon sizer on primary shapes within DRC expressions (see Layer#drc and sized for more details).

Usage:

- `sized(d [, mode])`
- `sized(dx, dy [, mode]))`
- `sized(layer, d [, mode])`
- `sized(layer, dx, dy [, mode]))`

Example:

```ruby
# usage: sized(d [, mode])
sized(d )
```

### `smoothed`

Applies smoothing

This function can be used with a layer argument. In this case it is equivalent to "layer.smoothed" (see Layer#smoothed). Without a layer argument, "smoothed" represents the polygon smoother on primary shapes within DRC expressions (see Layer#drc and smoothed for more details).

Usage:

- `smoothed(d)`
- `smoothed(layer, d)`

Example:

```ruby
# usage: smoothed(d)
smoothed(d)
```

### `soft_connect`

Specifies a soft connection between two layers

A "soft connection" is made between two layers and is a directional connection (like an ideal diode). Soft connections allow detecting if nets are connected via a high-ohmic substrate or diffusion layer (the "lower" layer). "b" is the "lower" and "a" the upper layer.

Usage:

- `soft_connect(a, b)`

Example:

```ruby
# usage: soft_connect(a, b)
soft_connect(a, b)
```

### `soft_connect_global`

Specifies a soft connection to a global net

Like soft_connect, a soft connection is made between a layer and a global net (e.g. substrate). The global net is always the "lower" net of the soft connection.

Usage:

- `soft_connect_global(l, name)`

Example:

```ruby
# usage: soft_connect_global(l, name)
soft_connect_global(l, name)
```

### `source`

Specifies a source layout

This function replaces the default source layout by the specified file. If this function is not used, the currently active layout is used as input.

layout is a similar method which specifies an additional input layout.

Usage:

- `source`
- `source(what)`

Example:

```ruby
# XOR between layers 1 of "first_layout.gds" and "second_layout.gds" and sends the results to "xor_layout.gds":
target("xor_layout.gds")
source("first_layout.gds")
l2 = layout("second_layout.gds")
(input(1, 0) ^ l2.input(1, 0)).output(100, 0)
```

### `space`

Performs a space check

"space" looks for spacing violations between edges of the same polygon (intra-polygon checks) and between different polygons (inter-polygon checks). notch is similar function that provides only intra-polygon space checks. isolated is the version checking inter-polygon distance only. The check has manifold options. See Layer#width for the basic options such as metrics, projection and angle constraints etc.

This function can be used in classic mode with a layer argument. In this case it is equivalent to "layer.space" (see Layer#space). In this mode, "space" is applicable to edge layers too.

Usage:

- `space([ options ]) (in conditions)`
- `space(layer [, options ])`

Example:

```ruby
# classic "space" check for space < 0.2 um
in = layer(1, 0)
errors = space(in, 0.2.um)
```

```ruby
# universal DRC check for space < 0.2.um
in = layer(1, 0)
errors = in.drc(space < 0.2.um)
```

### `sparse_array_limit`

Gets or sets the sparse array singularization limit

In deep mode, array instances with a bad ratio of overall bounding box area vs. actually covered area, induce a performance penalty, because their bounding box is not longer a good approximation for their footprint. The "sparse array limit" defines the ratio of array instance bounding box area vs. sum of bounding box areas of the individual instances, above which the array is resolved into single instances.

Use this method without an argument to get the current value.

Usage:

- `sparse_array_limit(limit)`
- `sparse_array_limit`

Example:

```ruby
# usage: sparse_array_limit(limit)
sparse_array_limit(limit)
```

### `squares`

Selects all polygons which are squares

This function can be used with a layer argument. In this case it is equivalent to "layer.squares" (see Layer#squares). Without a layer argument, "squares" represents the rectangles filter for primary shapes in DRC expressions (see Layer#drc and squares for more details).

Usage:

- `squares`
- `squares(layer)`

Example:

```ruby
# usage: squares
squares
```

### `switch`

A conditional selector for the "drc" universal DRC function

This function provides a conditional selector for the "drc" function. It is used this way:

out = in.drc(switch(c1, r1, c2, r2, ..., cn, rn) out = in.drc(switch(c1, r1, c2, r2, ..., cn, rn, rdef)

Usage:

- `switch(...)`

Example:

```ruby
out = in.drc(switch(c1, r1, c2, r2, ..., cn, rn)
out = in.drc(switch(c1, r1, c2, r2, ..., cn, rn, rdef)
```

### `target`

Specify the target layout

This function can be used to specify a target layout for output. Subsequent calls of "output" will send their results to that target layout. Using "target" will disable output to a report database. If any target was specified before, that target will be closed and a new target will be set up.

"what" specifies what input to use. "what" be either

Usage:

- `target`
- `target(what [, cellname])`

Example:

```ruby
target("out.gds")
```

### `target_netlist`

With this statement, an extracted netlist is finally written to a file

This method applies to runsets creating a netlist through extraction. Extraction happens when connections and/or device extractions are made. If this statement is used, the extracted netlist is written to the given file.

The format parameter specifies the writer to use. You can use nil to use the standard format or produce a SPICE writer with write_spice. See write_spice for more details.

Usage:

- `target_netlist(filename [, format [, comment ] ])`

Example:

```ruby
# usage: target_netlist(filename [, format [, comment ] ])
target_netlist(filename ])
```

### `threads`

Specifies the number of CPU cores to use in tiling mode

If using threads, tiles are distributed on multiple CPU cores for parallelization. Still, all tiles must be processed before the operation proceeds with the next statement.

Without an argument, "threads" will return the current number of threads

Usage:

- `threads(n)`
- `threads`

Example:

```ruby
threads
metal = input(1, 0)
```

### `tile_borders`

Specifies a minimum tile border

The tile border specifies the distance to which shapes are collected into the tile. In order words, when processing a tile, shapes within the border distance participate in the operations.

For some operations such as booleans (Layer#and, Layer#or, ...), Layer#size and the DRC functions (Layer#width, Layer#space, ...) a tile border is automatically established. For other operations such as Layer#with_area or Layer#edges, the exact distance is unknown, because such operations may have a long range. In that cases, no border is used. The tile_borders function may be used to specify a minimum border which is used in that case. That allows taking into account at least shapes within the…

Usage:

- `tile_borders(b)`
- `tile_borders(bx, by)`

Example:

```ruby
# usage: tile_borders(b)
tile_borders(b)
```

### `tiles`

Specifies tiling

Specifies tiling mode. In tiling mode, the DRC operations are evaluated in tiles with width w and height h. With one argument, square tiles with width and height t are used.

Special care must be taken when using tiling mode, since some operations may not behave as expected at the borders of the tile. Tiles can be made overlapping by specifying a tile border dimension with tile_borders. Some operations like sizing, the DRC functions specify a tile border implicitly. Other operations without a defined range won't do so and the consequences of tiling mode can be difficult to predict.

Usage:

- `tiles(t)`
- `tiles(w, h)`

Example:

```ruby
tiles
metal = input(1, 0)
```

### `top_level`

Specifies that the circuit is a chip top level circuit

Usage:

- `top_level(flag)`

Example:

```ruby
# usage: top_level(flag)
top_level(flag)
```

### `verbose`

Sets or resets verbose mode

In verbose mode, more output is generated in the log file

Usage:

- `verbose`
- `verbose(m)`

Example:

```ruby
verbose
metal = input(1, 0)
```

### `verbose?`

Returns true, if verbose mode is enabled

In verbose mode, more output is generated in the log file

Usage:

- `verbose?`

Example:

```ruby
# usage: verbose?
verbose?
```

### `warn`

Prints a warning

Similar to log, but the message is printed formatted as a warning

Usage:

- `warn(message)`

Example:

```ruby
# usage: warn(message)
warn(message)
```

### `width`

Performs a width check

A width check is a check for the distance of edges of the same polygon.

This function can be used in classic mode with a layer argument. In this case it is equivalent to "layer.width" (see Layer#width).

Usage:

- `width([ options ]) (in conditions)`
- `width(layer [, options ])`

Example:

```ruby
# classic "width" check for width < 2 um
in = layer(1, 0)
errors = width(in, 0.2.um)
```

```ruby
# universal DRC check for width < 2 um
in = layer(1, 0)
errors = in.drc(width < 0.2.um)
```

```ruby
errors = in.drc(width  0.2.um)
errors = in.drc(width >= 0.2.um)
errors = in.drc(width == 0.2.um)
errors = in.drc(width != 0.2.um)
errors = in.drc(0.1.um <= width < 0.2.um)
```

### `with_holes`

Selects all input polygons according to their number of holes in DRC expressions

"with_holes" represents a polygon selector for DRC expressions selecting polygons of the primary by their number of holes (see Layer#drc and with_holes for more details).

Usage:

- `with_holes (in condition)`

Example:

```ruby
# usage: with_holes (in condition)
with_holes (in condition)
```

### `write_spice`

Defines SPICE output format (with options)

Use this option in target_netlist for the format parameter to specify SPICE format. "use_net_names" and "with_comments" are boolean parameters indicating whether to use named nets (numbers if false) and whether to add information comments such as instance coordinates or pin names.

"writer_delegate" allows using a NetlistSpiceWriterDelegate object to control the actual writing.

Usage:

- `write_spice([ use_net_names [, with_comments ] ])`
- `write_spice(writer_delegate [, use_net_names [, with_comments ] ])`

Example:

```ruby
# usage: write_spice([ use_net_names [, with_comments ] ])
write_spice( ])
```


---

## Source object

| Command | Description |
|---|---|
| `cell` | Specifies input from a specific cell |
| `cell_name` | Returns the name of the currently selected cell |
| `cell_obj` | Returns the Cell object of the currently selected cell |
| `clip` | Specifies clipped input |
| `edge_pairs` | Gets the edge pairs from an input layer |
| `edges` | Gets the edge shapes (or shapes that can be converted edges) from an input layer |
| `extent` | Returns a layer with the bounding box of the selected layout or cells |
| `global_transform` | Gets or sets a global transformation |
| `input` | Specifies input from a source |
| `labels` | Gets the labels (texts) from an input layer |
| `layers` | Gets the layers the source contains |
| `layout` | Returns the Layout object associated with this source |
| `make_layer` | Creates an empty polygon layer based on the hierarchy of the layout |
| `overlapping` | Specifies input selected from a region in overlapping mode |
| `path` | Gets the path of the corresponding layout file or nil if there is no path |
| `polygons` | Gets the polygon shapes (or shapes that can be converted polygons) from an input layer |
| `select` | Adds cell name expressions to the cell filters |
| `touching` | Specifies input selected from a region in touching mode |

### Source method details

### `cell`

Specifies input from a specific cell

This method will create a new source that delivers shapes from the specified cell.

Usage:

- `source.cell(name)`

Example:

```ruby
s = source("chip.gds")
s.cell("TOP")
metal = s.input(1, 0)
```

### `cell_name`

Returns the name of the currently selected cell

Usage:

- `cell_name`

Example:

```ruby
s = source("chip.gds")
# cell_name
value = s.cell_name
```

### `cell_obj`

Returns the Cell object of the currently selected cell

Usage:

- `cell_obj`

Example:

```ruby
s = source("chip.gds")
# cell_obj
value = s.cell_obj
```

### `clip`

Specifies clipped input

Creates a source which represents a rectangular part of the original input. Three ways are provided to specify the rectangular region: a single DBox object (micron units), two DPoint objects (lower/left and upper/right coordinate in micron units) or four coordinates: left, bottom, right and top coordinate.

This method will create a new source which delivers the shapes from that region clipped to the rectangle. A method doing the same but without clipping is touching or overlapping.

Usage:

- `source.clip(box)`
- `source.clip(p1, p2)`
- `source.clip(l, b, r, t)`

Example:

```ruby
s = source("chip.gds")
s2 = s.clip(0.0, 0.0, 100.0, 100.0)
metal = s2.input(1, 0)
```

### `edge_pairs`

Gets the edge pairs from an input layer

Creates a layer with the edge_pairs from the given layer of the source. Edge pairs are not supported by layout formats so far. So except if the source is a custom-built layout object, this method has little use. It is provided for future extensions which may include edge pairs in file streams.

This method is identical to input with respect to the options supported.

Usage:

- `source.edge_pairs`
- `source.edge_pairs(layer)`
- `source.edge_pairs(layer, datatype)`
- `source.edge_pairs(layer_info)`
- `source.edge_pairs(filter, ...)`

Example:

```ruby
s = source("chip.gds")
# source.edge_pairs
value = s.edge_pairs
```

### `edges`

Gets the edge shapes (or shapes that can be converted edges) from an input layer

Creates a layer with the edges from the given layer of the source. Edge layers are formed from shapes by decomposing the shapes into edges: polygons for example are decomposed into their outline edges. Some file formats support egdes as native objects.

This method is identical to input with respect to the options supported.

Usage:

- `source.edges`
- `source.edges(layer)`
- `source.edges(layer, datatype)`
- `source.edges(layer_info)`
- `source.edges(filter, ...)`

Example:

```ruby
s = source("chip.gds")
# source.edges
value = s.edges
```

### `extent`

Returns a layer with the bounding box of the selected layout or cells

Without an argument, the extent method returns a layer with the bounding box of the top cell. With a cell filter argument, the method returns a layer with the bounding boxes of the selected cells. The cell filter is a glob pattern.

The extent function is useful to invert a layer:

Usage:

- `source.extent`
- `source.extent(cell_filter)`

Example:

```ruby
inverse_1 = extent.sized(100.0) - input(1, 0)
```

```ruby
a_cells = extent("A*")
```

### `global_transform`

Gets or sets a global transformation

This method returns a new source representing the transformed layout. It is provided in the spritit of Source#clip and similar methods.

The transformation is either given as a DTrans, DVector or DCplxTrans object or as one of the following specifications:

Usage:

- `global_transform`
- `global_transform([ transformations ])`

Example:

```ruby
source.global_transform(shift(0, 100.um), rotate(90.0))
```

### `input`

Specifies input from a source

Creates a layer with the shapes from the given layer of the source. The layer can be specified by layer and optionally datatype, by a LayerInfo object or by a sequence of filters. Filters are expressions describing ranges of layers and/or datatype numbers or layer names. Multiple filters can be given and all layers matching at least one of these filter expressions are joined to render the input layer for the DRC engine. For the syntax of the filter expressions see LayerMap#map (look for the vers…

1/0-255 : Datatypes 0 to 255 for layer 1 1/* : All datatypes for layer 1 1/0,5,10 : Datatypes 0, 5 and 10 for layer 1 1/0;2/17 : Layer 1, datatype 0 and layer 2, datatype 17 1-10 : Layers 1 to 10, datatype 0 METAL : A layer named "METAL" METAL;VIA : A layer named "METAL" and the layer named "VIA" METAL;17/0 : A layer named "METAL" and layer 17, datatype 0 '17' : A layer named "17". Note the quotes which indicate a string, not a layer number

Usage:

- `source.input`
- `source.input(layer)`
- `source.input(layer, datatype)`
- `source.input(layer_info)`
- `source.input(filter, ...)`
- `source.input(props_spec, ...)`

Example:

```ruby
input1_with_props = input(1, 0, enable_props)
```

```ruby
input1_with_props = input(1, 0, select_props(17))
```

### `labels`

Gets the labels (texts) from an input layer

Creates a true text layer with the labels from the given layer of the source.

This method is identical to input, but takes only texts from the given input layer. Starting with version 0.27, the result is no longer a polygon layer that tries to provide text support but a layer type which is provided for carrying text objects explicitly.

Usage:

- `source.labels`
- `source.labels(layer)`
- `source.labels(layer, datatype)`
- `source.labels(layer_info)`
- `source.labels(filter, ...)`

Example:

```ruby
s = source("chip.gds")
# source.labels
value = s.labels
```

### `layers`

Gets the layers the source contains

Delivers a list of LayerInfo objects representing the layers inside the source.

One application is to read all layers from a source. In the following example, the "and" operation is used to perform a clip with the given rectangle. Note that this solution is not efficient - it's provided as an example only:

Usage:

- `source.layers`

Example:

```ruby
output_cell("Clipped")

clip_box = polygon_layer
clip_box.insert(box(0.um, -4.um, 4.um, 0.um))

layers.each { |l| (input(l) & clip_box).output(l) }
```

### `layout`

Returns the Layout object associated with this source

Usage:

- `layout`

Example:

```ruby
s = source("chip.gds")
# layout
value = s.layout
```

### `make_layer`

Creates an empty polygon layer based on the hierarchy of the layout

This method delivers a new empty original layer. It is provided to keep old code working. Use "input" without arguments instead.

Usage:

- `make_layer`

Example:

```ruby
s = source("chip.gds")
# make_layer
value = s.make_layer
```

### `overlapping`

Specifies input selected from a region in overlapping mode

Like clip, this method will create a new source delivering shapes from a specified rectangular region. In contrast to clip, all shapes overlapping the region with their bounding boxes are delivered as a whole and are not clipped. Hence shapes may extent beyond the limits of the specified rectangle.

touching is a similar method which delivers shapes touching the search region with their bounding box (without the requirement to overlap)

Usage:

- `source.overlapping(...)`

Example:

```ruby
s = source("chip.gds")
s2 = s.overlapping(0.0, 0.0, 100.0, 100.0)
metal = s2.input(1, 0)
```

### `path`

Gets the path of the corresponding layout file or nil if there is no path

Usage:

- `path`

Example:

```ruby
s = source("chip.gds")
# path
value = s.path
```

### `polygons`

Gets the polygon shapes (or shapes that can be converted polygons) from an input layer

Creates a layer with the polygon shapes from the given layer of the source. With "polygon shapes" we mean all kind of shapes that can be converted to polygons. Those are boxes, paths and real polygons.

This method is identical to input with respect to the options supported.

Usage:

- `source.polygons`
- `source.polygons(layer)`
- `source.polygons(layer, datatype)`
- `source.polygons(layer_info)`
- `source.polygons(filter, ...)`

Example:

```ruby
s = source("chip.gds")
# source.polygons
value = s.polygons
```

### `select`

Adds cell name expressions to the cell filters

This method will construct a new source object with the given cell filters applied. Note that there is a global version of "select" which does not create a new source, but acts on the default source.

Cell filters will enable or disable cells plus their subtree. Cells can be switched on and off, which makes the hierarchy traversal stop or begin delivering shapes at the given cell. The arguments of the select method form a sequence of enabling or disabling instructions using cell name pattern in the glob notation ("*" as the wildcard, like shell). Disabling instructions start with a "-", enabling instructions with a "+" or no specification.

Usage:

- `new_source = source.select(filter1, filter2, ...)`

Example:

```ruby
source_with_selection = source.select("-TOP", "+B")
l1 = source_with_selection.input(1, 0)
...
```

```ruby
source_with_selection = source.select("-*", "+B")
l1 = source_with_selection.input(1, 0)
...
```

```ruby
source_with_selection = source.select("-", "+B")
l1 = source_with_selection.input(1, 0)
...
```

### `touching`

Specifies input selected from a region in touching mode

Like clip, this method will create a new source delivering shapes from a specified rectangular region. In contrast to clip, all shapes touching the region with their bounding boxes are delivered as a whole and are not clipped. Hence shapes may extent beyond the limits of the specified rectangle.

overlapping is a similar method which delivers shapes overlapping the search region with their bounding box (and not just touching)

Usage:

- `source.touching(box)`
- `source.touching(p1, p2)`
- `source.touching(l, b, r, t)`

Example:

```ruby
s = source("chip.gds")
s2 = s.touching(0.0, 0.0, 100.0, 100.0)
metal = s2.input(1, 0)
```


---

## Layer object

| Command | Description |
|---|---|
| `&` | Boolean AND operation |
| `+` | Join layers |
| `-` | Boolean NOT operation |
| `^` | Boolean XOR operation |
| `and` | Boolean AND operation |
| `andnot` | Computes Boolean AND and NOT results at the same time |
| `area` | Returns the total area of the polygons in the region |
| `bbox` | Returns the overall bounding box of the layer |
| `centers` | Returns the center parts of the edges |
| `clean` | Marks a layer as clean |
| `collect` | Transforms a layer |
| `collect_to_edge_pairs` | Transforms a layer into edge pair objects |
| `collect_to_edges` | Transforms a layer into edge objects |
| `collect_to_region` | Transforms a layer into polygon objects |
| `corners` | Selects corners of polygons |
| `count` | Returns the number of objects on the layer |
| `covering` | Selects shapes or regions of self which completely cover (enclose) one or more shapes from the other region |
| `data` | Gets the low-level data object |
| `drc` | Provides a generic DRC function for use with DRC expressions |
| `dup` | Duplicates a layer |
| `each` | Iterates over the objects from the layer |
| `edge_pairs?` | Returns true, if the layer is an edge pair collection |
| `edges` | Decomposes the layer into single edges |
| `edges?` | Returns true, if the layer is an edge layer |
| `enc` | An alias for "enclosing" |
| `enclosed` | An enclosing check (other_layer enclosing layer) |
| `enclosing` | An enclosing check (layer enclosing other_layer) |
| `end_segments` | Returns the part at the end of each edge |
| `evaluate` | Evaluates expressions on the shapes of the layer |
| `evaluated` | Evaluates expressions on the shapes of the layer and returns a new layer |
| `extended` | Returns polygons describing an area along the edges of the input |
| `extended_in` | Returns polygons describing an area along the edges of the input |
| `extended_out` | Returns polygons describing an area along the edges of the input |
| `extent_refs` | Returns partial references to the boundings boxes of the polygons |
| `extents` | Returns the bounding box of each input object |
| `fill` | Fills the region with regular pattern of shapes |
| `fill_with_left` | Fills the region with regular pattern of shapes |
| `first_edges` | Returns the first edges of an edge pair collection |
| `flatten` | Flattens the layer |
| `forget` | Cleans up memory for this layer |
| `hier_count` | Returns the hierarchical number of objects on the layer |
| `holes` | Selects all polygon holes from the input |
| `hulls` | Selects all polygon hulls from the input |
| `in` | Selects shapes or regions of self which are contained in the other layer |
| `in_and_out` | Selects shapes or regions of self which are and which are not contained in the other layer |
| `insert` | Inserts one or many objects into the layer |
| `inside` | Selects edges, edge pairs or polygons of self which are inside edges or polygons from the other layer |
| `inside_outside_part` | Returns the parts of the edges inside and outside the given region |
| `inside_part` | Returns the parts of the edges inside the given region |
| `interacting` | Selects shapes or regions of self which touch or overlap shapes from the other region |
| `intersections` | Returns the intersection points of intersecting edge segments for two edge collections |
| `is_box?` | Returns true, if the region contains a single box |
| `is_clean?` | Returns true, if the layer is clean state |
| `is_deep?` | Returns true, if the layer is a deep (hierarchical) layer |
| `is_empty?` | Returns true, if the layer is empty |
| `is_merged?` | Returns true, if the polygons of the layer are merged |
| `is_raw?` | Returns true, if the layer is raw state |
| `iso` | An alias for "isolated" |
| `isolated` | An inter-polygon isolation check |
| `join` | Joins the layer with another layer |
| `length` | Returns the total length of the edges in the edge layer |
| `map_props` | Selects properties with certain keys and allows key mapping |
| `merge` | Merges the layer (modifies the layer) |
| `merge_props` | Merges the layer and joins the properties (modifies the layer) |
| `merged` | Returns the merged layer |
| `merged_props` | Merges and joins properties of the shapes |
| `middle` | Returns the center points of the bounding boxes of the polygons |
| `move` | Moves (shifts, translates) a layer (modifies the layer) |
| `moved` | Moves (shifts, translates) a layer |
| `nets` | Pulls net shapes from selected or all nets, optionally annotating nets with properties |
| `non_rectangles` | Selects all polygons from the input which are not rectangles |
| `non_rectilinear` | Selects all non-rectilinear polygons from the input |
| `non_squares` | Selects all polygons from the input which are not squares |
| `non_strict` | Marks a layer for non-strict handling |
| `not` | Boolean NOT operation |
| `not_covering` | Selects shapes or regions of self which do not cover (enclose) one or more shapes from the other region |
| `not_in` | Selects shapes or regions of self which are not contained in the other layer |
| `not_inside` | Selects edges, edge pairs or polygons of self which are not inside edges or polygons from the other layer |
| `not_interacting` | Selects shapes or regions of self which do not touch or overlap shapes from the other region |
| `not_outside` | Selects edges, edge pairs or polygons of self which are not outside edges or polygons from the other layer |
| `not_overlapping` | Selects shapes or regions of self which do not overlap shapes from the other region |
| `notch` | An intra-polygon spacing check |
| `odd_polygons` | Checks for odd polygons (self-overlapping, non-orientable) |
| `ongrid` | Checks for on-grid vertices |
| `or` | Boolean OR operation |
| `output` | Outputs the content of the layer |
| `outside` | Selects edges, edge pairs or polygons of self which are outside edges or polygons from the other layer |
| `outside_part` | Returns the parts of the edges outside the given region |
| `overlap` | An overlap check |
| `overlapping` | Selects shapes or regions of self which overlap shapes from the other region |
| `perimeter` | Returns the total perimeter of the polygons in the region |
| `polygons` | Returns polygons from edge pairs |
| `polygons?` | Returns true, if the layer is a polygon layer |
| `pull_inside` | Selects shapes or regions of other which are inside polygons from the this region |
| `pull_interacting` | Selects shapes or edges of other which touch or overlap shapes from the this region |
| `pull_overlapping` | Selects shapes or regions of other which overlap shapes from the this region |
| `raw` | Marks a layer as raw |
| `rectangles` | Selects all rectangles from the input |
| `rectilinear` | Selects all rectilinear polygons from the input |
| `remove_props` | Returns a new layer with all properties removed |
| `rotate` | Rotates a layer (modifies the layer) |
| `rotated` | Rotates a layer |
| `rounded_corners` | Applies corner rounding to each corner of the polygon |
| `scale` | Scales a layer (modifies the layer) |
| `scaled` | Scales a layer |
| `second_edges` | Returns the second edges of an edge pair collection |
| `select` | Selects edges, edge pairs or polygons based on evaluation of a block |
| `select_covering` | Selects shapes or regions of self which completely cover (enclose) one or more shapes from the other region |
| `select_if` | Selects shapes of a layer based on the evaluation of an expression |
| `select_inside` | Selects edges, edge pairs or polygons of self which are inside edges or polygons from the other layer |
| `select_interacting` | Selects shapes or regions of self which touch or overlap shapes from the other region |
| `select_not_covering` | Selects shapes or regions of self which do not cover (enclose) one or more shapes from the other region |
| `select_not_inside` | Selects edges, edge pairs or polygons of self which are not inside edges or polygons from the other layer |
| `select_not_interacting` | Selects shapes or regions of self which do not touch or overlap shapes from the other region |
| `select_not_outside` | Selects edges, edge pairs or polygons of self which are not outside edges or polygons from the other layer |
| `select_not_overlapping` | Selects shapes or regions of self which do not overlap shapes from the other region |
| `select_outside` | Selects edges, edge pairs or polygons of self which are outside edges or polygons from the other layer |
| `select_overlapping` | Selects shapes or regions of self which overlap shapes from the other region |
| `select_props` | Enables or selects properties from a property-annotated layer |
| `selected_if` | Selects shapes based on the evaluation of an expression |
| `sep` | An alias for "separation" |
| `separation` | A two-layer spacing check |
| `size` | Polygon sizing (per-edge biasing, modifies the layer) |
| `sized` | Polygon sizing (per-edge biasing) |
| `smoothed` | Smoothes the polygons of the region |
| `snap` | Brings each vertex on the given grid (g or gx/gy for x or y direction) |
| `snapped` | Returns a snapped version of the layer |
| `space` | A space check |
| `split_covering` | Returns the results of covering and not_covering at the same time |
| `split_if` | Selects shapes based on the evaluation of an expression and returns selected and unselected shapes in different layers |
| `split_inside` | Returns the results of inside and not_inside at the same time |
| `split_interacting` | Returns the results of interacting and not_interacting at the same time |
| `split_outside` | Returns the results of outside and not_outside at the same time |
| `split_overlapping` | Returns the results of overlapping and not_overlapping at the same time |
| `squares` | Selects all squares from the input |
| `start_segments` | Returns the part at the beginning of each edge |
| `strict` | Marks a layer for strict handling |
| `strict?` | Returns true, if strict handling is enabled for this layer |
| `texts` | Selects texts from an original layer |
| `texts?` | Returns true, if the layer is a text collection |
| `texts_not` | Selects texts from an original layer not matching a specific selection |
| `transform` | Transforms a layer (modifies the layer) |
| `transformed` | Transforms a layer |
| `width` | A width check |
| `with_angle` | Selects edges by their angle |
| `with_area` | Selects polygons or edge pairs by area |
| `with_area_ratio` | Selects polygons by the ratio of the bounding box area vs. polygon area |
| `with_bbox_aspect_ratio` | Selects polygons by the aspect ratio of their bounding box |
| `with_bbox_height` | Selects polygons by the height of the bounding box |
| `with_bbox_max` | Selects polygons by the maximum dimension of the bounding box |
| `with_bbox_min` | Selects polygons by the minimum dimension of the bounding box |
| `with_bbox_width` | Selects polygons by the width of the bounding box |
| `with_density` | Returns tiles whose density is within a given range |
| `with_distance` | Selects edge pairs by the distance of the edges |
| `with_holes` | Selects all polygons with the specified number of holes |
| `with_internal_angle` | Selects edge pairs by their internal angle |
| `with_length` | Selects edges by their length |
| `with_perimeter` | Selects polygons by perimeter |
| `with_relative_height` | Selects polygons by the ratio of the height vs. width of its bounding box |
| `without_angle` | Selects edges by the their angle |
| `without_area` | Selects polygons or edge pairs by area |
| `without_area_ratio` | Selects polygons by the aspect ratio of their bounding box |
| `without_bbox_height` | Selects polygons by the aspect ratio of their bounding box |
| `without_bbox_max` | Selects polygons by the maximum dimension of the bounding box |
| `without_bbox_min` | Selects polygons by the minimum dimension of the bounding box |
| `without_bbox_width` | Selects polygons by the width of the bounding box |
| `without_density` | Returns tiles whose density is not within a given range |
| `without_distance` | Selects edge pairs by the distance of the edges |
| `without_holes` | Selects all polygons with the specified number of holes |
| `without_internal_angle` | Selects edge pairs by their internal angle |
| `without_length` | Selects edges by the their length |
| `without_perimeter` | Selects polygons by perimeter |
| `without_relative_height` | Selects polygons by the ratio of the height vs. width |
| `xor` | Boolean XOR operation |
| `|` | Boolean OR operation |

### Layer method details

### `&`

Boolean AND operation

The method computes a boolean AND between self and other.

This method is available for polygon and edge layers. An alias is "and". See there for a description of the function.

Usage:

- `self & other`

Example:

```ruby
metal1 = input(1, 0)
metal2 = input(2, 0)
out = metal1 & metal2
out.output("bool_&")
```

### `+`

Join layers

The method includes the edges or polygons from the other layer into this layer. The "+" operator is an alias for the join method.

This method is available for polygon, edge and edge pair layers. An alias is "join". See there for a description of the function.

Usage:

- `self + other`

Example:

```ruby
metal1 = input(1, 0)
metal2 = input(2, 0)
out = metal1 + metal2
out.output("bool_+")
```

### `-`

Boolean NOT operation

The method computes a boolean NOT between self and other.

This method is available for polygon and edge layers. An alias is "not". See there for a description of the function.

Usage:

- `self - other`

Example:

```ruby
metal1 = input(1, 0)
metal2 = input(2, 0)
out = metal1 - metal2
out.output("bool_-")
```

### `^`

Boolean XOR operation

The method computes a boolean XOR between self and other.

This method is available for polygon and edge layers. An alias is "xor". See there for a description of the function.

Usage:

- `self ^ other`

Example:

```ruby
metal1 = input(1, 0)
metal2 = input(2, 0)
out = metal1 ^ metal2
out.output("bool_^")
```

### `and`

Boolean AND operation

The method computes a boolean AND between self and other. It is an alias for the "&" operator which lacks the ability to specify a properties constraint.

This method is available for polygon and edge layers. If the first operand is an edge layer and the second is a polygon layer, the result will be the edges of the first operand which are inside or on the borders of the polygons of the second operand.

Usage:

- `layer.and(other [, prop_constraint ])`

Example:

```ruby
a = input(1, 0)
b = input(2, 0)
out = a.and(b)
out.output("result")
```

### `andnot`

Computes Boolean AND and NOT results at the same time

This method returns a two-element array containing one layer for the AND result and one for the NOT result.

This method is available for polygon and edge layers. For polygon layers, the other input must be a polygon layer too. For edge layers, the other input can be polygon or edge.

Usage:

- `layer.andnot(other)`

Example:

```ruby
(and_result, not_result) = l1.andnot(l2)
```

### `area`

Returns the total area of the polygons in the region

This method requires a polygon layer. It returns the total area of all polygons in square micron. Merged semantics applies, i.e. before computing the area, the polygons are merged unless raw mode is chosen (see raw). Hence, in clean mode, overlapping polygons are not counted twice.

The returned value gives the area in square micrometer units.

Usage:

- `layer.area`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.area
result = metal.area
```

### `bbox`

Returns the overall bounding box of the layer

The return value is a DBox object giving the bounding box in micrometer units.

Usage:

- `layer.bbox`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.bbox
result = metal.bbox
```

### `centers`

Returns the center parts of the edges

Similar to start_segments and end_segments, this method will return partial edges for each given edge in the input. For the description of the parameters see start_segments or end_segments.

The following images show the effect of the method:

Usage:

- `layer.centers(length)`
- `layer.centers(length, fraction)`

Example:

```ruby
layer = input(1, 0)
out = layer.centers
out.output("centers")
```

### `clean`

Marks a layer as clean

A layer marked as clean will provide "merged" semantics, i.e. overlapping or touching polygons are considered as single polygons. Inner edges are removed and collinear edges are connected. Clean state is the default.

Usage:

- `layer.clean`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.clean
result = metal.clean
```

### `collect`

Transforms a layer

This method evaluates the block for each object in the layer and returns a new layer with the objects returned from the block. It is available for edge, polygon and edge pair layers. The corresponding objects are DPolygon, DEdge or DEdgePair.

If the block evaluates to nil, no object is added to the output layer. If it returns an array, each of the objects in the array is added. The returned layer is of the original type and will only accept objects of the respective type. Hence, for polygon layers, DPolygon objects need to be returned. For edge layers those need to be DEdge and for edge pair layers, they need to be DEdgePair objects. For convenience, Polygon, Edge and EdgePair objects are accepted too and are scaled by the database u…

Usage:

- `layer.collect { |object| ... }`

Example:

```ruby
# Rotates by 45 degree
t = DCplxTrans(1.0, 45.0, false, DVector::new)
new_layer = layer.collect { |polygon| polygon.transformed(t) }
```

### `collect_to_edge_pairs`

Transforms a layer into edge pair objects

This method is similar to collect, but creates an edge pair layer. It expects the block to deliver EdgePair, DEdgePair or EdgePairs objects.

Usage:

- `layer.collect_to_edge_pairs { |object| ... }`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.collect_to_edge_pairs { |object| ... }
result = metal.collect_to_edge_pairs { |object| ... }
```

### `collect_to_edges`

Transforms a layer into edge objects

This method is similar to collect, but creates an edge layer. It expects the block to deliver objects that can be converted into edges. If polygon-like objects are returned, their contours will be turned into edge sequences.

Usage:

- `layer.collect_to_edges { |object| ... }`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.collect_to_edges { |object| ... }
result = metal.collect_to_edges { |object| ... }
```

### `collect_to_region`

Transforms a layer into polygon objects

This method is similar to collect, but creates a polygon layer. It expects the block to deliver objects that can be converted into polygons. Such objects are of class DPolygon, DBox, DPath, Polygon, Path, Box and Region.

Usage:

- `layer.collect_to_region { |object| ... }`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.collect_to_region { |object| ... }
result = metal.collect_to_region { |object| ... }
```

### `corners`

Selects corners of polygons

This method produces markers on the corners of the polygons. An angle criterion can be given which selects corners based on the angle of the connecting edges. Positive angles indicate a left turn while negative angles indicate a right turn. Since polygons are oriented clockwise, positive angles indicate concave (inner) corners while negative ones indicate convex (outer) corners The 'absolute' option allows turning this off and considering both left and right turns positive angles.

The markers generated can be point-like edges or small 2x2 DBU boxes. The latter is the default.

Usage:

- `layer.corners([ options ])`
- `layer.corners(angle [, options ])`
- `layer.corners(amin .. amax [, options ])`

Example:

```ruby
layer = input(1, 0)
out = layer.corners
out.output("corners")
```

### `count`

Returns the number of objects on the layer

The count is the number of raw objects, not merged regions or edges. This is the flat count - the number of polygons, edges or edge pairs seen from the top cell. "count" can be computationally expensive for original layers with clip regions or cell tree filters.

Usage:

- `layer.count`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.count
result = metal.count
```

### `covering`

Selects shapes or regions of self which completely cover (enclose) one or more shapes from the other region

This method selects all shapes or regions from self which completly cover shapes from the other region. Unless self is in raw mode (see raw), coherent regions are selected from self, otherwise individual shapes are selected. It returns a new layer containing the selected shapes. A version which modifies self is select_covering.

This method is available for polygons only.

Usage:

- `layer.covering(other)`
- `layer.covering(other, min_count)`
- `layer.covering(other, min_count, max_count)`
- `layer.covering(other, min_count .. max_count)`

Example:

```ruby
a = input(1, 0)
b = input(2, 0)
out = a.covering(b)
out.output("result")
```

### `data`

Gets the low-level data object

This method returns a Region, Edges or EdgePairs object representing the underlying RBA object for the data. Access to these objects is provided to support low-level iteration and manipulation of the layer's data.

Usage:

- `layer.data`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.data
result = metal.data
```

### `drc`

Provides a generic DRC function for use with DRC expressions

This method implements the universal DRC which offers enhanced abilities, improved performance in some applications and better readability.

The key concept for this method are DRC expressions. DRC expressions are formed by using predefined keywords like "width", operators like "&" and methods to build an abstract definition of the operations to perform within the DRC.

Usage:

- `layer.drc(expression [, prop_constraint ])`

Example:

```ruby
out = in.drc(width < 0.5.um)
```

```ruby
out = in.drc(width  0.5.um)
out = in.drc(width == 0.5.um)
out = in.drc(width != 0.5.um)
out = in.drc(0.2.um < width < 0.5.um)
```

```ruby
l1 = input(1, 0)
l2 = input(2, 0)
out = l1.drc(separation(l2) < 0.5.um)
```

### `dup`

Duplicates a layer

Duplicates the layer. This basically will create a copy and modifications of the original layer will not affect the duplicate. Please note that just assigning the layer to another variable will not create a copy but rather a pointer to the original layer. Hence modifications will then be visible on the original and derived layer. Using the dup method will avoid that.

However, dup will double the memory required to hold the data and performing the deep copy may be expensive in terms of CPU time.

Usage:

- `layer.dup`

Example:

```ruby
layer = input(1, 0)
out = layer.dup()
out.output("dup")
```

### `each`

Iterates over the objects from the layer

This method evaluates the block on each object of the layer. Depending on the layer type, these objects are of DPolygon, DEdge or DEdgePair type.

Because this method executes inside the interpreter, it's inherently slow. Tiling does not apply to this method.

Usage:

- `layer.each { |object| ... }`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.each { |object| ... }
result = metal.each { |object| ... }
```

### `edge_pairs?`

Returns true, if the layer is an edge pair collection

Usage:

- `layer.edge_pairs?`

Example:

```ruby
layer = input(1, 0)
if layer.edge_pairs?
  puts "layer.edge_pairs? is true"
end
```

### `edges`

Decomposes the layer into single edges

Edge pair collections are decomposed into the individual edges that make up the edge pairs. Polygon layers are decomposed into the edges making up the polygons. This method returns an edge layer but will not modify the layer it is called on.

Merged semantics applies, i.e. the result reflects merged polygons rather than individual ones unless raw mode is chosen.

Usage:

- `layer.edges`
- `layer.edges(mode)`

Example:

```ruby
out = in.edges(convex)
```

```ruby
out = in.edges(not_convex)
```

### `edges?`

Returns true, if the layer is an edge layer

Usage:

- `layer.edges?`

Example:

```ruby
layer = input(1, 0)
if layer.edges?
  puts "layer.edges? is true"
end
```

### `enc`

An alias for "enclosing"

Usage:

- `layer.enc(value [, options])`

Example:

```ruby
metal = input(1, 0)
markers = metal.enc(0.2.um)
markers.output("enc_violations")
```

### `enclosed`

An enclosing check (other_layer enclosing layer)

Note: "enclosed" is available as operators for the "universal DRC" function drc within the DRC framework. These variants have more options and are more intuitive to use. See enclosed for more details.

This method checks whether layer is enclosed by (is inside of) other_layer by not less than the given distance value. Locations, where the distance is less will be reported in form of edge pair error markers. Locations, where both edges coincide will be reported as errors as well. Formally such locations form an enclosure with a distance of 0. Locations, where other_layer is inside layer will not be reported as errors. Such regions can be detected by inside or a boolean "not" operation.

Usage:

- `layer.enclosed(other_layer, value [, options])`

Example:

```ruby
metal = input(1, 0)
markers = metal.enclosed(0.2.um)
markers.output("enclosed_violations")
```

### `enclosing`

An enclosing check (layer enclosing other_layer)

Note: "enclosing" and "enc" are available as operators for the "universal DRC" function drc within the DRC framework. These variants have more options and are more intuitive to use. See enclosing for more details.

This method checks whether layer encloses (is bigger than) other_layer by not less than the given distance value. Locations, where the distance is less will be reported in form of edge pair error markers. Locations, where both edges coincide will be reported as errors as well. Formally such locations form an enclosure with a distance of 0. Locations, where other_layer extends outside layer will not be reported as errors. Such regions can be detected by not_inside or a boolean "not" operation.

Usage:

- `layer.enclosing(other_layer, value [, options])`
- `layer.enc(other_layer, value [, options])`

Example:

```ruby
metal = input(1, 0)
markers = metal.enclosing(0.2.um)
markers.output("enclosing_violations")
```

### `end_segments`

Returns the part at the end of each edge

This method will return a partial edge for each edge in the input, located and the end of the original edge. The new edges will share the end point with the original edges, but not necessarily their start point. This method applies to edge layers only. The direction of edges is defined by the clockwise orientation of a polygon: the end point of the edges will be the terminal point of each edge when walking a polygon in clockwise direction. Or in other words: when looking from start to the end po…

The length of the new edge can be given in two ways: as a fixed length, or a fraction, or both. In the latter case, the length of the resulting edge will be either the fraction or the fixed length, whichever is larger. To specify a length only, omit the fraction argument or leave it at 0. To specify a fraction only, pass 0 to the length argument and specify the fraction in the second parameter. A fraction of 0.5 will result in edges which cover the end half of the edge.

Usage:

- `layer.end_segments(length)`
- `layer.end_segments(length, fraction)`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.end_segments(length)
result = metal.end_segments(length)
```

### `evaluate`

Evaluates expressions on the shapes of the layer

Evaluates the given expression on the shapes of the layer. The expression needs to be written in the KLayout expressions notation.

The expressions can place properties on the shapes using the "put" function. As input, the expressions will receive the (merged) shapes in micrometer units (e.g. DPolygon type) by calling the "shape" function.

Usage:

- `layer.evaluate(expression [, variables [, keep_properties ]])`

Example:

```ruby
layer.evaluate(scales("put('area', shape.area)"))
```

```ruby
# isotropic and scale invariant
layer.evaluate("put('holes', shape.holes)")

# anisotropic, but scale invariant
layer.evaluate(aniso("put('aspect_ratio', shape.bbox.height/shape.bbox.width)"))

# isotropic, but not scale invariant
layer.evaluate(scales("put('area', shape.area)"))

# anisotropic and not scale invariant
layer.evaluate(aniso_and_scales("put('width', shape.bbox.width)"))
```

### `evaluated`

Evaluates expressions on the shapes of the layer and returns a new layer

This method is the out-of-place version of evaluate. It takes the same arguments.

Usage:

- `layer.evaluated(expression [, variables [, keep_properties]])`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.evaluated(expression [, variables [, keep_properties]])
result = metal.evaluated(expression ])
```

### `extended`

Returns polygons describing an area along the edges of the input

This method is available for edge layers only. It will create a polygon for each edge tracing the edge with certain offsets to the edge. "o" is the offset applied to the outer side of the edge, "i" is the offset applied to the inner side of the edge. "b" is the offset applied at the beginning and "e" is the offset applied at the end.

When looking from start to end point, the "inside" side is to the right, while the "outside" side is to the left.

Usage:

- `layer.extended([:begin => b,] [:end => e,] [:out => o,] [:in => i], [:joined => true])`
- `layer.extended(b, e, o, i)`
- `layer.extended(b, e, o, i, joined)`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.extended([:begin => b,] [:end => e,] [:out => o,] [:in => i], [:joined => true])
result = metal.extended( )
```

### `extended_in`

Returns polygons describing an area along the edges of the input

This method applies to edge layers only. Polygons are generated for each edge describing the edge drawn with a certain width extending into the "inside" (the right side when looking from start to end). This method is basically equivalent to the extended method: "extended(0, 0, 0, dist)". A version extending to the outside is extended_out.

Usage:

- `layer.extended_in(d)`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.extended_in(d)
result = metal.extended_in(d)
```

### `extended_out`

Returns polygons describing an area along the edges of the input

This method applies to edge layers only. Polygons are generated for each edge describing the edge drawn with a certain width extending into the "outside" (the left side when looking from start to end). This method is basically equivalent to the extended method: "extended(0, 0, dist, 0)". A version extending to the inside is extended_in.

Usage:

- `layer.extended_out(d)`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.extended_out(d)
result = metal.extended_out(d)
```

### `extent_refs`

Returns partial references to the boundings boxes of the polygons

This method produces parts of the bounding box of the polygons. It can select either edges, certain points or partial boxes. It can be used the following ways:

With a formal specification : This is an identifier like ":center" or ":left" to indicate which part will be produced. With two floating-point arguments : These arguments specify a point relative to the bounding box. The first argument is a relative x coordinate where 0.0 means "left side of the bounding box" and 1.0 is the right side. The second argument is a relative y coordinate where 0.0 means "bottom" and 1.0 means "top". The results will be small (2x2 DBU) boxes or point-like edges for edg…

Usage:

- `layer.extent_refs(fx, fy [, options ])`
- `layer.extent_refs(fx1, fy1, fx2, fx2 [, options ])`
- `layer.extent_refs(ref_spec [, options ])`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.extent_refs(fx, fy [, options ])
result = metal.extent_refs(fx, fy )
```

### `extents`

Returns the bounding box of each input object

Applies to edge layers, polygon layers on edge pair collections. Returns a polygon layer consisting of boxes for each input object. The boxes enclose the original object.

Merged semantics applies, so the box encloses the merged polygons or edges unless raw mode is chosen (see raw).

Usage:

- `layer.extents([ enlargement ])`

Example:

```ruby
layer = input(1, 0)
out = layer.extents
out.output("extents")
```

### `fill`

Fills the region with regular pattern of shapes

This method will attempt to fill the polygons of the layer with a regular pattern of shapes.

The fill function currently is not available in deep mode.

Usage:

- `layer.fill([ options ])`

Example:

```ruby
p = fill_pattern("FILL_CELL")
p.shape(1, 0, box(0.0, 0.0, 1.0, 1.0))
```

```ruby
p = fill_pattern("FILL_CELL").shape(1, 0, box(0.0, 0.0, 1.0, 1.0))
```

```ruby
p = fill_pattern("FILL_CELL")
p.shape(1, 0, box(0.0, 0.0, 1.0, 1.0))
p.origin(-0.5, -0.5)
```

### `fill_with_left`

Fills the region with regular pattern of shapes

This method has the same call syntax and functionality than fill. Other than this method it will return the area not covered by fill cells as a DRC layer.

Usage:

- `layer.fill_with_left([ options ])`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.fill_with_left([ options ])
result = metal.fill_with_left()
```

### `first_edges`

Returns the first edges of an edge pair collection

Applies to edge pair collections only. Returns the first edges of the edge pairs in the collection.

Some checks deliver symmetric edge pairs (e.g. space, width, etc.) for which the edges are commutable. "first_edges" will deliver both edges for such edge pairs.

Usage:

- `layer.first_edges`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.first_edges
result = metal.first_edges
```

### `flatten`

Flattens the layer

If the layer already is a flat one, this method does nothing. If the layer is a hierarchical layer (an original layer or a derived layer in deep mode), this method will convert it to a flat collection of texts, polygons, edges or edge pairs.

Usage:

- `layer.flatten`

Example:

```ruby
layer = input(1, 0)
out = layer.flatten()
out.output("flatten")
```

### `forget`

Cleans up memory for this layer

KLayout's DRC engine is imperative. This means, every command is executed immediately rather than being compiled and executed later. The advantage of this approach is that it allows decisions to be taken depending on the content of a layer and to code functions that operate directly on the layer's content.

However, one drawback is that the engine cannot decide when a layer is no longer required - it may still be used later in the script. So a layer's data is not cleaned up automatically.

Usage:

- `forget`

Example:

```ruby
l = ... # compute some layer
...
# once you're done with l:
l.forget
l = nil
```

### `hier_count`

Returns the hierarchical number of objects on the layer

The hier_count is the number of raw objects, not merged regions or edges, with each cell counting once. A high count to hier_count (flat to hierarchical) ratio is an indication of a good hierarchical compression. "hier_count" applies only to original layers without clip regions or cell filters and to layers in deep mode. Otherwise, hier_count gives the same value than count.

Usage:

- `layer.hier_count`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.hier_count
result = metal.hier_count
```

### `holes`

Selects all polygon holes from the input

This method is available for polygon layers. It will create polygons from all holes inside polygons of the input. Although it is possible, running this method on raw polygon layers will usually not render the expected result, since raw layers do not contain polygons with holes in most cases.

The following image shows the effects of the holes method:

Usage:

- `layer.holes`

Example:

```ruby
layer = input(1, 0)
out = layer.holes
out.output("holes")
```

### `hulls`

Selects all polygon hulls from the input

This method is available for polygon layers. It will remove all holes from the input and render the hull polygons only. Although it is possible, running this method on raw polygon layers will usually not render the expected result, since raw layers do not contain polygons with holes in most cases.

The following image shows the effects of the hulls method:

Usage:

- `layer.hulls`

Example:

```ruby
layer = input(1, 0)
out = layer.hulls
out.output("hulls")
```

### `in`

Selects shapes or regions of self which are contained in the other layer

This method selects all shapes or regions from self which are contained the other region exactly. It will use individual shapes from self or other if the respective region is in raw mode. If not, it will use coherent regions or combined edges from self or other.

It will return a new layer containing the selected shapes. A method which selects all shapes not contained in the other layer is not_in.

Usage:

- `layer.in(other)`

Example:

```ruby
a = input(1, 0)
b = input(2, 0)
out = a.in(b)
out.output("result")
```

### `in_and_out`

Selects shapes or regions of self which are and which are not contained in the other layer

This method is equivalent to calling in and not_in, but more efficient as it delivers both results in a single call.

Usage:

- `(in, not_in) = layer.in_and_out(other)`

Example:

```ruby
a = input(1, 0)
b = input(2, 0)
out = a.in_and_out(b)
out.output("result")
```

### `insert`

Inserts one or many objects into the layer

Objects that can be inserted are Edge objects (into edge layers) or DPolygon, DSimplePolygon, Path, DBox (into polygon layers). Convenience methods exist to create such objects (edge, polygon, box and path). However, RBA constructors can used as well.

The insert method is useful in combination with the polygon_layer or edge_layer functions:

Usage:

- `insert(object, object ...)`

Example:

```ruby
el = edge_layer
el.insert(edge(0.0, 0.0, 100.0, 0.0)

pl = polygon_layer
pl.insert(box(0.0, 0.0, 100.0, 200.0)
```

### `inside`

Selects edges, edge pairs or polygons of self which are inside edges or polygons from the other layer

If layer is a polygon layer, the other layer needs to be a polygon layer too. In this case, this method selects all polygons which are completely inside polygons from the other layer.

If layer is an edge pair layer, the other layer needs to be a polygon layer. In this case, this method selects all edge pairs which are completely inside polygons from the other layer.

Usage:

- `layer.inside(other)`

Example:

```ruby
a = input(1, 0)
b = input(2, 0)
out = a.inside(b)
out.output("result")
```

### `inside_outside_part`

Returns the parts of the edges inside and outside the given region

The method is available for edge layers. The argument must be a polygon layer.

This method returns two layers: the first with the edge parts inside the given region and the second with the parts outside the given region. It is equivalent to calling inside_part and outside_part, but more efficient if both parts need to be computed.

Usage:

- `(inside_part, outside_part) = layer.inside_outside_part(region)`

Example:

```ruby
layer = input(1, 0)
result = layer.inside_outside_part
```

### `inside_part`

Returns the parts of the edges inside the given region

This method returns the parts of the edges which are inside the given region. This is similar to the "&" operator, but this method does not return edges that are exactly on the boundaries of the polygons of the region.

This method is available for edge layers. The argument must be a polygon layer.

Usage:

- `layer.inside_part(region)`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.inside_part(region)
result = metal.inside_part(region)
```

### `interacting`

Selects shapes or regions of self which touch or overlap shapes from the other region

This method selects all shapes or regions from self which touch or overlap shapes from the other region. Unless self is in raw mode (see raw), coherent regions are selected from self, otherwise individual shapes are selected. It returns a new layer containing the selected shapes. A version which modifies self is select_interacting.

This method is available for polygon, text, edge and edge pair layers. Edges and edge pairs can be selected with respect to other edges or polygons. Texts can be selected with respect to polygons. Polygons can be selected with respect to edges, texts and other polygons.

Usage:

- `layer.interacting(other)`
- `layer.interacting(other, min_count)`
- `layer.interacting(other, min_count, max_count)`
- `layer.interacting(other, min_count .. max_count)`

Example:

```ruby
a = input(1, 0)
b = input(2, 0)
out = a.interacting(b)
out.output("result")
```

### `intersections`

Returns the intersection points of intersecting edge segments for two edge collections

This operation is similar to the "&" operator, but it does also report intersection points between non-colinear, but intersecting edges. Such points are reported as point-like, degenerated edge objects.

This method is available for edge layers. The argument must be an edge layer.

Usage:

- `layer.intersections(edges)`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.intersections(edges)
result = metal.intersections(edges)
```

### `is_box?`

Returns true, if the region contains a single box

The method returns true, if the region consists of a single box only. Merged semantics does not apply - if the region forms a box which is composed of multiple pieces, this method will not return true.

Usage:

- `layer.is_box?`

Example:

```ruby
layer = input(1, 0)
if layer.is_box?
  puts "layer.is_box? is true"
end
```

### `is_clean?`

Returns true, if the layer is clean state

Usage:

- `layer.is_clean?`

Example:

```ruby
layer = input(1, 0)
if layer.is_clean?
  puts "layer.is_clean? is true"
end
```

### `is_deep?`

Returns true, if the layer is a deep (hierarchical) layer

Usage:

- `layer.is_deep?`

Example:

```ruby
layer = input(1, 0)
if layer.is_deep?
  puts "layer.is_deep? is true"
end
```

### `is_empty?`

Returns true, if the layer is empty

Usage:

- `layer.is_empty?`

Example:

```ruby
layer = input(1, 0)
if layer.is_empty?
  puts "layer.is_empty? is true"
end
```

### `is_merged?`

Returns true, if the polygons of the layer are merged

This method will return true, if the polygons of this layer are merged, i.e. they don't overlap and form single continuous polygons. In clean mode, this is ensured implicitly. In raw mode (see raw), merging can be achieved by using the merge method. is_merged? tells, whether calling merge is necessary.

Usage:

- `layer.is_merged?`

Example:

```ruby
layer = input(1, 0)
if layer.is_merged?
  puts "layer.is_merged? is true"
end
```

### `is_raw?`

Returns true, if the layer is raw state

Usage:

- `layer.is_raw?`

Example:

```ruby
layer = input(1, 0)
if layer.is_raw?
  puts "layer.is_raw? is true"
end
```

### `iso`

An alias for "isolated"

Usage:

- `layer.iso(value [, options])`

Example:

```ruby
metal = input(1, 0)
markers = metal.iso(0.2.um)
markers.output("iso_violations")
```

### `isolated`

An inter-polygon isolation check

Note: "isolated" and "iso" are available as operators for the "universal DRC" function Layer#drc within the DRC framework. These variants have more options and are more intuitive to use. See isolated for more details.

See space for a description of this method. "isolated" is the space check variant which checks different polygons only. In contrast to space, the "isolated" method is available for polygon layers only, since only on such layers different polygons can be identified.

Usage:

- `layer.isolated(value [, options])`
- `layer.iso(value [, options])`

Example:

```ruby
metal = input(1, 0)
markers = metal.isolated(0.2.um)
markers.output("isolated_violations")
```

### `join`

Joins the layer with another layer

The method includes the edges or polygons from the other layer into this layer. It is an alias for the "+" operator.

This method is available for polygon, edge and edge pair layers.

Usage:

- `layer.join(other)`

Example:

```ruby
a = input(1, 0)
b = input(2, 0)
out = a.join(b)
out.output("result")
```

### `length`

Returns the total length of the edges in the edge layer

This method requires an edge layer. It returns the total length of all edges in micron. Merged semantics applies, i.e. before computing the length, the edges are merged unless raw mode is chosen (see raw). Hence in clean mode (see clean), overlapping edges are not counted twice.

Usage:

- `layer.length`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.length
result = metal.length
```

### `map_props`

Selects properties with certain keys and allows key mapping

Similar to select_props, this method will map or filter properties and and take the values from certain keys. In addition, this method allows mapping keys to new keys. Specify a hash argument with old to new keys.

Property values with keys not listed in the hash are removed.

Usage:

- `layer.map_props({ key => key_new, .. })`

Example:

```ruby
layer1 = input(1, 0, enable_properties)
layer1_mapped = layer1.map_props({ 2 => 1 })
```

### `merge`

Merges the layer (modifies the layer)

Like merged, but modifies the input and returns a reference to the new layer.

Usage:

- `layer.merge([overlap_count])`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.merge([overlap_count])
result = metal.merge()
```

### `merge_props`

Merges the layer and joins the properties (modifies the layer)

Like merged_props, but modifies the input and returns a reference to the new layer.

Usage:

- `layer.merge_props([overlap_count])`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.merge_props([overlap_count])
result = metal.merge_props()
```

### `merged`

Returns the merged layer

Returns the merged input. Usually, merging is done implicitly using the clean state (which is default). However, in raw state, merging can be enforced by using this method. In addition, this method allows specification of a minimum overlap count, i.e. only where at least the given number of polygons overlap, output is produced. See sized for an application of that.

This method works both on edge or polygon layers. Edge merging forms single, continuous edges from coincident and connected individual edges. The overlap count is only available on polygon layers.

Usage:

- `layer.merged([overlap_count])`

Example:

```ruby
layer = input(1, 0)
out = layer.merged()
out.output("merged")
```

### `merged_props`

Merges and joins properties of the shapes

Returns the merged input. Unlike the plain merged method, this version will join properties on merged shapes. Properties with the same name will be merged by computing the maximum value of the parts.

For example: Properties { "A" => 17, "C" => 2.5 } merged with { "A" => 1, "B" => "a text" } will give { "A" => 17, "B" => "a text", "C" => 2.5 } .

Usage:

- `layer.merged_props([overlap_count])`

Example:

```ruby
{ "A" => 17, "C" => 2.5 }
```

```ruby
{ "A" => 1, "B" => "a text" }
```

```ruby
{ "A" => 17, "B" => "a text", "C" => 2.5 }
```

### `middle`

Returns the center points of the bounding boxes of the polygons

This method produces markers on the centers of the polygon's bounding box centers. These markers can be point-like edges or small 2x2 DBU boxes. The latter is the default. A more generic function is extent_refs. "middle" is basically a synonym for "extent_refs(:center)".

as_boxes : with this option, small boxes will be produced as markers as_dots : with this option, point-like edges will be produced instead of small boxes

Usage:

- `layer.middle([ options ])`

Example:

```ruby
layer = input(1, 0)
out = layer.middle
out.output("middle")
```

### `move`

Moves (shifts, translates) a layer (modifies the layer)

Moved the input by the given distance. The layer that this method is called upon is modified and the modified version is returned for further processing.

Shift distances can be given as floating-point values (in micron) or integer values (in database units). To explicitly specify the unit, use the unit denominators.

Usage:

- `layer.move(dx, dy)`

Example:

```ruby
layer = input(1, 0)
out = layer.move(1.0, 0.0)
out.output("transformed")
```

### `moved`

Moves (shifts, translates) a layer

Moves the input layer by the given distance (x, y) and returns the moved layer. The layer that this method is called upon is not modified.

Shift distances can be given as floating-point values (in micron) or integer values (in database units). To explicitly specify the unit, use the unit denominators.

Usage:

- `layer.moved(dx, dy)`

Example:

```ruby
layer = input(1, 0)
out = layer.moved(1.0, 0.0)
out.output("transformed")
```

### `nets`

Pulls net shapes from selected or all nets, optionally annotating nets with properties

This method needs a layer that has been used in a connect statement. It will take the shapes corresponding to this layer for all or selected nets and attach the net identity in form of a user property.

This way, the resulting shapes can be used in property-constrained boolean operations or DRC checks to implement operations in connected or non-connected mode.

Usage:

- `layer.nets`
- `layer.nets(net_filter)`
- `layer.nets(net_object)`
- `layer.nets(circuit_filter, net_filter)`
- `layer.nets(netter, ...)`
- `layer.nets(prop(key), ...)`
- `layer.nets(prop(key), ...)`

Example:

```ruby
connect(metal1, via1)
connect(via1, metal2)

metal1_all_nets = metal1.nets
metal1_vdd      = metal1.nets("VDD")
metal1_vdd      = metal1.nets("TOPLEVEL", "VDD")
```

```ruby
metal1_vdd = metal1.nets("VDD", prop(1))
# disables properties:
metal1_vdd = metal1.nets("VDD", prop(nil))
```

### `non_rectangles`

Selects all polygons from the input which are not rectangles

This method is available for polygon layers. By default "merged" semantics applies, i.e. all polygons are merged before non-rectangles are selected (see clean and raw).

Usage:

- `layer.non_rectangles`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.non_rectangles
result = metal.non_rectangles
```

### `non_rectilinear`

Selects all non-rectilinear polygons from the input

This method is available for polygon layers. By default "merged" semantics applies, i.e. all polygons are merged before non-rectilinear polygons are selected (see clean and raw).

Usage:

- `layer.non_rectilinear`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.non_rectilinear
result = metal.non_rectilinear
```

### `non_squares`

Selects all polygons from the input which are not squares

This method is available for polygon layers. By default "merged" semantics applies, i.e. all polygons are merged before non-squares are selected (see clean and raw).

Usage:

- `layer.non_rectangles`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.non_rectangles
result = metal.non_rectangles
```

### `non_strict`

Marks a layer for non-strict handling

This feature has been introduced in version 0.23.2.

Usage:

- `layer.non_strict`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.non_strict
result = metal.non_strict
```

### `not`

Boolean NOT operation

The method computes a boolean NOT between self and other. It is an alias for the "-" operator.

This method is available for polygon and edge layers. If the first operand is an edge layer and the second is an edge layer, the result will be the edges of the first operand which are outside the polygons of the second operand.

Usage:

- `layer.not(other [, prop_constraint ])`

Example:

```ruby
a = input(1, 0)
b = input(2, 0)
out = a.not(b)
out.output("result")
```

### `not_covering`

Selects shapes or regions of self which do not cover (enclose) one or more shapes from the other region

This method selects all shapes or regions from self which do not cover shapes from the other region. Unless self is in raw mode (see raw), coherent regions are selected from self, otherwise individual shapes are selected. This method returns the inverse of covering and provides the same options.

The following image shows the effect of the "not_covering" method:

Usage:

- `layer.not_covering(other)`
- `layer.not_covering(other, min_count)`
- `layer.not_covering(other, min_count, max_count)`
- `layer.not_covering(other, min_count .. max_count)`

Example:

```ruby
a = input(1, 0)
b = input(2, 0)
out = a.not_covering(b)
out.output("result")
```

### `not_in`

Selects shapes or regions of self which are not contained in the other layer

This method selects all shapes or regions from self which are not contained the other region exactly. It will use individual shapes from self or other if the respective region is in raw mode. If not, it will use coherent regions or combined edges from self or other.

It will return a new layer containing the selected shapes. A method which selects all shapes contained in the other layer is in.

Usage:

- `layer.not_in(other)`

Example:

```ruby
a = input(1, 0)
b = input(2, 0)
out = a.not_in(b)
out.output("result")
```

### `not_inside`

Selects edges, edge pairs or polygons of self which are not inside edges or polygons from the other layer

This method computes the inverse of inside - i.e. edge, edge pairs or polygons from the layer not being inside polygons or edges from the other layer.

This method returns a new layer containing the selected shapes. A version which modifies self is select_not_inside. split_inside is a function computing both results of inside and not_inside in a single call. outside is a similar function selecting edges or polygons outside other edges or polygons. Note that "outside" is not the same than "not inside".

Usage:

- `layer.not_inside(other)`

Example:

```ruby
a = input(1, 0)
b = input(2, 0)
out = a.not_inside(b)
out.output("result")
```

### `not_interacting`

Selects shapes or regions of self which do not touch or overlap shapes from the other region

This method selects all shapes or regions from self which do not touch or overlap shapes from the other region. Unless self is in raw mode (see raw), coherent regions are selected from self, otherwise individual shapes are selected. It returns a new layer containing the selected shapes. A version which modifies self is select_not_interacting.

This method is available for polygon, text, edge and edge pair layers. Edges and edge pairs can be selected with respect to other edges or polygons. Texts can be selected with respect to polygons. Polygons can be selected with respect to edges, texts and other polygons.

Usage:

- `layer.not_interacting(other)`
- `layer.not_interacting(other, min_count)`
- `layer.not_interacting(other, min_count, max_count)`
- `layer.not_interacting(other, min_count .. max_count)`

Example:

```ruby
a = input(1, 0)
b = input(2, 0)
out = a.not_interacting(b)
out.output("result")
```

### `not_outside`

Selects edges, edge pairs or polygons of self which are not outside edges or polygons from the other layer

This method computes the inverse of outside - i.e. edges, edge pairs or polygons from the layer not being outside polygons or edges from the other layer.

This method returns a new layer containing the selected shapes. A version which modifies self is select_not_outside. split_outside is a function computing both results of outside and not_outside in a single call. outside is a similar function selecting edges or polygons outside other edges or polygons. Note that "outside" is not the same than "not outside".

Usage:

- `layer.not_outside(other)`

Example:

```ruby
a = input(1, 0)
b = input(2, 0)
out = a.not_outside(b)
out.output("result")
```

### `not_overlapping`

Selects shapes or regions of self which do not overlap shapes from the other region

This method selects all shapes or regions from self which do not overlap shapes from the other region. Unless self is in raw mode (see raw), coherent regions are selected from self, otherwise individual shapes are selected. This method will return the inverse of overlapping and provides the same options.

The "not_overlapping" method is similar to the outside method. However, "outside" does not provide the option to specify counts.

Usage:

- `layer.not_overlapping(other)`
- `layer.not_overlapping(other, min_count)`
- `layer.not_overlapping(other, min_count, max_count)`
- `layer.not_overlapping(other, min_count .. max_count)`

Example:

```ruby
a = input(1, 0)
b = input(2, 0)
out = a.not_overlapping(b)
out.output("result")
```

### `notch`

An intra-polygon spacing check

Note: "notch" is available as an operator for the "universal DRC" function Layer#drc within the DRC framework. This variant has more options and is more intuitive to use. See notch for more details.

See space for a description of this method. "notch" is the space check variant which finds space violations within a single polygon, but not against other polygons. In contrast to space, the "notch" method is available for polygon layers only, since only on such layers different polygons can be identified. Also, opposite and rectangle error filtering is not available for this method.

Usage:

- `layer.notch(value [, options])`

Example:

```ruby
metal = input(1, 0)
markers = metal.notch(0.2.um)
markers.output("notch_violations")
```

### `odd_polygons`

Checks for odd polygons (self-overlapping, non-orientable)

Returns the parts of the polygons which are not orientable (i.e. "8" configuration) or self-overlapping. Merged semantics does not apply for this method. Always the raw polygons are taken (see raw).

The odd_polygons check is not available in deep mode currently. See deep_reject_odd_polygons for an alternative.

Usage:

- `layer.odd_polygons`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.odd_polygons
result = metal.odd_polygons
```

### `ongrid`

Checks for on-grid vertices

Returns a single-vertex marker for each vertex whose x coordinate is not a multiple of g or gx or whose y coordinate is not a multiple of g or gy. The single-vertex markers are edge pair objects which describe a single point. When setting the grid to 0, no grid check is performed in that specific direction.

This method requires a polygon layer. Merged semantics applies (see raw and clean).

Usage:

- `layer.ongrid(g)`
- `layer.ongrid(gx, gy)`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.ongrid(g)
result = metal.ongrid(g)
```

### `or`

Boolean OR operation

The method computes a boolean OR between self and other. It is an alias for the "|" operator.

This method is available for polygon and edge layers.

Usage:

- `layer.or(other)`

Example:

```ruby
a = input(1, 0)
b = input(2, 0)
out = a.or(b)
out.output("result")
```

### `output`

Outputs the content of the layer

This method will copy the content of the layer to the specified output.

If a report database is selected for the output, the specification has to include a category name and optionally a category description. The category name can be an array of strings - in that case, a hierarchy of categories is created with the first array item being the top level category name. Shapes are added to an existing category, if a category with the given name already exists.

Usage:

- `layer.output(specs)`

Example:

```ruby
check1 = ...
check2 = ...
check3 = ...

second_report = new_report("Only for check2", "check2.lyrdb")

check1.output("Check 1")
check2.output("Check 2", second_report)
check3.output("Check 3")
```

### `outside`

Selects edges, edge pairs or polygons of self which are outside edges or polygons from the other layer

If layer is a polygon layer, the other layer needs to be a polygon layer too. In this case, this method selects all polygons which are entirely outside polygons from the other layer.

If layer is an edge pair layer, the other layer needs to be a polygon layer. In this case, this method selects all edge pairs which are entirely outside polygons from the other layer.

Usage:

- `layer.outside(other)`

Example:

```ruby
a = input(1, 0)
b = input(2, 0)
out = a.outside(b)
out.output("result")
```

### `outside_part`

Returns the parts of the edges outside the given region

This method returns the parts of the edges which are outside the given region. This is similar to the "&" operator, but this method does not remove edges that are exactly on the boundaries of the polygons of the region.

This method is available for edge layers. The argument must be a polygon layer.

Usage:

- `layer.outside_part(region)`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.outside_part(region)
result = metal.outside_part(region)
```

### `overlap`

An overlap check

Note: "overlap" is available as an operator for the "universal DRC" function drc within the DRC framework. This variant has more options and is more intuitive to use. See overlap for more details.

This method checks whether layer and other_layer overlap by at least the given length. Locations, where this is not the case will be reported in form of edge pair error markers. Locations, where both layers touch will be reported as errors as well. Formally such locations form an overlap with a value of 0. Locations, where both regions do not overlap or touch will not be reported. Such regions can be detected with outside or by a boolean "not".

Usage:

- `layer.overlap(other_layer, value [, options])`

Example:

```ruby
metal = input(1, 0)
markers = metal.overlap(0.2.um)
markers.output("overlap_violations")
```

### `overlapping`

Selects shapes or regions of self which overlap shapes from the other region

This method selects all shapes or regions from self which overlap shapes from the other region. Unless self is in raw mode (see raw), coherent regions are selected from self, otherwise individual shapes are selected. It returns a new layer containing the selected shapes. A version which modifies self is select_overlapping.

This method is available for polygons only.

Usage:

- `layer.overlapping(other)`
- `layer.overlapping(other, min_count)`
- `layer.overlapping(other, min_count, max_count)`
- `layer.overlapping(other, min_count .. max_count)`

Example:

```ruby
a = input(1, 0)
b = input(2, 0)
out = a.overlapping(b)
out.output("result")
```

### `perimeter`

Returns the total perimeter of the polygons in the region

This method requires a polygon layer. It returns the total perimeter of all polygons in micron. Merged semantics applies, i.e. before computing the perimeter, the polygons are merged unless raw mode is chosen (see raw).

The returned value gives the perimeter in micrometer units.

Usage:

- `layer.perimeter`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.perimeter
result = metal.perimeter
```

### `polygons`

Returns polygons from edge pairs

This method applies to edge pair collections. The edge pairs will be converted into polygons connecting the edges the edge pairs are made of. In order to properly handle special edge pairs (coincident edges, point-like edges etc.) an enlargement parameter can be specified which will make the resulting polygon somewhat larger than the original edge pair. If the enlargement parameter is 0, special edge pairs with an area of 0 will be dropped.

Usage:

- `layer.polygons([ enlargement ])`

Example:

```ruby
layer = input(1, 0)
out = layer.polygons
out.output("polygons")
```

### `polygons?`

Returns true, if the layer is a polygon layer

Usage:

- `layer.polygons?`

Example:

```ruby
layer = input(1, 0)
if layer.polygons?
  puts "layer.polygons? is true"
end
```

### `pull_inside`

Selects shapes or regions of other which are inside polygons from the this region

This method selects all shapes or regions from other which are inside polygons from this region. Unless other is in raw mode (see raw), coherent regions are selected from other, otherwise individual shapes are selected.

The functionality is similar to select_inside, but chosing shapes from other rather than from self. Because in deep mode the hierarchy reference comes from self, this method provides a way to pull shapes from other to the hierarchy to self.

Usage:

- `layer.pull_inside(other)`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.pull_inside(other)
result = metal.pull_inside(other)
```

### `pull_interacting`

Selects shapes or edges of other which touch or overlap shapes from the this region

This method selects all shapes or regions from other which touch or overlap shapes from this region. Unless other is in raw mode (see raw), coherent regions are selected from other, otherwise individual shapes are selected.

The functionality is similar to select_interacting, but chosing shapes from other rather than from self. Because in deep mode the hierarchy reference comes from self, this method provides a way to pull shapes from other to the hierarchy to self.

Usage:

- `layer.pull_interacting(other)`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.pull_interacting(other)
result = metal.pull_interacting(other)
```

### `pull_overlapping`

Selects shapes or regions of other which overlap shapes from the this region

This method selects all shapes or regions from other which overlap shapes from this region. Unless other is in raw mode (see raw), coherent regions are selected from other, otherwise individual shapes are selected.

The functionality is similar to select_overlapping, but chosing shapes from other rather than from self. Because in deep mode the hierarchy reference comes from self, this method provides a way to pull shapes from other to the hierarchy to self.

Usage:

- `layer.pull_overlapping(other)`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.pull_overlapping(other)
result = metal.pull_overlapping(other)
```

### `raw`

Marks a layer as raw

A raw layer basically is the opposite of a "clean" layer (see clean). Polygons on a raw layer are considered "as is", i.e. overlapping polygons are not connected and inner edges may occur due to cut lines. Holes may not exists if the polygons are derived from a representation that does not allow holes (i.e. GDS2 files).

Note that this method will set the state of the layer. In combination with the fact, that copied layers are references to the original layer, this may lead to unexpected results:

Usage:

- `layer.raw`

Example:

```ruby
l = ...
l2 = l1
... do something
l.raw
# now l2 is also a raw layer
```

### `rectangles`

Selects all rectangles from the input

This method is available for polygon layers. By default "merged" semantics applies, i.e. all polygons are merged before rectangles are selected (see clean and raw). non_rectangles will select all non-rectangles.

Usage:

- `layer.rectangles`

Example:

```ruby
layer = input(1, 0)
out = layer.rectangles
out.output("rectangles")
```

### `rectilinear`

Selects all rectilinear polygons from the input

This method is available for polygon layers. By default "merged" semantics applies, i.e. all polygons are merged before rectilinear polygons are selected (see clean and raw). non_rectilinear will select all non-rectangles.

Usage:

- `layer.rectilinear`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.rectilinear
result = metal.rectilinear
```

### `remove_props`

Returns a new layer with all properties removed

This method will drop all user properties from the layer. Note that a new layer without properties is returned. The original layer stays untouched.

Usage:

- `layer.remove_props`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.remove_props
result = metal.remove_props
```

### `rotate`

Rotates a layer (modifies the layer)

Rotates the input by the given angle (in degree). The layer that this method is called upon is modified and the modified version is returned for further processing.

Usage:

- `layer.rotate(a)`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.rotate(a)
result = metal.rotate(a)
```

### `rotated`

Rotates a layer

Rotates the input layer by the given angle (in degree) and returns the rotated layer. The layer that this method is called upon is not modified.

The following image shows the effect of the "rotated" method:

Usage:

- `layer.rotated(a)`

Example:

```ruby
layer = input(1, 0)
out = layer.rotated(1.0, 0.0)
out.output("transformed")
```

### `rounded_corners`

Applies corner rounding to each corner of the polygon

Inner (concave) corners are replaced by circle segments with a radius given by the "inner" parameter. Outer (convex) corners are relaced by circle segments with a radius given by the "outer" parameter.

The circles are approximated by polygons. "n" segments are used to approximate a full circle.

Usage:

- `layer.rounded_corners(inner, outer, n)`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.rounded_corners(inner, outer, n)
result = metal.rounded_corners(inner, outer, n)
```

### `scale`

Scales a layer (modifies the layer)

Scales the input. After scaling, features have a f times bigger dimension. The layer that this method is called upon is modified and the modified version is returned for further processing.

Usage:

- `layer.scale(f)`

Example:

```ruby
layer = input(1, 0)
out = layer.scale(1.0, 0.0)
out.output("transformed")
```

### `scaled`

Scales a layer

Scales the input layer and returns a new layer whose features have a f times bigger dimension. The layer that this method is called upon is not modified.

The following images shows the effect of the "scaled" method:

Usage:

- `layer.scaled(f)`

Example:

```ruby
layer = input(1, 0)
out = layer.scaled(1.0, 0.0)
out.output("transformed")
```

### `second_edges`

Returns the second edges of an edge pair collection

Applies to edge pair collections only. Returns the second edges of the edge pairs in the collection.

Some checks deliver symmetric edge pairs (e.g. space, width, etc.) for which the edges are commutable. "second_edges" will not deliver edges for such edge pairs. Instead, "first_edges" will deliver both.

Usage:

- `layer.second_edges`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.second_edges
result = metal.second_edges
```

### `select`

Selects edges, edge pairs or polygons based on evaluation of a block

This method evaluates the block and returns a new container with those objects for which the block evaluates to true. It is available for edge, polygon and edge pair layers. The corresponding objects are DPolygon, DEdge or DEdgePair.

Because this method executes inside the interpreter, it's inherently slow. Tiling does not apply to this method.

Usage:

- `layer.select { |object| ... }`

Example:

```ruby
new_layer = layer.select { |polygon| polygon.area >= 10.0 }
```

### `select_covering`

Selects shapes or regions of self which completely cover (enclose) one or more shapes from the other region

This method selects all shapes or regions from self which cover shapes from the other region. Unless self is in raw mode (see raw), coherent regions are selected from self, otherwise individual shapes are selected. It modifies self to contain the selected shapes. A version which does not modify self is covering.

This method is available for polygons only.

Usage:

- `layer.select_covering(other)`
- `layer.select_covering(other, min_count)`
- `layer.select_covering(other, min_count, max_count)`
- `layer.select_covering(other, min_count .. max_count)`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.select_covering(other)
result = metal.select_covering(other)
```

### `select_if`

Selects shapes of a layer based on the evaluation of an expression

Evaluates the given expression on the shapes of the layer. If the evaluation gives a 'true' value, the shape is selected. Otherwise it is discarded.

The expression is written in KLayout expression notation.

Usage:

- `layer.select_if(expression [, variables])`

Example:

```ruby
# isotropic and scale invariant
layer.select_if("shape.holes > 0")

# anisotropic, but scale invariant
layer.select_if(aniso("shape.bbox.height/shape.bbox.width > 2"))

# isotropic, but not scale invariant
layer.select_if(scales("shape.area > 10.0"))

# anisotropic and not scale invariant
layer.select_if(aniso_and_scales("shape.bbox.width > 10.0"))
```

```ruby
layer.select(scales("shape.area < 10.0"))
```

```ruby
layer.select(scales("shape.area  10.0 })
```

### `select_inside`

Selects edges, edge pairs or polygons of self which are inside edges or polygons from the other layer

This method is the in-place version of inside - i.e. it modifies the layer instead of returning a new layer and leaving the original layer untouched.

Usage:

- `layer.select_inside(other)`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.select_inside(other)
result = metal.select_inside(other)
```

### `select_interacting`

Selects shapes or regions of self which touch or overlap shapes from the other region

This method selects all shapes or regions from self which touch or overlap shapes from the other layer. Unless self is in raw mode (see raw), coherent regions are selected from self, otherwise individual shapes are selected. It modifies self to contain the selected shapes. A version which does not modify self is interacting.

This method is available for polygon, text, edge and edge pair layers. Edges and edge pairs can be selected with respect to other edges or polygons. Texts can be selected with respect to polygons. Polygons can be selected with respect to edges, texts and other polygons.

Usage:

- `layer.select_interacting(other)`
- `layer.select_interacting(other, min_count)`
- `layer.select_interacting(other, min_count, max_count)`
- `layer.select_interacting(other, min_count .. max_count)`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.select_interacting(other)
result = metal.select_interacting(other)
```

### `select_not_covering`

Selects shapes or regions of self which do not cover (enclose) one or more shapes from the other region

This method selects all shapes or regions from self which do not cover shapes from the other region. Unless self is in raw mode (see raw), coherent regions are selected from self, otherwise individual shapes are selected. It modifies self to contain the selected shapes. A version which does not modify self is not_covering.

This method is available for polygons only.

Usage:

- `layer.select_not_covering(other)`
- `layer.select_not_covering(other, min_count)`
- `layer.select_not_covering(other, min_count, max_count)`
- `layer.select_not_covering(other, min_count .. max_count)`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.select_not_covering(other)
result = metal.select_not_covering(other)
```

### `select_not_inside`

Selects edges, edge pairs or polygons of self which are not inside edges or polygons from the other layer

This method is the in-place version of inside - i.e. it modifies the layer instead of returning a new layer and leaving the original layer untouched.

Usage:

- `layer.select_not_inside(other)`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.select_not_inside(other)
result = metal.select_not_inside(other)
```

### `select_not_interacting`

Selects shapes or regions of self which do not touch or overlap shapes from the other region

This method selects all shapes or regions from self which do not touch or overlap shapes from the other layer. Unless self is in raw mode (see raw), coherent regions are selected from self, otherwise individual shapes are selected. It modifies self to contain the selected shapes. A version which does not modify self is not_interacting.

This method is available for polygon, text, edge and edge pair layers. Edges or edge pairs can be selected with respect to other edges or polygons. Texts can be selected with respect to polygons. Polygons can be selected with respect to edges, texts and other polygons.

Usage:

- `layer.select_not_interacting(other)`
- `layer.select_not_interacting(other, min_count)`
- `layer.select_not_interacting(other, min_count, max_count)`
- `layer.select_not_interacting(other, min_count .. max_count)`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.select_not_interacting(other)
result = metal.select_not_interacting(other)
```

### `select_not_outside`

Selects edges, edge pairs or polygons of self which are not outside edges or polygons from the other layer

This method is the in-place version of outside - i.e. it modifies the layer instead of returning a new layer and leaving the original layer untouched.

Usage:

- `layer.select_not_outside(other)`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.select_not_outside(other)
result = metal.select_not_outside(other)
```

### `select_not_overlapping`

Selects shapes or regions of self which do not overlap shapes from the other region

This method selects all shapes or regions from self which do not overlap shapes from the other region. Unless self is in raw mode (see raw), coherent regions are selected from self, otherwise individual shapes are selected. It modifies self to contain the selected shapes. A version which does not modify self is not_overlapping.

This method is available for polygons only.

Usage:

- `layer.select_not_overlapping(other)`
- `layer.select_not_overlapping(other, min_count)`
- `layer.select_not_overlapping(other, min_count, max_count)`
- `layer.select_not_overlapping(other, min_count .. max_count)`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.select_not_overlapping(other)
result = metal.select_not_overlapping(other)
```

### `select_outside`

Selects edges, edge pairs or polygons of self which are outside edges or polygons from the other layer

This method is the in-place version of outside - i.e. it modifies the layer instead of returning a new layer and leaving the original layer untouched.

Usage:

- `layer.select_outside(other)`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.select_outside(other)
result = metal.select_outside(other)
```

### `select_overlapping`

Selects shapes or regions of self which overlap shapes from the other region

This method selects all shapes or regions from self which overlap shapes from the other region. Unless self is in raw mode (see raw), coherent regions are selected from self, otherwise individual shapes are selected. It modifies self to contain the selected shapes. A version which does not modify self is overlapping.

This method is available for polygons only.

Usage:

- `layer.select_overlapping(other)`
- `layer.select_overlapping(other, min_count)`
- `layer.select_overlapping(other, min_count, max_count)`
- `layer.select_overlapping(other, min_count .. max_count)`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.select_overlapping(other)
result = metal.select_overlapping(other)
```

### `select_props`

Enables or selects properties from a property-annotated layer

This method will select specific property keys from layers. It returns a new layer with the new properties. The original layer is not modified.

You can specify the user property keys (names) to use. As user properties in general are a set of key/value pairs and may carry multiple values under different keys, this feature can be handy to filter out a specific aspect. To get only the values from key 1 (integer), use:

Usage:

- `layer.select_props(keys)`

Example:

```ruby
layer1 = input(1, 0, enable_properties)
layer1_filtered = layer1.select_props(1)
```

```ruby
layer1 = input(1, 0, enable_properties)
layer1_filtered = layer1.select_props(1, 2)
```

### `selected_if`

Selects shapes based on the evaluation of an expression

This method is the out-of-place version of select_if. It takes the same arguments.

Usage:

- `layer.selected_if(expression [, variables])`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.selected_if(expression [, variables])
result = metal.selected_if(expression )
```

### `sep`

An alias for "separation"

Usage:

- `layer.sep(value [, options])`

Example:

```ruby
metal = input(1, 0)
markers = metal.sep(0.2.um)
markers.output("sep_violations")
```

### `separation`

A two-layer spacing check

Note: "separation" and "sep" are available as operators for the "universal DRC" function drc within the DRC framework. These variants have more options and are more intuitive to use. See separation for more details.

This method performs a two-layer spacing check. Like space, this method can be applied to edge or polygon layers. Locations where edges of the layer are closer than the specified distance to the other layer are reported as edge pair error markers.

Usage:

- `layer.separation(other_layer, value [, options])`
- `layer.sep(other_layer, value [, options])`

Example:

```ruby
metal = input(1, 0)
markers = metal.separation(0.2.um)
markers.output("separation_violations")
```

### `size`

Polygon sizing (per-edge biasing, modifies the layer)

See sized for a description of the options. The size method basically does the same but modifies the layer it is called on. The input layer is returned and available for further processing.

Usage:

- `layer.size(d [, mode])`
- `layer.size(d, size_inside(l) [, steps(n)] [, mode])`
- `layer.size(d, size_outside(l) [, steps(n)] [, mode])`
- `layer.size(dx, dy [, mode])`
- `layer.size(dx, dy, size_inside(l) [, steps(n)] [, mode])`
- `layer.size(dx, dy, size_outside(l) [, steps(n)] [, mode])`

Example:

```ruby
layer = input(1, 0)
out = layer.size(0.1.um)
out.output("transformed")
```

### `sized`

Polygon sizing (per-edge biasing)

This method requires a polygon layer. It will apply a bias per edge of the polygons and return the biased layer. The layer that this method is called on is not modified.

The alternative method size works like sized but modifies the layer it is called on.

Usage:

- `layer.sized(d [, mode] [, size_inside(l) [, steps(n)]])`
- `layer.sized(d, size_inside(l) [, steps(n)] [, mode])`
- `layer.sized(d, size_outside(l) [, steps(n)] [, mode])`
- `layer.sized(dx, dy [, mode])`
- `layer.sized(dx, dy, size_inside(l) [, steps(n)] [, mode])`
- `layer.sized(dx, dy, size_outside(l) [, steps(n)] [, mode])`

Example:

```ruby
layer.sized(300.nm).raw.merged(2)
```

```ruby
ntap.sized(30.um, size_inside(nwell), steps(100))
```

### `smoothed`

Smoothes the polygons of the region

"Smoothing" returns a simplified version of the polygons. Simplification is achieved by removing vertices unless the resulting polygon deviates by more than the given distance d from the original polygon.

"hv_keep" is a boolean parameter which makes the smoothing function maintain horizontal or vertical edges. The default is false, meaning horizontal or vertical edges may be changed into tilted ones.

Usage:

- `layer.smoothed(d)`
- `layer.smoothed(d, hv_keep)`

Example:

```ruby
layer = input(1, 0)
out = layer.smoothed()
out.output("smoothed")
```

### `snap`

Brings each vertex on the given grid (g or gx/gy for x or y direction)

Shifts each off-grid vertex to the nearest on-grid location. If one grid is given, this grid is applied to x and y coordinates. If two grids are given, gx is applied to the x coordinates and gy is applied to the y coordinates. If 0 is given as a grid, no snapping is performed in that direction.

This method modifies the layer. A version that returns a snapped version of the layer without modifying the layer is snapped.

Usage:

- `layer.snap(g)`
- `layer.snap(gx, gy)`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.snap(g)
result = metal.snap(g)
```

### `snapped`

Returns a snapped version of the layer

See snap for a description of the functionality. In contrast to snap, this method does not modify the layer but returns a snapped copy.

Usage:

- `layer.snapped(g)`
- `layer.snapped(gx, gy)`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.snapped(g)
result = metal.snapped(g)
```

### `space`

A space check

Note: "space" is available as an operator for the "universal DRC" function Layer#drc within the DRC framework. This variant has more options and is more intuitive to use. See space for more details.

This method performs a space check and returns a collection of edge pairs. A space check can be performed on polygon and edge layers. On edge layers, all edges are checked against all other edges. If two edges form a "face to face" relation (i.e. their outer sides face each other) and their distance is less than the specified value, an error shape is generated for that edge pair. On polygon layers, the polygons on each layer are checked for space against other polygons for locations where their…

Usage:

- `layer.space(value [, options])`

Example:

```ruby
metal = input(1, 0)
markers = metal.space(0.2.um)
markers.output("space_violations")
```

### `split_covering`

Returns the results of covering and not_covering at the same time

This method returns the polygons covering polygons from the other layer in one layer and all others in a second layer. This method is equivalent to calling covering and not_covering, but is faster than doing this in separate steps:

(covering, not_covering) = l1.split_covering(l2)

Usage:

- `(a, b) = layer.split_covering(other [, options ])`

Example:

```ruby
(covering, not_covering) = l1.split_covering(l2)
```

### `split_if`

Selects shapes based on the evaluation of an expression and returns selected and unselected shapes in different layers

This method, like the other 'split_...' methods returns two layers: one with the result of selected_if, and a second with all other shapes.

The following example splits a layer into two: one with the shapes that have an area less than 10 square micrometers and another one with the shapes that have a bigger area:

Usage:

- `layer.selected_if(expression [, variables])`

Example:

```ruby
(smaller, bigger) = layer.split_if(scales("shape.area < 10.0"))
```

### `split_inside`

Returns the results of inside and not_inside at the same time

This method returns the polygons, edge pairs or edges inside of polygons or edges from the other layer in one layer and all others in a second layer. This method is equivalent to calling inside and not_inside, but is faster than doing this in separate steps:

(inside, not_inside) = l1.split_inside(l2)

Usage:

- `(a, b) = layer.split_inside(other)`

Example:

```ruby
(inside, not_inside) = l1.split_inside(l2)
```

### `split_interacting`

Returns the results of interacting and not_interacting at the same time

This method returns the polygons or edges interacting with objects from the other container in one layer and all others in a second layer. This method is equivalent to calling interacting and not_interacting, but is faster than doing this in separate steps:

(interacting, not_interacting) = l1.split_interacting(l2)

Usage:

- `(a, b) = layer.split_interacting(other [, options ])`

Example:

```ruby
(interacting, not_interacting) = l1.split_interacting(l2)
```

### `split_outside`

Returns the results of outside and not_outside at the same time

This method returns the polygons, edge pairs or edges outside of polygons or edges from the other layer in one layer and all others in a second layer. This method is equivalent to calling outside and not_outside, but is faster than doing this in separate steps:

(outside, not_outside) = l1.split_outside(l2)

Usage:

- `(a, b) = layer.split_outside(other)`

Example:

```ruby
(outside, not_outside) = l1.split_outside(l2)
```

### `split_overlapping`

Returns the results of overlapping and not_overlapping at the same time

This method returns the polygons overlapping polygons from the other layer in one layer and all others in a second layer. This method is equivalent to calling overlapping and not_overlapping, but is faster than doing this in separate steps:

(overlapping, not_overlapping) = l1.split_overlapping(l2)

Usage:

- `(a, b) = layer.split_overlapping(other [, options ])`

Example:

```ruby
(overlapping, not_overlapping) = l1.split_overlapping(l2)
```

### `squares`

Selects all squares from the input

This method is available for polygon layers. By default "merged" semantics applies, i.e. all polygons are merged before squares are selected (see clean and raw). non_squares will select all non-rectangles.

Usage:

- `layer.squares`

Example:

```ruby
layer = input(1, 0)
out = layer.squares
out.output("squares")
```

### `start_segments`

Returns the part at the beginning of each edge

This method will return a partial edge for each edge in the input, located and the end of the original edge. The new edges will share the start point with the original edges, but not necessarily their end points. For further details about the orientation of edges and the parameters of this method, see end_segments.

The following images show the effect of the method:

Usage:

- `layer.start_segments(length)`
- `layer.start_segments(length, fraction)`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.start_segments(length)
result = metal.start_segments(length)
```

### `strict`

Marks a layer for strict handling

If a layer is marked for strict handling, some optimizations are disabled. Specifically for boolean operations, the results will also be merged if one input is empty. For boolean operations, strict handling should be enabled for both inputs. Strict handling is disabled by default.

This feature has been introduced in version 0.23.2.

Usage:

- `layer.strict`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.strict
result = metal.strict
```

### `strict?`

Returns true, if strict handling is enabled for this layer

This feature has been introduced in version 0.23.2.

Usage:

- `layer.is_strict?`

Example:

```ruby
layer = input(1, 0)
if layer.strict?
  puts "layer.strict? is true"
end
```

### `texts`

Selects texts from an original layer

This method can be applied to original layers - i.e. ones that have been created with input. By default, a small box (2x2 DBU) will be produced on each selected text. By using the "as_dots" option, degenerated point-like edges will be produced.

The preferred method however is to use true text layers created with labels. In this case, without specifying "as_dots" or "as_boxes" retains the text objects as such a text filtering is applied. In contrast to this, layers generated with input cannot maintain the text nature of the selected objects and produce dots or small polygon boxes in the texts method.

Usage:

- `layer.texts`
- `layer.texts(p)`
- `layer.texts([ options ])`

Example:

```ruby
# Selects all texts
t = labels(1, 0).texts
# Selects all texts beginning with an "A"
t = labels(1, 0).texts("A*")
t = labels(1, 0).texts(pattern("A*"))
# Selects all texts whose string is "ABC"
t = labels(1, 0).texts(text("ABC"))
```

### `texts?`

Returns true, if the layer is a text collection

Usage:

- `layer.texts?`

Example:

```ruby
layer = input(1, 0)
if layer.texts?
  puts "layer.texts? is true"
end
```

### `texts_not`

Selects texts from an original layer not matching a specific selection

This method can be applied to true text layers obtained with labels. In this case, without specifying "as_dots" or "as_boxes" retains the text objects as such. Only text filtering is applied.

Beside that this method acts like texts, but will select the text objects not matching the filter.

Usage:

- `layer.texts_not`
- `layer.texts_not(p)`
- `layer.texts_not([ options ])`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.texts_not
result = metal.texts_not
```

### `transform`

Transforms a layer (modifies the layer)

Like transform, but modifies the input and returns a reference to it for further processing.

Usage:

- `layer.transform(t)`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.transform(t)
result = metal.transform(t)
```

### `transformed`

Transforms a layer

Transforms the input layer by the given transformation and returns the moved layer. The layer that this method is called upon is not modified. This is the most generic method is transform a layer. The transformation is a DCplxTrans object which describes many different kinds of affine transformations except shear and anisotropic magnification.

The following image shows the effect of the "moved" method:

Usage:

- `layer.transformed(t)`

Example:

```ruby
metal = input(1, 0)
# from usage: layer.transformed(t)
result = metal.transformed(t)
```

### `width`

A width check

Note: "width" is available as an operator for the "universal DRC" function Layer#drc within the DRC framework. This variant has more options and is more intuitive to use. See width for more details.

This method performs a width check and returns a collection of edge pairs. A width check can be performed on polygon and edge layers. On edge layers, all edges are checked against all other edges. If two edges form a "back to back" relation (i.e. their inner sides face each other) and their distance is less than the specified value, an error shape is generated for that edge pair. On polygon layers, the polygons on each layer are checked for locations where their width is less than the specified…

Usage:

- `layer.width(value [, options])`

Example:

```ruby
# width check for 1.5 micron:
markers = in.width(1.5)
# width check for 2 database units:
markers = in.width(2)
# width check for 2 micron:
markers = in.width(2.um)
# width check for 20 nanometers:
markers = in.width(20.nm)
```

```ruby
connect(metal1, via1)
...

# attaches net identity as properties
metal1_nets = metal1.nets

space_not_connected = metal1_nets.space(0.4.um, props_ne)
space_connected     = metal1_nets.space(0.4.um, props_eq)
```

```ruby
space_not_connected = metal1_nets.space(0.4.um, props_ne + props_copy)
space_connected     = metal1_nets.space(0.4.um, props_eq + props_copy)
```

### `with_angle`

Selects edges by their angle

When called on an edge layer, the method selects edges by their angle, measured against the horizontal axis in the mathematical sense.

For this measurement edges are considered without their direction and straight lines. A horizontal edge has an angle of zero degree. A vertical one has an angle of 90 degee. The angle range is from -90 (exclusive) to 90 degree (inclusive).

Usage:

- `layer.with_angle(min .. max [, absolute])`
- `layer.with_angle(value [, absolute])`
- `layer.with_angle(min, max [, absolute])`
- `layer.with_angle(ortho)`
- `layer.with_angle(diagonal)`
- `layer.with_angle(diagonal_only)`
- `edge_pair_layer.with_angle(... [, both] [, absolute])`

Example:

```ruby
# at least one edge needs to be horizontal
ep1 = edge_pairs.with_angle(0)
# both edges need to vertical
ep2 = edge_pairs.with_angle(90, both)
```

```ruby
ortho_edges = edges.with_angle(ortho)

# which is equivalent to, but more efficient as:
ortho_edges = edges.with_angle(0) + edges.with_angle(90)
```

### `with_area`

Selects polygons or edge pairs by area

The first form will select all polygons or edge pairs with an area larger or equal to min and less (but not equal to) max. The second form will select the polygons or edge pairs with exactly the given area. The third form basically is equivalent to the first form, but allows specification of nil for min or max indicating no lower or upper limit.

This method is available for polygon or edge pair layers.

Usage:

- `layer.with_area(min .. max)`
- `layer.with_area(value)`
- `layer.with_area(min, max)`

Example:

```ruby
layer = input(1, 0)
out = layer.with_area(0.0 .. 1.0)
out.output("filtered")
```

### `with_area_ratio`

Selects polygons by the ratio of the bounding box area vs. polygon area

The area ratio is a measure how far a polygon is approximated by its bounding box. The value is always larger or equal to 1. Boxes have a area ratio of 1. Larger values mean more empty area inside the bounding box.

This method is available for polygon layers only.

Usage:

- `layer.with_area_ratio(min .. max)`
- `layer.with_area_ratio(value)`
- `layer.with_area_ratio(min, max)`

Example:

```ruby
layer = input(1, 0)
out = layer.with_area_ratio(0.0 .. 1.0)
out.output("filtered")
```

### `with_bbox_aspect_ratio`

Selects polygons by the aspect ratio of their bounding box

The method selects polygons similar to with_area or with_perimeter. However, the measured value is the aspect ratio of the bounding box. It is the larger dimensions divided by the smaller one. The "thinner" the polygon, the larger the aspect ratio. A square bounding box gives an aspect ratio of 1.

This method is available for polygon layers only.

Usage:

- `layer.with_bbox_aspect_ratio(min .. max)`
- `layer.with_bbox_aspect_ratio(value)`
- `layer.with_bbox_aspect_ratio(min, max)`

Example:

```ruby
layer = input(1, 0)
out = layer.with_bbox_aspect_ratio(0.0 .. 1.0)
out.output("filtered")
```

### `with_bbox_height`

Selects polygons by the height of the bounding box

The method selects polygons similar to with_area or with_perimeter. However, the measured dimension is the width of the bounding box.

This method is available for polygon layers only.

Usage:

- `layer.with_bbox_height(min .. max)`
- `layer.with_bbox_height(value)`
- `layer.with_bbox_height(min, max)`

Example:

```ruby
layer = input(1, 0)
out = layer.with_bbox_height(0.0 .. 1.0)
out.output("filtered")
```

### `with_bbox_max`

Selects polygons by the maximum dimension of the bounding box

The method selects polygons similar to with_area or with_perimeter. However, the measured dimension is the maximum dimension of the bounding box. The maximum dimension is either the width or height of the bounding box, whichever is larger.

This method is available for polygon layers only.

Usage:

- `layer.with_bbox_max(min .. max)`
- `layer.with_bbox_max(value)`
- `layer.with_bbox_max(min, max)`

Example:

```ruby
layer = input(1, 0)
out = layer.with_bbox_max(0.0 .. 1.0)
out.output("filtered")
```

### `with_bbox_min`

Selects polygons by the minimum dimension of the bounding box

The method selects polygons similar to with_area or with_perimeter. However, the measured dimension is the minimum dimension of the bounding box. The minimum dimension is either the width or height of the bounding box, whichever is smaller.

This method is available for polygon layers only.

Usage:

- `layer.with_bbox_min(min .. max)`
- `layer.with_bbox_min(value)`
- `layer.with_bbox_min(min, max)`

Example:

```ruby
layer = input(1, 0)
out = layer.with_bbox_min(0.0 .. 1.0)
out.output("filtered")
```

### `with_bbox_width`

Selects polygons by the width of the bounding box

The method selects polygons similar to with_area or with_perimeter. However, the measured dimension is the width of the bounding box.

This method is available for polygon layers only.

Usage:

- `layer.with_bbox_width(min .. max)`
- `layer.with_bbox_width(value)`
- `layer.with_bbox_width(min, max)`

Example:

```ruby
layer = input(1, 0)
out = layer.with_bbox_width(0.0 .. 1.0)
out.output("filtered")
```

### `with_density`

Returns tiles whose density is within a given range

This method runs a tiled analysis over the current layout. It reports the tiles whose density is between "min_value" and "max_value". "min_value" and "max_value" are given in relative units, i.e. within the range of 0 to 1.0 corresponding to a density of 0 to 100%.

"min_value" or "max_value" can be nil or omitted in the ".." range notation. In this case, they are taken as "0" and "100%".

Usage:

- `layer.with_density(min_value, max_value [, options ])`
- `layer.with_density(min_value .. max_value [, options ])`

Example:

```ruby
# reports areas where layer 1/0 density is below 10% on 20x20 um tiles
low_density = input(1, 0).with_density(0.0 .. 0.1, tile_size(20.um))
```

```ruby
# reports areas where layer 1/0 density is below 10% on 30x30 um tiles
# with a tile step of 20x20 um:
low_density = input(1, 0).with_density(0.0 .. 0.1, tile_size(30.um), tile_step(20.um))
```

```ruby
# reports density of layer 1/0 below 10% on 20x20 um tiles. The layout's boundary is taken from
# layer 0/0:
cell_frame = input(0, 0)
low_density = input(1, 0).with_density(0.0 .. 0.1, tile_size(20.um), tile_boundary(cell_frame))
```

### `with_distance`

Selects edge pairs by the distance of the edges

The method selects edge pairs by the distance of their edges. The first version selects edge pairs with a distance larger or equal to min and less than max (but not equal). The second version selects edge pairs with exactly the given distance. The third version is similar to the first one, but allows specification of nil for min or max indicating that there is no lower or upper limit.

The distance of the edges is defined by the minimum distance of all points from the edges involved. For edge pairs generated in geometrical checks this is equivalent to the actual distance of the original edges.

Usage:

- `layer.with_distance(min .. max)`
- `layer.with_distance(value)`
- `layer.with_distance(min, max)`

Example:

```ruby
layer = input(1, 0)
out = layer.with_distance(0.0 .. 1.0)
out.output("filtered")
```

### `with_holes`

Selects all polygons with the specified number of holes

This method is available for polygon layers. It will select all polygons from the input layer which have the specified number of holes. Without any argument, all polygons with holes are selected.

Usage:

- `layer.with_holes`
- `layer.with_holes(count)`
- `layer.with_holes(min_count, max_count)`
- `layer.with_holes(min_count .. max_count)`

Example:

```ruby
layer = input(1, 0)
out = layer.with_holes(0.0 .. 1.0)
out.output("filtered")
```

### `with_internal_angle`

Selects edge pairs by their internal angle

This method selects edge pairs by the angle enclosed by their edges. The angle is between 0 (parallel or anti-parallel edges) and 90 degree (perpendicular edges). If an interval or two values are given, the angle is checked to be within the given range.

Here are examples for "with_internal_angle" on edge pair layers:

Usage:

- `edge_pair_layer.with_internal_angle(min .. max)`
- `edge_pair_layer.with_internal_angle(value)`
- `edge_pair_layer.with_internal_angle(min, max)`

Example:

```ruby
# selects edge pairs with parallel edges
ep1 = edge_pairs.with_internal_angle(0)
# selects edge pairs with perpendicular edges
ep2 = edge_pairs.with_internal_angle(90)
```

### `with_length`

Selects edges by their length

The method selects edges by their length. The first version selects edges with a length larger or equal to min and less than max (but not equal). The second version selects edges with exactly the given length. The third version is similar to the first one, but allows specification of nil for min or max indicating that there is no lower or upper limit.

This method is available for edge and edge pair layers.

Usage:

- `layer.with_length(min .. max)`
- `layer.with_length(value)`
- `layer.with_length(min, max)`
- `edge_pairlayer.with_length(min, max [, both])`

Example:

```ruby
# at least one edge needs to have a length of 1.0 <= l < 2.0
ep1 = edge_pairs.with_length(1.um .. 2.um)
# both edges need to have a length of exactly 2 um
ep2 = edge_pairs.with_length(2.um, both)
```

### `with_perimeter`

Selects polygons by perimeter

The first form will select all polygons with an perimeter larger or equal to min and less (but not equal to) max. The second form will select the polygons with exactly the given perimeter. The third form basically is equivalent to the first form, but allows specification of nil for min or max indicating no lower or upper limit.

This method is available for polygon layers only.

Usage:

- `layer.with_perimeter(min .. max)`
- `layer.with_perimeter(value)`
- `layer.with_perimeter(min, max)`

Example:

```ruby
layer = input(1, 0)
out = layer.with_perimeter(0.0 .. 1.0)
out.output("filtered")
```

### `with_relative_height`

Selects polygons by the ratio of the height vs. width of its bounding box

The relative height is a measure how tall a polygon is. Tall polygons have values larger than 1, wide polygons have a value smaller than 1. Squares have a value of 1.

Don't use this method when you can use with_area_ratio, which provides a similar measure but is isotropic.

Usage:

- `layer.with_relative_height(min .. max)`
- `layer.with_relative_height(value)`
- `layer.with_relative_height(min, max)`

Example:

```ruby
layer = input(1, 0)
out = layer.with_relative_height(0.0 .. 1.0)
out.output("filtered")
```

### `without_angle`

Selects edges by the their angle

The method basically is the inverse of with_angle. It selects all edges of the edge layer or corners of the polygons which do not have the given angle (second form) or whose angle is not inside the given interval (first and third form) or of the given type (other forms).

When called on edge pairs, it selects edge pairs by the angles of their edges.

Usage:

- `layer.without_angle(min .. max [, absolute])`
- `layer.without_angle(value [, absolute])`
- `layer.without_angle(min, max [, absolute])`
- `layer.without_angle(ortho)`
- `layer.without_angle(diagonal)`
- `layer.without_angle(diagonal_only)`
- `edge_pair_layer.without_angle(... [, both] [, absolute])`

Example:

```ruby
# both edges are not horizontal or:
# the edge pair is skipped if one edge is horizontal
ep = edge_pairs.without_angle(0, both)
```

### `without_area`

Selects polygons or edge pairs by area

This method is the inverse of "with_area". It will select polygons or edge pairs without an area equal to the given one or outside the given interval.

This method is available for polygon or edge pair layers.

Usage:

- `layer.without_area(min .. max)`
- `layer.without_area(value)`
- `layer.without_area(min, max)`

Example:

```ruby
layer = input(1, 0)
out = layer.without_area(0.0 .. 1.0)
out.output("filtered")
```

### `without_area_ratio`

Selects polygons by the aspect ratio of their bounding box

The method provides the opposite filter for with_area_ratio.

This method is available for polygon layers only.

Usage:

- `layer.without_area_ratio(min .. max)`
- `layer.without_area_ratio(value)`
- `layer.without_area_ratio(min, max)`

Example:

```ruby
layer = input(1, 0)
out = layer.without_area_ratio(0.0 .. 1.0)
out.output("filtered")
```

### `without_bbox_height`

Selects polygons by the aspect ratio of their bounding box

The method provides the opposite filter for with_bbox_aspect_ratio.

This method is available for polygon layers only.

Usage:

- `layer.without_bbox_aspect_ratio(min .. max)`
- `layer.without_bbox_aspect_ratio(value)`
- `layer.without_bbox_aspect_ratio(min, max)`
- `layer.without_bbox_height(min .. max)`
- `layer.without_bbox_height(value)`
- `layer.without_bbox_height(min, max)`

Example:

```ruby
layer = input(1, 0)
out = layer.without_bbox_height(0.0 .. 1.0)
out.output("filtered")
```

### `without_bbox_max`

Selects polygons by the maximum dimension of the bounding box

The method selects polygons similar to without_area or without_perimeter. However, the measured dimension is the maximum dimension of the bounding box. The minimum dimension is either the width or height of the bounding box, whichever is larger.

This method is available for polygon layers only.

Usage:

- `layer.without_bbox_max(min .. max)`
- `layer.without_bbox_max(value)`
- `layer.without_bbox_max(min, max)`

Example:

```ruby
layer = input(1, 0)
out = layer.without_bbox_max(0.0 .. 1.0)
out.output("filtered")
```

### `without_bbox_min`

Selects polygons by the minimum dimension of the bounding box

The method selects polygons similar to without_area or without_perimeter. However, the measured dimension is the minimum dimension of the bounding box. The minimum dimension is either the width or height of the bounding box, whichever is smaller.

This method is available for polygon layers only.

Usage:

- `layer.without_bbox_min(min .. max)`
- `layer.without_bbox_min(value)`
- `layer.without_bbox_min(min, max)`

Example:

```ruby
layer = input(1, 0)
out = layer.without_bbox_min(0.0 .. 1.0)
out.output("filtered")
```

### `without_bbox_width`

Selects polygons by the width of the bounding box

The method selects polygons similar to without_area or without_perimeter. However, the measured dimension is the width of the bounding box.

This method is available for polygon layers only.

Usage:

- `layer.without_bbox_width(min .. max)`
- `layer.without_bbox_width(value)`
- `layer.without_bbox_width(min, max)`

Example:

```ruby
layer = input(1, 0)
out = layer.without_bbox_width(0.0 .. 1.0)
out.output("filtered")
```

### `without_density`

Returns tiles whose density is not within a given range

For details about the operations and the operation see with_density. This version will return the tiles where the density is not within the given range.

Usage:

- `layer.without_density(min_value, max_value [, options ])`
- `layer.without_density(min_value .. max_value [, options ])`

Example:

```ruby
layer = input(1, 0)
out = layer.without_density(0.0 .. 1.0)
out.output("filtered")
```

### `without_distance`

Selects edge pairs by the distance of the edges

The method basically is the inverse of with_distance. It selects all edge pairs of the edge pair layer which do not have the given distance (second form) or are not inside the given interval (first and third form).

This method is available for edge pair layers only.

Usage:

- `layer.without_distance(min .. max)`
- `layer.without_distance(value)`
- `layer.without_distance(min, max)`

Example:

```ruby
layer = input(1, 0)
out = layer.without_distance(0.0 .. 1.0)
out.output("filtered")
```

### `without_holes`

Selects all polygons with the specified number of holes

This method is available for polygon layers. It will select all polygons from the input layer which do not have the specified number of holes. Without any arguments, all polygons without holes are selected.

Usage:

- `layer.without_holes`
- `layer.without_holes(count)`
- `layer.without_holes(min_count, max_count)`
- `layer.without_holes(min_count .. max_count)`

Example:

```ruby
layer = input(1, 0)
out = layer.without_holes(0.0 .. 1.0)
out.output("filtered")
```

### `without_internal_angle`

Selects edge pairs by their internal angle

The method basically is the inverse of with_internal_angle. It selects all edge pairs by the angle enclosed by their edges, applying the opposite criterion than with_internal_angle.

Usage:

- `edge_pair_layer.without_internal_angle(min .. max)`
- `edge_pair_layer.without_internal_angle(value)`
- `edge_pair_layer.without_internal_angle(min, max)`

Example:

```ruby
layer = input(1, 0)
out = layer.without_internal_angle(0.0 .. 1.0)
out.output("filtered")
```

### `without_length`

Selects edges by the their length

The method basically is the inverse of with_length. It selects all edges of the edge layer which do not have the given length (second form) or are not inside the given interval (first and third form).

This method is available for edge and edge pair layers.

Usage:

- `layer.without_length(min .. max)`
- `layer.without_length(value)`
- `layer.without_length(min, max)`
- `edge_pairlayer.with_length(min, max [, both])`

Example:

```ruby
# both edges are not exactly 1 um in length, or:
# the edge pair is skipped if one edge has a length of exactly 1 um
ep = edge_pairs.without_length(1.um, both)
```

### `without_perimeter`

Selects polygons by perimeter

This method is the inverse of "with_perimeter". It will select polygons without a perimeter equal to the given one or outside the given interval.

This method is available for polygon layers only.

Usage:

- `layer.without_perimeter(min .. max)`
- `layer.without_perimeter(value)`
- `layer.without_perimeter(min, max)`

Example:

```ruby
layer = input(1, 0)
out = layer.without_perimeter(0.0 .. 1.0)
out.output("filtered")
```

### `without_relative_height`

Selects polygons by the ratio of the height vs. width

The method provides the opposite filter for with_relative_height.

This method is available for polygon layers only.

Usage:

- `layer.without_relative_height(min .. max)`
- `layer.without_relative_height(value)`
- `layer.without_relative_height(min, max)`

Example:

```ruby
layer = input(1, 0)
out = layer.without_relative_height(0.0 .. 1.0)
out.output("filtered")
```

### `xor`

Boolean XOR operation

The method computes a boolean XOR between self and other. It is an alias for the "^" operator.

This method is available for polygon and edge layers.

Usage:

- `layer.xor(other)`

Example:

```ruby
a = input(1, 0)
b = input(2, 0)
out = a.xor(b)
out.output("result")
```

### `|`

Boolean OR operation

The method computes a boolean OR between self and other. A similar operation is join which will basically gives the same result but won't merge the shapes.

This method is available for polygon and edge layers. An alias is "or". See there for a description of the function.

Usage:

- `self | other`

Example:

```ruby
metal1 = input(1, 0)
metal2 = input(2, 0)
out = metal1 | metal2
out.output("bool_|")
```


---

## Netter object (connectivity / netlist extraction)

| Command | Description |
|---|---|
| `antenna_check` | Performs an antenna check |
| `clear_connections` | Clears all connections stored so far |
| `connect` | Specifies a connection between two layers |
| `connect_explicit` | Specifies a list of net names for nets to connect ("must connect" nets) |
| `connect_global` | Connects a layer with a global net |
| `connect_implicit` | Specifies a search pattern for implicit net connections ("must connect" nets) |
| `device_scaling` | Specifies a dimension scale factor for the geometrical device properties |
| `evaluate_nets` | Evaluates net properties and annotates shapes from a given layer on the nets |
| `extract_devices` | Extracts devices based on the given extractor class, name and device layer selection |
| `ignore_extraction_errors` | Specifies whether to ignore extraction errors |
| `l2n_data` | Gets the internal LayoutToNetlist object |
| `name` | Assigns a name to a layer |
| `name_prefix` | Specifies the name prefix for auto-generated layer names |
| `netlist` | Gets the extracted netlist or triggers extraction if not done yet |
| `soft_connect` | Specifies a soft connection between two layers |
| `soft_connect_global` | Soft-connects a layer with a global net |
| `top_level` | Specifies top level mode |

### Netter method details

### `antenna_check`

Performs an antenna check

The antenna check is used to avoid plasma induced damage. Physically, the damage happes if during the manufacturing of a metal layer with plasma etching charge accumulates on the metal islands. On reaching a certain threshold, this charge may discarge over gate oxide attached of devices attached to such metal areas hence damaging it.

Antenna checks are performed by collecting all connected nets up to a certain metal layer and then computing the area of all metal shapes and all connected gates of a certain kind (e.g. thin and thick oxide gates). The ratio of metal area divided by the gate area must not exceed a certain threshold.

Usage:

- `antenna_check(gate, metal, ratio, [ diode_specs ... ] [, texts ])`

Example:

```ruby
poly = ... # poly layer
diff = ... # diffusion layer
contact = ... # contact layer
metal1 = ... # metal layer

# compute gate area
gate = poly & diff

# note that gate and poly have to be included - gate is
# a subset of poly, but forms the sensitive area
connect(gate, poly)
connect(poly, contact)
connect(contact, metal1)
errors = antenna_check(gate, metal1, 50.0)
```

```ruby
# provide connections up to metal1
connect(gate, poly)
connect(poly, contact)
connect(contact, metal1)
metal1_errors = antenna_check(gate, metal1, 50.0)

# now *add* connections up to metal2
connect(metal1, via1)
connect(via1, metal2)
metal2_errors = antenna_check(gate, metal2, 50.0)

... continue this scheme with further metal layers ...
```

```ruby
...
diode = ... # diode recognition layer

connect(diode, contact)
errors = antenna_check(gate, metal1, 50.0, diode)
```

### `clear_connections`

Clears all connections stored so far

Usage:

- `clear_connections`

Example:

```ruby
# Netter / connectivity
clear_connections
```

### `connect`

Specifies a connection between two layers

a and b must be polygon or text layers. After calling this function, the Netter regards all overlapping or touching shapes on these layers to form an electrical connection between the materials formed by these layers. This also implies intra-layer connections: shapes on these layers touching or overlapping other shapes on these layers will form bigger, electrically connected areas.

Texts will be used to assign net names to the nets. The preferred method is to use labels to create a text layer from a design layer. When using input, text labels are carried implicitly with the polygons but at the cost of small dummy shapes (2x2 DBU marker polygons) and limited functionality.

Usage:

- `connect(a, b)`

Example:

```ruby
connect(metal1, via1)
connect(via1, metal2)
```

### `connect_explicit`

Specifies a list of net names for nets to connect ("must connect" nets)

Use this method to explicitly connect nets even if there is no physical connection. The concept is similar to implicit connection (see connect_implicit). The method gets a list of nets which are connected virtually, even if there is no physical connection. The first version applies this scheme to all cells, the second version to cells matching the cell name pattern. The cell name pattern follows the usual glob style form (e.g. "A*" applies the connection in all cells whose name starts with "A").

This method is useful to establish a logical connection which is made later up on the next level of hierarchy. For example, a standard cell my not contain substrate or well taps as these may be made by tap or spare cells. Logically however, the cell only has one power or ground pin for the devices and substrate or well. In order to match both representations - for example for the purpose of LVS - the dual power or ground pins have to be connected. Assuming that there is a global net "BULK" for t…

Usage:

- `connect_explicit(net_names)`
- `connect_explicit(cell_pattern, net_names)`

Example:

```ruby
connect_global(bulk, "BULK")
...
connect_explicit("INV*", [ "BULK", "VSS" ])
```

### `connect_global`

Connects a layer with a global net

Connects the shapes from the given layer l to a global net with the given name. Global nets are common to all cells. Global nets automatically connect to parent cells throughs implied pins. An example is the substrate (bulk) net which connects to shapes belonging to tie-down diodes. "l" can be a polygon or text layer.

Usage:

- `connect_global(l, name)`

Example:

```ruby
connect(metal1, via1)
connect(via1, metal2)
```

### `connect_implicit`

Specifies a search pattern for implicit net connections ("must connect" nets)

This method specifies a net name search pattern, either for all cells or for certain cells, given by a name search pattern. Search pattern follow the usual glob form (e.g. "A*" for all cells or nets with names starting with "A").

Then, for nets matching the net name pattern and for which there is more than one subnet, the subnets are connected. "Subnets" are physically disconnected parts of a net which carry the same name.

Usage:

- `connect_implicit(label_pattern)`
- `connect_implicit(cell_pattern, label_pattern)`

Example:

```ruby
connect(metal1, via1)
connect(via1, metal2)
```

### `device_scaling`

Specifies a dimension scale factor for the geometrical device properties

Specifying a factor of 2 will make all devices being extracted as if the geometries were two times larger. This feature is useful when the drawn layout does not correspond to the physical dimensions.

Usage:

- `device_scaling(factor)`

Example:

```ruby
# Netter / connectivity
device_scaling
```

### `evaluate_nets`

Evaluates net properties and annotates shapes from a given layer on the nets

The function takes a primary layer and a number of secondary layers, each of them given a variable name. It visits each net and evaluates the given expression on the net. The expression needs to be written in KLayout expression notations.

The default action is to copy the shapes of the primary layer to the output. It is possible to customize the output further: you can conditionally skip the output or copy all shapes of the net from all layers the output. You can choose to emit individual polygons or merge all polygons from a net (all layers or a subset) into a single polygon. The latter is the default.

Usage:

- `evaluate_nets(primary_layer, secondary_layers, expression [, variables])`

Example:

```ruby
copy(net.name == "VDD")
```

```ruby
skip ; net.name == "VDD" && copy
```

```ruby
gate = ...   # a layer with the gate shapes
metal = ...  # a layer with metal shapes

# NOTE: 'MET' is the name we are going to use in the expression
antenna_errors = evaluate_nets(gate, { "MET" => metal }, "put('AR',area(MET)/area)")
```

### `extract_devices`

Extracts devices based on the given extractor class, name and device layer selection

Runs the device extraction for given device extractor class. In the first form, the extractor object is given. In the second form, the extractor's class object and the new extractor's name is given.

The device extractor is either an instance of one of the predefined extractor classes (e.g. obtained from the utility methods such as mos4) or a custom class. It provides the algorithms for deriving the device parameters from the device geometry. It needs several device recognition layers which are passed in the layer hash.

Usage:

- `extract_devices(extractor, layer_hash)`
- `extract_devices(extractor_class, name, layer_hash)`

Example:

```ruby
deep

nwell   = input(1, 0)
active  = input(2, 0)
poly    = input(3, 0)
bulk    = make_layer   # renders an empty layer used for putting the terminals on

nactive = active - nwell  # active area of NMOS
nsd     = nactive - poly  # source/drain area
gate    = nactive & poly  # gate area

extract_devices(mos4("NMOS4"), { :SD => nsd, :G => gate, :P => poly, :W => bulk })
```

### `ignore_extraction_errors`

Specifies whether to ignore extraction errors

With this value set to false (the default), "extract_netlist" will raise an exception upon extraction errors. Otherwise, extraction errors will be logged but no error is raised.

Usage:

- `ignore_extraction_errors(value)`

Example:

```ruby
# Netter / connectivity
ignore_extraction_errors
```

### `l2n_data`

Gets the internal LayoutToNetlist object

The LayoutToNetlist object provides access to the internal details of the netter object.

Usage:

- `l2n_data`

Example:

```ruby
# Netter / connectivity
l2n_data
```

### `name`

Assigns a name to a layer

Layer names are listed in the LayoutToNetlist (L2N) or LVS database. They are used to identify the layers, the net or device terminal geometries are on. It is usual to have computed layers, so it is necessary to indicate the purpose of the layer for later reuse of the geometries.

It is a good practice to assign names to computed and original layers, for example:

Usage:

- `name(layer, name)`
- `name(layer, name, layer_number, datatype_number)`
- `name(layer, name, layer_info)`

Example:

```ruby
poly = input(...)
poly_resistor = input(...)

poly_wiring = poly - poly_resistor
name(poly_wiring, "poly_wiring")
```

### `name_prefix`

Specifies the name prefix for auto-generated layer names

Usage:

- `name_prefix(prefix)`

Example:

```ruby
# Netter / connectivity
name_prefix
```

### `netlist`

Gets the extracted netlist or triggers extraction if not done yet

If no extraction has been performed yet, this method will start the layout analysis. Hence, all connect, connect_global and connect_implicit calls must have been made before this method is used. Further connect statements will clear the netlist and re-extract it again.

Usage:

- `netlist`

Example:

```ruby
nl = netlist
puts nl.circuits.size
```

### `soft_connect`

Specifies a soft connection between two layers

a and b must be polygon or text layers. After calling this function, the Netter considers shapes from layer a and b connected in "soft mode". Typically, b is a high-ohmic layer such as diffusion, implant for substate material, also called the "lower" layer.

A soft connection between shapes from layer a and b forms a directional connection like an ideal diode: current can flow down, but now up (not meant in the physical sense, this is a concept).

Usage:

- `soft_connect(a, b)`

Example:

```ruby
# Netter / connectivity
soft_connect
```

### `soft_connect_global`

Soft-connects a layer with a global net

Connects the shapes from the given layer l to a global net with the given name in "soft mode".

See connect_global for details about the concepts of global nets. See soft_connect for details about the concept of soft connections. In global net soft connections, the global net (typically a substrate) is always the "lower" layer.

Usage:

- `soft-connect_global(l, name)`

Example:

```ruby
# Netter / connectivity
soft_connect_global
```

### `top_level`

Specifies top level mode

With this value set to false (the default), it is assumed that the circuit is not used as a top level chip circuit. In that case, for example must-connect nets which are not connected are reported as as warnings. If top level mode is set to true, such disconnected nets are reported as errors as this indicates a missing physical connection.

Usage:

- `top_level(value)`

Example:

```ruby
# Netter / connectivity
top_level
```


---

## Universal `drc` expression operators / selectors

Used inside `layer.drc(expression)` (see `Layer#drc`).

| Command | Description |
|---|---|
| `!` | Logical not |
| `&` | Boolean AND between the results of two expressions |
| `+` | Boolean OR between the results of two expressions |
| `-` | Boolean NOT between the results of two expressions |
| `angle` | Selects edges based on their angle |
| `area` | Selects the primary shape if the area is meeting the condition |
| `area_ratio` | Selects the input polygon according to its area ratio (bounding box area by polygon area) |
| `area_sum` | Selects the input polygons if the sum of all areas meets the condition |
| `bbox_aspect_ratio` | Selects the input polygon according to the aspect ratio of the bounding box |
| `bbox_height` | Selects the input polygon if its bounding box height is meeting the condition |
| `bbox_max` | Selects the input polygon if its bounding box larger dimension is meeting the condition |
| `bbox_min` | Selects the input polygon if its bounding box smaller dimension is meeting the condition |
| `bbox_width` | Selects the input polygon if its bounding box width is meeting the condition |
| `centers` | Returns the part at the center of each edge of the input |
| `corners` | Selects corners of polygons |
| `count` | Selects a expression result based on the number of (local) shapes |
| `covering` | Selects shapes entirely covering other shapes |
| `edges` | Converts the input shapes into edges |
| `end_segments` | Returns the part at the end of each edge of the input |
| `extended` | Returns polygons describing an area along the edges of the input |
| `extended_in` | Returns polygons describing an area along the edges of the input |
| `extended_out` | Returns polygons describing an area along the edges of the input |
| `extent_refs` | Returns partial references to the bounding boxes of the polygons |
| `extents` | Returns the bounding box of each input object |
| `first_edges` | Returns the first edges of edge pairs |
| `holes` | Selects all holes from the input polygons |
| `hulls` | Selects all hulls from the input polygons |
| `inside` | Selects shapes entirely inside other shapes |
| `interacting` | Selects shapes interacting with other shapes |
| `length` | Selects edges based on their length |
| `length_sum` | Selects the input edges if the sum of their lengths meets the condition |
| `merged` | Returns the merged input polygons, optionally selecting multi-overlap |
| `middle` | Returns the centers of polygon bounding boxes |
| `outside` | Selects shapes entirely outside other shapes |
| `overlapping` | Selects shapes overlapping with other shapes |
| `perimeter` | Selects the input polygon if the perimeter is meeting the condition |
| `perimeter_sum` | Selects the input polygons if the sum of all perimeters meets the condition |
| `polygons` | Converts the input shapes into polygons |
| `rectangles` | Selects all polygons which are rectangles |
| `rectilinear` | Selects all polygons which are rectilinear |
| `relative_height` | Selects the input polygon according to the height vs. width of the bounding box |
| `rounded_corners` | Applies corner rounding |
| `second_edges` | Returns the second edges of edge pairs |
| `sized` | Returns the sized version of the input |
| `smoothed` | Applies smoothing |
| `squares` | Selects all polygons which are squares |
| `start_segments` | Returns the part at the beginning of each edge of the input |
| `with_holes` | Selects all input polygons with the specified number of holes |
| `|` | Boolean OR between the results of two expressions |

### Universal DRC details

### `!`

Logical not

This operator will evaluate the expression after. If this expression renders an empty result, the operator will return the primary shape. Otherwise it will return an empty result.

This operator can be used together with predicates such a "rectangles" to invert their meaning. For example, this code selects all primary shapes which are not rectangles:

Usage:

- `! expression`

Example:

```ruby
out = in.drc(! rectangles)
out = in.drc(! primary.rectangles)   # equivalent
```

### `&`

Boolean AND between the results of two expressions

The & operator will compute the boolean AND between the results of two expressions. The expression types need to be edge or polygon.

The following example computes the partial edges where width is less than 0.3 micrometers and space is less than 0.2 micrometers:

Usage:

- `expression & expression`

Example:

```ruby
out = in.drc((width < 0.3).edges & (space < 0.2).edges)
```

### `+`

Boolean OR between the results of two expressions

The + operator will join the results of two expressions.

Usage:

- `expression + expression`

Example:

```ruby
out = layer.drc(primary + secondary(other))
out.output("expr")
```

### `-`

Boolean NOT between the results of two expressions

The - operator will compute the difference between the results of two expressions. The NOT operation is defined for polygons, edges and polygons subtracted from edges (first argument edge, second argument polygon).

CAUTION: be careful not to take secondary input for the first argument. This will not render the desired results. Remember that the "drc" function will walk over all primary shapes and present single primaries to the NOT operation together with the secondaries of that single shape. So when you use secondary shapes as the first argument, they will not see all all the primaries required to compute the correct result. That's also why a XOR operation cannot be provided in the context of a generic DR…

Usage:

- `expression - expression`

Example:

```ruby
out = in.drc((width < 0.3).edges - secondary(waive))
```

### `angle`

Selects edges based on their angle

This operation selects edges by their angle, measured against the horizontal axis in the mathematical sense.

For this measurement edges are considered without their direction. A horizontal edge has an angle of zero degree. A vertical one has an angle of 90 degrees. The angle range is from -90 (exclusive) to 90 degree (inclusive).

Usage:

- `expression.angle (in condition)`
- `angle (in condition)`

Example:

```ruby
out = in.drc((angle == 45) + (angle == -45))
out = in.drc((primary.angle == 45) + (primary.angle == -45))    # equivalent
```

```ruby
out = in.drc(angle(absolute) == 45)
```

### `area`

Selects the primary shape if the area is meeting the condition

This operation is used in conditions to select shapes based on their area. It is applicable on polygon expressions. The result will be the input polygons if the area condition is met.

The following example will select all polygons with an area less than 2.0 square micrometers:

Usage:

- `expression.area (in condition)`
- `area (in condition)`
- `area(layer)`

Example:

```ruby
out = in.drc(area < 2.0)
out = in.drc(primary.area < 2.0)   # equivalent
```

### `area_ratio`

Selects the input polygon according to its area ratio (bounding box area by polygon area)

This operation is used in conditions to select shapes based on their area ratio. The area ratio is the ratio of bounding box vs. polygon area. It's a measure how "sparse" the polygons are and how good an approximation the bounding box is. The value is always larger or equal than 1. Boxes have a value of 1.

This filter is applicable on polygon expressions. The result will be the input polygon if the condition is met.

Usage:

- `expression.area_ratio (in condition)`
- `area_ratio (in condition)`

Example:

```ruby
out = in.drc(area_ratio > 3)
out = in.drc(primary.area_ratio > 3)   # equivalent
```

### `area_sum`

Selects the input polygons if the sum of all areas meets the condition

Returns the input polygons if the sum of their areas meets the specified condition. This condition is evaluated on the total of all shapes generated in one step of the "drc" loop. As there is a single primary in each loop iteration, "primary.area_sum" is equivalent to "primary.area".

Usage:

- `expression.area_sum (in condition)`

Example:

```ruby
layer = input(1, 0)
out = layer.drc(area_sum)
out.output("univ_area_sum")
```

### `bbox_aspect_ratio`

Selects the input polygon according to the aspect ratio of the bounding box

This operation is used in conditions to select shapes based on aspect ratios of their bounding boxes. The aspect ratio is computed by dividing the larger of width and height by the smaller of both. The aspect ratio is always larger or equal to 1. Square or square-boxed shapes have a bounding box aspect ratio of 1.

This filter is applicable on polygon expressions. The result will be the input polygon if the bounding box condition is met.

Usage:

- `expression.bbox_aspect_ratio (in condition)`
- `bbox_aspect_ratio (in condition)`

Example:

```ruby
out = in.drc(bbox_aspect_ratio > 3)
out = in.drc(primary.bbox_aspect_ratio > 3)   # equivalent
```

### `bbox_height`

Selects the input polygon if its bounding box height is meeting the condition

This operation acts similar to DRC#bbox_min, but takes the height of the shape's bounding box. In general, it's more advisable to use DRC#bbox_min or DRC#bbox_max because bbox_height implies a certain orientation. This can imply variant formation in hierarchical contexts: cells rotated by 90 degree have to be treated differently from ones not rotated. This usually results in a larger computation effort and larger result files.

The "bbox_height" method is available as a plain function or as a method on DRC expressions. The plain function is equivalent to "primary.bbox_height".

Usage:

- `expression.bbox_height (in condition)`
- `bbox_height (in condition)`

Example:

```ruby
layer = input(1, 0)
out = layer.drc(bbox_height > 2.0)
out.output("select")
```

### `bbox_max`

Selects the input polygon if its bounding box larger dimension is meeting the condition

This operation acts similar to DRC#bbox_min, but takes the larger dimension of the shape's bounding box.

The "bbox_max" method is available as a plain function or as a method on DRC expressions. The plain function is equivalent to "primary.bbox_max".

Usage:

- `expression.bbox_max (in condition)`
- `bbox_max (in condition)`

Example:

```ruby
layer = input(1, 0)
out = layer.drc(bbox_max > 2.0)
out.output("select")
```

### `bbox_min`

Selects the input polygon if its bounding box smaller dimension is meeting the condition

This operation is used in conditions to select shapes based on smaller dimension of their bounding boxes. It is applicable on polygon expressions. The result will be the input polygons if the bounding box condition is met.

The following example will select all polygons whose bounding box smaller dimension is larger than 200 nm:

Usage:

- `expression.bbox_min (in condition)`
- `bbox_max (in condition)`

Example:

```ruby
out = in.drc(bbox_min > 200.nm)
out = in.drc(primary.bbox_min > 200.nm)   # equivalent
```

### `bbox_width`

Selects the input polygon if its bounding box width is meeting the condition

This operation acts similar to DRC#bbox_min, but takes the width of the shape's bounding box. In general, it's more advisable to use DRC#bbox_min or DRC#bbox_max because bbox_width implies a certain orientation. This can imply variant formation in hierarchical contexts: cells rotated by 90 degree have to be treated differently from ones not rotated. This usually results in a larger computation effort and larger result files.

The "bbox_width" method is available as a plain function or as a method on DRC expressions. The plain function is equivalent to "primary.bbox_width".

Usage:

- `expression.bbox_width (in condition)`
- `bbox_max (in condition)`

Example:

```ruby
layer = input(1, 0)
out = layer.drc(bbox_width > 2.0)
out.output("select")
```

### `centers`

Returns the part at the center of each edge of the input

This method acts on edge expressions and delivers a specific part of each edge. See layer#centers for details about this functionality.

Usage:

- `expression.centers(length)`
- `expression.end_segments(length, fraction)`

Example:

```ruby
layer = input(1, 0)
out = layer.drc(centers)
out.output("univ_centers")
```

### `corners`

Selects corners of polygons

This operation acts on polygons and selects the corners of the polygons. It can be put into a condition to select corners by their angles. The angle of a corner is positive for a turn to the left if walking a polygon clockwise and negative for the turn to the right. Hence positive angles indicate concave (inner) corners, negative ones indicate convex (outer) corners. Angles take values between -180 and 180 degree.

When using "as_dots" for an option, the operation will return single-point edges at the selected corners. With "as_boxes" (the default), small (2x2 DBU) rectangles will be produced at each selected corner.

Usage:

- `expression.corners`
- `expression.corners([ options ])`
- `corners([ options ]) (in condition)`
- `corners(layer [, options ])`

Example:

```ruby
corners(as_dots)
corners(as_boxes, absolute)
```

```ruby
out = in.drc(corners)
out = in.drc(primary.corners)    # equivalent
```

```ruby
out = in.drc(corners > 0)
out = in.drc(primary.corners > 0)    # equivalent
```

### `count`

Selects a expression result based on the number of (local) shapes

This operation is used in conditions to select expression results based on their count. "count" is used as a method on a expression. It will evaluate the expression locally and return the original result if the shape count in the result is matching the condition.

Note that the expression is evaluated locally: for each primary shape, the expression is evaluated and the count of the resulting edge, edge pair or polygon set is taken. As the primary input will always have a single item (the local shape), using "count" on primary does not really make sense. It can be used on derived expressions however.

Usage:

- `expression.count (in condition)`

Example:

```ruby
out = in.drc(if_any(corners.count == 3))
```

### `covering`

Selects shapes entirely covering other shapes

This method represents the selector of primary shapes which entirely cover shapes from the other layer. This version can be put into a condition indicating how many shapes of the other layer need to be covered. Use this variant within DRC expressions (also see Layer#drc).

For example, the following statement selects all input shapes which entirely cover shapes from the "other" layer:

Usage:

- `expression.covering(other) (optionally in conditions)`
- `covering(other) (optionally in conditions)`
- `covering(other) (optionally in condition)`

Example:

```ruby
out = in.drc(covering(other))
```

```ruby
out = in.drc(covering(other) > 2)
```

### `edges`

Converts the input shapes into edges

Polygons will be separated into edges forming their contours. Edge pairs will be decomposed into individual edges.

Contrary most other operations, "edges" does not have a plain function equivalent as this is reserved for the function generating an edges layer. To generate the edges of the primary shapes, use "primary" explicit as the source for the edges:

Usage:

- `expression.edges`
- `expression.edges(mode)`

Example:

```ruby
out = in.drc(primary.edges)
```

```ruby
out = in.drc(primary.edges(convex))
```

```ruby
out = in.drc(primary.edges(not_convex))
```

### `end_segments`

Returns the part at the end of each edge of the input

This method acts on edge expressions and delivers a specific part of each edge. See layer#end_segments for details about this functionality.

Usage:

- `expression.end_segments(length)`
- `expression.end_segments(length, fraction)`

Example:

```ruby
layer = input(1, 0)
out = layer.drc(end_segments)
out.output("univ_end_segments")
```

### `extended`

Returns polygons describing an area along the edges of the input

This method acts on edge expressions. It will create a polygon for each edge tracing the edge with certain offsets to the edge. "o" is the offset applied to the outer side of the edge, "i" is the offset applied to the inner side of the edge. "b" is the offset applied at the beginning and "e" is the offset applied at the end.

Usage:

- `expression.extended([:begin => b,] [:end => e,] [:out => o,] [:in => i], [:joined => true])`
- `expression.extended(b, e, o, i)`

Example:

```ruby
layer = input(1, 0)
out = layer.drc(extended)
out.output("univ_extended")
```

### `extended_in`

Returns polygons describing an area along the edges of the input

This method acts on edge expressions. Polygons are generated for each edge describing the edge drawn with a certain width extending into the "inside" (the right side when looking from start to end). This method is basically equivalent to the extended method: "extended(0, 0, 0, dist)". A version extending to the outside is extended_out.

Usage:

- `expression.extended_in(d)`

Example:

```ruby
layer = input(1, 0)
out = layer.drc(extended_in)
out.output("univ_extended_in")
```

### `extended_out`

Returns polygons describing an area along the edges of the input

This method acts on edge expressions. Polygons are generated for each edge describing the edge drawn with a certain width extending into the "outside" (the left side when looking from start to end). This method is basically equivalent to the extended method: "extended(0, 0, dist, 0)". A version extending to the inside is extended_in.

Usage:

- `expression.extended_out(d)`

Example:

```ruby
layer = input(1, 0)
out = layer.drc(extended_out)
out.output("univ_extended_out")
```

### `extent_refs`

Returns partial references to the bounding boxes of the polygons

The extent_refs operation acts on polygons and has the same effect than Layer#extent_refs. It takes the same arguments. It is available as a method on DRC expressions or as plain function, in which case it acts on the primary shapes.

Usage:

- `expression.extent_refs([ options ])`
- `extent_refs([ options ])`
- `extent_refs(layer, [ options ])`

Example:

```ruby
layer = input(1, 0)
out = layer.drc(extent_refs)
out.output("univ_extent_refs")
```

### `extents`

Returns the bounding box of each input object

This method provides the same functionality as Layer#extents and takes the same arguments. It returns the bounding boxes of the input objects. It acts on edge edge pair and polygon expressions.

The "extents" method is available as a plain function or as a method on DRC expressions. The plain function is equivalent to "primary.extents".

Usage:

- `expression.extents([ enlargement ])`
- `extents([ enlargement ])`
- `extents(layer, [ enlargement ])`

Example:

```ruby
layer = input(1, 0)
out = layer.drc(extents)
out.output("univ_extents")
```

### `first_edges`

Returns the first edges of edge pairs

This method acts on edge pair expressions and returns the first edges of the edge pairs delivered by the expression.

Some checks deliver symmetric edge pairs (e.g. space, width, etc.) for which the edges are commutable. "first_edges" will deliver both edges for such edge pairs.

Usage:

- `expression.first_edges`

Example:

```ruby
layer = input(1, 0)
out = layer.drc(first_edges)
out.output("univ_first_edges")
```

### `holes`

Selects all holes from the input polygons

This operation can be used as a plain function in which case it acts on primary shapes or can be used as method on another DRC expression. The following example selects all holes with an area larger than 2 square micrometers:

out = in.drc(holes.area > 2.um) out = in.drc(primary.holes.area > 2.um) # equivalent

Usage:

- `expression.holes`
- `holes`
- `holes(layer)`

Example:

```ruby
out = in.drc(holes.area > 2.um)
out = in.drc(primary.holes.area > 2.um)   # equivalent
```

### `hulls`

Selects all hulls from the input polygons

The hulls are the outer contours of the input polygons. By selecting hulls only, all holes will be closed.

This operation can be used as a plain function in which case it acts on primary shapes or can be used as method on another DRC expression. The following example closes all holes:

Usage:

- `expression.hulls`
- `hulls`
- `hulls(layer)`

Example:

```ruby
out = in.drc(hulls)
out = in.drc(primary.hulls)   # equivalent
```

### `inside`

Selects shapes entirely inside other shapes

This method represents the selector of primary shapes which are entirely inside shapes from the other layer. Use this variant within DRC expressions (also see Layer#drc).

Usage:

- `expression.inside(other)`
- `inside(other)`

Example:

```ruby
layer = input(1, 0)
out = layer.drc(inside)
out.output("univ_inside")
```

### `interacting`

Selects shapes interacting with other shapes

See covering for a description of the use cases for this function. When using "interacting", shapes are selected when the interact (overlap, touch) shapes from the other layer.

When using this method with a count, the operation may not render the correct results if the other input is not merged. By nature of the generic DRC feature, only those shapes that interact with the primary shape will be selected. If the other input is split into multiple polygons, not all components may be captured and the computed interaction count may be incorrect.

Usage:

- `expression.interacting(other) (optionally in conditions)`
- `interacting(other) (optionally in conditions)`
- `interacting(other) (optionally in condition)`

Example:

```ruby
layer = input(1, 0)
out = layer.drc(interacting)
out.output("univ_interacting")
```

### `length`

Selects edges based on their length

This operation will select those edges which are meeting the length criterion. Non-edge shapes (polygons, edge pairs) will be converted to edges before.

For example, this code selects all edges from the primary shape which are longer or equal than 1 micrometer:

Usage:

- `expression.length (in condition)`
- `length (in condition)`
- `length(layer)`

Example:

```ruby
out = in.drc(length >= 1.um)
out = in.drc(primary.length >= 1.um)   # equivalent
```

### `length_sum`

Selects the input edges if the sum of their lengths meets the condition

Returns the input edges if the sum of their lengths meets the specified condition. This condition is evaluated on the total of all edges generated in one step of the "drc" loop.

Usage:

- `expression.length_sum (in condition)`

Example:

```ruby
layer = input(1, 0)
out = layer.drc(length_sum)
out.output("univ_length_sum")
```

### `merged`

Returns the merged input polygons, optionally selecting multi-overlap

This operation will act on polygons. Without a min_count argument, the merged polygons will be returned.

With a min_count argument, the result will include only those parts where more than the given number of polygons overlap. As the primary input is merged already, it will always contribute as one.

Usage:

- `expression.merged`
- `expression.merged(min_count)`

Example:

```ruby
layer = input(1, 0)
out = layer.drc(merged)
out.output("univ_merged")
```

### `middle`

Returns the centers of polygon bounding boxes

The middle operation acts on polygons and has the same effect than Layer#middle. It takes the same arguments. It is available as a method on DRC expressions or as plain function, in which case it acts on the primary shapes.

Usage:

- `expression.middle([ options ])`
- `middle([ options ])`
- `middle(layer, [ options ])`

Example:

```ruby
layer = input(1, 0)
out = layer.drc(middle)
out.output("univ_middle")
```

### `outside`

Selects shapes entirely outside other shapes

This method represents the selector of primary shapes which are entirely outside shapes from the other layer. Use this variant within DRC expressions (also see Layer#drc).

Usage:

- `expression.outside(other)`
- `outside(other)`

Example:

```ruby
layer = input(1, 0)
out = layer.drc(outside)
out.output("univ_outside")
```

### `overlapping`

Selects shapes overlapping with other shapes

See covering for a description of the use cases for this function. When using "overlapping", shapes are selected when the overlap shapes from the other layer.

When using this method with a count, the operation may not render the correct results if the other input is not merged. By nature of the generic DRC feature, only those shapes that interact with the primary shape will be selected. If the other input is split into multiple polygons, not all components may be captured and the computed interaction count may be incorrect.

Usage:

- `expression.overlapping(other) (optionally in conditions)`
- `overlapping(other) (optionally in conditions)`
- `overlapping(other) (optionally in condition)`

Example:

```ruby
layer = input(1, 0)
out = layer.drc(overlapping)
out.output("univ_overlapping")
```

### `perimeter`

Selects the input polygon if the perimeter is meeting the condition

This operation is used in conditions to select shapes based on their perimeter. It is applicable on polygon expressions. The result will be the input polygons if the perimeter condition is met.

The following example will select all polygons with a perimeter less than 10 micrometers:

Usage:

- `expression.perimeter (in condition)`
- `perimeter (in condition)`
- `perimeter(layer)`

Example:

```ruby
out = in.drc(perimeter < 10.0)
out = in.drc(primary.perimeter < 10.0)   # equivalent
```

### `perimeter_sum`

Selects the input polygons if the sum of all perimeters meets the condition

Returns the input polygons if the sum of their perimeters meets the specified condition. This condition is evaluated on the total of all shapes generated in one step of the "drc" loop. As there is a single primary in each loop iteration, "primary.perimeter_sum" is equivalent to "primary.perimeter".

Usage:

- `expression.perimeter_sum (in condition)`

Example:

```ruby
layer = input(1, 0)
out = layer.drc(perimeter_sum)
out.output("univ_perimeter_sum")
```

### `polygons`

Converts the input shapes into polygons

Generates polygons from the input shapes. Polygons stay polygons. Edges and edge pairs are converted to polygons. For this, the enlargement parameter will specify the edge thickness or augmentation applied to edge pairs. With the default enlargement of zero edges will not be converted to valid polygons and degenerated edge pairs will not become valid polygons as well.

Contrary most other operations, "polygons" does not have a plain function equivalent as this is reserved for the function generating a polygon layer.

Usage:

- `expression.polygons([ enlargement ])`

Example:

```ruby
out = in.drc((width < 0.5.um).polygons)
```

### `rectangles`

Selects all polygons which are rectangles

This operation can be used as a plain function in which case it acts on primary shapes or can be used as method on another DRC expression. The following example selects all rectangles:

out = in.drc(rectangles) out = in.drc(primary.rectangles) # equivalent

Usage:

- `expression.rectangles`
- `rectangles`
- `rectangles(layer)`

Example:

```ruby
out = in.drc(rectangles)
out = in.drc(primary.rectangles)    # equivalent
```

### `rectilinear`

Selects all polygons which are rectilinear

Rectilinear polygons only have vertical and horizontal edges. Such polygons are also called manhattan polygons.

This operation can be used as a plain function in which case it acts on primary shapes or can be used as method on another DRC expression. The following example selects all manhattan polygons:

Usage:

- `expression.rectilinear`
- `rectilinear`
- `rectilinear(layer)`

Example:

```ruby
out = in.drc(rectilinear)
out = in.drc(primary.rectilinear)    # equivalent
```

### `relative_height`

Selects the input polygon according to the height vs. width of the bounding box

This operation is used in conditions to select shapes based on the ratio of bounding box height vs. width. The taller the shape, the larger the value. Wide polygons have a value below 1. A square has a relative height of 1.

This filter is applicable on polygon expressions. The result will be the input polygon if the condition is met.

Usage:

- `expression.relative_height (in condition)`
- `relative_height (in condition)`

Example:

```ruby
out = in.drc(relative_height > 3)
out = in.drc(primary.relative_height > 3)   # equivalent
```

### `rounded_corners`

Applies corner rounding

This operation acts on polygons and applies corner rounding to the given inner and outer corner radius and the number of points n per full circle. See Layer#rounded_corners for more details.

The "rounded_corners" method is available as a plain function or as a method on DRC expressions. The plain function is equivalent to "primary.rounded_corners".

Usage:

- `expression.rounded_corners(inner, outer, n)`
- `rounded_corners(inner, outer, n)`
- `rounded_corners(layer, inner, outer, n)`

Example:

```ruby
layer = input(1, 0)
out = layer.drc(rounded_corners)
out.output("univ_rounded_corners")
```

### `second_edges`

Returns the second edges of edge pairs

This method acts on edge pair expressions and returns the second edges of the edge pairs delivered by the expression.

Some checks deliver symmetric edge pairs (e.g. space, width, etc.) for which the edges are commutable. "second_edges" will not deliver edges for such edge pairs. Instead, "first_edges" will deliver both.

Usage:

- `expression.second_edges`

Example:

```ruby
layer = input(1, 0)
out = layer.drc(second_edges)
out.output("univ_second_edges")
```

### `sized`

Returns the sized version of the input

This method provides the same functionality as Layer#sized and takes the same arguments. It acts on polygon expressions.

The "sized" method is available as a plain function or as a method on DRC expressions. The plain function is equivalent to "primary.sized".

Usage:

- `expression.sized(d [, mode])`
- `expression.sized(dx, dy [, mode]))`
- `sized(d [, mode])`
- `sized(dx, dy [, mode]))`
- `sized(layer, d [, mode])`
- `sized(layer, dx, dy [, mode]))`

Example:

```ruby
layer = input(1, 0)
out = layer.drc(sized)
out.output("univ_sized")
```

### `smoothed`

Applies smoothing

This operation acts on polygons and applies polygon smoothing with the tolerance d. 'keep_hv' indicates whether horizontal and vertical edges are maintained. Default is 'no' which means such edges may be distorted. See Layer#smoothed for more details.

The "smoothed" method is available as a plain function or as a method on DRC expressions. The plain function is equivalent to "primary.smoothed".

Usage:

- `expression.smoothed(d [, keep_hv ])`
- `smoothed(d)`
- `smoothed(layer, d)`

Example:

```ruby
layer = input(1, 0)
out = layer.drc(smoothed)
out.output("univ_smoothed")
```

### `squares`

Selects all polygons which are squares

This operation can be used as a plain function in which case it acts on primary shapes or can be used as method on another DRC expression. The following example selects all squares:

out = in.drc(squares) out = in.drc(primary.squares) # equivalent

Usage:

- `expression.squares`
- `squares`
- `squares(layer)`

Example:

```ruby
out = in.drc(squares)
out = in.drc(primary.squares)    # equivalent
```

### `start_segments`

Returns the part at the beginning of each edge of the input

This method acts on edge expressions and delivers a specific part of each edge. See layer#start_segments for details about this functionality.

Usage:

- `expression.start_segments(length)`
- `expression.start_segments(length, fraction)`

Example:

```ruby
layer = input(1, 0)
out = layer.drc(start_segments)
out.output("univ_start_segments")
```

### `with_holes`

Selects all input polygons with the specified number of holes

This operation can be used as a plain function in which case it acts on primary shapes or can be used as method on another DRC expression. The following example selects all polygons with more than 2 holes:

out = in.drc(with_holes > 2) out = in.drc(primary.with_holes > 2) # equivalent

Usage:

- `expression.with_holes (in condition)`
- `with_holes (in condition)`

Example:

```ruby
out = in.drc(with_holes > 2)
out = in.drc(primary.with_holes > 2)   # equivalent
```

### `|`

Boolean OR between the results of two expressions

The | operator will compute the boolean OR between the results of two expressions. '+' is basically a synonym. Both expressions must render the same type.

Usage:

- `expression | expression`

Example:

```ruby
out = layer.drc(primary | secondary(other))
out.output("expr")
```

