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
initial begin
    $readmemh("program.txt", mem);
end

endmodule  // Instruction_memory
