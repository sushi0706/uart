`timescale 1ns/1ns
module uart_rx_tb;
	
	//wire to show output
	wire [7:0] rx_msg;
	wire rx_complete;
	
	//registers to drive input
	reg clk;
	reg rx;
	
	
	//additional resgisters
	reg [7:0] data;
	integer i;
	integer passes=0, fails=0;
	
	//instance of the design module
	uart_rx uut(.clk_50M(clk),
					.rx(rx),
					.rx_msg(rx_msg),
					.rx_complete(rx_complete));
					
	//run the test sequence
	initial begin
		clk=0;
		repeat(20) begin
			data=$urandom_range(128);
			rx=0;
			#8680;
			for(i=0;i<8;i=i+1) begin
				rx=data[i];
				#8680;
			end
			rx=1;
			#8680;
			
			//check if received byte is correct or not
			if(rx_msg==data) passes=passes+1;
			else fails=fails+1;
		end
		
		$display("BAUD RATE:%d",115200);
		$display("Clock Frequency:%d", 50000000);
		$display("CYCLES PER BITS:%d",434);
	end 
	
	//clock generation
	always begin
		#10;
		clk = ~clk;
	end
	
endmodule 