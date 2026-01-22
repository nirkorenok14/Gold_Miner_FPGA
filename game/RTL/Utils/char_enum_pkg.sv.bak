module bin_to_bcd (
    input  logic [13:0] binary_in,  // Input binary number (0 to 9999)
    
    output logic [3:0]  thousands,  // The thousands digit
    output logic [3:0]  hundreds,   // The hundreds digit
    output logic [3:0]  tens,       // The tens digit
    output logic [3:0]  units       // The units digit
);


 // Internal register for the algorithm
 // the length must be 30 - 14 bits for input + 16 bits for BCD (4 digits * 4 bits) = 30 bits
  logic [29:0] bcd_data; 
  int i;

// using the known double dabble algorithm so we could extract digit without diving by 10
// Double Dabble converts binary to BCD by shifting bits into decimal columns. 
// If a nibble is ≥ 5, we add 3 before the shift to correct for the binary-to-decimal carry gap. 
// This "Add 3, Shift" (equal to +6 after doubling) skips illegal values and forces a decimal carry.
    always_comb begin
        
        // Step 1: Initialize with binary value in the lower bits
        bcd_data = {16'd0, binary_in}; 
        
        // Step 2: Double Dabble Algorithm Loop
        // Iterate 14 times (once for each input bit)
        for (i = 0; i < 14; i = i + 1) begin
            // Check if any BCD nibble is >= 5, if so add 3
            
            // Units (Bits 17-14)
            if (bcd_data[17:14] >= 5) 
                bcd_data[17:14] = bcd_data[17:14] + 3;
                
            // Tens (Bits 21-18)
            if (bcd_data[21:18] >= 5) 
                bcd_data[21:18] = bcd_data[21:18] + 3;
                
            // Hundreds (Bits 25-22)
            if (bcd_data[25:22] >= 5) 
                bcd_data[25:22] = bcd_data[25:22] + 3;
                
            // Thousands (Bits 29-26)
            if (bcd_data[29:26] >= 5) 
                bcd_data[29:26] = bcd_data[29:26] + 3;
            
            // Shift entire register left by 1
            bcd_data = bcd_data << 1;
        end
        
        // Step 3: Assign outputs
        thousands = bcd_data[29:26];
        hundreds  = bcd_data[25:22];
        tens      = bcd_data[21:18];
        units     = bcd_data[17:14];
    end

endmodule