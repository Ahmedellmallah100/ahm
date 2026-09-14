module riscv_core (
    input         clk,
    input         areset,
    input         Execute,
    input  [4:0]   ReadRegAddr,

    output [31:0] Instruction,
    output [7:0]  ALUResult,
    output [7:0]  ReadRegData,
    output [7:0]  MemoryData,
    output [7:0]  Result
);

wire [7:0] PC;
wire [7:0] PC_Next;

wire [7:0] SrcA;
wire [7:0] SrcB;
wire [7:0] SrcB_reg;
wire [7:0] ImmExt;

wire [7:0] LoadData;

wire [2:0] ALUControl;

wire ALUSrc;
wire RegWrite_control;
wire MemWrite_control;
wire MemToReg;
wire Branch;

wire RegWrite;
wire MemWrite;
wire BranchTaken;

wire zero_flag;

wire [4:0] Rs1;
wire [4:0] Rs2;
wire [4:0] Rd;


/* =========================
   Register Addresses
   ========================= */

assign Rs1 = Instruction[19:15];
assign Rs2 = Instruction[24:20];
assign Rd  = Instruction[11:7];


/* =========================
   Control Unit
   ========================= */

Control_Unit cu_inst (
    .opcode(Instruction[6:0]),
    .funct3(Instruction[14:12]),
    .funct7(Instruction[30]),

    .ALUControl(ALUControl),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite_control),
    .MemWrite(MemWrite_control),
    .MemToReg(MemToReg),
    .Branch(Branch)
);


/* =========================
   Execute Enable
   ========================= */

assign RegWrite = RegWrite_control & Execute;
assign MemWrite = MemWrite_control & Execute;


/* =========================
   Immediate Generator
   ========================= */

always @(*) begin

    case (Instruction[6:0])

        /* BEQ
           low 8 bits of B-immediate
           offset is always aligned */
        7'b1100011:
            ImmExt = {
                Instruction[30:28],
                Instruction[11:8],
                1'b0
            };

        /* SW
           low 8 bits of S-immediate */
        7'b0100011:
            ImmExt = {
                Instruction[30:28],
                Instruction[11:8],
                1'b0
            };

        /* SLLI / SRLI */
        7'b0010011:
            ImmExt = {
                3'b000,
                Instruction[24:20]
            };

        /* LW */
        7'b0000011:
            ImmExt = Instruction[27:20];

        default:
            /* ADDI */
            ImmExt = Instruction[27:20];

    endcase

end


/* =========================
   Register File
   ========================= */

Register_File rf_inst (
    .clk(clk),
    .areset(areset),

    .A1(Rs1),
    .A2(Rs2),
    .A3(Rd),

    .ReadRegAddr(ReadRegAddr),

    .WD3(Result),
    .WE3(RegWrite),

    .RD1(SrcA),
    .RD2(SrcB_reg),
    .ReadRegData(ReadRegData)
);


/* =========================
   ALU Input
   ========================= */

assign SrcB = ALUSrc ? ImmExt : SrcB_reg;


/* =========================
   ALU
   ========================= */

ALU alu_inst (
    .SrcA(SrcA),
    .SrcB(SrcB),
    .ALUControl(ALUControl),

    .ALuResult(ALUResult),

    .zero_flag(zero_flag),

    .sign_flag()
);


/* =========================
   Data Memory
   ========================= */

Data_Memory data_mem_inst (
    .clk(clk),
    .areset(areset),

    .A(ALUResult),
    .WD(SrcB_reg),
    .WE(MemWrite),

    .RD(LoadData)
);

assign MemoryData = LoadData;


/* =========================
   Write Back
   ========================= */

assign Result = MemToReg ? LoadData : ALUResult;


/* =========================
   BEQ
   ========================= */

assign BranchTaken = Branch & zero_flag;


/* =========================
   Next PC
   ========================= */

assign PC_Next =
    BranchTaken ?
    (PC + ImmExt) :
    (PC + 8'd4);


/* =========================
   PC
   ========================= */

PC pc_inst (
    .clk(clk),
    .areset(areset),

    .PC_Next(PC_Next),
    .PC(PC),

    .Load(Execute)
);


/* =========================
   Instruction Memory
   ========================= */

Instruction_memory im_inst (
    .A({24'b0, PC}),
    .RD(Instruction)
);

endmodule
