module	line_object	(	
 
					input	 logic clk,
					input	 logic resetN,
					input  logic signed 	[10:0] x_end,
					input  logic signed 	[10:0] y_end,
					//  current VGA pixel 
					input	 logic signed	[10:0] pixelX, 
					input  logic signed	[10:0] pixelY,
					// used incase you want to connect in the the middle of the claw
					input	 logic signed  [10:0] x_offset,
					
					output	logic	drawingRequest, // indicates pixel inside the bracket
					output	logic	[7:0]	 RGBout 
);

// line start loc
parameter int x_start = 300;
parameter int y_start = 0;
parameter int width = 2;
parameter [7:0] line_color = 8'h6d ; //gray
localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// bitmap  representation for a transparent pixel 


// total boundries - enforce end and start are bigger and smaller in colleration
logic is_x_in_range, is_y_in_range; 
// the offset is to move the x start/end togther
// the width is for the case where x_end==x_start or y, where these conditions minimize the width
assign is_x_in_range = (pixelX >= (x_start < x_end ? x_start : x_end)  + x_offset - width) &&
							  (pixelX <= (x_start > x_end ? x_start : x_end)  + x_offset + width);
assign is_y_in_range = (pixelY >= (y_start < y_end ? y_start : y_end) - width) && 
							  (pixelY <= (y_start > y_end ? y_start : y_end) + width);

// check if pixel within line equastion with a certain width
// x_offset is for both x_end and x_start and they cancel each other where they get minused
logic signed [21:0] a, b, diff; 
assign a = (pixelY - y_start) * (x_end - x_start);
assign b = (y_end - y_start) * (pixelX - (x_start + x_offset));
assign diff = a - b;

// Normalized Width Calculation -  width is always possitive
logic [10:0] dx, dy;
assign dx = (x_end > x_start) ? (x_end - x_start) : (x_start - x_end);
assign dy = (y_end > y_start) ? (y_end - y_start) : (y_start - y_end);

logic signed [21:0] threshold;
assign threshold = (width * (dx + dy)) + ((dx + dy) >> 1) + 11'd1; // Scales width based on line direction
// add a factor to ensure a thickness when dx or dy are 0

logic is_within_line;
assign is_within_line = ((diff < 0 ? -diff : diff) <= threshold);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout			<=	TRANSPARENT_ENCODING;
		drawingRequest	<=	1'b0;
	end
	else begin
		RGBout <= TRANSPARENT_ENCODING;
		drawingRequest <= 1'b0;
		
		if (is_x_in_range && is_y_in_range && is_within_line) begin
			RGBout <= line_color;
			drawingRequest <= 1'b1;
		end
	end
end

endmodule
	
	