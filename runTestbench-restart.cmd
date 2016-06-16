* Testbench

.control
	source ./testbench-restart.cir
	tran 1ps 10ns uic
	write output/spice-output-restart.bin
	quit
.endc