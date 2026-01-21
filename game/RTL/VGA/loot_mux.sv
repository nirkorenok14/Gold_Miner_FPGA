module loot_mux	(	
		//ir == inside rectangle
		// by order of importance: caught loot
					input		logic	[2:0] caught_loot_type, // saved by another module
					input		logic	caught_loot_ir,
					input		logic [10:0] caught_loot_offestX,
					input		logic [10:0] caught_loot_offestY,

		// loot from the matrix is second in importance
					input		logic	[2:0] matrix_loot_type,
					input		logic	matrix_loot_ir,
					input		logic [10:0] matrix_loot_offestX,
					input		logic [10:0] matrix_loot_offestY, 
					
					output		logic	[2:0] loot_type,
					output		logic [10:0] loot_offestX,
					output		logic [10:0] loot_offestY,
					output		logic	loot_ir
);



always_comb begin
	// loot type 0 is saved for empty
	if(caught_loot_type != 2'b0 && caught_loot_ir) begin
			loot_type = caught_loot_type; 
			loot_ir = caught_loot_ir;
			loot_offestX = caught_loot_offestX;
			loot_offestY = caught_loot_offestY;
	end
	
	// default - the matrix loot
	else begin
		loot_type = matrix_loot_type; 
		loot_ir = matrix_loot_ir;
		loot_offestX = matrix_loot_offestX;
		loot_offestY = matrix_loot_offestY;
	end
end

endmodule


