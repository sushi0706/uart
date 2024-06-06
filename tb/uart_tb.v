`timescale 1ns/1ns
module uart_tb;
	reg clk = 0;
   reg tx_en = 0;
   reg [7:0] data = 0;
	wire tx;
	wire tx_done;
	
   reg rx = 1;
   wire [7:0] rx_msg;
	wire rx_complete;
	
	//takes in input byte and serializes it
	task UART_WRITE;
		input [7:0] in_data;
		integer i;
		begin
			//start bit
			rx<=1'b0;
			#8680;
			
			//data bits
			for(i=0;i<8;i=i+1) begin
				rx<=in_data[i];
				#8680;
			end
			
			//stop bit
			rx<=1'b1;
			#8680;
		end
	endtask
	
	//instance of receiver's design module
	uart_rx RX(.clk_50M(clk),
					  .rx(rx),
					  .rx_msg(rx_msg),
					  .rx_complete(rx_complete));
				
	//instance of transmitter's design module
	uart_tx TX(.clk_50M(clk),
					  .tx_en(tx_en),
					  .data(data),
					  .tx(tx),
					  .tx_done(tx_done));
					  
	//clock generation
	always begin
		#10;
		clk = ~clk;
	end
	
	//run the test sequence
	initial begin
		@(posedge clk);
		repeat(10) begin
			
			//exercise transmitter
			@(posedge clk);
			tx_en<=1'b1;
			data<=$urandom_range(128);
			@(posedge clk);
			tx_en<=1'b0;
			@(posedge tx_done);
			
			//exercise receiver
			@(posedge clk);
			UART_WRITE(data);
			@(posedge clk);
			
			//check if received byte is correct or not
			if(rx_msg==data) $display("correct byte received");
			else $display("incorrect byte received");
		end
		
		$display("BAUD RATE:%d",115200);
		$display("Clock Frequency:%d", 50000000);
		$display("CYCLES PER BITS:%d",434);
	end
	
endmodule 
