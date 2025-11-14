`timescale 1ns/1ns
`include "synch_fifo.v"
module top;
	parameter DEPTH=16;
	parameter DATA_WIDTH=08;
	parameter DATA_PTR=$clog2(DEPTH);

	reg clk,rst,wr_en_i,rd_en_i;
	reg [DATA_WIDTH-1:0]wdata_i;
	wire [DATA_WIDTH-1:0]rdata_o;
	wire full_o,empty_o,overflow_o,underflow_o;
	reg [30*8:0]testname;
	
	integer i;

	synch_fifo #(.DEPTH(DEPTH),.DATA_WIDTH(DATA_WIDTH)) dut(.clk(clk),
														  .rst(rst),
														  .wr_en_i(wr_en_i),
														  .wdata_i(wdata_i),
														  .full_o(full_o),
														  .overflow_o(overflow_o),
														  .rd_en_i(rd_en_i),
														  .rdata_o(rdata_o),
														  .empty_o(empty_o),
														  .underflow_o(underflow_o));

	initial begin
		clk=0;
		forever #5 clk=~clk;
	end

	initial begin
		rstfifo();
		$value$plusargs("testname=%0s",testname);
		case(testname)
			"test_full":begin
			writefifo(0,DEPTH);
			end
			"test_empty":begin
			writefifo(0,DEPTH);
			readfifo(0,DEPTH);
			end
			"test_overflow":begin
			writefifo(0,DEPTH+3);
			readfifo(0,DEPTH);
			end
			"test_underflow":begin
			writefifo(0,DEPTH);
			readfifo(0,DEPTH+2);
			end
			"test_over_under":begin
			writefifo(0,DEPTH+3);
			readfifo(0,DEPTH+2);
			end
		endcase
		#50;
		$finish();
	end

	task rstfifo();
		begin
			rst=1;
			wr_en_i=0;
			wdata_i=0;
			rd_en_i=0;
			repeat(2)@(posedge clk);
			rst=0;
		end
	endtask

	task writefifo(input integer st_loc,ed_loc );
		begin
			for(i=st_loc;i<ed_loc;i=i+1) begin
				@(posedge clk);
				wr_en_i=1;
				wdata_i=$random;
			end
				@(posedge clk);
				wr_en_i=0;
				wdata_i=0;
		end
	endtask

	task readfifo(input integer st_loc,ed_loc);
		begin
			for(i=st_loc;i<ed_loc;i=i+1) begin
				@(posedge clk);
				rd_en_i=1;
				$display("%0t_ns: read_data=%0d",$time,rdata_o);
			end
				@(posedge clk);
				rd_en_i=0;
		end
	endtask
endmodule

		



