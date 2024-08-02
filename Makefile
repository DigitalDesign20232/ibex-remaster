create_vivado_project:
	vivado -mode batch -source vivado/tcl/create_ibex_project.tcl
	rm *.jou
	rm *.log
