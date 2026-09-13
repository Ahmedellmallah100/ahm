module tt_um_example (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,

    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,

    input  wire ena,
    input  wire clk,
    input  wire rst_n
);


// ============================================================
// Inputs
// ============================================================

// ui_in[4:0] = Instruction Address
wire [4:0] instr_addr;
assign instr_addr = ui_in[4:0];


// ui_in[5] = Execute
wire execute;
assign execute = ui_in[5];


// ui_in[7:6] = Output Select
wire [1:0] output_select;
assign output_select = ui_in[7:6];


// uio_in[4:0] = Register Read Address
wire [4:0] read_reg_addr;
assign read_reg_addr = uio_in[4:0];


// ============================================================
// Core outputs
// ============================================================

wire [31:0] Instruction;
wire [31:0] ALUResult;
wire [31:0] ReadRegData;
wire [31:0] MemoryData;


// ============================================================
// RISC-V Core
// ============================================================

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


// ============================================================
// Output MUX
// ============================================================

reg [31:0] selected_data;

always @(*) begin

    case (output_select)

        // 00 = Result
        2'b00:
            selected_data = ALUResult;

        // 01 = Register Read
        2'b01:
            selected_data = ReadRegData;

        // 10 = Instruction
        2'b10:
            selected_data = Instruction;

        // 11 = Memory Data
        2'b11:
            selected_data = MemoryData;

        default:
            selected_data = 32'b0;

    endcase

end


// ============================================================
// 32-bit -> 8-bit output
// ============================================================

assign uo_out = selected_data[7:0];


// ============================================================
// Bidirectional pins
// ============================================================

assign uio_out = 8'b0;
assign uio_oe  = 8'b0;


// ============================================================
// Unused signals
// ============================================================

wire _unused;

assign _unused = &{
    ena,
    uio_in[7:5]
};

endmodule
