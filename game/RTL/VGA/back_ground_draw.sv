//-- feb 2021 add all colors square 
// (c) Technion IIT, Department of Electrical Engineering 2025


module back_ground_draw (	
    input	logic	clk,
    input	logic	resetN,
    input 	logic	[10:0]	pixelX,
    input 	logic	[10:0]	pixelY,

    output	logic	[7:0]	BG_RGB,
    output	logic		    boardersDrawReq 
);

    const int	xFrameSize	=	635;
    const int	yFrameSize	=	475;
    const int	bracketOffset =	20; 
    
    logic [2:0] redBits;
    logic [2:0] greenBits;
    logic [1:0] blueBits;

    localparam logic [2:0] DARK_COLOR = 3'b111; 
    
    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            redBits <= DARK_COLOR;	
            greenBits <= DARK_COLOR;	
            blueBits <= DARK_COLOR;	 
        end 
        else begin

            // defaults
            greenBits <= 3'b111; 
            redBits <= 3'b000;
            blueBits <= 2'b11;
            boardersDrawReq <= 1'b0; 
            
            
            if (    
                (pixelX <= bracketOffset) ||
                (pixelY <= bracketOffset) ||
                (pixelX >= (xFrameSize - bracketOffset)) || 
                (pixelY >= (yFrameSize - bracketOffset)) 
               ) 
            begin 
               
                
                redBits   <= 3'b111;  
                greenBits <= 3'b000;  
                blueBits  <= 2'b11;  
                
                boardersDrawReq <= 1'b1;
            end
            
            BG_RGB <= { blueBits, redBits, greenBits }; 
        end 	
    end 
endmodule