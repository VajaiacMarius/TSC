/***********************************************************************
 * A SystemVerilog RTL model of an instruction regisgter
 *
 * An error can be injected into the design by invoking compilation with
 * the option:  +define+FORCE_LOAD_ERROR
 *
 **********************************************************************/


/* O functie check_res in care luam rezultatu received din dut cu rezultatul expected din test dar nu facem cum face dutu
sau cu if else si la urma dupa tot if else punem un alt if separat si care trebuie sa faca comparatie intre rez calculcat de mn si cel primit, functia void,mesajul e cu $display ,trebuie adaugate multe printuri si sa afiseze pass/fail in functie de cum merge*/
module instr_register
import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
(input  logic          clk,
 input  logic          load_en,
 input  logic          reset_n,
 input  operand_t      operand_a,
 input  operand_t      operand_b,
 input  opcode_t       opcode,
 input  address_t      write_pointer,
 input  address_t      read_pointer,
 output instruction_t  instruction_word
); // input nu se modifica
  timeunit 1ns/1ns;

  instruction_t  iw_reg [0:31];  // an array of instruction_word structures

  // write to the register
  always@(posedge clk, negedge reset_n)   // write into register 
    if (!reset_n) begin
      foreach (iw_reg[i])
        iw_reg[i] = '{opc:ZERO,default:0};  // reset to all zeros 
    end
    else if (load_en) begin 
      case (opcode)
        ZERO: iw_reg[write_pointer] = '{opcode,operand_a,operand_b, 'b0}; //rezultatul este setat la 0
        PASSA: iw_reg[write_pointer] = '{opcode,operand_a,operand_b, operand_a}; //rezultatul este operandul A
        PASSB: iw_reg[write_pointer] = '{opcode,operand_a,operand_b, operand_b};//rezultatul este operandul B
        ADD: iw_reg[write_pointer] = '{opcode,operand_a,operand_b, operand_a + operand_b};
        SUB: iw_reg[write_pointer] = '{opcode,operand_a,operand_b, operand_a - operand_b};
        MULT: iw_reg[write_pointer] = '{opcode,operand_a,operand_b, operand_a * operand_b};
        DIV:begin 
        if(operand_b == 0) begin
            iw_reg[write_pointer] <= '{opcode, operand_a, operand_b, 0};
        end else begin
        iw_reg[write_pointer] = '{opcode,operand_a,operand_b, operand_a / operand_b}; end
        end
        MOD:if(operand_b == 0) begin
            iw_reg[write_pointer] <= '{opcode, operand_a, operand_b, 0};
        end else begin
         iw_reg[write_pointer] = '{opcode,operand_a,operand_b, operand_a % operand_b};  
        end
      endcase 
    end

  // read from the register
  assign instruction_word = iw_reg[read_pointer];  // continuously read from register

// compile with +define+FORCE_LOAD_ERROR to inject a functional bug for verification to catch
`ifdef FORCE_LOAD_ERROR
initial begin
  force operand_b = operand_a; // cause wrong value to be loaded into operand_b
end
`endif

endmodule: instr_register