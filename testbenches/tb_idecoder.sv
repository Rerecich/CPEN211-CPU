module tb_idecoder(output err);
  reg [15:0] ir;
  reg [1:0] reg_sel;
  reg [2:0] opcode;
  reg [1:0] ALU_op;
  reg [1:0] shift_op;
  reg [15:0] sximm5;
  reg [15:0] sximm8;
  reg [2:0] r_addr;
  reg [2:0] w_addr;

  integer simError = 0;
  assign err = simError;
  


  idecoder dut(
    .ir(ir),
    .reg_sel(reg_sel),
    .opcode(opcode),
    .ALU_op(ALU_op),
    .shift_op(shift_op),
    .sximm5(sximm5),
    .sximm8(sximm8),
    .r_addr(r_addr),
    .w_addr(w_addr)
  );


initial begin
  ir = 16'b0000000000000000;
  reg_sel = 2'b00;
  #5;

  assert (opcode === 3'b000) begin
     $display("[PASS] opcode %b",opcode);
  end else begin
     $error("[FAIL] opcode is %b, expected %b", opcode, 3'b000);
     simError = 1;
  end

  assert (ALU_op === 2'b00) begin
     $display("[PASS] ALU_op %b", ALU_op);
  end else begin
     $error("[FAIL] ALU_op is %b, expected %b", ALU_op, 2'b00);
     simError = 1;
  end

  assert (shift_op === 2'b00) begin
     $display("[PASS] shift_op %b", shift_op);
  end else begin
     $error("[FAIL] shift_op is %b, expected %b", shift_op, 2'b00);
     simError = 1;
  end

  assert (sximm5 === 16'b0) begin
     $display("[PASS] sximm5 %b", sximm5);
  end else begin
     $error("[FAIL] sximm5 is %b, expected %b", sximm5, 16'b0);
     simError = 1;
  end

  assert (sximm8 === 16'b0) begin
     $display("[PASS] sximm8 %b", sximm8);
  end else begin
     $error("[FAIL] sximm8 is %b, expected %b", sximm8, 16'b0);
     simError = 1;
  end


assert (r_addr === w_addr) begin
     $display("[PASS] r_addr and w_addr are the same");
  end else begin
     $error("[FAIL] r_addr and w_addr are not the same");
     simError = 1;
  end

assert (r_addr === 3'b000) begin
     $display("[PASS] r_addr is 000");
  end else begin
     $error("[FAIL] r_addr is %b, expected 000", r_addr);
     simError = 1;
  end

assert(simError === 0) begin
    $display("ALL TESTS PASSED");
  end else begin
    $error("fail.");
  end
#5;

ir = 16'b1101000110000000;
reg_sel = 2'b10;
#5;

  assert (opcode === 3'b110) begin
     $display("[PASS] opcode %b",opcode);
  end else begin
     $error("[FAIL] opcode is %b, expected %b", opcode, 3'b110);
     simError = 1;
  end

  assert (ALU_op === 2'b10) begin
     $display("[PASS] ALU_op %b", ALU_op);
  end else begin
     $error("[FAIL] ALU_op is %b, expected %b", ALU_op, 2'b10);
     simError = 1;
  end

  assert (shift_op === 2'b00) begin
     $display("[PASS] shift_op %b", shift_op);
  end else begin
     $error("[FAIL] shift_op is %b, expected %b", shift_op, 2'b00);
     simError = 1;
  end

  assert (sximm5 === 16'b0) begin
     $display("[PASS] sximm5 %b", sximm5);
  end else begin
     $error("[FAIL] sximm5 is %b, expected %b", sximm5, 16'b0);
     simError = 1;
  end

  assert (sximm8 === 16'b1111111110000000) begin
     $display("[PASS] sximm8 %b", sximm8);
  end else begin
     $error("[FAIL] sximm8 is %b, expected %b", sximm8, 16'b1111111110000000);
     simError = 1;
  end


assert (r_addr === w_addr) begin
     $display("[PASS] r_addr and w_addr are the same");
  end else begin
     $error("[FAIL] r_addr and w_addr are not the same");
     simError = 1;
  end

assert (r_addr === 3'b001) begin
     $display("[PASS] r_addr is %b", r_addr);
  end else begin
     $error("[FAIL] r_addr is %b, expected %b", r_addr, 3'b001);
     simError = 1;
  end

assert(simError === 0) begin
    $display("ALL TESTS PASSED");
  end else begin
    $error("fail.");
  end
end

endmodule: tb_idecoder
