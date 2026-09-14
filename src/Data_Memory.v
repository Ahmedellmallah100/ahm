module Data_Memory (
    input         clk,
    input         WE,
    input         areset,
    input  [31:0] A,
    input  [31:0] WD,
    output [31:0] RD
);

assign RD = 32'b0;

endmodule
