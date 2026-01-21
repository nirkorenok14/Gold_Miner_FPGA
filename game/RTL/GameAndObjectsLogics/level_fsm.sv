module level_fsm (
    input  logic       clk,
    input  logic       resetN,
    input  logic       startOfFrame,  // short pulse every start of frame 30Hz
    input  logic       start_level,
    // drawing requests
    input  logic       claw_dr,
    input  logic       borders_dr,
    input  logic       loot_dr,
    
    input  logic       timer_ended,
    input  logic       is_enter_pressed, // player wants to the claw
    input  logic [2:0] loot_type,        // which loot we are on now
    input  logic [13:0] goal,             // the goal the player need to get
    input  logic       claw_returned,    // the claw reached its' original location
    
    // collision are on only once on hit with object on the way down
    output logic       claw_collision, // something colliade the claw - border, loot, etc.
    output logic       loot_collision, // claw collide with a loot 
    output logic [3:0] move_speed,     // define the speed of the claw and loot 
    output logic [13:0] score,
    output logic       level_ended,

    // --- NEW OUTPUTS FOR SOUND ---
    output logic [3:0] sound_request, // 1=Win, 2=Loss, 3=Claw, 4=Gold, 5=Stone
    output logic       play_sound     // Pulse to trigger the sound
);

    parameter logic [3:0] def_move_speed = 4'd4;
	 localparam logic [2:0] TOTAL_LOOT_TYPES = 3'd5;

    // collisions
    logic inter_claw_collision;
    logic inter_loot_collision;
    assign inter_claw_collision = inter_loot_collision | (claw_dr && borders_dr);
    assign inter_loot_collision = (claw_dr && loot_dr);


    // loot properties 
    logic [0:TOTAL_LOOT_TYPES-1][6:0] loot_data_scores ={
        7'd0, // default
        7'd10, // gold
        7'd0,  // rock
		  7'd50, //diamond 
		  7'd100 // goblet
    };
    logic [0:TOTAL_LOOT_TYPES-1][3:0] loot_data_speeds ={
        def_move_speed, // default
        4'd4, // gold
		  4'd2, // rock
		  4'd8, //diamond
		  4'd1 // goblet
    };
	 logic [0:TOTAL_LOOT_TYPES-1][3:0] loot_data_sounds ={
        4'd0, // default
        4'd4, // gold - good loot
		  4'd5, // rock - bad loot
		  4'd4, //diamond - good loot
		  4'd4 // goblet - good loot
    };

    localparam [1:0] score_loc = 4'd0;
    localparam [1:0] move_speed_loc = 4'd1;

    // state machine and parameters declaration 
    enum logic [2:0] {IDLE_ST, SWING_ST, GOING_DOWN_ST, HOLD_COLLISION_ST, GOING_BACK_ST, LEVEL_END_ST} SMlevel; 
    logic [2:0] collided_loot_type; // save which loot the hook hits
    logic is_loot_collision;

    // Sound Logic: Helper to trigger sound for just one clock cycle
    // We use this task or just direct assignment in the states
    
    always_ff @(posedge clk or negedge resetN)
    begin
        if(!resetN)
        begin 
            SMlevel <= IDLE_ST;
            score <= 0;
            move_speed <= 4'd0; 
            collided_loot_type <= 3'd0;
            level_ended <= 1'b0;
            is_loot_collision <= 1'b0;
            
            // Reset Sound Outputs
            sound_request <= 4'd0;
            play_sound    <= 1'b0;
        end 
        else begin 
            // Default: Stop triggering sound (pulse behavior)
            play_sound <= 1'b0; 

            case (SMlevel)
            // wait for the level to start
                IDLE_ST: begin
                    collided_loot_type <= 3'd0;
                    score <= 0;
                    level_ended <= 1'b0;
                    is_loot_collision <= 1'b0;
						  SMlevel <= SWING_ST;
                end
                
            // the claw waits for the player, can't collide
                SWING_ST: begin
                    collided_loot_type <= 0;
                    move_speed <= def_move_speed;
                    is_loot_collision <= 1'b0;
						  
						  if (start_level)
								SMlevel <= IDLE_ST;
                    else if (timer_ended)
                        SMlevel <= LEVEL_END_ST;
                    
                    else if (is_enter_pressed) begin
                        SMlevel <= GOING_DOWN_ST;
                        
                        // --- SOUND 3: CLAW MOVING (Trigger when going down) ---
                        sound_request <= 4'd3; 
                        play_sound    <= 1'b1;
                    end
                end

            // the claw search for collision with a loot
                GOING_DOWN_ST: begin
                    move_speed <= def_move_speed;
						  if (start_level)
								SMlevel <= IDLE_ST;
                    else if (timer_ended)
                        SMlevel <= LEVEL_END_ST;
                    else if (inter_claw_collision) begin
                        SMlevel <= HOLD_COLLISION_ST;
                        claw_collision <= 1'b1;
								if(inter_loot_collision) begin
									is_loot_collision <= 1'b1;
									loot_collision <= 1'b1;
								end
                    end                         
                end
                
                HOLD_COLLISION_ST: begin
                    // sample one clock after, because it is changed only in this clk
                    if (is_loot_collision) begin
                        collided_loot_type <= loot_type;
                        is_loot_collision <= 1'b0;
								play_sound    <= 1'b1;
                        
                        // --- SOUND TRIGGER FOR LOOT ---
                        // We check 'loot_type' directly here because 'collided_loot_type' is just being updated
							   sound_request <= loot_data_sounds[loot_type];
                    end
                    claw_collision <= 1'b0;
						  loot_collision <= 1'b0;
                    if (start_level)
								SMlevel <= IDLE_ST;
						  else if (timer_ended)
                        SMlevel <= LEVEL_END_ST;
                    else if (startOfFrame) begin
                        SMlevel <= GOING_BACK_ST;
                    end
                end

            // the claw hit something and going back, either with or without something
                GOING_BACK_ST: begin
                    move_speed <= loot_data_speeds[collided_loot_type];
						  if (start_level)
								SMlevel <= IDLE_ST;
                    else if (timer_ended)
                        SMlevel <= LEVEL_END_ST;
                    else if (claw_returned) begin
                        score <= score + loot_data_scores[collided_loot_type];
                        SMlevel <= SWING_ST;
                    end
                end

            // the timer is run out, waits for another level to begin
                LEVEL_END_ST: begin
                    // Only trigger Win/Loss sound ONCE when entering this state
                    if (level_ended == 1'b0) begin 
								play_sound  <= 1'b1;
                        if (score >= goal)
                            sound_request <= 4'd1; // Sound 1: Win
                        else begin
                            sound_request <= 4'd2; // Sound 2: Loss
                        end
                    end

                    level_ended <= 1'b1;
                    move_speed <= 4'd0;
                    
                    if (start_level)
								SMlevel <= IDLE_ST;
                end
                
                default: begin
                    SMlevel <= IDLE_ST;
                end
                
            endcase
    end 
end

endmodule