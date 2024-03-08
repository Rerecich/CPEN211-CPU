module tb_datapath(output err);
  
  reg clk;

  //reg [15:0] datapath_in;
  reg [15:0] mdata;
  reg [7:0] pc;
  reg [1:0] wb_sel;
  reg [2:0] w_addr;
  reg w_en;
  reg [2:0] r_addr;
  reg en_A;
  reg en_B;
  reg [1:0] shift_op;
  reg sel_A;
  reg sel_B;
  reg [1:0] ALU_op;
  reg en_C;
  reg en_status;
  reg [15:0] sximm8;
  reg [15:0] sximm5;
  
  reg [15:0] datapath_out;
  reg Z_out;
  reg N_out;
  reg V_out;

  integer error = 0;
  integer error_count = 0;
  assign err = error;

  datapath dut(
    .clk(clk),
    .mdata(mdata),
    .pc(pc),
    .wb_sel(wb_sel),
    .w_addr(w_addr),
    .w_en(w_en),
    .r_addr(r_addr),
    .en_A(en_A),
    .en_B(en_B),
    .shift_op(shift_op),
    .sel_A(sel_A),
    .sel_B(sel_B),
    .ALU_op(ALU_op),
    .en_C(en_C),
    .en_status(en_status),
    .sximm8(sximm8),
    .sximm5(sximm5),
    .datapath_out(datapath_out),
    .Z_out(Z_out),
    .N_out(N_out),
    .V_out(V_out)
  );


  //addresses 
`define R0 3'b000
`define R1 3'b001
`define R2 3'b010
`define R3 3'b011
`define R4 3'b100
`define R5 3'b101
`define R6 3'b110
`define R7 3'b111

//for us, 
//alu ops
`define ADD 2'b00
`define SUB 2'b01
`define AND 2'b10
`define NOT 2'b11

//mov op
`define MOV_IMM 2'b10
`define MOV_SH 2'b00

//define shifter operations
`define no_shift          2'b00
`define left_shift        2'b01
`define log_right_shift   2'b10
`define arith_right       2'b11

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

task setzeros;
  pc = 8'b0;
  mdata = 16'b0;
endtask

//add R5, R2, R3 w no shift
task loadRF_A;
  sximm8    = 16'b0000000000000001;
  wb_sel = 2'b10;
  w_addr = `R2;
  r_addr = `R2;
  w_en = 1'b1;
  en_A = 1'b1;
  en_B = 1'b0;
endtask

task loadRF_B;
  sximm8    = 16'b0000000000000011;
  wb_sel = 2'b10;
  //#5;
  w_addr = `R2;
  r_addr = `R2;
  #5;
  w_en = 1'b1;
  //#5;
  en_A = 1'b0;
  en_B = 1'b1;
endtask

 task computation;
  
  en_A      = 1'b0;
  en_B      = 1'b0;
  shift_op  = `no_shift;
  #5;
 
  sel_A     = 1'b0;     //ensure left ALU input comes from register A
  sel_B     = 1'b0;     //same w B
  ALU_op    = `ADD;
  
  en_C      = 1'b1;     //update C to result of ALU
  en_status = 1'b1;     //make status register update
  w_en      = 1'b0;     
 endtask

 task write;
  en_A      = 1'b0;    //all the enables except for RF enable set to 0
  en_B      = 1'b0;
  en_C      = 1'b0;
  en_status = 1'b0;
  w_en      = 1'b0;
  wb_sel    = 2'b10;
  w_addr    = `R5;     //writing into R5
 endtask

//////////////////////////////////////////////

 task loadRF_A2;
  sximm8    = 16'b0000000000000001;
  wb_sel = 2'b10;
  w_addr = `R2;
  r_addr = `R2;
  w_en = 1'b1;
  en_A = 1'b1;
  en_B = 1'b0;
endtask


task loadRF_B2;
  sximm8    = 16'b0000000000000011;
  wb_sel = 2'b10;
  w_addr = `R2;
  r_addr = `R2;
  #5;
  w_en = 1'b1;
  en_A = 1'b0;
  en_B = 1'b1;
endtask

 task computation2;
  
  en_A      = 1'b0;
  en_B      = 1'b0;
  shift_op  = `left_shift;
  #5;
 
  sel_A     = 1'b0;     //ensure left ALU input comes from register A
  sel_B     = 1'b0;     //same w B
  ALU_op    = `SUB;
  
  en_C      = 1'b1;     //update C to result of ALU
  en_status = 1'b1;     //make status register update
  w_en      = 1'b0;     
 endtask
////////////////////////////////////////////////////////////
 task loadRF_A3;
  sximm8    = 16'b0000000000000111;
  wb_sel = 2'b10;
  w_addr = `R4;
  r_addr = `R4;
  w_en = 1'b1;
  en_A = 1'b1;
  en_B = 1'b0;
endtask


task loadRF_B3;
  sximm8    = 16'b1000000000011111;
  wb_sel = 2'b10;
  w_addr = `R4;
  r_addr = `R4;
  #5;
  w_en = 1'b1;
  en_A = 1'b0;
  en_B = 1'b1;
endtask

 task computation3;
  
  en_A      = 1'b0;
  en_B      = 1'b0;
  shift_op  = `arith_right;
  #5;
 
  sel_A     = 1'b0;     //ensure left ALU input comes from register A
  sel_B     = 1'b0;     //same w B
  ALU_op    = `NOT;
  
  en_C      = 1'b1;     //update C to result of ALU
  en_status = 1'b1;     //make status register update
  w_en      = 1'b0;     
 endtask
/////////////////////////////////////////////////////
task loadRF_A4;
  sximm8    = 16'b0000000000000111;
  wb_sel = 2'b10;
  w_addr = `R4;
  r_addr = `R4;
  w_en = 1'b1;
  en_A = 1'b1;
  en_B = 1'b0;
endtask

task loadRF_B4;
  sximm8    = 16'b1000000000011111;
  wb_sel = 2'b10;
  w_addr = `R4;
  r_addr = `R4;
  #5;
  w_en = 1'b1;
  en_A = 1'b0;
  en_B = 1'b1;
endtask

 task computation4;
  
  en_A      = 1'b0;
  en_B      = 1'b0;
  shift_op  = `log_right_shift;
  #5;
 
  sel_A     = 1'b0;     //ensure left ALU input comes from register A
  sel_B     = 1'b0;     //same w B
  ALU_op    = `AND;
  
  en_C      = 1'b1;     //update C to result of ALU
  en_status = 1'b1;     //make status register update
  w_en      = 1'b0;     
 endtask

 ////////////////////////////////////////
 task loadRF_A5;
  sximm8    = 16'b0000000000000111;
  wb_sel = 2'b10;
  w_addr = `R4;
  r_addr = `R4;
  w_en = 1'b1;
  en_A = 1'b1;
  en_B = 1'b0;
endtask

task loadRF_B5;
  sximm8    = 16'b1000000000011111;
  wb_sel = 2'b10;
  w_addr = `R4;
  r_addr = `R4;
  #5;
  w_en = 1'b1;
  en_A = 1'b0;
  en_B = 1'b1;
endtask

 task computation5;
  
  en_A      = 1'b0;
  en_B      = 1'b0;
  shift_op  = `no_shift;
  #5;
 
  sel_A     = 1'b0;     //ensure left ALU input comes from register A
  sel_B     = 1'b0;     //same w B
  ALU_op    = `AND;     //shouldn't matter
  
  en_C      = 1'b1;     //shouldn't matter
  en_status = 1'b1;     //shouldn't matter
  w_en      = 1'b0;    
 endtask


//can't check internal signals so gotta look at inputs/outputs of regfile, alu, and shifter
initial begin
  #7;

  setzeros;
  #5;

  loadRF_A;
  #15;

  loadRF_B;
  #15;

  computation; //addition, no shift
  #10;

  write;
  #10;

  $display("======ADDITION, NO SHIFT========");
  assert (datapath_out === 16'b0000000000000100) begin
    $display("[PASS] - datapath_out = %b", datapath_out);
  end else begin
    $error("[FAIL] - datapath_out is %b, expected %b", datapath_out, 16'b0000000000000111);
    error = 1;
    error_count = error_count + 1;
  end
  
  #15;

  loadRF_A2;
  #15;

  loadRF_B2;
  #15;


  computation2; //subtraction, left shift
  #10;

  write;
  #10;  

  $display("======SUBTRACTION, LEFT SHIFT========");
  assert (datapath_out === 16'b1111111111111011) begin
    $display("[PASS] - datapath_out = %b", datapath_out);
  end else begin
    $display("[FAIL] - datapath_out is %b, expected %b", datapath_out, 16'b1111111111111011);
    error = 1;
    error_count = error_count + 1;
  end

  #15;

  loadRF_A3;
  #15;

  loadRF_B3;
  #15;


  computation3; //negation, arith right
  #10;

  write;
  #10;  
  
  $display("======NEGATION, ARITH RIGHT========");
  assert (datapath_out === 16'b0011111111110000) begin
    $display("[PASS] - datapath_out = %b", datapath_out);
  end else begin
    $error("[FAIL] - datapath_out is %b, expected %b", datapath_out, 16'b0011111111110000);
    error = 1;
    error_count = error_count + 1;
  end

  #15;

  loadRF_A4;
  #15;

  loadRF_B4;
  #15;


  computation4; //and, log right
  #10;

  write;
  #10;  

   $display("======AND, LOG RIGHT========");
  assert (datapath_out === 16'b0000000000000111) begin
    $display("[PASS] - datapath_out = %b", datapath_out);
  end else begin
    $error("[FAIL] - datapath_out is %b, expected %b", datapath_out, 16'b1011111111110111);
    error = 1;
    error_count = error_count + 1;
  end

//
#15;

  loadRF_A5;
  #15;

  loadRF_B5;
  #15;


  computation5; //mov imm
  #10;

  write;
  #10;  

   $display("======MOV IMMEDIATE========");
  assert (datapath_out === 16'b0000000000000111) begin
    $display("[PASS] - datapath_out = %b", datapath_out);
  end else begin
    $error("[FAIL] - datapath_out is %b, expected %b", datapath_out, 16'b1011111111110111);
    error = 1;
    error_count = error_count + 1;
  end




  
  assert (error_count === 1'b0) begin
    $display("ALL TESTS PASSED");
  end else begin
    $display("%d tests failed", error_count);
  end

end

endmodule: tb_datapath
