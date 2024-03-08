
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

