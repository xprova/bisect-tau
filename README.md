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
indicated by `d`.

The DUT must be prepared as a spice sub-circuit and have the required ports so
minimum definition would be something like:

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

Once the DUT spice file is prepared, the design behavior can be checked by
running

```
./bisect-tau check mydut.cir
```

This will simulate the design using two testbenches to verify that its reset
and latching behaviors are correct.

#### Case 1

In the first test, the design is initially reset and then stimulated with non-
overlapping high states of `clk` and `d`. The final state of the design must
be low at the end of this test.

![Example 1](https://cdn.rawgit.com/xprova/bisect-tau/master/figures/example1.svg)

#### Case 2

The DUT is then fed input stimuli with overlapping `clk` and `d` high states
and expected to be in a logic high state at the end of the simulation.

![Example 2](https://cdn.rawgit.com/xprova/bisect-tau/master/figures/example2.svg)

### 3. Running Bisection

After verifying that the design functions correctly in test cases 1 and 2,
bisection can ran by executing

```
./bisect-tau bisect mydut.cir
```

This will start a bisection search procedure to find the tipping point between
test cases 1 and 2. The transition time of `d` will be varied to bring the
design into progressively deeper metastable states and calculate it transition
or "settling" time. During bisection, the tool will output a printout of
bisection parameters similar to the below:

```
checking if ngspice is installed ... pass
checking if dut file exists ... pass
checking DUT behavior (test Case 1) ... pass
checking DUT behavior (test Case 2) ... pass
All checks passed successfully
starting bisection ...
round ( 1/50), window size = 1.00e-08 sec, settling time = Inf sec
round ( 2/50), window size = 5.00e-09 sec, settling time = Inf sec
round ( 3/50), window size = 2.50e-09 sec, settling time = 5.05e-09 sec
round ( 4/50), window size = 1.25e-09 sec, settling time = 5.05e-09 sec
round ( 5/50), window size = 6.25e-10 sec, settling time = 5.05e-09 sec
round ( 6/50), window size = 3.13e-10 sec, settling time = 5.05e-09 sec
round ( 7/50), window size = 1.56e-10 sec, settling time = 5.05e-09 sec
round ( 8/50), window size = 7.81e-11 sec, settling time = 5.05e-09 sec
round ( 9/50), window size = 3.91e-11 sec, settling time = 5.05e-09 sec
round (10/50), window size = 1.95e-11 sec, settling time = 5.05e-09 sec
round (11/50), window size = 9.77e-12 sec, settling time = 5.05e-09 sec
round (12/50), window size = 4.88e-12 sec, settling time = 5.06e-09 sec
round (13/50), window size = 2.44e-12 sec, settling time = 5.10e-09 sec
round (14/50), window size = 1.22e-12 sec, settling time = 5.07e-09 sec
round (15/50), window size = 6.10e-13 sec, settling time = 5.11e-09 sec
round (16/50), window size = 3.05e-13 sec, settling time = 5.12e-09 sec
round (17/50), window size = 1.53e-13 sec, settling time = 5.13e-09 sec
round (18/50), window size = 7.63e-14 sec, settling time = 5.15e-09 sec
round (19/50), window size = 3.81e-14 sec, settling time = 5.17e-09 sec
round (20/50), window size = 1.91e-14 sec, settling time = 5.19e-09 sec
round (21/50), window size = 9.54e-15 sec, settling time = 5.20e-09 sec
round (22/50), window size = 4.77e-15 sec, settling time = 5.23e-09 sec
round (23/50), window size = 2.38e-15 sec, settling time = 5.23e-09 sec
round (24/50), window size = 1.19e-15 sec, settling time = 5.29e-09 sec
round (25/50), window size = 5.96e-16 sec, settling time = 5.25e-09 sec
...
```

If bisection is progressing correcting then window size will shrink by a
factor of 2 per round and settling time will increase in small increments
(although not at the beginning or very end of the process).

A waveform window will also appear and show plots of signals `q` and `qn` as
the design is pushed into deeper metastable states.

### 4. Calculating Tau

Once bisection is complete, execute:

```
./bisect-tau calculate
```

This will pull out simulation traces from the bisection procedure ran last and
print the calculated values of Tau and Tw:

```
Results:

Tau = 2.519e-11 sec
Tw  = 1.548e-12 sec

Close figure window to exit.
```

For a quick sanity check, the tool will also produce a semi-log plot of window
size vs. settling time. If bisection was successful, there will be a clear
straight line segment showing the exponential relationship from which Tau and
Tw were calculated.
