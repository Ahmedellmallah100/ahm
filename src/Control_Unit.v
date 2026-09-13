module Control_Unit (
    input  [6:0] opcode,
    input  [2:0] funct3,
    input        funct7,
    input        Zero,
    input        sign_flag,

    output reg [2:0] ALUControl,
    output reg       ALUSrc,
    output reg       RegWrite,
    output reg       MemWrite,
    output reg       PCSrc,
    output reg       ResultSrc,
    output reg [1:0] ImmSrc
);

reg [1:0] ALUOp;
reg       Branch;

always @(*) begin

    // Default values
    RegWrite = 1'b0;
    ImmSrc   = 2'b00;
    ALUSrc   = 1'b0;
    MemWrite = 1'b0;
    ResultSrc = 1'b0;
    Branch   = 1'b0;
    ALUOp    = 2'b00;

    case (opcode)

        // LOAD
        7'b0000011: begin
            RegWrite  = 1'b1;
            ImmSrc    = 2'b00;
            ALUSrc    = 1'b1;
            MemWrite  = 1'b0;
            ResultSrc = 1'b1;
            Branch    = 1'b0;
            ALUOp     = 2'b00;
        end

        // STORE
        7'b0100011: begin
            RegWrite  = 1'b0;
            ImmSrc    = 2'b01;
            ALUSrc    = 1'b1;
            MemWrite  = 1'b1;
            ResultSrc = 1'b0;
            Branch    = 1'b0;
            ALUOp     = 2'b00;
        end

        // R-Type
        7'b0110011: begin
            RegWrite  = 1'b1;
            ImmSrc    = 2'b00;
            ALUSrc    = 1'b0;
            MemWrite  = 1'b0;
            ResultSrc = 1'b0;
            Branch    = 1'b0;
            ALUOp     = 2'b10;
        end

        // I-Type
        7'b0010011: begin
            RegWrite  = 1'b1;
            ImmSrc    = 2'b00;
            ALUSrc    = 1'b1;
            MemWrite  = 1'b0;
            ResultSrc = 1'b0;
            Branch    = 1'b0;
            ALUOp     = 2'b10;
        end

        // BRANCH
        7'b1100011: begin
            RegWrite  = 1'b0;
            ImmSrc    = 2'b10;
            ALUSrc    = 1'b0;
            MemWrite  = 1'b0;
            ResultSrc = 1'b0;
            Branch    = 1'b1;
            ALUOp     = 2'b01;
        end

        default: begin
            RegWrite  = 1'b0;
            ImmSrc    = 2'b00;
            ALUSrc    = 1'b0;
            MemWrite  = 1'b0;
            ResultSrc = 1'b0;
            Branch    = 1'b0;
            ALUOp     = 2'b00;
        end

    endcase
end


// Branch control
always @(*) begin

    case (funct3)

        3'b000: PCSrc = Branch & Zero;        // BEQ
        3'b001: PCSrc = Branch & ~Zero;       // BNE
        3'b100: PCSrc = Branch & sign_flag;  // BLT

        default: PCSrc = 1'b0;

    endcase

end


// ALU control
always @(*) begin

    case (ALUOp)

        // ADD
        2'b00:
            ALUControl = 3'b000;

        // SUB
        2'b01:
            ALUControl = 3'b010;

        // R-Type / I-Type
        2'b10: begin

            case (funct3)

                3'b000: begin
                    if (funct7)
                        ALUControl = 3'b010; // SUB
                    else
                        ALUControl = 3'b000; // ADD
                end

                3'b001:
                    ALUControl = 3'b001; // SLL

                3'b100:
                    ALUControl = 3'b100; // XOR

                3'b101:
                    ALUControl = 3'b101; // SRL

                3'b110:
                    ALUControl = 3'b110; // OR

                3'b111:
                    ALUControl = 3'b111; // AND

                default:
                    ALUControl = 3'b000;

            endcase

        end

        default:
            ALUControl = 3'b000;

    endcase

end

endmodule
