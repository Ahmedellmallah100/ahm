module Control_Unit (
    opcode, funct3, funct7, Zero, sign_flag,
    ALUControl, ALUSrc, RegWrite, MemWrite, PCSrc, ResultSrc, ImmSrc
);

input  [6:0] opcode;
input  [2:0] funct3;
input        funct7;
input        Zero;
input        sign_flag;
output reg [2:0] ALUControl;
output reg       ALUSrc, RegWrite, MemWrite, PCSrc, ResultSrc;
output reg [1:0] ImmSrc;
reg [1:0] ALUOp;
reg       Branch;
// Main Decoder
always @(*) begin
    case (opcode)
    // -------- LOAD --------
        7'b0000011: begin
            RegWrite = 1;
            ImmSrc   = 2'b00;
            ALUSrc   = 1;
            MemWrite = 0;
            ResultSrc= 1;
            Branch   = 0;
            ALUOp    = 2'b00;
        end
    // -------- STORE --------
        7'b0100011: begin
            RegWrite = 0;
            ImmSrc   = 2'b01;
            ALUSrc   = 1;
            MemWrite = 1;
            ResultSrc= 0;
            Branch   = 0;
            ALUOp    = 2'b00;
        end
    // -------- R-TYPE --------
        7'b0110011: begin
            RegWrite = 1;
            ImmSrc   = 2'b00;
            ALUSrc   = 0;
            MemWrite = 0;
            ResultSrc= 0;
            Branch   = 0;
            ALUOp    = 2'b10;
        end
    // -------- I-TYPE --------
        7'b0010011: begin
            RegWrite = 1;
            ImmSrc   = 2'b00;
            ALUSrc   = 1;
            MemWrite = 0;
            ResultSrc= 0;
            Branch   = 0;
            ALUOp    = 2'b10;
        end
    // -------- BRANCH --------
        7'b1100011: begin
            RegWrite = 0;
            ImmSrc   = 2'b10;
            ALUSrc   = 0;
            MemWrite = 0;
            ResultSrc= 0;
            Branch   = 1;
            ALUOp    = 2'b01;   // ALWAYS SUB
        end
        default: begin
            RegWrite = 0;
            ImmSrc   = 2'b00;
            ALUSrc   = 0;
            MemWrite = 0;
            ResultSrc= 0;
            Branch   = 0;
            ALUOp    = 2'b00;
        end
    endcase
end
// Branch Logic
always @(*) begin
    case (funct3)
        3'b000: PCSrc = Branch &  Zero;      // BEQ
        3'b001: PCSrc = Branch & ~Zero;      // BNE
        3'b100: PCSrc = Branch &  sign_flag; // BLT
        default: PCSrc = 1'b0;
    endcase
end
// ALU Decoder
always @(*) begin
    case (ALUOp)
        2'b00: ALUControl = 3'b000; // ADD
        2'b01: ALUControl = 3'b010; // SUB for all branches
        2'b10: begin
            case (funct3)
                // ADD / SUB
                3'b000: begin
                    if (funct7)
                        ALUControl = 3'b010; // SUB
                    else
                        ALUControl = 3'b000; // ADD
                end
                3'b001: ALUControl = 3'b001; // SLL
                3'b100: ALUControl = 3'b100; // XOR
                3'b101: ALUControl = 3'b101; // SRL
                3'b110: ALUControl = 3'b110; // OR
                3'b111: ALUControl = 3'b111; // AND
                default: ALUControl = 3'b000;
            endcase
        end
        default: ALUControl = 3'b000;
    endcase
end
endmodule  // Control_Unit
