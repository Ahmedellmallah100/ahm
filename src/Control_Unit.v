module Control_Unit (
    input  [6:0] opcode,
    input  [2:0] funct3,
    input        funct7,

    output reg [2:0] ALUControl,
    output reg       ALUSrc,
    output reg       RegWrite,
    output reg       MemWrite,
    output reg       PCSrc,
    output reg       ResultSrc,
    output reg [1:0] ImmSrc
);

always @(*) begin

    // Defaults
    ALUControl = 3'b000;
    ALUSrc     = 1'b0;
    RegWrite   = 1'b0;
    MemWrite   = 1'b0;
    PCSrc      = 1'b0;
    ResultSrc  = 1'b0;
    ImmSrc     = 2'b00;

    case (opcode)

        // I-Type: ADDI / SLLI / SRLI
        7'b0010011: begin
            ALUSrc   = 1'b1;
            RegWrite = 1'b1;

            case (funct3)
                3'b000: ALUControl = 3'b000; // ADDI
                3'b001: ALUControl = 3'b001; // SLLI
                3'b101: ALUControl = 3'b101; // SRLI
                default: ALUControl = 3'b000;
            endcase
        end

        // R-Type
        7'b0110011: begin
            ALUSrc   = 1'b0;
            RegWrite = 1'b1;

            case (funct3)

                3'b000: begin
                    if (funct7)
                        ALUControl = 3'b010; // SUB
                    else
                        ALUControl = 3'b000; // ADD
                end

                3'b100: ALUControl = 3'b100; // XOR
                3'b110: ALUControl = 3'b110; // OR
                3'b111: ALUControl = 3'b111; // AND

                default:
                    ALUControl = 3'b000;

            endcase
        end

        default: begin
            ALUControl = 3'b000;
            ALUSrc     = 1'b0;
            RegWrite   = 1'b0;
        end

    endcase
end

endmodule
