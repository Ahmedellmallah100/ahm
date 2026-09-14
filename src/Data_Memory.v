module Data_Memory (
    input        clk,
    input        areset,

    input  [7:0] A,
    input  [7:0] WD,
    input        WE,

    output [7:0] RD
);

reg [7:0] mem [0:15];

integer i;


/* =========================
   Asynchronous Read
   ========================= */

assign RD =
    (A < 8'd16) ?
    mem[A[3:0]] :
    8'd0;


/* =========================
   Write
   ========================= */

always @(posedge clk) begin

    if (!areset) begin

        for (i = 0; i < 16; i = i + 1)
            mem[i] <= 8'd0;

    end

    else if (WE && (A < 8'd16)) begin

        mem[A[3:0]] <= WD;

    end

end

endmodule
