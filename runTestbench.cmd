* Testbench

.control
	source ./testbench.cir
	tran 1ps 10ns
	write output/spice-output.bin
	quit
.endc