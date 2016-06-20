## bisect-tau
Octave/Spice tool for characterizing the metastability resolution time constant tau

### 1. Preparing the DUT

The Design under Test (DUT) (latch/flip-flop/arbiter circuit) must be a spice
sub-circuit with the input ports: `reset`, `clk` and `d` and output ports: `q`
and `qn`.

![Example 1](https://cdn.rawgit.com/xprova/bisect-tau/master/figures/diagram.svg)

The outputs `q` and `qn` indicate the logical state of the DUT (logic high
when `q` is larger than `qn` and logic low otherwise).

The DUT can be either a level or an edge-sensitive device and must behave in
the following way:

1. When `reset` is pulled high, the DUT must transition to logic low.

2. When `reset` is low and `clk` is high (or at a low-to-high transition of
`clk` for edge-sensitive devics) the DUT must transition to the logic state
indicated y `d`.

The DUT must be prepared as a spice sub-circuit and have the required ports. A
minimum definition would therfore be something like the below:

```
.SUBCKT mydut D Q QN CLK RESET

	* spice components of dut defined here

.ENDS mydut
```

The sub-circuit definition (and any denpendencies) must be listed in the spice
circuit file `dut.cir` at the root directory. The file must also define the
supply voltage and instantiate the design. For example:

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