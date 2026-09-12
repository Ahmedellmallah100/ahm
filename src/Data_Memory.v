module Data_Memory (
    A, WD, clk, WE, RD, areset
);

// Memory parameters
parameter mem_width = 32;
parameter mem_datapath_width = 64;

// Port declaration
input clk, WE, areset;
input [31:0] A, WD;
output reg [31:0] RD;
integer i;

// Memory array
reg [mem_width-1:0] mem [mem_datapath_width-1:0];

// Read operation (Asynchronous)
always @(*) begin
    RD = mem[A[31:2]];     // Word aligned read
end

// Write operation (Synchronous)
always @(posedge clk) begin
    if (WE) begin
        mem[A[31:2]] <= WD;
    end
end
endmodule  // Data_Memory
