module	level_fsm	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	startOfFrame,  // short pulse every start of frame 30Hz
			input logic start_level,
			// drawing requests
			input	logic	claw_dr,
			input	logic	borders_dr,
			input logic miner_dr,
			input logic loot_dr,
			
			input logic timer_endedN,
			input logic is_enter_pressed, // player wants to the claw
			input logic loot_type, // which loot we are on now
			input int goal, // check if the player won the level
			
			output logic claw_collision, // something colliade the claw - border, loot, etc.
			output logic loot_collision, // claw collide with a loot
			output logic move_speed, // define the speed of the claw and loot 
			output int score,
			output logic SingleHitPulse, // critical code, generating A single pulse in a frame, i.e. only collide once 
			output logic level_ended
);

parameter logic [3:0] def_move_speed = 4'd4;

// collisions
assign claw_collision = (claw_dr && borders_dr && miner_dr && loot_dr);
assign loot_collision = (claw_dr && loot_dr);

// loot properties matrix - rows are loot types, colmunes in order are score, move_speed
logic [0:1][0:1][3:0] loot_data ={
    {4'd10, 4'd4},
    {4'd0,  4'd2}
};


localparam [1:0] score_loc = 4'd0;
localparam [1:0] move_speed_loc = 4'd1;

// state machine and parameters declaration 

enum logic [2:0] {idle, swing, going_down, going_back, level_end} SMlevel; // state machine
int collided_loot_type; // save which loot the hook hits

always_ff@(posedge clk or negedge resetN)
begin
	
	if(!resetN)
	begin 
		SingleHitPulse <= 1'b0 ;
		SMlevel <= idle;
		score <= 0;
		move_speed <= 4'd0; 
		collided_loot_type <= -1;
		level_ended <= 1'b0;
		
	end 
	else begin 
			// defaults outputs
			score <= 0;
			move_speed <= 4'd0;
			SingleHitPulse <= 1'b0;
			collided_loot_type <= collided_loot_type;
			level_ended <= 1'b0;
		
			
			case (SMlevel)
			// wait for the level to start
				idle: begin
					if (start_level) begin
						SMlevel <= swing;
						collided_loot_type <= -1;
					end
				end
				
			// the claw waits for the player, can't collide
				swing: begin
					move_speed <= def_move_speed;
					if (!timer_endedN)
						SMlevel <= level_end;
					else if (is_enter_pressed)
						SMlevel <= going_down;
				end
			// the claws search for collision with a loot
				going_down: begin
					move_speed <= def_move_speed;
					if (!timer_endedN)
						SMlevel <= level_end;
					else if (claw_collision) begin
						SingleHitPulse <= 1'b1;
						SMlevel <= going_back;
						if(loot_collision)
							collided_loot_type <= loot_type;
					end
				end
			// the claw hit something and going back, either with or without something
				going_back: begin
					move_speed <= (collided_loot_type != -1) ? loot_data[collided_loot_type][move_speed_loc] : def_move_speed;
					if (!timer_endedN)
						SMlevel <= level_end;
					if (claw_dr && miner_dr) begin
						score <= score + loot_data[collided_loot_type][score_loc];
						SMlevel <= swing;
					end
				end
			// the timer is run out, waits for another level to begin
				level_end: begin
					level_ended <= 1'b1;
					// delete - multiple levels the game controller rules all
					if (is_enter_pressed && score >= goal)
						SMlevel <= idle;
				end
			endcase
	end 
end

endmodule
