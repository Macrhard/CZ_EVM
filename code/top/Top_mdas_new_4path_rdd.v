`timescale 1ns / 1ps                  
//==================================================================================================                  
// Company : COMBA TELECOM TECHNOLOGY(GUANGZHOU)CO.LTD                   
// Engineer :                       
// Create Date :  2018-8-23 20:17            
// Design Name : Top_mdas_new_4path_rdd                
// Module Name :                    
// Project Name :                   
// Target Devices : EP4CGX50CF23I7             
// Tool versions :  QUARTUS II 13P0      
// Description : 				
// Dependencies :                                 
// Revision :                    
// Revision 0.01 - File Created                 
// Additional Comments:                                                                                   
//==================================================================================================  
  
module Top_mdas_new_4path_rdd #(
	parameter MAIN_VERSION = 16'b0001_0000_0000_0001,//
	parameter DATE         = 16'h0127 //
)(                                                                                    
    input              		I_fpgaclk_p			 ,//fpga main colck 125MHz                                   	                				                                 	                	        			                             
    input              		I_fpgakey_rst		 ,//key rst	                 
    input              		I_fpgasoft_rst		 ,//soft rst    		                       
	input              		I_rx0_clk        	 ,//AD80305 interface LTE1 LVCMOS DDR            
	input              		I_rx0_frame      	 ,         
	input [11:0]       		I_rx0_data       	 ,                                                                                   
	output             		O_tx0_clk        	 ,         
	output             		O_tx0_frame      	 ,         
	output [11:0]      		O_tx0_data       	 , 	
    output [1:0]			O_ctrl_in0           , 
    output                  O_enable0            , 
    output                  O_enagc0             ,
    output                  O_txnrx0             ,
    output                  O_rst0               ,
    input                   I_ctrl_out0          ,	     	                                                                                                            
	input              		I_rx1_clk        	 ,//AD80305 interface LTE2 LVCMOS DDR               
	input              		I_rx1_frame      	 ,         
	input [11:0]       		I_rx1_data       	 ,                                                                                   
	output             		O_tx1_clk        	 ,         
	output             		O_tx1_frame      	 ,         
	output [11:0]      		O_tx1_data       	 , 
    output [1:0]			O_ctrl_in1           ,
    output                  O_enable1            , 
    output                  O_enagc1             ,
    output                  O_txnrx1             ,
    output                  O_rst1		         ,    	                                         
    input                   I_ctrl_out1          ,
	input                   I_spi_LTE_di         ,
	output                  O_spi_LTE_do         ,
	output                  O_spi_LTE_clk        ,
	output                  O_spi_LTE_cs0        ,
	output                  O_spi_LTE_cs1        ,	        	    	                                                                                            
	input              		I_rx2_clk_p      	 ,  	                  
	input              		I_rx2_frame_p    	 ,         
	input [5:0]        		I_rx2_data_p     	 ,      	  	                                                                          
	output             		O_tx2_clk_p      	 ,         
	output             		O_tx2_frame_p    	 ,         
	output [5:0]       		O_tx2_data_p     	 ,    
    output [1:0]			O_ctrl_in2           ,  
    output                  O_rst2				 ,
    input                   I_ctrl_out2          ,    	        	    	                                                                                                 
	input              		I_rx3_clk_p      	 ,              
	input              		I_rx3_frame_p    	 ,         
	input [5:0]        		I_rx3_data_p     	 ,                                                                                   
	output             		O_tx3_clk_p      	 ,         
	output             		O_tx3_frame_p    	 ,         
	output [5:0]       		O_tx3_data_p     	 ,  	
    output [1:0]			O_ctrl_in3           ,  
    output                  O_rst3				 ,    
    input                   I_ctrl_out3          ,
	input                   I_spi_TD_di          ,
	output                  O_spi_TD_do          ,
	output                  O_spi_TD_clk         ,
	output                  O_spi_TD_cs0         ,
	output                  O_spi_TD_cs1         ,
	
	input           		I_omt_rs232_rx       ,
	output          		O_omt_rs232_tx       , 		
	input                   I_omt_rs232_rxa      ,
	output                  O_omt_rs232_txa      ,		
	input                   I_mcu_omt            ,
	input                   I_mcu_fpga           ,
                                             
	input					I_i2c_scl			 , //I2C    
    inout					IO_i2c_sda			 ,
    output                  o_led0               ,
    output                  o_led1               ,
    output                  o_led2               ,
    output                  o_led4               ,
	
	//cz_spi
	input 					I_cz_spi_di,
	output 					O_cz_spi_do,
	output 					O_cz_spi_clk,
	output					O_cz_spi_cs
);
//------------------------------------------------------------------------------              
//signal Define                                                                               
//------------------------------------------------------------------------------              
wire					w_fpga_clk_10p		 	;	                                          
wire					w_fpga_clk_125p 	 	;	                                          
wire					w_fpga_dcm_locked    	;	                                          
wire					w_fpga_clk_150p 	 	;	                                          
wire					w_fpga_clk_25p		 	;	                                          
wire					w_fpga_clk_40p		 	;//37.5                                       
wire 					w_fpga_clk_62p5			;	                                          
wire					w_fpga_dcm_locked1	 	;	                                          
wire					w_tx0_clk			 	;	                                                                                
wire					w_tx1_clk		     	;	                                                                                  
wire					w_tx2_clk		     	;	                                                                                 
wire					w_tx3_clk		     	;	                                                                                                                            
wire					w_rst_62p5_m         	;	                                          
wire					w_rst_125p_m         	;	                                          
wire					w_rst_150p_m         	;	                                          
//------------------------------------------------------------------------------              
//AD80305 interface                                                                           
wire               		w_iqdata_fp_lte1 		;                                             
wire signed [11:0] 		w_idata_lte1			;                                             
wire signed [11:0] 		w_qdata_lte1			;                                             
wire               		w_iqdata_fp_lte2 		;                                             
wire signed [11:0] 		w_idata_lte2			;                                             
wire signed [11:0] 		w_qdata_lte2			;                                             
wire                	w_iqdata_fp_td 			;                                             
wire signed [11:0]  	w_idata_td				;                                             
wire signed [11:0]  	w_qdata_td				;                                             
wire               		w_iqdata_fp_dcs 		;                                             
wire signed [11:0] 		w_idata_dcs				;                                             
wire signed [11:0] 		w_qdata_dcs				;    

wire               		w_adc_iqdata_fp0 		;                                             
wire signed [11:0] 		w_adc_idata0			;                                             
wire signed [11:0] 		w_adc_qdata0			;   
wire               		w_adc_iqdata_fp1 		;                                             
wire signed [11:0] 		w_adc_idata1			;                                             
wire signed [11:0] 		w_adc_qdata1			; 
wire               		w_adc_iqdata_fp2 		;                                             
wire signed [11:0] 		w_adc_idata2			;                                             
wire signed [11:0] 		w_adc_qdata2			; 
wire               		w_adc_iqdata_fp3		;                                             
wire signed [11:0] 		w_adc_idata3			;                                             
wire signed [11:0] 		w_adc_qdata3			;                                          

wire               		w_dac_lte1_iqdata_fp 	;                                             
wire signed [11:0] 		w_dac_lte1_idata    	;                                             
wire signed [11:0] 		w_dac_lte1_qdata    	;   
wire               		w_dac_lte2_iqdata_fp 	;                                             
wire signed [11:0] 		w_dac_lte2_idata    	;                                             
wire signed [11:0] 		w_dac_lte2_qdata    	; 
wire               		w_dac_wcdma_iqdata_fp  ;                                             
wire signed [11:0] 		w_dac_wcdma_idata    	;                                             
wire signed [11:0] 		w_dac_wcdma_qdata    	; 

wire               		w_adc_lte1_iqdata_fp 	;
wire signed [11:0] 		w_adc_lte1_idata    	;
wire signed [11:0] 		w_adc_lte1_qdata    	;
wire               		w_adc_lte2_iqdata_fp 	;
wire signed [11:0] 		w_adc_lte2_idata    	;
wire signed [11:0] 		w_adc_lte2_qdata    	;
wire               		w_adc_wcdma_iqdata_fp   ;
wire signed [11:0] 		w_adc_wcdma_idata    	;
wire signed [11:0] 		w_adc_wcdma_qdata    	;
                       
wire               		w_dac_iqdata_fp0 		;
wire signed [11:0] 		w_dac_idata0    		;
wire signed [11:0] 		w_dac_qdata0    		;
wire               		w_dac_iqdata_fp1 		;
wire signed [11:0] 		w_dac_idata1    		;
wire signed [11:0] 		w_dac_qdata1    		;
wire               		w_dac_iqdata_fp2 		;
wire signed [11:0] 		w_dac_idata2    		;
wire signed [11:0] 		w_dac_qdata2    		;
wire               		w_dac_iqdata_fp3 		;
wire signed [11:0] 		w_dac_idata3    		;
wire signed [11:0] 		w_dac_qdata3    		;


wire signed [11:0]		w_i_sin_idata			;
wire signed	[11:0]		w_i_sin_qdata			;
wire					w_i_sin_iqdata_fp		;

wire signed	[11:0]		w_o_sin_idata			;
wire signed	[11:0]		w_o_sin_qdata			;
wire signed				w_o_sin_iqdata_fp		;

wire signed	[11:0]		w_i_diff_idata			;
wire signed	[11:0]		w_i_diff_qdata			;
wire signed				w_i_diff_iqdata_fp		;

wire signed [11:0]		w_o_diff_idata			;
wire signed	[11:0]		w_o_diff_qdata			;
wire					w_o_diff_iqdata_fp		;




//NCO                                                                                         
wire signed  [11:0]		w_ddc0_idata	        ; 	                 	                      
wire signed  [11:0]		w_ddc0_qdata	 	    ;             	                              
wire signed  [11:0]		w_ddc1_idata	 	    ;             	                              
wire signed  [11:0]		w_ddc1_qdata	 	    ;             	                              
wire 			    	w_ddc1_data_fp 	 	    ;                                             
wire signed  [11:0]		w_ddc2_idata	 	    ;                                             
wire signed  [11:0]		w_ddc2_qdata	 	    ;                                             
wire 			    	w_ddc2_data_fp 	 	    ;                                             
wire signed  [11:0]		w_duc0_idata	        ;                                             
wire signed  [11:0]		w_duc0_qdata	 	    ;                                             
wire signed  [11:0]		w_duc1_idata	 	    ;                                             
wire signed  [11:0]		w_duc1_qdata	 	    ;                                             
wire 			    	w_duc1_data_fp 	 	    ;                                             
wire signed  [11:0]		w_duc2_idata			;                                             
wire signed  [11:0]		w_duc2_qdata			;   
wire signed  [11:0]		w_duc3_idata			; 
wire signed  [11:0]		w_duc3_qdata			;                                           
wire 			    	w_duc3_data_fp  		;                                             
//DAC  	                                	                                                  
wire		[11:0]		w_ch0_dac_idata     	;                                             
wire		[11:0]		w_ch0_dac_qdata     	;                                             
wire					w_ch0_dac_iqdata_fp 	;                                             
wire		[11:0]		w_ch1_dac_idata     	;                                             
wire		[11:0]		w_ch1_dac_qdata     	;                                             
wire					w_ch1_dac_iqdata_fp 	;                                             
wire		[11:0]		w_ch2_dac_idata     	;                                             
wire		[11:0]		w_ch2_dac_qdata     	;                                             
wire					w_ch2_dac_iqdata_fp 	;                                             
wire		[11:0]		w_ch3_dac_idata     	;                                             
wire		[11:0]		w_ch3_dac_qdata     	;                                             
wire					w_ch3_dac_iqdata_fp 	;                                                                                                              
wire		[11:0]		w_gain0_dac_idata   	;                                             
wire		[11:0]		w_gain0_dac_qdata   	;                                             
wire					w_gain0_dac_iqdata_fp   ;                                             
wire		[11:0]		w_gain1_dac_idata   	;                                             
wire		[11:0]		w_gain1_dac_qdata   	;                                             
wire					w_gain1_dac_iqdata_fp   ;                                             
wire		[11:0]		w_gain2_dac_idata   	;                                             
wire		[11:0]		w_gain2_dac_qdata   	;                                             
wire					w_gain2_dac_iqdata_fp   ;                                             
wire		[11:0]		w_gain3_dac_idata   	;                                             
wire		[11:0]		w_gain3_dac_qdata   	;                                             
wire					w_gain3_dac_iqdata_fp   ;                                             
                                                               
wire		[11:0]		w_dc_gain0_dac_idata   	;                                             
wire		[11:0]		w_dc_gain0_dac_qdata   	;                                             
wire					w_dc_gain0_dac_iqdata_fp;                                             
wire		[11:0]		w_dc_gain1_dac_idata   	;                                             
wire		[11:0]		w_dc_gain1_dac_qdata   	;                                             
wire					w_dc_gain1_dac_iqdata_fp;                                             
wire		[11:0]		w_dc_gain2_dac_idata   	;                                             
wire		[11:0]		w_dc_gain2_dac_qdata   	;                                             
wire					w_dc_gain2_dac_iqdata_fp;                                             
wire		[11:0]		w_dc_gain3_dac_idata   	;                                             
wire		[11:0]		w_dc_gain3_dac_qdata   	;                                             
wire					w_dc_gain3_dac_iqdata_fp;                                             
//------------------------------------------------------------------------------              
//temperature complement                                                                      
wire		[11:0]		w0_gain_adjust_idata  	;//lte1	                                      
wire		[11:0]		w0_gain_adjust_qdata	;	                                          
wire					w0_gain_adjust_data_fp	;	                                          
wire		[11:0]		w1_gain_adjust_idata  	;//lte2	                                      
wire		[11:0]		w1_gain_adjust_qdata	;	                                          
wire					w1_gain_adjust_data_fp	;	                                          
wire		[11:0]		w2_gain_adjust_idata  	;//td	                                      
wire		[11:0]		w2_gain_adjust_qdata	;	                                          
wire					w2_gain_adjust_data_fp	;	                                          
wire		[11:0]		w3_gain_adjust_idata  	;//dcs	                                      
wire		[11:0]		w3_gain_adjust_qdata	;	                                          
wire					w3_gain_adjust_data_fp	;	 

//------------------------------------------------------------------------------              
//uplink gain adjust 0.1db                                                                     
wire		[11:0]		w0_gain_adjust_0p1_idata  	;//lte1	                                      
wire		[11:0]		w0_gain_adjust_0p1_qdata	;	                                          
wire					    w0_gain_adjust_0p1_data_fp	;	                                          
wire		[11:0]		w1_gain_adjust_0p1_idata  	;//lte2	                                      
wire		[11:0]		w1_gain_adjust_0p1_qdata	;	                                          
wire					    w1_gain_adjust_0p1_data_fp	;	                                          	                                          
wire		[11:0]		w2_gain_adjust_0p1_idata  	;//wcdma	                                      
wire		[11:0]		w2_gain_adjust_0p1_qdata	;	                                          
wire					    w2_gain_adjust_0p1_data_fp	;	 

//dnlink gain adjust 0.1db   	                                	                                                                                                                                                             
wire		[11:0]		w_gain0_dac_0p1_idata   	;                                             
wire		[11:0]		w_gain0_dac_0p1_qdata   	;                                             
wire					    w_gain0_dac_0p1_iqdata_fp   ;                                             
wire		[11:0]		w_gain1_dac_0p1_idata   	;                                             
wire		[11:0]		w_gain1_dac_0p1_qdata   	;                                             
wire					    w_gain1_dac_0p1_iqdata_fp   ;                                                                                        
wire		[11:0]		w_gain2_dac_0p1_idata   	;                                             
wire		[11:0]		w_gain2_dac_0p1_qdata   	;                                             
wire					    w_gain2_dac_0p1_iqdata_fp   ;                                            
//------------------------------------------------------------------------------              
//uplink pwr        	                                                                      
wire 		[23:0]  	w0_power_peak 		 	;                                             
wire 		[23:0]  	w1_power_peak 		 	;                                             
wire 		[23:0]  	w2_power_peak 		 	;                                             
wire 		[23:0]  	w3_power_peak 		 	;                                             
wire 		[31:0]  	w0_power_avg 		 	;                                             
wire 		[31:0]  	w1_power_avg 		 	;                                             
wire 		[31:0]  	w2_power_avg 		 	;                                         
wire 		[31:0]  	w3_power_avg 		 	; 
wire 		[31:0]  	w0_power_agc 		 	;   
wire 		[31:0]  	w1_power_agc 		 	;   
wire 		[31:0]  	w2_power_agc 		 	;   
wire 		[31:0]  	w3_power_agc 		 	;                                              
//dnlink_pwr                                                                                  
wire 		[23:0]  	w0_dac_power_peak 		;                                             
wire 		[23:0]  	w1_dac_power_peak 		;                                             
wire 		[23:0]  	w2_dac_power_peak 		;                                             
wire 		[23:0]  	w3_dac_power_peak 		;                                             
wire 		[31:0]  	w0_dac_power_avg 		;                                             
wire 		[31:0]  	w1_dac_power_avg 		;                                             
wire 		[31:0]  	w2_dac_power_avg 		;                                             
wire 		[31:0]  	w3_dac_power_avg 		;                                             
//agc_module & arbiter
//                               
//------------------------------------------------------------------------------              
//------------------------------------------------------------------------------              
//LTE_MIMO          	                                                                          
wire					w_lte_dn_sw   		 	;                                             
wire					w_lte_up_sw   		 	;                                             
wire [7 :0]				w_lte_sp_sel			;                                             
wire [7 :0]				w_lte_slot_sel  		;                                              
wire 					w_lte_dn_before			;                                            
wire [11:0]				w_lte2cpri_iqdata0	 	;  	                                          
wire					w_lte2cpri_iqdata_fp0 	;	                                          
wire [11:0]				w_lte2cpri_iqdata1	 	;  	
wire					w_lte2cpri_iqdata_fp1 	;	
wire [7:0]  			w_pw0_shift  		 	;                                             
wire [1:0]  			w_pw0_selt   		 	;                                             
wire        			w_func_en0_n 		 	;                                             
wire [3:0]				w_slot0_power_sel	 	;                                             
wire [7:0]  			w_pw1_shift  		 	;                                             
wire [1:0]  			w_pw1_selt   		 	;                                             
wire        			w_func_en1_n 		 	;                                             
wire [3:0]				w_slot1_power_sel	 	;                                             
wire [11:0]  			w_plagc0_idata       	; 	                                          
wire [11:0]  			w_plagc0_qdata       	; 	                                          
wire           			w_plagc0_data_fp     	; 	                                          
wire [11:0]  			w_plagc1_idata       	; 	                                          
wire [11:0]  			w_plagc1_qdata       	; 	                                          
wire           			w_plagc1_data_fp     	;                                             
wire [31:0]				w_lte_fram_max_pw0   	;	                                          
wire [15:0]				w_lte_lte0_slot_power	;	                                          
wire [31:0]				w_lte_fram_max_pw1   	;                                             
wire [15:0]				w_lte_lte1_slot_power	;	                                          
wire [7 :0]				w_lte0_plagc_att_value	;                                             
wire [7 :0]				w_lte1_plagc_att_value  ;                                             
//-----------------------------------------------------------------------------               
//TD-SCDMA                                                                                    
wire [11:0]				w_td_iq_data 		 	;			                                  
wire					w_td_iq2cpri_fp		 	;                                             
wire					w_td_dn_sw	    	 	;                                             
wire					w_td_up_sw	    	 	; 
wire					w_td_dn_before			;                                            
wire					w_td_syn			 	;                                             
wire [11:0]				w_td_iqdata				;	                                          
wire    				w_td_iqdata_fp          ;                                             
wire [31:0]				w_td_slot_power		 	;                                             
wire [11:0]		 		w_td_att_idata	     	;    	                                      
wire [11:0]		 		w_td_att_qdata	     	;        	                                  
wire					w_td_att_data_fp     	;                                             
wire [7 :0]				w_td_plagc_att_value	;                                             
//------------------------------------------------------------------------------              
//DCS               	                                                                      
wire 	[6 :0]   		w_gsm_att_value      	;	     	  	                              
wire	[33:0]  		w_shape_dcs_pwr	     	;		  	                                  
wire	[31:0]			w_iqdata_power_average	;                                             
wire	[11:0]			w_gsm2cpri_iqdata	 	;  	                                          
wire					w_gsm2cpri_iqdata_fp 	;	                                          
wire 	[15:0]  		w_gsm_fram_max_pw  	 	;                                             
wire 	[15:0]  		w_gsm_alc_addr    	 	;                                             
wire	[11:0]			w_gsm_dnlink_idata 	 	;	                                          
wire	[11:0]			w_gsm_dnlink_qdata   	;                                             
wire	 				w_gsm_dnlink_data_fp 	;                                             
wire	[11:0]			w_dcs_iqdata			;                                             
wire	[0 :0]			w_dcs_fp    			;	                                          
//------------------------------------------------------------------------------              
wire					w_serdes_recover_clk_a	;                                             
wire					w_serdes_recover_clk_b	;                                             
wire  	[ 1:0]  		w_baud_sel    			;                                             
wire        			w_cpri_lte_fp0		 	;                                             
wire  	[11:0]			w_cpri_lte_iqdata0 		;     
wire        			w_cpri_lte_fp1		 	;                                             
wire  	[11:0]			w_cpri_lte_iqdata1 		;    
wire        			w_cpri_wcdma_fp		 	;                                             
wire  	[11:0]			w_cpri_wcdma_iqdata 	;    
                                        
wire 					w_hfnsync_a	  			;                                             
wire 					w_hfnsync_b	  			;                                             
wire	[ 5:0]			w_fible_syn				;                                             
wire	[1:0] 			rx_dv_a 				;                                             
wire					w_rx_dva				;                                             
wire         			w_rx_era      			;                                             
wire	[7:0]			w_gsm_carrieroff		;                                             
wire	[7:0]			w_gsm_nco_0				;                                             
wire	[7:0]			w_gsm_nco_1             ;                                             
wire	[7:0]			w_gsm_nco_2             ;                                             
wire	[7:0]			w_gsm_nco_3             ;                                             
wire	[7:0]			w_gsm_nco_4             ;                                             
wire	[7:0]			w_gsm_nco_5             ;                                             
wire	[7:0]			w_gsm_nco_6             ;                                             
wire	[7:0]			w_gsm_nco_7             ;                                             
wire    [15:0]			w_td_slot_sel 			;                                             
wire 	[47:0]			w_route_addr  			;                                             
wire	[15:0]			w_last_len    			;                                             
wire	[15:0]			w_most_len    			;                                             
wire  	[15:0]			w_after_delay_rank		;                                             
wire	[15:0]			w_delay_rank  			;                                             
wire	[15:0]			w_vendor_7 	  			;                                             
wire	[15:0]			w_vendor_32	  			;                                             
wire	[15:0]			w_vendor_57   			;                                             
wire                    w_mcu_omt_rx            ;                                             
wire                    w_mcu_omt_tx            ;                                             
//------------------------------------------------------------------------------              
//PA protect                                                                                  
//TD+DCS                            	                                                      
wire 	[0 :0]			w0_lte_pa_off 		  ; 
wire 	[15:0]			w0_lte_peak_power	  ; 
wire	[15:0]			w0_lte_avg_power 	  ; 
wire	[0 :0]			w1_lte_pa_off		  ; 
wire	[15:0]			w1_lte_peak_power	  ; 
wire 	[15:0]			w1_lte_avg_power 	  ;                                             
wire 	[13:0]			w0_ltepaprotect_idata ;                                             
wire	[13:0]			w0_ltepaprotect_qdata ;                                             
wire	[13:0]			w1_ltepaprotect_idata ;                                             
wire	[13:0]			w1_ltepaprotect_qdata ;   

wire 	[13:0]			w1_wpaprotect_idata     ; 
wire 	[13:0]			w1_wpaprotect_qdata     ; 
wire	[0 :0]			w1_wcdma_pa_off		    ; 
wire	[15:0]			w1_wcdma_peak_power     ; 
wire	[15:0]			w1_wcdma_avg_power      ; 

wire 	[13:0]			w1_dpaprotect_idata  	;                                             
wire 	[13:0]			w1_dpaprotect_qdata  	;                                             
wire	[0 :0]			w1_dcs_pa_off			;                                             
wire	[15:0]			w1_dcs_peak_power   	;                                             
wire	[15:0]			w1_dcs_avg_power        ;                                             
//------------------------------------------------------------------------------              
//delay_adjust                                                                                
wire	[11:0]			w_dw_lte_delay_iqdata0	;                                             
wire					w_dw_lte_delay_fp0		;          
wire	[11:0]			w_dw_lte_delay_iqdata1	; 
wire					w_dw_lte_delay_fp1		; 
wire	[11:0]			w_dw_wcdma_delay_iqdata	; 
wire					w_dw_wcdma_delay_fp		; 
                                   
wire	[11:0]			w_dw_td_delay_iqdata	;                                             
wire					w_dw_td_delay_fp		;                                             
wire	[11:0]			w_dw_gsm_delay_iqdata	;                                             
wire					w_dw_gsm_delay_fp		;                                             
wire	[11:0]			w_up_lte_delay_iqdata0	;                                             
wire					w_up_lte_delay_fp0		;    
wire	[11:0]			w_up_lte_delay_iqdata1	;                                             
wire					w_up_lte_delay_fp1		;
wire	[11:0]			w_up_wcdm_delay_iqdata	;                                             
wire					w_up_wcdm_delay_fp		;
                                         
wire	[11:0]			w_up_td_delay_iqdata	;                                             
wire					w_up_td_delay_fp		;                                             
wire	[11:0]			w_up_gsm_delay_iqdata	;                                             
wire					w_up_gsm_delay_fp		;                                             
//------------------------------------------------------------------------------              
//ripple_adjust                                                                               
wire	[11:0]			w_ch0_adc_idata 	  	;                                             
wire	[11:0]			w_ch0_adc_qdata       	;                                             
wire	[0:0]			w_ch0_adc_data_fp		;                                             
wire	[11:0]			w_ch1_adc_idata       	;                                             
wire	[11:0]			w_ch1_adc_qdata 	  	;                                             
wire	[11:0]			w_ch0_adc_ripple_idata 	;                                             
wire	[11:0]			w_ch0_adc_ripple_qdata  ;                                             
wire	[0:0]			w_ch0_adc_ripple_data_fp;                                             
wire	[11:0]			w_ch1_adc_ripple_idata  ;                                             
wire	[11:0]			w_ch1_adc_ripple_qdata 	;                                             
wire	[0:0]			w_ch1_adc_ripple_data_fp;                                             
wire	[11:0]			w1_ch0_dac_idata 	  	;                                             
wire	[11:0]			w1_ch0_dac_qdata       	;                                             
wire	[0 :0]			w1_ch0_dac_data_fp		;                                             
wire	[11:0]			w1_ch1_dac_idata       	;                                             
wire	[11:0]			w1_ch1_dac_qdata 	  	;                                             
wire	[0 :0]			w1_ch1_dac_data_fp		;                                             
wire	[11:0]			w_ch0_dac_ripple_idata 	;                                             
wire	[11:0]			w_ch0_dac_ripple_qdata  ;                                             
wire	[0:0]			w_ch0_dac_ripple_data_fp;                                             
wire	[11:0]			w_ch1_dac_ripple_idata  ;                                             
wire	[11:0]			w_ch1_dac_ripple_qdata 	;                                             
wire	[0 :0]			w_ch1_dac_ripple_data_fp;                                             
//td                                                                                          
wire	[11:0]			w_ch2_adc_idata 	  	;                                             
wire	[11:0]			w_ch2_adc_qdata       	;                                             
wire	[0:0]			w_ch2_adc_data_fp		;                                             
wire	[11:0]			w_ch2_adc_ripple_idata 	;                                             
wire	[11:0]			w_ch2_adc_ripple_qdata  ;                                             
wire	[0:0]			w_ch2_adc_ripple_data_fp;                                             
wire	[11:0]			w1_ch2_dac_idata       	;                                             
wire	[11:0]			w1_ch2_dac_qdata 	  	;                                             
wire	[0 :0]			w1_ch2_dac_data_fp		;                                             
wire	[11:0]			w_ch2_dac_ripple_idata 	;                                             
wire	[11:0]			w_ch2_dac_ripple_qdata 	;                                             
wire	[0 :0]			w_ch2_dac_ripple_data_fp;                                             
wire    [31:0]          w_ripple_power_average  ;                                             
wire 	[11:0]			w_rd_coe_sel_combine	;                                             
wire 	[15:0]			w_rd_coe_combine		;                                             
wire 	[5 :0]			w_rd_addr_combine		;                                             
//------------------------------------------------------------------------------                                                         
//------------------------------------------------------------------------------              
//IO_LED                                                                                      
wire					w_work_led 				;	                                          
//------------------------------------------------------------------------------              
//MCU_BUS                                	                                                  
wire	[7:0 ]			monitor_0x0080          ;                                             
wire	[7:0 ]	        monitor_0x0081          ;                                             
wire	[7:0 ]			monitor_0x0082          ;                                             
wire	[7:0 ]			monitor_0x0083          ;                                             
wire	[7:0 ]			monitor_0x0084          ;                                             
wire	[7:0 ]			monitor_0x0085          ;                                             
wire	[7:0 ]			monitor_0x0086          ;                                             
wire	[7:0 ]			monitor_0x0087          ;                                             
wire	[7:0 ]			monitor_0x0088          ;                                             
wire	[7:0 ]			monitor_0x0089          ;                                             
wire	[7:0 ]			monitor_0x008a          ;                                             
wire	[7:0 ]			monitor_0x008b          ;                                             
wire	[7:0 ]			monitor_0x008c          ;                                             
wire	[7:0 ]			monitor_0x008d          ;                                             
wire	[7:0 ]			monitor_0x008e          ;                                             
wire	[7:0 ]			monitor_0x008f          ;                                             
wire	[7:0 ]			monitor_0x0090          ;                                             
wire	[7:0 ]			monitor_0x0091          ;                                             
wire	[7:0 ]			monitor_0x0092          ;                                             
wire	[7:0 ]			monitor_0x0093          ;                                             
wire	[7:0 ]			monitor_0x0094          ;                                             
wire	[7:0 ]			monitor_0x0095          ;                                             
wire	[7:0 ]			monitor_0x0096          ;                                             
wire	[7:0 ]			monitor_0x0097          ;                                             
wire	[7:0 ]			monitor_0x0098          ;                                             
wire	[7:0 ]			monitor_0x0099          ;                                             
wire	[7:0 ]			monitor_0x009a          ;                                             
wire	[7:0 ]			monitor_0x009b          ;                                             
wire	[7:0 ]			monitor_0x009c          ;                                             
wire	[7:0 ]			monitor_0x009d          ; 
wire	[7:0 ]			monitor_0x009e          ;                                             
wire	[7:0 ]			monitor_0x00a0          ;                                             
wire	[7:0 ]			monitor_0x00a1          ;                                             
wire	[7:0 ]			monitor_0x00a4          ;                                             
wire	[7:0 ]			monitor_0x00a5          ;                                             
wire	[7:0 ]			monitor_0x00a6          ;                                             
wire	[7:0 ]			monitor_0x00a7          ;                                             
wire	[7:0 ]			monitor_0x00a8          ;                                             
wire	[7:0 ]			monitor_0x00a9          ;                                             
wire	[7:0 ]			monitor_0x00aa          ;                                             
wire	[7:0 ]			monitor_0x00ac          ;                                             
wire	[7:0 ]			monitor_0x00ad          ;                                             
wire	[7:0 ]			monitor_0x00ae          ;                                             
wire	[7:0 ]			monitor_0x00b0          ;                                             
wire	[7:0 ]			monitor_0x00b1          ;                                             
wire	[7:0 ]			monitor_0x00b2          ;                                             
wire	[7:0 ]			monitor_0x00b3          ;                                             
wire	[7:0 ]			monitor_0x00b4          ;                                             
wire	[7:0 ]			monitor_0x00b5          ; 
wire	[7:0 ]			monitor_0x00b6          ;  
wire	[7:0 ]			monitor_0x00bb			;    
wire	[7:0 ]			monitor_0x00bc			;
wire	[7:0 ]			monitor_0x00bd			;	
wire	[7:0 ]			monitor_0x00be			;		
wire	[7:0 ]			monitor_0x00bf			;	
wire	[7:0 ]			monitor_0x01bc			;
wire	[7:0 ]			monitor_0x01bd			;	
wire	[7:0 ]			monitor_0x01be			;		
wire	[7:0 ]			monitor_0x01bf			;
wire	[7:0 ]			monitor_0x02bc			;
wire	[7:0 ]			monitor_0x02bd			;	
wire	[7:0 ]			monitor_0x02be			;		
wire	[7:0 ]			monitor_0x02bf			;
	                                        		                                                                                      
wire	[7:0 ]			monitor_0x00c0          ;                                             
wire	[7:0 ]			monitor_0x00c1          ;                                             
wire	[7:0 ]			monitor_0x00c2          ;                                             
wire	[7:0 ]			monitor_0x00c3          ;                                             
wire	[7:0 ]			monitor_0x00c4          ;                                             
wire	[7:0 ]			monitor_0x00c5          ;                                             
wire	[7:0 ]			monitor_0x00c6          ;                                             
wire	[7:0 ]			monitor_0x00c7          ;                                             
wire	[7:0 ]			monitor_0x00c8          ; 
wire	[7:0 ]			monitor_0x01c8			;
wire	[7:0 ]			monitor_0x02c8			;
wire	[7:0 ]			monitor_0x03c8			;

wire	[7:0 ]			monitor_0x00c9          ;
wire	[7:0 ]			monitor_0x00ca          ;
wire	[7:0 ]			monitor_0x00cb          ;
wire	[7:0 ]			monitor_0x00cc          ;
wire	[7:0 ]			monitor_0x00cd          ;
wire	[7:0 ]			monitor_0x00ce          ;
wire	[7:0 ]			monitor_0x01ce          ;
wire	[7:0 ]			monitor_0x01c9          ;
wire	[7:0 ]			monitor_0x01ca          ;
wire	[7:0 ]			monitor_0x01cb          ;
wire	[7:0 ]			monitor_0x01cc          ;
wire	[7:0 ]			monitor_0x01cd          ;

wire	[7:0 ]			monitor_0x02c9          ;
wire	[7:0 ]			monitor_0x03c9          ;                                            
wire	[7:0 ]			monitor_0x00ff          ;                                             
wire	[7:0 ]			monitor_0x0196          ;                                             
wire	[7:0 ]			monitor_0x0197          ;                                             
wire	[7:0 ]			monitor_0x0198          ;                                             
wire	[7:0 ]			monitor_0x0199          ;                                             
wire	[7:0 ]			monitor_0x019a          ;                                             
wire	[7:0 ]			monitor_0x019b          ;                                             
wire	[7:0 ]			monitor_0x019c          ;                                             
wire	[7:0 ]			monitor_0x019d          ;                                             
wire	[7:0 ]			monitor_0x01a0          ;                                             
wire	[7:0 ]			monitor_0x01a1          ;                                             
wire	[7:0 ]			monitor_0x01a4          ;                                             
wire	[7:0 ]			monitor_0x01a5          ;                                             
wire	[7:0 ]			monitor_0x01a6          ;                                             
wire	[7:0 ]			monitor_0x01a7          ;                                             
wire	[7:0 ]			monitor_0x01a8          ;                                             
wire	[7:0 ]			monitor_0x01a9          ;                                             
wire	[7:0 ]			monitor_0x01aa          ;                                             
wire	[7:0 ]			monitor_0x01b0          ;                                             
wire	[7:0 ]			monitor_0x01b1          ;                                             
wire	[7:0 ]			monitor_0x01b2          ;                                             
wire	[7:0 ]			monitor_0x01b3          ;                                             
wire	[7:0 ]			monitor_0x01b4          ;                                             
wire	[7:0 ]			monitor_0x01b5          ;  
wire	[7:0 ]			monitor_0x02b4          ;  
wire	[7:0 ]			monitor_0x02b5          ;                                             
wire	[7:0 ]			monitor_0x0294          ;                                             
wire	[7:0 ]			monitor_0x0295          ;                                             
wire	[7:0 ]			monitor_0x0296          ;                                             
wire	[7:0 ]			monitor_0x0297          ;                                             
wire	[7:0 ]			monitor_0x0298          ;                                             
wire	[7:0 ]			monitor_0x0299          ;                                             
wire	[7:0 ]			monitor_0x029a          ;                                             
wire	[7:0 ]			monitor_0x029b          ;                                             
wire	[7:0 ]			monitor_0x029c          ;                                             
wire	[7:0 ]			monitor_0x029d          ;                                             
wire	[7:0 ]			monitor_0x02a0          ;                                             
wire	[7:0 ]			monitor_0x02a1          ;                                             
wire	[7:0 ]			monitor_0x02a2          ;                                             
wire	[7:0 ]			monitor_0x02a3          ;                                             
wire	[7:0 ]			monitor_0x02a4          ;                                             
wire	[7:0 ]			monitor_0x02a5          ;                                             
wire	[7:0 ]			monitor_0x02a6          ;                                             
wire	[7:0 ]			monitor_0x02a7          ;                                             
wire	[7:0 ]			monitor_0x02a8          ;                                             
wire	[7:0 ]			monitor_0x02a9          ;                                             
wire	[7:0 ]			monitor_0x02aa          ;                                             
wire	[7:0 ]			monitor_0x02ab          ;                                             
wire	[7:0 ]			monitor_0x02ac          ;                                             
wire	[7:0 ]			monitor_0x02ad          ;   
wire	[7:0 ]			monitor_0x00af          ;  
wire	[7:0 ]			monitor_0x02af          ;                                        
wire	[7:0 ]			monitor_0x0394          ;     
wire	[7:0 ]			monitor_0x0395          ;                                           
wire	[7:0 ]			monitor_0x0396          ;                                             
wire	[7:0 ]			monitor_0x0397          ;                                             
wire	[7:0 ]			monitor_0x0398          ;                                             
wire	[7:0 ]			monitor_0x0399          ;                                             
wire	[7:0 ]			monitor_0x039a          ;                                             
wire	[7:0 ]			monitor_0x039b          ;                                             
wire	[7:0 ]			monitor_0x039c          ;                                             
wire	[7:0 ]			monitor_0x039d          ;                                             
wire	[7:0 ]			monitor_0x03a4          ;                                             
wire	[7:0 ]			monitor_0x03a5          ;                                             
wire	[7:0 ]			monitor_0x03a6			;                                             
wire	[7:0 ]			monitor_0x03a7			;                                             
wire	[7:0 ]			monitor_0x03a8			;                                             
wire	[7:0 ]			monitor_0x03a9			;                                             
wire	[7:0 ]			monitor_0x03aa			; 
wire	[7:0 ]			monitor_0x00ab	 		;
wire	[7:0 ]			monitor_0x01ab	 		;
wire	[7:0 ]			monitor_0x01ac			;   	  	
wire	[7:0 ]			monitor_0x03ab			; 
wire	[7:0 ]			monitor_0x03ac			; 
wire	[7:0 ]			monitor_0x03ad			; 
		                                          
wire	[7:0 ]			monitor_0x03b0			;                                             
wire	[7:0 ]			monitor_0x03b1          ;                                             
wire	[7:0 ]			monitor_0x03b2          ;                                             
wire	[7:0 ]			monitor_0x03b3          ;                                             
wire	[7:0 ]			monitor_0x03b4          ;                                             
wire	[7:0 ]			monitor_0x03b5          ;                                             
wire	[7:0 ]			monitor_0x03b6          ;                                             
wire	[7:0 ]			monitor_0x03b7          ;                                             
wire	[7:0 ]			monitor_0x03b8          ;                                             
wire	[7:0 ]			monitor_0x03b9          ;                                             
wire	[7:0 ]			monitor_0x03ba          ;                                             
wire	[7:0 ]			monitor_0x03bb          ;                                             
wire	[7:0 ]			monitor_0x03c0          ;                                             
wire	[7:0 ]			monitor_0x03c1          ;                                             
wire	[7:0 ]			monitor_0x03c2          ;                                             
wire	[7:0 ]			monitor_0x03c3          ;                                             
wire	[7:0 ]			monitor_0x03c4          ;                                             
wire	[7:0 ]			monitor_0x03c5          ;                                             
wire	[7:0 ]			monitor_0x03c6          ;                                             
wire	[7:0 ]			monitor_0x03c7          ;                                             
wire	[7:0 ]			userreg_0x0000          ;                                             
wire	[7:0 ]			userreg_0x0001          ;                                             
wire	[7:0 ]			userreg_0x0010          ;                                             
wire	[7:0 ]			userreg_0x0011          ;                                             
wire	[7:0 ]			userreg_0x0210          ;                                             
wire	[7:0 ]			userreg_0x0211          ;                                             
wire	[7:0 ]			userreg_0x0012          ;                                             
wire	[7:0 ]			userreg_0x0013          ;                                             
wire	[7:0 ]			userreg_0x0014          ;                                             
wire	[7:0 ]			userreg_0x0015          ;                                             
wire	[7:0 ]			userreg_0x0016          ;                                             
wire	[7:0 ]			userreg_0x0017          ;                                             
wire	[7:0 ]			userreg_0x0018          ;                                             
wire	[7:0 ]			userreg_0x0019          ;                                             
wire	[7:0 ]			userreg_0x001a          ;                                             
wire	[7:0 ]			userreg_0x001b          ;                                             
wire	[7:0 ]			userreg_0x001c          ;                                             
wire	[7:0 ]			userreg_0x001d          ;                                             
wire	[7:0 ]			userreg_0x001e          ;                                             
wire	[7:0 ]			userreg_0x0020          ;                                             
wire	[7:0 ]			userreg_0x0021          ;                                             
wire	[7:0 ]			userreg_0x0022          ;   
wire	[7:0 ]			userreg_0x0122          ;                                            
wire	[7:0 ]			userreg_0x0023          ;                                             
wire	[7:0 ]			userreg_0x0024          ;                                             
wire	[7:0 ]			userreg_0x0025          ;                                             
wire	[7:0 ]			userreg_0x0030          ; 
wire	[7:0 ]			userreg_0x0031			;
wire	[7:0 ]			monitor_0x02b0			;
wire	[7:0 ]			monitor_0x02b1			;
wire	[7:0 ]			monitor_0x02b2			;
wire	[7:0 ]			monitor_0x02b3			;                                          
wire	[7:0 ]			userreg_0x003a          ; 
wire	[7:0 ]			userreg_0x013a          ;                                             
wire	[7:0 ]			userreg_0x003b          ;                                             
wire	[7:0 ]			userreg_0x003c          ;                                             
wire	[7:0 ]			userreg_0x003d          ;                                             
wire	[7:0 ]			userreg_0x0040          ;                                             
wire	[7:0 ]			userreg_0x0041          ;                                             
wire	[7:0 ]			userreg_0x0042          ;                                             
wire	[7:0 ]			userreg_0x0043          ;                                             
wire	[7:0 ]			userreg_0x0044          ;                                             
wire	[7:0 ]			userreg_0x0045          ;                                             
wire	[7:0 ]			userreg_0x0046          ;                                             
wire	[7:0 ]			userreg_0x0047          ;                                             
wire	[7:0 ]			userreg_0x0048          ;                                             
wire	[7:0 ]			userreg_0x0049          ;                                             
wire	[7:0 ]			userreg_0x004a          ;                                             
wire	[7:0 ]			userreg_0x004b          ;                                             
wire	[7:0 ]			userreg_0x004c          ;                                             
wire	[7:0 ]			userreg_0x004d          ;                                             
wire	[7:0 ]			userreg_0x004e          ;                                             
wire	[7:0 ]			userreg_0x004f          ;                                             
wire	[7:0 ]			userreg_0x0050			; 
wire	[7:0 ]			userreg_0x0250			;  
wire	[7:0 ]			userreg_0x0350			;                                              
wire	[7:0 ]			userreg_0x0051			;                                             
wire	[7:0 ]			userreg_0x0052			;                                             
wire	[7:0 ]			userreg_0x0053			;                                             
wire	[7:0 ]			userreg_0x0054  		;                                             
wire	[7:0 ]			userreg_0x0055  		;   
wire	[7:0 ]			userreg_0x0056  		; 
wire	[7:0 ]			userreg_0x0057  		;                                            
wire	[7:0 ]			userreg_0x005d  		;  
wire	[7:0 ]			userreg_0x015d  		;                                            
wire	[7:0 ]			userreg_0x0060  		;                                             
wire	[7 :0]			userreg_0x0061		 	;                                             
wire	[7 :0]			userreg_0x0062		 	;                                             
wire	[7 :0]			userreg_0x0063		 	;                                             
wire	[7 :0]			userreg_0x0064		 	;                                             
wire	[7 :0]			userreg_0x0065		 	;
wire	[7 :0]			userreg_0x0066		 	;   
wire	[7 :0]			userreg_0x0067		 	;   
wire	[7 :0]			userreg_0x0068		 	;     
wire	[7 :0]			userreg_0x0069		 	;  
wire	[7 :0]			userreg_0x006a		 	;  
wire	[7 :0]			userreg_0x006b		 	;  
wire	[7 :0]			userreg_0x0166		 	;   
wire	[7 :0]			userreg_0x0167		 	;   
wire	[7 :0]			userreg_0x0168		 	;  
wire	[7 :0]			userreg_0x0169		 	;
wire	[7 :0]			userreg_0x016a		 	;
wire	[7 :0]			userreg_0x016b		 	;                                                
wire	[7 :0]			userreg_0x006c		 	;                                             
wire	[7 :0]			userreg_0x006d		 	;                                             
wire	[7 :0]			userreg_0x006e		 	;                                             
wire	[7 :0]			userreg_0x006f		 	;                                             
wire	[7 :0]			userreg_0x0070		 	;                                             
wire	[7 :0]			userreg_0x0071		 	;                                             
wire	[7 :0]			userreg_0x0072		 	;                                             
wire	[7 :0]			userreg_0x0073		 	;                                             
wire	[7 :0]			userreg_0x0074		 	;                                             
wire	[7 :0]			userreg_0x0075		 	;                                             
wire	[7 :0]			userreg_0x0076 			;                                             
wire	[7 :0]			userreg_0x0077 			;                                             
wire	[7 :0]			userreg_0x0078 			;                                             
wire	[7 :0]			userreg_0x0079 			;                                             
wire	[7 :0]			userreg_0x007a 			;                                             
wire	[7 :0]			userreg_0x007b 			;                                             
wire	[7 :0]			userreg_0x007c 			;                                             
wire	[7 :0]			userreg_0x007d 			; 
wire	[7 :0]			userreg_0x007e 			;                                             
wire	[7 :0]			userreg_0x0112 			;                                             
wire	[7 :0]			userreg_0x0113 			;                                             
wire	[7 :0]			userreg_0x0114 			;                                             
wire	[7 :0]			userreg_0x0115 			;                                             
wire	[7 :0]			userreg_0x0116 			;                                             
wire	[7 :0]			userreg_0x0117 			;                                             
wire	[7 :0]			userreg_0x0118 			;                                             
wire	[7 :0]			userreg_0x0119 			;                                             
wire	[7 :0]			userreg_0x011a 			;                                             
wire	[7 :0]			userreg_0x011b 			;                                             
wire	[7 :0]			userreg_0x011c 			;
wire	[7 :0]			userreg_0x001f			;
wire	[7 :0]			userreg_0x0026          ;
wire	[7 :0]			userreg_0x0125          ;
wire	[7 :0]			userreg_0x0126          ;
wire	[7 :0]			userreg_0x0325          ;
wire	[7 :0]			userreg_0x0326          ;                                             
wire	[7 :0]			userreg_0x011d 			;                                             
wire	[7 :0]			userreg_0x011e 			;                                             
wire	[7 :0]			userreg_0x0120 			;                                             
wire	[7 :0]			userreg_0x0121 			;                                             
wire	[7 :0]			userreg_0x0130 			;                                             
wire	[7 :0]			userreg_0x0140 			;                                             
wire	[7 :0]			userreg_0x0141 			; /*systhesis keep*/                                            
wire	[7 :0]			userreg_0x0144 			;                                             
wire	[7 :0]			userreg_0x014a 			;                                             
wire	[7 :0]			userreg_0x014b 			;                                             
wire	[7 :0]			userreg_0x014e 			;                                             
wire	[7 :0]			userreg_0x014f 			;                                             
wire	[7 :0]			userreg_0x0153 			;                                             
wire	[7 :0]			userreg_0x0154 			;                                             
wire	[7 :0]			userreg_0x0155 			;                                             
wire	[7 :0]			userreg_0x0164 			;                                             
wire	[7 :0]			userreg_0x016c 			;                                             
wire	[7 :0]			userreg_0x016d 			;                                             
wire	[7 :0]			userreg_0x016e 			;                                             
wire	[7 :0]			userreg_0x016f 			;                                             
wire	[7 :0]			userreg_0x0212 			;                                             
wire	[7 :0]			userreg_0x0213 			;                                             
wire	[7 :0]			userreg_0x0214 			;                                             
wire	[7 :0]			userreg_0x0215 			;                                             
wire	[7 :0]			userreg_0x0216 			;                                             
wire	[7 :0]			userreg_0x0217 			;                                             
wire	[7 :0]			userreg_0x0218 			;                                             
wire	[7 :0]			userreg_0x0219 			;                                             
wire	[7 :0]			userreg_0x021a 			;                                             
wire	[7 :0]			userreg_0x021b 			;                                             
wire	[7 :0]			userreg_0x021c 			;                                             
wire	[7 :0]			userreg_0x021d 			;                                             
wire	[7 :0]			userreg_0x021e 			;   
wire	[7 :0]			userreg_0x021f 			;                                            
wire	[7 :0]			userreg_0x0220 			;                                             
wire	[7 :0]			userreg_0x0221 			;                                             
wire	[7 :0]			userreg_0x0222 			;                                             
wire	[7 :0]			userreg_0x0223 			;                                             
wire	[7 :0]			userreg_0x0224 			;                                             
wire	[7 :0]			userreg_0x0225 			;                                             
wire	[7 :0]			userreg_0x0226 			;                                             
wire	[7 :0]			userreg_0x0230 			;                                             
wire	[7 :0]			userreg_0x023a 			;                                             
wire	[7 :0]			userreg_0x023b 			;                                             
wire	[7 :0]			userreg_0x0240 			;                                             
wire	[7 :0]			userreg_0x0241 			;                                             
wire	[7 :0]			userreg_0x024a 			;                                             
wire	[7 :0]			userreg_0x024b 			;                                             
wire	[7 :0]			userreg_0x024e 			;                                             
wire	[7 :0]			userreg_0x024f 			;                                             
wire	[7 :0]			userreg_0x0251 			;                                             
wire	[7 :0]			userreg_0x0252 			;                                             
wire	[7 :0]			userreg_0x0253 			;                                             
wire	[7 :0]			userreg_0x0254 			;                                             
wire	[7 :0]			userreg_0x0255 			;                                             
wire	[7 :0]			userreg_0x0262 			;                                             
wire	[7 :0]			userreg_0x026f 			;                                             
wire	[7 :0]			userreg_0x0277 			;                                             
wire	[7 :0]			userreg_0x0278 			;                                             
wire	[7 :0]			userreg_0x0279 			;                                             
wire	[7 :0]			userreg_0x027a 			;                                             
wire	[7 :0]			userreg_0x027b 			;                                             
wire	[7 :0]			userreg_0x027c 			;                                             
wire	[7 :0]			userreg_0x027d 			;                                             
wire	[7 :0]			userreg_0x027e 			;                                             
wire	[7 :0]			userreg_0x027f 			;                                             
wire	[7 :0]			userreg_0x0312 			;                                             
wire	[7 :0]			userreg_0x0313 			;                                             
wire	[7 :0]			userreg_0x0314 			;                                             
wire	[7 :0]			userreg_0x0315 			;                                             
wire	[7 :0]			userreg_0x0316 			;                                             
wire	[7 :0]			userreg_0x0317 			;                                             
wire	[7 :0]			userreg_0x0318 			;                                             
wire	[7 :0]			userreg_0x0319 			;                                             
wire	[7 :0]			userreg_0x031a 			;                                             
wire	[7 :0]			userreg_0x031b 			;                                             
wire	[7 :0]			userreg_0x031c 			;                                             
wire	[7 :0]			userreg_0x031d 			;                                             
wire	[7 :0]			userreg_0x031e 			;       
wire	[7 :0]			userreg_0x031f			;                                        
wire	[7 :0]			userreg_0x0320 			;                                             
wire	[7 :0]			userreg_0x0321 			;
wire	[7 :0]			userreg_0x0349 			;                                             
wire	[7 :0]			userreg_0x0322 			;                                             
wire	[7 :0]			userreg_0x0324 			;                                             
wire	[7 :0]			userreg_0x0330 			;                                             
wire	[7 :0]			userreg_0x0331 			;                                             
wire	[7 :0]			userreg_0x0332 			;                                             
wire	[7 :0]			userreg_0x0333 			; 
wire	[7 :0]			userreg_0x0034 			; 
wire	[7 :0]			userreg_0x0134 			;                                             
wire	[7 :0]			userreg_0x0334 			;                                             
wire	[7 :0]			userreg_0x0336 			;                                             
wire	[7 :0]			userreg_0x0337 			;                                             
wire	[7 :0]			userreg_0x0338 			;                                             
wire	[7 :0]			userreg_0x0339 			;                                             
wire	[7 :0]			userreg_0x033a 			;                                             
wire	[7 :0]			userreg_0x033b			;                                             
wire	[7 :0]			userreg_0x033c			;                                             
wire	[7 :0]			userreg_0x033d			;                                             
wire	[7 :0]			userreg_0x033e			;                                             
wire 	[7 :0]			userreg_0x033f			;                                             
wire	[7 :0]			userreg_0x0340			;	
wire	[7 :0]			userreg_0x0244			;
wire	[7 :0]			userreg_0x0245			;
wire	[7 :0]			userreg_0x0246			;

wire	[7 :0]			userreg_0x0344			;
wire	[7 :0]			userreg_0x0346			;
wire	[7 :0]			userreg_0x0345			;
wire	[7 :0]			userreg_0x0272			;
wire	[7 :0]			userreg_0x0271			;
wire	[7 :0]			userreg_0x0270			;
wire 	[7 :0]			userreg_0x014c			;
wire	[7 :0]			userreg_0x0348			;
wire	[7 :0]			userreg_0x0347  		;
                                            	
wire	[7 :0]			userreg_0x0341			;	                                          
wire	[7 :0]			userreg_0x0342			;                                             
wire	[7 :0]			userreg_0x0343			;                                             
wire	[7 :0]			userreg_0x0351			;                                             
wire	[7 :0]			userreg_0x0352			;                                             
wire 	[7 :0]			userreg_0x0353			;                                             
wire	[7 :0]			userreg_0x0354			;                                             
wire	[7 :0]			userreg_0x0355			;   

wire	[7 :0]			userreg_0x005e			;                          
wire	[7 :0]			userreg_0x005f			;  
wire	[7 :0]			userreg_0x015e			;  
wire	[7 :0]			userreg_0x015f			;  
wire	[7 :0]			userreg_0x025e			;  
wire	[7 :0]			userreg_0x025f			;   
wire	[7 :0]			userreg_0x035e			; 
wire	[7 :0]			userreg_0x035f			;   
                                         
wire 	[7 :0]			userreg_0x036f			;
wire 	[7 :0]			userreg_0x0027			;
wire 	[7 :0]			userreg_0x0028			;  
wire 	[7 :0]			userreg_0x0128			; 
wire 	[7 :0]			userreg_0x0228			; 
wire 	[7 :0]			userreg_0x0328			; 


wire 	[7 :0]			userreg_0x0029   		;    
wire 	[7 :0]			userreg_0x002a   		; 
wire 	[7 :0]			userreg_0x012a   		; 
wire 	[7 :0]			userreg_0x022a   		; 
wire 	[7 :0]			userreg_0x0127			;
wire 	[7 :0]			userreg_0x0227			;
wire 	[7 :0]			userreg_0x0229			;                                             
                                   	                                                          
//------------------------------------------------------------------------------              
//system clock generate & reset_n signal                                                      
//------------------------------------------------------------------------------    

	wire w_rx0_clk0;
	wire w_rx1_clk0;
	wire w_rx2_clk0;
	wire w_rx3_clk0;
	
	
//clk_rst_system 	u_clk_rst_system(                                                         
clk_rst_system_v2 	u_clk_rst_system_v2(                                                      
	.i_fpgaclk_p    	(I_fpgaclk_p   		),//125mhz                                        
	.i_fpgakey_rst  	(I_fpgakey_rst 		),                                                
	.i_fpgasoft_rst 	(I_fpgasoft_rst		),                                                
	.o_fpga_clk_10p		(w_fpga_clk_10p		),//level 1	//system_clk                          
	.o_fpga_clk_125p 	(w_fpga_clk_125p 	),                                                
	.o_fpga_dcm_locked  (w_fpga_dcm_locked  ),                                                
	.o_fpga_clk_150p 	(w_fpga_clk_150p 	),//level 2                                       
	.o_fpga_clk_25p		(w_fpga_clk_25p		),//                                              
	.o_fpga_clk_40p		(w_fpga_clk_40p		),                                                
	.o_fpga_clk_62p5	(w_fpga_clk_62p5	),                                                
//------------------------------------------------------------------------------                         
	.o_tx0_clk			(w_tx0_clk			),//DAC_CLK	                                                                                  
	.o_tx1_clk		    (w_tx1_clk		    ),                                                                                          
	.o_tx2_clk		    (w_tx2_clk		    ),                                                                                           
	.o_tx3_clk		    (w_tx3_clk		    ),                                                                                                                           
	.o_rst_62p5_m       (w_rst_62p5_m       ),                                                
	.o_rst_125p_m       (w_rst_125p_m       ),                                                
	.o_rst_150p_m       (w_rst_150p_m       )                                                 
);  

                                                                                         
//主板接口2，LVCMOS，时钟为31.25MHz，采样率为31.25MSPS，使用可能：1、LTE2（1.8G）；2、LTE2（1.8G）；3、悬空                                                                                                 
ad80305_inf_top_ddr_lvcmos_31p25 u1_ad80305_inf_top_ddr_lvcmos_31p25(//LTE2 31.25                                     
	.i_rx_clk       	(I_rx1_clk   				), 	                                     
	.i_rx_frame     	(I_rx1_frame				),                                        
	.i_rx_data      	(I_rx1_data					),                                        
	.i_fpga_clk_125p	(w_fpga_clk_125p 			),                                        
	.i_fpga_rst_125p	(w_rst_125p_m       		), 
	.i_dc_bypass		(userreg_0x007e[0]			),
	.i_dc_set_sw        (userreg_0x007e[1]			),
	.i_iq_corr_bypass	( userreg_0x005d[0] 		), 
	.i_dc_corr_idata    (userreg_0x015e     		), 
	.i_dc_corr_qdata	(userreg_0x015f     		), 
	.o_aver_idata		(),
	.o_aver_qdata       (),                                                                               
	.o_idata        	(w_i_sin_idata				),//(w_idata_lte2	 			),                                        
	.o_qdata        	(w_i_sin_qdata				),//(w_qdata_lte2	 			), 
	.o_iqdata_fp    	(w_i_sin_iqdata_fp			),//(w_iqdata_fp_lte2			),                                        
    .i_tx_clk       	(w_tx1_clk		 			),                                        
	.i_idata          	(w_o_sin_idata				),//(w_dac_idata1				),//(w_gain1_dac_0p1_idata   	),//w_duc1_idata       ),                                  
	.i_qdata          	(w_o_sin_qdata				),//(w_dac_qdata1				),//(w_gain1_dac_0p1_qdata   	),//w_duc1_qdata       ),                                  
    .i_iqdata_fp        (w_o_sin_iqdata_fp			),//(w_dac_iqdata_fp1			),//(w_gain1_dac_0p1_iqdata_fp  ),//w_duc1_data_fp     ),                                      
	.o_tx_clk       	(O_tx1_clk  				),                                        
	.o_tx_frame     	(O_tx1_frame				),                                        
	.o_tx_data      	(O_tx1_data 				)                                         
    ); 
    
//从板接口1，LVDS，时钟为62.5MHz，采样率为31.25MSPS，使用可能：1、LTE1(1.8G)；2、LTE1(1.8G)；3、LTE1(2.1G)                                                        
ad80305_inf_top_ddr_dcs u2_ad80305_inf_top_ddr_lvds_lte(//LTE1 31.25                                                
	.i_fpga_clk_125p	(w_fpga_clk_125p 			), 
	.i_fpga_rst_125p	(w_rst_125p_m       		), 
	.i_rx_clk_p        	(I_rx2_clk_p				),
	.i_rx_frame_p      	(I_rx2_frame_p				),
	.i_rx_data_p       	(I_rx2_data_p				),
	.i_dc_bypass		(userreg_0x007e[0]			),
	.i_dc_set_sw        (userreg_0x007e[1]			),
	.i_iq_corr_bypass	(userreg_0x005d[0] 			),  
	.i_dc_corr_idata    (userreg_0x005e     		), 
	.i_dc_corr_qdata	(userreg_0x005f     		), 
	.o_aver_idata		(),
	.o_aver_qdata       (),
	.o_idata         	(w_i_diff_idata				),//(w_idata_lte1	 			),//w_idata_td			),
	.o_qdata         	(w_i_diff_qdata				),//(w_qdata_lte1	 			),//w_qdata_td			),
	.o_iqdata_fp     	(w_i_diff_iqdata_fp			),//(w_iqdata_fp_lte1			),//w_iqdata_fp_td		),                                                                                  
	.i_idata         	(w_o_diff_idata				),//(w_dac_idata2				),//(w_gain0_dac_0p1_idata   	),//w_duc0_idata  		),//w_duc2_idata        ),
	.i_qdata         	(w_o_diff_qdata				),//(w_dac_qdata2				),//(w_gain0_dac_0p1_qdata   	),//w_duc0_qdata  		),//w_duc2_qdata        ),
	.i_iqdata_fp 		(w_o_diff_iqdata_fp			),//(w_dac_iqdata_fp2			),//(w_gain0_dac_0p1_iqdata_fp  ),//w_duc1_data_fp		),//w_duc2_data_fp      ),
	.i_tx_clk			(w_tx2_clk					), 
	.o_tx_clk        	(O_tx2_clk_p   				),
	.o_tx_frame      	(O_tx2_frame_p 				),
	.o_tx_data       	(O_tx2_data_p  				)          
                                                                	                    
    );                                                          	                                                                                   	                                                                                      	
                                                                    	                 
                                                                                                                                                                                                  
                                                                                                              
//------------------------------------------------------------------------------              
//AGC_module                                                                                  
//------------------------------------------------------------------------------  
wire		[5:0]		w0_agc_value   			;  
wire		[5:0]		w2_agc_ad80305   		;
wire		[5:0]		w0_agc_sum_value        ; 
wire 		[1:0]		w0_agc_digtial_att		; 
wire		[5:0]		w1_agc_value   			; 
wire		[5:0]		w1_agc_sum_value        ; 
wire 		[1:0]		w1_agc_digtial_att		; 
wire		[5:0]		w2_agc_value   			; 
wire		[5:0]		w2_agc_sum_value        ; 
wire 		[1:0]		w2_agc_digtial_att		; 
wire		[6:0]		w3_agc_value   			; 
wire		[5:0]		w3_agc_sum_value        ; 
wire 		[1:0]		w3_agc_digtial_att		; 
wire [5:0] w0_to_be_set_pulse;
wire [5:0] w0_set_success_pulse;

wire 	   w_read_ad80305_2			;
wire       w_read_success_2			;
wire [7:0] w_read_ad80305_value_2	;

wire [5:0] w2_to_be_set_pulse;
wire [5:0] w2_set_success_pulse;

wire 	   w_read_ad80305_0			;
wire       w_read_success_0			;
wire [7:0] w_read_ad80305_value_0	;

wire [5:0] w1_to_be_set_pulse;
wire [5:0] w1_set_success_pulse;

wire 	   w_read_ad80305_1;
wire       w_read_success_1;
wire [7:0] w_read_ad80305_value_1;

wire [5:0] w3_to_be_set_pulse;
wire [5:0] w3_set_success_pulse;

wire 	   w_read_ad80305_3;
wire       w_read_success_3;
wire [7:0] w_read_ad80305_value_3;
//lte1
AGC_MODULE  #(.WR_CNT (36864)) //511;//127; 150us
	
u0_AGC_MODULE_LTE0(                                  		  
	.i_clk               (w_fpga_clk_125p		),                                          
	.i_rst_n             (w_rst_125p_m			),        
	.i_abs_ena           (userreg_0x001f[0]		),
	.i_high_gate         ({userreg_0x0017,userreg_0x0016,userreg_0x0015,userreg_0x0014}),                                          
	.i_low_gate          ({userreg_0x001b,userreg_0x001a,userreg_0x0019,userreg_0x0018}),                   		            
	.i_power_peak        (w0_power_agc[31:10] 	),//w0_power_peak[21:0] ),//w0_power_avg_288us  ),                                         
	.i_att_value         (userreg_0x001e[5:0]	),                   		            
	.i_temp_up           (userreg_0x001d[5:0]	),                                         
	.i_gain_control_up   (userreg_0x001c[5:0]	), 
	.i_max_gain          (userreg_0x0025[5:0] 	), 
	.i_mcu_clr           (userreg_0x0026[0]		),
	.o_read_ad80305	     (w_read_ad80305_2		),                                                                                                                                     
	.i_read_success	     (w_read_success_2		),                                                                                                                                     
	.i_read_ad80305_value(w_read_ad80305_value_2),                                                                                                                                    
	.o_to_be_set_pulse   (w0_to_be_set_pulse	),
	.o_set_success_pulse (w0_set_success_pulse	),
	.o_agc_value         (w0_agc_value			),  
	.o_agc_att_inc 	     (O_ctrl_in2[1]			),//(O_ctrl_in0[0]		),//??bit 0/bit1
	.o_agc_att_dec       (O_ctrl_in2[0]			),//(O_ctrl_in0[1]		),
	.o_agc_digtial_att   (w0_agc_digtial_att	) 
); 


//lte2
AGC_MODULE  #(.WR_CNT (36864))
u1_AGC_MODULE(                                   		  
	.i_clk             (w_fpga_clk_125p		),                                          
	.i_rst_n           (w_rst_125p_m		),  
	.i_abs_ena         (userreg_0x001f[0]	),                 		            
	.i_high_gate       ({userreg_0x0117,userreg_0x0116,userreg_0x0115,userreg_0x0114}),                                          
	.i_low_gate        ({userreg_0x011b,userreg_0x011a,userreg_0x0119,userreg_0x0118}),                   		            
	.i_power_peak      (w1_power_agc[31:10] ),//w1_power_peak	),                                         
	.i_att_value       (userreg_0x011e[5:0]	),                   		            
	.i_temp_up         (userreg_0x011d[5:0]	),                                         
	.i_gain_control_up (userreg_0x011c[5:0]	),  
	.i_max_gain        (userreg_0x0125[5:0] ), 
	.i_mcu_clr         (userreg_0x0126[0]	),
	.o_read_ad80305	   (w_read_ad80305_1	),
	.i_read_success	   (w_read_success_1	),
	.i_read_ad80305_value(w_read_ad80305_value_1), 	
	.o_to_be_set_pulse (w1_to_be_set_pulse	),
	.o_set_success_pulse(w1_set_success_pulse),
	.o_agc_value       (w1_agc_value		),  
	.o_agc_att_inc 	   (O_ctrl_in1[1]		),//(O_ctrl_in1[0]		),//??bit 0/bit1
	.o_agc_att_dec     (O_ctrl_in1[0]		),//(O_ctrl_in1[1]		),
	.o_agc_digtial_att (w1_agc_digtial_att	) 	                                                          
); 
                               
                                            
//uplink agc to AD80305 Interface
assign monitor_0x00a9	= { 2'd0,w0_agc_value   	 	};	
assign monitor_0x00aa	= { 6'd0,w0_agc_digtial_att 	};  
assign monitor_0x01a9	= { 2'd0,w1_agc_value   	 	};	
assign monitor_0x01aa	= { 6'd0,w1_agc_digtial_att 	};  
assign monitor_0x00ab   = {2'd0,w0_to_be_set_pulse		};
assign monitor_0x00ac   = {2'd0,w0_set_success_pulse	};
assign monitor_0x01ab   = {2'd0,w1_to_be_set_pulse		};
assign monitor_0x01ac   = {2'd0,w1_set_success_pulse	};
//------------------------------------------------------------------------------
//SPI                                                                  
//------------------------------------------------------------------------------
wire 			w_rd_en      	;
wire 			w_wr_en         ;
wire [9:0]		w_rw_addr       ;
wire [2:0]		w_mod_sel_mcu   ;
wire [7:0]		w_wr_data_mcu   ;
wire [1:0]		w_rw_chip_mcu   ;

wire [7:0]		rw_result	    ;
wire [7:0]		rw_data	        ;

wire [7:0]		w_data_to_mcu   ;
wire 			w_success_to_mcu;
spi_arbitration u0_spi_arbitration(
	.i_clk			    (w_fpga_clk_125p	),
	.i_rst_n			(w_rst_125p_m		),
	
	.i_rd_en_mcu     	(userreg_0x0077[0]	),
	.i_wr_en_mcu     	(userreg_0x0078[0]	),
	.i_mod_sel_mcu   	(userreg_0x0079[2:0]),
	.i_rw_chip_mcu   	(userreg_0x007d[1:0]),
	.i_rw_addr_mcu   	({userreg_0x007b[1:0],userreg_0x007a[7:0]}	),
	.i_wr_data_mcu   	(userreg_0x007c[7:0]),	
	.i_rd_en_fpga0    	(w_read_ad80305_0	),
    .i_rd_en_fpga1    	(w_read_ad80305_1	),                                        
	.o_rd_en         	(w_rd_en      		),
	.o_wr_en         	(w_wr_en      		),
	.o_rw_addr       	(w_rw_addr    		),
	.o_mod_sel_mcu   	(w_mod_sel_mcu		),
	.o_wr_data_mcu   	(w_wr_data_mcu		),
	.o_rw_chip_mcu   	(w_rw_chip_mcu		),
	.i_return_success	(rw_result   		),
	.i_return_data   	(rw_data	 		),
	.o_data_to_fpga0   	(w_read_ad80305_value_0 ),
	.o_success_to_fpga0	(w_read_success_0		),
	.o_data_to_fpga1   	(w_read_ad80305_value_1	),
	.o_success_to_fpga1	(w_read_success_1	),	
	.o_data_to_mcu    	(w_data_to_mcu		),
	.o_success_to_mcu 	(w_success_to_mcu	)


	); 

assign  monitor_0x02c8 = w_read_ad80305_value_0;
assign  monitor_0x01c8 = w_read_ad80305_value_1;
////------------------------------------------------------------------------------
////AD80305 SPI interface                                                                   
////------------------------------------------------------------------------------
spi_interface u0_spi_interface(
	.i_fpga_clk_125p	(w_fpga_clk_125p),
	.i_fpga_rst_125p	(w_rst_125p_m	),	
	.i_rd_en            (w_rd_en		),
	.i_wr_en            (w_wr_en		),
	.i_mod_sel			(w_mod_sel_mcu	),
	.i_chip_sel         (w_rw_chip_mcu	),
	.i_addr				(w_rw_addr		),
	.i_data             (w_wr_data_mcu	),
	.o_rw_result        (rw_result   	),
	.o_rw_data          (rw_data    	),
	.i_ad80305_do       (I_spi_LTE_di	),//I_spi_di 					
	.o_ad80305_di       (O_spi_LTE_do	),//O_spi_do 					
	.o_ad80305_clk      (O_spi_LTE_clk  ),//O_spi_clk					
	.o_ad80305_cs0      (O_spi_LTE_cs0  ),//O_spi_cs0					
	.o_ad80305_cs1		(O_spi_LTE_cs1  ),//O_spi_cs1					
   
    );
    
assign monitor_0x0094 = w_success_to_mcu;
assign monitor_0x0095 = w_data_to_mcu  ;

	wire [5:0] w_agc_ad80305 ;
//wcdma
//AGC_MODULE #(.WR_CNT (36864)) 
//u2_AGC_MODULE(                                   		  
//	.i_clk               	(w_fpga_clk_125p		),                                          
//	.i_rst_n             	(w_rst_125p_m			),        
//	.i_abs_ena           	( userreg_0x001f[0]		),
//	.i_high_gate         	({userreg_0x0217,userreg_0x0216,userreg_0x0215,userreg_0x0214}),                                          
//	.i_low_gate          	({userreg_0x021b,userreg_0x021a,userreg_0x0219,userreg_0x0218}),                   		            
//	.i_power_peak        	(w2_power_agc[31:10]    ),//w2_power_peak[21:0] 	),//w0_power_avg_288us  ),                                         
//	.i_att_value         	(userreg_0x021e[5:0]	),                   		            
//	.i_temp_up           	(userreg_0x021d[5:0]	),                                         
//	.i_gain_control_up   	(userreg_0x021c[5:0]	), 
//	.i_max_gain          	(userreg_0x0225[5:0] 	), 
//	.i_mcu_clr           	(userreg_0x0226[0]		),
//	.o_read_ad80305	     	(w_read_ad80305_2		),
//	.i_read_success	     	(w_read_success_2		),
//	.i_read_ad80305_value	(w_read_ad80305_value_2 ),
//	.o_to_be_set_pulse 		(w2_to_be_set_pulse		),
//	.o_set_success_pulse	(w2_set_success_pulse	),
//	.o_agc_value       		(w2_agc_value			),
//	.o_agc_att_inc 	   		(O_ctrl_in2[1]			),
//	.o_agc_att_dec     		(O_ctrl_in2[0]			),
//	.o_agc_digtial_att 		(w2_agc_digtial_att		) 
//); 



//AGC_MODULE_DCS #(.WR_CNT (512)) u3_AGC_MODULE_DCS(                                   		  
//	.i_clk             		(w_fpga_clk_125p		),                                          
//	.i_rst_n           		(w_rst_125p_m			),  
//	.i_abs_ena         		(userreg_0x001f[0]		),                 		            
//	.i_high_gate       		({userreg_0x0217,userreg_0x0216,userreg_0x0215,userreg_0x0214}),                                          
//	.i_low_gate        		({userreg_0x021b,userreg_0x021a,userreg_0x0219,userreg_0x0218}),                   		            
//	.i_power_peak      		(w2_power_peak[21:0]	), 
//	.i_agc_ad80305          (w2_agc_ad80305          ), 
//	.i_overflow_agc		 	(userreg_0x021f[5:0]	),                               
//	.i_att_value       		(userreg_0x021e[5:0]	),                   		            
//	.i_temp_up         		(userreg_0x021d[5:0]	),                                         
//	.i_gain_control_up 		(userreg_0x021c[5:0]	),  
//	.i_max_gain        		(userreg_0x0225[5:0] 	), 
//	.i_mcu_clr         		(userreg_0x0226[0]		),
//	.o_read_ad80305	   		(w_read_ad80305_2		),
//	.i_read_success	   		(w_read_success_2		),
//	.i_read_ad80305_value	(w_read_ad80305_value_2	),
//	.o_to_be_set_pulse 		(w2_to_be_set_pulse		),
//	.o_set_success_pulse	(w2_set_success_pulse	),
//	.o_agc_value       		(w2_agc_value			),
//	.o_agc_att_inc 	   		(O_ctrl_in2[1]			),
//	.o_agc_att_dec     		(O_ctrl_in2[0]			),//(O_ctrl_in1[1]		),
//	.o_agc_digtial_att 		(w2_agc_digtial_att		) 	                                                          
//); 
                               
                                            
//uplink agc to AD80305 Interface
assign monitor_0x02a9	= { 2'd0,w2_agc_value   	};	
assign monitor_0x02aa	= { 6'd0,w2_agc_digtial_att };  
assign monitor_0x03a9	= { 1'd0,w3_agc_value   	};	
assign monitor_0x03aa	= { 6'd0,w3_agc_digtial_att };  
assign monitor_0x02ab   = {2'd0,w2_to_be_set_pulse	};
assign monitor_0x02ac   = {2'd0,w2_set_success_pulse};
assign monitor_0x03ab   = {2'd0,w3_to_be_set_pulse	};
assign monitor_0x03ac   = {2'd0,w3_set_success_pulse};
//------------------------------------------------------------------------------
//SPI                                                                
//------------------------------------------------------------------------------
wire 			w1_rd_en      	;
wire 			w1_wr_en         ;
wire [9:0]		w1_rw_addr       ;
wire [2:0]		w1_mod_sel_mcu   ;
wire [7:0]		w1_wr_data_mcu   ;
wire [1:0]		w1_rw_chip_mcu   ;
wire [7:0]		rw1_result	    ;
wire [7:0]		rw1_data	        ;
wire [7:0]		w1_data_to_mcu   ;
wire 			w1_success_to_mcu;
spi_arbitration u1_spi_arbitration(
	.i_clk			    (w_fpga_clk_125p		),
	.i_rst_n			(w_rst_125p_m			),	
	.i_rd_en_mcu     	( userreg_0x0277[0]		),
	.i_wr_en_mcu     	( userreg_0x0278[0]		),
	.i_mod_sel_mcu   	( userreg_0x0279[2:0]	),
	.i_rw_chip_mcu   	( userreg_0x027d[1:0]	),
	.i_rw_addr_mcu   	({userreg_0x027b[1:0],userreg_0x027a[7:0]}	),
	.i_wr_data_mcu   	( userreg_0x027c[7:0]						),
	.i_rd_en_fpga0    	(w_read_ad80305_2		),
    .i_rd_en_fpga1    	(w_read_ad80305_3		),                                       
	.o_rd_en         	(w1_rd_en      			),
	.o_wr_en         	(w1_wr_en      			),
	.o_rw_addr       	(w1_rw_addr    			),
	.o_mod_sel_mcu   	(w1_mod_sel_mcu			),
	.o_wr_data_mcu   	(w1_wr_data_mcu			),
	.o_rw_chip_mcu   	(w1_rw_chip_mcu			),
	.i_return_success	(rw1_result   			),
	.i_return_data   	(rw1_data	 			),
	.o_data_to_fpga0   	(w_read_ad80305_value_2 ),
	.o_success_to_fpga0	(w_read_success_2		),
	.o_data_to_fpga1   	(w_read_ad80305_value_3	),
	.o_success_to_fpga1	(w_read_success_3		),
	.o_data_to_mcu    	(w1_data_to_mcu			),
	.o_success_to_mcu 	(w1_success_to_mcu		)
	); 

assign  monitor_0x00c8 = w_read_ad80305_value_2;
assign  monitor_0x03c8 = w_read_ad80305_value_3;
////------------------------------------------------------------------------------
////AD80305 SPI interface                                                                   
////------------------------------------------------------------------------------

spi_interface u1_spi_interface(
	.i_fpga_clk_125p		(w_fpga_clk_125p),
	.i_fpga_rst_125p		(w_rst_125p_m	),	
	.i_rd_en                (w1_rd_en		),
	.i_wr_en                (w1_wr_en		),
	.i_mod_sel			    (w1_mod_sel_mcu	),
	.i_chip_sel             (w1_rw_chip_mcu	),
	.i_addr				    (w1_rw_addr		),
	.i_data                 (w1_wr_data_mcu	),
	.o_rw_result            (rw1_result   	),
	.o_rw_data              (rw1_data    	),
	.i_ad80305_do           (I_spi_TD_di	),
	.o_ad80305_di           (O_spi_TD_do	),
	.o_ad80305_clk          (O_spi_TD_clk   ),
	.o_ad80305_cs0          (O_spi_TD_cs0   ),
	.o_ad80305_cs1		    (O_spi_TD_cs1   ) 
   
    );
    
assign monitor_0x0294 = w1_success_to_mcu;//??????
assign monitor_0x0295 = w1_data_to_mcu  ;           
                                                                                                                                                                                                                                                     
   
        
//------------------------------------------------------------------------------              
//LED display                                                                                 
//------------------------------------------------------------------------------  	          
led_display_module u_led_display_module(
  .i_fpga_clk 		(w_fpga_clk_125p	),
  .i_rst_n    		(w_rst_125p_m   	),
  .i_fpga_workin	(userreg_0x0000		),
  .o_fpga_workout   (monitor_0x00ff		),
  .o_work_led 		(w_work_led			)   
);                                                              
//------------------------------------------------------------------------------
//FPGA_IO_Interface
//------------------------------------------------------------------------------	
assign O_enable0   	  =	userreg_0x006c[0]   ;                  
assign O_enagc0    	  =	userreg_0x006d[0]   ;                  
assign O_txnrx0    	  =	userreg_0x006e[0]   ;                  
assign O_rst0      	  =	userreg_0x006f[0]   ;                  
assign O_enable1   	  =	userreg_0x016c[0]   ;                  
assign O_enagc1    	  =	userreg_0x016d[0]   ;                  
assign O_txnrx1    	  =	userreg_0x016e[0]   ;                  
assign O_rst1      	  =	userreg_0x016f[0]   ;                     
assign O_rst2      	  =	userreg_0x026f[0]   ;                  
assign O_rst3      	  =	userreg_0x036f[0]   ;                  
assign o_led0 		  = w_work_led		    ;                  
assign o_led4 		  = !w_fible_syn[0]     ; 
//------------------------------------------------------------------------------
//FPGA_Version                                                              
//------------------------------------------------------------------------------
assign {monitor_0x0082,monitor_0x0081} = MAIN_VERSION ;
assign {monitor_0x0084,monitor_0x0083} = DATE 		  ;	          
//------------------------------------------------------------------------------              
//MCU_BUS -------------Register                                                               
//------------------------------------------------------------------------------              
iic_slave_module u_iic_slave_module(                                                          
	.i_fpga_clk   	(w_fpga_clk_62p5 	), //62.5MHz-->125MHz                                 
	.i_rst_n      	(w_rst_62p5_m    	),                                                    
	.i_i2c_scl    	(I_i2c_scl   	 	),                                                    
	.io_i2c_sda   	(IO_i2c_sda  	 	),                                                    
	.userreg_0x0000 (userreg_0x0000		),                                                    
	.userreg_0x0001 (userreg_0x0001		),//reserved version                                  
	.userreg_0x0010 (userreg_0x0010 	),                                                    
	.userreg_0x0011 (userreg_0x0011 	),                                                    
	.userreg_0x0210 (userreg_0x0210 	),                                                    
	.userreg_0x0211 (userreg_0x0211 	),                                                    
	.userreg_0x0012 (userreg_0x0012    	),                                                    
	.userreg_0x0112 (userreg_0x0112    	),                                                    
	.userreg_0x0212 (userreg_0x0212    	),                                                    
	.userreg_0x0312 (userreg_0x0312    	),                                                    
	.userreg_0x0013 (userreg_0x0013    	),                                                    
	.userreg_0x0113 (userreg_0x0113    	),                                                    
	.userreg_0x0213 (userreg_0x0213    	),                                                    
	.userreg_0x0313 (userreg_0x0313    	),                                                    
	.userreg_0x0014 (userreg_0x0014    	),                                                    
	.userreg_0x0114 (userreg_0x0114    	),                                                    
	.userreg_0x0214 (userreg_0x0214    	),                                                    
	.userreg_0x0314 (userreg_0x0314    	),                                                    
	.userreg_0x0015 (userreg_0x0015    	),                                                    
	.userreg_0x0115 (userreg_0x0115    	),                                                    
	.userreg_0x0215 (userreg_0x0215    	),                                                    
	.userreg_0x0315 (userreg_0x0315    	),                                                    
	.userreg_0x0016 (userreg_0x0016    	),                                                    
	.userreg_0x0116 (userreg_0x0116    	),                                                    
	.userreg_0x0216 (userreg_0x0216    	),                                                    
	.userreg_0x0316 (userreg_0x0316    	),                                                    
	.userreg_0x0017 (userreg_0x0017    	),                                                    
	.userreg_0x0117 (userreg_0x0117    	),                                                    
	.userreg_0x0217 (userreg_0x0217    	),                                                    
	.userreg_0x0317 (userreg_0x0317    	),                                                    
	.userreg_0x0018 (userreg_0x0018    	),                                                    
	.userreg_0x0118 (userreg_0x0118    	),                                                    
	.userreg_0x0218 (userreg_0x0218    	),                                                    
	.userreg_0x0318 (userreg_0x0318    	),                                                    
	.userreg_0x0019 (userreg_0x0019    	),                                                    
	.userreg_0x0119 (userreg_0x0119    	),                                                    
	.userreg_0x0219 (userreg_0x0219    	),                                                    
	.userreg_0x0319 (userreg_0x0319    	),                                                    
	.userreg_0x001a (userreg_0x001a    	),                                                    
	.userreg_0x011a (userreg_0x011a    	),                                                    
	.userreg_0x021a (userreg_0x021a    	),                                                    
	.userreg_0x031a (userreg_0x031a    	),                                                    
	.userreg_0x001b (userreg_0x001b    	),                                                    
	.userreg_0x011b (userreg_0x011b    	),                                                    
	.userreg_0x021b (userreg_0x021b    	),                                                    
	.userreg_0x031b (userreg_0x031b    	),                                                    
	.userreg_0x001c (userreg_0x001c    	),                                                    
	.userreg_0x011c (userreg_0x011c    	), 
	.userreg_0x001f (userreg_0x001f    	),                                       
	.userreg_0x0026 (userreg_0x0026    	), 	
	.userreg_0x0125 (userreg_0x0125    	), 	
	.userreg_0x0126 (userreg_0x0126    	), 	
	.userreg_0x0225 (userreg_0x0225    	), 	
	.userreg_0x0226 (userreg_0x0226    	), 	
	.userreg_0x0325 (userreg_0x0325    	), 	
	.userreg_0x0326 (userreg_0x0326    	), 		                                           	                                                                                         
	.userreg_0x021c (userreg_0x021c    	),                                                    
	.userreg_0x031c (userreg_0x031c    	),                                                    
	.userreg_0x001d (userreg_0x001d    	),                                                    
	.userreg_0x011d (userreg_0x011d    	),                                                    
	.userreg_0x021d (userreg_0x021d    	),                                                    
	.userreg_0x031d (userreg_0x031d    	),                                                    
	.userreg_0x001e (userreg_0x001e    	),                                                    
	.userreg_0x011e (userreg_0x011e    	),                                                    
	.userreg_0x021e (userreg_0x021e    	),     
	.userreg_0x021f (userreg_0x021f    	),                                                 
	.userreg_0x031e (userreg_0x031e    	),  
	.userreg_0x031f (userreg_0x031f    	),                                                   
	.userreg_0x0020 (userreg_0x0020    	),                                                    
	.userreg_0x0021 (userreg_0x0021		),                                                    
	.userreg_0x0120 (userreg_0x0120    	),                                                    
	.userreg_0x0121 (userreg_0x0121    	),                                                    
	.userreg_0x0220 (userreg_0x0220    	),                                                    
	.userreg_0x0221 (userreg_0x0221    	),                                                    
	.userreg_0x0320 (userreg_0x0320    	),                                                    
	.userreg_0x0321 (userreg_0x0321    	),
	.userreg_0x0349 (userreg_0x0349    	),	                                                    
	.userreg_0x0022 (userreg_0x0022    	), 
	.userreg_0x0122 (userreg_0x0122    	),	                                                   
	.userreg_0x0222 (userreg_0x0222    	),                                                    
	.userreg_0x0322 (userreg_0x0322    	),                                                    
	.userreg_0x0023 (userreg_0x0023    	),                                                    
	.userreg_0x0223 (userreg_0x0223    	),                                                    
	.userreg_0x0024 (userreg_0x0024    	),                                                    
	.userreg_0x0224 (userreg_0x0224    	),                                                    
	.userreg_0x0324 (userreg_0x0324    	),                                                    
	.userreg_0x0025 (userreg_0x0025    	),                                                                                                       
	.userreg_0x0030 (userreg_0x0030    	), 	
	.userreg_0x0031 (userreg_0x0031 	),
	.monitor_0x02b0 (monitor_0x02b0 	),
	.monitor_0x02b1 (monitor_0x02b1 	),
	.monitor_0x02b2 (monitor_0x02b2 	),
	.monitor_0x02b3 (monitor_0x02b3 	),                                            
	.userreg_0x0130 (userreg_0x0130    	),                                                    
	.userreg_0x0230 (userreg_0x0230    	),                                                    
	.userreg_0x0330 (userreg_0x0330    	),                                                    
	.userreg_0x0331 (userreg_0x0331		),                                                    
	.userreg_0x0332 (userreg_0x0332		),                                                    
	.userreg_0x0333 (userreg_0x0333		), 
	.userreg_0x0034 (userreg_0x0034    	), 	
	.userreg_0x0134 (userreg_0x0134    	), 	                                                   
	.userreg_0x0334 (userreg_0x0334    	),                                                    
	.userreg_0x0336 (userreg_0x0336    	),                                                    
	.userreg_0x0337 (userreg_0x0337    	),                                                    
	.userreg_0x0338 (userreg_0x0338    	),                                                    
	.userreg_0x0339 (userreg_0x0339    	),                                                    
	.userreg_0x033a (userreg_0x033a    	),                                                    
	.userreg_0x003b (userreg_0x003b    	),                                                    
	.userreg_0x033b (userreg_0x033b    	),                                                    
	.userreg_0x003c (userreg_0x003c    	),                                                    
	.userreg_0x033c (userreg_0x033c    	),                                                    
	.userreg_0x003d (userreg_0x003d    	),                                                    
	.userreg_0x033d (userreg_0x033d    	),                                                    
	.userreg_0x033e (userreg_0x033e    	),                                                    
	.userreg_0x033f (userreg_0x033f    	),                                                    
	.userreg_0x0040 (userreg_0x0040    	),                                                    
	.userreg_0x0140 (userreg_0x0140    	),                                                    
	.userreg_0x0240 (userreg_0x0240    	),                                                    
	.userreg_0x0041 (userreg_0x0041    	),                                                    
	.userreg_0x0141 (userreg_0x0141    	),                                                    
	.userreg_0x0241 (userreg_0x0241    	),                                                    
	.userreg_0x0042 (userreg_0x0042    	),                                                    
	.userreg_0x0043 (userreg_0x0043    	),                                                    
	.userreg_0x0044 (userreg_0x0044    	),                                                    
	.userreg_0x0144 (userreg_0x0144    	),                                                    
	.userreg_0x0045 (userreg_0x0045    	),                                                    
	.userreg_0x0046 (userreg_0x0046    	),                                                    
	.userreg_0x0047 (userreg_0x0047    	),                                                    
	.userreg_0x0048 (userreg_0x0048    	),                                                    
	.userreg_0x0049 (userreg_0x0049    	),                                                    
	.userreg_0x004a (userreg_0x004a    	),                                                    
	.userreg_0x014a (userreg_0x014a    	),                                                    
	.userreg_0x024a (userreg_0x024a    	),                                                    
	.userreg_0x004b (userreg_0x004b    	),                                                    
	.userreg_0x014b (userreg_0x014b    	),                                                    
	.userreg_0x024b (userreg_0x024b    	),                                                    
	.userreg_0x004c (userreg_0x004c    	),                                                    
	.userreg_0x004e (userreg_0x004e		),                                                    
	.userreg_0x004f (userreg_0x004f		),	                                                  
	.userreg_0x014e (userreg_0x014e		),     	                                              
	.userreg_0x014f (userreg_0x014f		),	   	                                              
	.userreg_0x024e (userreg_0x024e		),     	                                              
	.userreg_0x024f (userreg_0x024f		),	   		                                          
	.userreg_0x0050 (userreg_0x0050    	), 
	.userreg_0x0250 (userreg_0x0250    	),
	.userreg_0x0350 (userreg_0x0350    	),		                                                   
	.userreg_0x0051 (userreg_0x0051    	),                                                    
	.userreg_0x0251 (userreg_0x0251    	),                                                    
	.userreg_0x0351 (userreg_0x0351    	),                                                    
	.userreg_0x0052 (userreg_0x0052    	),                                                    
	.userreg_0x0252 (userreg_0x0252    	),                                                    
	.userreg_0x0352 (userreg_0x0352    	),                                                    
	.userreg_0x0053 (userreg_0x0053    	),                                                    
	.userreg_0x0153 (userreg_0x0153    	),                                                    
	.userreg_0x0253 (userreg_0x0253    	),                                                    
	.userreg_0x0353 (userreg_0x0353    	),                                                    
	.userreg_0x0054 (userreg_0x0054    	),                                                    
	.userreg_0x0154 (userreg_0x0154    	),                                                    
	.userreg_0x0254 (userreg_0x0254    	),                                                    
	.userreg_0x0354 (userreg_0x0354    	),                                                    
	.userreg_0x0056 (userreg_0x0056    	), 
	.userreg_0x0057 (userreg_0x0057    	),	
	.userreg_0x0055 (userreg_0x0055    	),                                                    
	.userreg_0x0155 (userreg_0x0155    	),                                                    
	.userreg_0x0255 (userreg_0x0255    	),                                                    
	.userreg_0x0355 (userreg_0x0355    	), 
    .userreg_0x005e (userreg_0x005e    	),   
    .userreg_0x005f (userreg_0x005f    	),   
    .userreg_0x015e (userreg_0x015e    	),   
    .userreg_0x015f (userreg_0x015f    	),   
    .userreg_0x025e (userreg_0x025e    	),   
    .userreg_0x025f (userreg_0x025f    	),   		
	.userreg_0x035e (userreg_0x035e    	),
	.userreg_0x035f (userreg_0x035f    	),                                                     
	.userreg_0x005d (userreg_0x005d    	), 
	.userreg_0x015d (userreg_0x015d    	),	                                                   
	.userreg_0x0060 (userreg_0x0060    	),                                                    
	.userreg_0x0061 (userreg_0x0061    	),                                                    
	.userreg_0x0062 (userreg_0x0062    	),                                                    
	.userreg_0x0262 (userreg_0x0262    	),                                                    
	.userreg_0x0063 (userreg_0x0063    	),                                                    
	.userreg_0x0064 (userreg_0x0064    	),                                                    
	.userreg_0x0164 (userreg_0x0164    	),                                                    
	.userreg_0x0065 (userreg_0x0065    	),
	.userreg_0x0066 (userreg_0x0066  	),
	.userreg_0x0067 (userreg_0x0067  	),
	.userreg_0x0068 (userreg_0x0068  	),
	.userreg_0x0069 (userreg_0x0069  	),
	.userreg_0x006a (userreg_0x006a  	),
	.userreg_0x006b (userreg_0x006b  	),
	.userreg_0x0166 (userreg_0x0166  	),
	.userreg_0x0167 (userreg_0x0167  	),
	.userreg_0x0168 (userreg_0x0168  	),
	.userreg_0x0169 (userreg_0x0169  	),
	.userreg_0x016a (userreg_0x016a  	),
	.userreg_0x016b (userreg_0x016b  	),                 	                                                    
	.userreg_0x006c (userreg_0x006c    	),                                                    
	.userreg_0x016c (userreg_0x016c    	),                                                    
	.userreg_0x006d (userreg_0x006d    	),                                                    
	.userreg_0x016d (userreg_0x016d    	),                                                    
	.userreg_0x006e (userreg_0x006e    	),                                                    
	.userreg_0x016e (userreg_0x016e    	),                                                    
	.userreg_0x006f (userreg_0x006f    	),                                                    
	.userreg_0x016f (userreg_0x016f    	),                                                    
	.userreg_0x026f (userreg_0x026f    	),                                                    
	.userreg_0x036f (userreg_0x036f    	), 
	.userreg_0x0027 (userreg_0x0027     ),
	.userreg_0x0028 (userreg_0x0028     ),         
	.userreg_0x0128 (userreg_0x0128     ),  
	.userreg_0x0228 (userreg_0x0228     ),  
	.userreg_0x0328 (userreg_0x0328     ),  
	.userreg_0x0029 (userreg_0x0029     ), 
	.userreg_0x002a (userreg_0x002a     ), 
	.userreg_0x012a (userreg_0x012a     ),	
	.userreg_0x022a (userreg_0x022a     ),	
	.userreg_0x0127 (userreg_0x0127     ), 	
	.userreg_0x0227 (userreg_0x0227     ),
	.userreg_0x0229	(userreg_0x0229   	),  
	                                                 
	.userreg_0x0070 (userreg_0x0070    	),                                                    
	.userreg_0x0071 (userreg_0x0071    	),                                                    
	.userreg_0x0072 (userreg_0x0072    	),                                                    
	.userreg_0x0073 (userreg_0x0073    	),                                                    
	.userreg_0x0074 (userreg_0x0074    	),                                                    
	.userreg_0x0075 (userreg_0x0075    	),                                                    
	.userreg_0x0076 (userreg_0x0076    	),                                                    
	.userreg_0x0077 (userreg_0x0077    	),                                                    
	.userreg_0x0277 (userreg_0x0277    	),                                                    
	.userreg_0x0078 (userreg_0x0078    	),                                                    
	.userreg_0x0278 (userreg_0x0278    	),                                                    
	.userreg_0x0079 (userreg_0x0079    	),                                                    
	.userreg_0x0279 (userreg_0x0279    	),                                                    
	.userreg_0x007a (userreg_0x007a    	),                                                    
	.userreg_0x027a (userreg_0x027a    	),                                                    
	.userreg_0x007b (userreg_0x007b    	),                                                    
	.userreg_0x027b (userreg_0x027b    	),                                                    
	.userreg_0x007c (userreg_0x007c    	),                                                    
	.userreg_0x027c (userreg_0x027c    	),                                                    
	.userreg_0x007d (userreg_0x007d    	),    
	.userreg_0x007e (userreg_0x007e    	),                                                  
	.userreg_0x027d (userreg_0x027d    	),                                                    
	.userreg_0x027e (userreg_0x027e    	),                                                    
	.userreg_0x027f (userreg_0x027f    	),                                                    
	.userreg_0x003a (userreg_0x003a		),  
	.userreg_0x013a (userreg_0x013a		),	                                                  
	.userreg_0x023a (userreg_0x023a		),                                                    
	.userreg_0x023b (userreg_0x023b		),                                                    
	.userreg_0x004d (userreg_0x004d		),                                                    
	.userreg_0x0340 (userreg_0x0340		), 
	.userreg_0x0244 (userreg_0x0244   	), 
	.userreg_0x0245 (userreg_0x0245   	),  
	.userreg_0x0246 (userreg_0x0246		),
	.userreg_0x0344 (userreg_0x0344   	), 
	.userreg_0x0346 (userreg_0x0346   	), 
	.userreg_0x0345 (userreg_0x0345   	), 
	.userreg_0x0272 (userreg_0x0272   	), 
	.userreg_0x0271 (userreg_0x0271   	), 
	.userreg_0x0270 (userreg_0x0270   	), 
	.userreg_0x014c (userreg_0x014c	 	), 
	.userreg_0x0348 (userreg_0x0348	 	), 
	.userreg_0x0347 (userreg_0x0347	  	),   
  
  
	.monitor_0x0081	(monitor_0x0081	   	),                                                    
	.monitor_0x0082	(monitor_0x0082	   	),                                                    
	.monitor_0x0083	(monitor_0x0083	   	),                                                    
	.monitor_0x0084	(monitor_0x0084	   	),                                                    
	.monitor_0x0085	(monitor_0x0085	   	),                                                    
	.monitor_0x0086	(monitor_0x0086	   	),                                                    
	.monitor_0x0087	(monitor_0x0087	   	),                                                    
	.monitor_0x0088	(monitor_0x0088	   	),                                                    
	.monitor_0x0089	(monitor_0x0089	   	),                                                    
	.monitor_0x008a	(monitor_0x008a	   	),                                                    
	.monitor_0x008b	(monitor_0x008b	   	),                                                    
	.monitor_0x008c	(monitor_0x008c	   	),                                                    
	.monitor_0x008d	(monitor_0x008d	   	),                                                    
	.monitor_0x008e	(monitor_0x008e	   	),                                                    
	.monitor_0x008f (monitor_0x008f    	),                                                    
	.monitor_0x0090 (monitor_0x0090    	),                                                    
	.monitor_0x0091 (monitor_0x0091    	),                                                    
	.monitor_0x0092 (monitor_0x0092    	),                                                    
	.monitor_0x0093 (monitor_0x0093    	),                                                    
	.monitor_0x0094 (monitor_0x0094    	),                                                    
	.monitor_0x0294 (monitor_0x0294    	),                                                    
	.monitor_0x0095 (monitor_0x0095    	),                                                    
	.monitor_0x0295 (monitor_0x0295    	),                                                    
	.monitor_0x0096 (monitor_0x0096    	),                                                    
	.monitor_0x0196 (monitor_0x0196    	),                                                    
	.monitor_0x0296 (monitor_0x0296    	),                                                    
	.monitor_0x0396 (monitor_0x0396    	),                                                    
	.monitor_0x0097 (monitor_0x0097    	),                                                    
	.monitor_0x0197 (monitor_0x0197    	),                                                    
	.monitor_0x0297 (monitor_0x0297    	),                                                    
	.monitor_0x0397 (monitor_0x0397    	),                                                    
	.monitor_0x0098 (monitor_0x0098    	),                                                    
	.monitor_0x0198 (monitor_0x0198    	),                                                    
	.monitor_0x0298 (monitor_0x0298    	),                                                    
	.monitor_0x0398 (monitor_0x0398    	),                                                    
	.monitor_0x0099 (monitor_0x0099    	),                                                    
	.monitor_0x0199 (monitor_0x0199    	),                                                    
	.monitor_0x0299 (monitor_0x0299    	),                                                    
	.monitor_0x0399 (monitor_0x0399    	),                                                    
	.monitor_0x009a (monitor_0x009a    	),                                                    
	.monitor_0x019a (monitor_0x019a    	),                                                    
	.monitor_0x029a (monitor_0x029a    	),                                                    
	.monitor_0x039a (monitor_0x039a    	),                                                    
	.monitor_0x009b (monitor_0x009b    	),                                                    
	.monitor_0x019b (monitor_0x019b    	),                                                    
	.monitor_0x029b (monitor_0x029b    	),                                                    
	.monitor_0x039b (monitor_0x039b    	),                                                    
	.monitor_0x009c (monitor_0x009c    	),                                                    
	.monitor_0x019c (monitor_0x019c    	),                                                    
	.monitor_0x029c (monitor_0x029c    	),                                                    
	.monitor_0x039c (monitor_0x039c    	),                                                    
	.monitor_0x009d (monitor_0x009d    	), 
	.monitor_0x009e (monitor_0x009e    	),	                                                   
	.monitor_0x019d (monitor_0x019d    	),                                                    
	.monitor_0x029d (monitor_0x029d    	),                                                    
	.monitor_0x039d (monitor_0x039d    	),                                                    
	.monitor_0x00a0 (monitor_0x00a0    	),                                                    
	.monitor_0x01a0 (monitor_0x01a0    	),                                                    
	.monitor_0x02a0 (monitor_0x02a0    	),                                                    
	.monitor_0x00a1 (monitor_0x00a1    	),                                                    
	.monitor_0x01a1 (monitor_0x01a1    	),                                                    
	.monitor_0x02a1 (monitor_0x02a1    	),                                                    
	.monitor_0x02a2 (monitor_0x02a2    	),                                                    
	.monitor_0x02a3 (monitor_0x02a3    	),                                                    
	.monitor_0x00a4 (monitor_0x00a4    	),                                                    
	.monitor_0x01a4 (monitor_0x01a4    	),                                                    
	.monitor_0x02a4 (monitor_0x02a4    	),                                                    
	.monitor_0x03a4 (monitor_0x03a4    	),                                                    
	.monitor_0x00a5 (monitor_0x00a5    	),                                                    
	.monitor_0x01a5 (monitor_0x01a5    	),                                                    
	.monitor_0x02a5 (monitor_0x02a5    	),                                                    
	.monitor_0x03a5 (monitor_0x03a5    	),                                                    
	.monitor_0x00a6 (monitor_0x00a6    	),                                                    
	.monitor_0x01a6 (monitor_0x01a6    	),                                                    
	.monitor_0x02a6 (monitor_0x02a6    	),                                                    
	.monitor_0x03a6 (monitor_0x03a6    	),                                                    
	.monitor_0x00a7 (monitor_0x00a7    	),                                                    
	.monitor_0x01a7 (monitor_0x01a7    	),                                                    
	.monitor_0x02a7 (monitor_0x02a7    	),                                                    
	.monitor_0x03a7 (monitor_0x03a7    	),                                                    
	.monitor_0x00a8 (monitor_0x00a8    	),                                                    
	.monitor_0x01a8 (monitor_0x01a8    	),                                                    
	.monitor_0x02a8 (monitor_0x02a8    	),                                                    
	.monitor_0x03a8 (monitor_0x03a8    	),                                                    
	.monitor_0x00a9 (monitor_0x00a9    	),                                                    
	.monitor_0x01a9 (monitor_0x01a9    	),                                                    
	.monitor_0x02a9 (monitor_0x02a9    	),                                                    
	.monitor_0x03a9 (monitor_0x03a9    	),                                                    
	.monitor_0x00aa (monitor_0x00aa    	),                                                    
	.monitor_0x01aa (monitor_0x01aa    	),                                                    
	.monitor_0x02aa (monitor_0x02aa    	),                                                    
	.monitor_0x03aa (monitor_0x03aa    	),                                                    
	
	.monitor_0x00ab (monitor_0x00ab    	), 
  
	.monitor_0x01ab (monitor_0x01ab    	),  
	.monitor_0x01ac (monitor_0x01ac    	), 
	.monitor_0x02ab (monitor_0x02ab    	), 
	.monitor_0x02ac (monitor_0x02ac    	), 
	.monitor_0x03ab (monitor_0x03ab    	), 
	.monitor_0x03ac (monitor_0x03ac   	),
	.monitor_0x03ad (monitor_0x03ad   	), 	 	                                                                                                     
	.monitor_0x02ad (monitor_0x02ad    	),                                                    
	.monitor_0x00ae (monitor_0x00ae    	),   
	.monitor_0x00af (monitor_0x00af		),
	.monitor_0x02af (monitor_0x02af		),                                                 
	.monitor_0x00b0 (monitor_0x00b0    	),                                                    
	.monitor_0x01b0 (monitor_0x01b0    	),                                                    
	.monitor_0x03b0 (monitor_0x03b0    	),                                                    
	.monitor_0x00b1 (monitor_0x00b1    	),                                                    
	.monitor_0x01b1 (monitor_0x01b1    	),                                                    
	.monitor_0x03b1 (monitor_0x03b1    	),                                                    
	.monitor_0x00b2 (monitor_0x00b2    	),                                                    
	.monitor_0x01b2 (monitor_0x01b2    	),                                                    
	.monitor_0x03b2 (monitor_0x03b2    	),                                                    
	.monitor_0x00b3 (monitor_0x00b3    	),    
	.monitor_0x00bb (monitor_0x00bb    	), 	  
	.monitor_0x00bc (monitor_0x00bc    	),    
	.monitor_0x00bd (monitor_0x00bd    	),   
	.monitor_0x00be (monitor_0x00be    	),   
	.monitor_0x00bf (monitor_0x00bf    	),  
	.monitor_0x01bc (monitor_0x01bc    	),  
	.monitor_0x01bd (monitor_0x01bd    	),  
	.monitor_0x01be (monitor_0x01be    	),  
	.monitor_0x01bf (monitor_0x01bf    	),  
	.monitor_0x02bc (monitor_0x02bc    	),  
	.monitor_0x02bd (monitor_0x02bd    	),  
	.monitor_0x02be (monitor_0x02be    	),  
	.monitor_0x02bf (monitor_0x02bf    	),  	 
	                                             
	.monitor_0x01b3 (monitor_0x01b3    	),                                                    
	.monitor_0x03b3 (monitor_0x03b3    	),                                                    
	.monitor_0x03b4 (monitor_0x03b4    	),                                                    
	.monitor_0x03b5 (monitor_0x03b5    	),                                                    
	.monitor_0x03b6 (monitor_0x03b6    	),                                                    
	.monitor_0x03b7 (monitor_0x03b7    	),                                                    
	.monitor_0x03b8 (monitor_0x03b8    	),                                                    
	.monitor_0x03b9 (monitor_0x03b9    	),                                                    
	.monitor_0x03ba (monitor_0x03ba    	),                                                    
	.monitor_0x03bb (monitor_0x03bb    	),                                                    
	.monitor_0x00c0 (monitor_0x00c0    	),                                                    
	.monitor_0x00c1 (monitor_0x00c1    	),                                                    
	.monitor_0x00c2 (monitor_0x00c2    	),                                                    
	.monitor_0x00c3 (monitor_0x00c3    	),                                                    
	.monitor_0x00c4 (monitor_0x00c4    	),                                                    
	.monitor_0x00c5 (monitor_0x00c5    	),                                                    
	.monitor_0x00c6 (monitor_0x00c6    	),                                                    
	.monitor_0x00c7 (monitor_0x00c7    	),                                                    
	.monitor_0x00c8 (monitor_0x00c8    	),  
	.monitor_0x01c8 (monitor_0x01c8    	), //**
	.monitor_0x02c8 (monitor_0x02c8    	),  
	.monitor_0x03c8 (monitor_0x03c8    	), 
	.monitor_0x00c9 (monitor_0x00c9    	),
	.monitor_0x00ca (monitor_0x00ca    	),
	.monitor_0x00cb (monitor_0x00cb    	),
	.monitor_0x00cc (monitor_0x00cc    	),
	.monitor_0x00cd (monitor_0x00cd    	),	
	.monitor_0x00ce (monitor_0x00ce    	),	
	.monitor_0x01ce (monitor_0x01ce    	),	
	
	.monitor_0x01c9 (monitor_0x01c9    	),
	.monitor_0x01ca (monitor_0x01ca    	),
	.monitor_0x01cb (monitor_0x01cb    	),
	.monitor_0x01cc (monitor_0x01cc    	),
	.monitor_0x01cd (monitor_0x01cd    	),		
	.monitor_0x02c9 (monitor_0x02c9    	),
	.monitor_0x03c9 (monitor_0x03c9    	),
	                                                 
	.monitor_0x03c0 (monitor_0x03c0		),                                                    
	.monitor_0x03c1 (monitor_0x03c1		),                                                    
	.monitor_0x03c2 (monitor_0x03c2		),                                                    
	.monitor_0x03c3 (monitor_0x03c3		),                                                    
	.monitor_0x03c4 (monitor_0x03c4		),                                                    
	.monitor_0x03c5 (monitor_0x03c5		),                                                    
	.monitor_0x03c6 (monitor_0x03c6		),                                                    
	.monitor_0x03c7 (monitor_0x03c7		),                                                    
	.monitor_0x0394 (monitor_0x0394    	),
	.monitor_0x0395 (monitor_0x0395    	),                                                    
	.monitor_0x00b4 (monitor_0x00b4 	),                                                    
	.monitor_0x00b5 (monitor_0x00b5 	), 
	.monitor_0x00b6 (monitor_0x00b6    	),	                                                   
	.monitor_0x01b4 (monitor_0x01b4 	),                                                    
	.monitor_0x01b5 (monitor_0x01b5 	),      
	.monitor_0x02b4 (monitor_0x02b4 	),  
	.monitor_0x02b5 (monitor_0x02b5 	),                                                
	.monitor_0x00ff (monitor_0x00ff		),                                                    
	.monitor_0x00ac (monitor_0x00ac		),                                                    
	.monitor_0x00ad (monitor_0x00ad		)				                                              
    ); 
	
	
	
//-----------------------------------------------------------
//CZ_SPI's arbitration	
//目前仅添加了 SPI 端口，AGC模块端口，需要时可再添加
//-----------------------------------------------------------
	//从SPI模块返回的数据和成功标志
	wire   [7:0]		w_cz_success_spi_to_arbi;
	wire   [31:0]		w_cz_data_spi_to_arbi;
	
	//输出到SPI模块
	wire   				w_cz_rd_en;
	wire				w_cz_wr_en;
	wire   [15:0]		w_cz_rw_addr;
	wire   [31:0]		w_cz_wr_data_mcu;
	wire				w_cz_mod_sel_mcu;
	
	//输出到监视寄存器 即输出到MCU
	wire   [7:0]		w_cz_success_arbi_to_monitor;
	wire   [31:0]		w_cz_data_to_arbi_monitor;

	
cz_spi_arbitration u_cz_spi_arbitration(
	.i_clk			    (w_fpga_clk_125p		),
	.i_rst_n			(w_rst_125p_m			),	
	.i_rd_en_mcu		(userreg_0x0166[0]		),
	.i_wr_en_mcu		(userreg_0x0140[0]		),
	.i_mod_sel_mcu		(userreg_0x0270[0]		),
	.i_rw_addr_mcu		({userreg_0x0127[7:0],userreg_0x0128[7:0]}),
	.i_wr_data_mcu		({userreg_0x0255[7:0],userreg_0x0134[7:0],userreg_0x0155[7:0],userreg_0x0164[7:0]}),
	
	//从SPI模块返回的数据和成功标志	
	.i_return_success	(w_cz_success_spi_to_arbi),
	.i_return_data		(w_cz_data_spi_to_arbi	),
	
	//输出到SPI模块
	.o_rd_en			(w_cz_rd_en				),
	.o_wr_en			(w_cz_wr_en				),
	.o_mod_sel_mcu		(w_cz_mod_sel_mcu		),
	.o_rw_addr			(w_cz_rw_addr			),
	.o_wr_data_mcu		(w_cz_wr_data_mcu		),
		
	
	//输出到监视寄存器
	.o_success_to_mcu	(w_cz_success_arbi_to_monitor),
	.o_data_to_mcu		(w_cz_data_to_arbi_monitor	)
);
	

	assign	{monitor_0x00bb,monitor_0x00bc,monitor_0x00bd,monitor_0x00be} = w_cz_data_to_arbi_monitor;
	assign	monitor_0x00bf = w_cz_success_arbi_to_monitor;
	

//---------------------------------------------------------
//cz SPI 模块
//---------------------------------------------------------
	 
cz_spi_interface u_cz_spi_interface(
	.i_fpga_clk_125p	(w_fpga_clk_125p),
	.i_fpga_rst_125p	(w_rst_125p_m),
	
	.i_rd_en			(w_cz_rd_en),
	.i_wr_en			(w_cz_wr_en),
	.i_mod_sel			(w_cz_mod_sel_mcu),
	.i_addr				(w_cz_rw_addr),
	.i_data				(w_cz_wr_data_mcu),
	
	.o_rw_result		(w_cz_success_spi_to_arbi),
	.o_rw_data			(w_cz_data_spi_to_arbi),
	
	.i_ad80305_do		(I_cz_spi_di),
	.o_ad80305_di		(O_cz_spi_do),
	.o_ad80305_clk		(O_cz_spi_clk),
	.o_ad80305_cs		(O_cz_spi_cs)
);	 

//-----------------------------------------
// 通道切换模块
//-----------------------------------------
change_channel	u_change_channel(
	.i_clk_125p			(w_fpga_clk_125p),
	.i_rst_n			(w_rst_125p_m),
	.tx_switch			(userreg_0x0168),
	.rx_switch			(userreg_0x0167),	
	.i_sin_idata		(w_i_sin_idata),
	.i_sin_qdata		(w_i_sin_qdata),
	.i_sin_iqdata_fp	(w_i_sin_iqdata_fp),
	.i_diff_idata		(w_i_diff_idata),
	.i_diff_qdata		(w_i_diff_qdata),
	.i_diff_iqdata_fp	(w_i_diff_iqdata_fp),
	.o_sin_idata		(w_o_sin_idata),
	.o_sin_qdata		(w_o_sin_qdata),
	.o_sin_iqdata_fp	(w_o_sin_iqdata_fp),
	.o_diff_idata		(w_o_diff_idata),
	.o_diff_qdata		(w_o_diff_qdata),
	.o_diff_iqdata_fp	(w_o_diff_iqdata_fp)
);

endmodule