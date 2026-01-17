module	claw_move	(	
 
					input	 logic clk,
					input	 logic resetN,
					input	 logic startOfFrame,      //short pulse every start of frame 30Hz 
					input  logic claw_collision,         //collision if smiley hits an object
					input  logic is_enter_pressed,
					input	 logic [3:0] move_speed,
					input  logic start_level,
					output logic signed 	[10:0] topLeftX, // output the top left corner 
					output logic signed	[10:0] topLeftY,  // can be negative , if the object is partliy outside 
					output logic claw_returned
					
);

// circle center position
parameter int INITIAL_X = 280;
parameter int INITIAL_Y = 50;
// define radius
parameter logic [2:0] SHIFT_RADIUS = 3'd5;
parameter logic [2:0] SHIFT_RADIUS_LINEAR = 3'd3;
// how many frames the claw waits before movement - 1 for simulation mode
parameter logic [3:0] wait_time = 1;


typedef enum logic [3:0] {IDLE_ST,         	// initial state
				 SWING_MOVE_ST, 		// moving in swings no collision 
				 WAIT_ST,  				// pause so the movement won't be too fast
				 LINEAR_MOVE_ST,		// the claw move down after user clicked
				 COLLISION_ST
				 }  SM_type ;

SM_type SM_Motion;
SM_type prev_SM;


logic [9:0] dx;
logic [9:0] dy;
logic [6:0] alpha = 0; //degree between 0-90
logic signed [10:0] next_alpha;
int x_position ; //position   
int y_position ;
logic is_right_quarter; //right to left
logic signed [1:0] alpha_speed;
logic [3:0] time_counter;
logic down_dir; // up or down direcation (1 - down, 0 - up)
logic signed [8:0] line_length; //how long did we go down from start location
logic [3:0] init_speed; 
 
 //---------
 
always_ff @(posedge clk or negedge resetN or posedge start_level)
begin : fsm_move_proc

	if (!resetN || start_level) begin 
		SM_Motion <= IDLE_ST; 
		x_position <= INITIAL_X + dx; 
		y_position <= INITIAL_Y + dy;
		alpha <= 0;
		is_right_quarter <= 1;
		alpha_speed <= 2'sd0;
		time_counter <= 0;
		prev_SM <= IDLE_ST;
		down_dir <= 1;
		line_length <= 0;
		init_speed <= move_speed;
	end 	
	
	else begin
	
		case(SM_Motion)
			
			IDLE_ST: begin	
				alpha_speed <= 2'sd1;
				is_right_quarter <= 1;
				time_counter <= 0;
				line_length <= 0;
				claw_returned <= 0;
				down_dir <= 1;
				init_speed <= move_speed;
				if (startOfFrame)
					SM_Motion <= SWING_MOVE_ST ;
			end
	
			SWING_MOVE_ST:  begin
				init_speed <= move_speed;
				down_dir <= 1;
				line_length <= 1;
				alpha <= next_alpha[6:0];
				if (next_alpha > 11'sd90 || next_alpha < 11'sd0) begin
					alpha_speed <= -alpha_speed;					
					if (next_alpha > 11'sd90) begin
						alpha <= 90;
						is_right_quarter <= !is_right_quarter;
					end
					if (next_alpha <  11'sd0)
						alpha <= 0;
				end
					
				if (is_right_quarter) 
					x_position <= INITIAL_X + dx;
				else
					x_position <= INITIAL_X - dx;
				y_position <= INITIAL_Y + dy;
				claw_returned <= 0;
				if (is_enter_pressed) 
					SM_Motion <= LINEAR_MOVE_ST;
				else begin
					SM_Motion <= WAIT_ST;
					prev_SM <= SWING_MOVE_ST;
					time_counter <= 0;
				end
			end
				
			WAIT_ST: begin
				if (prev_SM == SWING_MOVE_ST && is_enter_pressed)
					SM_Motion <= LINEAR_MOVE_ST;
				else if (claw_collision && prev_SM == LINEAR_MOVE_ST && down_dir) begin
					init_speed <= move_speed;
					prev_SM <= COLLISION_ST;
					time_counter <= 0; // collision happens before start frame, and it is highly impossible for hitting the bottom right corner
				end
				else if (time_counter == wait_time)
					SM_Motion <= prev_SM;
				if (startOfFrame)
					time_counter <= time_counter + 1;
			end 
		
			LINEAR_MOVE_ST: begin
				// calc line movement
				if	(is_right_quarter)
					x_position <= INITIAL_X + dx + dx_shifted * move_speed * line_length;
				else
					x_position <= INITIAL_X - dx - dx_shifted * move_speed * line_length;
				y_position <= INITIAL_Y + dy + dy_shifted * move_speed * line_length;
				if (down_dir)
					line_length <= line_length + 1;
				else
					line_length <= line_length - 1;
				if (line_length <= 0) begin 
						SM_Motion <= SWING_MOVE_ST;
						claw_returned <= 1;
				end
//				end
				// collision can only happen once with a loot
				else if (claw_collision && down_dir) begin
					SM_Motion <= WAIT_ST;
					prev_SM <= COLLISION_ST;
					time_counter <= 0;
				end
				else begin
					SM_Motion <= WAIT_ST;
					prev_SM <= LINEAR_MOVE_ST;
					time_counter <= 0;
				end
				
			end
			
			COLLISION_ST: begin
				case ({init_speed, move_speed})
					{4'd4, 4'd2}: line_length <= line_length << 1; // Speed halved -> length doubles
					{4'd4, 4'd1}: line_length <= line_length << 2; // Speed /4 -> length x4
					{4'd4, 4'd8}: line_length <= line_length >> 1; // Speed x2 -> length /2
					default:      line_length <= line_length;
				endcase
				down_dir <= 0;
				SM_Motion <= WAIT_ST;
				prev_SM <= LINEAR_MOVE_ST;
			end
			
			default: begin
					SM_Motion <= IDLE_ST;
				end
			
		endcase  // case 

		
	end 

end // end fsm_move

logic [9:0] dx_shifted;
assign dx_shifted = dx >> SHIFT_RADIUS_LINEAR;
logic [9:0] dy_shifted;
assign dy_shifted = dy >> SHIFT_RADIUS_LINEAR;

  
assign topLeftX = x_position;
assign topLeftY = y_position;
assign next_alpha = $signed({1'b0, alpha}) + (alpha_speed * $signed({1'b0, move_speed}));
circle_object circle_calc(.alpha(alpha), .shift_radius(SHIFT_RADIUS), .dx(dx), .dy(dy));

endmodule	
//---------------
 
