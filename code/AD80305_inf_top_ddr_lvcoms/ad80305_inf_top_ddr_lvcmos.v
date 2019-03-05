`timescale 1ps / 1ps
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
// Dependencies: AD80305接口驱动，单独设计一片,时钟和数据采用LVcmos DDR接口
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
////////////////////////////////////////////////                                       
module ad80305_inf_top_ddr_lvcmos(                                                     
    input                       i_rx_clk                            ,
    input                       i_rx_frame                          ,
    input   [11:0]              i_rx_data                           ,
	input                       i_fpga_clk_125p						,
	input                       i_fpga_rst_125p						,
	input       				i_iq_corr_bypass					, 
	input  signed [7:0]         i_dc_corr_idata     ,
	input  signed [7:0]         i_dc_corr_qdata     ,	   
    output                      o_iqdata_fp                         ,
    output [11:0]				o_idata                             ,
    output [11:0]				o_qdata                             ,
    input                       i_iqdata_fp 						,
    input [11:0]				i_idata                             ,
    input [11:0]				i_qdata                             ,              
	input                       i_tx_clk							,
    output                      o_tx_clk                            ,
    output 					    o_tx_frame                          ,
    output [11:0]				o_tx_data                           
    );

wire        w_rx_iqdata_fp ; 
wire [11:0]	w_rx_idata     ; 
wire [11:0]	w_rx_qdata     ;     
ad80305_rx_if_ddr_lvcmos u0_ad80305_rx_if_ddr_lvcmos(
	.i_rx_clk                (i_rx_clk			),
	.i_rx_frame              (i_rx_frame		),
	.i_rx_data               (i_rx_data			),
	.i_fpga_clk_125p         (i_fpga_clk_125p	),
	.i_fpga_rst_125p         (i_fpga_rst_125p	),
	.o_iqdata_fp             (o_iqdata_fp		),
	.o_idata                 (o_idata    		),
	.o_qdata                 (o_qdata    		)
    );


ad80305_tx_if_ddr_lvcmos u0_ad80305_tx_if_ddr_lvcmos( 
	.i_fpga_clk              (i_fpga_clk_125p	),
	.i_fpga_rst              (i_fpga_rst_125p	),
	.i_tx_iqdata_fp          (i_iqdata_fp		),
	.i_tx_idata              (i_idata    		),
	.i_tx_qdata              (i_qdata    		),
	.i_tx_clk                (i_tx_clk			),  
	.o_tx_clk                (o_tx_clk			),
	.o_tx_frame              (o_tx_frame		),
	.o_tx_data               (o_tx_data			)
    );
    
        
endmodule    
    
    