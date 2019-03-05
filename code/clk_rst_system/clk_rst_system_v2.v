`timescale 1ns / 1ps
module clk_rst_system_v2(
	input				i_fpgaclk_p    		,//150mhz
	input 				i_fpgakey_rst  		,
	input				i_fpgasoft_rst 		,
	output				o_fpga_clk_10p		,//level 1	//system_clk
	output				o_fpga_clk_125p 	,
	output				o_fpga_dcm_locked   ,
	output				o_fpga_clk_150p 	,//level 2 
	output				o_fpga_clk_25p		,	
	output				o_fpga_clk_40p		,    
	output				o_fpga_clk_62p5		,   
//--------------------------------------------------- 			
	output				o_tx0_clk			,//DAC_CLK	
	output				o_tx1_clk		    ,
	output				o_tx2_clk		    ,
	output				o_tx3_clk		    ,
	 
    output				o_rst_62p5_m        ,
    output				o_rst_125p_m        ,
	output				o_rst_150p_m        
);


wire 	w_fpga_clk_10p       ;
wire 	w_fpga_clk_25p     	 ;  
wire 	w_fpga_clk_125p      ;
wire 	w_fpga_clk_150p      ;
wire 	w_fpga_clk_40p       ;  
wire 	w_fpga_clk_62p5		 ;
wire 	w_fpga_dcm_locked    ;	
clock_gen u0_clock_gen(
	.inclk0	(i_fpgaclk_p		),
	.c0		(w_fpga_clk_10p		),
	.c1		(w_fpga_clk_25p		),
	.c2		(w_fpga_clk_125p	),
	.c3		(w_fpga_clk_150p	),
	.c4		(w_fpga_clk_40p		),
	.locked (w_fpga_dcm_locked	)
	);
          
assign  o_fpga_clk_10p	 	= w_fpga_clk_10p	;	
assign  o_fpga_clk_25p   	= w_fpga_clk_25p    ;  	    
assign  o_fpga_clk_125p	 	= w_fpga_clk_125p	;     
assign  o_fpga_clk_150p	 	= w_fpga_clk_150p	;   
assign  o_fpga_clk_40p   	= w_fpga_clk_40p    ;//37.5    
assign  o_fpga_clk_62p5		= w_fpga_clk_40p	;//w_fpga_clk_62p5	;
assign  o_fpga_dcm_locked 	= w_fpga_dcm_locked ; 



wire	w_tx0_clk	;
wire	w_tx1_clk	;
wire	w_tx2_clk	;
wire	w_tx3_clk	;	
tx_clock_gen u1_tx_clock_gen(               
	.inclk0	(w_fpga_clk_125p	),    
	.c0		(w_tx0_clk			),    
	.c1		(w_tx1_clk			),    
	.c2		(w_tx2_clk			),    
	.c3		(w_tx3_clk			)       
	);                                
                                                                 
assign  o_tx0_clk		= w_tx0_clk		  ;                                                                                 
assign  o_tx1_clk		= w_tx1_clk		  ;                                   	                                 
assign	o_tx2_clk		= w_tx2_clk		  ;                                   
assign	o_tx3_clk		= w_tx3_clk		  ;                                   
  
//================================================================================
//1.    rst_ctrl_module           
//================================================================================
    wire    w_fpga_rst;         
    assign  w_fpga_rst = i_fpgakey_rst & i_fpgasoft_rst;	
	wire  w_rst_125p_m	; 
	wire  w_rst_150p_m	;  
	wire  w_rst_40p_m;//w_rst_62p5_m  ;
rst_module u0_rst_module(
	.i_fpga_clk2   		(w_fpga_clk_125p	),
	.i_fpga_clk3   		(w_fpga_clk_150p	),
	.i_fpga_clk4   		(w_fpga_clk_40p		),//w_fpga_clk_62p5	),
	.i_fpga_clk    		(i_fpgaclk_p		), 
	.i_fpga_rst    		(w_fpga_rst			),
	.i_dcm_locked  		(w_fpga_dcm_locked	),
	.i_i2c_pll_locked	(w_fpga_dcm_locked	),
	.o_rst_62p5_m  		(w_rst_40p_m		),//w_rst_62p5_m		),
	.o_rst_125p_m  		(w_rst_125p_m		),
	.o_rst_150p_m  		(w_rst_150p_m		)
);

assign o_rst_62p5_m = w_rst_40p_m	  ;//w_rst_62p5_m    ;
assign o_rst_125p_m = w_rst_125p_m    ;
assign o_rst_150p_m = w_rst_150p_m    ;
                                  
endmodule



