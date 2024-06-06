module uart_tx(input clk_50M,				//main system's 50MHz clock
					input tx_en,				//enable to start sending data
					input [7:0] data,			//input 8 bit data
					output reg tx,				//output serial data
					output reg tx_done);		//high when transmission is done
	
	//external parameters 
	parameter BAUD_RATE=115200;
	parameter PAYLOAD_BITS=8;
	parameter PARITY_BITS=0;
	parameter STOP_BITS=1;
	
	//internal parameters
	parameter CYCLES_PER_BIT=434;
	parameter IDLE=2'b00, START_BIT=2'b01, DATA_BITS=2'b10, STOP_BIT=2'b11;	//FSM states
	
	//internal registers
	reg [1:0] state=IDLE;	//current state
	reg [10:0] cycle_count;	//counts clock cycles for each bit
	reg [3:0] index;			//bit being transmitted
	
	always@(posedge clk_50M) begin
		case(state)
		
			IDLE: begin
				tx_done<=1'b0;
				tx<=1'b1;
				cycle_count<=11'd0;
				if(tx_en==1) begin
					state<=START_BIT;
				end
				else state<=IDLE;
			end
			
			//send out start bit
			START_BIT: begin
				tx<=1'b0;
				//wait CLKS_PER_BIT-1 clock cycles for start bit to finish
				if(cycle_count==CYCLES_PER_BIT) begin
					index<=4'b0000;
					state<=DATA_BITS;
					cycle_count<=11'd0;
				end
				else begin
					cycle_count<=cycle_count+1;
					state<=START_BIT;
				end
			end
			
			//send out data bits
			//wait CLKS_PER_BIT-1 clock cycles for each data bit to finish
			DATA_BITS: begin
				tx<=data[index];
				if(cycle_count==CYCLES_PER_BIT) begin
					cycle_count<=11'd0;
					if(index==7) begin
						index<=0;
						state<=STOP_BIT;
					end
					else begin
						index<=index+1;
						state<=DATA_BITS;
					end
				end
				else begin
					cycle_count<=cycle_count+1;
					state<=DATA_BITS;
				end
			end
			
			//send out stop bit
			STOP_BIT: begin
				tx<=1'b1;
				//wait CLKS_PER_BIT-1 clock cycles for stop bit to finish
				if(cycle_count==CYCLES_PER_BIT) begin
					cycle_count<=11'd0;
					tx_done<=1'b1;
					state<=IDLE;
				end
				else begin
					cycle_count<=cycle_count+1;
					state<=STOP_BIT;
				end
			end
		endcase
	end 
	
endmodule 