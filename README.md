# ACG720 FPGA–RK3588 Integration

ACG720-GW5AT60 摄像头、TFmini-S、WT901、电机驱动、编码器反馈及 RK3588 接口的完整工程基线。

## 从这里开始

- [电机控制与 RK3588 集成核对资料](docs/ACG720_电机控制与RK3588集成资料_20261018.md)
- 完整 Gowin 工程：`b_perception/camera/ov5640_ddr3_hdmi_full/`
- 公共电机 RTL：`src/`
- 传感器 RTL 与 Linux 接收工具：`b_perception/`
- 已实测低速发布位流：`b_full_top.fs`

## 证据边界

当前有实车记录的是低速前进、编码器、遥控启停和近障原地转向。速度闭环、完整动作、RK3588→FPGA UART 控制及网口尚未完成实机验收。不要把仿真、综合或生成 `.fs` 当作整车实测通过。

存在 setup 违例的本地 V4 候选没有放入本仓库发布基线。