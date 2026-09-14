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

wire [7:0] SrcA;
wire [7:0] SrcB;
wire [7:0] SrcB_reg;
wire [7:0] ImmExt;

wire [2:0] ALUControl;
wire ALUSrc;
wire RegWrite_control;
wire RegWrite;

wire [4:0] Rs1;
wire [4:0] Rs2;
wire [4:0] Rd;

/* =========================
   Program Counter
   ========================= */

reg [6:0] PC;

always @(posedge clk) begin
    if (!areset)
        PC <= 7'd0;
    else if (Execute)
        PC <= PC + 7'd4;
end

/* =========================
   Instruction Memory
   ========================= */

Instruction_memory im_inst (
    .A({25'b0, PC}),
    .RD(Instruction)
);

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
    .ImmSrc()
);

assign RegWrite = RegWrite_control & Execute;

/* =========================
   Immediate
   ========================= */

assign ImmExt =
    (Instruction[14:12] == 3'b001 ||
     Instruction[14:12] == 3'b101) ?
    {3'b000, Instruction[24:20]} :
    {{4{Instruction[31]}}, Instruction[27:20]};

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

assign SrcB = ALUSrc ? ImmExt : SrcB_reg;

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
   No Data Memory yet
   ========================= */

assign MemoryData = 8'b0;

assign Result = ALUResult;

endmodule
