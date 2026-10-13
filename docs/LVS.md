# KLayout LVS Commands

Extracted from KLayout official DRC/LVS reference HTML and built-in macros (KLayout 0.30.2+). Every command includes Usage plus an Example (preferring official doc samples; otherwise a minimal illustrative snippet).

LVS scripts (`.lvs` / `.lylvs`) extend DRC: **every command in `DRC.md` is available**. This file lists LVS-specific compare / schematic APIs.

```bash
klayout -b -r script.lvs
```

**Command counts:** LVS global 25 · LVS Netter 23

---

## LVS global functions

| Command | Description |
|---|---|
| `align` | Aligns the extracted netlist vs. the schematic by flattening circuits where required |
| `blank_circuit` | Removes the content from the given circuits (blackboxing) |
| `compare` | Compares the extracted netlist vs. the schematic netlist |
| `consider_net_names` | Indicates whether the netlist comparer shall use net names |
| `disable_parameter` | Specifies whether to disable a parameter from a given device class for netlisting and default compare |
| `enable_parameter` | Specifies whether to enable a parameter from a given device class for netlisting and default compare |
| `equivalent_pins` | Marks pins as equivalent |
| `flag_missing_ports` | Checks if all top level ports are properly labelled |
| `ignore_parameter` | Specifies whether to ignore a parameter from a given device class for the compare |
| `join_symmetric_nets` | Joins symmetric nets of selected circuits on the extracted netlist |
| `lvs_data` | Gets the LayoutVsSchematic object after compare was used |
| `max_branch_complexity` | Configures the maximum branch complexity for ambiguous net matching |
| `max_depth` | Configures the maximum search depth for net match deduction |
| `max_res` | Ignores resistors with a resistance above a certain value |
| `min_caps` | Ignores capacitors with a capacitance below a certain value |
| `netter` | Creates a new netter object |
| `no_lvs_hints` | Disables LVS hints |
| `report_lvs` | Specifies an LVS report for output |
| `same_circuits` | Establishes an equivalence between the circuits |
| `same_device_classes` | Establishes an equivalence between the device_classes |
| `same_nets` | Establishes an equivalence between the nets |
| `same_nets!` | Establishes an equivalence between the nets (must match) |
| `schematic` | Reads the reference netlist |
| `split_gates` | Implements the "split gates" feature for the given device and circuits |
| `tolerance` | Specifies compare tolerances for certain device parameters |

### LVS global function details

### `align`

Aligns the extracted netlist vs. the schematic by flattening circuits where required

Usage:

- `align`

Example:

```ruby
align
```

### `blank_circuit`

Removes the content from the given circuits (blackboxing)

Usage:

- `blank_circuit(circuit_filter)`

Example:

```ruby
blank_circuit("IP_BLOCK*")
```

### `compare`

Compares the extracted netlist vs. the schematic netlist

Usage:

- `compare`

Example:

```ruby
schematic("reference.cir")
ok = compare
puts ok
```

### `consider_net_names`

Indicates whether the netlist comparer shall use net names

Usage:

- `consider_net_names(f)`

Example:

```ruby
# LVS
consider_net_names(f)
```

### `disable_parameter`

Specifies whether to disable a parameter from a given device class for netlisting and default compare

Usage:

- `disable_parameter(device_class_name, parameter_name)`

Example:

```ruby
# LVS
disable_parameter(device_class_name, parameter_name)
```

### `enable_parameter`

Specifies whether to enable a parameter from a given device class for netlisting and default compare

Usage:

- `enable_parameter(device_class_name, parameter_name)`

Example:

```ruby
# LVS
enable_parameter(device_class_name, parameter_name)
```

### `equivalent_pins`

Marks pins as equivalent

Usage:

- `equivalent_pins(circuit, pins ...)`
- `equivalent_pins(circuit, pin ...)`

Example:

```ruby
equivalent_pins("NAND2", "A", "B")
```

### `flag_missing_ports`

Checks if all top level ports are properly labelled

Usage:

- `flag_missing_ports`

Example:

```ruby
# LVS
flag_missing_ports
```

### `ignore_parameter`

Specifies whether to ignore a parameter from a given device class for the compare

Usage:

- `ignore_parameter(device_class_name, parameter_name)`

Example:

```ruby
# LVS
ignore_parameter(device_class_name, parameter_name)
```

### `join_symmetric_nets`

Joins symmetric nets of selected circuits on the extracted netlist

Usage:

- `join_symmetric_nets(circuit_filter)`

Example:

```ruby
# LVS
join_symmetric_nets(circuit_filter)
```

### `lvs_data`

Gets the LayoutVsSchematic object after compare was used

Usage:

- `lvs_data`

Example:

```ruby
# LVS
lvs_data
```

### `max_branch_complexity`

Configures the maximum branch complexity for ambiguous net matching

Usage:

- `max_branch_complexity(n)`

Example:

```ruby
# LVS
max_branch_complexity(n)
```

### `max_depth`

Configures the maximum search depth for net match deduction

Usage:

- `max_depth(n)`

Example:

```ruby
# LVS
max_depth(n)
```

### `max_res`

Ignores resistors with a resistance above a certain value

Usage:

- `max_res(threshold)`

Example:

```ruby
# LVS
max_res(threshold)
```

### `min_caps`

Ignores capacitors with a capacitance below a certain value

Usage:

- `min_caps(threshold)`

Example:

```ruby
# LVS
min_caps(threshold)
```

### `netter`

Creates a new netter object

Usage:

- `netter`

Example:

```ruby
# LVS
netter
```

### `no_lvs_hints`

Disables LVS hints

Usage:

- `no_lvs_hints`

Example:

```ruby
# LVS
no_lvs_hints
```

### `report_lvs`

Specifies an LVS report for output

After the comparison step, the LVS database will be shown in the netlist database browser in a cross-reference view. If a filename is given, the LVS database is also written to this file. If a file name is given and "long" is true, a verbose version of the LVS DB format will be used.

If this method is called together with report_netlist and two files each, two files can be generated - one for the extracted netlist (L2N database) and one for the LVS database. However, report_netlist will only write the extracted netlist while report_lvs will write the LVS database which also includes the extracted netlist.

Usage:

- `report_lvs([ filename [, long ] ])`

Example:

```ruby
report_lvs("result.lvsdb")
```

### `same_circuits`

Establishes an equivalence between the circuits

Usage:

- `same_circuits(circuit_a, circuit_b)`

Example:

```ruby
same_circuits("INVX1", "inv")
```

### `same_device_classes`

Establishes an equivalence between the device_classes

Usage:

- `same_device_classes(class_a, class_b)`

Example:

```ruby
same_device_classes("NMOS", "nmos_lv")
```

### `same_nets`

Establishes an equivalence between the nets

Usage:

- `same_nets(circuit_pattern, net_pattern)`
- `same_nets(circuit_pattern, net_a, net_b)`
- `same_nets(circuit_a, net_a, circuit_b, net_b)`

Example:

```ruby
same_nets("TOP", "VDD")
same_nets("TOP", "VSS")
```

### `same_nets!`

Establishes an equivalence between the nets (must match)

Usage:

- `same_nets!(circuit_pattern, net_pattern)`
- `same_nets!(circuit_pattern, net_a, net_b)`
- `same_nets!(circuit_a, net_a, circuit_b, net_b)`

Example:

```ruby
# LVS
same_nets!(circuit_pattern, net_pattern)
```

### `schematic`

Reads the reference netlist

Usage:

- `schematic(filename)`
- `schematic(filename, reader)`
- `schematic(netlist)`
- `schematic`

Example:

```ruby
schematic("reference.cir")
```

### `split_gates`

Implements the "split gates" feature for the given device and circuits

Usage:

- `split_gates(device_name)`
- `split_gates(device_name, circuit_filter)`

Example:

```ruby
split_gates("NMOS")
```

### `tolerance`

Specifies compare tolerances for certain device parameters

Usage:

- `tolerance(device_class_name, parameter_name, absolute_tolerance [, relative_tolerance])`
- `tolerance(device_class_name, parameter_name [, :absolute => absolute_tolerance] [, :relative => relative_tolerance])`

Example:

```ruby
tolerance("NMOS", "L", 0.001)
tolerance("NMOS", "W", absolute: 0.01, relative: 0.05)
```


---

## LVS Netter object

Inherits DRC `Netter` (`connect`, `extract_devices`, … — see `DRC.md`) and adds comparison. Most methods are also global functions.

| Command | Description |
|---|---|
| `align` | Aligns the extracted netlist vs. the schematic |
| `blank_circuit` | Removes the content from the given circuits (blackboxing) |
| `compare` | Compares the extracted netlist vs. the schematic |
| `consider_net_names` | Indicates whether the netlist comparer shall use net names |
| `disable_parameter` | Indicates whether to disable a specific parameter for a given device |
| `enable_parameter` | Indicates whether to enable a specific parameter for a given device |
| `equivalent_pins` | Marks pins as equivalent |
| `flag_missing_ports` | Flags inconsistently labelled or missing ports in the current top circuit |
| `ignore_parameter` | Skip a specific parameter for a given device class name during device compare |
| `join_symmetric_nets` | Joins symmetric nets of selected circuits on the extracted netlist |
| `lvs_data` | Gets the internal LayoutVsSchematic object |
| `max_branch_complexity` | Configures the maximum branch complexity for ambiguous net matching |
| `max_depth` | Configures the maximum search depth for net match deduction |
| `max_res` | Ignores resistors with a resistance above a certain value |
| `min_caps` | Ignores capacitors with a capacitance below a certain value |
| `no_lvs_hints` | Disables LVS hints |
| `same_circuits` | Establishes an equivalence between the circuits |
| `same_device_classes` | Establishes an equivalence between the device classes |
| `same_nets` | Establishes an equivalence between the nets |
| `same_nets!` | Establishes an equivalence between the nets with matching requirement |
| `schematic` | Gets, sets or reads the reference netlist |
| `split_gates` | Implements the "split gates" feature |
| `tolerance` | Specifies compare tolerances for certain device parameters |

### LVS Netter method details

### `align`

Aligns the extracted netlist vs. the schematic

The align method will modify the netlists in case of missing corresponding circuits. It will flatten these circuits, thus improving the equivalence between the netlists. Top level circuits are not flattened.

This feature is in particular useful to remove structural cells like device PCells, reuse blocks etc.

Usage:

- `align`

Example:

```ruby
align
```

### `blank_circuit`

Removes the content from the given circuits (blackboxing)

This method will erase all content from the circuits matching the filter. The filter is a glob expression.

This has the following effects:

Usage:

- `blank_circuit(circuit_filter)`

Example:

```ruby
# skips all MEMORY* circuits from compare
blank_circuit("MEMORY*")
```

### `compare`

Compares the extracted netlist vs. the schematic

Before using this method, a schematic netlist has to be loaded with schematic. The compare can be configured in more details using same_nets, same_circuits, same_device_classes and equivalent_pins.

The compare method will also modify the netlists in case of missing corresponding circuits: the unpaired circuit will be flattened then.

Usage:

- `compare`

Example:

```ruby
schematic("reference.cir")
ok = compare
puts ok
```

### `consider_net_names`

Indicates whether the netlist comparer shall use net names

If this value is set to true (the default), the netlist comparer will employ net names to resolve ambiguities. If set to false, ambiguities will be resolved based on the topology alone. Topology resolution is more expensive.

Usage:

- `consider_net_names(f)`

Example:

```ruby
# LVS
consider_net_names(f)
```

### `disable_parameter`

Indicates whether to disable a specific parameter for a given device

Disabling a parameter is the inverse of enable_parameter. Disabling a parameter will reset the "primary" flag of the parameter. This has several effects - e.g. the parameter will not be used in device compare during netlist matching by default.

This is not a strong concept but rather a hint for the system. Disabling a parameter for netlist compare without side effects is possible with the ignore_parameter function. In the same way, tolerance will enable a parameter for netlist compare regardless of the "primary" status of the parameter.

Usage:

- `disable_parameter(device_class_name, parameter_name)`

Example:

```ruby
# LVS
disable_parameter(device_class_name, parameter_name)
```

### `enable_parameter`

Indicates whether to enable a specific parameter for a given device

The parameter is made "primary" which enables further applications - e.g. it is netlisted for some elements which normally would not print that parameter, and the parameter is compared in the default device compare scheme during netlist matching.

Enabling a parameter is rather a hint for the system and the effects can be controlled by other means, so this is not a strong concept. For example, once a tolerance is specified for a parameter, the "primary" flag of the parameter is not considered anymore. The inverse the this function is disable_parameter.

Usage:

- `enable_parameter(device_class_name, parameter_name)`

Example:

```ruby
# LVS
enable_parameter(device_class_name, parameter_name)
```

### `equivalent_pins`

Marks pins as equivalent

This method will mark the given pins as equivalent. This gives the compare algorithm more degrees of freedom when establishing net correspondence. Typically this method is used to declare inputs from gates are equivalent where are are logically, but not physically (e.g. in a CMOS NAND gate):

netter.equivalent_pins("NAND2", 0, 1)

Usage:

- `equivalent_pins(circuit, pin ...)`

Example:

```ruby
netter.equivalent_pins("NAND2", 0, 1)
```

### `flag_missing_ports`

Flags inconsistently labelled or missing ports in the current top circuit

This method must be called after "compare" was executed successfully and will report errors if pins in the current top circuit's schematic are not labelled correspondingly in the layout. This prevents swapping of port labels or pads.

success = compare success && flag_missing_ports

Usage:

- `flag_missing_ports`

Example:

```ruby
success = compare
success && flag_missing_ports
```

### `ignore_parameter`

Skip a specific parameter for a given device class name during device compare

Use this function is ignore a parameter for a particular device class during the netlist compare. Some parameters - for example "L" and "W" parameters of the resistor device - are "secondary" parameters which are not ignored by default. Using "ignore_parameter" on such devices does not have an effect.

"ignore_parameter" and "tolerance" only have an effect with the default device comparer. Using a custom device comparer will override the definitions by "ignore_parameter" or "tolerance".

Usage:

- `ignore_parameter(device_class_name, parameter_name)`

Example:

```ruby
# LVS
ignore_parameter(device_class_name, parameter_name)
```

### `join_symmetric_nets`

Joins symmetric nets of selected circuits on the extracted netlist

Nets are symmetrical if swapping them would not modify the circuit. Hence they will carry the same potential and can be connected (joined). This will simplify the circuit and can be applied before device combination (e.g. through "netlist.simplify") to render a schematic-equivalent netlist in some cases where symmetric nodes are split (i.e. "split gate" configuration).

This method operates on the extracted netlist (layout). The circuit filter specifies the circuits to which to apply this operation. The filter is a glob-style pattern. Using "*" for all circuits is possible, but it's discouraged currenty until the reliability of the symmetry detection algorithm is established. Currently it is recommended to apply it only to those circuits for which this feature is required.

Usage:

- `join_symmetric_nets(circuit_filter)`

Example:

```ruby
# LVS
join_symmetric_nets(circuit_filter)
```

### `lvs_data`

Gets the internal LayoutVsSchematic object

The LayoutVsSchematic object provides access to the internal details of the netter object.

Usage:

- `lvs_data`

Example:

```ruby
# LVS
lvs_data
```

### `max_branch_complexity`

Configures the maximum branch complexity for ambiguous net matching

The netlist compare algorithm is basically a backtracing algorithm. With ambiguous nets, the algorithm picks possible net pairs and tries whether they will make a good match. Following the deduction path for this nets may lead to further branches if more ambiguous nets are encountered. To avoid combinational explosion, the maximum branch complexity is limited to the value configured with this function. The default value is 500 which means not more than 500 combinations are tried for a single see…

By default, the branch complexity is unlimited, but it may be reduced in order to limit the compare runtimes at the cost of a less elaborate compare attempt. The preferred solution however is to use labels for net name hints which also reduces the depth.

Usage:

- `max_branch_complexity(n)`

Example:

```ruby
# LVS
max_branch_complexity(n)
```

### `max_depth`

Configures the maximum search depth for net match deduction

The netlist compare algorithm works recursively: once a net equivalence is established, additional matches are derived from this equivalence. Such equivalences in turn are used to derive new equivalences and so on. The maximum depth parameter configures the number of recursions the algorithm performs before picking the next net. With higher values for the depth, the algorithm pursues this "deduction path" in greater depth while with smaller values, the algorithm prefers picking nets in a random…

By default, the depth is unlimited, but it may be reduced in order to limit the compare runtimes at the cost of a less elaborate compare attempt. The preferred solution however is to use labels for net name hints which also reduces the branch complexity.

Usage:

- `max_depth(n)`

Example:

```ruby
# LVS
max_depth(n)
```

### `max_res`

Ignores resistors with a resistance above a certain value

After using this method, the netlist compare will ignore resistor devices with a resistance value above the given threshold (in Farad).

Usage:

- `max_res(threshold)`

Example:

```ruby
# LVS
max_res(threshold)
```

### `min_caps`

Ignores capacitors with a capacitance below a certain value

After using this method, the netlist compare will ignore capacitance devices with a capacitance values below the given threshold (in Farad).

Usage:

- `min_caps(threshold)`

Example:

```ruby
# LVS
min_caps(threshold)
```

### `no_lvs_hints`

Disables LVS hints

LVS hints may be expensive to compute. Use this function to disable generation of LVS hints

Usage:

- `no_lvs_hints`

Example:

```ruby
# LVS
no_lvs_hints
```

### `same_circuits`

Establishes an equivalence between the circuits

This method will force an equivalence between the two circuits. By default, circuits are identified by name. If names are different, this method allows establishing an explicit correspondence.

circuit_a is for the layout netlist, circuit_b for the schematic netlist. Names are case sensitive for layout-derived netlists and case-insensitive for SPICE schematic netlists.

Usage:

- `same_circuits(circuit_a, circuit_b)`

Example:

```ruby
same_circuits("INVX1", "inv")
```

### `same_device_classes`

Establishes an equivalence between the device classes

This method will force an equivalence between the two device classes. Device classes are also known as "models". By default, device classes are identified by name. If names are different, this method allows establishing an explicit correspondence.

Before this method can be used, a schematic netlist needs to be loaded with schematic.

Usage:

- `same_device_classes(class_a, class_b)`

Example:

```ruby
same_device_classes("POLYRES", "RES")
same_device_classes("WELLRES", "RES")
```

### `same_nets`

Establishes an equivalence between the nets

This method will force an equivalence between the net_a and net_b from circuit_a and circuit_b (circuit in the three-argument form is for both circuit_a and circuit_b).

In the four-argument form, the circuits can be either given by name or as Circuit objects. In the three-argument form, the circuits have to be given by name pattern. Nets can be either given by name or as Net objects. In the two-argument form, the circuits and nets have to be given as name pattern.

Usage:

- `same_nets(circuit_pattern, net_pattern)`
- `same_nets(circuit_pattern, net_a, net_b)`
- `same_nets(circuit_a, net_a, circuit_b, net_b)`

Example:

```ruby
same_nets("INV*", "A*")
```

```ruby
same_nets("*", "*")
same_nets("ND2", "A", "B")
```

### `same_nets!`

Establishes an equivalence between the nets with matching requirement

This method is equivalent to same_nets, but requires identity of the given nets. If the specified nets do not match, an error is reported.

For example, this global specification requires all named nets from the layout to have an equivalent net in the schematic and those nets need to be identical for all circuits:

Usage:

- `same_nets!(circuit_pattern, net_pattern)`
- `same_nets!(circuit_pattern, net_a, net_b)`
- `same_nets!(circuit_a, net_a, circuit_b, net_b)`

Example:

```ruby
same_nets!("*", "*")
```

```ruby
same_nets!("ND2", "A", "B")
```

### `schematic`

Gets, sets or reads the reference netlist

If no argument is given, the current schematic netlist is returned. nil is returned if no schematic netlist is set yet.

If a filename is given (first two forms), the netlist is read from the given file. If no reader is provided, Spice format will be assumed. The reader object is a NetlistReader object and allows detailed customization of the reader process.

Usage:

- `schematic(filename)`
- `schematic(filename, reader)`
- `schematic(netlist)`
- `schematic`

Example:

```ruby
schematic("reference.cir")
```

### `split_gates`

Implements the "split gates" feature

Multi-fingered, multi-gate MOS transistors can be built without connecting the source/drain internal nets between the fingers. This will prevent "combine_devices" from combining the single gate transistors of the different fingers into single ones.

"split_gates" now marks the devices of the given class so that they will receive a special treatment which joins the internl source/drain nodes.

Usage:

- `split_gates(device_name)`
- `split_gates(device_name, circuit_filter)`

Example:

```ruby
split_gates("NMOS")
```

### `tolerance`

Specifies compare tolerances for certain device parameters

Specifies a compare tolerance for a specific parameter on a given device class. The device class is the name of a device class in the extracted netlist. Tolerances can be given in absolute units or relative or both. The relative tolerance is given as a factor, so 0.1 is a 10% tolerance. Absolute and relative tolerances add, so specifying both allows for a larger deviation.

Some device parameters - like the resistor's "L" and "W" parameters - are not compared by default. These are "secondary" device parameters. Using a tolerance on such parameters will make these parameters being compared even if they are secondary ones.

Usage:

- `tolerance(device_class_name, parameter_name, absolute_tolerance [, relative_tolerance])`
- `tolerance(device_class_name, parameter_name [, :absolute => absolute_tolerance] [, :relative => relative_tolerance])`

Example:

```ruby
tolerance("NMOS", "L", 0.001)
tolerance("NMOS", "W", absolute: 0.01, relative: 0.05)
```


---

## Typical LVS flow

```ruby
report_lvs("result.lvsdb")

metal1 = input(1, 0)
via1   = input(2, 0)
metal2 = input(3, 0)

connect(metal1, via1)
connect(via1, metal2)

extract_devices(mos4("NMOS"), {
  "SD" => input(11, 0),
  "G"  => input(12, 0),
  "P"  => input(14, 0),
  "B"  => input(13, 0)
})

schematic("reference.cir")
compare
```
