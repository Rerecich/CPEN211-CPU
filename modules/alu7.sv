module ALU(input [15:0] val_A, input [15:0] val_B, input [1:0] ALU_op, output [15:0] ALU_out, output [2:0] Z);
 
//OPERATIONS ENCODING//
  `define addition    2'b00
  `define subtraction 2'b01
  `define bit_and     2'b10
  `define bit_neg     2'b11

//STATUS ENCODING
  `define ZERO 3'b100
  `define NEGATIVE 3'b010
  `define OVERFLOW 3'b001

//registers to use in always
  reg signed [15:0] ALU_out_reg;
  reg signed [15:0] val_B_reg;
   
  reg signed [15:0] val_A_reg;
  reg [2:0] Z_reg;

  //assign val_A_reg = val_A;
 // assign val_B_reg = ~val_B;
  assign ALU_out = ALU_out_reg;
  assign Z = Z_reg;

//

 always_comb begin
    ALU_out_reg = 16'bx;
     val_B_reg = ~val_B + 1'b1;

  if (ALU_op == `addition) begin
    ALU_out_reg = val_A + val_B;
  end 
  else if (ALU_op == `subtraction) begin
    ALU_out_reg = val_A + val_B_reg;
  end
  else if (ALU_op == `bit_and) begin
   ALU_out_reg = val_A & val_B;
  end
  else if (ALU_op == `bit_neg) begin
    ALU_out_reg = ~val_B;
  end
  else begin
    ALU_out_reg = 16'bx;
  end
end

always_comb begin
  Z_reg = 3'bx;
  if (ALU_op == `subtraction) begin
    if(ALU_out == 16'b000000000000000) begin
      Z_reg = `ZERO;
    end else if (ALU_out_reg[0] == 1'b1) begin
      Z_reg = `NEGATIVE;
    end else if ((val_A[0] == val_B[0]) && val_A[0] != ALU_out[0]) begin
      Z_reg = `OVERFLOW;
    end
    else begin
      Z_reg = 3'bx;
    end
  end
end

endmodule: ALU
