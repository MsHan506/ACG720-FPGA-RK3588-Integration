open_project ./uart_onboard_ch9102_test.gprj
set_option -verilog_std v2001
set_option -top_module uart_onboard_ch9102_test
set_option -output_base_name uart_onboard_ch9102_9600_acg720_60b
set_option -timing_driven 1
run all
