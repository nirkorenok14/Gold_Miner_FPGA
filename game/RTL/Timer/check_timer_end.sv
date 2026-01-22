module check_timer_end     	
	(
   // Input, Output Ports
	input  logic clk, 
	input  logic resetN, 
	input	 logic [3:0] ones,
	input	 logic [3:0] tens,
	input  logic start_level,
	
	output logic enable_timer,
	output logic timer_ended
	
   );
	
	logic [3:0] prev_ones;
	logic [3:0] prev_tens;
	
	
   always_ff @( posedge clk or negedge resetN )
   begin
	
		// asynchronous reset
		if ( !resetN ) begin
			enable_timer <= 1'b0;
			timer_ended <= 1'b0;
			prev_ones <= 0;
			prev_tens <= 0;
		end
		
		// executed check if timer reached zero
		else begin
			prev_ones <= ones;
			prev_tens <= tens;
			if (start_level)
				enable_timer <= 1'b1;
			if (ones == 0 && tens == 0 && prev_ones == 1 && prev_tens == 0 && !timer_ended) begin
				enable_timer <= 1'b0;
				timer_ended <= 1'b1;
			end
			else 
				timer_ended <= 1'b0;
		end
		
	end // always

endmodule