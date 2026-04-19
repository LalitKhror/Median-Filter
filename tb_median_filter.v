`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench for median_filter using MEM image files
//////////////////////////////////////////////////////////////////////////////////

`define IN_FILE_NAME  "lena_256x256.mem"
`define OUT_FILE_NAME "lena_256x256_output.mem"

module tb_median_filter;

// -----------------------------------------------------------------------------
// Memory for storing image pixels
reg [23:0] image_mem [0:`ROW*`COL-1];

// registers
reg  [0:23] r24;
reg  [`ROW*`width*3-1:0] data_out;

integer file_out;
integer i,j;
integer valid_delay;

// -----------------------------------------------------------------------------
// UUT signals
reg  [`ROW*`width*3-1:0] row_in;
reg CLK;
reg SET;
reg RST;

wire [`ROW*`width*3-1:0] row_out;

// -----------------------------------------------------------------------------
// Instantiate median filter

median_filter UUT(
.row_in(row_in),
.CLK(CLK),
.SET(SET),
.RST(RST),
.row_out(row_out)
);

// -----------------------------------------------------------------------------
// Clock generator

always begin
    CLK = 0;
    #5;
    CLK = 1;
    #5;
end

// -----------------------------------------------------------------------------
// Simulation

initial begin

row_in = 0;
SET = 0;
RST = 1;
valid_delay = 0;

$readmemh(`IN_FILE_NAME, image_mem);

file_out = $fopen(`OUT_FILE_NAME,"w");

#20;
SET = 1;

// -----------------------------------------------------------------------------
// Feed all rows

for(i=0;i<`ROW;i=i+1)
begin

    for(j=0;j<`COL;j=j+1)
        row_in[24*j +:24] = image_mem[i*`COL + j];

    #10;

    if(valid_delay >= 2)
    begin
        data_out = row_out;

        for(j=0;j<`COL;j=j+1)
        begin
            r24 = data_out[24*j +:24];
            $fwrite(file_out,"%06x\n",r24);
        end
    end

    valid_delay = valid_delay + 1;

end

// -----------------------------------------------------------------------------
// Flush remaining pipeline rows

repeat(2)
begin

    #10;

    data_out = row_out;

    for(j=0;j<`COL;j=j+1)
    begin
        r24 = data_out[24*j +:24];
        $fwrite(file_out,"%06x\n",r24);
    end

end

// -----------------------------------------------------------------------------
// finish simulation

$fclose(file_out);

$display("Simulation finished.");

$stop;

end

endmodule
