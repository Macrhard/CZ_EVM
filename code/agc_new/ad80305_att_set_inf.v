`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: comba
// Engineer: 
// 
// Create Date:    
// Design Name: 
// Module Name:    mix_dds 
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

module ad80305_att_set_inf(
    input                i_clk,
    input                i_rst_n,
    
    input  [5:0]         i_temp_value,
    input  [5:0]		 i_overflow_agc,
    input  [5:0]         i_gain_value,
    input  [5:0]         i_att_value ,
    input  [5:0]         i_agc_value ,
 
    input  [5:0]         i_max_att_value,//可设置的最大ATT值，由监控设置
    input                i_mcu_clr      ,//清除对ad80305的设置，由监控设置

    output [5:0]         o_to_be_set_pulse,//需要设置的脉冲数，调试用
    output [5:0]         o_set_success_pulse,//已经设置成功的脉冲数，调试用

    
    output               o_read_ad80305,//触发一次读取ad80305数据，对象为10c的值
//    output [9:0]  		 o_rw_addr	   ,    
//    output [2:0]		 o_mod_sel	   ,
//    output [7:0]         o_wr_data_mcu ,
//    output [1:0]		 o_rw_chip_mcu , 
    
    input                i_read_success,//回读ad80305成功标志
    input  [5:0]         i_read_ad80305_value,//回读的ad80305数值

    output [1:0]         o_dec_value,//输出设置在数字域的小数部分

    output               o_inc_pulse    ,
    output               o_dec_pulse        
);

reg r_wire_en_att;
reg r_read_ad80305_refresh;

//定期检查是否存在数据更新,每32个clk更新一次
reg [4:0] cnt_32;
always@(posedge i_clk or negedge i_rst_n)
begin
    if(!i_rst_n)
	cnt_32 <= 5'd0;
    else
	cnt_32 <= cnt_32 + 5'd1;
end

reg [5:0] r0_temp_value;
always@(posedge i_clk )
begin
    if(cnt_32  == 5'd0)
        r0_temp_value <= i_temp_value;
    else
        r0_temp_value <= r0_temp_value ;
end

 reg [5:0] r0_overflow_agc;
always@(posedge i_clk )
begin
    if(cnt_32  == 5'd0)
        r0_overflow_agc <= i_overflow_agc;
    else
        r0_overflow_agc <= r0_overflow_agc ;
end


reg [5:0] r0_gain_value;
always@(posedge i_clk)
begin
    if(cnt_32  == 5'd0)
        r0_gain_value <= i_gain_value;
    else
        r0_gain_value <= r0_gain_value;
end


reg [5:0] r0_att_value;
always@(posedge i_clk)
begin
    if(cnt_32  == 5'd0)
        r0_att_value <= i_att_value ;
    else
        r0_att_value <= r0_att_value;
end

reg [5:0] r0_agc_value ;
always@(posedge i_clk)
begin
    if(cnt_32  == 5'd0)
        r0_agc_value <= i_agc_value ;
    else
        r0_agc_value <= r0_agc_value ;
end

////累加各设置量
reg [6:0] r0_sum0 ;
always@(posedge i_clk or negedge i_rst_n)
begin
    if(!i_rst_n)
        r0_sum0 <= 7'd0;
    else
        r0_sum0 <= {1'b0,r0_temp_value} + {1'b0,r0_gain_value}+{1'b0,r0_overflow_agc};
end

reg [6:0] r0_sum1 ;
always@(posedge i_clk or negedge i_rst_n)
begin
    if(!i_rst_n)
        r0_sum1 <= 7'd0;
    else
        r0_sum1 <= {1'b0,r0_att_value} + {1'b0,r0_agc_value};
end

reg [7:0] r1_sum ;
always@(posedge i_clk or negedge i_rst_n)
begin
    if(!i_rst_n)
        r1_sum  <= 8'd0;
    else
        r1_sum  <= {1'b0,r0_sum0} + {1'b0,r0_sum1};//3 piple
end

//设置的最大值限制
reg [5:0] r2_sum ;
always@(posedge i_clk or negedge i_rst_n)
begin
    if(!i_rst_n)
        r2_sum  <= 6'd0;
    else if(r1_sum[7:1] > i_max_att_value)
		r2_sum  <= i_max_att_value;
    else if(r1_sum[7:1] <0)
		r2_sum <= 6'd0;
    else
        r2_sum  <= r1_sum[6:1];
end


//小数部分
assign o_dec_value = {1'b0,r1_sum[0]};


//定义需要设置的att值
reg [5:0]  r_to_be_set_value = 0;
//记录已经设置的att值
reg [5:0] r_set_success = 0;

always@(posedge i_clk)
begin
    if(cnt_32  == 5'd31)
    	r_to_be_set_value <= r2_sum;
    else 
       r_to_be_set_value <= r_to_be_set_value ;
end

assign o_to_be_set_pulse = r_to_be_set_value ;

//产生一个脉冲
reg r_inc_pulse_gen;
always@(posedge i_clk or negedge i_rst_n)
begin
    if(!i_rst_n)
       r_inc_pulse_gen <= 1'b0;
    else if((cnt_32 == 5'd0)&&(i_mcu_clr == 1'b0)&&(r_wire_en_att == 1'b0))
       begin
           if(r_to_be_set_value > r_set_success)
               r_inc_pulse_gen <= 1'b1;
           else
               r_inc_pulse_gen <= 1'b0;
       end
    else
        r_inc_pulse_gen <= 1'b0;
end

reg r_dec_pulse_gen;
always@(posedge i_clk or negedge i_rst_n)
begin
    if(!i_rst_n)
       r_dec_pulse_gen <= 1'b0;
    else if((cnt_32 == 5'd0)&&(i_mcu_clr == 1'b0)&&(r_wire_en_att == 1'b0))
       begin
           if(r_to_be_set_value < r_set_success)
               r_dec_pulse_gen <= 1'b1;
           else
               r_dec_pulse_gen <= 1'b0;
       end
    else
       r_dec_pulse_gen <= 1'b0;
end


reg r_inc_pulse_output;
always@(posedge i_clk or negedge i_rst_n)
begin
    if(!i_rst_n)
       r_inc_pulse_output <= 1'b0;
    else if((r_inc_pulse_gen == 1'b1))
       r_inc_pulse_output <= 1'b1;
    else if(cnt_32 == 5'd16)
       r_inc_pulse_output <= 1'b0;
    else
       r_inc_pulse_output <= r_inc_pulse_output;
end

reg r_dec_pulse_output;
always@(posedge i_clk or negedge i_rst_n)
begin
    if(!i_rst_n)
       r_dec_pulse_output <= 1'b0;
    else if(r_dec_pulse_gen == 1'b1)
       r_dec_pulse_output <= 1'b1;
    else if(cnt_32 == 5'd16)
       r_dec_pulse_output <= 1'b0;
    else
       r_dec_pulse_output <= r_dec_pulse_output;
end

assign o_inc_pulse = r_inc_pulse_output ;
assign o_dec_pulse = r_dec_pulse_output ;

reg [5:0] r_read_ad80305_value;
always@(posedge i_clk)
begin
    r_read_ad80305_value <= i_max_att_value - i_read_ad80305_value ;
end

//记录已经设置的att值
always@(posedge i_clk)
begin
    if(i_mcu_clr == 1'b1)
        r_set_success <= 5'd0;
    else if(r_read_ad80305_refresh == 1'b1)
    	begin
    		if(r_set_success != r_read_ad80305_value)
    			r_set_success <= r_read_ad80305_value;
    		else
    			r_set_success <= r_set_success;
    	end
    else if(r_inc_pulse_gen == 1'b1)
        r_set_success <= r_set_success + 6'd1;
    else if(r_dec_pulse_gen == 1'b1) 
        r_set_success <= r_set_success - 6'd1;
    else
       r_set_success <= r_set_success;
end

reg [5:0] r1_set_success ;
always@(posedge i_clk)
begin
   	r1_set_success <= r_set_success;
end

//触发一次回读ad80305寄存器为10c的值
reg r_read_ad80305_start;
always@(posedge i_clk or negedge i_rst_n)
begin
    if(!i_rst_n)
    	r_read_ad80305_start <= 1'b0;
    else if(r1_set_success != r_set_success)
		begin
			if(r_set_success == r_to_be_set_value)
				r_read_ad80305_start <= 1'b1;
			else
				r_read_ad80305_start <= 1'b0;
		end
	else
		r_read_ad80305_start <= 1'b0;
end

//在读取ad80305时禁止对ad80305进行增益控制
always@(posedge i_clk or negedge i_rst_n)
begin
    if(!i_rst_n)
    	r_wire_en_att <= 1'b0;
    else if(r_read_ad80305_start == 1'b1)
    	r_wire_en_att <= 1'b1;
    else if(r_read_ad80305_refresh == 1'b1)
    	r_wire_en_att <= 1'b0;
    else
    	r_wire_en_att <= r_wire_en_att;    	
end


reg r_read_success;
always@(posedge i_clk or negedge i_rst_n)
begin
    if(!i_rst_n)
    	r_read_success <= 1'b0;
    else
    	r_read_success <= i_read_success;
end


always@(posedge i_clk or negedge i_rst_n)
begin
    if(!i_rst_n)
    	r_read_ad80305_refresh <= 1'b0;
    else if(((!r_read_success)&i_read_success))
    	r_read_ad80305_refresh <= 1'b1;
    else
    	r_read_ad80305_refresh <= 1'b0;
end



assign o_read_ad80305 = r_read_ad80305_start;

assign o_set_success_pulse = r_set_success;

endmodule

























