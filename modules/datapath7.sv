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


