//
// (c) Technion IIT, The Faculty of Electrical and Computer Engineering, 2025
//
//
//  PRELIMINARY VERSION  -  06 April 2025
//


module JukeBox1
    (
    // Declare wires and regs :
 
 input logic [3:0] melodySelect ,      // selector of one melody  
 input logic [4:0] noteIndex,          // serial number of current note. ( maximum 31 ). noteIndex determines freqIndex and note_length, via JueBox
 
 output logic [3:0] tone,         // index to toneDecoder
 output logic [3:0] note_length,       // length of notes, in beats
 output logic silenceOutN ) ;          //  a silence note: disable sound
 

 localparam MaxMelodyLength = 6'h32;  // maximum melody length, in notes. 
    

// ************** frequencies: *************************************************************************************************
    typedef enum logic [3:0] {do_, doD, re, reD, mi, fa, faD, sol, solD, la, laD, si, do_H, doDH, re_H, silence } musicNote ;//*
//              Hex value:      0    1    2    3    4    5    6    7      8    9    A    B     C      D    E       F                   //*
// *****************************************************************************************************************************
      
   // type of frequency is musicNote   (enum)  
   // Frequency index is 0....15   
   // length is in beats ( 1 to 15 )
   // length = 0 means end of melody        

musicNote frq[(MaxMelodyLength-1'b1):0]  ;      // frq is the array of frequency indices of the melody. it includes up to 32 notes.  
logic [3:0] len[(MaxMelodyLength-1'b1):0] ;    // len is the array of note lengths , in terms of beats. it includes up to 32 notes.        

assign silenceOutN = !( tone == silence ) ; // disable sound if note is "silence"    
    
    
    
always_comb begin    
    frq = '{default: 0};
     len = '{default: 0}; 
 case (melodySelect)  
 
      // --- Sound 1: Win (Victory) ---
      1:   begin
             frq[0] = do_;   len[0] = 1;
             frq[1] = mi;    len[1] = 1;
             frq[2] = sol;   len[2] = 1;
             frq[3] = do_H;  len[3] = 4; // High finish
             frq[4] = do_;   len[4] = 0; // End of melody
       end 

      // --- Sound 2: Loss (Game Over) ---
      2:   begin
             frq[0] = sol;   len[0] = 2;
             frq[1] = fa;    len[1] = 2;
             frq[2] = mi;    len[2] = 2;
             frq[3] = do_;   len[3] = 6; // Low and long finish
             frq[4] = do_;   len[4] = 0; // End of melody
       end 

      // --- Sound 3: Claw Moving (Mechanical Tension) ---
      3:   begin
             frq[0] = re;    len[0] = 1;
             frq[1] = reD;   len[1] = 1;
             frq[2] = re;    len[2] = 1;
             frq[3] = reD;   len[3] = 1;
             frq[4] = do_;   len[4] = 0; // End of melody
       end 

      // --- Sound 4: Catch Gold (High Ding) ---
      4:   begin
             frq[0] = si;    len[0] = 1;
             frq[1] = do_H;  len[1] = 4; // Sharp high sound
             frq[2] = do_;   len[2] = 0; // End of melody
       end 

      // --- Sound 5: Catch Stone (Low Thud) ---
      5:   begin
             frq[0] = do_;   len[0] = 1;
             frq[1] = doD;   len[1] = 4; // Low dissonant sound
             frq[2] = do_;   len[2] = 0; // End of melody
       end 

        
        default: begin
                 frq[0] = silence ;        len[0] = 0 ;    // length = 0 means end of melod
    
      end
   endcase
  end // always 
 
//***********************************************************************
//      Extract outputs of specific note from sheet music :                                                 *
//***********************************************************************

assign tone   = frq[noteIndex] ;
assign note_length = len[noteIndex] ; 

 
 
endmodule