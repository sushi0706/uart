module uart_rx(input clk_50M,						//main system's 50MHz clock
	       input rx,						//input serial data
	       output reg [7:0] rx_msg,					//output data byte
	       output reg rx_complete);					//high when data received
					
	//external parameters 
	parameter BAUD_RATE=115200;
	parameter PAYLOAD_BITS=8;
	parameter PARITY_BITS=0;
	parameter STOP_BITS=1;
	
	//internal parameters
	parameter CYCLES_PER_BIT=434;
	parameter IDLE=2'b00, START=2'b01, DATA=2'b10, STOP=2'b11;	//FSM states
	
	//internal registers
	reg [1:0] state=IDLE;			//current state
	reg [3:0] index;			//bit being received
	reg [10:0] cycle_count;			//counts clock cycles for each bit
	reg ff_rx_1=1'b1, ff_rx_2=1'b1;		//additional flip flops
	
	
	//dual flip flop synchronizer 
	//to avoid metastability
	always@(posedge clk_50M) begin
		ff_rx_1<=rx;
		ff_rx_2<=ff_rx_1;
	end
	
	always@(posedge clk_50M) begin
		case(state)
		
			IDLE:begin
				cycle_count<=0;
				rx_complete<=0;
				index<=0;
				if(ff_rx_2) state<=IDLE;
				else state<=START;
			end
			
			//receive start bit
			START:begin
				if(cycle_count==(CYCLES_PER_BIT-1)/2) begin
					if(!ff_rx_2) begin
						state<=DATA;
						cycle_count<=0;
					end
					else state<=IDLE;
				end
				else begin
					cycle_count<=cycle_count+1;
					state<=START;
				end
			end
			
			//receive data bits
			DATA:begin
				if(cycle_count==CYCLES_PER_BIT-1) begin
					rx_msg[index]<=ff_rx_2;
					cycle_count<=0;
					if(index==7) state<=STOP;
					else begin
						index<=index+1;
						state<=DATA;
					end
				end
				else begin
					cycle_count<=cycle_count+1;
					state<=DATA;
				end
			end
			
			//receive stop bit
			STOP:begin
				if(cycle_count==CYCLES_PER_BIT-1) begin
					cycle_count<=0;
					state<=IDLE;
					rx_complete<=1;
				end
				else begin
					cycle_count<=cycle_count+1;
					state<=STOP;
				end
			end
		endcase
	end 
	
endmodule 
