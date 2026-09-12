module Sign_extend (
    Instr ,ImmExt ,ImmSrc
);
// Port declaration
input [31:7] Instr;
input [1:0] ImmSrc;
output reg signed [31:0] ImmExt;

wire [11:0] I_imm =Instr[31:20];
wire [11:0] S_imm ={Instr[31:25] ,Instr[11:7]};
wire [12:0] B_imm ={Instr[31] ,Instr[7] ,Instr[30:25] ,Instr[11:8] ,1'b0};
 
//  logic for Sign Extension
always @( *) begin
    case (ImmSrc)
        2'b00 : ImmExt = {{20{I_imm[11]}}, I_imm};                  //12-bit signed immediate -> I Type
        2'b01 : ImmExt = {{20{S_imm[11]}}, S_imm};                  //12-bit signed immediate -> S Type
        2'b10 : ImmExt = {{19{B_imm[12]}}, B_imm};                  //13 bit signed immediate -> B Type
        default :ImmExt = 32'b0;  
    endcase
end

endmodule //Sign_extend