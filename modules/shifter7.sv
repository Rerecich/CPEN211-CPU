module shifter( input [15:0] shift_in, input [1:0] shift_op, output [15:0] shift_out);
 

//SHIFT ENCODING//
  `define no_shift          2'b00
  `define left_shift        2'b01
  `define log_right_shift   2'b10
  `define arith_right       2'b11


//registers to use in always
  reg signed [15:0] shift_out_reg;
  reg signed [15:0] shift_in_reg;

  assign shift_out = shift_out_reg;

 // assign shift_in = shift_in_reg;


always_comb begin
  
  //shift_out_reg = shift_in;

  if (shift_op == `no_shift) begin
    shift_in_reg = shift_in;
    shift_out_reg = shift_in;
    //noshift++;
  end 
  else if (shift_op == `left_shift) begin
    shift_in_reg = shift_in;
    shift_out_reg = shift_in << 1;
  end
  else if (shift_op == `log_right_shift) begin
    shift_in_reg = shift_in;
    shift_out_reg = shift_in >> 1;
  end
  else if (shift_op == `arith_right) begin
    shift_in_reg = shift_in;
    shift_out_reg = shift_in_reg >>> 1;
   //shift_out_reg = signed_shift_out_reg;
  end
  else begin
    shift_out_reg = 16'bx;
    shift_in_reg = 16'bx;
  end
 
end

endmodule: shifter
