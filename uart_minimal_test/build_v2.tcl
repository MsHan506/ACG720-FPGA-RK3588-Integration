open_project ./uart_ascii_test_v2.gprj
set_option -verilog_std v2001
set_option -top_module uart_ascii_test_v2
set_option -output_base_name uart_ascii_test_v2_external_cp2102
set_option -timing_driven 1
run all
