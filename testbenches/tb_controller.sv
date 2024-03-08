module tb_controller(output err);
  
integer error = 0;
integer error_count = 0;
assign err = error;

//registers for variables
reg clk;
reg rst_n;
reg start;
reg [2:0] opcode;
reg [1:0] ALU_op;
reg [1:0] shift_op;
reg Z;
reg N;
reg V;

reg waiting;
reg [1:0] reg_sel;
reg [1:0] wb_sel;
reg w_en;
reg en_A;
reg en_B;
reg en_C;
reg en_status;
reg sel_A;
reg sel_B;

`define sel_Rd 2'b01
`define sel_Rm 2'b00
`define sel_Rn 2'b10

//****making life easier******

//type
  `define MOV 3'b110
  `define ALU 3'b101
//MOV op definitions
  `define IMM 2'b10
  `define SH  2'b00
//ALUop definitions
  `define ADD 2'b00
  `define CMP 2'b01
  `define AND 2'b10
  `define MVN 2'b11

controller dut(
  .clk(clk),
  .rst_n(rst_n),
  .start(start),
  .opcode(opcode),
  .ALU_op(ALU_op),
  .shift_op(shift_op),
  .Z(Z),
  .N(N),
  .V(V),

  .waiting(waiting),
  .reg_sel(reg_sel),
  .wb_sel(wb_sel),
  .w_en(w_en),
  .en_A(en_A),
  .en_B(en_B),
  .en_C(en_C),
  .en_status(en_status),
  .sel_A(sel_A),
  .sel_B(sel_B)
);

initial begin
  clk = 1'b0;
  forever #5 clk = ~clk;
end


task check_waiting;
  rst_n = 1'b0;
  #20;
  

  assert (waiting === 1'b1) begin
    $display("[PASS] - Waiting activated.");
  end else begin 
    $error("[FAIL] - Waiting is %d, expected %d", waiting, 1'd1);
    error = 1;
    error_count = error_count + 1;
  end

  rst_n = 1'b1;
  start = 1'b1;
  #20;
  assert (waiting === 1'b0) begin
    $display("[PASS] - Waiting deactivated.");
  end else begin 
    $error("[FAIL] - Waiting is %d, expected %d", waiting, 1'd0);
    error = 1;
    error_count = error_count + 1;
  end
  #5;

  //rst_n = 1'b0;
endtask

task startoffandon;
  start = 1'b0;
  #5;
  start = 1'b1;
endtask







initial begin
#6;
check_waiting;

//checking mov
$display("======MOV IMMEDIATE======");
opcode = `MOV;
ALU_op = `IMM;
#20;

assert (en_A === 1'b1) begin
  $display("[PASS] - Register A ready.");
end else begin
  $error("[FAIL] - en_A is %d, expected %d.", en_A, 1'd1);
  error = 1;
  error_count = error_count + 1;
end

assert (wb_sel === 2'b10) begin
  $display("[PASS] - Reading from immediate.");
end else begin
  $error("[FAIL] - wb_sel is %b, expected %b.", wb_sel, 2'b10);
  error = 1;
  error_count = error_count + 1;
end

assert (reg_sel === `sel_Rn) begin
  $display("[PASS] - Writing to Rn");
end else begin
  $error("[FAIL] - reg_sel is %b, expected %b.", reg_sel, `sel_Rn);
  error = 1;
  error_count = error_count + 1;
end

start = 1'b0;
#20;

assert (waiting === 1'b1) begin
    $display("[PASS] - Waiting activated.");
  end else begin 
    $error("[FAIL] - Waiting is %d, expected %d", waiting, 1'd1);
    error = 1;
    error_count = error_count + 1;
  end



$display("========MOV SHIFTED========");
start = 1'b1;
ALU_op = `SH;
#25; //time to go from waits, decode, load b

assert (en_B === 1'b1) begin
    $display("[PASS] - Regsiter B ready.");
  end else begin 
    $error("[FAIL] - en_B is %d, expected %d", en_B, 1'd1);
    error = 1;
    error_count = error_count + 1;
  end

assert (en_A === 1'b0) begin
    $display("[PASS] - Regsiter A closed.");
  end else begin 
    $error("[FAIL] - en_A is %d, expected %d", en_A, 1'd0);
    error = 1;
    error_count = error_count + 1;
  end

assert (reg_sel === `sel_Rm) begin
  $display("[PASS] - Writing to Rm");
end else begin
  $error("[FAIL] - reg_sel is %b, expected %b.", reg_sel, `sel_Rm);
  error = 1;
  error_count = error_count + 1;
end

//startoffandon;
#10; //time to move to next state (movshift)

assert (en_B === 1'b0) begin
    $display("[PASS] - Regsiter B closed.");
  end else begin 
    $error("[FAIL] - en_B is %d, expected %d", en_B, 1'd0);
    error = 1;
    error_count = error_count + 1;
  end

assert (sel_A === 1'b1) begin
    $display("[PASS] - Taking zero from register A");
  end else begin 
    $error("[FAIL] - sel_A is %d, expected %d", sel_A, 1'd1);
    error = 1;
    error_count = error_count + 1;
  end

  assert (sel_B === 1'b0) begin
    $display("[PASS] - Taking value from register B");
  end else begin 
    $error("[FAIL] - sel_B is %d, expected %d", sel_B, 1'd0);
    error = 1;
    error_count = error_count + 1;
  end

  assert (en_C === 1'b1) begin
    $display("[PASS] - Regsiter C open.");
  end else begin 
    $error("[FAIL] - en_C is %d, expected %d", en_C, 1'd1);
    error = 1;
    error_count = error_count + 1;
  end

//startoffandon;
#10; //time for next state (write)

assert (reg_sel === `sel_Rd) begin
  $display("[PASS] - Writing to Rd");
end else begin
  $error("[FAIL] - reg_sel is %b, expected %b.", reg_sel, `sel_Rd);
  error = 1;
  error_count = error_count + 1;
end

 assert (en_C === 1'b0) begin
    $display("[PASS] - Regsiter C closed.");
  end else begin 
    $error("[FAIL] - en_C is %d, expected %d", en_C, 1'd0);
    error = 1;
    error_count = error_count + 1;
  end

assert (wb_sel === 2'b00) begin
  $display("[PASS] - Reading from register C.");
end else begin
  $error("[FAIL] - wb_sel is %b, expected %d.", wb_sel, 2'b00);
  error = 1;
  error_count = error_count + 1;
end

start = 1'b0;
#15;




///////////////////////////////////////

$display("===========ADD===========");
ALU_op = `ADD;
opcode = `ALU;
start = 1'b1;
//start = 1'b0;
#25; //time to go from waits, decode, load a

assert (en_B === 1'b0) begin
    $display("[PASS] - Regsiter B closed.");
  end else begin 
    $error("[FAIL] - en_B is %d, expected %d", en_B, 1'd0);
    error = 1;
    error_count = error_count + 1;
  end

assert (en_A === 1'b1) begin
    $display("[PASS] - Regsiter A open.");
  end else begin 
    $error("[FAIL] - en_A is %d, expected %d", en_A, 1'd1);
    error = 1;
    error_count = error_count + 1;
  end

assert (reg_sel === `sel_Rn) begin
  $display("[PASS] - Writing to Rn");
end else begin
  $error("[FAIL] - reg_sel is %b, expected %b.", reg_sel, `sel_Rn);
  error = 1;
  error_count = error_count + 1;
end

#10; //time to move to next state (load b)

assert (en_B === 1'b1) begin
    $display("[PASS] - Regsiter B open.");
  end else begin 
    $error("[FAIL] - en_B is %d, expected %d", en_B, 1'd1);
    error = 1;
    error_count = error_count + 1;
  end

assert (en_A === 1'b0) begin
    $display("[PASS] - Regsiter A closed.");
  end else begin 
    $error("[FAIL] - en_A is %d, expected %d", en_A, 1'd0);
    error = 1;
    error_count = error_count + 1;
  end

#15; //time to move to next state (add)

assert (sel_A === 1'b0) begin
    $display("[PASS] - Taking value from register A");
  end else begin 
    $error("[FAIL] - sel_A is %d, expected %d", sel_A, 1'd0);
    error = 1;
    error_count = error_count + 1;
  end

  assert (sel_B === 1'b0) begin
    $display("[PASS] - Taking value from register B");
  end else begin 
    $error("[FAIL] - sel_B is %d, expected %d", sel_B, 1'd0);
    error = 1;
    error_count = error_count + 1;
  end

  assert (en_C === 1'b1) begin
    $display("[PASS] - Regsiter C open.");
  end else begin 
    $error("[FAIL] - en_C is %d, expected %d", en_C, 1'd1);
    error = 1;
    error_count = error_count + 1;
  end

#15; //time for next state (write)

assert (reg_sel === `sel_Rd) begin
  $display("[PASS] - Writing to Rd");
end else begin
  $error("[FAIL] - reg_sel is %b, expected %b.", reg_sel, `sel_Rd);
  error = 1;
  error_count = error_count + 1;
end

 assert (en_C === 1'b0) begin
    $display("[PASS] - Regsiter C closed.");
  end else begin 
    $error("[FAIL] - en_C is %d, expected %d", en_C, 1'd0);
    error = 1;
    error_count = error_count + 1;
  end

assert (wb_sel === 2'b00) begin
  $display("[PASS] - Reading from register C.");
end else begin
  $error("[FAIL] - wb_sel is %b, expected %d.", wb_sel, 2'b00);
  error = 1;
  error_count = error_count + 1;
end

start = 1'b0;
#5;


$display("===========CMP===========");
ALU_op = `CMP;
opcode = `ALU;
start = 1'b1;
//start = 1'b0;
#20; //time to go from waits, decode, load a

assert (en_B === 1'b0) begin
    $display("[PASS] - Regsiter B closed.");
  end else begin 
    $error("[FAIL] - en_B is %d, expected %d", en_B, 1'd0);
    error = 1;
    error_count = error_count + 1;
  end

assert (en_A === 1'b1) begin
    $display("[PASS] - Regsiter A open.");
  end else begin 
    $error("[FAIL] - en_A is %d, expected %d", en_A, 1'd1);
    error = 1;
    error_count = error_count + 1;
  end

assert (reg_sel === `sel_Rn) begin
  $display("[PASS] - Writing to Rn");
end else begin
  $error("[FAIL] - reg_sel is %b, expected %b.", reg_sel, `sel_Rn);
  error = 1;
  error_count = error_count + 1;
end

#10; //time to move to next state (load b)

assert (en_B === 1'b1) begin
    $display("[PASS] - Regsiter B open.");
  end else begin 
    $error("[FAIL] - en_B is %d, expected %d", en_B, 1'd1);
    error = 1;
    error_count = error_count + 1;
  end

assert (en_A === 1'b0) begin
    $display("[PASS] - Regsiter A closed.");
  end else begin 
    $error("[FAIL] - en_A is %d, expected %d", en_A, 1'd0);
    error = 1;
    error_count = error_count + 1;
  end

#10; //time to move to next state (cmp)

assert (sel_A === 1'b0) begin
    $display("[PASS] - Taking value from register A");
  end else begin 
    $error("[FAIL] - sel_A is %d, expected %d", sel_A, 1'd0);
    error = 1;
    error_count = error_count + 1;
  end

  assert (sel_B === 1'b0) begin
    $display("[PASS] - Taking value from register B");
  end else begin 
    $error("[FAIL] - sel_B is %d, expected %d", sel_B, 1'd0);
    error = 1;
    error_count = error_count + 1;
  end

  assert (en_status === 1'b1) begin
    $display("[PASS] -Ready to update status.");
  end else begin 
    $error("[FAIL] - en_status is %d, expected %d", en_status, 1'd1);
    error = 1;
    error_count = error_count + 1;
  end

  assert (en_B === 1'b0) begin
    $display("[PASS] - Regsiter B closed.");
  end else begin 
    $error("[FAIL] - en_B is %d, expected %d", en_B, 1'd0);
    error = 1;
    error_count = error_count + 1;
  end


start = 1'b0;
#10;

$display("===========ANDS===========");
ALU_op = `AND;
opcode = `ALU;
start = 1'b1;
//start = 1'b0;
#30; //time to go from waits, decode, load a

assert (en_B === 1'b0) begin
    $display("[PASS] - Regsiter B closed.");
  end else begin 
    $error("[FAIL] - en_B is %d, expected %d", en_B, 1'd0);
    error = 1;
    error_count = error_count + 1;
  end

assert (en_A === 1'b1) begin
    $display("[PASS] - Regsiter A open.");
  end else begin 
    $error("[FAIL] - en_A is %d, expected %d", en_A, 1'd1);
    error = 1;
    error_count = error_count + 1;
  end

assert (reg_sel === `sel_Rn) begin
  $display("[PASS] - Writing to Rn");
end else begin
  $error("[FAIL] - reg_sel is %b, expected %b.", reg_sel, `sel_Rn);
  error = 1;
  error_count = error_count + 1;
end

#10; //time to move to next state (load b)

assert (en_B === 1'b1) begin
    $display("[PASS] - Regsiter B open.");
  end else begin 
    $error("[FAIL] - en_B is %d, expected %d", en_B, 1'd1);
    error = 1;
    error_count = error_count + 1;
  end

assert (en_A === 1'b0) begin
    $display("[PASS] - Regsiter A closed.");
  end else begin 
    $error("[FAIL] - en_A is %d, expected %d", en_A, 1'd0);
    error = 1;
    error_count = error_count + 1;
  end

#10; //time to move to next state (ands)

assert (sel_A === 1'b0) begin
    $display("[PASS] - Taking value from register A");
  end else begin 
    $error("[FAIL] - sel_A is %d, expected %d", sel_A, 1'd0);
    error = 1;
    error_count = error_count + 1;
  end

  assert (sel_B === 1'b0) begin
    $display("[PASS] - Taking value from register B");
  end else begin 
    $error("[FAIL] - sel_B is %d, expected %d", sel_B, 1'd0);
    error = 1;
    error_count = error_count + 1;
  end

  assert (en_C === 1'b1) begin
    $display("[PASS] - Regsiter C open.");
  end else begin 
    $error("[FAIL] - en_C is %d, expected %d", en_C, 1'd1);
    error = 1;
    error_count = error_count + 1;
  end

  assert (en_status === 1'b1) begin
    $display("[PASS] -Ready to update status.");
  end else begin 
    $error("[FAIL] - en_status is %d, expected %d", en_status, 1'd1);
    error = 1;
    error_count = error_count + 1;
  end

#10; //time for next state (write)

assert (reg_sel === `sel_Rd) begin
  $display("[PASS] - Writing to Rd");
end else begin
  $error("[FAIL] - reg_sel is %b, expected %b.", reg_sel, `sel_Rd);
  error = 1;
  error_count = error_count + 1;
end

 assert (en_C === 1'b0) begin
    $display("[PASS] - Regsiter C closed.");
  end else begin 
    $error("[FAIL] - en_C is %d, expected %d", en_C, 1'd0);
    error = 1;
    error_count = error_count + 1;
  end

assert (wb_sel === 2'b00) begin
  $display("[PASS] - Reading from register C.");
end else begin
  $error("[FAIL] - wb_sel is %b, expected %d.", wb_sel, 2'b00);
  error = 1;
  error_count = error_count + 1;
end

start = 1'b0;
#5;


$display("===========MVN===========");
ALU_op = `MVN;
opcode = `ALU;
start = 1'b1;
//start = 1'b0;
#30; //time to go from waits, decode, load b (skips load a)


assert (en_B === 1'b1) begin
    $display("[PASS] - Regsiter B open.");
  end else begin 
    $error("[FAIL] - en_B is %d, expected %d", en_B, 1'd1);
    error = 1;
    error_count = error_count + 1;
  end

assert (en_A === 1'b0) begin
    $display("[PASS] - Regsiter A closed.");
  end else begin 
    $error("[FAIL] - en_A is %d, expected %d", en_A, 1'd0);
    error = 1;
    error_count = error_count + 1;
  end

#15; //time to move to next state (mvn)

assert (sel_A === 1'b1) begin
    $display("[PASS] - Taking zero from register A");
  end else begin 
    $error("[FAIL] - sel_A is %d, expected %d", sel_A, 1'd1);
    error = 1;
    error_count = error_count + 1;
  end

  assert (sel_B === 1'b0) begin
    $display("[PASS] - Taking value from register B");
  end else begin 
    $error("[FAIL] - sel_B is %d, expected %d", sel_B, 1'd0);
    error = 1;
    error_count = error_count + 1;
  end

  assert (en_C === 1'b1) begin
    $display("[PASS] - Regsiter C open.");
  end else begin 
    $error("[FAIL] - en_C is %d, expected %d", en_C, 1'd1);
    error = 1;
    error_count = error_count + 1;
  end

  assert (en_B === 1'b0) begin
    $display("[PASS] - Register B closed.");
  end else begin 
    $error("[FAIL] - en_status is %d, expected %d", en_status, 1'd1);
    error = 1;
    error_count = error_count + 1;
  end

#15; //time for next state (write)

assert (reg_sel === `sel_Rd) begin
  $display("[PASS] - Writing to Rd");
end else begin
  $error("[FAIL] - reg_sel is %b, expected %b.", reg_sel, `sel_Rd);
  error = 1;
  error_count = error_count + 1;
end

 assert (en_C === 1'b0) begin
    $display("[PASS] - Regsiter C closed.");
  end else begin 
    $error("[FAIL] - en_C is %d, expected %d", en_C, 1'd0);
    error = 1;
    error_count = error_count + 1;
  end

assert (wb_sel === 2'b00) begin
  $display("[PASS] - Reading from register C.");
end else begin
  $error("[FAIL] - wb_sel is %b, expected %d.", wb_sel, 2'b00);
  error = 1;
  error_count = error_count + 1;
end






assert (error === 0) begin 
  $display("ALL TESTS PASSED");
end else begin
  $display("Error - %d tests failed.", error_count);
end

//$stop;



end

endmodule: tb_controller
