
// (c) Technion IIT, Department of Electrical Engineering 2025 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018

//-- Eyal Lev 31 Jan 2021

module	objects_mux	(	
//		--------	Clock Input	 	
					input		logic	clk,
					input		logic	resetN,
		//dr == drawing_request
		// by order of importance: claw should above all always
					input		logic	claw_dr, 
					input		logic	[7:0] claw_RGB,
		// line is imortant than loot, but almost immossible from them to overlap
					input    logic claw_line_dr, 
					input		logic	[7:0] claw_lineRGB,   
			  
		// loot should be second
					input    logic loot_dr, 
					input		logic	[7:0] lootRGB,   
		// miner timer and don't overlaps so order not important
					input 	logic miner_dr,
					input		logic [7:0] minerRGB,
					input    logic timer_dr, 
					input		logic	[7:0] timerRGB,   
		  // background - always last
					input		logic	[7:0] backGroundRGB, 
					input		logic	BG_dr, 
					input		logic	[7:0] RGB_MIF, 
			  
				   output	logic	[7:0] RGBOut
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut	<= 8'b0;
	end
	
	else begin
		if (claw_dr == 1'b1 )   
			RGBOut <= claw_RGB;  //first priority	

		else if (claw_line_dr == 1'b1)
			RGBOut <= claw_lineRGB;
			
		else if (loot_dr == 1'b1)
			RGBOut <= lootRGB;

 		else if (miner_dr == 1'b1)
				RGBOut <= minerRGB;
		else if (timer_dr == 1'b1)
				RGBOut <= timerRGB;
		else if (BG_dr == 1'b1)
				RGBOut <= backGroundRGB ;
		else RGBOut <= RGB_MIF ;// last priority 
		end ; 
	end

endmodule


