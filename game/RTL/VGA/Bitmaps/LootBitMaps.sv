module	LootBitMaps(	
					input		logic	clk,
					input		logic	resetN,
					input 	logic [2:0] loot_type,
					input 	logic	[10:0] offsetX,// offset from top left  position 
					input 	logic	[10:0] offsetY,
					input		logic	InsideRectangle, //input that the pixel is within a bracket 
					
					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0]	RGBout
);

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF; 

parameter int TILE_NUMBER_OF_X_BITS = 5; 
parameter int TILE_NUMBER_OF_Y_BITS = 5; 

localparam int TILE_WIDTH_X = 1 << TILE_NUMBER_OF_X_BITS;
localparam int TILE_HEIGHT_Y = 1 << TILE_NUMBER_OF_Y_BITS;


logic [1:0] [0:(TILE_HEIGHT_Y-1)][0:(TILE_WIDTH_X-1)] [7:0] loot_colors = {
    // --- Index 0: GOLD ---
	 {
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h01,8'h2D,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h25,8'h6D,8'h2D,8'h2D,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h25,8'h72,8'h96,8'h6D,8'hB6,8'h2D,8'h00,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h05,8'h2D,8'h92,8'h96,8'h96,8'h6D,8'hB6,8'hB6,8'h2D,8'h05,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h2D,8'h6D,8'h96,8'h96,8'hB6,8'hBA,8'h6D,8'hB6,8'hB6,8'hB6,8'h72,8'h25,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h00,8'h2D,8'h2D,8'h71,8'h6D,8'h2D,8'h2D,8'h72,8'hB6,8'h6D,8'hB6,8'hB6,8'hB6,8'h92,8'h25,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h2D,8'h2D,8'h6D,8'h71,8'h91,8'h71,8'h96,8'h96,8'h96,8'h92,8'h2D,8'h2D,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'h72,8'h25,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h2D,8'h6D,8'h71,8'h71,8'h71,8'h92,8'h96,8'h96,8'h96,8'h96,8'h2D,8'h6D,8'h2D,8'h96,8'hB6,8'hB6,8'hB6,8'hB6,8'h2D,8'h2D,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h2D,8'h2D,8'h71,8'h92,8'h96,8'h96,8'h96,8'h96,8'h96,8'h2D,8'h71,8'h91,8'h91,8'h2D,8'hB6,8'hB6,8'hB6,8'h92,8'h6D,8'h2D,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h2D,8'hB6,8'h2D,8'h92,8'h96,8'h96,8'h96,8'h92,8'h2D,8'h71,8'h91,8'h91,8'h91,8'h6D,8'h92,8'hB6,8'hB6,8'h2D,8'h91,8'h2D,8'h00,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h00,8'h72,8'h2D,8'hBA,8'h2D,8'h92,8'h96,8'h72,8'h2D,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h2D,8'hB6,8'h96,8'h6D,8'h91,8'h6D,8'h00,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h25,8'h92,8'h71,8'hB6,8'hBA,8'h2D,8'h6D,8'h2D,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h6D,8'h92,8'h2D,8'h91,8'h91,8'h91,8'h25,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h25,8'h92,8'h6D,8'hBA,8'hBA,8'hBA,8'h2D,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h2D,8'h6D,8'h91,8'h91,8'h91,8'h2D,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h25,8'h71,8'h91,8'hBA,8'hBA,8'hBA,8'h2D,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h71,8'h2D,8'h2D,8'h2D,8'h6D,8'h91,8'h91,8'h2D,8'hBA,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h25,8'h6D,8'h92,8'hBA,8'hBA,8'hB6,8'h2D,8'h91,8'h91,8'h91,8'h91,8'h91,8'h6D,8'h2D,8'h72,8'h96,8'h96,8'h2D,8'h6D,8'h2D,8'h6D,8'h6D,8'h00,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h2D,8'h2D,8'h96,8'hBA,8'hBA,8'hB6,8'h6D,8'h91,8'h91,8'h71,8'h2D,8'h2D,8'h92,8'h96,8'h96,8'h96,8'h96,8'h2D,8'h6D,8'h6D,8'h2D,8'h2D,8'h25,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h6D,8'h92,8'hB6,8'hBA,8'hBA,8'h96,8'h6D,8'h71,8'h2D,8'h6D,8'h92,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h92,8'h2D,8'h6D,8'h6D,8'h6D,8'h2D,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'h01,8'h72,8'h96,8'hB6,8'hBA,8'hBA,8'h72,8'h2D,8'h72,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h2D,8'h6D,8'h6D,8'h6D,8'h01,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'h25,8'h92,8'h96,8'hB6,8'h72,8'h2D,8'h96,8'h2D,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h6D,8'h6D,8'h6D,8'h2D,8'h00,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'h25,8'h92,8'h6D,8'h2D,8'h96,8'hB6,8'hB6,8'hB6,8'h2D,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h2D,8'h6D,8'h2D,8'h00,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'h2D,8'h2D,8'h91,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'h96,8'h2D,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h2D,8'h6D,8'h2D,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'h2D,8'h92,8'h92,8'h92,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'h72,8'h2D,8'h92,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h96,8'h71,8'h6D,8'h2D,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'h05,8'h71,8'h92,8'h92,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'h96,8'h2D,8'h6D,8'h2D,8'h2D,8'h2D,8'h92,8'h96,8'h96,8'h96,8'h96,8'h96,8'h2D,8'h2D,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h2D,8'h92,8'h92,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'h96,8'h6D,8'h91,8'h91,8'h91,8'h71,8'h6D,8'h2D,8'h2D,8'h2D,8'h72,8'h96,8'h2D,8'h2D,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h25,8'h92,8'h92,8'h96,8'hB6,8'hB6,8'hB6,8'hB6,8'h92,8'h6D,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h71,8'h6D,8'h2D,8'h2D,8'h2D,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h25,8'h91,8'h92,8'h92,8'hB6,8'hB6,8'hB6,8'hB6,8'h92,8'h6D,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h2D,8'h96,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h00,8'h71,8'h92,8'h92,8'hB6,8'hB6,8'hB6,8'hB6,8'h92,8'h71,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h6D,8'h25,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h2D,8'h91,8'h71,8'h71,8'h6D,8'h2D,8'h2D,8'h2D,8'h2D,8'h2D,8'h71,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h2D,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h2D,8'h2D,8'h2D,8'h2D,8'h6D,8'h6D,8'h6D,8'h6D,8'h6D,8'h6D,8'h2D,8'h2D,8'h2D,8'h71,8'h91,8'h91,8'h91,8'h2D,8'h00,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h2D,8'h2D,8'h2D,8'h6D,8'h6D,8'h6D,8'h6D,8'h6D,8'h6D,8'h6D,8'h6D,8'h2D,8'h2D,8'h2D,8'h6D,8'h25,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h2D,8'h2D,8'h2D,8'h2D,8'h2D,8'h2D,8'h2D,8'h2D,8'h2D,8'h2D,8'h2D,8'h2D,8'h25,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h2D,8'h25,8'h2D,8'h92,8'h96,8'hDA,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF}
    },

    // --- Index 1: STONE ---
	 {
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hF9,8'hD5,8'hF5,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hF9,8'hFE,8'hF9,8'hD5,8'hD5,8'hF5,8'hFD,8'hFE,8'hFD,8'hFD,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hF9,8'hF4,8'hFE,8'hF9,8'hF9,8'hF5,8'hD0,8'hF9,8'hFD,8'hFE,8'hFE,8'hFD,8'hF9,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hF9,8'hF9,8'hF4,8'hFD,8'hFD,8'hFD,8'hFD,8'hF5,8'hF4,8'hF9,8'hF9,8'hFE,8'hF9,8'hFD,8'hF5,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hF4,8'hF4,8'hFE,8'hFE,8'hFD,8'hFD,8'hFE,8'hFE,8'hF9,8'hD5,8'hD0,8'hF4,8'hF9,8'hF9,8'hF9,8'hB1,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hF9,8'hF4,8'hFE,8'hFE,8'hFE,8'hFD,8'hFD,8'hFE,8'hF9,8'hD5,8'hD5,8'hB0,8'hB1,8'hD5,8'hF9,8'hF9,8'hB1,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFD,8'hFE,8'hF9,8'hF8,8'hFD,8'hFD,8'hFD,8'hFE,8'hFD,8'hF9,8'hD5,8'hD5,8'hD5,8'hF9,8'hB1,8'hD1,8'hD5,8'hF9,8'hD5,8'hB1,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFE,8'hFE,8'hFE,8'hF4,8'hFD,8'hF9,8'hFE,8'hFD,8'hFD,8'hFD,8'hD5,8'hD5,8'hD5,8'hF9,8'hFD,8'hF9,8'hF9,8'hF4,8'hF5,8'hD5,8'hB1,8'hD0,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hF4,8'hFD,8'hF9,8'hFE,8'hFE,8'hFD,8'hFE,8'hD4,8'hF4,8'hF4,8'hFD,8'hF9,8'hD5,8'hF9,8'hFD,8'hFD,8'hFE,8'hF9,8'hF9,8'hF5,8'hD0,8'hB1,8'hD0,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hF0,8'hF4,8'hF0,8'hFD,8'hFE,8'hFD,8'hFE,8'hD9,8'hD5,8'hF4,8'hF4,8'hF8,8'hFD,8'hD5,8'hF9,8'hF9,8'hFD,8'hFD,8'hF9,8'hF9,8'hF9,8'hB1,8'hD0,8'hD5,8'hD5,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hF4,8'hF8,8'hF4,8'hF8,8'hFD,8'hFD,8'hFD,8'hD9,8'hD9,8'hF8,8'hF8,8'hF4,8'hF4,8'hFD,8'hF9,8'hF9,8'hF5,8'hD5,8'hD5,8'hD5,8'hD5,8'hD5,8'hB1,8'hD5,8'h8C,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hF8,8'hF4,8'hF4,8'hF4,8'hF8,8'hFD,8'hFD,8'hD0,8'hD0,8'hD5,8'hD4,8'hF0,8'hD0,8'hAC,8'h84,8'hCC,8'hF9,8'hF9,8'hF9,8'hF9,8'hD5,8'hD5,8'hD4,8'hB1,8'hB0,8'h8C,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hF9,8'hF0,8'hF4,8'hF4,8'hF4,8'hFC,8'hD0,8'hAC,8'hAC,8'hB0,8'hD5,8'hD0,8'hCC,8'hAC,8'hD0,8'hF4,8'hF9,8'hD5,8'hD4,8'hD4,8'hD4,8'hD4,8'hB0,8'hB1,8'hB1,8'hB1,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hF8,8'hD0,8'hCC,8'hF0,8'hF0,8'hFC,8'hB0,8'hB0,8'hB0,8'hAC,8'hAC,8'hD4,8'hAC,8'hD0,8'hF8,8'hFD,8'hD0,8'hAC,8'hB0,8'hB0,8'hD0,8'hB0,8'hAC,8'hAC,8'hB0,8'hD6,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hD0,8'hAC,8'hAC,8'hF0,8'hF4,8'hFD,8'hD4,8'hD0,8'hD0,8'hD4,8'hF4,8'hF8,8'hFD,8'hFD,8'hF8,8'hFC,8'hB0,8'hB0,8'hB0,8'hAC,8'hAC,8'h8C,8'h8C,8'h8C,8'hB0,8'hD5,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hD0,8'hAC,8'hAC,8'hD0,8'hF4,8'hF4,8'hF9,8'hD5,8'hF5,8'hF9,8'hFD,8'hFC,8'hFD,8'hFD,8'hFD,8'hF4,8'hD5,8'hD5,8'hD0,8'hB0,8'h8C,8'h8C,8'h8C,8'hAC,8'hB1,8'hD5,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hAC,8'hD0,8'hD0,8'hAC,8'hCC,8'hAC,8'hAC,8'hF9,8'hF5,8'hF9,8'hFD,8'hFD,8'hD4,8'hD0,8'h8C,8'hAC,8'hD4,8'hD5,8'hD4,8'hAC,8'h8C,8'h8C,8'hAC,8'h8C,8'hB5,8'hB5,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hF0,8'hFC,8'hF4,8'hAC,8'h64,8'h84,8'hA4,8'hD0,8'hAC,8'hF8,8'hD4,8'hF5,8'hB0,8'hD0,8'hD0,8'h84,8'hAC,8'hAC,8'hB1,8'hAC,8'hB0,8'hB1,8'hB5,8'hD5,8'hB1,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hCC,8'hFC,8'hF4,8'hAC,8'hAC,8'hF4,8'hD0,8'hAC,8'hF4,8'hF4,8'hD0,8'hD0,8'hD4,8'hD4,8'hD0,8'hAC,8'h8C,8'hAC,8'hD5,8'hB5,8'hD5,8'hD6,8'hB1,8'h8C,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hF4,8'hF4,8'hAC,8'hAC,8'hAC,8'hAC,8'hAC,8'hAC,8'hAC,8'h84,8'hB0,8'hD0,8'h8C,8'h64,8'h64,8'h64,8'h64,8'hB0,8'hD5,8'hD5,8'hB0,8'h8C,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hAC,8'hD0,8'hD0,8'h8C,8'h64,8'h24,8'h20,8'h64,8'h64,8'h84,8'hAC,8'h8C,8'h8C,8'hB0,8'hAC,8'hAC,8'h8C,8'h84,8'hAC,8'hB0,8'hB0,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h84,8'h84,8'h84,8'h64,8'h64,8'h84,8'h64,8'h84,8'h84,8'h64,8'h64,8'h8C,8'hB0,8'hD0,8'hD0,8'hAC,8'h8C,8'h8C,8'h8C,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h64,8'h64,8'h64,8'h64,8'h84,8'h84,8'hA4,8'h84,8'h64,8'h84,8'hAC,8'hAC,8'hAC,8'h8C,8'h84,8'h8C,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h8D,8'h84,8'hAC,8'hD0,8'hCC,8'hAC,8'h84,8'h84,8'h8C,8'h8C,8'h84,8'h84,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h84,8'hAC,8'hD0,8'hAC,8'h84,8'h64,8'h64,8'h64,8'h64,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h20,8'h24,8'h64,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
        {8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF}
    }
}; 

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		drawingRequest <=	1'b0;
	end
	else begin
		drawingRequest <=	1'b0;
	
		if (InsideRectangle == 1'b1 && loot_type != 0) begin 
			// loot_type == 0 is resevered for nothing
			
			drawingRequest <= loot_colors[loot_type - 1][offsetY][offsetX] != TRANSPARENT_ENCODING;
		   RGBout = loot_colors[loot_type - 1][offsetY][offsetX];
		end
	end 
end

endmodule