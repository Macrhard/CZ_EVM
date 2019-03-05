module change_channel(
	input 	[11:0]		i_sin_idata,		//母板 2
	input	[11:0]		i_sin_qdata,
	input				i_sin_iqdata_fp,
	
	input	[11:0]		i_diff_idata,		//子板 3
	input	[11:0]		i_diff_qdata,
	input				i_diff_iqdata_fp,
	
	output		[11:0]	o_sin_idata,
	output		[11:0]	o_sin_qdata,
	output		[11:0]	o_sin_iqdata_fp,
	
	output		[11:0]	o_diff_idata,
	output		[11:0]	o_diff_qdata,
	output				o_diff_iqdata_fp,
		 

	input				i_clk_125p,
	input				i_rst_n,
	
	input 	[7:0]		tx_switch,
	input	[7:0]		rx_switch,
	output 	[11:0]		o_assign_test

); 

	reg state_a; 
	reg state_b;



always @(posedge i_clk_125p or negedge i_rst_n)
begin
	if(!i_rst_n)
		begin
			state_a <= 1'b0;
			state_b <= 1'b0; 
		end
	else 
	begin
		if ((tx_switch == 8'd2) &&(rx_switch == 8'd2))  //母板单端
		begin
			state_a <= 1'b0;
			state_b <= 1'b0; 
		end
		else if((tx_switch == 8'd2) &&(rx_switch == 8'd4))
		begin
			state_a <= 1'b0;
			state_b <= 1'b1; 
		end
		else if((tx_switch == 8'd2) &&(rx_switch == 8'd6))
		begin
			state_a <= 1'b0;
			state_b <= 1'b1;
		end
		else if((tx_switch == 8'd4) &&(rx_switch == 8'd2))
		begin
			state_a <= 1'b1;
			state_b <= 1'b0;
		end
		else if((tx_switch == 8'd4) &&(rx_switch == 8'd4))
		begin
			state_a <= 1'b0;
			state_b <= 1'b0; 
		end
		else if((tx_switch == 8'd4) &&(rx_switch == 8'd6))
		begin
			state_a <= 1'b1;
			state_b <= 1'b0; 
		end
		else if((tx_switch == 8'd6) &&(rx_switch == 8'd6))
		begin
			state_a <= 1'b1;
			state_b <= 1'b1; 
		end
		else
		begin
			state_a <= 1'b0;
			state_b <= 1'b0; 
		end
	end
	
			
end
	
	assign o_sin_idata = (state_a )  ?  i_diff_idata:i_sin_idata;
	assign o_sin_qdata = (state_a )  ? 	i_diff_qdata:i_sin_qdata;
	assign o_sin_iqdata_fp = (state_a) ? 	i_diff_iqdata_fp:i_sin_iqdata_fp;
	
	assign o_diff_idata = (state_b) ?	 	i_sin_idata : i_diff_idata;
	assign o_diff_qdata = (state_b) ? 		i_sin_qdata : i_diff_qdata;
	assign o_diff_iqdata_fp = (state_b) ?	i_sin_iqdata_fp :i_diff_iqdata_fp;
	
	
	assign o_assign_test = i_sin_idata;
endmodule
