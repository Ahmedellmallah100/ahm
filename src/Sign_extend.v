module Sign_extend (
    input  [31:7] Instr,
    input  [1:0]  ImmSrc,
    output reg [31:0] ImmExt
);

always @(*) begin
    case (ImmSrc)

        // I-type
        2'b00:
            ImmExt = {{20{Instr[31]}}, Instr[31:20]};

        // S-type
        2'b01:
            ImmExt = {{20{Instr[31]}},
                      Instr[31:25],
                      Instr[11:7]};

        // B-type
        2'b10:
            ImmExt = {{19{Instr[31]}},
                      Instr[31],
                      Instr[7],
                      Instr[30:25],
                      Instr[11:8],
                      1'b0};

        // U-type
        2'b11:
            ImmExt = {Instr[31:12], 12'b0};

        default:
            ImmExt = 32'b0;

    endcase
end

endmodule
