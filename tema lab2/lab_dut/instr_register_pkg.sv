/***********************************************************************
 * A SystemVerilog RTL model of an instruction regisgter:
 * User-defined type definitions
 **********************************************************************/
package instr_register_pkg;
  timeunit 1ns/1ns;

  typedef enum logic [3:0] {   // o enumeratie de tip logic, pe 4 biti, 16 stari
  	ZERO, //sa iasa doar zero
    PASSA, //iese A
    PASSB,
    ADD,
    SUB,
    MULT,
    DIV,
    MOD
  } opcode_t;
  
  
 typedef logic signed [31:0] operand_t;   //registru

  typedef logic signed [63:0] result_t; // 64 de biti, pentru * si /, pot sa genereze rezultate peste 32 de biti. Trunchierea 
  
  typedef logic [4:0] address_t;    //32 de adrese 
  
  typedef struct {
    opcode_t  opc;
    operand_t op_a;
    operand_t op_b; 
    result_t rezultat; // pentru * si /, se stocheaza valorile
  } instruction_t;
  
  
endpackage: instr_register_pkg