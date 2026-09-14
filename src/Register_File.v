module Register_File (
    input         clk,
    input         areset,

    input  [4:0]  A1,
    input  [4:0]  A2,
    input  [4:0]  A3,

    input  [4:0]  ReadRegAddr,

    input  [31:0] WD3,
    input         WE3,

    output [31:0] RD1,
    output [31:0] RD2,
    output [31:0] ReadRegData
);

// 16 registers: x0 - x15
reg [31:0] mem [0:15];

integer i;

// Read port 1
assign RD1 =
    (A1 == 5'd0) ? 32'd0 :
    (A1 < 5'd16) ? mem[A1] :
    32'd0;

// Read port 2
assign RD2 =
    (A2 == 5'd0) ? 32'd0 :
    (A2 < 5'd16) ? mem[A2] :
    32'd0;

// External register read
assign ReadRegData =
    (ReadRegAddr == 5'd0) ? 32'd0 :
    (ReadRegAddr < 5'd16) ? mem[ReadRegAddr] :
    32'd0;

// Write port
always @(posedge clk) begin

    if (!areset) begin
        for (i = 0; i < 16; i = i + 1)
            mem[i] <= 32'd0;
    end

    else if (WE3 && (A3 != 5'd0) && (A3 < 5'd16)) begin
        mem[A3] <= WD3;
    end

end

endmodule
