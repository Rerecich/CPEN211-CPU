module tb_ALU(output err);

//**************DUT INPUTS/OUTPUTS************//
reg signed [15:0] val_A;
reg signed [15:0] val_B;
reg [1:0] ALU_op;
reg [2:0] opcode;

reg signed [15:0] ALU_out;
reg [2:0] Z;

integer error = 0;
integer error_count = 0;
assign err = error;

//OPERATIONS ENCODING//
  `define addition    2'b00
  `define subtraction 2'b01
  `define bit_and     2'b10
  `define bit_neg     2'b11

//STATUS ENCODING
  `define ZERO 3'b001
  `define NEGATIVE 3'b010
  `define OVERFLOW 3'b001

//***************INSTANTIATION*************//
ALU dut(
  .val_A(val_A),
  .val_B(val_B),
  .ALU_op(ALU_op),
  .ALU_out(ALU_out),
  .Z(Z)
);

//****************TASKS******************//
task check_addition(input reg [15:0] A_test, input reg [15:0] B_test);
  reg [15:0] test_output;

$display("===========ADDITION===========");
  $display("Test A: %b", A_test);
  $display("Test B: %b", B_test);

  ALU_op = 2'b00;
  val_A = A_test;
  val_B = B_test;
  #3;

  test_output = A_test + B_test;

  #3;
  assert (ALU_out === test_output) begin
    $display("[PASS] - ALU_out = %b", ALU_out);
  end else begin
    $error("[FAIL] - ALU_out is %b. Expected %b.", ALU_out, test_output);
    error = 1;
  end
  
endtask

//

task additionhard;
  reg [15:0] test_output;

$display("===========ADDITION HARD CODED===========");
  $display("Test A: %b", 16'b0000010101100001);
  $display("Test B: %b", 16'b0000000000000101);

  ALU_op = 2'b00;
  val_A = 16'b0000010101100001;
  val_B = 16'b0000000000000101;
  #3;

  test_output = 16'b0000010101100110;

  #3;
  assert (ALU_out === test_output) begin
    $display("[PASS] - ALU_out = %b", ALU_out);
  end else begin
    $error("[FAIL] - ALU_out is %b. Expected %b.", ALU_out, test_output);
    error = 1;
    error_count = error_count + 1;
  end
  
endtask

//

task check_subtraction(input reg [15:0] A_test, input reg [15:0] B_test);
  reg [15:0] test_output;
  
  $display("===========SUBTRACTION===========");
  $display("Test A: %b", A_test);
  $display("Test B: %b", B_test);

  ALU_op = `subtraction;
  val_A = A_test;
  val_B = B_test;
  #3;

  test_output = A_test +1 + ~B_test;

  #3;
  assert (ALU_out === test_output) begin
    $display("[PASS] - ALU_out = %b", ALU_out);
  end else begin
    $error("[FAIL] - ALU_out is %b. Expected %b.", ALU_out, test_output);
    error = 1;
    error_count = error_count + 1;
  end
  
endtask

//

task subtractionhard;
  reg [15:0] test_output;

$display("===========SUBTRACTION HARD CODED===========");
  $display("Test A: %b", 16'b0000010101100001);
  $display("Test B: %b", 16'b0000000000000101);

  ALU_op = `subtraction;
  val_A = 16'b0000010101100001;
  val_B = 16'b0000000000000101;
  #3;

  test_output = 16'b0000010101011100;

  #3;
  assert (ALU_out === test_output) begin
    $display("[PASS] - ALU_out = %b", ALU_out);
  end else begin
    $error("[FAIL] - ALU_out is %b. Expected %b.", ALU_out, test_output);
    error = 1;
    error_count = error_count + 1;
  end
  
endtask

//

task check_AND(input reg [15:0] A_test, input reg [15:0] B_test);
  reg [15:0] test_output;

  $display("===========AND===========");
  $display("Test A: %b", A_test);
  $display("Test B: %b", B_test);

  ALU_op = 2'b10;
  val_A = A_test;
  val_B = B_test;
  #3;

  test_output = A_test & B_test;

  #3;
  assert (ALU_out === test_output) begin
    $display("[PASS] - ALU_out = %b", ALU_out);
  end else begin
    $error("[FAIL] - ALU_out is %b. Expected %b.", ALU_out, test_output);
    error = 1;
  end
  
endtask

//

task andhard;
  reg signed[15:0] test_output;

$display("===========AND HARD CODED===========");
  $display("Test A: %b", 16'b0000010101100001);
  $display("Test B: %b", 16'b0000000000000101);

  ALU_op = `bit_and;
  val_A = 16'b0000010101100001;
  val_B = 16'b0000000100100101;
  #3;

  test_output = 16'b0000000100100001;

  #3;
  assert (ALU_out === test_output) begin
    $display("[PASS] - ALU_out = %b", ALU_out);
  end else begin
    $error("[FAIL] - ALU_out is %b. Expected %b.", ALU_out, test_output);
    error = 1;
    error_count = error_count + 1;
  end
  
endtask

//

task check_negate_B(input reg [15:0] A_test, input reg [15:0] B_test);
  reg [15:0] test_output;
  $display("===========NEGATION===========");
  $display("Test A: %b", A_test);
  $display("Test B: %b", B_test);

  ALU_op = 2'b11;
  val_A = A_test;
  val_B = B_test;
  #3;

  test_output = ~B_test;

  #3;
  assert (ALU_out === test_output) begin
    $display("[PASS] - ALU_out = %b", ALU_out);
  end else begin
    $error("[FAIL] - ALU_out is %b. Expected %b.", ALU_out, test_output);
    error = 1;
    error_count = error_count + 1;
  end
  
endtask

//

task checkoverflow;
   reg [15:0] test_output;

$display("===========OVERFLOW/UNDERFLOW===========");
  $display("Test A: %b", 16'b0000000000000111);
  $display("Test B: %b", 16'b0000010101100001);

  ALU_op = 2'b01;
  val_A = 16'b0000000000000101;
  val_B = 16'b0000010101100001;
  #3;

  test_output = 16'b1111101010100100;

  #3;
  assert (ALU_out === test_output) begin
    $display("[PASS] - ALU_out = %b", ALU_out);
  end else begin
    $error("[FAIL] - ALU_out is %b. Expected %b.", ALU_out, test_output);
    error = 1;
    error_count = error_count +1;
  end

  assert (Z === `OVERFLOW) begin
    $display("[PASS] - Z shows overflow/undeflow");
  end else begin
    $error("[FAIL] - Z does not show overflow/underflow.");
    error = 1;
    error_count = error_count + 1;
  end
endtask




initial begin
  opcode = 3'b101;
  check_addition(16'b0000000000000000, 16'b0000000000000001);
  #3;

  additionhard;
  #3;

  check_subtraction(16'b0000000000000001, 16'b0000000000000010);
  #3;

  subtractionhard;
  #3;

  check_AND(16'b0000000000000001, 16'b0000000000000010);
  #3;

  andhard;
  #3;

  check_negate_B(16'b0000000000000001, 16'b0000000000000010);
  #3;

  checkoverflow;
  #3;

  assert(error === 0) begin
    $display("ALL TESTS PASSED");
  end else begin
    $error("%d tests failed.", error_count);
  end
end

endmodule: tb_ALU
