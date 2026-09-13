module Sign_extend (
input  [31:7] Instr,
input  [1:0]  ImmSrc,
    output reg signed [31:0] ImmExt
);

wire [11:0] I_imm;
wire [11:0] S_imm;
wire [12:0] B_imm;

assign I_imm = Instr[31:20];

assign S_imm = {
    Instr[31:25],
    Instr[11:7]
};

assign B_imm = {
    Instr[31],
    Instr[7],
    Instr[30:25],
    Instr[11:8],
    1'b0
};
    output reg [31:0] ImmExt
);

always @(*) begin

case (ImmSrc)

        // I-Type
        // ====================================================
        // I-type
        // ====================================================

2'b00:
            ImmExt = {{20{I_imm[11]}}, I_imm};
            ImmExt = {{20{Instr[31]}}, Instr[31:20]};


        // ====================================================
        // S-type
        // ====================================================

        // S-Type
2'b01:
            ImmExt = {{20{S_imm[11]}}, S_imm};
            ImmExt = {{20{Instr[31]}},
                      Instr[31:25],
                      Instr[11:7]};


        // ====================================================
        // B-type
        // ====================================================

        // B-Type
2'b10:
            ImmExt = {{19{B_imm[12]}}, B_imm};
            ImmExt = {{19{Instr[31]}},
                      Instr[31],
                      Instr[7],
                      Instr[30:25],
                      Instr[11:8],
                      1'b0};


        // ====================================================
        // U-type
        // ====================================================

        2'b11:
            ImmExt = {Instr[31:12], 12'b0};


default:
ImmExt = 32'b0;
