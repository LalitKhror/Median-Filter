`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.02.2025 16:47:18
// Design Name: 
// Module Name: tb_median_filter_3x3
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
// -----------------------------------------------------------------------------
`define ROW 256                // Define the number of rows in the image (256)
`define COL 256                // Define the number of columns in the image (256)
`define width 8                // Define the bit width of each pixel component (8 bits)
`define IN_FILE_NAME  "test.raw" // Define input file name for raw image data
`define OUT_FILE_NAME "test_f.raw" // Define output file name for filtered image data
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
module tb_median_filter;       // Testbench module for the median_filter_3x3 design
// -----------------------------------------------------------------------------
// ----------------------------test arguments-----------------------------------
reg          [0:23]    r24;    // 24-bit register to hold RGB pixel data for writing to file
reg          [0:1572863] data_in; // Register to store all input image data (256 rows * 6144 bits = 1,572,864 bits)
reg  [`ROW*`width*3-1:0] data_out; // Register to store one row of output data from the module (6144 bits)
integer   file_in, file_out, i, j, f; // File pointers for input/output files, loop indices, and file read status
// -----------------------------------------------------------------------------
// --------------------------component arguments--------------------------------
reg  [`ROW*`width*3-1:0]  row_in; // Input row signal to the Unit Under Test (UUT), 6144 bits
reg                       CLK;    // Clock signal for the UUT
reg                       SET;    // Set signal to initialize the UUT
reg                       RST;    // Reset signal for the UUT
wire [`ROW*`width*3-1:0]  row_out; // Output row signal from the UUT, 6144 bits
// -----------------------------------------------------------------------------
// ---------------------------------UUT-----------------------------------------
median_filter UUT(             // Instantiate the median_filter module as the Unit Under Test (UUT)
.row_in    (row_in),           // Connect row_in to the UUT input
.CLK       (CLK),              // Connect clock to the UUT
.SET       (SET),              // Connect set signal to the UUT
.RST       (RST),              // Connect reset signal to the UUT
.row_out   (row_out)           // Connect row_out from the UUT output
);
// -----------------------------------------------------------------------------
// ----------------------------Clock Generator----------------------------------
always                         // Continuous clock generation block
begin 
CLK = 0;                       // Set clock low
#5;                            // Wait 5 time units (half period)
CLK = 1;                       // Set clock high
#5;                            // Wait 5 time units (half period, total 10ns period)
end  
// -----------------------------------------------------------------------------
// ---------------------------start simulation----------------------------------
initial begin                  // Initial block to run the simulation
file_in  = $fopen(`IN_FILE_NAME, "rb"); // Open input file in read-binary mode
file_out = $fopen(`OUT_FILE_NAME, "wb"); // Open output file in write-binary mode
f = $fread(data_in, file_in);  // Read all data from input file into data_in register
SET = 1'b0;                    // Assert SET low to initialize the filter with the first row
row_in = data_in[0:6143];      // Load first row (bits 0 to 6143) into row_in
RST = 1'b1;                    // Keep RST high (inactive)
#5;                            // Wait 5 time units for initialization
SET = 1'b1;                    // Deassert SET to proceed normally
// -----------------------------------------------------------------------------
row_in = data_in[6144:12287];  // Load second row (bits 6144 to 12287) into row_in
RST = 1'b1;                    // Keep RST high (inactive)
SET = 1'b1;                    // Keep SET high (normal operation)
// -----------------------------------------------------------------------------
for (i=0; i<`ROW; i=i+1)       // Loop over all 256 rows (including first two already loaded)
begin
    SET = 1'b1;                // Ensure SET remains high
    row_in = data_in[12288+6144*i +:6144]; // Load subsequent rows (6144 bits each, starting at 12288)
    RST = 1'b1;                // Keep RST high (inactive)
    data_out = row_out;        // Capture the filtered output row from the UUT
    for (j=0; j<`COL; j=j+1)   // Loop over all 256 columns in the row
        begin
            r24 = data_out[6120-24*j +:24]; // Extract 24-bit RGB pixel (starting from end, moving backwards)
            $fwrite(file_out, "%c%c%c", r24[0:7], r24[8:15], r24[16:23]); // Write RGB bytes to output file
        end
    #10;                       // Wait 10 time units (one clock cycle) for processing
end
// -----------------------------------------------------------------------------
$fclose(file_in);              // Close the input file
$fclose(file_out);             // Close the output file
$stop;                         // Stop the simulation
end
endmodule
// -------------------------------End-------------------------------------------			