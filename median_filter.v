`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.02.2025 16:44:53
// Design Name: 
// Module Name: median_filter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define ROW 256          // Define the number of rows in the image (256)
`define COL 256          // Define the number of columns in the image (256)
`define width 8          // Define the bit width of each pixel component (8 bits)
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
module median_filter(    // Module declaration for a 3x3 median filter
// -----------------------------------------------------------------------------
// --------------------------------input's--------------------------------------
input     [`ROW*`width*3-1:0]  row_in  , // Input row of pixel data (256 pixels * 8 bits * 3 colors = 6144 bits)
input                          CLK     , // Clock signal for synchronous operation
input                          SET     , // Set signal to initialize the module
input                          RST     , // Reset signal to restart the state machine
// -----------------------------------------------------------------------------
// --------------------------------output's-------------------------------------
output reg[`ROW*`width*3-1:0]  row_out   // Output row of filtered pixel data (6144 bits)
);
// -----------------------------------------------------------------------------
// -------------------------------register's------------------------------------
reg       [`ROW*`width*3-1:0]  line_1  ; // Register to store the first (upper) row of the 3x3 window
reg       [`ROW*`width*3-1:0]  line_2  ; // Register to store the second (middle) row of the 3x3 window
reg       [`ROW*`width*3-1:0]  line_3  ; // Register to store the third (lower) row of the 3x3 window
reg                    [2:0]   state, next; // 3-bit registers for current and next state of the state machine
reg             [`width-1:0]   counter  ; // 8-bit counter to track the number of processed rows
// -----------------------------------------------------------------------------
// -------------------------------parameter's-----------------------------------
parameter [2:0]  ROW1 = 3'b000,          // State: Load first row
                 ROW2 = 3'b001,          // State: Load second row
                 ROW3 = 3'b010,          // State: Load third row and start filtering
                 ROUTINE = 3'b011,       // State: Normal filtering operation
                 ROW256 = 3'b100,        // State: Process the last row
                 SLEEP = 3'b101;         // State: Idle state waiting for reset
// -----------------------------------------------------------------------------
// ------------------------------State Machine----------------------------------
// -----------------------------------------------------------------------------
always@(posedge CLK or negedge SET) begin // State machine control block, triggered by clock or set signal
if(SET == 1'b0)                           // If SET is low (active-low), initialize the module
    begin
    counter <= 8'b00000000;               // Reset counter to 0
    state <= ROW1;                        // Set initial state to ROW1 (load first row)
    end                                   
else 
    state <= next;                        // Otherwise, transition to the next state on clock edge
end
// -----------------------------------------------------------------------------
always@(state or negedge RST or row_in) begin // State machine logic block, combinational
case(state)                                   // Determine behavior based on current state
    ROW1:                                     // State ROW1: Load the first row
        begin
        line_1 = row_in;                  // Store input row in line_1
        next = ROW2;                      // Transition to ROW2 state
        end
    ROW2:                                     // State ROW2: Load the second row
        begin
        line_2 = row_in;                  // Store input row in line_2
        next = ROW3;                      // Transition to ROW3 state
        end
    ROW3:                                     // State ROW3: Load third row and start filtering
        begin
        row_out = median_3 ( line_1, line_1, line_2 ); // Apply median filter using line_1 twice (edge case)
        line_3 = row_in;                  // Store input row in line_3
        counter = counter + 1'b1;         // Increment counter
        next = ROUTINE;                   // Transition to ROUTINE state
        end
    ROUTINE:                                  // State ROUTINE: Normal filtering operation
        begin
        row_out = median_3 (line_1, line_2, line_3 ); // Apply median filter to 3 rows
        line_1 = line_2;                  // Shift middle row up
        line_2 = line_3;                  // Shift lower row to middle
        line_3 = row_in;                  // Load new row into lower position
        counter = counter + 1'b1;         // Increment counter
            if (counter == 8'b11111111)   // Check if counter reaches 255 (last row - 1)
                next = ROW256;            // If so, transition to ROW256 state
            else
                next = ROUTINE;           // Otherwise, stay in ROUTINE state
        end
    ROW256:                                   // State ROW256: Process the last row
        begin
        row_out = median_3 (line_2, line_3, line_3 ); // Apply median filter using line_3 twice (edge case)
        next = SLEEP;                     // Transition to SLEEP state
        end
    SLEEP:                                    // State SLEEP: Idle state
        begin
            if(RST == 1'b0)               // If RST is low (active-low), reset to ROW1
                next = ROW1;              // Transition to ROW1 state
            else
                next = SLEEP;             // Otherwise, remain in SLEEP state
        end
endcase
end
// -------------------------------function's------------------------------------
// -----------------------------------------------------------------------------
// -------------------------------function 1------------------------------------
function [0:`width-1] median_1;           // Function to find the median of 3 pixel values (8-bit each)
input [0:`width-1] p_1;                   // First input pixel value
input [0:`width-1] p_2;                   // Second input pixel value
input [0:`width-1] p_3;                   // Third input pixel value
begin
         if(p_1>=p_3 && p_1<=p_2)        // Check ordering: p_3 <= p_1 <= p_2
            median_1=p_1;                // p_1 is the median
    else if(p_1>=p_2 && p_1<=p_3)        // Check ordering: p_2 <= p_1 <= p_3
            median_1=p_1;                // p_1 is the median
    else if(p_2>=p_1 && p_2<=p_3)        // Check ordering: p_1 <= p_2 <= p_3
            median_1=p_2;                // p_2 is the median
    else if(p_2>=p_3 && p_2<=p_1)        // Check ordering: p_3 <= p_2 <= p_1
            median_1=p_2;                // p_2 is the median
    else if(p_3>=p_1 && p_3<=p_2)        // Check ordering: p_1 <= p_3 <= p_2
            median_1=p_3;                // p_3 is the median
    else if(p_3>=p_2 && p_3<=p_1)        // Check ordering: p_2 <= p_3 <= p_1
            median_1=p_3;                // p_3 is the median
end
endfunction
// -----------------------------------------------------------------------------
// -------------------------------function 2------------------------------------
function  [0:`width-1] median_2;          // Function to find the median of a 3x3 window (9 pixels)
input    [0:`width-1] p11;                // Pixel at (1,1) in 3x3 window
input    [0:`width-1] p12;                // Pixel at (1,2)
input    [0:`width-1] p13;                // Pixel at (1,3)
input    [0:`width-1] p21;                // Pixel at (2,1)
input    [0:`width-1] p22;                // Pixel at (2,2)
input    [0:`width-1] p23;                // Pixel at (2,3)
input    [0:`width-1] p31;                // Pixel at (3,1)
input    [0:`width-1] p32;                // Pixel at (3,2)
input    [0:`width-1] p33;                // Pixel at (3,3)
reg      [0:`width-1] L1;                 // Median of first row
reg      [0:`width-1] L2;                 // Median of second row
reg      [0:`width-1] L3;                 // Median of third row
begin
L1 = median_1(p11, p12, p13);             // Compute median of first row
L2 = median_1(p21, p22, p23);             // Compute median of second row
L3 = median_1(p31, p32, p33);             // Compute median of third row
median_2 = median_1(L1, L2, L3);          // Compute median of the three row medians
end
endfunction
// -----------------------------------------------------------------------------
// -------------------------------function 3------------------------------------
function [0:`ROW*`width*3-1] median_3;    // Function to process three rows and produce one filtered row
input [0:`ROW*`width*3-1] line1;          // First input row (6144 bits: 256 pixels * 3 colors * 8 bits)
input [0:`ROW*`width*3-1] line2;          // Second input row
input [0:`ROW*`width*3-1] line3;          // Third input row
// With edge handling
reg [0:(`ROW+2)*`width*3-1] line1_e;      // Extended line1 with edge pixels (258 pixels wide)
reg [0:(`ROW+2)*`width*3-1] line2_e;      // Extended line2 with edge pixels
reg [0:(`ROW+2)*`width*3-1] line3_e;      // Extended line3 with edge pixels
integer i;                                // Loop variable for column iteration
begin
line1_e = {line1[0:`width*3-1], line1, line1[(`ROW-1)*`width*3:`ROW*`width*3-1]}; // Extend line1 by duplicating edge pixels
line2_e = {line2[0:`width*3-1], line2, line2[(`ROW-1)*`width*3:`ROW*`width*3-1]}; // Extend line2 similarly
line3_e = {line3[0:`width*3-1], line3, line3[(`ROW-1)*`width*3:`ROW*`width*3-1]}; // Extend line3 similarly
    for (i=0; i<`COL ; i=i+1) begin       // Loop over all 256 columns
        // RED channel: Apply median filter to 3x3 window for red component
        median_3[24*i   +: 8] = median_2( line1_e[24*i   +: 8], line1_e[24*i+24 +:8] , line1_e[24*i+48 +:8], 
                                          line2_e[24*i   +: 8], line2_e[24*i+24 +:8] , line2_e[24*i+48 +:8] , 
                                          line3_e[24*i   +: 8], line3_e[24*i+24 +:8] , line3_e[24*i+48 +:8]);
        // GREEN channel: Apply median filter to 3x3 window for green component
        median_3[24*i+8 +: 8] = median_2( line1_e[24*i+8 +: 8], line1_e[24*1+32 +:8] , line1_e[24*i+56 +:8], 
                                          line2_e[24*i+8 +: 8], line2_e[24*1+32 +:8] , line2_e[24*i+56 +:8] , 
                                          line3_e[24*i+8 +: 8], line3_e[24*1+32 +:8] , line3_e[24*i+56 +:8]);
        // BLUE channel: Apply median filter to 3x3 window for blue component
        median_3[24*i+16+: 8] = median_2( line1_e[24*i+16+: 8], line1_e[24*i+40 +:8] , line1_e[24*i+64 +:8], 
                                          line2_e[24*i+16+: 8], line2_e[24*i+40 +:8] , line2_e[24*i+64 +:8] , 
                                          line3_e[24*i+16+: 8], line3_e[24*i+40 +:8] , line3_e[24*i+64 +:8]);
    end
end
endfunction
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
endmodule                                // End of module definition