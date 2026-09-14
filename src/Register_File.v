module Register_File (
    input         clk,
    input         areset,

    input  [4:0]  A1,
    input  [4:0]  A2,
    input  [4:0]  A3,

    input  [4:0]  ReadRegAddr,

    input  [7:0]  WD3,
    input         WE3,

    output [7:0] RD1,
    output [7:0] RD2,
    output [7:0] ReadRegData
);

reg [7:0] mem [0:15];

integer i;

assign RD1 =
    (A1 == 5'd0) ? 8'd0 :
    (A1 < 5'd16) ? mem[A1] :
    8'd0;

assign RD2 =
    (A2 == 5'd0) ? 8'd0 :
    (A2 < 5'd16) ? mem[A2] :
    8'd0;

assign ReadRegData =
    (ReadRegAddr == 5'd0) ? 8'd0 :
    (ReadRegAddr < 5'd16) ? mem[ReadRegAddr] :
    8'd0;

always @(posedge clk) begin
    if (!areset) begin
        for (i = 0; i < 16; i = i + 1)
            mem[i] <= 8'd0;
    end
    else if (WE3 && (A3 != 5'd0) && (A3 < 5'd16)) begin
        mem[A3] <= WD3;
    end
end

endmodule
