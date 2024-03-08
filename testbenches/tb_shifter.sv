module tb_shifter(output err);
  
//*************DUT INPUTS/OUTPUTS**************//
reg [15:0] SIM_shift_in;
reg [1:0] SIM_shift_op;
reg [15:0] SIM_shift_out;

integer SIM_error;
assign err = SIM_error;

//other 
/*reg clk;
initial begin
  clk <=1'b1;
  forever #5 clk <= ~clk;
end*/

//****************INSTANTIATION***************//
shifter dut(
  .shift_in(SIM_shift_in),
  .shift_op(SIM_shift_op),
  .shift_out(SIM_shift_out)
);

 `define no_shift           2'b00
  `define left_shift        2'b01
  `define log_right_shift   2'b10
  `define arith_right       2'b11

//***************TASKS*****************//
task check_no_shift(reg [15:0] test_input);
  $display("test_input = %b", test_input);

  SIM_shift_op = `no_shift;
  SIM_shift_in = test_input;
  
  #3;
  assert (SIM_shift_out === SIM_shift_in) begin
    $display("[PASS] shift_out is %b",SIM_shift_out);
  end else begin
    $error("[FAIL]- shift_out is %b, expected %b",SIM_shift_out, test_input);
    SIM_error = 1;
  end
  #5;
endtask

//

task check_left_shift(reg [15:0] test_input);
  
  reg signed [15:0] test_output;

  $display("test_input = %b", test_input);
  
  SIM_shift_op = 2'b01;
  SIM_shift_in = test_input;

  
  test_output = test_input << 1;
  
  #3;
  assert (SIM_shift_out === test_output) begin
    $display("[PASS] shift_out is %b",SIM_shift_out);
  end else begin
    $error("[FAIL] - shift_out is %b, expected %b",SIM_shift_out, test_output);
    SIM_error = 1;
  end
  #5;
endtask

//

task check_log_right_shift(reg [15:0] test_input);
  
  reg[15:0] test_output;

  $display("test_input = %b", test_input);
  
  SIM_shift_op = 2'b10;
  SIM_shift_in = test_input;

  
  test_output = test_input >> 1;
  
  #3;
  assert (SIM_shift_out === test_output) begin
    $display("[PASS] shift_out is %b",SIM_shift_out);
  end else begin
    $error("[FAIL] - shift_out is %b, expected %b",SIM_shift_out, test_output);
    SIM_error = 1;
  end
  #5;
endtask

//

task check_arith_right(reg signed [15:0] test_input);
  
  reg signed [15:0] test_output;

  $display("test_input = %b", test_input);
  
  SIM_shift_op = 2'b11;
  SIM_shift_in = test_input;

  
  test_output = test_input >>> 1;
  
  #3;
  assert (SIM_shift_out === test_output) begin
    $display("[PASS] shift_out is %b",SIM_shift_out);
  end else begin
    $error("[FAIL] - shift_out is %b, expected %b",SIM_shift_out, test_output);
    SIM_error = 1;
  end
  #5;
endtask

//


//

//*******************RUNNING TESTS******************//

initial begin
  SIM_error = 0;
  #5;
  check_no_shift(16'b1111000011001111);
  #5;

  check_left_shift(16'b1111000011001100);
  #5;

  check_log_right_shift(16'b1111000011001000);
  #5;

  check_arith_right(16'b1111000011000000);
  #5;


  //HARD CODED TESTS//
  $display("NO SHIFT HARD CODE");
  SIM_shift_in = 16'b1111000011001111;
  SIM_shift_op = `no_shift;
  #5;
  assert (SIM_shift_out === 16'b1111000011001111) begin
     $display("[PASS] shift_out is %b",SIM_shift_out);
  end else begin
    $error("[FAIL] - shift_out is %b, expected %b",SIM_shift_out, 16'b1111000011001111);
    SIM_error = 1;
  end
  #5;

  SIM_shift_in = 16'bx;
  SIM_shift_op = `no_shift;
  #5;
  assert (SIM_shift_out === 16'bx) begin
     $display("[PASS] shift_out is %b",SIM_shift_out);
  end else begin
    $error("[FAIL] - shift_out is %b, expected %b",SIM_shift_out, 16'bx);
    SIM_error = 1;
  end
  #5;

  //left
   $display("LEFT SHIFT HARD CODE");
  SIM_shift_in = 16'b1111000011001111;
  SIM_shift_op = `left_shift;
  #5;
  assert (SIM_shift_out === 16'b1110000110011110) begin
     $display("[PASS] shift_out is %b",SIM_shift_out);
  end else begin
    $error("[FAIL] - shift_out is %b, expected %b",SIM_shift_out, 16'b1110000110011110);
    SIM_error = 1;
  end
  #5;

  //right
  $display("LOGICAL RIGHT SHIFT HARD CODE");
  SIM_shift_in = 16'b1111000011001111;
  SIM_shift_op = `log_right_shift;
  #5;
  assert (SIM_shift_out === 16'b0111100001100111) begin
     $display("[PASS] shift_out is %b",SIM_shift_out);
  end else begin
    $error("[FAIL] - shift_out is %b, expected %b",SIM_shift_out, 16'b0111100001100111);
    SIM_error = 1;
  end
  #5;

  //arith right
  $display("ARITHMETIC RIGHT SHIFT HARD CODE");
  SIM_shift_in = 16'b1111000011001111;
  SIM_shift_op = `arith_right;
  #5;
  assert (SIM_shift_out === 16'b1111100001100111) begin
     $display("[PASS] shift_out is %b",SIM_shift_out);
  end else begin
    $error("[FAIL] - shift_out is %b, expected %b",SIM_shift_out, 16'b1111100001100111);
    SIM_error = 1;
  end
  #5;

  assert(SIM_error === 0) begin
    $display("ALL TESTS PASSED");
  end else begin
    $error(":(");
  end
end


endmodule: tb_shifter
