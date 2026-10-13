# KLayout PEX Commands

Extracted from KLayout official DRC/LVS reference HTML and built-in macros (KLayout 0.30.2+). Every command includes Usage plus an Example (preferring official doc samples; otherwise a minimal illustrative snippet).

Built-in **resistance** parasitic extraction API: Python `klayout.pex` / Ruby module `pex` (`libklayout_pex`, since 0.30.2).

> [KLayout-PEX (`kpex`)](https://iic-jku.github.io/klayout-pex-website/doc/doc.html) is a separate flow (full parasitic **C/CC**). This file covers the **built-in `pex` module** (R-only) only. For a runnable sky130A sidewall **CC** demo, see [`../pex/`](../pex/) (`./run_kpex.sh`).

**API coverage:** 8 classes · 2 enums · 60 methods (with examples).

---

## Module overview

| Class / type | Description |
|---|---|
| `RExtractor` | The basic R extractor class |
| `RExtractorTechVia` | Describes a via for the network extraction. |
| `RExtractorTechConductor` | Describes a conductor layer for the network extraction. |
| `RExtractorTech` | Specifies the tech stack for the R extraction. |
| `RNetExtractor` | The network R extractor class |
| `RNode` | Represents a node in a R network graph |
| `RElement` | Represents an edge (also called element) in a R network graph |
| `RNetwork` | Represents a network of resistors |
| `Algorithm` (enum) | This enum represents the extraction algorithm for \\RExtractorTechConductor. |
| `RNodeType` (enum) | This class represents the node type for RNode. |

---

## `RExtractor`

The basic R extractor class

| Command | Kind | Description |
|---|---|---|
| `square_counting_extractor` | constructor | Creates a square counting R extractor |
| `tesselation_extractor` | constructor | Creates a tesselation R extractor |
| `extract` | factory_ext | Runs the extraction on the given polygon |

### `square_counting_extractor`

Creates a square counting R extractor

Usage:

- `square_counting_extractor(dbu, skip_simplify)`

Example:

```ruby
poly = RBA::Polygon::new(RBA::Box::new(0, 0, 1100, 100))
vp = [ RBA::Point::new(50, 50) ]
pp = [ RBA::Polygon::new(RBA::Box::new(1000, 0, 1100, 100)) ]
rex = RBA::RExtractor::square_counting_extractor(0.001)
network = rex.extract(poly, vp, pp)
puts network.to_s
```

### `tesselation_extractor`

Creates a tesselation R extractor

Usage:

- `tesselation_extractor(dbu, min_b, max_area, skip_reduction)`

Example:

```ruby
poly = RBA::Polygon::new(RBA::Box::new(0, 0, 1100, 100))
vp = [ RBA::Point::new(50, 50) ]
pp = [ RBA::Polygon::new(RBA::Box::new(1000, 0, 1100, 100)) ]
rex = RBA::RExtractor::tesselation_extractor(0.001, 0.8)
network = rex.extract(poly, vp, pp)
```

### `extract`

Runs the extraction on the given polygon

Usage:

- `extract(polygon, vertex_ports, polygon_ports)`

Example:

```ruby
rex = RBA::RExtractor::square_counting_extractor(0.001)
network = rex.extract(polygon, vertex_ports, polygon_ports)
```


## `RExtractorTechVia`

Describes a via for the network extraction.

| Command | Kind | Description |
|---|---|---|
| `to_s` | method | Returns a string describing this object |
| `merge_distance` | method_ext | Gets the merge distance |
| `merge_distance=` | method_ext | Sets the merge distance |
| `resistance` | method_ext | Gets the area resistance value of the vias |
| `resistance=` | method_ext | Sets the via area resistance value |
| `bottom_conductor` | method_ext | Gets the bottom conductor layer index |
| `bottom_conductor=` | method_ext | Sets the via bottom conductor layer index |
| `cut_layer` | method_ext | Gets the cut layer index |
| `cut_layer=` | method_ext | Sets the cut layer index |
| `top_conductor` | method_ext | Gets the top conductor layer index |
| `top_conductor=` | method_ext | Sets the via top conductor layer index |

### `to_s`

Returns a string describing this object

Example:

```ruby
puts obj.to_s
```

### `merge_distance`

Gets the merge distance

Example:

```ruby
obj.merge_distance
```

### `merge_distance=`

Sets the merge distance

Usage:

- `merge_distance(d)`

Example:

```ruby
obj.merge_distance = value
```

### `resistance`

Gets the area resistance value of the vias

Example:

```ruby
obj.resistance
```

### `resistance=`

Sets the via area resistance value

Usage:

- `resistance(d)`

Example:

```ruby
obj.resistance = value
```

### `bottom_conductor`

Gets the bottom conductor layer index

Example:

```ruby
obj.bottom_conductor
```

### `bottom_conductor=`

Sets the via bottom conductor layer index

Usage:

- `bottom_conductor(l)`

Example:

```ruby
obj.bottom_conductor = value
```

### `cut_layer`

Gets the cut layer index

Example:

```ruby
obj.cut_layer
```

### `cut_layer=`

Sets the cut layer index

Usage:

- `cut_layer(l)`

Example:

```ruby
obj.cut_layer = value
```

### `top_conductor`

Gets the top conductor layer index

Example:

```ruby
obj.top_conductor
```

### `top_conductor=`

Sets the via top conductor layer index

Usage:

- `top_conductor(l)`

Example:

```ruby
obj.top_conductor = value
```


## `RExtractorTechConductor`

Describes a conductor layer for the network extraction.

| Command | Kind | Description |
|---|---|---|
| `to_s` | method | Returns a string describing this object |
| `algorithm` | method_ext | Gets the algorithm to use |
| `algorithm=` | method_ext | Sets the algorithm to use |
| `resistance` | method_ext | Gets the sheet resistance value of the conductor layer |
| `resistance=` | method_ext | Sets the sheet resistance value of the conductor layer |
| `layer` | method_ext | Gets the layer index |
| `layer=` | method_ext | Sets the layer index |
| `triangulation_min_b` | method_ext | Gets the triangulation 'min_b' parameter |
| `triangulation_min_b=` | method_ext | Sets the triangulation 'min_b' parameter |
| `triangulation_max_area` | method_ext | Gets the triangulation 'max_area' parameter |
| `triangulation_max_area=` | method_ext | Sets the triangulation 'max_area' parameter |

### `to_s`

Returns a string describing this object

Example:

```ruby
puts obj.to_s
```

### `algorithm`

Gets the algorithm to use

Example:

```ruby
obj.algorithm
```

### `algorithm=`

Sets the algorithm to use

Usage:

- `algorithm(d)`

Example:

```ruby
obj.algorithm = value
```

### `resistance`

Gets the sheet resistance value of the conductor layer

Example:

```ruby
obj.resistance
```

### `resistance=`

Sets the sheet resistance value of the conductor layer

Usage:

- `resistance(r)`

Example:

```ruby
obj.resistance = value
```

### `layer`

Gets the layer index

Example:

```ruby
obj.layer
```

### `layer=`

Sets the layer index

Usage:

- `layer(l)`

Example:

```ruby
obj.layer = value
```

### `triangulation_min_b`

Gets the triangulation 'min_b' parameter

Example:

```ruby
obj.triangulation_min_b
```

### `triangulation_min_b=`

Sets the triangulation 'min_b' parameter

Usage:

- `triangulation_min_b(min_b)`

Example:

```ruby
obj.triangulation_min_b = value
```

### `triangulation_max_area`

Gets the triangulation 'max_area' parameter

Example:

```ruby
obj.triangulation_max_area
```

### `triangulation_max_area=`

Sets the triangulation 'max_area' parameter

Usage:

- `triangulation_max_area(max_area)`

Example:

```ruby
obj.triangulation_max_area = value
```


## `RExtractorTech`

Specifies the tech stack for the R extraction.

| Command | Kind | Description |
|---|---|---|
| `to_s` | method | Returns a string describing this object |
| `skip_simplify` | method_ext | Gets a value indicating whether to skip the simplify step |
| `skip_simplify=` | method_ext | Sets a value indicating whether to skip the simplify step |
| `each_via` | iterator_ext | Iterates the list of via definitions |
| `clear_vias` | method_ext | Clears the list of via definitions |
| `add_via` | method_ext | Adds the given via definition to the list of vias |
| `each_conductor` | iterator_ext | Iterates the list of conductor definitions |
| `clear_conductors` | method_ext | Clears the list of conductor definitions |
| `add_conductor` | method_ext | Adds the given conductor definition to the list of conductors |

### `to_s`

Returns a string describing this object

Example:

```ruby
puts obj.to_s
```

### `skip_simplify`

Gets a value indicating whether to skip the simplify step

Example:

```ruby
obj.skip_simplify
```

### `skip_simplify=`

Sets a value indicating whether to skip the simplify step

Usage:

- `skip_simplify(f)`

Example:

```ruby
obj.skip_simplify = value
```

### `each_via`

Iterates the list of via definitions

Example:

```ruby
obj.each_via do |item|
  puts item
end
```

### `clear_vias`

Clears the list of via definitions

Example:

```ruby
obj.clear_vias
```

### `add_via`

Adds the given via definition to the list of vias

Usage:

- `add_via(via)`

Example:

```ruby
via = RBA::RExtractorTechVia::new
via.bottom_conductor = 1
via.cut_layer = 2
via.top_conductor = 3
via.resistance = 2.0  # Ohm * um^2
tech.add_via(via)
```

### `each_conductor`

Iterates the list of conductor definitions

Example:

```ruby
obj.each_conductor do |item|
  puts item
end
```

### `clear_conductors`

Clears the list of conductor definitions

Example:

```ruby
obj.clear_conductors
```

### `add_conductor`

Adds the given conductor definition to the list of conductors

Usage:

- `add_conductor(conductor)`

Example:

```ruby
tech = RBA::RExtractorTech::new
c = RBA::RExtractorTechConductor::new
c.layer = 1
c.resistance = 0.08  # Ohm/square
c.algorithm = RBA::RExtractorTechConductor::SquareCounting
tech.add_conductor(c)
```


## `RNetExtractor`

The network R extractor class

| Command | Kind | Description |
|---|---|---|
| `new` | constructor | Creates a network R extractor |
| `extract` | factory_ext | Runs the extraction on the given multi-layer geometry |

### `new`

Creates a network R extractor

Usage:

- `new(dbu)`

Example:

```ruby
rex = RBA::RNetExtractor::new(0.001)  # dbu in µm
```

### `extract`

Runs the extraction on the given multi-layer geometry

Usage:

- `extract(tech_stack, geo, vertex_ports, polygon_ports)`

Example:

```ruby
tech = RBA::RExtractorTech::new
# tech.add_conductor(...); tech.add_via(...)
rex = RBA::RNetExtractor::new(0.001)
network = rex.extract(tech, geo, vertex_ports, polygon_ports)
network.simplify
```


## `RNode`

Represents a node in a R network graph

| Command | Kind | Description |
|---|---|---|
| `object_id` | method | Returns an ID representing the actual object |
| `to_s` | method | Returns a string representation of this object |
| `each_element` | iterator_ext | Iterates the \\RElement objects attached to the node |
| `type` | method | Gets the type attribute of the node |
| `location` | method | Gets the location attribute of the node |
| `port_index` | method | Gets the port index of the node |
| `layer` | method | Gets the Layer ID of the node |

### `object_id`

Returns an ID representing the actual object

Example:

```ruby
obj.object_id
```

### `to_s`

Returns a string representation of this object

Usage:

- `to_s(with_coords)`

Example:

```ruby
puts node.to_s
puts node.to_s(true)
```

### `each_element`

Iterates the \\RElement objects attached to the node

Example:

```ruby
obj.each_element do |item|
  puts item
end
```

### `type`

Gets the type attribute of the node

Example:

```ruby
obj.type
```

### `location`

Gets the location attribute of the node

Example:

```ruby
obj.location
```

### `port_index`

Gets the port index of the node

Example:

```ruby
obj.port_index
```

### `layer`

Gets the Layer ID of the node

Example:

```ruby
obj.layer
```


## `RElement`

Represents an edge (also called element) in a R network graph

| Command | Kind | Description |
|---|---|---|
| `object_id` | method | Returns an ID representing the actual object |
| `to_s` | method | Returns a string representation of this object |
| `resistance` | method | Gets the resistance value of the object |
| `a` | factory | Gets the first node the element connects |
| `b` | factory | Gets the second node the element connects |

### `object_id`

Returns an ID representing the actual object

Example:

```ruby
obj.object_id
```

### `to_s`

Returns a string representation of this object

Usage:

- `to_s(with_coords)`

Example:

```ruby
puts obj.to_s
```

### `resistance`

Gets the resistance value of the object

Example:

```ruby
puts element.resistance
```

### `a`

Gets the first node the element connects

Example:

```ruby
n1 = element.a
n2 = element.b
```

### `b`

Gets the second node the element connects

Example:

```ruby
obj.b
```


## `RNetwork`

Represents a network of resistors

| Command | Kind | Description |
|---|---|---|
| `create_node` | factory_ext | Creates a new node with the given type and index'. |
| `create_element` | factory_ext | Creates a new element between the nodes given by 'a' abd 'b'. |
| `remove_element` | method_ext | Removes the given element |
| `remove_node` | method_ext | Removes the given node |
| `clear` | method | Clears the network |
| `simplify` | method | Simplifies the network |
| `each_element` | iterator_ext | Iterates the \\RElement objects inside the network |
| `each_node` | iterator_ext | Iterates the \\RNode objects inside the network |
| `num_nodes` | method | Gets the total number of nodes in the network |
| `num_internal_nodes` | method | Gets the number of internal nodes in the network |
| `num_elements` | method | Gets the number of elements in the network |
| `to_s` | method | Returns a string representation of the network |

### `create_node`

Creates a new node with the given type and index'.

Usage:

- `create_node(type, port_index, layer)`

Example:

```ruby
rn = RBA::RNetwork::new
a = rn.create_node(RBA::RNodeType::VertexPort, 1)
b = rn.create_node(RBA::RNodeType::Internal, 2)
c = rn.create_node(RBA::RNodeType::PolygonPort, 3)
```

### `create_element`

Creates a new element between the nodes given by 'a' abd 'b'.

Usage:

- `create_element(resistance, a, b)`

Example:

```ruby
rn = RBA::RNetwork::new
a = rn.create_node(RBA::RNodeType::VertexPort, 1)
b = rn.create_node(RBA::RNodeType::Internal, 2)
rab = rn.create_element(1.0, a, b)  # conductance
```

### `remove_element`

Removes the given element

Usage:

- `remove_element(element)`

Example:

```ruby
obj.remove_element(element)
```

### `remove_node`

Removes the given node

Usage:

- `remove_node(node)`

Example:

```ruby
obj.remove_node(node)
```

### `clear`

Clears the network

Example:

```ruby
network.clear
```

### `simplify`

Simplifies the network

Example:

```ruby
network.simplify
puts network.to_s
```

### `each_element`

Iterates the \\RElement objects inside the network

Example:

```ruby
obj.each_element do |item|
  puts item
end
```

### `each_node`

Iterates the \\RNode objects inside the network

Example:

```ruby
obj.each_node do |item|
  puts item
end
```

### `num_nodes`

Gets the total number of nodes in the network

Example:

```ruby
obj.num_nodes
```

### `num_internal_nodes`

Gets the number of internal nodes in the network

Example:

```ruby
obj.num_internal_nodes
```

### `num_elements`

Gets the number of elements in the network

Example:

```ruby
obj.num_elements
```

### `to_s`

Returns a string representation of the network

Usage:

- `to_s(with_coords)`

Example:

```ruby
puts network.to_s
puts network.to_s(true)  # with coordinates
```


## Enum `Algorithm`

This enum represents the extraction algorithm for \\RExtractorTechConductor.

| Command | Description |
|---|---|
| `SquareCounting` | Specifies the square counting algorithm for \\RExtractorTechConductor#algorithm. |
| `Tesselation` | Specifies the square counting algorithm for \\RExtractorTechConductor#algorithm. |

Example:

```ruby
c.algorithm = RBA::RExtractorTechConductor::SquareCounting
# or
c.algorithm = RBA::RExtractorTechConductor::Tesselation
```

## Enum `RNodeType`

This class represents the node type for RNode.

| Command | Description |
|---|---|
| `Internal` | Specifies an internal node in a R network |
| `VertexPort` | Specifies a vertex port node in a R network |
| `PolygonPort` | Specifies a polygon port node in a R network |

Example:

```ruby
a = network.create_node(RBA::RNodeType::VertexPort, 0)
b = network.create_node(RBA::RNodeType::Internal, 1)
c = network.create_node(RBA::RNodeType::PolygonPort, 0)
```

---

## End-to-end resistance extraction

```ruby
# Polygon R extraction (sheet resistance = 1 Ω/□; scale afterwards)
poly = RBA::Polygon::new(RBA::Box::new(0, 0, 1100, 100))
vp = [ RBA::Point::new(50, 50) ]
pp = [ RBA::Polygon::new(RBA::Box::new(1000, 0, 1100, 100)) ]
rex = RBA::RExtractor::square_counting_extractor(0.001)
network = rex.extract(poly, vp, pp)
network.simplify
puts network.to_s
```
