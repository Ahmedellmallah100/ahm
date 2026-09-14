module riscv_core (
    input         clk,
    input         areset,
    input         Execute,
    input  [4:0]  ReadRegAddr,

    output [31:0] Instruction,
    output [7:0]  ALUResult,
    output [7:0]  ReadRegData,
    output [7:0]  MemoryData,
    output [7:0]  Result
);

wire [31:0] PC;
wire [31:0] PC_Next;
wire [31:0] PC_Plus4;
wire [31:0] BranchTarget;

wire [7:0] SrcA;
wire [7:0] SrcB;
wire [7:0] SrcB_reg;
wire [7:0] ImmExt;

wire [2:0] ALUControl;
wire ALUSrc;
wire RegWrite_control;
wire RegWrite;

wire Branch;
wire BranchTaken;

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
    .MemWrite(),
    .PCSrc(),
    .ResultSrc(),
    .ImmSrc(),
    .Branch(Branch)
);

assign RegWrite = RegWrite_control & Execute;


/* =========================
   Immediate
   ========================= */

/*
   I-Type:
   ADDI / SLLI / SRLI

   B-Type:
   BEQ
*/

assign ImmExt =
    (Instruction[6:0] == 7'b1100011) ?
    {
        {1{Instruction[31]}},
        {1{Instruction[7]}},
        Instruction[30:25],
        Instruction[11:8],
        1'b0
    } :
    (
        (Instruction[14:12] == 3'b001 ||
         Instruction[14:12] == 3'b101)
        ?
        {3'b000, Instruction[24:20]}
        :
        {{4{Instruction[31]}}, Instruction[27:20]}
    );


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

    .WD3(ALUResult),
    .WE3(RegWrite),

    .RD1(SrcA),
    .RD2(SrcB_reg),
    .ReadRegData(ReadRegData)
);


/* =========================
   ALU Input
   ========================= */

assign SrcB = ALUSrc ? ImmExt[7:0] : SrcB_reg;


/* =========================
   ALU
   ========================= */

ALU alu_inst (
    .SrcA(SrcA),
    .SrcB(SrcB),
    .ALUControl(ALUControl),

    .ALuResult(ALUResult),

    .zero_flag(),
    .sign_flag()
);


/* =========================
   Branch Comparison
   ========================= */

/*
   BEQ:
   SrcA == SrcB_reg
*/

assign BranchTaken =
    Branch &&
    (SrcA == SrcB_reg);


/* =========================
   Program Counter
   ========================= */

assign PC_Plus4 = PC + 32'd4;


/*
   Branch immediate is sign-extended
   and added to current PC.
*/

assign BranchTarget =
    PC + {{24{ImmExt[7]}}, ImmExt};


assign PC_Next =
    BranchTaken ?
    BranchTarget :
    PC_Plus4;


/* =========================
   PC Module
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
    .A(PC),
    .RD(Instruction)
);


/* =========================
   Data Memory
   ========================= */

assign MemoryData = 8'b0;


/* =========================
   Result
   ========================= */

assign Result = ALUResult;

endmodule
