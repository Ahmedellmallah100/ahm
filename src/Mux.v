module Mux (
    in0, in1, sel, out  
);

// Port declaration
input [31:0] in0, in1;
input sel;
output reg [31:0] out;

//  logic for Mux
always @( *) begin
    case (sel)
        1'b0 : out = in0;
        1'b1 : out = in1;
    endcase
end


endmodule //Mux