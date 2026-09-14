module riscv_core (
    input         clk,
    input         areset,
    input  [4:0]  InstrAddr,
    input         Execute,
    input  [4:0]  ReadRegAddr,

    output [31:0] Instruction,
    output [31:0] ALUResult,
    output [31:0] ReadRegData,
    output [31:0] MemoryData,
    output [31:0] Result
);

wire [31:0] SrcA;
wire [31:0] SrcB;
wire [31:0] SrcB_reg;
wire [31:0] ImmExt;

wire [2:0] ALUControl;
wire ALUSrc;
wire RegWrite_control;

wire RegWrite;

wire [4:0] Rs1;
wire [4:0] Rs2;
wire [4:0] Rd;

assign Rs1 = Instruction[19:15];
assign Rs2 = Instruction[24:20];
assign Rd  = Instruction[11:7];


// ==================================================
// Instruction Memory
// ==================================================

Instruction_memory im_inst (
    .A({25'b0, InstrAddr, 2'b00}),
    .RD(Instruction)
);


// ==================================================
// Control Unit
// ==================================================

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
    .ImmSrc()
);

assign RegWrite = RegWrite_control & Execute;


// ==================================================
// Immediate Generator
// ==================================================

assign ImmExt =
    (Instruction[14:12] == 3'b001 ||
     Instruction[14:12] == 3'b101) ?

    {27'b0, Instruction[24:20]} :

    {{20{Instruction[31]}}, Instruction[31:20]};


// ==================================================
// Register File
// ==================================================

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


// ==================================================
// ALU input MUX
// ==================================================

assign SrcB = ALUSrc ? ImmExt : SrcB_reg;


// ==================================================
// ALU
// ==================================================

ALU alu_inst (
    .SrcA(SrcA),
    .SrcB(SrcB),
    .ALUControl(ALUControl),
    .ALuResult(ALUResult),
    .zero_flag(),
    .sign_flag()
);


// ==================================================
// No Data Memory
// ==================================================

assign MemoryData = 32'b0;


// ==================================================
// Result
// ==================================================

assign Result = ALUResult;

endmodule
