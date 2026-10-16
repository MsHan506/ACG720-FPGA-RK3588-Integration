# 极简 UART 工程检查结果

## 板载 CH9102 版本（当前推荐）

- 顶层：`uart_onboard_ch9102_test`
- 输出：`ONBOARD_UART_OK\r\n`，约 2 行/秒，9600 8N1
- 数据链路：FPGA M15 -> 板载 CH9102 -> J2 Type-C -> RK3588 USB
- 外部复位：无
- 状态灯：L21，即板载 D2
- ModelSim：连续两帧消息通过，0 errors、0 warnings
- Gowin：综合、布局布线、位流生成通过
- 最终管脚报告：时钟 Y18、UART_TX M15、D2 L21
- 时序：Setup/Hold 违例端点均为 0，50 MHz 约束下 Fmax 206.478 MHz
- 当前位流：`impl/pnr/uart_onboard_ch9102_9600_acg720_60b.fs`
- 文件大小：17,311,931 bytes
- SHA256：`C5CFBA0D87D8F1DADE23493BE073C6238001CCBABEC46C870EA34746805D360A`

以上结果证明 RTL 仿真和工具实现完成；从板载 CH9102 到 RK3588 的实物接收
结果仍需上板确认。

## 外接 CP2102 V2（历史记录）

- 顶层：`uart_ascii_test_v2`
- 输出：`FPGA_UART_OK\r\n`，约 2 行/秒，115200 8N1
- TX：FPGA E14，即 GPIO0_9
- P7 物理针号未得到官方资料确认，因此此版本不再用于当前接线诊断
- 位流：`impl/pnr/uart_ascii_test_v2_external_cp2102.fs`
- SHA256：`77E750C531A4257B702542FE621A5326599425946B8794B47B1636627F88EF38`

## 固定二进制 V1（历史记录）

- 位流：`impl/pnr/uart_fixed_pattern_acg720_60b.fs`
- SHA256：`4E39E96F978692437AEBAE607D7490616A22F3F2132964C5CDF91F9077B3C9E6`
