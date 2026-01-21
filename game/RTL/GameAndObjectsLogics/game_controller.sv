module	game_controller	(	
			input	logic	clk,
			input	logic	resetN,
			// what is the current score, used to decide if the player managed to pass the level
			input logic [13:0] score,
			// used to start the game and move next level
			input logic next_level,
			// skip level externally
			input logic skip_level,
			// tell the level had ended
			input logic level_ended,
			
			// gives a pulse to all units that all the units to skip to next level
			output logic start_level,
			// what level we are now
			output logic [2:0] level_num,
			// the goal the player needs to get
			output logic [13:0] goal,
			// init the timer for every level
			output logic [7:0] timer_time
			
);

parameter logic [2:0] MAX_LEVEL = 3'd5;
// going down by powers of two each level
parameter logic [13:0] INIT_GOAL = 13'd160;
// going up with each level
parameter logic [7:0] INIT_TIME = 8'd40;
// how much it is going up
parameter logic [2:0] LEVEL_TIME_DT = 3'd5;

// state machine and parameters declaration 
enum logic [2:0] {IDLE_ST, START_LEVEL_ST, PLAY_LEVEL_ST, LEVEL_END_ST} game_SM;



always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin 
		start_level <= 0;
		level_num <= 0;
		goal <= 0;
		game_SM <= IDLE_ST;
		timer_time <= 0;
	end 
	
	else begin
		case (game_SM)
		
		
			// waits to start the game
			IDLE_ST: begin
				start_level <= 0;
				goal <= 0;
				level_num <= 0;
				timer_time <= 0;
				if (next_level)
					game_SM <= START_LEVEL_ST;
			end
			
			// init the and sends a pulse that the level started
			START_LEVEL_ST: begin
				// max time is 5*5 so 25 + 45 so 70 for the last level - timer max is digit
				timer_time <= INIT_TIME + LEVEL_TIME_DT * level_num;
				if (next_level) begin
					start_level <= 1;
					level_num <= level_num + 1;
					goal <= INIT_GOAL >> level_num;
					game_SM <= PLAY_LEVEL_ST;
				end
			end
			
			// wait untill something happens during the level - finished or skip to next one
			PLAY_LEVEL_ST: begin
				start_level <= 0;
				if (skip_level)
					game_SM <= START_LEVEL_ST;
				else if (level_ended)
					game_SM <= LEVEL_END_ST;
			end
			
			// check if the player winned the level or the game had finished
			LEVEL_END_ST: begin
				// move to the next level if the player is allowed and wants
				if (score >= goal && level_num < MAX_LEVEL) begin
				// waits for the player
					if(next_level)
						game_SM <= START_LEVEL_ST;
				end
				// if there is no other level or the player lose (didn't achived the score)
				else
					game_SM <= IDLE_ST;
			end
		
		endcase
	end 
end

endmodule
