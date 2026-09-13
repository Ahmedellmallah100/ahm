module Data_Memory (
    input         clk,
    input         WE,
    input         areset,

    input  [2:0]  A,
    input  [31:0] WD,

    output [31:0] RD
);

reg [31:0] mem [0:7];

integer i;


// ============================================================
// Read
// ============================================================

assign RD = mem[A];


// ============================================================
// Write
// ============================================================

always @(posedge clk) begin

    if (!areset) begin

        for (i = 0; i < 8; i = i + 1)
            mem[i] <= 32'd0;

    end

    else if (WE) begin

        mem[A] <= WD;

    end

end

endmodule
