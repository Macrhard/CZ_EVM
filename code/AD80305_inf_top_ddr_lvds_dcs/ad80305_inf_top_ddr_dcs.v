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
// Dependencies: AD8030 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ad80305_inf_top_ddr_dcs(
    input                       i_rx_clk_p          ,  
    input                       i_rx_frame_p        ,
    input   [5:0]               i_rx_data_p         ,
	input                       i_fpga_clk_125p		,
	input                       i_fpga_rst_125p		,
	input	[2:0]				i_iq_corr_bypass	,
	input						i_dc_bypass			,
	input						i_dc_set_sw			,
	input  signed [7:0]         i_dc_corr_idata     ,
	input  signed [7:0]         i_dc_corr_qdata     ,	
	output		  [11:0]		o_aver_idata		,
	output		  [11:0]		o_aver_qdata        ,
	
    output                      o_iqdata_fp         ,
    output signed [11:0]		o_idata             ,
    output signed [11:0]		o_qdata             ,
    input                       i_iqdata_fp 		,
    input [11:0]				i_idata             ,
    input [11:0]				i_qdata             ,   
	input                       i_tx_clk			,	       
    output                      o_tx_clk            ,
    output 					    o_tx_frame          ,
    output [5:0]				o_tx_data                      
    );
    
wire        w_rx_iqdata_fp ; 
wire signed [11:0]	w_rx_idata     ; 
wire signed [11:0]	w_rx_qdata     ; 
ad80305_rx_if_ddr_dcs u0_ad80305_rx_if_ddr_dcs(
	.i_rx_clk_p       (i_rx_clk_p		),
	.i_rx_frame_p     (i_rx_frame_p		),
	.i_rx_data_p      (i_rx_data_p		),
	.i_fpga_clk_125p  (i_fpga_clk_125p	),
	.i_fpga_rst_125p  (i_fpga_rst_125p	),
	.o_iqdata_fp      (o_iqdata_fp		),                              
	.o_idata          (o_idata    		),                              
	.o_qdata          (o_qdata    		)                               
    );



    
ad80305_tx_if_ddr_dcs u0_ad80305_tx_if_ddr_dcs(
	.i_fpga_clk               (i_fpga_clk_125p	),
	.i_fpga_rst               (i_fpga_rst_125p	),
	.i_tx_iqdata_fp           (i_iqdata_fp		),
	.i_tx_idata               (i_idata			),
	.i_tx_qdata               (i_qdata			),
	.i_tx_clk                 (i_tx_clk			),
	.o_tx_clk                 (o_tx_clk			),
	.o_tx_frame               (o_tx_frame		),
	.o_tx_data                (o_tx_data		)
    );
        
endmodule    
    
    