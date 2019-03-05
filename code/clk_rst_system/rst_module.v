`timescale 1ns / 1ps
/*==============================================================================
Company             : COMBA TELECOM TECHNOLOGY(GUANGZHOU)CO.LTD
Engineer            : 
Create Date         : 
Module Hierarchy    : 
Design Name         : rst_module.v
Module Name         : rst_module
Project Name        : 
Target Devices      : Altera 
Tool versions       : QUARTUSII11.0/Windows XP
Description         :                      
Dependencies        :                       
Revision            : 0.01 - File Created
Additional Comments :
==============================================================================*/
module rst_module(
	input    i_fpga_clk2   		,
	input    i_fpga_clk3   		,
	input    i_fpga_clk4   		,
	input    i_fpga_clk    		,
	input    i_fpga_rst    		,
	input    i_dcm_locked  		,
	input	 i_i2c_pll_locked	,
	output   o_rst_62p5_m  		, 	
	output   o_rst_125p_m  		,
	output   o_rst_150p_m  		
);
//================================================================================
// 1、INPUT BUFFER                                                                  
//================================================================================
 	reg r_rst_buf;//复位信号缓存                         
 	reg [10:0]  cnt_10;                                              
always@( posedge i_fpga_clk or negedge i_fpga_rst)
	if(!i_fpga_rst)
        cnt_10 <= 11'd0;                                                    
    else 
    	if( !i_dcm_locked )                                                                                      
        	cnt_10 <= 11'd0;   
   	 	else 
   	 		if(cnt_10[10] == 1'b1)                                                                                            
        		cnt_10 <= cnt_10;                                                                               
        	else
        		cnt_10 <= cnt_10 + 11'd1;
                                                                                                        
always@( posedge i_fpga_clk or negedge i_fpga_rst)                                                                      
    if( !i_fpga_rst )                                                                                      
        r_rst_buf <= 1'b0;                                             
	else	                                                                                                
		r_rst_buf <= cnt_10[10];                                                                         


	reg r_rst2_n0;
	reg r_rst2_n1;
always@( posedge i_fpga_clk2)
begin
	r_rst2_n0 <= r_rst_buf;
	r_rst2_n1 <= r_rst2_n0;
end
	
	reg r_rst3_n0;
	reg r_rst3_n1;
always@( posedge i_fpga_clk3)
begin
	r_rst3_n0 <= r_rst_buf;
	r_rst3_n1 <= r_rst3_n0;
end



//2013-05-14_add by Liao
	reg r1_rst_buf;//复位信号缓存                                   
 	reg [10:0]  r_cnt_10;                                           
always@( posedge i_fpga_clk or negedge i_fpga_rst)                  
	if(!i_fpga_rst)                                                 
        r_cnt_10 <= 11'd0;                                          
    else                                                            
    	if( !i_i2c_pll_locked )                                     
        	r_cnt_10 <= 11'd0;                                      
   	 	else                                                        
   	 		if(r_cnt_10[10] == 1'b1)                                
        		r_cnt_10 <= r_cnt_10;                               
        	else                                                    
        		r_cnt_10 <= r_cnt_10 + 11'd1;                       
                                                                    
always@( posedge i_fpga_clk or negedge i_fpga_rst)                  
    if( !i_fpga_rst )                                               
        r1_rst_buf <= 1'b0;                                         
	else	                                                        
		r1_rst_buf <= r_cnt_10[10];                                 
                                                                    
                                                                    
	reg r1_rst2_n0;                                                 
	reg r1_rst2_n1;                                                 
always@( posedge i_fpga_clk4)                                       
begin                                                               
	r1_rst2_n0 <= r1_rst_buf;                                       
	r1_rst2_n1 <= r1_rst2_n0;                                       
end                                                                 
	
//================================================================================
// 4、DATA OUTPUT
//================================================================================
    assign o_rst_62p5_m = r1_rst2_n1;
    assign o_rst_125p_m = r_rst2_n1;//w_rst_n2;
    assign o_rst_150p_m = r_rst3_n1;//w_rst_n3;

//================================================================================   		
endmodule
