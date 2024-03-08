module tb_regfile(output err);

//*************DUT INPUTS/OUTPUTS*************//
reg clk;

//w inputs
reg [15:0] w_data;
reg [2:0] w_addr;
reg w_en;

//r inputs/outputs
reg [2:0] r_addr;
reg [15:0] r_data;

//other - error?
integer error = 0;
integer error_count = 0;
assign err = error;

reg[2:0] test_address;
//***************INSTANTIATION**************//
regfile dut (
  .clk(clk),
  .w_data(w_data),
  .w_addr(w_addr),
  .w_en(w_en),
  .r_addr(r_addr),
  .r_data(r_data)
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

//alu ops
`define SUM 2'b00
`define SUB 2'b01
`define AND 2'b10
`define NOT 2'b11

//define shifter operations
`define no_shift          2'b00
`define left_shift        2'b01
`define log_right_shift   2'b10
`define arith_right       2'b11


initial begin
  clk = 1'b0;
  #5; //time to do not-rising-edge test
  forever #5 clk = ~clk;
end

//******************TESTS********************//

/*
test if r_data is equal to the value in register 
you're checking
*/
task setup_good;
//in order to check values inside registers, we gotta put some inside
//technically the datapath should do that but we'll set up some hard-coded ones
  w_data = 16'b0;
  w_addr = 3'b000;
  w_en = 1'b1;         
  r_addr = 3'b000;
endtask

//

task setup_bad;
  w_en = 1'b0; //nothing shalt be written
  w_data = 16'b1111111111111111;
  r_addr = 3'b000;
endtask

//

task before_clk;
  assert(r_data === 16'bxxxxxxxxxxxxxxxx) begin
    $display("[PASS] - data %b being read from register", w_data);
  end else begin 
    $error("[FAIL] - data read is %b, expected xxxxxxxxxxxxxxxx", r_data);
    error = 1;
    error_count = error_count + 1;
  end
endtask

//
task write_to_address(test_address);
  w_data = 16'b0000000000000001; //1 into register
  w_addr = test_address;
endtask

//
task check_register_output(test_address);
  r_addr = test_address;
  #5;
  
  assert(r_data === w_data) begin
    $display("[PASS] - data %b being read from register", w_data);
  end else begin 
    $error("[FAIL] - data read is %b, expected %b", r_data, w_data);
    error = 1;
    error_count = error_count + 1;
  end
endtask

task summary;
 assert(error === 0) begin
    $display("ALL TESTS PASSED");
  end else begin
    $error("%d tests failed", error_count);
  end
endtask

//
task check_every_register;
  write_to_address(`R0);
    #5;
  
    check_register_output(`R0);
    #5;
  
  //
    write_to_address(`R1);
    #5;
  
    check_register_output(`R1);
    #5;
  //
    write_to_address(`R2);
    #5;
  
    check_register_output(`R2);
    #5;
  //
    write_to_address(`R3);
    #5;
  
    check_register_output(`R3);
    #5;
  //
    write_to_address(`R4);
    #5;
  
    check_register_output(`R4);
    #5;
  //
    write_to_address(`R5);
    #5;
  
    check_register_output(`R5);
    #5;
  //
    write_to_address(`R6);
    #5;
  
    check_register_output(`R6);
    #5;
  //
    write_to_address(`R7);
    #5;
  
    check_register_output(`R7);
    #5;

endtask



initial begin
  before_clk;
  #6;
  //provide r_addr, value inside that register appears on r_data
  setup_good;
  #3;

  check_every_register;
  #5;

  setup_bad;
  #5;

  check_every_register;
  #5;

  summary;

  $stop;


end


endmodule: tb_regfile
