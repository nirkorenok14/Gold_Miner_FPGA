module	loot_matrix(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket 
					input logic loot_collision,
					input logic start_level,
					input logic [2:0] level_num,
					input logic start_of_frame,
					
					output	logic [2:0] loot_type,
					// loot offset
					output	logic	[10:0] offsetX_LSB,
					output	logic	[10:0] offsetY_LSB,
					output 	logic [7:0] total_amount
 ) ;

localparam  int MAZE_NUMBER_OF__X_BITS = 4;  // 2^4 = 16 / /the maze of the objects 
localparam  int MAZE_NUMBER_OF__Y_BITS = 3;  // 2^3 = 8 

//-----
localparam  int MAZE_WIDTH_X = 1 << MAZE_NUMBER_OF__X_BITS ;
localparam  int MAZE_HEIGHT_Y = 1 << MAZE_NUMBER_OF__Y_BITS ;
localparam	[2:0] LOOT_AMOUNT_SIZE = 6;
localparam	[2:0] LOOT_TYPE_SIZE = 3;

parameter [2:0] TOTAL_LOOT_TYPES = 3'd3;

localparam logic [2:0] AMOUNT_FIELD_SIZE = 3'd6;
parameter [(AMOUNT_FIELD_SIZE-1):0] INIT_GOLD_AMOUNT = 32;
parameter [(AMOUNT_FIELD_SIZE-1):0] INIT_ROCK_AMOUNT = 32;


 logic [10:0] offsetX_MSB ;
 logic [10:0] offsetY_MSB  ;
 parameter int TILE_NUMBER_OF_X_BITS = 5; 
 parameter int TILE_NUMBER_OF_Y_BITS = 5; 

 assign offsetX_LSB  = offsetX[(TILE_NUMBER_OF_X_BITS-1):0] ; // get lower bits 
 assign offsetY_LSB  = offsetY[(TILE_NUMBER_OF_Y_BITS-1):0] ; // get lower bits 
 assign offsetX_MSB  = offsetX[(TILE_NUMBER_OF_X_BITS + MAZE_NUMBER_OF__X_BITS -1 ):TILE_NUMBER_OF_X_BITS] ; // get higher bits 
 assign offsetY_MSB  = offsetY[(TILE_NUMBER_OF_Y_BITS + MAZE_NUMBER_OF__Y_BITS -1 ):TILE_NUMBER_OF_Y_BITS] ; // get higher bits 
 
logic [(MAZE_WIDTH_X-1):0] random_seed;
// default params are 8
random  #(.SIZE_BITS(MAZE_WIDTH_X)) random1(.clk(clk), .resetN(resetN), .rise(start_level), .dout(random_seed));
 
// the screen is 640*480  or  20 * 15 squares of 32*32  bits ,  we will round up to 8 *16 
// this is the bitmap  of the maze , if there is a specific value  the  whole 32*32 rectanlge will be drawn on the screen
// there are  16 options of differents kinds of 32*32 squares  


logic [0:(MAZE_HEIGHT_Y-1)][0:(MAZE_WIDTH_X-1)] [(LOOT_TYPE_SIZE-1):0]  MazeBitMapMask ;  

assign total_amount = loot_amounts[1] + loot_amounts[2];
logic [8:0] total_amount_countr;
assign total_amount_countr = loot_amounts_counter[1] + loot_amounts_counter[2];

//
// randomize a map and find a loot in it

logic [3:0] col_ptr, row_ptr; // which place in col or row vectors - col[col_ptr] or row[row_prt]
// needed for the LCG pseudo random, both needs to be prime numbers, the multiplyer should be larger
localparam [(MAZE_WIDTH_X-1):0] mult_prime = 8'd13;
localparam [(MAZE_WIDTH_X-1):0] inc_prime = 8'd7;
logic [(MAZE_WIDTH_X-1):0] random_row;
logic [(LOOT_TYPE_SIZE-1):0] loot_type_tmp;
logic is_fill_missing;
logic is_collision;

logic [(LOOT_AMOUNT_SIZE-1):0] loot_amounts [0:(TOTAL_LOOT_TYPES-1)];

always_comb begin
    loot_amounts[0] = 0; //defualt don't have amount, deduced by other
    loot_amounts[1] = INIT_GOLD_AMOUNT >> shift;
    loot_amounts[2] = INIT_ROCK_AMOUNT << shift;
end


logic [2:0] shift;
assign shift = (level_num != 0) ? level_num - 1 : 3'd0;

logic [(LOOT_AMOUNT_SIZE-1):0] loot_amounts_counter [0:(TOTAL_LOOT_TYPES-1)];


enum logic [2:0] {IDLE_ST, START_LEVEL_ST, MAP_GEN_ST, NEXT_COL_ST, FILL_MISSING_ST, LEVEL_ST} loot_SM;


logic [10:0] x_history [0:2]; // Array to hold 3 cycles of history
logic [10:0] y_history [0:2];

always_ff@(posedge clk or negedge resetN) begin
	if(!resetN) begin
		loot_type <= 0;
		MazeBitMapMask  <=  '{default:0} ;  //  clear map
		loot_SM <= IDLE_ST;
		random_row <= random_seed;
		loot_amounts_counter  <=  loot_amounts;
		loot_type_tmp <= 3'd1;
		col_ptr <= MAZE_HEIGHT_Y-1;
	   row_ptr <= MAZE_WIDTH_X-1;
		is_fill_missing <= 0;
		is_collision <= 0;
	end
	else begin
		x_history[0] <= offsetX_MSB; // Current
		x_history[1] <= x_history[0]; // 1 clock ago
		x_history[2] <= x_history[1]; // 2 clocks ago

		y_history[0] <= offsetY_MSB;
		y_history[1] <= y_history[0];
		y_history[2] <= y_history[1];
		case (loot_SM)
		
			IDLE_ST: begin
				if (start_level)
					loot_SM <= START_LEVEL_ST;
			end
		
			START_LEVEL_ST: begin
				loot_type <= 0;
				MazeBitMapMask  <=  '{default:0} ;
				random_row <= random_seed;
				loot_amounts_counter <= loot_amounts;
				loot_type_tmp <= 3'd1;
				loot_SM <= MAP_GEN_ST;
				col_ptr <= MAZE_HEIGHT_Y-1; //start at the bottom-right
				row_ptr <= MAZE_WIDTH_X-1;
				is_fill_missing <= 0;
				is_collision <= 0;
			end
			

			// this fsm should be faster than a humen can see somthing
			// create a map of possible random loot locations
			// starts from the bottom so the gold would be on the bottom (harder as the level goes)
			MAP_GEN_ST: begin
				if (total_amount_countr == 0)
					loot_SM <= LEVEL_ST;
				// find the next possible loot and fill it
				else begin
					if (!random_row[row_ptr]) begin
						if (loot_amounts_counter[loot_type_tmp] > 0) begin
							MazeBitMapMask[col_ptr][row_ptr] <= loot_type_tmp;
							loot_amounts_counter[loot_type_tmp] <= loot_amounts_counter[loot_type_tmp] - 1;
						end
						// Move to next treasure type if this one is empty
						loot_type_tmp <= (loot_type_tmp == TOTAL_LOOT_TYPES - 1) ? 3'd1 : loot_type_tmp + 3'd1; // first none default loot type
						loot_SM <= MAP_GEN_ST;
					end
					if (row_ptr == 0) begin
						 row_ptr <=  MAZE_WIDTH_X - 1;
						 loot_SM <= (!is_fill_missing) ? NEXT_COL_ST : FILL_MISSING_ST;
					end 
					else
						 row_ptr <= row_ptr - 1;
				end		 
			end
			
			// calc next col
			NEXT_COL_ST: begin
				// all the loot is in, skip to next level
				if (total_amount_countr == 0)
					loot_SM <= LEVEL_ST;
				else if (col_ptr ==  0) begin 
					 loot_SM <= FILL_MISSING_ST;
					 row_ptr <=  MAZE_WIDTH_X - 1; //next_row_st need to start from the end
				end
				else begin
					 col_ptr <= col_ptr - 1;
					 // Scramble for the next column
					 random_row <= (random_row * mult_prime) + inc_prime; 
					 loot_SM <= MAP_GEN_ST;
				end
			end
			
			// less likely to happen, but there is a chance where not all the loot found a location
			// that case just fill where it is empty (doesn't really matter where it beggins)
			// make sure the init amount are less than the total possible locations!!!
			FILL_MISSING_ST: begin
				// col is starting from zero, row from the end
				is_fill_missing <= 1;
				if (total_amount_countr == 0)
					loot_SM <= LEVEL_ST;
				// the oppsite for where there is loot in that row
				else begin
					logic [MAZE_WIDTH_X-1:0] next_row_mask;
					for (int tmp_row = 0; tmp_row < MAZE_WIDTH_X; tmp_row ++)
						next_row_mask[tmp_row] = ~(|MazeBitMapMask[col_ptr][tmp_row]);
					random_row <= next_row_mask;
					col_ptr <= col_ptr + 1;
					// fail safe if amounts are higher than the map
					if (col_ptr == MAZE_HEIGHT_Y-1)
						loot_SM <= LEVEL_ST;
					else 
						loot_SM <= MAP_GEN_ST;
				end
			end
		
			LEVEL_ST: begin
				// collision is only up for one clk, but it happens one clk after the hit itself, so two clks after it was here
				if (loot_collision) begin
					MazeBitMapMask[y_history[2]][x_history[2]] <= 3'd0;  // clear entry 
//					is_collision <= 1;
				end
//				if (start_of_frame)
//					is_collision <= 0;
				
				if (InsideRectangle == 1'b1)
					loot_type <= MazeBitMapMask[offsetY_MSB][offsetX_MSB];
				if (start_level)
					loot_SM <= START_LEVEL_ST;
			end

		endcase
	end
end 


endmodule

