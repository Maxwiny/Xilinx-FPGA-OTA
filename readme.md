[中文](#cn)

<span id="cn">基于Xilinx FPGA的在线升级</span>
===========================

# 简介
&emsp;从上位机采用UART或以太网将位流文件烧写到片外Flash中，利用Xilinx FPGA的Multiboot特性，进行OTA(over the air)在线升级。如升级失败，可以回到原来的位流文件。

# Multiboot功能实现

## 方法1 直接在BIT流中启动
&emsp;只需要在约束文件中添加属性，就可以实现，缺点是只能固化两个位流文件。
在Gold bit中添加：
```xdc
set_property BITSTREAM.CONFIG.CONFIGFALLBACK ENABLE [current_design] 
set_property BITSTREAM.CONFIG.NEXT_CONFIG_ADDR 0x0400000 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design] 
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
```
在Update bit中添加：
```
set_property BITSTREAM.CONFIG.CONFIGFALLBACK ENABLE [current_design] 
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design] 
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
```
其中：

- `CONFIG.CONFIGFALLBACK`       启动回滚
- `CONFIG.NEXT_CONFIG_ADDR`     BIT流下次启动的地址
- `GENERAL.COMPRESS`    Xilinx 7系列的比特流大小一般为定值，但可以使用压缩比特流约束，减小bit流的大小。
- `CONFIG.SPI_BUSWIDTH` 设置SPI位宽，取决于板载FLASH的大小。

### 如何验证是否设置成功
直接使用WINHEX修改updatebit（需要改20位的样子，不能修改关于约束信息的位，会报错），则此时会启动goldbit。
可在`Hardware Device Properties`中看到部分标志位有变化，这里不多介绍。

## 方法2 使用ICAPE2原语
通过状态机发送IPROG指令（internal Program_B）给ICAPE原语，ICAPE原语在接收到这些指令后会根据指定的地址自动加载配置文件。IPROG指令的作用跟外部Program_B管脚的作用类似。        
代码见`rtl\icape2_start`,该模块实现了使用原语发送重配置指令

### 如何调用本模块

```verilog
icap_start icap_inst1(
 	.sclk(clk),
 	.rst_n(rstn),
 	.icap_flag(icap_flag),
 	.icap_done(icap_done) 
);
```
其中：
`icap_flag`给一个高电平脉冲便可启动重配置逻辑。

# 附录1 BIT流说明



# 参考文献
- xapp1233 部分比特流属性的介绍
- UG768	原语手册
- UG470	查找FPGA的设备ID，IPROG与ICAPE2的说明
