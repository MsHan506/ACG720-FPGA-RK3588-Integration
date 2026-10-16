$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $MyInvocation.MyCommand.Path
$iverilog = 'C:\iverilog\bin\iverilog.exe'
$vvp = 'C:\iverilog\bin\vvp.exe'

if (-not (Test-Path -LiteralPath $iverilog) -or
    -not (Test-Path -LiteralPath $vvp)) {
    throw 'Icarus Verilog was not found at C:\iverilog\bin.'
}

& "$repo\b_perception\tb\run_tests.ps1"

$camera = "$repo\b_perception\camera\ov5640_ddr3_hdmi_full\src\vga"
$osdOutput = Join-Path $env:TEMP 'tb_sensor_osd_overlay.vvp'
& $iverilog -g2005-sv -s tb_sensor_osd_overlay -o $osdOutput `
    "$camera\sensor_osd_overlay.v" "$camera\tb_sensor_osd_overlay.v"
if ($LASTEXITCODE -ne 0) { throw 'OSD test compilation failed.' }
& $vvp $osdOutput
if ($LASTEXITCODE -ne 0) { throw 'OSD test failed.' }

$motor = "$repo\src"
$motorOutput = Join-Path $env:TEMP 'motor_logic_selfcheck_tb.vvp'
& $iverilog -g2012 -s motor_logic_selfcheck_tb -o $motorOutput `
    "$motor\PWM.v" "$motor\DIR.v" "$motor\motor_control.v" `
    "$motor\quadrature_encoder.v" "$motor\speed_measure.v" `
    "$motor\PI_controller.v" "$motor\wheel_sync_control.v" `
    "$motor\motor_logic_selfcheck_tb.v"
if ($LASTEXITCODE -ne 0) { throw 'Motor logic test compilation failed.' }
& $vvp $motorOutput
if ($LASTEXITCODE -ne 0) { throw 'Motor logic test failed.' }

$reverseOutput = Join-Path $env:TEMP 'single_motor_reverse_feedback_tb.vvp'
& $iverilog -g2012 -s single_motor_reverse_feedback_tb -o $reverseOutput `
    "$motor\PWM.v" "$motor\DIR.v" "$motor\motor_control.v" `
    "$motor\quadrature_encoder.v" "$motor\speed_measure.v" `
    "$motor\PI_controller.v" "$motor\single_motor_control.v" `
    "$motor\single_motor_reverse_feedback_tb.v"
if ($LASTEXITCODE -ne 0) { throw 'Reverse feedback test compilation failed.' }
& $vvp $reverseOutput
if ($LASTEXITCODE -ne 0) { throw 'Reverse feedback test failed.' }

$rpmMonitorOutput = Join-Path $env:TEMP 'wheel_rpm_monitor_1480_tb.vvp'
& $iverilog -g2012 -s wheel_rpm_monitor_1480_tb -o $rpmMonitorOutput `
    "$motor\wheel_rpm_monitor_1480.v" `
    "$motor\wheel_rpm_monitor_1480_tb.v"
if ($LASTEXITCODE -ne 0) { throw 'Measured-CPR RPM monitor compilation failed.' }
& $vvp $rpmMonitorOutput
if ($LASTEXITCODE -ne 0) { throw 'Measured-CPR RPM monitor test failed.' }

$motionOutput = Join-Path $env:TEMP 'autonomous_motion_controller_tb.vvp'
& $iverilog -g2012 -s autonomous_motion_controller_tb -o $motionOutput `
    "$motor\autonomous_motion_controller.v" `
    "$motor\autonomous_motion_controller_tb.v"
if ($LASTEXITCODE -ne 0) { throw 'Autonomous motion test compilation failed.' }
& $vvp $motionOutput
if ($LASTEXITCODE -ne 0) { throw 'Autonomous motion test failed.' }

$rampOutput = Join-Path $env:TEMP 'safe_motor_command_ramp_tb.vvp'
& $iverilog -g2012 -s safe_motor_command_ramp_tb -o $rampOutput `
    "$motor\safe_motor_command_ramp.v" `
    "$motor\safe_motor_command_ramp_tb.v"
if ($LASTEXITCODE -ne 0) { throw 'Motor command ramp compilation failed.' }
& $vvp $rampOutput
if ($LASTEXITCODE -ne 0) { throw 'Motor command ramp test failed.' }

$tb6612Output = Join-Path $env:TEMP 'tb6612_quad_safe_adapter_tb.vvp'
& $iverilog -g2012 -s tb6612_quad_safe_adapter_tb -o $tb6612Output `
    "$motor\tb6612_quad_safe_adapter.v" `
    "$motor\tb6612_quad_safe_adapter_tb.v"
if ($LASTEXITCODE -ne 0) { throw 'TB6612 adapter test compilation failed.' }
& $vvp $tb6612Output
if ($LASTEXITCODE -ne 0) { throw 'TB6612 adapter test failed.' }

$tb6612DualOutput = Join-Path $env:TEMP 'tb6612_dual_safe_adapter_tb.vvp'
& $iverilog -g2012 -s tb6612_dual_safe_adapter_tb -o $tb6612DualOutput `
    "$motor\tb6612_dual_safe_adapter.v" `
    "$motor\tb6612_dual_safe_adapter_tb.v"
if ($LASTEXITCODE -ne 0) { throw 'Two-channel TB6612 adapter test compilation failed.' }
& $vvp $tb6612DualOutput
if ($LASTEXITCODE -ne 0) { throw 'Two-channel TB6612 adapter test failed.' }

$buttonTestOutput = Join-Path $env:TEMP 'motor_button_commissioning_tb.vvp'
& $iverilog -g2012 -s motor_button_commissioning_tb -o $buttonTestOutput `
    "$motor\tb6612_dual_safe_adapter.v" `
    "$motor\motor_button_commissioning.v" `
    "$motor\motor_button_commissioning_tb.v"
if ($LASTEXITCODE -ne 0) { throw 'Button motor test compilation failed.' }
& $vvp $buttonTestOutput
if ($LASTEXITCODE -ne 0) { throw 'Button motor test failed.' }

$startStopOutput = Join-Path $env:TEMP 'safe_start_stop_latch_tb.vvp'
& $iverilog -g2012 -s safe_start_stop_latch_tb -o $startStopOutput `
    "$motor\safe_start_stop_latch.v" "$motor\safe_start_stop_latch_tb.v"
if ($LASTEXITCODE -ne 0) { throw 'Safe start/stop test compilation failed.' }
& $vvp $startStopOutput
if ($LASTEXITCODE -ne 0) { throw 'Safe start/stop test failed.' }

$irOutput = Join-Path $env:TEMP 'nec_ir_decoder_tb.vvp'
& $iverilog -g2012 -s nec_ir_decoder_tb -o $irOutput `
    "$motor\nec_ir_decoder.v" "$motor\nec_ir_decoder_tb.v"
if ($LASTEXITCODE -ne 0) { throw 'Infrared decoder test compilation failed.' }
& $vvp $irOutput
if ($LASTEXITCODE -ne 0) { throw 'Infrared decoder test failed.' }

$remoteOutput = Join-Path $env:TEMP 'remote_drive_commands.vvp'
& $iverilog -g2012 -s remote_drive_commands -o $remoteOutput `
    "$motor\remote_drive_commands.v"
if ($LASTEXITCODE -ne 0) { throw 'Remote command mapping compilation failed.' }

$aiCommandOutput = Join-Path $env:TEMP 'tb_ai_uart_command_receiver.vvp'
& $iverilog -g2012 -s tb_ai_uart_command_receiver -o $aiCommandOutput `
    "$camera\..\perception\common\uart_rx.v" `
    "$motor\ai_uart_command_receiver.v" "$motor\tb_ai_uart_command_receiver.v"
if ($LASTEXITCODE -ne 0) { throw 'AI UART command receiver compilation failed.' }
& $vvp $aiCommandOutput
if ($LASTEXITCODE -ne 0) { throw 'AI UART command receiver test failed.' }

$advancedOutput = Join-Path $env:TEMP 'advanced_features_tb.vvp'
& $iverilog -g2012 -s advanced_features_tb -o $advancedOutput `
    "$motor\remote_drive_commands.v" "$motor\dual_rpm_command_ramp.v" `
    "$motor\red_target_detector.v" "$motor\target_follow_controller.v" `
    "$motor\waypoint_navigation_controller.v" "$motor\PI_controller_fast.v" `
    "$motor\advanced_features_tb.v"
if ($LASTEXITCODE -ne 0) { throw 'Advanced feature test compilation failed.' }
& $vvp $advancedOutput
if ($LASTEXITCODE -ne 0) { throw 'Advanced feature test failed.' }

$integrationOutput = Join-Path $env:TEMP 'car_control_core.vvp'
& $iverilog -g2012 -s car_control_core -o $integrationOutput `
    "$motor\PWM.v" "$motor\DIR.v" "$motor\motor_control.v" `
    "$motor\quadrature_encoder.v" "$motor\speed_measure.v" `
    "$motor\PI_controller.v" "$motor\single_motor_control.v" `
    "$motor\dual_motor_control.v" "$motor\wheel_sync_control.v" `
    "$motor\autonomous_motion_controller.v" "$motor\car_control_core.v" `
    "$motor\tb6612_dual_safe_adapter.v" `
    "$motor\tb6612_quad_safe_adapter.v" `
    "$motor\quad_motor_car_control_core.v"
if ($LASTEXITCODE -ne 0) { throw 'Integrated car control core compilation failed.' }

$quadIntegrationOutput = Join-Path $env:TEMP 'quad_motor_car_control_core.vvp'
& $iverilog -g2012 -s quad_motor_car_control_core -o $quadIntegrationOutput `
    "$motor\PWM.v" "$motor\DIR.v" "$motor\motor_control.v" `
    "$motor\quadrature_encoder.v" "$motor\speed_measure.v" `
    "$motor\PI_controller.v" "$motor\single_motor_control.v" `
    "$motor\quad_motor_control.v" "$motor\wheel_sync_control.v" `
    "$motor\autonomous_motion_controller.v" `
    "$motor\tb6612_quad_safe_adapter.v" `
    "$motor\quad_motor_car_control_core.v"
if ($LASTEXITCODE -ne 0) { throw 'Four-motor integration compilation failed.' }

$quadTbOutput = Join-Path $env:TEMP 'quad_motor_car_control_core_tb.vvp'
& $iverilog -g2012 -s quad_motor_car_control_core_tb -o $quadTbOutput `
    "$motor\PWM.v" "$motor\DIR.v" "$motor\motor_control.v" `
    "$motor\quadrature_encoder.v" "$motor\speed_measure.v" `
    "$motor\PI_controller.v" "$motor\single_motor_control.v" `
    "$motor\quad_motor_control.v" "$motor\wheel_sync_control.v" `
    "$motor\autonomous_motion_controller.v" `
    "$motor\tb6612_quad_safe_adapter.v" `
    "$motor\quad_motor_car_control_core.v" `
    "$motor\quad_motor_car_control_core_tb.v"
if ($LASTEXITCODE -ne 0) { throw 'Four-motor safety test compilation failed.' }
& $vvp $quadTbOutput
if ($LASTEXITCODE -ne 0) { throw 'Four-motor safety test failed.' }

Push-Location $repo
try {
    python -m unittest discover -s edge_ai/tests -v
    if ($LASTEXITCODE -ne 0) { throw 'Edge AI Python tests failed.' }
} finally {
    Pop-Location
}

Write-Output 'PASS all protocol, filter, OSD, motor, navigation, target-follow, and edge-AI checks'
