/*============================================================================
           Filename : AGC_MODULE.v
             Author : 陈尧
        Description : 数字AGC模块，对输入数据求功率，与门限比较并控制外部PE4302完成AGC     
          Called by : AGC_MODULE
   Revision History : 4/13/2009
                      Revision 1.0
           Copyright(c)2009,COMBA TELECOM TECHNOLOGY(GUANGZHOU)CO.LTD.
============================================================================*/
module  AGC_MODULE_DCS#(
	parameter  WR_CNT = 1024 //36864//18432//511;127;//统一采用峰值控制
)(
    input 				i_clk             ,//工作时钟
    input 				i_rst_n           ,//异步复位信号，低有效  
    input               i_abs_ena		  ,            	               
    input  [31:0]		i_high_gate       ,//输入高门限
    input  [31:0]		i_low_gate        ,//输入低门限
    input  [31:0]		i_power_peak      , 
    input  [ 5:0]       i_agc_ad80305     ,                	               
    input  [ 5:0]	    i_att_value       ,//外部监控设置的输入前端ATT
    input  [ 5:0]	    i_temp_up         ,   
    input  [ 5:0]		i_overflow_agc	  ,//前级前衰后放AGC     
	input  [ 5:0] 		i_gain_control_up ,
	input  [ 5:0]       i_max_gain        ,
	input               i_mcu_clr         ,
	output  			o_read_ad80305	  ,		
	input 				i_read_success	  ,		
	input  [5:0]		i_read_ad80305_value,	
	output [5:0]        o_to_be_set_pulse ,
	output [5:0]        o_set_success_pulse,
	output [6:0]   	    o_agc_value    	  , 
	output				o_agc_att_inc 	  ,		
	output				o_agc_att_dec     ,
	output [ 1:0]   	o_agc_digtial_att   
); 
//------------------------------------------------------------------------------
//AGC_Integerate Part
//------------------------------------------------------------------------------
wire [6:0] w_agc_value; 
AGC_FSM_DCS #(.WR_CNT_VALUE(WR_CNT))
U_AGC_FSM_DCS(
    .i_clk        (i_clk       	), 
    .i_rst_n      (i_rst_n	   	), 
    .i_abs_ena    (i_abs_ena   	),
    .i_high_gate  (i_high_gate 	),
    .i_low_gate   (i_low_gate  	),
    .i_power_peak (i_power_peak	),
    .o_att_value  (w_agc_value 	)
);
assign o_agc_value = w_agc_value ;

//AGC_80305_INF u_AGC_80305_INF(                   
//	.i_clk		 (i_clk	 				 ),   
//	.i_rst_n	 (i_rst_n				 ),
//	.i_manual_gain_ctrl(i_gain_control_up[1:0]),   
//	.i_agc_value ({1'b0,w_agc_value[5:1]}),//63   
//	.o_att_inc	 (o_agc_att_inc			 ),   
//	.o_att_dec	 (o_agc_att_dec			 )
//);           


ad80305_att_set_inf u0_ad80305_att_set_inf(
	.i_clk					(i_clk				),
	.i_rst_n				(i_rst_n			)	,

	.i_temp_value			(i_temp_up			),
	.i_overflow_agc			(i_overflow_agc		),
	.i_gain_value			(i_att_value		),
	.i_att_value 			(i_gain_control_up	),
	.i_agc_value 			(i_agc_ad80305		),

	.i_max_att_value		(i_max_gain			)	,//可设置的最大ATT值，由监控设置
	.i_mcu_clr      		(i_mcu_clr			)	,//清除对ad80305的设置，由监控设置

	.o_to_be_set_pulse		(o_to_be_set_pulse	),//需要设置的脉冲数，调试用
	.o_set_success_pulse	(o_set_success_pulse)	,//已经设置成功的脉冲数，调试用


	.o_read_ad80305			(o_read_ad80305		),//触发一次读取ad80305数据，对象为10c的值
	.i_read_success			(i_read_success		),//回读ad80305成功标志
	.i_read_ad80305_value	(i_read_ad80305_value),//回读的ad80305数值

	.o_dec_value			(o_agc_digtial_att)	,//输出设置在数字域的小数部分

	.o_inc_pulse    		(o_agc_att_inc	)	,
	.o_dec_pulse    		(o_agc_att_dec	)	    
);          
                           
////------------------------------------------------------------------------------
////AGC Decimal Part
////------------------------------------------------------------------------------
//reg signed [5:0] 	r_tmp_gain_sum 	;
//always@(posedge i_clk ) r_tmp_gain_sum 	  <= i_att_value  + i_temp_up ;  
//
//
//reg	[1:0]	r_agc_digtial_att ;
//always@(posedge i_clk ) r_agc_digtial_att <= {1'b0,w_agc_value[0]}+{1'b0,r_tmp_gain_sum[0]}; 
//
//assign o_agc_digtial_att = r_agc_digtial_att ;
                                                

endmodule 

























