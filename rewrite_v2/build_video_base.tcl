open_project ./video_base.gprj
set_option -verilog_std sysv2017
set_option -top_module video_base_top
set_option -output_base_name rewrite_v2_video_base_720p60
set_option -use_sspi_as_gpio 1
run all
