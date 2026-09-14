module PC (
    input         clk,
    input         areset,
    input  [7:0]  PC_Next,
    output reg [7:0] PC,
    input         Load
);

always @(posedge clk or negedge areset) begin

    if (!areset)
        PC <= 8'd0;

    else if (Load)
        PC <= PC_Next;

end

endmodule
