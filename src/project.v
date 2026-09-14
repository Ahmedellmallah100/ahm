wire [31:0] Instruction;
wire [7:0]  ALUResult;
wire [7:0]  ReadRegData;
wire [7:0]  MemoryData;
wire [7:0]  Result;

riscv_core core_inst (
    .clk(clk),
    .areset(rst_n),

    .InstrAddr(instr_addr),
    .Execute(execute),

    .ReadRegAddr(read_reg_addr),

    .Instruction(Instruction),
    .ALUResult(ALUResult),
    .ReadRegData(ReadRegData),
    .MemoryData(MemoryData),
    .Result(Result)
);

reg [7:0] selected_data;

always @(*) begin
    case (output_select)
        2'b00: selected_data = Result;
        2'b01: selected_data = ReadRegData;
        2'b10: selected_data = Instruction[7:0];
        2'b11: selected_data = MemoryData;
        default: selected_data = 8'b0;
    endcase
end

assign uo_out = selected_data;
