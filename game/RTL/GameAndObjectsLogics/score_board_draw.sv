// At the very top of your file
// holds all the char cases 
import char_enum_pkg::*;

module score_board_draw (
    input  logic [10:0] pixelX,
    input  logic [10:0] pixelY,
    
    input  logic [2:0]  level_num,  
    input  logic [13:0] score,  
    input  logic [13:0] target,
	 input  logic [3:0]  units_timer,
	 input  logic [3:0]  tens_timer,
    
    output logic [7:0] scoreboardRGB,
	 output logic [6:0] char_code,
	 output logic [2:0] row_idx,
	 output logic [2:0] col_idx
);
    // ============================================================
    //  CONSTANTS & PARAMETERS
    // ============================================================
    
    // --- TIMER POSITION (Adjustable) ---
    // Defined independently to allow placement anywhere
    localparam int TIMER_LABEL_X = 500; 
    localparam int TIMER_LABEL_Y = 55;  

	 
	// --- LEFT SIDE SCOREBOARD POSITIONS ---
    localparam int POS_X = 30;        
    localparam int LINE_HEIGHT = 20; 
    
    localparam int LEVEL_Y  = 40;                
    localparam int TARGET_Y = LEVEL_Y + LINE_HEIGHT; 
    localparam int SCORE_Y  = TARGET_Y + LINE_HEIGHT; 
	 
	 // zero base all are in len+1
	 localparam int SCORE_STR_LEN = 10; 
	 localparam int TARGET_STR_LEN = 10;
	 localparam int LEVEL_STR_LEN = 8;
	 localparam int TIMER_STR_LEN = 8;
	 
	 localparam int HEX_SIZE = 8;
	 
	 
    // BCD Signals (4 bits per digit)
    logic [3:0] sc_tho, sc_hun, sc_ten, sc_uni;
    logic [3:0] tr_tho, tr_hun, tr_ten, tr_uni;

     // Instance for the Target BCD conversion
	 bin_to_bcd target_converter (
	 	 .binary_in(target),      // Connect your 14-bit target input
	 	 .thousands(tr_tho),      // Output thousands digit
	 	 .hundreds(tr_hun),       // Output hundreds digit
	 	 .tens(tr_ten),           // Output tens digit
	 	 .units(tr_uni)           // Output units digit
	 );

	 // Instance for the Score BCD conversion
	 bin_to_bcd score_converter (
	 	 .binary_in(score),       // Connect your 14-bit score input
	 	 .thousands(sc_tho),      // Output thousands digit
	 	 .hundreds(sc_hun),       // Output hundreds digit
	 	 .tens(sc_ten),           // Output tens digit
	 	 .units(sc_uni)           // Output units digit
	 );


 
    logic [10:0] diffX;
	 logic [10:0] diffX_Timer;
    logic [10:0] diffY_Level;
    logic [10:0] diffY_Target;
    logic [10:0] diffY_Score;
	 logic [10:0] diffY_Timer;
    
    assign diffX = pixelX - POS_X;
	 assign diffX_Timer = pixelX - TIMER_LABEL_X;
    assign diffY_Level = pixelY - LEVEL_Y;
    assign diffY_Target = pixelY - TARGET_Y;
    assign diffY_Score = pixelY - SCORE_Y;
	 assign diffY_Timer = pixelY - TIMER_LABEL_Y;
	 
	 // char_name_t is the enum
	 char_name_t level_string [0:LEVEL_STR_LEN];   // Array for "LEVEL:  X"
	 char_name_t score_string [0:SCORE_STR_LEN];  // Array for "SCORE: XXXX"
	 char_name_t target_string [0:TARGET_STR_LEN]; // Array for "TARGET:XXXX"
	 
	 char_name_t timer_string [0:TIMER_STR_LEN]; // Array for "TIMER: XX"
	 
	 // Logic to pick the character
	 logic [3:0] char_index;

    always_comb begin
		  // default empty val - important to remove a ff
        char_code = CHAR_NULL;
        row_idx = 3'd0;
		  col_idx = 3'd0;
		  char_index = 4'd0;
		  
		  level_string = '{CHAR_L, CHAR_E, CHAR_V, CHAR_E, CHAR_L, CHAR_COLON, CHAR_NULL, CHAR_NULL, 
						//converstaion_math
						char_name_t'(level_num + CHAR_0)};
		  score_string = '{CHAR_S, CHAR_C, CHAR_O, CHAR_R, CHAR_E, CHAR_COLON, CHAR_NULL, 
								//converstaion_math
                        char_name_t'(sc_tho + CHAR_0), char_name_t'(sc_hun + CHAR_0), 
                        char_name_t'(sc_ten + CHAR_0), char_name_t'(sc_uni + CHAR_0)};
		  target_string = '{CHAR_T, CHAR_A, CHAR_R, CHAR_G, CHAR_E, CHAR_T, CHAR_COLON, 
								//converstaion_math
                        char_name_t'(tr_tho + CHAR_0), char_name_t'(tr_hun + CHAR_0), 
                        char_name_t'(tr_ten + CHAR_0), char_name_t'(tr_uni + CHAR_0)};
		  timer_string = '{CHAR_T, CHAR_I, CHAR_M, CHAR_E, CHAR_R, CHAR_COLON, CHAR_NULL,
								//converstaion_math
                        char_name_t'(tens_timer + CHAR_0), char_name_t'(units_timer + CHAR_0)};
			
			
        // --- PART 1: LEFT SIDE SCOREBOARD ---
		  // Check if we are inside the X-range for the left scoreboard first
		  // the len should be the max
		  if (pixelX >= POS_X && pixelX < POS_X + (SCORE_STR_LEN + 1) * HEX_SIZE) begin
			  col_idx = diffX[2:0];
			  char_index = diffX[6:3]; // Same as diffX / 8
			  if (pixelY >= LEVEL_Y && pixelY < LEVEL_Y + HEX_SIZE && char_index <= LEVEL_STR_LEN) begin
					row_idx = diffY_Level[2:0]; 
					char_code = level_string[char_index];
			  end
			  
			  
			  else if (pixelY >= TARGET_Y && pixelY < TARGET_Y + HEX_SIZE && char_index <= TARGET_STR_LEN) begin
					row_idx = diffY_Target[2:0]; 
					char_code = target_string[char_index];
			  end

			  
			  else if (pixelY >= SCORE_Y && pixelY < SCORE_Y + HEX_SIZE && char_index <= SCORE_STR_LEN) begin
					row_idx = diffY_Score[2:0]; 
					char_code = score_string[char_index];
				end
        end

         // --- PART 2: TIMER ---
        // Independent IF statement (NOT else if).
        // This solves the visibility issue if TIMER_LABEL_Y equals LEVEL_Y.
		  if (pixelX >= TIMER_LABEL_X && pixelX < TIMER_LABEL_X + (TIMER_STR_LEN + 1) * HEX_SIZE) begin
			  if (pixelY >= TIMER_LABEL_Y && pixelY < TIMER_LABEL_Y + HEX_SIZE) begin
					// Only draw if we are in the specific X range of the TIMER text
					char_index = diffX_Timer[6:3];
					if (char_index <= TIMER_STR_LEN) begin
						 row_idx = diffY_Timer[2:0];
						 col_idx = diffX_Timer[2:0];
						 char_code = timer_string[char_index];
					end
				end
        end

    end
    
assign scoreboardRGB = 8'h00; 

endmodule