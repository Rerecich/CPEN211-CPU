module cpu(input clk, input rst_n, input [7:0] start_pc, input [15:0] ram_r_data,
           output waiting, output [15:0] out, output [15:0] ram_w_data, output N, output V, output Z, output [7:0] ram_addr, output ram_w_en);

/*instruction register:
receives instruction on instr bus load which i think is like the status.. like 
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



