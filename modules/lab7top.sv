module lab7top (input clk, input rst_n, input [7:0] start_pc, output[15:0] out, output waiting, output N, output V, output Z);


//signals not in port declaration 
reg [15:0] ram_r_data;
//reg waiting;
//reg N;
//reg V;
//reg Z;

reg ram_w_en;
reg [7:0] ram_r_addr;
reg [7:0] ram_w_addr;
reg [15:0] ram_w_data;
reg [7:0] ram_addr;

cpu U3(clk, rst_n, start_pc, ram_r_data,
        waiting, out, ram_w_data, N, V, Z, ram_addr, ram_w_en);

ram U4(clk, ram_w_en, ram_addr, ram_addr,
        ram_w_data, ram_r_data);

endmodule: lab7top

module cpu(input clk, input rst_n, input [7:0] start_pc, input [15:0] ram_r_data,
           output waiting, output [15:0] out, output [15:0] ram_w_data, output N, output V, output Z, output [7:0] ram_addr, output ram_w_en);

/*instruction register:
receives instruction on instr bus load which i think is like the status.. as in 
yes you may now load the instruction
*/

/* old port declaration:
(input clk, input rst_n, input load, input start, input [15:0] instr,
           output waiting, output [15:0] out, output N, output V, output Z);

    CHANGES:
        - load internal now, comes from FSM
        - start is specifically start_pc
        - instruction now comes from RAM as ram_r_data

*/



/*
*************NOTES************
    IR: instr now comes from ram_r_data instead of the oblivion, enable comes from FSM
    DAR: data address register
        - input is datapath_out[7:0]
        - keeps the address that ldr and str will use (the m thing)
        - enable comes from FSM (load_addr) - updates when m thing changes i guess
    RAM: 
        - ram_w_addr (which is the same as ram_r_addr) can come from either the DAR (sel_addr is 0)
          or from the pc
        - fetching instructions: address comes from pc
        - load data: address comes from DAR

    DATAPATH:
        - pc and mdata are actual things now
        - output is copied onto external out port
    
    PC: a register storing address of NEXT instruction to be fetched; include in cpu, enable signal from here
        - when load is enabled, PC can either update to PC + 1 or to the address on start_pc (force restart kinda?) 
            


*/

//signals not in port declaration
reg [15:0] ir;
reg [1:0] reg_sel;
reg [2:0] opcode;
reg [1:0] ALU_op;
reg [15:0] sximm5;
reg [15:0] sximm8;
reg [2:0] r_addr;
reg [2:0] w_addr;

reg [1:0] shift_op;

reg [1:0] wb_sel;
reg w_en;
reg en_A;
reg en_B;
reg en_C;
reg en_status;
reg sel_A;
reg sel_B;

reg [15:0] mdata;
reg [7:0] pc;

//lab 7 new
reg load_ir;
//reg load_addr;
reg sel_addr;
reg load_pc;
reg clear_pc;
//reg ram_w_en;

reg [15:0] datapath_out;

//reg [15:0] ram_r_data;

reg load_addr;
reg [7:0] data_addr;
reg [7:0] next_pc;
reg [7:0] pc_addr;
//reg [7:0] start_pc;
//reg [7:0] ram_addr;
assign ram_w_data = datapath_out;


//instruciton decoder - dont think anything changes on the inside
idecoder U0(ir, reg_sel, 
            opcode, ALU_op, shift_op, sximm5, sximm8, r_addr, w_addr);

//controller fsm - last row is new inputs
controller7 U1(clk, rst_n, opcode, ALU_op, shift_op,
              waiting, reg_sel, wb_sel, w_en, en_A, en_B, en_C, en_status, sel_A, sel_B,
              load_ir, load_addr, sel_addr, load_pc, clear_pc, ram_w_en);

//modified datapath - extra out, mdata and pc are not just zero
datapath U2( clk, ram_r_data, pc, wb_sel, w_addr,  w_en, r_addr,  en_A, en_B, shift_op, sel_A, sel_B, ALU_op, en_C, en_status, sximm8, sximm5,
            datapath_out, out, Z, N, V);

//instruction register - instr is now specifically ram_r_data 
DFFe_16 inst_reg(clk, load_ir, ram_r_data, ir);

//data address register
DFFe_8 DAR(clk, load_addr, datapath_out[7:0], data_addr);

//program counter register
DFFe_8 PC(clk, load_pc, next_pc, pc);

//PC mux - next address or start pc address
mux_8 PC_control(start_pc, {pc + 1'b1}, clear_pc, next_pc);

//mux after DAR before RAM - which address to write to RAM
mux_8 ram_AddrControl(pc, data_addr, sel_addr, ram_addr);

endmodule: cpu



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

module idecoder(input [15:0] ir, input [1:0] reg_sel,
                output [2:0] opcode, output [1:0] ALU_op, output [1:0] shift_op,
		output [15:0] sximm5, output [15:0] sximm8,
                output [2:0] r_addr, output [2:0] w_addr);
 
 //takes input from instruction register and spits out most of it again, but sign extending imm5 and imm8
 //to 16 bits (ie turns into sximm5 and sximm8) and chooses what goes into r_addr and w_addr based on 
 //reg_sel from FSM
        reg [2:0] out;
        
        assign opcode = ir[15:13];
        assign ALU_op = ir[12:11];
        assign shift_op = ir[4:3];

        mux_3 regselmux(ir[10:8], ir[7:5], ir[2:0], reg_sel, out);
        assign r_addr = out;
        assign w_addr = out;

        assign sximm5 = {{11{ir[4]}},ir[3:0]};
        assign sximm8 = {{8{ir[7]}},ir[7:0]};



endmodule: idecoder

module mux_3(input wire [2:0] Rn_in, input wire [2:0] Rd_in, input wire [2:0] Rm_in, input reg [1:0] selection_FSM, output reg [2:0] out);
 //reg r_out_reg;
 //reg w_out_reg;

  //assign addr_r = r_out_reg;
  //assign addr_w = w_out_reg;
  
  
  always @(*) begin //confirm
   case(selection_FSM) 
        2'b00: out <= Rm_in;
        2'b01: out <= Rd_in;
        2'b10: out <= Rn_in;
        default: out <= 3'bx;
   endcase
  end
   
endmodule: mux_3


//************REGISTERS*************//

//one input 16 bit flip flop with enable - a and b registers
module DFFe_16(input clk, input en, input [15:0] D, output reg[15:0] Q);
  always @(posedge clk) begin
    if (en) begin
      Q <= D;
    end
  end
endmodule: DFFe_16


//one input 3 bit flip flop with enable
module DFFe_3(input clk, input en, input [2:0] D, output reg [2:0]Q);
  always @(posedge clk) begin
    if (en) begin
      Q <= D;
    end
  end
endmodule: DFFe_3

//one input 8 bit flip flop with enable
module DFFe_8(input clk, input en, input [7:0] D, output reg [7:0]Q);
  always @(posedge clk) begin
    if (en) begin
      Q <= D;
    end
  end
endmodule: DFFe_8

//*************MUXES************//

//default two options

//two option 16 bit mux
module mux_16(input [15:0] option_1, input [15:0] option_2, input selection, output reg[15:0] out);
   always @(*) begin //confirm
   case(selection) 
        1'b0: out <= option_2;
        1'b1: out <= option_1;
        default: out <= 16'bx;
   endcase
  end
endmodule: mux_16

//two option 8 bit mux
module mux_8(input [7:0] option_1, input [7:0] option_2, input selection, output reg[7:0] out);
   always @(*) begin //confirm
   case(selection) 
        1'b0: out <= option_2;
        1'b1: out <= option_1;
        default: out <= 8'bx;
   endcase
  end
endmodule: mux_8


//three option mux
module mux_writeback(input [15:0] option_1, input [15:0] option_2, input [15:0] option_3, input [15:0] option_4, input [1:0] selection, output reg [15:0] out);
 always @(*) begin //confirm
   case(selection) 
        2'b00: out <= option_1;
        2'b01: out <= option_2;
        2'b10: out <= option_3;
        2'b11: out <= option_4;
        default: out <= 16'bx;
   endcase
  end
endmodule: mux_writeback

module datapath(input clk, input [15:0] mdata, input [7:0] pc, input [1:0] wb_sel,
                input [2:0] w_addr, input w_en, input [2:0] r_addr, input en_A,
                input en_B, input [1:0] shift_op, input sel_A, input sel_B,
                input [1:0] ALU_op, input en_C, input en_status,
		            input [15:0] sximm8, input [15:0] sximm5,
                output [15:0] datapath_out, output [15:0] out,output Z_out, output N_out, output V_out);
  // your implementation here
  
//***************INPUTS/OUTPUTS***************//
//          clk: clock
//          (REMOVED)datapath_in-----
//           **(NEW) mdata: set to zero, can ignore for now
//           **(NEW) pc: set to zero, can ignore for now
//          wb_sel: tells first mux that input is coming from c, not datapath_in
//          w_addr: indicates where result should be stored
//          w_en: (write) 0 until we actually have something to write into RF
//          r_addr:  indicates where to read info from
//          en_A: 1 when we want to update register A (for register with enable)
//          en_B: 1 when we want to update register B (for register with enable)
//          shift_op: (shift) input to shifter, which operation
//          sel_A: 0 to ensure that the left ALU input comes from reg A (not really sure why necessary)
//          sel_B: same dealio
//          ALU_op: input to ALU, which operation
//          en_C: 1 when we want to update register C (when we are capturing result)
//          en_status: ??? this is z_out: 1 only when the output ALU_out is equal to 0
//           **(NEW) sximm8: decoded instruction 
//           **(NEW) sximm5: input to mux B instead of {11'b0, datapath_in[4:0]} (still constant)

//          datapath_out: 16 bit output
//          Z_out: 1 only when the output ALU_out is equal to 0
//           **(NEW) N_out: 1 only when output ALU_out is negative
//           **(NEW) V_out:                   ''          overflow
  

/*
            LAB 7 UPDATES
     DATAPATH:
    - pc and mdata are actual things now
    - output is copied onto external out port (added in declaration)

*/

//********************MODULE INSTANTIATIONS*******************//
  //reg clk, w_en;
  reg [15:0] w_data;
  //input [2:0] w_addr;
  //input [2:0] r_addr;

  reg [15:0] shift_in;
  //input [1:0] shift_op;

  reg [15:0] val_A;
  reg [15:0] val_B;
  //input [1:0] ALU_op;
  
  assign out = datapath_out;

 
  reg [15:0] r_data;
  reg [15:0] shift_out;
  reg [15:0] ALU_out;
  reg [2:0] Z;

  wire [15:0] A_out; 
  //wire [15:0] B_out;

//storage flip flops
  DFFe_16 A(clk, en_A, r_data, A_out);
  DFFe_16 B(clk, en_B, r_data, shift_in);
  DFFe_16 C(clk, en_C, ALU_out, datapath_out);
  DFFe_3 status(clk, en_status, Z, {Z_out,N_out,V_out});

//muxF
  mux_16 a_select(16'b0, A_out, sel_A, val_A);
  mux_16 b_select(sximm5, shift_out, sel_B, val_B);
  mux_writeback writeback(datapath_out, {8'b0,pc}, sximm8, mdata, wb_sel, w_data); 

//my modules
  regfile U0(clk, w_data, w_addr, w_en, r_addr, r_data); 
  shifter U1(shift_in, shift_op, shift_out);
  ALU U2(val_A, val_B, ALU_op, ALU_out, Z);

endmodule: datapath


//this stuff is in foundationalstoof now 

/*module DFFe_1(input clk, input en, input [15:0] D, output reg[15:0] Q);
  always @(posedge clk) begin
    if (en) begin
      Q <= D;
    end
  end
endmodule: DFFe_1

module DFFe_2(input clk, input en, input [2:0] D, output reg [2:0]Q);
  always @(posedge clk) begin
    if (en) begin
      Q <= D;
    end
  end
endmodule: DFFe_2




module mux(input [15:0] option_1, input [15:0] option_2, input selection, output reg[15:0] out);
   always @(*) begin //confirm
   case(selection) 
        2'b0: out <= option_2;
        2'b1: out <= option_1;
        default: out <= 16'bx;
   endcase
  end
endmodule: mux




module mux_writeback(input [15:0] option_1, input [15:0] option_2, input [15:0] option_3, input [15:0] option_4, input [1:0] selection, output reg [15:0] out);
 always @(*) begin //confirm
   case(selection) 
        2'b00: out <= option_1;
        2'b01: out <= option_2;
        2'b10: out <= option_3;
        2'b11: out <= option_4;
        default: out <= 16'bx;
   endcase
  end
endmodule: mux_writeback
*/



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
