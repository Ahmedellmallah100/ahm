/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - active low
);

    // ===== إشارات داخلية =====
    wire        areset;
    wire [31:0] PC_out;
    wire [31:0] Result_out;

    // TT بيدّي reset فعّال بصفر (active-low)، والتصميم عايز active-high
    assign areset = ~rst_n;

    // ===== اختيار نافذة المراقبة عن طريق ui_in[1:0] =====
    // 00: PC[7:0]        01: PC[15:8]
    // 10: Result[7:0]    11: Result[15:8]
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
    assign uio_out = 8'b0;   // مش مستخدمة كمخارج
    assign uio_oe  = 8'b0;   // كل بنات uio مضبوطة كـ input (مش مستخدمة فعليًا)

    // إشارات مش مستخدمة (لمنع warnings)
    wire _unused = &{ena, ui_in[7:2], uio_in, 1'b0};

    //====================== التوب الأصلي (بعد التعديل) ============================
    //====================== التوب الأصلي (بعد التعديل) ============================
    riscv_core core_inst (     // ← الاسم اتغيّر من TOP لـ riscv_core
        .clk    (clk),
        .areset (areset),
        .PC     (PC_out),
        .Result (Result_out)
    );
endmodule
