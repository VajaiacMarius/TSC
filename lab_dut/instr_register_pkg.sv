/***********************************************************************
 * A SystemVerilog RTL model of an instruction regisgter:
 * User-defined type definitions
 **********************************************************************/
package instr_register_pkg;
  timeunit 1ns/1ns;

  typedef enum logic [3:0] {   
  	ZERO, 
    PASSA, 
    PASSB,
    ADD,
    SUB,
    MULT,
    DIV,
    MOD
  } opcode_t;
  
  
 typedef logic signed [31:0] operand_t;   

  typedef logic signed [63:0] result_t; 
  //bitul de 63 reprezinta semnul
  // bitul se declara cu b si pui sa fie egal cu semn
  typedef logic [4:0] address_t;     
  
  typedef struct {
    opcode_t  opc;
    operand_t op_a;
    operand_t op_b; 
    result_t rezultat; 
  } instruction_t;
  
  
endpackage: instr_register_pkg