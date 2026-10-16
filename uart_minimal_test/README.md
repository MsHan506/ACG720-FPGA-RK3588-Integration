# ACG720-GW5AT60 板载 CH9102 极简 UART 验证工程

当前推荐版本是 `uart_onboard_ch9102_9600_acg720_60b.fs`。
它绕过 P7 和外接 CP2102，只验证以下链路：

```text
FPGA M15 (UART_TX) -> 板载 CH9102 -> 开发板左上角 J2 Type-C -> RK3588 USB
```

M15 和 9600 baud 来自 ACG720 官方《第6章 串口发送模块设计与验证》。旧的
外接 CP2102 版本保留作历史对照，但不再作为当前上板诊断版本。

## 固定输出

- 串口参数：9600 baud、8N1。
- 每秒约 2 行：`ONBOARD_UART_OK\r\n`。
- 每发送完一行，板载 D2（L21）翻转一次。
- 不包含摄像头、DDR、HDMI、传感器、电机或 RK3588 应用代码。
- 不使用外部复位输入。

## 接线

1. 拔掉外接 CP2102，并移除 P7 上的所有杜邦线。
2. 使用一根能够传数据的 Type-C 线连接开发板左上角 `J2` 和 RK3588 的 USB。
3. 不要接开发板右上角靠近 `USB-RST/USB-PGM` 的 `J5`，也不要接右下角
   USB2.0/FX2 接口。

这一版不需要两根杜邦线。

## 构建与烧录文件

构建命令：

```powershell
& 'C:\Gowin\Gowin_V1.9.12.03_x64\IDE\bin\gw_sh.exe' .\build_onboard_ch9102.tcl
```

只烧录下面这个文件：

```text
C:\chatgpt\fpga\uart_minimal_test\impl\pnr\uart_onboard_ch9102_9600_acg720_60b.fs
```

Gowin Programmer 使用 `External Flash Mode 5AT` 和相应的
`exFlash Erase, Program` 操作。完成后将开发板彻底断电，再重新上电。

## RK3588 接收检查

先确认 CH9102 对应的设备节点：

```bash
ls -l /dev/serial/by-id/
dmesg | tail -n 30
ls -l /dev/ttyUSB*
```

若它是 `/dev/ttyUSB0`，执行：

```bash
sudo stty -F /dev/ttyUSB0 9600 cs8 -cstopb -parenb -ixon -ixoff -crtscts raw -echo
sudo timeout 5s cat /dev/ttyUSB0
```

成功时会看到：

```text
ONBOARD_UART_OK
ONBOARD_UART_OK
```

`timeout 5s` 在 5 秒后结束是预期行为；判断成功与否要看结束前是否出现文本。

