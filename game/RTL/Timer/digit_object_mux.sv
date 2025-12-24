// decides which digit to draw

module digit_object_mux     	
	(
   // Input, Output Ports
	input	 logic [10:0] ones_x_offest,
	input	 logic [10:0] ones_y_offest,
	input  logic ones_dr, //drawing request
	input  logic [3:0] ones_digit,
	
	input	 logic [10:0] tens_x_offest,
	input	 logic [10:0] tens_y_offest,
	input  logic tens_dr, //drawing request
	input  logic [3:0] tens_digit,
	
	output	logic [10:0] x_offest,
	output	logic [10:0] y_offest,
	output   logic dr, //drawing request
	output   logic [3:0] digit
   );
	
	
always_comb begin
	
		//the object aren't overlaping, thus if one has a dr, the other doesn't
		// if both dr is zero then nothing will be drawen
		x_offest = ones_x_offest;
		y_offest = ones_y_offest;
		dr = ones_dr;
		digit = ones_digit;
		if (tens_dr) begin
			x_offest = tens_x_offest;
			y_offest = tens_y_offest;
			dr = tens_dr;
			digit = tens_digit;
		end
end 

endmodule