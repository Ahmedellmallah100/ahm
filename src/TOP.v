module TOP (
    clk, areset
);

// Port declaration
input clk, areset;
// Internal wires
wire [31:0] PC, PC_Next;
wire [31:0] Instr;
wire [2:0]  ALUControl;
wire        ALUSrc, RegWrite, MemWrite, PCSrc;
wire [1:0]  ImmSrc;
wire        ResultSrc;
wire        Zero, sign_flag;
wire signed [31:0] ImmExt;
wire [31:0] SrcA, SrcB, SrcB_not_muxed;
wire [31:0] ALuResult;
wire [31:0] RD;
wire [31:0] Result;
// Instantiate PC
PC pc_inst (
    .clk(clk),
    .areset(areset),
    .PC_Next(PC_Next),
    .PC(PC),
    .Load(1'b1)
);
// Instantiate Instruction Memory
Instruction_memory im_inst (
    .A(PC),
    .RD(Instr)
);
// Instantiate Control Unit
Control_Unit cu_inst (
    .opcode(Instr[6:0]),
    .funct3(Instr[14:12]),
    .funct7(Instr[30]),
    .ALUControl(ALUControl),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite),
    .MemWrite(MemWrite),
    .PCSrc(PCSrc),
    .ImmSrc(ImmSrc),
    .ResultSrc(ResultSrc),
    .Zero(Zero),
    .sign_flag(sign_flag)
);
// Instantiate Sign Extend
Sign_extend se_inst (
    .Instr(Instr[31:7]),
    .ImmExt(ImmExt),
    .ImmSrc(ImmSrc)
);
// Instantiate Register File
Register_File rf_inst (
    .clk(clk),
    .areset(areset),
    .A1(Instr[19:15]),
    .A2(Instr[24:20]),
    .A3(Instr[11:7]),
    .WD3(Result),
    .WE3(RegWrite),
    .RD1(SrcA),
    .RD2(SrcB_not_muxed)
);
// Instantiate PC Mux
Mux PC_mux_inst (
    .in0(PC + 32'd4),
    .in1(PC + ImmExt),
    .sel(PCSrc),
    .out(PC_Next)
);
// Instantiate ALU Mux
Mux mux_alu_inst (
    .in0(SrcB_not_muxed),
    .in1(ImmExt),
    .sel(ALUSrc),
    .out(SrcB)
);
// Instantiate ALU
ALU alu_inst (
    .ALUControl(ALUControl),
    .SrcA(SrcA),
    .SrcB(SrcB),
    .ALuResult(ALuResult),
    .zero_flag(Zero),
    .sign_flag(sign_flag)
);
// Instantiate Data Memory
Data_Memory dm_inst (
    .A(ALuResult),
    .WD(SrcB_not_muxed),
    .clk(clk),
    .WE(MemWrite),
    .RD(RD)
);
// Instantiate Result Mux
Mux result_mux_inst (
    .in0(ALuResult),
    .in1(RD),
    .sel(ResultSrc),
    .out(Result)
);
endmodule  // TOP
