module tt_um_example (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    wire [31:0] PC_out;
    wire [31:0] Result_out;

    // rst_n و areset الاتنين active-low، فمحتاجينش أي عكس
    // (شيلنا سطر assign areset = ~rst_n; خالص)

    reg [7:0] mux_out;
    always @(*) begin
        case (ui_in[1:0])
            2'b00: mux_out = PC_out[7:0];
            2'b01: mux_out = PC_out[15:8];
            2'b10: mux_out = Result_out[7:0];
            2'b11: mux_out = Result_out[15:8];
            default: mux_out = 8'b0;
        endcase
    end

    assign uo_out  = mux_out;
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    wire _unused = &{ena, ui_in[7:2], uio_in, 1'b0};

    riscv_core core_inst (
        .clk    (clk),
        .areset (rst_n),      // ← التصحيح هنا: توصيل مباشر بدون عكس
        .PC     (PC_out),
        .Result (Result_out)
    );

endmodule
