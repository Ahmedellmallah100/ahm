module PC (
    clk, areset, PC_Next, PC, Load
);

// Port declaration
input  clk, areset;
input  Load;
input  [31:0] PC_Next;
output reg [31:0] PC;

// PC register update
always @(posedge clk or negedge areset) begin
    if (!areset)
        PC <= 32'b0;
    else if (Load)
        PC <= PC_Next;
end

endmodule  // PC
