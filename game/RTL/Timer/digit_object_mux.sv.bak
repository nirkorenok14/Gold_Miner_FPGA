module check_timer_end     	
	(
   // Input, Output Ports
	input  logic clk, 
	input  logic resetN, 
	input	 logic [3:0] ones,
	input	 logic [3:0] tens,
	
	output logic timer_endedN
   );
	
	
   always_ff @( posedge clk or negedge resetN )
   begin
	
		// asynchronous reset
		if ( !resetN )
			timer_endedN <= 1'b1;
		
		// executed once every clock 	
		else begin
			if (ones == 0 && tens == 0) 
				timer_endedN <= 1'b0;
			else 
				timer_endedN <= 1'b1;
		end // else clk
		
	end // always

endmodule