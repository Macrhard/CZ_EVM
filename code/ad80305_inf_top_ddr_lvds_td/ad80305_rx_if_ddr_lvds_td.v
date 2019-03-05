`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: comba
// Engineer: 
// 
// Create Date:     
// Design Name: 
// Module Name:    ad80305_rx_if 
// Project Name: 
// Target Devices: 
// Tool versions:
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ad80305_rx_if_ddr_lvds_td(
    input               i_rx_clk                ,
    input               i_rx_frame              ,
    input   [5:0]       i_rx_data               ,

    input               i_fpga_clk_125p         ,
    input               i_fpga_rst_125p         ,

    output reg          o_iqdata_fp             ,
    output reg [11:0]   o_idata                 ,
    output reg [11:0]   o_qdata                     
    );

//--1,IDD����AD80305 SDR�ӿ�ӿ�?
wire [6:0] w_adc_data;
assign w_adc_data = {i_rx_frame,i_rx_data};
    
wire [6:0] dataout_h; 
wire [6:0] dataout_l; 
        
ad_ddioin_ddr u0_ad_ddioin_ddr(
	.aclr      (!i_fpga_rst_125p	),
	.datain    (w_adc_data	),
	.inclock   (i_rx_clk 	),
	
	.dataout_h (dataout_h 	),
	.dataout_l (dataout_l 	)
	);
	

reg [11:0] r0_dataout_i;
reg [11:0] r0_dataout_q;
always @ (posedge i_rx_clk)
begin
	if(dataout_h[6] == 1'b1)
        begin
        	r0_dataout_q <= {dataout_h[5:0],r0_dataout_q[5:0]};
        end
    else
    	begin
        	r0_dataout_q <= {r0_dataout_q[11:6],dataout_h[5:0]};   		
    	end
end

always @ (posedge i_rx_clk)
begin
	if(dataout_l[6] == 1'b1)
        begin
        	r0_dataout_i <= {dataout_l[5:0],r0_dataout_i[5:0]};
        end
    else 
    	begin
        	r0_dataout_i <= {r0_dataout_i[11:6],dataout_l[5:0]};   		
    	end
end
//

reg [11:0] r1_dataout_i;
reg [11:0] r1_dataout_q;
//always @ (posedge i_rx_clk)
//	r1_dataout_q <= r0_dataout_q;


//reg [11:0] r2_dataout_i;
//reg [11:0] r2_dataout_q;
always @ (posedge i_rx_clk)
begin
	if(dataout_l[6] == 1'b1)
        begin
        	r1_dataout_i <= r0_dataout_i;
        end
    else
    	begin
        	r1_dataout_i <= r1_dataout_i;
    	end
end

//always @ (posedge i_rx_clk)
//begin
//	if(dataout_h[6] == 1'b0)
//        begin
//        	r2_dataout_i <= r1_dataout_i;
//        end
//    else
//    	begin
//        	r2_dataout_i <= r2_dataout_i; 		
//    	end
//end

always @ (posedge i_rx_clk)
begin
	if(dataout_h[6] == 1'b1)
        begin
        	r1_dataout_q <= r0_dataout_q;
        end
    else
    	begin
        	r1_dataout_q <= r1_dataout_q; 		
    	end
end


//--2,ʱ����ת����FPGAʱ����
reg r_wr_en;
always @ (posedge i_rx_clk or negedge i_fpga_rst_125p)
begin
	if(!i_fpga_rst_125p)
		r_wr_en <= 1'b0;
	else if(dataout_h[6] == 1'b0)
		r_wr_en <= 1'b1;
	else
		r_wr_en <= 1'b0;
end

reg [3:0]	r_wr_addr;
always @ (posedge i_rx_clk or negedge i_fpga_rst_125p)
begin
	if(!i_fpga_rst_125p)
		r_wr_addr <= 4'd0;
	else if(dataout_h[6] == 1'b0)
		r_wr_addr <= r_wr_addr + 4'd1;
	else
		r_wr_addr <= r_wr_addr;
end

reg r_wr_en0 ;
always@(posedge i_rx_clk or negedge i_fpga_rst_125p)
	if(!i_fpga_rst_125p)
		r_wr_en0 <=1'd0;
	else if(r_wr_addr==3'd6 )
		r_wr_en0 <= 1'b1 ;
	else
		r_wr_en0 <=r_wr_en0;

reg [1:0] cnt_3;
always @ (posedge i_fpga_clk_125p or negedge i_fpga_rst_125p)
begin
	if(!i_fpga_rst_125p)
		cnt_3 <= 2'd0;
	else if(cnt_3 == 2'd1)
		cnt_3 <= 2'd0;
	else
		cnt_3 <= cnt_3 + 2'd1;
end

reg r_rd_en;
always @ (posedge i_fpga_clk_125p or negedge i_fpga_rst_125p)
begin
	if(!i_fpga_rst_125p)
		r_rd_en <= 1'b0;
	else if(cnt_3 == 2'd0)
		r_rd_en <= 1'b1;
	else
		r_rd_en <= 1'b0;
end

reg [3:0] r_rd_addr;
always @ (posedge i_fpga_clk_125p or negedge i_fpga_rst_125p)
begin
	if(!i_fpga_rst_125p)
		r_rd_addr <= 4'd0;
	else if(!r_wr_en0)
		r_rd_addr <= 4'd0;
	else if(cnt_3 == 2'd0  && r_wr_en0)
		r_rd_addr <= r_rd_addr + 4'd1;
	else
		r_rd_addr <= r_rd_addr;
end

wire [23:0] w_adc_iqdata;
ad_dpram_inf #(
  .BRAM_WIDTH (24),
  .BRAM_DEPTH (16),
  .ADDR_WIDTH (4 )
)u_ad_dpram_inf(
	.i_wr_clk (i_rx_clk 	 			),
	.i_wr_en  (r_wr_en		 			),
	.i_wr_addr(r_wr_addr 				),
	.i_wr_data({r1_dataout_q,r1_dataout_i} 	),
	                    
	.i_rd_clk (i_fpga_clk_125p			),
	.i_rd_en  (r_rd_en     				),	
	.i_rd_addr(r_rd_addr 				),
	.o_rd_data(w_adc_iqdata 			)		
);

reg 		w_iqdata_fp;
reg signed [11:0] w_idata    ;
reg signed [11:0] w_qdata    ;
always @ (posedge i_fpga_clk_125p or negedge i_fpga_rst_125p)
begin
	if(!i_fpga_rst_125p)
		begin
			w_iqdata_fp <= 1'b0;
			w_idata     <= 12'd0;
			w_qdata     <= 12'd0;
		end
	else if(r_rd_en == 1'b1)
		begin
			w_iqdata_fp <= 1'b1;
			w_idata     <= w_idata;
			w_qdata     <= w_qdata;
		end
	else
		begin
			w_iqdata_fp <= 1'b0;
			w_idata     <= w_adc_iqdata[11:0];
			w_qdata     <= w_adc_iqdata[23:12];
		end
end   

always@(posedge i_fpga_clk_125p) o_iqdata_fp  <=  w_iqdata_fp ;
always@(posedge i_fpga_clk_125p) o_idata      <=  w_idata     ;
always@(posedge i_fpga_clk_125p) o_qdata      <=  w_qdata     ;
                    


endmodule                      
            
    	         	
	                 