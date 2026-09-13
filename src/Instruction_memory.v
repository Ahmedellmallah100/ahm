module Instruction_memory (
    input  [31:0] A,
    output reg [31:0] RD
);

always @(*) begin
    case (A[6:2])
        5'd0:  RD = 32'h00500093; // ADDI x1, x0, 5
        5'd1:  RD = 32'h00A00113; // ADDI x2, x0, 10
        5'd2:  RD = 32'h002081B3; // ADD  x3, x1, x2
        5'd3:  RD = 32'h40118233; // SUB  x4, x3, x1
        5'd4:  RD = 32'h0020F2B3; // AND  x5, x1, x2
        5'd5:  RD = 32'h0020E333; // OR   x6, x1, x2
        5'd6:  RD = 32'h0020C3B3; // XOR  x7, x1, x2
        5'd7:  RD = 32'h00109413; // SLLI x8, x1, 1
        5'd8:  RD = 32'h0010D493; // SRLI x9, x1, 1
        5'd9:  RD = 32'h00300513; // ADDI x10, x0, 3
        5'd10: RD = 32'h00A505B3; // ADD  x11, x10, x10
        5'd11: RD = 32'h00000000; // NOP
        default: RD = 32'h00000000;
    endcase
end

endmodule
