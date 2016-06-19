## bisect-tau
Octave/Spice tool for characterizing the metastability resolution time constant tau

### 1. Preparing the DUT

The Design under Test (DUT) (latch/flip-flop/arbiter circuit) must be a spice
sub-circuit with the input ports: `reset`, `clk` and `d` and output ports: `q`
and `qn`.

![Example 1](https://cdn.rawgit.com/xprova/bisect-tau/master/figures/diagram.svg)

The outputs `q` and `qn` indicate the logical state of the DUT. The DUT is
said to be in a logic high state when `q` is larger than `qn` and in a logic
low state otherwise.

The DUT can be either a level or an edge-sensitive device. Level sensitive
devices copy the logic state of their inputs while `clk` is high and retain
their state when `clk` goes low while edge-sensitive devices copy and retain
the state of their inputs at the time epoch when `clk` transitions from low to
high.

The DUT must behave in the following way:

1. When `reset` is pulled high, the DUT must transition to a logic low state.

2. When `reset` is low, the device must copy the state of its `d` port when
`clk` is high (only for level-sensitive devices) and when `clk` transitions
from low to high (only for edge-sensitive devices).

The DUT must be prepared as a spice sub-circuit with required ports. A minimum
definition would be something like the below

```
.SUBCKT mydut D Q QN CLK RESET

	* spice components of dut defined here

.ENDS mydut
```

The sub-circuit definition (and any denpendencies) must be defined in the
spice circuit file `dut.cir` at the root directory. The file must also
define the supply voltage and instantiate the design. For example:

```
.param vdd_voltage 	= 1

.include "./mydut/modelcard.nmos"
.include "./mydut/modelcard.pmos"
.include "./mydut/other_depencies.cir"

x1 D Q QN CLK RESET mydut
```

### 2. Running Checks

#### Case 1

![Example 1](https://cdn.rawgit.com/xprova/bisect-tau/master/figures/example1.svg)

#### Case 2

![Example 2](https://cdn.rawgit.com/xprova/bisect-tau/master/figures/example2.svg)

### 3. Running Bisection

Details here

### 4. Calculating Tau

Details here