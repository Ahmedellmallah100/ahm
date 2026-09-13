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

reg [31:0] mem [0:31];

// Read ports
assign RD1 = (A1 == 5'd0) ? 32'd0 : mem[A1];

assign RD2 = (A2 == 5'd0) ? 32'd0 : mem[A2];

// External read port
assign ReadRegData =
    (ReadRegAddr == 5'd0) ? 32'd0 : mem[ReadRegAddr];

// Write port
always @(posedge clk) begin
    if (areset && WE3 && (A3 != 5'd0))
        mem[A3] <= WD3;
end

endmodule
