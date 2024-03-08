module controller7(input clk, input rst_n, /*input start*/
                  input [2:0] opcode, input [1:0] ALU_op, input [1:0] shift_op,
                  output waiting,
                  output [1:0] reg_sel, output [1:0] wb_sel, output w_en,
                  output en_A, output en_B, output en_C, output en_status,
                  output sel_A, output sel_B,
                  
                  //new things
                  output load_ir, output load_addr, output sel_addr, output load_pc, output clear_pc,
                  output ram_w_en);
  // your implementation here
  //FSM
  /*
            ******INPUTS*****
            clk
            rst_n - active-low; when activated, fsm is in waiting state until start
            start
            opcode - 3 bits from instruction `decoder
            ALU_op - 2 bitsfrom instruction `decoder
            shift_op - from instruction `decoder
            Z - zero status from datapath... not in picture though
            N - negative from datapath...
            V - overflow from datapth...

          *****OUTPUTS*****
            waiting - output before starting
            reg_sel - to tell instruction `decoder which instruction 
            wb_sel - input to datapath saying to receive input not from datapath_in (confirm)
            w_en - status inputs to datapath
            en_A - ''
            en_B - ''
            en_C - ''
            en_status - ''
            sel_A - ''
            sel_B - ''

        ************NEW*********
            load_ir: ir enable basically, al`ready a thing in the ir
            load_addr: DAR enable
            sel_addr: decides what goes to ram_`addr - 8 bits from pc or 8 bits from dar
            load_pc: enable for pc
            clear_pc: decides if next_pc is start_pc or the last pc value + 1
            ram_w_en: ram enable 
        
        *******NOTES********
            PC: a register storing `address of NEXT instruction to be fetched; include in cpu, enable signal from here
                - when load is enabled, PC can either update to PC + 1 or to the `address on start_pc (force restart kinda?) 
            IR: see cpu.7 for changes
            DAR: see cpu.7 for changes

  */

//state registers
  reg [4:0] State; //do one for each instruction
  reg [4:0] NextState;

//registers for always block
  //reg waitingReg;
  reg [1:0] reg_selReg;
  reg [1:0] wb_selReg;
  reg w_enReg;
  reg en_AReg;
  reg en_BReg;
  reg en_CReg;
  reg en_statusReg;
  reg sel_AReg;
  reg sel_BReg;

  

  //assign waiting = waitingReg;
  assign reg_sel = reg_selReg;
  assign wb_sel = wb_selReg;
  assign w_en = w_enReg;
  assign en_B = en_BReg;
  assign en_C = en_CReg;
  assign en_A = en_AReg;
  assign en_status = en_statusReg;
  assign sel_A = sel_AReg;
  assign sel_B = sel_BReg;

  //new stuff
  reg load_irReg;
  reg load_addrReg;
  reg sel_addrReg;
  reg load_pcReg;
  reg clear_pcReg;
  reg ram_w_enReg;

  assign load_ir = load_irReg;
  assign load_addr = load_addrReg;
  assign sel_addr = sel_addrReg;
  assign load_pc = load_pcReg;
  assign clear_pc = clear_pcReg;
  assign ram_w_en = ram_w_enReg;





//Rn: reg A
//Rm: reg B
//Rd: reg C

  `define sel_Rd 2'b01
  `define sel_Rm 2'b00
  `define sel_Rn 2'b10
  
  //************STATES************//
 // enum reg [3:0] {
    `define ready3  5'b00000
   
    `define ready 5'b10101


    `define loadA 5'b00010
    `define ready2 5'b10110
    `define loadB 5'b00011
    `define mov_shift 5'b00100
    `define add 5'b00101
    `define cmp 5'b00110
    `define ands 5'b00111
    `define mvn 5'b01000
    `define write 5'b01001
    //lab 7 stuff
    `define halt 5'b11111
    `define memory_compute 5'b01011
    `define memory_store 5'b01100
    `define strLoadA 5'b01101
    `define strLoadB 5'b01110
    `define strCompute 5'b01111
    `define strWrite 5'b10000
    `define memory_write 5'b10001
    `define ldr 5'b10010
    `define strRFwrite 5'b10011
    `define strAddNothing 5'b10100

    `define reset 5'b11001
    `define updatePC 5'b10111
    `define decode 5'b00001
    `define getAddr 5'b11000
    `define movimm 5'b11100
    `define error 5'b11101
    //also changed waits to `halt
    
 // } state;




  always_ff@(posedge clk) begin
    if(~rst_n) begin
        State <= `ready;
        NextState <= `ready;
        sel_addrReg <= 1'b1;         //after `reset, instruction should come from start_pc
        wb_selReg <= 2'b01;
        clear_pcReg <= 1'b1;         //making sure start_pc is `address on pc
        load_irReg <= 1'b1;          //allowing IR to load instruction
        load_pcReg <= 1'b1;          //update PC
         reg_selReg <= 2'b00;
         w_enReg <= 1'b0;
    end else begin 
        //sel_addrReg <= 1'b0;   
       clear_pcReg <= 1'b0;    //next instruction will be from `address n + 1
        //wb_selReg <= 2'b11;
       // load_pcReg <= 1'b1;
       

      case(State)
        
         `halt: begin
            NextState <= `halt; //chills here til rst
          end

          `error: begin
            NextState <= `error;
          end

          `ready: begin
            NextState <= `updatePC; //gotta give something to the datapath
            load_pcReg <= 1'b0;
            load_irReg <= 1'b1;
            ram_w_enReg <= 1'b1;
            wb_selReg <= 2'b11;
            //clear_pcReg <= 1'b0; //next pc
          end
                
          
          `reset: begin
            NextState <= `ready2; //gotta give something to the datapath
            load_pcReg <= 1'b1;
            load_irReg <= 1'b1;
            ram_w_enReg <= 1'b1;
            wb_selReg <= 2'b11;
            //clear_pcReg <= 1'b0; //next pc
          end

          `ready2: begin
            load_pcReg <= 1'b0;
            NextState <= `ready3;
          end

          `ready3: begin
            
            NextState <= `updatePC;
          end

          `updatePC: begin
           // reg_selReg <= 2'b00;
            NextState <= `decode;
            load_irReg <= 1'b0; //done 
            ram_w_enReg <= 1'b0;
            load_pcReg <= 1'b0;
          end
            

          `decode: begin 
             // load_irReg <= 1'b1;
              load_pcReg <= 1'b0; //done 
              //load_irReg <= 1'b0;
                if ({opcode, ALU_op} ==  5'b11000 | {opcode, ALU_op} == 5'b10111) begin //if movsh or `mvn
                        NextState <= `loadB;
                end else if({opcode, ALU_op} == 5'b11010) begin  //if mov immediate

                        NextState <= `movimm;
                end else if (opcode == 3'b111) begin
                    NextState <= `halt;
                //end else if (opcode == 3'bxxx) begin
                  //NextState <= `error;
                end else begin
                        NextState <= `loadA;
                end
          end

          `movimm: begin
                        reg_selReg <= `sel_Rn;
                        //en_AReg <= 1'b1;
                        w_enReg <= 1'b1;
                        wb_selReg <= 2'b10; //taking im8 in wb
                        //load_pcReg <= 1'b1;
                        //ram_w_enReg <= 1'b1; //assert memory enable
                        load_pcReg <= 1'b0;
                        NextState <= `reset;
          end


          `loadA: begin //can only get here by being alu (but not `mvn) or the new ones
                    en_AReg <= 1'b1; //update A
                    en_BReg <= 1'b0; //not B
                    reg_selReg <= `sel_Rn; //selects A to `write to
                    NextState <= `loadB;
          end




          `loadB: begin
                    en_BReg <= 1'b1;
                    en_AReg <= 1'b0;
                    reg_selReg <= `sel_Rm;

                    if({opcode, ALU_op} == 5'b11000) begin //if mov shifted
                      NextState <= `mov_shift;
                    end else if ({opcode, ALU_op} == 5'b10100) begin //if `add
                      NextState <= `add;
                    end else if ({opcode, ALU_op} == 5'b10101) begin //if `cmp
                      NextState <= `cmp;
                    end else if ({opcode, ALU_op} == 5'b10110) begin //if and
                      NextState <= `ands;
                    end else if ({opcode, ALU_op} == 5'b10111) begin //if `mvn
                      NextState <= `mvn;
                    end else if (opcode == 3'b011 | opcode == 3'b100) begin //if `ldr/str
                      NextState <= `getAddr;
                    end else begin
                      //load_pcReg <= 1'b1;
                      //ram_w_enReg <= 1'b1; //assert memory enable
                      NextState <= `error;
                    end
          end

          `mov_shift: begin
                    en_BReg <= 1'b0; //done loading B
                    sel_AReg <= 1'b1; //zero for A
                    sel_BReg <= 1'b0; //shift out for B
                    en_CReg <= 1'b1; //`ready to update C
                    NextState <= `write;
          end

          `add: begin
                    en_BReg <= 1'b0;
                    sel_AReg <= 1'b0; //take a
                    sel_BReg <= 1'b0; //take shift out
                    en_CReg <= 1'b1; 
                    NextState <= `write;
          end

          `cmp: begin
                    en_BReg <= 1'b0;
                    sel_AReg <= 1'b0;
                    sel_BReg <= 1'b0;
                    en_statusReg <= 1'b1; 
                    load_pcReg <= 1'b1;
                    ram_w_enReg <= 1'b1; //assert memory enable
                    NextState <= `reset; //i dont think you actually need to `write anything into c so
          end

          `ands: begin
                    en_BReg <= 1'b0;
                    sel_AReg <= 1'b0;
                    sel_BReg <= 1'b0;
                    en_CReg <= 1'b1;
                    NextState <= `write;
          end

          `mvn: begin  
                  en_BReg <= 1'b0;
                  en_CReg <= 1'b1; 
                  sel_BReg <= 1'b0; //want shift out
                  sel_AReg <= 1'b1; //zero for a
                  NextState <= `write;    
          end

          `write: begin
                  reg_selReg <= `sel_Rd;
                  en_CReg <= 1'b0;
                  wb_selReg <= 2'b00; //taking datapath 
                  w_enReg <= 1'b1;
                  //load_pcReg <= 1'b1;
                  ram_w_enReg <= 1'b1; //assert memory enable
                  NextState <= `reset;
          end

          `getAddr: begin
            load_addrReg <= 1'b1;  //`ready to update dar
            sel_addrReg <= 1'b0; //using dar
           NextState <= `memory_compute;
          end


          `memory_compute: begin
                sel_BReg <= 1'b1; //taking sximm5
                sel_AReg <= 1'b1; //taking zero from a
                en_CReg <= 1'b1;

                NextState <= `memory_store;
          end

          `memory_store: begin
                en_CReg <= 1'b0; //done w c
                load_addrReg <= 1'b1; //enable dar to update
                w_enReg <= 1'b0; //dont want this output going to RF, just DAR

                if (opcode == 3'b011) begin //if `ldr
                    NextState <= `ldr;
                end else if (opcode == 3'b100) begin
                    NextState <= `strRFwrite;
                end
          end

          `ldr: begin
                reg_selReg <= `sel_Rd;
                en_CReg <= 1'b0; //back to zilch
                wb_selReg <= 2'b11; //choose mdata
                w_enReg <= 1'b1; //`write into Rf
                load_pcReg <= 1'b1;
                ram_w_enReg <= 1'b1; //assert memory enable
                NextState <= `reset;
          end

          `strRFwrite: begin //basically the same as `write, just with different next state
                wb_selReg <= 2'b00; //`write datapath_out into WB
                reg_selReg <= `sel_Rd;
                en_CReg <= 1'b0; //done w c
                w_enReg <= 1'b1; //want to udpdate RF
                NextState <= `strLoadA;
          end

          `strLoadA: begin  //same as `loadA but for easy tracking gonna call it str`LoadA
                en_AReg <= 1'b1; //update A
                en_BReg <= 1'b0; //not B
                reg_selReg <= `sel_Rn; //selects A to `write to
                NextState <= `strLoadB; 
          end

          `strLoadB: begin
                en_BReg <= 1'b1;
                en_AReg <= 1'b0;
                reg_selReg <= `sel_Rm;
                NextState <= `strAddNothing;
          end


          `strAddNothing: begin
                en_BReg <= 1'b0;
                sel_AReg <= 1'b0; //take a
                sel_BReg <= 1'b1; //take zero 
                en_CReg <= 1'b1; 
                NextState <= `memory_write;
          end

          `memory_write: begin
                ram_w_enReg <= 1'b1; //assert memory enable
                sel_addrReg <= 1'b0; //ram takng DAR `address
                load_pcReg <= 1'b1;
                NextState <= `reset;
          end

          default: begin
                  load_pcReg <= 1'b1;
                  NextState <= `reset;
          end

      endcase

      State <= NextState;
        
      
    end
    
  end

endmodule: controller7




  


