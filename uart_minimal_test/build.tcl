open_project ./uart_minimal_test.gprj
set_option -verilog_std v2001
set_option -top_module uart_fixed_pattern_top
set_option -output_base_name uart_fixed_pattern_acg720_60b
set_option -use_sspi_as_gpio 1
set_option -timing_driven 1
run all
