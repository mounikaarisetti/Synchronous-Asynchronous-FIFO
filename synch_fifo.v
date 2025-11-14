module synch_fifo(clk,rst,wr_en_i,wdata_i,full_o,overflow_o,rd_en_i,rdata_o,empty_o,underflow_o);
	parameter DEPTH=16;
	parameter DATA_WIDTH=08;
	parameter DATA_PTR=$clog2(DEPTH);

	input clk,rst,wr_en_i,rd_en_i;
	input [DATA_WIDTH-1:0]wdata_i;
	output reg [DATA_WIDTH-1:0]rdata_o;
	output reg full_o,empty_o,overflow_o,underflow_o;

	reg [DATA_WIDTH-1:0] fifo[DEPTH-1:0];
	reg [DATA_PTR-1:0]wr_ptr,rd_ptr;
	reg write_tg_f,read_tg_f;
	integer i;


	always@(posedge clk) begin
		if(rst) begin
			rdata_o=0;
			full_o=0;
			overflow_o=0;
			empty_o=1;
			underflow_o=0;
			wr_ptr=0;
			rd_ptr=0;
			write_tg_f=0;
			read_tg_f=0;
			for(i=0;i<DEPTH;i=i+1) begin
				fifo[i]=0;
			end
		end
		else begin
			overflow_o=0;
			underflow_o=0;
			if(wr_en_i==1) begin
				if(full_o==1) overflow_o=1;
				else begin
					fifo[wr_ptr]=wdata_i;
					if(wr_ptr==DEPTH-1) write_tg_f=~write_tg_f;
					wr_ptr=wr_ptr+1;
				end
			end
			if(rd_en_i==1) begin
				if(empty_o==1) underflow_o=1;
				else begin
					rdata_o=fifo[rd_ptr];
					if(rd_ptr==DEPTH-1) read_tg_f=~read_tg_f;
					rd_ptr=rd_ptr+1;
				end
			end
		end
	end
	always@(*) begin
	 	full_o=0;
		empty_o=0;
		if(wr_ptr==rd_ptr && write_tg_f!=read_tg_f) full_o=1;
		else if(wr_ptr==rd_ptr && write_tg_f==read_tg_f) empty_o=1;
	end
endmodule



