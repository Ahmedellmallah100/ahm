module Data_Memory (
    input         clk,
    input         WE,
    input         areset,
    input  [31:0] A,
    input  [31:0] WD,
    output [31:0] RD
);

reg [31:0] mem [0:7];

assign RD = mem[A[4:2]];

always @(posedge clk) begin
    if (!areset) begin
        mem[0] <= 32'd0;
        mem[1] <= 32'd0;
        mem[2] <= 32'd0;
        mem[3] <= 32'd0;
        mem[4] <= 32'd0;
        mem[5] <= 32'd0;
        mem[6] <= 32'd0;
        mem[7] <= 32'd0;
    end
    else if (WE) begin
        mem[A[4:2]] <= WD;
    end
end

endmodule
