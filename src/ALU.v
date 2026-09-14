module ALU (
    input  [7:0] SrcA,
    input  [7:0] SrcB,
    input  [2:0] ALUControl,
    output reg [7:0] ALuResult,
    output zero_flag,
    output sign_flag
);

always @(*) begin
    case (ALUControl)
        3'b000: ALuResult = SrcA + SrcB;          // ADD
        3'b001: ALuResult = SrcA << SrcB[2:0];    // SLL
        3'b010: ALuResult = SrcA - SrcB;          // SUB
        3'b100: ALuResult = SrcA ^ SrcB;          // XOR
        3'b101: ALuResult = SrcA >> SrcB[2:0];    // SRL
        3'b110: ALuResult = SrcA | SrcB;          // OR
        3'b111: ALuResult = SrcA & SrcB;          // AND
        default: ALuResult = 8'b0;
    endcase
end

assign zero_flag = (ALuResult == 8'b0);
assign sign_flag = ALuResult[7];

endmodule
