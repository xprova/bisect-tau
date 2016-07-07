## bisect-tau

This is a command line tool to calculate the metastability resolution time
constant (Tau) of a latch/arbiter/flip-flop circuit. It's based on
[Octave](https://www.gnu.org/software/octave/) (a GNU Matlab clone) and
[ngspice](http://ngspice.sourceforge.net/) (an open-source version of spice).

For background information on metastability, MTBF calculations and the
bisection process used to calculate Tau, refer to the paper:

* Jones, Ian W., Suwen Yang, and Mark Greenstreet. "[Synchronizer behavior and
analysis.](http://ieeexplore.ieee.org/xpls/abs_all.jsp?arnumber=5010342)"
Asynchronous Circuits and Systems, 2009. ASYNC'09. 15th IEEE Symposium on.
IEEE, 2009.

The tool uses bisection search to find the tipping point between an early and
a late input transition times of a bistable circuit. In each bisection round
the design is brought into a deeper metastable state and its output delay is
calculated. After 50 rounds the tool fits an exponential function to the
window size (the time difference between input transition and the tipping
point) and output delay data measured during bisection. The fit is then used
to calculate the MTBF parameters Tau and Tw of the characterized circuit.

### Installation

First, install the dependencies Octave and ngspice. For Ubuntu and apt-based
linux distros run:

```
sudo apt-get install octave
sudo apt-get install ngspice
```

Then either clone this repo by executing:

```
git clone https://github.com/xprova/bisect-tau
```

or download the source code to your machine manually.

### Quick Demo

Navigate to the tool directory and run:

```
./bisect-tau bisect examples/latch.cir
```

This will run bisection on an example latch circuit that is provided with the
tool. During bisection the tool will produce a figure (like the below) showing
the superimposed plots of the circuit outputs `q` and `qn` as the circuit is
pushed into deeper metastability.

![Metastable Waveforms](https://cdn.rawgit.com/xprova/bisect-tau/master/figures/fig_metastable.svg)

This will take few minutes to complete. Once done, run the command:

```
./bisect-tau calculate
```

The tool will now fit an exponential relationship to the input window size and
output delay data collected during bisection. It will produce an output plot
of the data, the exponential fit and print out the calculated values of the
parameters Tau and Tw:

![Exponential Fit](https://cdn.rawgit.com/xprova/bisect-tau/master/figures/fig_exponential.svg)

```
Results:

Tau = 2.519e-11 sec
Tw  = 1.548e-12 sec
```

Follow the guidelines in the following sections to learn how to use with tool
to characterize your own circuits.


### Calculating Tau for your Design

There are four basic steps to calculate Tau for your spice bistable circuit:

#### 1. Preparing the DUT

The Design under Test (DUT) (latch/flip-flop/arbiter circuit) must be a spice
sub-circuit with the input ports: `reset`, `clk` and `d` and output ports: `q`
and `qn` as shown in the diagram below.

![Example 1](https://cdn.rawgit.com/xprova/bisect-tau/master/figures/diagram.svg)

The outputs `q` and `qn` indicate the logical state of the DUT (logic high
when `q` > `qn` and logic low otherwise).

The DUT can be either a level or an edge-sensitive device and must behave in
the following way:

1. When `reset` is pulled high, the DUT must transition to logic low.

2. When `reset` is low and `clk` is pulled high (or at a low-to-high
transition of `clk` for edge-sensitive devices) the DUT must transition to the
state indicated by `d`.

A minumum definition of the DUT would be something like:

```
.SUBCKT mydut D Q QN CLK RESET

	* dut components and their connections defined here

.ENDS mydut
```

Note: ports don't need to be defined in order and are case insensitive.

Spice circuits are part of the backend of cell libraries and can usually be
used with the tool with little to no modification.

After locating the spice sub-circuit definition for the latch (or bistable)
design to be characterized, an instance of the design must be declared in a
wrapper spice file. The wrapper must:

1. Define any design dependencies (e.g. transistor models)
2. Define the supply voltage
3. Instantiate the design naming its ports `reset`, `clk`, `d`, `q` and `qn`

For example:

```
* include transistor models:

.include "./mydut/modelcard.nmos"
.include "./mydut/modelcard.pmos"

* include definition of cell latchx1:

.include "./mydut/latchx1.cir"

* specify supply voltage in volts:

.param vdd_voltage 	= 1

* instantiate latchx1 with the required port names:

x1 D Q QN CLK RESET latchx1
```

For details on defining sub-circuits refer to [Ngspice Users Manual - Section 2.4
(".SUBCKT Subcircuits")](http://ngspice.sourceforge.net/docs/ngspice-manual.pdf).

The directory `examples` contains sample latch files that can be inspected or
used to test run the tool.

#### 2. Running Checks

After preparing the spice wrapper file that instantiates the design, its
reset and latching behavior must be verified by running:

```
./bisect-tau check mydut.cir
```

where `mydut.cir` is the wrapper spice file. This will simulate the design
using two testbenches to verify that it's behaving in a correct way and can be
used in bisection search.

##### Case 1

In the first test, the design is initially reset and then stimulated with
non-overlapping high states of `clk` and `d`. Since `clk` and `d` do not
overlap, the design must retain its post-reset state (i.e. logic low) until
the end  of the simulation. The test will fail if the design does not reset or
is by other means found to be in a logic high state when the simulation ends.

This test may also fail if ngspice terminates with a non-zero exit code. In
this case the tool will output both stdout and stderr of ngspice to enable the
user to debug their spice circuit.

![Example 1](https://cdn.rawgit.com/xprova/bisect-tau/master/figures/example1.svg)

##### Case 2

Here the design is stimulated with `clk` and `d` signals that have overlapping
high states. The design is now expected to be in a logic high state when the
simulation ends, otherwise the test will fail.

![Example 2](https://cdn.rawgit.com/xprova/bisect-tau/master/figures/example2.svg)

#### 3. Running Bisection

Once the behavior of the design is verified by running the tests above, run:

```
./bisect-tau bisect mydut.cir
```

This will start bisection search to find the tipping point between test cases
1 and 2. In test case 1, the high-to-low transition of `d` at 4ns was *before*
the rising edge of `clk` at 5ns so the design remained in a *logic low* state.
On the other hand, the transition of `d` in test case 2 was at 6ns (*after*
the rising edge of `clk`) and so the design transitioned to *logic high*.
Within the interval [4ns, 6ns] lies the tipping point separating logic high
and low and approaching this point will make the circuit take longer to decide
which logical state to settle to. The tool will vary the transition time of
`d` to bring the design closer to this point and measure the corresponding
increase in its output delay. During this process, the tool will output a
trace similar to the below:

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
