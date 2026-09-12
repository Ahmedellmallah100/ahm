module Instruction_memory (
    A, RD
);

// Memory parameters
parameter mem_width = 32;
parameter mem_depth = 32;

// Port declaration
input  [31:0] A;
output reg [31:0] RD;

// Memory array
reg [mem_width-1:0] mem [mem_depth-1:0];

// Read operation (Asynchronous)
always @(*) begin
    RD = mem[A[31:2]];     // Word aligned
end

// Initialize memory from file
always @(*) begin
    case (A[6:2])   // 5 بت عنوان = 32 موقع (word-aligned)
        5'd0:  RD = 32'h00004033;
        5'd1:  RD = 32'h00000093;
        5'd2:  RD = 32'h00100113;
        5'd3:  RD = 32'h00100193;
        5'd4:  RD = 32'h00100213;
        5'd5:  RD = 32'h00000293;
        5'd6:  RD = 32'h00a00313;
        5'd7:  RD = 32'h00000393;
        5'd8:  RD = 32'h00418c63;
        5'd9:  RD = 32'h00110133;
        5'd10: RD = 32'h404181b3;
        5'd11: RD = 32'h00229393;
        5'd12: RD = 32'h0023a023;
        5'd13: RD = 32'h00420a63;
        5'd14: RD = 32'h002080b3;
        5'd15: RD = 32'h004181b3;
        5'd16: RD = 32'h00229393;
        5'd17: RD = 32'h0013a023;
        5'd18: RD = 32'h00128293;
        5'd19: RD = 32'hfc62cae3;
        5'd20: RD = 32'h00000000;
        default: RD = 32'h00000000;
    endcase
end


endmodule  // Instruction_memory
