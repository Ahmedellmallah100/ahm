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
wire [31:0] SrcB_not_muxed;

wire [31:0] ImmExt;

wire [2:0] ALUControl;

wire ALUSrc;
wire RegWrite_control;
wire MemWrite_control;

wire RegWrite;
wire MemWrite;

wire ResultSrc;

wire Zero;
wire sign_flag;

wire [31:0] RD;

wire [4:0] Rs1;
wire [4:0] Rs2;
wire [4:0] Rd;


// ============================================================
// Instruction Memory
// ============================================================

Instruction_memory im_inst (

    .A({27'b0, InstrAddr, 2'b00}),

    .RD(Instruction)

);


// ============================================================
// Instruction fields
// ============================================================

assign Rs1 = Instruction[19:15];

assign Rs2 = Instruction[24:20];

assign Rd  = Instruction[11:7];


// ============================================================
// Control Unit
// ============================================================

Control_Unit cu_inst (

    .opcode(Instruction[6:0]),

    .funct3(Instruction[14:12]),

    .funct7(Instruction[30]),

    .Zero(Zero),

    .sign_flag(sign_flag),

    .ALUControl(ALUControl),

    .ALUSrc(ALUSrc),

    .RegWrite(RegWrite_control),

    .MemWrite(MemWrite_control),

    .PCSrc(),

    .ResultSrc(ResultSrc),

    .ImmSrc(ImmSrc)

);


// ============================================================
// Execute controls
// ============================================================

assign RegWrite = RegWrite_control & Execute;

assign MemWrite = MemWrite_control & Execute;


// ============================================================
// Sign Extend
// ============================================================

wire [1:0] ImmSrc;

Sign_extend se_inst (

    .Instr(Instruction[31:7]),

    .ImmExt(ImmExt),

    .ImmSrc(ImmSrc)

);


// ============================================================
// Register File
// ============================================================

Register_File rf_inst (

    .A1(Rs1),

    .A2(Rs2),

    .A3(Rd),

    .WD3(Result),

    .clk(clk),

    .areset(areset),

    .RD1(SrcA),

    .RD2(SrcB_not_muxed),

    .WE3(RegWrite)

);




// ============================================================
// ALU MUX
// ============================================================

Mux mux_alu_inst (

    .in0(SrcB_not_muxed),

    .in1(ImmExt),

    .sel(ALUSrc),

    .out(SrcB)

);


// ============================================================
// ALU
// ============================================================

ALU alu_inst (

    .SrcA(SrcA),

    .SrcB(SrcB),

    .ALUControl(ALUControl),

    .ALuResult(ALUResult),

    .zero_flag(Zero),

    .sign_flag(sign_flag)

);


// ============================================================
// Data Memory
// ============================================================

Data_Memory dm_inst (

    .A(ALUResult),

    .WD(SrcB_not_muxed),

    .clk(clk),

    .WE(MemWrite),

    .RD(RD),

    .areset(areset)

);


// ============================================================
// Result MUX
// ============================================================

Mux result_mux_inst (

    .in0(ALUResult),

    .in1(RD),

    .sel(ResultSrc),

    .out(Result)

);


assign MemoryData = RD;

endmodule
