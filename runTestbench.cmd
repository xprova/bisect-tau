* Testbench

.control
	source ./testbench.cir
	param d_time 		= 4.02n
	tran 1ps 10ns
	write spice-output/traces2.bin
	quit
.endc