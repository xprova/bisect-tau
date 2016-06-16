* Testbench

.control
	source ./testbench.cir
	param d_time 		= 4.02n
	tran 1ps 10ns
	write output/spice-output.bin
	quit
.endc