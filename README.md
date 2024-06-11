# UART
Universal Asynchronous Receiver-Transmitter (UART) is one the simplest and oldest forms of device-to-device digital communication. UART is a serial communication protocol that performs parallel to serial data conversion at the transmitter side and serial to parallel data conversion at the receiver side.  
This is a really simple implementation of a UART. It is developed using Quartus Prime Lite and Modelsim.  
It runs using a 50MHz clock and is able to operate 8 bits of serial data with 1 start bit and 1 stop bit.  
## Tools  
Intel Quartus Prime Lite  
Modelsim  
## Parameters  
| **Parameter**  | **Value**  |
|-----------:|--------|
| Baud Rate  | 115200 |
| Data Bits  | 8-bit  |
| Parity Bit | None   |
| Stop Bit   | 1-bit  |  
## Modules  
### uart_rx
```
module uart_rx(
input clk_50M,                          //top level system clock 
input rx,	                        //input serial data  
output reg [7:0] rx_msg,		//output data byte  
output reg rx_complete);		//high when data received  
```
### uart_tx  
```
module uart_tx(
input clk_50M,				//top level system clock
input tx_en,				//enable to start sending data  
input [7:0] data,			//input 8 bit data  
output reg tx,				//output serial data  
output reg tx_done);			//high when transmission is done  
```
