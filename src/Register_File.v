module Register_File (
    A1, A2, A3, WD3, clk, areset, RD1, RD2, WE3
);

// Memory parameters
parameter mem_width = 32;
parameter mem_depth = 32;
parameter addr_size = 5;

// Port declaration
input clk, areset;
input [4:0]  A1, A2, A3;
input [31:0] WD3;
input WE3;
output reg [31:0] RD1, RD2;
integer i;

// Memory array
reg [mem_width-1:0] mem [mem_depth-1:0];

// Read operation (Asynchronous)
always @(*) begin
    RD1 = mem[A1];
    RD2 = mem[A2];
end

// Write operation (Synchronous)
always @(posedge clk) begin
    if (!areset) begin
        for (i = 0; i < mem_depth; i = i + 1) begin
            mem[i] = 32'd0;
        end
    end else if (WE3 && (A3 != 5'd0)) begin
        mem[A3] <= WD3;
    end
end
endmodule  // Register_File