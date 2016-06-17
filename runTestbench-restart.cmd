* Testbench

.control
	source ./testbench-restart.cir
	tran 1ps 10ns
	write output/spice-output-restart.bin
	quit
.endc