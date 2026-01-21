// At the very top of your file
// holds all the char cases 
import char_enum_pkg::*;


module char_to_color (
    input  logic [6:0] char_code, // Increased to 7 bits to fit all characters
    input  logic [2:0] row_idx,
	 input  logic [2:0] col_idx,
	 
	 output logic char_dr
);

localparam [2:0] HEX_SIZE = 3'd7; // starts from 0 so 8-1=7
logic [7:0] pixel_row;

    // ============================================================
    //  BITMAP FONT LOOKUP - compacted version
    // ============================================================
    always_comb begin
        case (char_code)
            CHAR_0: begin case(row_idx) 0: pixel_row = 8'h3C; 1: pixel_row = 8'h66; 2: pixel_row = 8'h66; 3: pixel_row = 8'h66; 4: pixel_row = 8'h66; 5: pixel_row = 8'h66; 6: pixel_row = 8'h3C; default: pixel_row = 0; endcase end
				CHAR_1: begin case(row_idx) 0: pixel_row = 8'h18; 1: pixel_row = 8'h38; 2: pixel_row = 8'h18; 3: pixel_row = 8'h18; 4: pixel_row = 8'h18; 5: pixel_row = 8'h18; 6: pixel_row = 8'h3C; default: pixel_row = 0; endcase end
				CHAR_2: begin case(row_idx) 0: pixel_row = 8'h3C; 1: pixel_row = 8'h66; 2: pixel_row = 8'h66; 2: pixel_row = 8'h0C; 3: pixel_row = 8'h18; 4: pixel_row = 8'h30; 5: pixel_row = 8'h60; 6: pixel_row = 8'h7E; default: pixel_row = 0; endcase end
				CHAR_3: begin case(row_idx) 0: pixel_row = 8'h3C; 1: pixel_row = 8'h66; 2: pixel_row = 8'h66; 2: pixel_row = 8'h0C; 3: pixel_row = 8'h1C; 4: pixel_row = 8'h0C; 5: pixel_row = 8'h66; 6: pixel_row = 8'h3C; default: pixel_row = 0; endcase end
				CHAR_4: begin case(row_idx) 0: pixel_row = 8'h0C; 1: pixel_row = 8'h1C; 2: pixel_row = 8'h3C; 3: pixel_row = 8'h6C; 4: pixel_row = 8'h7E; 5: pixel_row = 8'h0C; 6: pixel_row = 8'h0C; default: pixel_row = 0; endcase end
				CHAR_5: begin case(row_idx) 0: pixel_row = 8'h7E; 1: pixel_row = 8'h60; 2: pixel_row = 8'h7C; 3: pixel_row = 8'h06; 4: pixel_row = 8'h06; 5: pixel_row = 8'h66; 6: pixel_row = 8'h3C; default: pixel_row = 0; endcase end
				CHAR_6: begin case(row_idx) 0: pixel_row = 8'h3C; 1: pixel_row = 8'h66; 2: pixel_row = 8'h60; 3: pixel_row = 8'h7C; 4: pixel_row = 8'h66; 5: pixel_row = 8'h66; 6: pixel_row = 8'h3C; default: pixel_row = 0; endcase end
				CHAR_7: begin case(row_idx) 0: pixel_row = 8'h7E; 1: pixel_row = 8'h06; 2: pixel_row = 8'h0C; 3: pixel_row = 8'h18; 4: pixel_row = 8'h30; 5: pixel_row = 8'h30; 6: pixel_row = 8'h30; default: pixel_row = 0; endcase end
				CHAR_8: begin case(row_idx) 0: pixel_row = 8'h3C; 1: pixel_row = 8'h66; 2: pixel_row = 8'h66; 3: pixel_row = 8'h3C; 4: pixel_row = 8'h66; 5: pixel_row = 8'h66; 6: pixel_row = 8'h3C; default: pixel_row = 0; endcase end
				CHAR_9: begin case(row_idx) 0: pixel_row = 8'h3C; 1: pixel_row = 8'h66; 2: pixel_row = 8'h66; 3: pixel_row = 8'h3E; 4: pixel_row = 8'h06; 5: pixel_row = 8'h66; 6: pixel_row = 8'h3C; default: pixel_row = 0; endcase end

            // Example Uppercase
            CHAR_A: begin case(row_idx) 0: pixel_row = 8'h3C; 1: pixel_row = 8'h66; 2: pixel_row = 8'h66; 3: pixel_row = 8'h7E; 4: pixel_row = 8'h66; 5: pixel_row = 8'h66; 6: pixel_row = 8'h66; default: pixel_row = 0; endcase end
				//B
				CHAR_C: begin case(row_idx) 0: pixel_row = 8'h3C; 1: pixel_row = 8'h66; 2: pixel_row = 8'h60; 3: pixel_row = 8'h60; 4: pixel_row = 8'h60; 5: pixel_row = 8'h66; 6: pixel_row = 8'h3C; default: pixel_row = 0; endcase end            
				//D
				CHAR_E: begin case(row_idx) 0: pixel_row = 8'h7E; 1: pixel_row = 8'h60; 2: pixel_row = 8'h60; 3: pixel_row = 8'h7C; 4: pixel_row = 8'h60; 5: pixel_row = 8'h60; 6: pixel_row = 8'h7E; default: pixel_row = 0; endcase end
				//F
				CHAR_G: begin case(row_idx) 0: pixel_row = 8'h3C; 1: pixel_row = 8'h66; 2: pixel_row = 8'h60; 3: pixel_row = 8'h6E; 4: pixel_row = 8'h66; 5: pixel_row = 8'h66; 6: pixel_row = 8'h3C; default: pixel_row = 0; endcase end
				//H
				CHAR_I: begin case(row_idx) 0: pixel_row = 8'h3C; 1: pixel_row = 8'h18; 2: pixel_row = 8'h18; 3: pixel_row = 8'h18; 4: pixel_row = 8'h18; 5: pixel_row = 8'h18; 6: pixel_row = 8'h3C; default: pixel_row = 0; endcase end
            //J
				//K
				CHAR_L: begin case(row_idx) 0: pixel_row = 8'h60; 1: pixel_row = 8'h60; 2: pixel_row = 8'h60; 3: pixel_row = 8'h60; 4: pixel_row = 8'h60; 5: pixel_row = 8'h60; 6: pixel_row = 8'h7E; default: pixel_row = 0; endcase end
				CHAR_M: begin case(row_idx) 0: pixel_row = 8'h66; 1: pixel_row = 8'h7E; 2: pixel_row = 8'h5A; 3: pixel_row = 8'h42; 4: pixel_row = 8'h42; 5: pixel_row = 8'h42; 6: pixel_row = 8'h42; default: pixel_row = 0; endcase end
				//N
				CHAR_O: begin case(row_idx) 0: pixel_row = 8'h3C; 1: pixel_row = 8'h66; 2: pixel_row = 8'h66; 3: pixel_row = 8'h66; 4: pixel_row = 8'h66; 5: pixel_row = 8'h66; 6: pixel_row = 8'h3C; default: pixel_row = 0; endcase end
				//P
				//Q
				CHAR_R: begin case(row_idx) 0: pixel_row = 8'h7C; 1: pixel_row = 8'h66; 2: pixel_row = 8'h66; 3: pixel_row = 8'h7C; 4: pixel_row = 8'h78; 5: pixel_row = 8'h6C; 6: pixel_row = 8'h66; default: pixel_row = 0; endcase end
				CHAR_S: begin case(row_idx) 0: pixel_row = 8'h3C; 1: pixel_row = 8'h60; 2: pixel_row = 8'h60; 3: pixel_row = 8'h3C; 4: pixel_row = 8'h06; 5: pixel_row = 8'h06; 6: pixel_row = 8'h3C; default: pixel_row = 0; endcase end
				CHAR_T: begin case(row_idx) 0: pixel_row = 8'h7E; 1: pixel_row = 8'h18; 2: pixel_row = 8'h18; 3: pixel_row = 8'h18; 4: pixel_row = 8'h18; 5: pixel_row = 8'h18; 6: pixel_row = 8'h18; default: pixel_row = 0; endcase end
				CHAR_V: begin case(row_idx) 0: pixel_row = 8'h66; 1: pixel_row = 8'h66; 2: pixel_row = 8'h66; 3: pixel_row = 8'h66; 4: pixel_row = 8'h66; 5: pixel_row = 8'h3C; 6: pixel_row = 8'h18; default: pixel_row = 0; endcase end
				//U
				//W
				//X
				
				// Example Colon
            CHAR_COLON: begin case(row_idx) 0: pixel_row = 8'h00; 1: pixel_row = 8'h18; 2: pixel_row = 8'h18; 3: pixel_row = 8'h00; 4: pixel_row = 8'h18; 5: pixel_row = 8'h18; 6: pixel_row = 8'h00; default: pixel_row = 0; endcase end
            
            // Default to empty
            default:  pixel_row = 8'h00;
        endcase
		  
		  char_dr = 1'b0;
		  if (char_code != CHAR_NULL) begin
            if (pixel_row[HEX_SIZE - col_idx]) 
                char_dr = 1'b1;
        end
    end
endmodule