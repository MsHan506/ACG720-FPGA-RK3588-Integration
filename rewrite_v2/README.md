# FPGA full rewrite V2

This directory is an independent rewrite. It does not replace or modify the
existing competition design.

## Acceptance boundary

Each stage must pass simulation, synthesis, place-and-route and static timing
before the next stage is added. These checks prove the generated digital
implementation only; RK3588 lock remains a physical measurement.

1. `video_base`: free-running 1280x720p60 colour bars through Gowin DVI TX.
2. `camera_frame`: OV5640 configuration, capture and DDR3 frame buffering.
3. `perception`: ToF/IMU parsing and coherent OSD snapshots.
4. `motion`: safe start/stop, encoder feedback and TB6612 output.
5. `full_system`: integration and hardware acceptance image.

Generated Gowin PLL/DVI/DDR/FIFO files are device dependencies and are not
hand rewritten. All integration and behavioural RTL in this directory is new.

