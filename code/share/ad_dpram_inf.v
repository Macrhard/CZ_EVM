`timescale 1ns / 1ps
/*==============================================================================
Company             : COMBA TELECOM TECHNOLOGY(GUANGZHOU)CO.LTD
Engineer            : 
Create Date         : 
Module Hierarchy    : top function module
Design Name         : ad_dpram_inf.v
Module Name         : ad_dpram_inf
Project Name        : 
Target Devices      : 
Tool versions       : 
Description         : dpram
                     
Dependencies        :                       
Revision            : 0.01 - File Created
Additional Comments :
==============================================================================*/
module ad_dpram_inf #(
	parameter BRAM_WIDTH = 33,
    parameter BRAM_DEPTH = 128 ,
    parameter ADDR_WIDTH = 8         
)(
	input   						i_wr_clk ,
	input   						i_wr_en  ,
	input   	[ADDR_WIDTH-1:0]	i_wr_addr,
	input   	[BRAM_WIDTH-1:0]	i_wr_data,	
	input   						i_rd_clk ,
	input   						i_rd_en  ,
	input   	[ADDR_WIDTH-1:0]	i_rd_addr,
	        	
	output reg	[BRAM_WIDTH-1:0]	o_rd_data
	);
//================================================================================
// 1、INPUT BUFFER                                                                  
//================================================================================ 
	reg		[BRAM_WIDTH-1:0]	r_mem[0:BRAM_DEPTH-1] /* ram_style = "block" */;    ///*synthesis ram_style = "block"*/
integer i ;
initial 
    begin
        for(i=0;i<BRAM_DEPTH;i=i+1)
            r_mem[i] <= 0 ;
    end	
    
//================================================================================
// 2、 dpram operation ctrl
//================================================================================
	reg				r_wr_en;
	reg		[ ADDR_WIDTH-1:0]	r_wr_addr;
	reg		[ BRAM_WIDTH-1:0]	r_wr_data;
	reg		[ ADDR_WIDTH-1:0]	r_rd_addr;	
always @(posedge i_wr_clk)
	r_wr_en <= i_wr_en;
			
always @(posedge i_wr_clk)
	r_wr_addr <= i_wr_addr;	

always @(posedge i_wr_clk)
	r_wr_data <= i_wr_data;	

always @(posedge i_rd_clk)
	r_rd_addr <= i_rd_addr;	
	
//================================================================================
// 3、 dpram
//================================================================================
	//write operation
always @(posedge i_wr_clk)
	if(r_wr_en)
		r_mem[r_wr_addr] <= r_wr_data;

	//read operation
	reg		[BRAM_WIDTH-1:0]	r_rd_data;	
always @(posedge i_rd_clk)
	r_rd_data <= r_mem[r_rd_addr];		
	
//================================================================================ 
// 4、DATA OUTPUT                                                                  
//================================================================================ 
always @(posedge i_rd_clk)
	o_rd_data <= r_rd_data;	
		
//================================================================================						  
endmodule