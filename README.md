## bisect-tau

This is a command line tool to calculate the metastability resolution time
constant Tau of a spice latch circuit (or any bistable circuit that behaves
like a latch, e.g. an arbiter). It is based on Octave (a GNU Matlab clone) and
ngspice (an open-source free version of spice).

For background information on metastability, MTBF calculations, bisection and
synchronization reliability refer to the paper:

* Jones, Ian W., Suwen Yang, and Mark Greenstreet. "[Synchronizer behavior and
analysis.](http://ieeexplore.ieee.org/xpls/abs_all.jsp?arnumber=5010342)"
Asynchronous Circuits and Systems, 2009. ASYNC'09. 15th IEEE Symposium on.
IEEE, 2009.

The tool uses bisection search to bring the transition time of the design's
data input closer and closer to the tipping time point separating the final
states of logic high and low. With each step, the design is brought into
deeper metastable states and its output delay is increased. After 50 rounds of
bisection, the tool fits an exponential function to the relationship between
window size (the time difference between input transitions and the tipping
point) and output delay. The fit is subsequently used to calculate the MTBF
parameters Tau and Tw.

### Quick Demo

Clone this repo, navigate to the tool directory and run:

```
./bisect-tau bisect examples/latch.cir
```

This will run bisection on a test latch circuit. Once it completes, you can calculate Tau and Tw by running:

```
./bisect-tau calculate
```

### Calculating Tau for your Design

The sub-sections below describe the steps to calculate Tau for a given
bistable spice circuit.

#### 1. Preparing the DUT

The Design under Test (DUT) (latch/flip-flop/arbiter circuit) must be a spice
sub-circuit with the input ports: `reset`, `clk` and `d` and output ports: `q`
and `qn` as shown in the block diagram below.

![Example 1](https://cdn.rawgit.com/xprova/bisect-tau/master/figures/diagram.svg)

The outputs `q` and `qn` indicate the logical state of the DUT (logic high
when `q` > `qn` and logic low otherwise).

The DUT can be either a level or an edge-sensitive device and must behave in
the following way:

1. When `reset` is pulled high, the DUT must transition to logic low.

2. When `reset` is low and `clk` is high (or at a low-to-high transition of
`clk` for edge-sensitive devics) the DUT must transition to the logic state
indicated by `d`.

The DUT must be prepared as a spice sub-circuit and have the required ports so
a minimum definition would be something like:

```
.SUBCKT mydut D Q QN CLK RESET

	* spice components of dut defined here

.ENDS mydut
```

Spice circuits are usually part of the backend of cell libraries and can
usually be used with the tool with little or no modification.

After locating the spice sub-circuit definition for the bistable device
to be characterized, an instance of the latch must be declared in a wrapper
spice file. The wrapper must:

1. Define any DUT dependencies (e.g. transistor models)
2. Define the supply voltage
3. Instantiate the design naming its ports `reset`, `clk`, `d`, `q` and `qn`

For example:

```
* include transistor models:

.include "./mydut/modelcard.nmos"
.include "./mydut/modelcard.pmos"

* include definition of cell latchx1:

.include "./mydut/other_depencies.cir"

* specify supply voltage in volts:

.param vdd_voltage 	= 1

* instantiate latchx1 with the required port names:

x1 D Q QN CLK RESET latchx1
```

For details on defining sub-circuits refer to [Ngspice Users Manual - Section 2.4
(".SUBCKT Subcircuits")](http://ngspice.sourceforge.net/docs/ngspice-manual.pdf).

The directory `examples` contains sample latch files that can be inspected or
used to test run the rool.

#### 2. Running Checks

Once the spice file is prepared, the design behavior can be checked by
running:

```
./bisect-tau check mydut.cir
```

where `mydut.cir` is the wrapper spice file. This will simulate the design
using two testbenches to verify that its reset and latching behavior are
correct.

##### Case 1

In the first test, the design is initially reset and then stimulated with non-overlapping high states of `clk` and `d`. The final state of the design at the
end of this simulation must be logic low.

![Example 1](https://cdn.rawgit.com/xprova/bisect-tau/master/figures/example1.svg)

##### Case 2

Here the design is stimulated with `clk` and `d` signals that have overlapping high
states. The design's final state must be logic low in this test.

![Example 2](https://cdn.rawgit.com/xprova/bisect-tau/master/figures/example2.svg)

#### 3. Running Bisection

Once the behavior of the design is verified by running the tests above, bisection
can be started by running:

```
./bisect-tau bisect mydut.cir
```

This will start bisection search to find the tipping point between test cases
1 and 2.

This will start an incremental process to bring the transition time of `d`
closer to the tipping point between logic low and high final states. The tool
will run a spice simulation per bisection round and output a trace similar to
the below:

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

If bisection is progressing correctly then window size will shrink by a factor
of 2 and settling time will increase slightly on each round (although not at
the beginning or very end of the process).

A waveform window will also appear and show plots of `q` and `qn` as the
design is pushed into deeper metastable states.

#### 4. Calculating Tau

Once bisection is complete, run:

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
size vs. settling time. If everything went correctly, there will be a clear
straight line segment showing the exponential relationship from which Tau and
Tw were calculated.
