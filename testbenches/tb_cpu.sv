module tb_cpu(output err);

  reg clk;
  reg rst_n;
  reg load;
  reg start;
  reg [15:0] instr;

  reg waiting;
  reg [15:0] out;
  reg N;
  reg V;
  reg Z;

  integer error = 0;
  integer error_count = 0;
  assign err = error;

  cpu dut(
    .clk(clk),
    .rst_n(rst_n),
    .load(load),
    .start(start),
    .instr(instr),

    .waiting(waiting),
    .out(out),
    .N(N),
    .V(V),
    .Z(Z)
  );

  task neutral;
    rst_n = 1'b1; //rst is active low so this is the waiting state
    load = 1'b0;
    start = 1'b0;
    instr = 16'bx;
  endtask

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end


  initial begin
    #7;

    $display("==========NEUTRAL STATE=============");
    neutral;
    #5;

    assert(waiting == 1'b1) begin
      $display("[PASS] - Nothing has happened, waiting activated");
    end else begin
      $error("[FAIL] - %s is %d, expected %d.", "waiting", waiting, 1'b1);
      error = 1;
      error_count = error_count + 1;
    end

    //

    $display("=========RST BUT NO START=============");
    rst_n <= 1'b0;
    start <= 1'b0;
    #5;

    assert(waiting == 1'b1) begin
      $display("[PASS] - Nothing has happened, waiting activated");
    end else begin
      $error("[FAIL] - %s is %d, expected %d.", "waiting", waiting, 1'b1);
      error = 1;
      error_count = error_count + 1;
    end
  
  //

    $display("=========RST W START=============");
    rst_n <= 1'b1;
    start <= 1'b1;
    #10;

    assert(waiting == 1'b0) begin
      $display("[PASS] - Start pressed, waiting deactivated.");
    end else begin
      $error("[FAIL] - %s is %d, expected %d.", "waiting", waiting, 1'b0);
      error = 1;
      error_count = error_count + 1;
    end


  $display("=========INSTR NO LOAD=============");
  instr = 16'b1101000000000001; //aka mov imm MOV R0, immediate by 1

    $display("CHECK - Output is %b, expected xxxxxxxxxxxxxxxx.", out);
    #5;
  

$display("=========TIMING MOV IMM=============");
    start = 1'b0;
    rst_n = 1'b0; //back to waiting
    #10;
    assert(waiting == 1'b1) begin
      $display("[PASS] - Nothing has happened, waiting activated");
    end else begin
      $error("[FAIL] - %s is %d, expected %d.", "waiting", waiting, 1'b1);
      error = 1;
      error_count = error_count + 1;
    end
    #3;

    rst_n = 1'b1;
    start = 1'b1; //stop waiting
    load = 1'b1; //load instruction (mov shift, should take four cycles?)
    #1;
    assert(waiting == 1'b0) begin
      $display("[PASS] - Computation occuring.");
    end else begin
      $error("[FAIL] - %s is %d, expected %d.", "waiting", waiting, 1'b0);
      error = 1;
      error_count = error_count + 1;
    end
    #11; //1 full clock cycle plus buffer


    start = 1'b0;
    
    assert(waiting == 1'b1) begin
      $display("[PASS] - Waiting activated.");
    end else begin
      $error("[FAIL] - %s is %d, expected %d.", "waiting", waiting, 1'b1);
      error = 1;
      error_count = error_count + 1;
    end
    
    $display("=========TIMING MOV SH=============");
    rst_n = 1'b0; //waiting
    #10;
    start = 1'b1;
    rst_n = 1'b1; //done waiting
    load = 1'b1;
    instr = 16'b1100000000010001; //MOV R0, R1 shifted left
    #9;
      assert(waiting == 1'b0) begin
      $display("[PASS] - Computation occuring.");
    end else begin
      $error("[FAIL] - %s is %d, expected %d.", "waiting", waiting, 1'b0);
      error = 1;
      error_count = error_count + 1;
    end

    #40;

    start = 1'b0;
    
    assert(waiting == 1'b1) begin
      $display("[PASS] - Waiting activated.");
    end else begin
      $error("[FAIL] - %s is %d, expected %d.", "waiting", waiting, 1'b1);
      error = 1;
      error_count = error_count + 1;
    end

     $display("=========TIMING LONG ALUS=============");
    rst_n = 1'b0; //waiting
    #8;
    start = 1'b1;
    rst_n = 1'b1; //done waiting
    load = 1'b1;
    instr = 16'b1010000000010001; //ADD
    #9;
      assert(waiting == 1'b0) begin
      $display("[PASS] - Computation occuring.");
    end else begin
      $error("[FAIL] - %s is %d, expected %d.", "waiting", waiting, 1'b0);
      error = 1;
      error_count = error_count + 1;
    end

    #50;

    start = 1'b0;
    
    assert(waiting == 1'b1) begin
      $display("[PASS] - Waiting activated.");
    end else begin
      $error("[FAIL] - %s is %d, expected %d.", "waiting", waiting, 1'b1);
      error = 1;
      error_count = error_count + 1;
    end



//and
    rst_n = 1'b0; //waiting
    #8;
    start = 1'b1;
    rst_n = 1'b1; //done waiting
    load = 1'b1;
    instr = 16'b1011000000010001; //ADD
    #9;
      assert(waiting == 1'b0) begin
      $display("[PASS] - Computation occuring.");
    end else begin
      $error("[FAIL] - %s is %d, expected %d.", "waiting", waiting, 1'b0);
      error = 1;
      error_count = error_count + 1;
    end

    #50;

    start = 1'b0;
    
    assert(waiting == 1'b1) begin
      $display("[PASS] - Waiting activated.");
    end else begin
      $error("[FAIL] - %s is %d, expected %d.", "waiting", waiting, 1'b1);
      error = 1;
      error_count = error_count + 1;
    end



    //mvn
    rst_n = 1'b0; //waiting
    #8;
    start = 1'b1;
    rst_n = 1'b1; //done waiting
    load = 1'b1;
    instr = 16'b1011100000010001; //mvn
    #9;
      assert(waiting == 1'b0) begin
      $display("[PASS] - Computation occuring.");
    end else begin
      $error("[FAIL] - %s is %d, expected %d.", "waiting", waiting, 1'b0);
      error = 1;
      error_count = error_count + 1;
    end

    #40;

    start = 1'b0;
    
    assert(waiting == 1'b1) begin
      $display("[PASS] - Waiting activated.");
    end else begin
      $error("[FAIL] - %s is %d, expected %d.", "waiting", waiting, 1'b1);
      error = 1;
      error_count = error_count + 1;
    end


  //and
    rst_n = 1'b0; //waiting
    #8;
    start = 1'b1;
    rst_n = 1'b1; //done waiting
    load = 1'b1;
    instr = 16'b1011000000010001; //and
    #9;
      assert(waiting == 1'b0) begin
      $display("[PASS] - Computation occuring.");
    end else begin
      $error("[FAIL] - %s is %d, expected %d.", "waiting", waiting, 1'b0);
      error = 1;
      error_count = error_count + 1;
    end

    #50;

    start = 1'b0;
    
    assert(waiting == 1'b1) begin
      $display("[PASS] - Waiting activated.");
    end else begin
      $error("[FAIL] - %s is %d, expected %d.", "waiting", waiting, 1'b1);
      error = 1;
      error_count = error_count + 1;
    end


    //cmp
    rst_n = 1'b0; //waiting
    #8;
    start = 1'b1;
    rst_n = 1'b1; //done waiting
    load = 1'b1;
    instr = 16'b1010100000010001; 
    #9;
      assert(waiting == 1'b0) begin
      $display("[PASS] - Computation occuring.");
    end else begin
      $error("[FAIL] - %s is %d, expected %d.", "waiting", waiting, 1'b0);
      error = 1;
      error_count = error_count + 1;
    end

    #35;

    start = 1'b0;
    
    assert(waiting == 1'b1) begin
      $display("[PASS] - Waiting activated.");
    end else begin
      $error("[FAIL] - %s is %d, expected %d.", "waiting", waiting, 1'b1);
      error = 1;
      error_count = error_count + 1;
    end

  



    




   /*  

    load = 1'b0;
    #10;

    assert(out == 1'b0) begin
      $display("[PASS] - Start pressed, waiting deactivated.");
    end else begin
      $error("[FAIL] - %s is %d, expected %d.", "waiting", waiting, 1'b0);
      error = 1;
      error_count = error_count + 1;
    end

*/



  //
  assert (error_count === 1'b0) begin
    $display("ALL TESTS PASSED");
  end else begin
    $display("%d tests failed", error_count);
  end

  end



endmodule: tb_cpu
