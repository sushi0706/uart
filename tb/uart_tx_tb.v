`timescale 1ns/1ns
module uart_tx_tb;

	//wires to show the output
	wire tx;	
	wire tx_done;
	
	//reg to drive the inputs
	reg clk;
	reg tx_en;
	reg [7:0] data;
	
	//instance of the design module
	uart_tx uut(.clk_50M(clk),
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
		clk=0;
		tx_en=1'b0;
		#20;
		repeat(20) begin
			data=$urandom_range(128);
			tx_en=1'b1;
			#1000;
			wait(tx_done);
		end
		tx_en=1'b0;

		$display("BAUD RATE:%d",115200);
		$display("Clock Frequency:%d", 50000000);
		$display("CYCLES PER BITS:%d",434);
	end
	
endmodule 