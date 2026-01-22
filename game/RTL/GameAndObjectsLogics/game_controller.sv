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
parameter logic [13:0] INIT_GOAL = 13'd200;
// going up with each level
parameter logic [7:0] INIT_TIME = 8'd60;
// how much it is going up
localparam logic [2:0] LEVEL_TIME_DT = 3'd5;
localparam logic [3:0] SCORE_DT = 4'd10;

// state machine and parameters declaration 
enum logic [2:0] {IDLE_ST, INIT_NEW_LEVEL_ST, START_LEVEL_ST, PLAY_LEVEL_ST, LEVEL_END_ST} game_SM;

logic [2:0] clk_counter;
// --- Edge Detection Logic ---
logic next_level_d, skip_level_d;
logic next_level_pulse, skip_level_pulse;

always_ff @(posedge clk or negedge resetN) begin
    if (!resetN) begin
        next_level_d <= 1'b0;
        skip_level_d <= 1'b0;
    end else begin
        next_level_d <= next_level;
        skip_level_d <= skip_level;
    end
end

// These pulses are high for only ONE clock cycle per press
assign next_level_pulse = (next_level == 1'b1) && (next_level_d == 1'b0);
assign skip_level_pulse = (skip_level == 1'b1) && (skip_level_d == 1'b0);


always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin 
		start_level <= 0;
		level_num <= 2'd0;
		goal <= 0;
		game_SM <= IDLE_ST;
		timer_time <= 0;
		clk_counter <= 0;
	end 
	
	else begin
		case (game_SM)
		
		
			// waits to start the game
			IDLE_ST: begin
				start_level <= 0;
				level_num <= 2'd0;
				timer_time <= 0;
				goal <= 0;
				clk_counter <= 0;
				if (next_level_pulse) begin
					game_SM <= INIT_NEW_LEVEL_ST;
				end
			end
			
			INIT_NEW_LEVEL_ST: begin
				level_num <= level_num + 1;
				// max time is 5*5 so 60 - 25 = 35 for the last level - timer max is digit
				timer_time <= INIT_TIME - LEVEL_TIME_DT * level_num;
				goal <= INIT_GOAL + SCORE_DT * level_num;
				game_SM <= START_LEVEL_ST;
				clk_counter <= 3'd2; //needs to wait one more clk for the level to change state - 2 for the safe side
			end
			
			// sends a pulse that the level started
			START_LEVEL_ST: begin
				start_level <= 1;
				//needs to wait one more clk for the level to change state
				clk_counter <= clk_counter - 1;
				if (clk_counter == 0)
					game_SM <= PLAY_LEVEL_ST;
			end
			
			// wait untill something happens during the level - finished or skip to next one
			PLAY_LEVEL_ST: begin
				start_level <= 0;
				if (skip_level_pulse) begin
					game_SM <= INIT_NEW_LEVEL_ST;
				end
				else if (level_ended)
					game_SM <= LEVEL_END_ST;
			end
			
			// check if the player winned the level or the game had finished
			LEVEL_END_ST: begin
				// move to the next level if the player is allowed and wants
				if (score >= goal && level_num < MAX_LEVEL) begin
				// waits for the player
					if(next_level_pulse)
						game_SM <= INIT_NEW_LEVEL_ST;
				end
				// if there is no other level or the player lose (didn't achived the score)
				else
					game_SM <= IDLE_ST;
			end
		
		endcase
	end 
end

endmodule
