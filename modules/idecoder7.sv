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
