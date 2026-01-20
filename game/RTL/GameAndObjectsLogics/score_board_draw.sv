module score_board_draw (
    input  logic        clk,
    input  logic        resetN,
    input  logic [10:0] pixelX,
    input  logic [10:0] pixelY,
    
    input  logic    [13:0]      level,  
    input  logic      [13:0]        score,  
    input  logic      [13:0]        target, 
    
    output logic        drawing_request_scoreboard, 
    output logic [7:0]  scoreboardRGB
);

    localparam int POS_X = 30;        
    localparam int LINE_HEIGHT = 20; 
    
    localparam int LEVEL_Y  = 40;                
    localparam int TARGET_Y = LEVEL_Y + LINE_HEIGHT; 
    localparam int SCORE_Y  = TARGET_Y + LINE_HEIGHT; 

    logic [3:0] sc_tho, sc_hun, sc_ten, sc_uni;
    logic [3:0] tr_tho, tr_hun, tr_ten, tr_uni;
    logic [3:0] lv_ten, lv_uni;

    
    assign lv_ten = (level / 10) % 10;
    assign lv_uni = level % 10;

    assign tr_tho = (target / 1000) % 10;
    assign tr_hun = (target / 100) % 10;
    assign tr_ten = (target / 10) % 10;
    assign tr_uni = target % 10;

    assign sc_tho = (score / 1000) % 10;
    assign sc_hun = (score / 100) % 10;
    assign sc_ten = (score / 10) % 10;
    assign sc_uni = score % 10;

   
    function [7:0] get_char_row(input [4:0] char_code, input [2:0] row_idx);
        case (char_code)
            5'h00: begin /* S */ case(row_idx) 0:return 8'h3C; 1:return 8'h60; 2:return 8'h60; 3:return 8'h3C; 4:return 8'h06; 5:return 8'h06; 6:return 8'h3C; default:return 0; endcase end
            5'h01: begin /* C */ case(row_idx) 0:return 8'h3C; 1:return 8'h66; 2:return 8'h60; 3:return 8'h60; 4:return 8'h60; 5:return 8'h66; 6:return 8'h3C; default:return 0; endcase end
            5'h02: begin /* O */ case(row_idx) 0:return 8'h3C; 1:return 8'h66; 2:return 8'h66; 3:return 8'h66; 4:return 8'h66; 5:return 8'h66; 6:return 8'h3C; default:return 0; endcase end
            5'h03: begin /* R */ case(row_idx) 0:return 8'h7C; 1:return 8'h66; 2:return 8'h66; 3:return 8'h7C; 4:return 8'h78; 5:return 8'h6C; 6:return 8'h66; default:return 0; endcase end
            5'h04: begin /* E */ case(row_idx) 0:return 8'h7E; 1:return 8'h60; 2:return 8'h60; 3:return 8'h7C; 4:return 8'h60; 5:return 8'h60; 6:return 8'h7E; default:return 0; endcase end
            5'h05: begin /* : */ case(row_idx) 0:return 8'h00; 1:return 8'h18; 2:return 8'h18; 3:return 8'h00; 4:return 8'h18; 5:return 8'h18; 6:return 8'h00; default:return 0; endcase end
            5'h06: begin /* T */ case(row_idx) 0:return 8'h7E; 1:return 8'h18; 2:return 8'h18; 3:return 8'h18; 4:return 8'h18; 5:return 8'h18; 6:return 8'h18; default:return 0; endcase end
            5'h07: begin /* A */ case(row_idx) 0:return 8'h3C; 1:return 8'h66; 2:return 8'h66; 3:return 8'h7E; 4:return 8'h66; 5:return 8'h66; 6:return 8'h66; default:return 0; endcase end
            5'h08: begin /* G */ case(row_idx) 0:return 8'h3C; 1:return 8'h66; 2:return 8'h60; 3:return 8'h6E; 4:return 8'h66; 5:return 8'h66; 6:return 8'h3C; default:return 0; endcase end
            5'h09: begin /* L */ case(row_idx) 0:return 8'h60; 1:return 8'h60; 2:return 8'h60; 3:return 8'h60; 4:return 8'h60; 5:return 8'h60; 6:return 8'h7E; default:return 0; endcase end
            5'h14: begin /* V */ case(row_idx) 0:return 8'h66; 1:return 8'h66; 2:return 8'h66; 3:return 8'h66; 4:return 8'h66; 5:return 8'h3C; 6:return 8'h18; default:return 0; endcase end
            
            
            5'h0A: begin /* 0 */ case(row_idx) 0:return 8'h3C; 1:return 8'h66; 2:return 8'h66; 3:return 8'h66; 4:return 8'h66; 5:return 8'h66; 6:return 8'h3C; default:return 0; endcase end
            5'h0B: begin /* 1 */ case(row_idx) 0:return 8'h18; 1:return 8'h38; 2:return 8'h18; 3:return 8'h18; 4:return 8'h18; 5:return 8'h18; 6:return 8'h3C; default:return 0; endcase end
            5'h0C: begin /* 2 */ case(row_idx) 0:return 8'h3C; 1:return 8'h66; 2:return 8'h0C; 3:return 8'h18; 4:return 8'h30; 5:return 8'h60; 6:return 8'h7E; default:return 0; endcase end
            5'h0D: begin /* 3 */ case(row_idx) 0:return 8'h3C; 1:return 8'h66; 2:return 8'h0C; 3:return 8'h1C; 4:return 8'h0C; 5:return 8'h66; 6:return 8'h3C; default:return 0; endcase end
            5'h0E: begin /* 4 */ case(row_idx) 0:return 8'h0C; 1:return 8'h1C; 2:return 8'h3C; 3:return 8'h6C; 4:return 8'h7E; 5:return 8'h0C; 6:return 8'h0C; default:return 0; endcase end
            5'h0F: begin /* 5 */ case(row_idx) 0:return 8'h7E; 1:return 8'h60; 2:return 8'h7C; 3:return 8'h06; 4:return 8'h06; 5:return 8'h66; 6:return 8'h3C; default:return 0; endcase end
            5'h10: begin /* 6 */ case(row_idx) 0:return 8'h3C; 1:return 8'h66; 2:return 8'h60; 3:return 8'h7C; 4:return 8'h66; 5:return 8'h66; 6:return 8'h3C; default:return 0; endcase end
            5'h11: begin /* 7 */ case(row_idx) 0:return 8'h7E; 1:return 8'h06; 2:return 8'h0C; 3:return 8'h18; 4:return 8'h30; 5:return 8'h30; 6:return 8'h30; default:return 0; endcase end
            5'h12: begin /* 8 */ case(row_idx) 0:return 8'h3C; 1:return 8'h66; 2:return 8'h66; 3:return 8'h3C; 4:return 8'h66; 5:return 8'h66; 6:return 8'h3C; default:return 0; endcase end
            5'h13: begin /* 9 */ case(row_idx) 0:return 8'h3C; 1:return 8'h66; 2:return 8'h66; 3:return 8'h3E; 4:return 8'h06; 5:return 8'h66; 6:return 8'h3C; default:return 0; endcase end
            
            default: return 8'h00;
        endcase
    endfunction

    logic [4:0] char_to_draw;
    logic [2:0] row_in_char;
    logic [2:0] col_in_char;
    logic [7:0] pixel_row;
    logic       pixel_on;
 
 
    logic [10:0] diffX;
    logic [10:0] diffY_Level;
    logic [10:0] diffY_Target;
    logic [10:0] diffY_Score;
    
    assign diffX = pixelX - POS_X;
    assign diffY_Level = pixelY - LEVEL_Y;
    assign diffY_Target = pixelY - TARGET_Y;
    assign diffY_Score = pixelY - SCORE_Y;

    always_comb begin
       
        pixel_on = 1'b0;
        char_to_draw = 5'h1F;
        
        
        col_in_char = diffX[2:0]; 
        row_in_char = 3'b000;
        
        pixel_row = 8'h00;

        
        if (pixelY >= LEVEL_Y && pixelY < LEVEL_Y + 8) begin
            row_in_char = diffY_Level[2:0]; 
            
            if      (pixelX >= POS_X    && pixelX < POS_X+8)  char_to_draw = 5'h09; // L
            else if (pixelX >= POS_X+8  && pixelX < POS_X+16) char_to_draw = 5'h04; // E
            else if (pixelX >= POS_X+16 && pixelX < POS_X+24) char_to_draw = 5'h14; // V
            else if (pixelX >= POS_X+24 && pixelX < POS_X+32) char_to_draw = 5'h04; // E
            else if (pixelX >= POS_X+32 && pixelX < POS_X+40) char_to_draw = 5'h09; // L
            else if (pixelX >= POS_X+40 && pixelX < POS_X+48) char_to_draw = 5'h05; // :
            else if (pixelX >= POS_X+56 && pixelX < POS_X+64) begin
                 if(level >= 10) char_to_draw = {1'b0, lv_ten} + 5'h0A; else char_to_draw = 5'h1F; 
            end
            else if (pixelX >= POS_X+64 && pixelX < POS_X+72) char_to_draw = {1'b0, lv_uni} + 5'h0A; 
        end
        
        
        else if (pixelY >= TARGET_Y && pixelY < TARGET_Y + 8) begin
            row_in_char = diffY_Target[2:0]; 
            
            if      (pixelX >= POS_X    && pixelX < POS_X+8)  char_to_draw = 5'h06; // T
            else if (pixelX >= POS_X+8  && pixelX < POS_X+16) char_to_draw = 5'h07; // A
            else if (pixelX >= POS_X+16 && pixelX < POS_X+24) char_to_draw = 5'h03; // R
            else if (pixelX >= POS_X+24 && pixelX < POS_X+32) char_to_draw = 5'h08; // G
            else if (pixelX >= POS_X+32 && pixelX < POS_X+40) char_to_draw = 5'h04; // E
            else if (pixelX >= POS_X+40 && pixelX < POS_X+48) char_to_draw = 5'h06; // T
            else if (pixelX >= POS_X+48 && pixelX < POS_X+56) char_to_draw = 5'h05; // :
            
            else if (pixelX >= POS_X+56 && pixelX < POS_X+64) char_to_draw = {1'b0, tr_tho} + 5'h0A;
            else if (pixelX >= POS_X+64 && pixelX < POS_X+72) char_to_draw = {1'b0, tr_hun} + 5'h0A;
            else if (pixelX >= POS_X+72 && pixelX < POS_X+80) char_to_draw = {1'b0, tr_ten} + 5'h0A;
            else if (pixelX >= POS_X+80 && pixelX < POS_X+88) char_to_draw = {1'b0, tr_uni} + 5'h0A;
        end

        
        else if (pixelY >= SCORE_Y && pixelY < SCORE_Y + 8) begin
            row_in_char = diffY_Score[2:0]; 
            
            if      (pixelX >= POS_X    && pixelX < POS_X+8)  char_to_draw = 5'h00; // S
            else if (pixelX >= POS_X+8  && pixelX < POS_X+16) char_to_draw = 5'h01; // C
            else if (pixelX >= POS_X+16 && pixelX < POS_X+24) char_to_draw = 5'h02; // O
            else if (pixelX >= POS_X+24 && pixelX < POS_X+32) char_to_draw = 5'h03; // R
            else if (pixelX >= POS_X+32 && pixelX < POS_X+40) char_to_draw = 5'h04; // E
            else if (pixelX >= POS_X+40 && pixelX < POS_X+48) char_to_draw = 5'h05; // :
            
            else if (pixelX >= POS_X+56 && pixelX < POS_X+64) char_to_draw = {1'b0, sc_tho} + 5'h0A;
            else if (pixelX >= POS_X+64 && pixelX < POS_X+72) char_to_draw = {1'b0, sc_hun} + 5'h0A;
            else if (pixelX >= POS_X+72 && pixelX < POS_X+80) char_to_draw = {1'b0, sc_ten} + 5'h0A;
            else if (pixelX >= POS_X+80 && pixelX < POS_X+88) char_to_draw = {1'b0, sc_uni} + 5'h0A;
        end

        if (char_to_draw != 5'h1F) begin
            pixel_row = get_char_row(char_to_draw, row_in_char);
            if (pixel_row[7 - col_in_char] == 1'b1) 
                pixel_on = 1'b1;
        end
    end

    assign drawing_request_scoreboard = pixel_on;
    
    assign scoreboardRGB = 8'h00; 

endmodule