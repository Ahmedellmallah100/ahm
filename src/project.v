module tt_um_example (

input  wire [7:0] ui_in,

output wire [7:0] uo_out,

input  wire [7:0] uio_in,

output wire [7:0] uio_out,

output wire [7:0] uio_oe,

    input  wire       ena,

    input  wire       clk,

    input  wire       rst_n
    input  wire ena,
    input  wire clk,
    input  wire rst_n

);

    // ============================================================
    // Inputs
    // ============================================================

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
    wire [4:0] instr_addr;
    wire       execute;
    wire [1:0] output_select;
    wire [4:0] read_reg_addr;

assign output_select = ui_in[7:6];
    assign instr_addr    = ui_in[4:0];
    assign execute       = ui_in[5];
    assign output_select = ui_in[7:6];

    assign read_reg_addr = uio_in[4:0];

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
    wire [31:0] Result;

// ============================================================
// Core outputs
// ============================================================

wire [31:0] Instruction;
wire [31:0] ALUResult;
wire [31:0] ReadRegData;
wire [31:0] MemoryData;
wire [31:0] Result;
    // ============================================================
    // RISC-V Core
    // ============================================================

    riscv_core core_inst (

// ============================================================
// RISC-V Core
// ============================================================
        .clk(clk),
        .areset(rst_n),

riscv_core core_inst (
        .InstrAddr(instr_addr),
        .Execute(execute),

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
    // ============================================================
    // Output MUX
    // ============================================================

always @(*) begin
    reg [7:0] selected_data;

    case (output_select)
    always @(*) begin

        // 00 = ALU / Result
        2'b00:
            selected_data = Result;
        case (output_select)

        // 01 = Register Read
        2'b01:
            selected_data = ReadRegData;
            // 00 = ALU Result
            2'b00:
                selected_data = ALUResult[7:0];

        // 10 = Instruction
        2'b10:
            selected_data = Instruction;
            // 01 = Register Value
            2'b01:
                selected_data = ReadRegData[7:0];

        // 11 = Memory Data
        2'b11:
            selected_data = MemoryData;
            // 10 = Instruction
            2'b10:
                selected_data = Instruction[7:0];

        default:
            selected_data = 32'b0;
            // 11 = Memory Data
            2'b11:
                selected_data = MemoryData[7:0];

    endcase
            default:
                selected_data = 8'b0;

end
        endcase

    end

// ============================================================
// 32-bit → 8-bit output
// ============================================================
//
// uio_in[7:6] is not used.
// ui_in[7:6] selects data type.
//
// The current output gives the LOW 8 bits.
//
// Example:
// x3 = 15
//
// uo_out = 8'h0F
//

assign uo_out = selected_data[7:0];
    // ============================================================
    // Output
    // ============================================================

    assign uo_out = selected_data;

// ============================================================
// Bidirectional pins
// ============================================================
//
// We use uio as INPUT only.
//
// Therefore OE = 0.
//

assign uio_out = 8'b0;
    // ============================================================
    // Bidirectional pins
    // ============================================================

assign uio_oe = 8'b0;
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;


// ============================================================
// Unused signal
// ============================================================
    // ============================================================
    // Unused pins
    // ============================================================

wire _unused;
    wire _unused;

assign _unused = &{
    ena,
    uio_in[7:5]
};
    assign _unused = &{
        ena,
        uio_in[7:5]
    };

endmodule
