`timescale 1ns / 1ps
`default_nettype none

module Data_Memory (
    input  wire        clk,
    input  wire        WE,
    input  wire        areset,
    input  wire [31:0] A,
    input  wire [31:0] WD,
    output reg  [31:0] RD
);

reg [31:0] mem [0:7];

integer i;

always @(posedge clk) begin
    if (areset) begin
        for (i = 0; i < 8; i = i + 1)
            mem[i] <= 32'd0;
    end
    else if (WE) begin
        mem[A[4:2]] <= WD;
    end
end

always @(*) begin
    RD = mem[A[4:2]];
end

endmodule

`default_nettype wire
