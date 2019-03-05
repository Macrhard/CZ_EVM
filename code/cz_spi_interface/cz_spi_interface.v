//`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: comba
// Engineer: liyangjun
// 
// Create Date:    
// Design Name: 
// Module Name:    spi_interface 
// Project Name: 
// Target Devices: 
// Tool versions:
// Dependencies: AD80305 的SPI接口驱动,两片AD80305共用一组SPI总线
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 暂时按照每次只读写一次进行操作，后续考虑是否需要支持多寄存器连续读写功能
//
//////////////////////////////////////////////////////////////////////////////////
module cz_spi_interface(
//输入FPGA内部的相关量
	input                i_fpga_clk_125p		,
	input                i_fpga_rst_125p		,
  
//输入读写控制信号  
	input				 i_rd_en         	 	,//读使能，由0变为1时，触发一次读使能
	input				 i_wr_en        	    ,//写使能，由0变为1时，触发一次写使能
	input 	             i_mod_sel				,//控制操作的是内/外部寄存器	1:内部寄存器	0:外部寄存器
	input [15:0]		 i_addr					,//待读写的寄存器地址	
	input [31:0]         i_data                 ,//待写入数据
    
    output [7:0]         o_rw_result       	    ,//输出结果表示，为01时，表示读写正常，其他值时为失败；
    output [31:0]        o_rw_data              ,//输出读取的结果
               
//SPI控制信号
	input                i_ad80305_do     		,//ad80305-->fpga
	output               o_ad80305_di        	,//fpga-->ad80305
	output			  	 o_ad80305_clk       	,//输出时钟，1MHz
	output				 o_ad80305_cs       	 //输出使能，低电平有效 
);
    


reg [6:0] spi_current_state;
reg [6:0] spi_next_state;

parameter spi_idle  		= 	0;
parameter spi_start  		= 	1;        
parameter spi_rw    		= 	2;
parameter spi_inter_exter 	= 	3;

parameter spi_add15			= 	4;  
parameter spi_add14			= 	5;  
parameter spi_add13			= 	6;  
parameter spi_add12			= 	7;  
parameter spi_add11			= 	8;  
parameter spi_add10 	      = 	9; 
parameter spi_add9 	      = 	88; 
parameter spi_add8 			=  10; 
parameter spi_add7 			=  11; 
parameter spi_add6 			=  12; 
parameter spi_add5 			=  13; 
parameter spi_add4 			=  14; 
parameter spi_add3 			=  15; 
parameter spi_add2 			=  16; 
parameter spi_add1 			=  17; 
parameter spi_add0 			=  18; 
   
parameter spi_wr_data31		=  19;
parameter spi_wr_data30		=  20;
parameter spi_wr_data29		=  21;
parameter spi_wr_data28		=  22;
parameter spi_wr_data27		=  23;
parameter spi_wr_data26		=  24;
parameter spi_wr_data25		=  25;
parameter spi_wr_data24		=  26;
parameter spi_wr_data23		=  27;
parameter spi_wr_data22		=  28;
parameter spi_wr_data21		=  29;
parameter spi_wr_data20		=  30;
parameter spi_wr_data19		=  31;
parameter spi_wr_data18		=  32;
parameter spi_wr_data17		=  33;
parameter spi_wr_data16		=  34;
parameter spi_wr_data15		=  35;
parameter spi_wr_data14		=  36;
parameter spi_wr_data13		=  37;
parameter spi_wr_data12 	=  38;
parameter spi_wr_data11		=  39;
parameter spi_wr_data10		=  40;
parameter spi_wr_data9		=  41;
parameter spi_wr_data8		=  42;	
parameter spi_wr_data7		=  43; 
parameter spi_wr_data6		=  44; 
parameter spi_wr_data5		=  45; 
parameter spi_wr_data4		=  46; 
parameter spi_wr_data3		=  47; 
parameter spi_wr_data2		=  48; 
parameter spi_wr_data1		=  49; 
parameter spi_wr_data0		=  50; 

parameter spi_rd_data31		=  51;
parameter spi_rd_data30		=  52;
parameter spi_rd_data29		=  53;
parameter spi_rd_data28		=  54;
parameter spi_rd_data27		=  55;
parameter spi_rd_data26		=  56;
parameter spi_rd_data25		=  57;
parameter spi_rd_data24		=  58;
parameter spi_rd_data23		=  59;
parameter spi_rd_data22		=  60;
parameter spi_rd_data21		=  61;
parameter spi_rd_data20		=  62;
parameter spi_rd_data19		=  63;
parameter spi_rd_data18		=  64;
parameter spi_rd_data17		=  65;
parameter spi_rd_data16		=  66;
parameter spi_rd_data15		=  67;
parameter spi_rd_data14		=  68;
parameter spi_rd_data13		=  69;
parameter spi_rd_data12 	=  70;
parameter spi_rd_data11		=  71;
parameter spi_rd_data10		=  72;
parameter spi_rd_data9		=  73;
parameter spi_rd_data8		=  74;	
parameter spi_rd_data7		=  75; 
parameter spi_rd_data6		=  76; 
parameter spi_rd_data5		=  77; 
parameter spi_rd_data4		=  78; 
parameter spi_rd_data3		=  79; 
parameter spi_rd_data2		=  80; 
parameter spi_rd_data1		=  81; 
parameter spi_rd_data0		=  82;

parameter spi_null0			=	83;
parameter spi_null1			=	84;
parameter spi_null2			=	85;
parameter spi_null3			=	86;
parameter spi_stop 			=   87; 
 

parameter spi_clk_fre       =  124;//125MHz/125 = 1MHz分频


//---------------------------------------------------------
//读使能
//---------------------------------------------------------
reg r_rd_en0;
reg r_rd_en1;
always@(posedge i_fpga_clk_125p)
begin
	r_rd_en0 <= i_rd_en;
	r_rd_en1 <= r_rd_en0;			
end

reg r_rd_flag;
always@(posedge i_fpga_clk_125p or negedge i_fpga_rst_125p)
begin
	if(!i_fpga_rst_125p)
		r_rd_flag <= 1'b0;
	else if(r_rd_en0&&(!r_rd_en1))
		r_rd_flag <= 1'b1;
		
	else 
		r_rd_flag <= 1'b0;		
end

//---------------------------------------------------------
//写使能
//---------------------------------------------------------
reg r_wr_en0;
reg r_wr_en1;
always@(posedge i_fpga_clk_125p)
begin
	r_wr_en0 <= i_wr_en;
	r_wr_en1 <= r_wr_en0;			
end

reg r_wr_flag;
always@(posedge i_fpga_clk_125p or negedge i_fpga_rst_125p)
begin
	if(!i_fpga_rst_125p)
		r_wr_flag <= 1'b0;
	else if(r_wr_en0&&(!r_wr_en1))
		r_wr_flag <= 1'b1;
	else 
		r_wr_flag <= 1'b0;		
end

//---------------------------------------------------------
//读/写状态保存 写优先，监控需确保每次都只能进行读或者写 //单工模式
//---------------------------------------------------------
reg [1:0]r_rw_now_state;
always@(posedge i_fpga_clk_125p or negedge i_fpga_rst_125p)
begin
	if(!i_fpga_rst_125p)
		r_rw_now_state <= 2'b00;
	else if(r_wr_flag)
		r_rw_now_state <= 2'b01;//写标志
	else if(r_rd_flag)
		r_rw_now_state <= 2'b10;//读标志
	else
		r_rw_now_state <= r_rw_now_state;
end


//----------------------------------------------------------------
//读/写控制命令写入 模式+地址，共18位  1:W 0:R / 1:inter 0:exter
//----------------------------------------------------------------
reg [17:0] r_write_data;
always@(posedge i_fpga_clk_125p or negedge i_fpga_rst_125p)
begin
	if(!i_fpga_rst_125p)
		r_write_data <= 18'd0;
	else if(r_rd_flag)
		r_write_data <= {1'b0,i_mod_sel,i_addr};
	else if(r_wr_flag)
		r_write_data <= {1'b1,i_mod_sel,i_addr};
	else
		r_write_data <= r_write_data;
end

//---------------------------------------------------------
//时钟的生成计数 对125MHz进行125分频，频率为1MHz
//---------------------------------------------------------
reg [6:0] cnt_fre;
always@(posedge i_fpga_clk_125p or negedge i_fpga_rst_125p)
begin
	if(!i_fpga_rst_125p)
		cnt_fre <= 7'd0;
	else if(spi_current_state == spi_idle)
		cnt_fre <= 7'd0;
	else if(cnt_fre == spi_clk_fre)
		cnt_fre <= 7'd0;
	else
		cnt_fre <= cnt_fre + 7'd1;
end


//---------------------------------------------------------
//状态机转移 
//---------------------------------------------------------
always@(posedge i_fpga_clk_125p or negedge i_fpga_rst_125p)
begin
	if(!i_fpga_rst_125p)
		spi_current_state <= spi_idle;
	else
		spi_current_state <= spi_next_state;
end

always@(posedge i_fpga_clk_125p or negedge i_fpga_rst_125p)
begin
	if(!i_fpga_rst_125p)
		spi_next_state <= spi_idle;
	else
		begin
        	if(cnt_fre == 7'd0)
        		begin
                	case(spi_current_state)
                		spi_idle:
                			begin
                				if(r_rd_flag || r_wr_flag)
                					spi_next_state <= spi_start; 
                				else
                					spi_next_state <= spi_next_state;
                			end
                	spi_start    		  :begin	spi_next_state <= spi_rw    			;end
            		spi_rw       		  :begin	spi_next_state <= spi_inter_exter   ;end
            		spi_inter_exter     :begin	spi_next_state <= spi_add15   		;end           			
						
						spi_add15    		  :begin	spi_next_state <= spi_add14   		;end
						spi_add14    		  :begin	spi_next_state <= spi_add13   		;end
						spi_add13    		  :begin	spi_next_state <= spi_add12  			;end
						spi_add12    		  :begin	spi_next_state <= spi_add11  			;end
						spi_add11    		  :begin	spi_next_state <= spi_add10   		;end
						spi_add10   		  :begin	spi_next_state <= spi_add9   			;end
						spi_add9    		  :begin	spi_next_state <= spi_add8   			;end
						spi_add8    		  :begin	spi_next_state <= spi_add7   			;end
            		spi_add7    		  :begin	spi_next_state <= spi_add6  		   ;end
            		spi_add6    		  :begin	spi_next_state <= spi_add5   			;end
            		spi_add5    		  :begin	spi_next_state <= spi_add4   			;end
            		spi_add4    		  :begin	spi_next_state <= spi_add3   			;end
            		spi_add3    		  :begin	spi_next_state <= spi_add2   			;end
            		spi_add2    		  :begin	spi_next_state <= spi_add1   			;end
                  spi_add1    		  :begin	spi_next_state <= spi_add0   			;end
						spi_add0    		  :
								begin	
                        		if(r_rw_now_state == 2'b01)  //如果是写数据 
									spi_next_state <= spi_wr_data31;
                        		else 
									begin
										if(r_rw_now_state == 2'b10) //如果是读数据
											begin
												if(i_mod_sel == 1'b1) //如果是读内部
													spi_next_state <= spi_rd_data31;
												else
													spi_next_state <= spi_null0;
											end	
										else
											spi_next_state <= spi_idle;
									end
								end
							spi_wr_data31		  :begin 	spi_next_state <= spi_wr_data30	;end
							spi_wr_data30		  :begin 	spi_next_state <= spi_wr_data29	;end
							spi_wr_data29		  :begin 	spi_next_state <= spi_wr_data28	;end
							spi_wr_data28		  :begin 	spi_next_state <= spi_wr_data27	;end
							spi_wr_data27		  :begin 	spi_next_state <= spi_wr_data26	;end
							spi_wr_data26		  :begin 	spi_next_state <= spi_wr_data25	;end
							spi_wr_data25		  :begin 	spi_next_state <= spi_wr_data24	;end
							spi_wr_data24		  :begin 	spi_next_state <= spi_wr_data23	;end
							spi_wr_data23	  	  :begin 	spi_next_state <= spi_wr_data22	;end
							spi_wr_data22		  :begin 	spi_next_state <= spi_wr_data21	;end
							spi_wr_data21		  :begin 	spi_next_state <= spi_wr_data20	;end
							spi_wr_data20		  :begin 	spi_next_state <= spi_wr_data19	;end
							spi_wr_data19	 	  :begin 	spi_next_state <= spi_wr_data18	;end
							spi_wr_data18		  :begin 	spi_next_state <= spi_wr_data17	;end
							spi_wr_data17		  :begin 	spi_next_state <= spi_wr_data16	;end
							spi_wr_data16		  :begin 	spi_next_state <= spi_wr_data15	;end
							spi_wr_data15		  :begin 	spi_next_state <= spi_wr_data14	;end
							spi_wr_data14		  :begin 	spi_next_state <= spi_wr_data13	;end
							spi_wr_data13		  :begin 	spi_next_state <= spi_wr_data12	;end
							spi_wr_data12		  :begin 	spi_next_state <= spi_wr_data11	;end
							spi_wr_data11		  :begin 	spi_next_state <= spi_wr_data10	;end
							spi_wr_data10		  :begin 	spi_next_state <= spi_wr_data9 	;end
							spi_wr_data9 		  :begin 	spi_next_state <= spi_wr_data8 	;end
							spi_wr_data8 		  :begin 	spi_next_state <= spi_wr_data7	;end
							spi_wr_data7 		  :begin 	spi_next_state <= spi_wr_data6	;end
							spi_wr_data6 		  :begin 	spi_next_state <= spi_wr_data5	;end
							spi_wr_data5 		  :begin 	spi_next_state <= spi_wr_data4	;end
							spi_wr_data4 		  :begin 	spi_next_state <= spi_wr_data3	;end
							spi_wr_data3 		  :begin 	spi_next_state <= spi_wr_data2	;end
							spi_wr_data2 		  :begin 	spi_next_state <= spi_wr_data1	;end
							spi_wr_data1 		  :begin 	spi_next_state <= spi_wr_data0	;end
							spi_wr_data0 		  :begin 	spi_next_state <= spi_stop	 		;end    
							
							spi_null0			  :begin		spi_next_state <= spi_null1		;end
							spi_null1			  :begin		spi_next_state <= spi_null2		;end
							spi_null2			  :begin		spi_next_state <= spi_null3		;end
							spi_null3			  :begin		spi_next_state <= spi_rd_data31	;end
							spi_rd_data31		  :begin 	spi_next_state <= spi_rd_data30	;end
							spi_rd_data30		  :begin 	spi_next_state <= spi_rd_data29	;end
							spi_rd_data29		  :begin 	spi_next_state <= spi_rd_data28	;end
							spi_rd_data28		  :begin 	spi_next_state <= spi_rd_data27	;end
							spi_rd_data27		  :begin 	spi_next_state <= spi_rd_data26	;end
							spi_rd_data26		  :begin 	spi_next_state <= spi_rd_data25	;end
							spi_rd_data25		  :begin 	spi_next_state <= spi_rd_data24	;end
							spi_rd_data24		  :begin 	spi_next_state <= spi_rd_data23	;end
							spi_rd_data23	  	  :begin 	spi_next_state <= spi_rd_data22	;end
							spi_rd_data22		  :begin 	spi_next_state <= spi_rd_data21	;end
							spi_rd_data21		  :begin 	spi_next_state <= spi_rd_data20	;end
							spi_rd_data20		  :begin 	spi_next_state <= spi_rd_data19	;end
							spi_rd_data19	 	  :begin 	spi_next_state <= spi_rd_data18	;end
							spi_rd_data18		  :begin 	spi_next_state <= spi_rd_data17	;end
							spi_rd_data17		  :begin 	spi_next_state <= spi_rd_data16	;end
							spi_rd_data16		  :begin 	spi_next_state <= spi_rd_data15	;end
							spi_rd_data15		  :begin 	spi_next_state <= spi_rd_data14	;end
							spi_rd_data14		  :begin 	spi_next_state <= spi_rd_data13	;end
							spi_rd_data13		  :begin 	spi_next_state <= spi_rd_data12	;end
							spi_rd_data12		  :begin 	spi_next_state <= spi_rd_data11	;end
							spi_rd_data11		  :begin 	spi_next_state <= spi_rd_data10	;end
							spi_rd_data10		  :begin 	spi_next_state <= spi_rd_data9 	;end
							spi_rd_data9 		  :begin 	spi_next_state <= spi_rd_data8 	;end
							spi_rd_data8 		  :begin 	spi_next_state <= spi_rd_data7	;end
							spi_rd_data7 		  :begin 	spi_next_state <= spi_rd_data6	;end
							spi_rd_data6 		  :begin 	spi_next_state <= spi_rd_data5	;end
							spi_rd_data5 		  :begin 	spi_next_state <= spi_rd_data4	;end
							spi_rd_data4 		  :begin 	spi_next_state <= spi_rd_data3	;end
							spi_rd_data3 		  :begin 	spi_next_state <= spi_rd_data2	;end
							spi_rd_data2 		  :begin 	spi_next_state <= spi_rd_data1	;end
							spi_rd_data1 		  :begin 	spi_next_state <= spi_rd_data0	;end
							spi_rd_data0 		  :begin		spi_next_state <= spi_stop 		;end										            			
                	default:
                		begin
                			spi_next_state <= spi_idle;
                		end
                	endcase
                end
                   else
   						spi_next_state <= spi_next_state;
    		end
end

//---------------------------------------------------------
//输出时钟 		SPI模式 0
//---------------------------------------------------------
reg r_ad80305_clk;
always@(posedge i_fpga_clk_125p or negedge i_fpga_rst_125p)
begin
	if(!i_fpga_rst_125p)
		r_ad80305_clk <= 1'b0;
	else if(spi_current_state == spi_idle||spi_current_state == spi_start||spi_current_state == spi_stop)
		r_ad80305_clk <= 1'b0;
	else 
		begin
			if(cnt_fre == 7'd64)
				r_ad80305_clk <= 1'b1;
			else if(cnt_fre == 7'd124) 
				r_ad80305_clk <= 1'b0;
			else	
				r_ad80305_clk <= r_ad80305_clk;
		end
end

//---------------------------------------------------------
//输出数据
//---------------------------------------------------------
reg r_ad80305_dataout;
always@(posedge i_fpga_clk_125p or negedge i_fpga_rst_125p)
begin
	if(!i_fpga_rst_125p)
		r_ad80305_dataout <= 1'b0;
	else if(spi_current_state == spi_idle)
		r_ad80305_dataout <= 1'b0;
	else 
		begin
			if(cnt_fre == 7'd32)
				begin
					case(spi_current_state)
					   //控制命令写入到ad80305 

						spi_rw   			:begin	r_ad80305_dataout <= r_write_data[17];end //开始输出
						spi_inter_exter 	:begin	r_ad80305_dataout <= r_write_data[16];end
						spi_add15 			:begin	r_ad80305_dataout <= r_write_data[15];end
						spi_add14 			:begin	r_ad80305_dataout <= r_write_data[14];end
						spi_add13 			:begin	r_ad80305_dataout <= r_write_data[13];end
						spi_add12 			:begin	r_ad80305_dataout <= r_write_data[12];end
						spi_add11 			:begin	r_ad80305_dataout <= r_write_data[11];end
						spi_add10 			:begin	r_ad80305_dataout <= r_write_data[10];end
						spi_add9 			:begin	r_ad80305_dataout <= r_write_data[9] ;end
						spi_add8 			:begin	r_ad80305_dataout <= r_write_data[8] ;end
						spi_add7 			:begin	r_ad80305_dataout <= r_write_data[7] ;end
						spi_add6 			:begin	r_ad80305_dataout <= r_write_data[6] ;end
						spi_add5 			:begin	r_ad80305_dataout <= r_write_data[5] ;end
						spi_add4 			:begin	r_ad80305_dataout <= r_write_data[4] ;end
						spi_add3 			:begin	r_ad80305_dataout <= r_write_data[3] ;end
						spi_add2 			:begin	r_ad80305_dataout <= r_write_data[2] ;end
						spi_add1 			:begin	r_ad80305_dataout <= r_write_data[1] ;end
						spi_add0 			:begin	r_ad80305_dataout <= r_write_data[0] ;end
						
						//写入32位数据
						spi_wr_data31 		:begin	r_ad80305_dataout <= i_data[31]		 ;end
						spi_wr_data30 		:begin	r_ad80305_dataout <= i_data[30]		 ;end
						spi_wr_data29 		:begin	r_ad80305_dataout <= i_data[29]		 ;end
						spi_wr_data28 		:begin	r_ad80305_dataout <= i_data[28]		 ;end
						spi_wr_data27 		:begin	r_ad80305_dataout <= i_data[27]		 ;end
						spi_wr_data26 		:begin	r_ad80305_dataout <= i_data[26]		 ;end
						spi_wr_data25 		:begin	r_ad80305_dataout <= i_data[25]		 ;end
						spi_wr_data24 		:begin	r_ad80305_dataout <= i_data[24]		 ;end
						spi_wr_data23 		:begin	r_ad80305_dataout <= i_data[23]		 ;end
						spi_wr_data22 		:begin	r_ad80305_dataout <= i_data[22]		 ;end
						spi_wr_data21 		:begin	r_ad80305_dataout <= i_data[21]		 ;end
						spi_wr_data20 		:begin	r_ad80305_dataout <= i_data[20]		 ;end
						spi_wr_data19 		:begin	r_ad80305_dataout <= i_data[19]		 ;end
						spi_wr_data18 		:begin	r_ad80305_dataout <= i_data[18]		 ;end
						spi_wr_data17 		:begin	r_ad80305_dataout <= i_data[17]		 ;end
						spi_wr_data16 		:begin	r_ad80305_dataout <= i_data[16]		 ;end
						spi_wr_data15 		:begin	r_ad80305_dataout <= i_data[15]		 ;end
						spi_wr_data14 		:begin	r_ad80305_dataout <= i_data[14]		 ;end
						spi_wr_data13 		:begin	r_ad80305_dataout <= i_data[13]		 ;end
						spi_wr_data12 		:begin	r_ad80305_dataout <= i_data[12]		 ;end
						spi_wr_data11 		:begin	r_ad80305_dataout <= i_data[11]		 ;end
						spi_wr_data10 		:begin	r_ad80305_dataout <= i_data[10]		 ;end
						spi_wr_data9 		:begin	r_ad80305_dataout <= i_data[9]		 ;end
						spi_wr_data8 		:begin	r_ad80305_dataout <= i_data[8]		 ;end
						spi_wr_data7 		:begin	r_ad80305_dataout <= i_data[7]		 ;end
						spi_wr_data6 		:begin	r_ad80305_dataout <= i_data[6]		 ;end
						spi_wr_data5 		:begin	r_ad80305_dataout <= i_data[5]		 ;end
						spi_wr_data4 		:begin	r_ad80305_dataout <= i_data[4]		 ;end
						spi_wr_data3 		:begin	r_ad80305_dataout <= i_data[3]		 ;end
						spi_wr_data2 		:begin	r_ad80305_dataout <= i_data[2]		 ;end
						spi_wr_data1 		:begin	r_ad80305_dataout <= i_data[1]		 ;end
						spi_wr_data0 		:begin	r_ad80305_dataout <= i_data[0]		 ;end
						spi_stop    		:begin   r_ad80305_dataout <= 1'b0           ;end
				    default:	
				      	begin
				      		r_ad80305_dataout <= 1'b0;
				      	end                                               
					endcase
				end
			else
				r_ad80305_dataout <= r_ad80305_dataout;
		end
end

//---------------------------------------------------------
//读入数据
//---------------------------------------------------------
reg [31:0]	r_ad80305_datain;
always@(posedge i_fpga_clk_125p or negedge i_fpga_rst_125p)
begin
	if(!i_fpga_rst_125p)
		r_ad80305_datain <= 32'd0;
	else if(cnt_fre == 7'd124) 
		begin
			case(spi_current_state)
				spi_rd_data31:begin r_ad80305_datain <= {i_ad80305_do,r_ad80305_datain[30:0]}                        ;	end
				spi_rd_data30:begin r_ad80305_datain <= {r_ad80305_datain[31],i_ad80305_do,r_ad80305_datain[29:0]}   ;	end
				spi_rd_data29:begin r_ad80305_datain <= {r_ad80305_datain[31:30],i_ad80305_do,r_ad80305_datain[28:0]};	end
				spi_rd_data28:begin r_ad80305_datain <= {r_ad80305_datain[31:29],i_ad80305_do,r_ad80305_datain[27:0]};	end
			   spi_rd_data27:begin r_ad80305_datain <= {r_ad80305_datain[31:28],i_ad80305_do,r_ad80305_datain[26:0]};	end
				spi_rd_data26:begin r_ad80305_datain <= {r_ad80305_datain[31:27],i_ad80305_do,r_ad80305_datain[25:0]};	end
				spi_rd_data25:begin r_ad80305_datain <= {r_ad80305_datain[31:26],i_ad80305_do,r_ad80305_datain[24:0]};	end
				spi_rd_data24:begin r_ad80305_datain <= {r_ad80305_datain[31:25],i_ad80305_do,r_ad80305_datain[23:0]};	end
				spi_rd_data23:begin r_ad80305_datain <= {r_ad80305_datain[31:24],i_ad80305_do,r_ad80305_datain[22:0]};	end
				spi_rd_data22:begin r_ad80305_datain <= {r_ad80305_datain[31:23],i_ad80305_do,r_ad80305_datain[21:0]};	end
				spi_rd_data21:begin r_ad80305_datain <= {r_ad80305_datain[31:22],i_ad80305_do,r_ad80305_datain[20:0]};	end
				spi_rd_data20:begin r_ad80305_datain <= {r_ad80305_datain[31:21],i_ad80305_do,r_ad80305_datain[19:0]};	end
				spi_rd_data19:begin r_ad80305_datain <= {r_ad80305_datain[31:20],i_ad80305_do,r_ad80305_datain[18:0]};	end
				spi_rd_data18:begin r_ad80305_datain <= {r_ad80305_datain[31:19],i_ad80305_do,r_ad80305_datain[17:0]};	end
				spi_rd_data17:begin r_ad80305_datain <= {r_ad80305_datain[31:18],i_ad80305_do,r_ad80305_datain[16:0]};	end
				spi_rd_data16:begin r_ad80305_datain <= {r_ad80305_datain[31:17],i_ad80305_do,r_ad80305_datain[15:0]};	end
				spi_rd_data15:begin r_ad80305_datain <= {r_ad80305_datain[31:16],i_ad80305_do,r_ad80305_datain[14:0]};	end
				spi_rd_data14:begin r_ad80305_datain <= {r_ad80305_datain[31:15],i_ad80305_do,r_ad80305_datain[13:0]};	end
				spi_rd_data13:begin r_ad80305_datain <= {r_ad80305_datain[31:14],i_ad80305_do,r_ad80305_datain[12:0]};	end
				spi_rd_data12:begin r_ad80305_datain <= {r_ad80305_datain[31:13],i_ad80305_do,r_ad80305_datain[11:0]};	end
				spi_rd_data11:begin r_ad80305_datain <= {r_ad80305_datain[31:12],i_ad80305_do,r_ad80305_datain[10:0]};	end
				spi_rd_data10:begin r_ad80305_datain <= {r_ad80305_datain[31:11],i_ad80305_do,r_ad80305_datain[9:0]} ;	end
				spi_rd_data9 :begin r_ad80305_datain <= {r_ad80305_datain[31:10],i_ad80305_do,r_ad80305_datain[8:0]} ;	end
				spi_rd_data8 :begin r_ad80305_datain <= {r_ad80305_datain[31:9],i_ad80305_do,r_ad80305_datain[7:0]}  ;	end
				spi_rd_data7 :begin r_ad80305_datain <= {r_ad80305_datain[31:8],i_ad80305_do,r_ad80305_datain[6:0]}  ;	end
				spi_rd_data6 :begin r_ad80305_datain <= {r_ad80305_datain[31:7],i_ad80305_do,r_ad80305_datain[5:0]}  ;	end
				spi_rd_data5 :begin r_ad80305_datain <= {r_ad80305_datain[31:6],i_ad80305_do,r_ad80305_datain[4:0]}  ;   end
				spi_rd_data4 :begin r_ad80305_datain <= {r_ad80305_datain[31:5],i_ad80305_do,r_ad80305_datain[3:0]}  ;   end
				spi_rd_data3 :begin r_ad80305_datain <= {r_ad80305_datain[31:4],i_ad80305_do,r_ad80305_datain[2:0]}  ;   end
				spi_rd_data2 :begin r_ad80305_datain <= {r_ad80305_datain[31:3],i_ad80305_do,r_ad80305_datain[1:0]}  ;   end
				spi_rd_data1 :begin r_ad80305_datain <= {r_ad80305_datain[31:2],i_ad80305_do,r_ad80305_datain[0]}    ;   end
				spi_rd_data0 :begin r_ad80305_datain <= {r_ad80305_datain[31:1],i_ad80305_do}                        ;   end
			default:
				begin
					r_ad80305_datain <= r_ad80305_datain;
				end
			endcase
		end
	else
		r_ad80305_datain <= r_ad80305_datain;
		
		
end

//---------------------------------------------------------
//输出片选
//---------------------------------------------------------
reg 	r_chip_cs;
always@(posedge i_fpga_clk_125p or negedge i_fpga_rst_125p)
begin
	if(!i_fpga_rst_125p)
			r_chip_cs <= 1'b1;
	else if(spi_current_state == spi_idle)
			r_chip_cs <= 1'b1;
	else		
			r_chip_cs <= 1'b0;
end

//---------------------------------------------------------
//最后结果表示
//---------------------------------------------------------
reg [7:0] r_rw_result;
always@(posedge i_fpga_clk_125p or negedge i_fpga_rst_125p)
begin
	if(!i_fpga_rst_125p)
		r_rw_result <= 8'd1;
	else if(spi_current_state == spi_start)
		r_rw_result <= 8'd0;
	else if(spi_current_state == spi_idle)
		r_rw_result <= 8'd1;
	else
		r_rw_result <= r_rw_result;
		
end


assign o_rw_data = r_ad80305_datain;
assign o_rw_result = r_rw_result;

assign o_ad80305_clk = r_ad80305_clk    ;
assign o_ad80305_di  = r_ad80305_dataout;
assign o_ad80305_cs = r_chip_cs         ;


endmodule    
    
    