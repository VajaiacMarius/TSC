/*************************!!!!  
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 ************************/

module instr_register_test
  import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
  (input  logic          clk,
   output logic          load_en,
   output logic          reset_n,
   output operand_t      operand_a,
   output operand_t      operand_b,
   output opcode_t       opcode,
   output address_t      write_pointer,
   output address_t      read_pointer,
   output result_t       result,
   input  instruction_t  instruction_word
  );//dut ul are output care merge in test


  timeunit 1ns/1ns;

  parameter WRITE_NUMBER = 50;
  parameter READ_NUMBER  = 50;
  parameter WRITE_ORDER = 2; // 0 = incremental, 1 = random, 2 = decremental
  parameter READ_ORDER = 1; // 0 = incremental, 1 = random, 2 = decremental
  

  int seed = 555;
  instruction_t  iw_test_reg [0:31]; 
    // Variabile pentru contoare
  int pass_count = 0;
  int fail_count = 0;


  initial begin
    $display("\n\n*********************");
    $display(    "*  THIS IS A SELF-CHECKING TESTBENCH (YET).  YOU  *");
    $display(    "*  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     *");
    $display(    "*  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  *");
    $display(    "*********************");

    $display("\nReseting the instruction register...");
    write_pointer  = 5'h00;         // 5 biti in hexazecimal si toate in zero
    read_pointer   = 5'h1F;         // initialize read pointer
    load_en        = 1'b0;          // initialize load control line
    reset_n       <= 1'b0;          // assert reset_n (active low)
    repeat (2) @(posedge clk) ;     // hold in reset for 2 clock cycles
    reset_n        = 1'b1;          // deassert reset_n (active low)

    $display("\nWriting values to register stack...");
    @(posedge clk) load_en = 1'b1;  // enable writing to register
    repeat (READ_NUMBER) begin 
      @(posedge clk) randomize_transaction;
      @(negedge clk) print_transaction;
      saveTestData;
    end
    @(posedge clk) load_en = 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    
    for (int i=0; i<  WRITE_NUMBER; i++) begin
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      @(posedge clk) read_pointer = i;
      @(negedge clk) print_results;
      checkResult;
    end
      final_report;
    @(posedge clk) ;
    $display("\n*********************");
    $display(  "*  THIS IS A SELF-CHECKING TESTBENCH (YET).  YOU  *");
    $display(  "* DON'T NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     *");
    $display(  "*  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  *");
    $display(  "*********************\n");
    $finish;
  end
//functie randomize_transaction--------------------
  function void randomize_transaction;
    static int temp_decremental = 31;
    static int temp = 0;

    case (WRITE_ORDER)
        0: write_pointer = write_pointer + 1; // Incremental order
        1: write_pointer = $unsigned($random) % 32; // Random order
        2: write_pointer = temp_decremental--; // Decremental order
        default: $display("Non-existent write order");
    endcase

    operand_a <= $random(seed) % 16;   
    operand_b <= $unsigned($random) % 16;  
    opcode <= opcode_t'($unsigned($random) % 8);  

    case (READ_ORDER)
        0: read_pointer = temp++; // Incremental order
        1: read_pointer = $unsigned($random) % 32; // Random order
        2: read_pointer = temp_decremental--; // Decremental order
        default: $display("Non-existent read order");
    endcase
endfunction: randomize_transaction

//functie print_transaction--------------------
  function void print_transaction;
    $display("Writing to register location %0d: ", write_pointer);
    $display("  opcode = %0d (%s)", opcode, opcode.name);
    $display("  operand_a = %0d",   operand_a);
    $display("  operand_b = %0d\n", operand_b);
  endfunction: print_transaction

//functie print_results--------------------
  function void print_results;
    $display("Read from register location %0d: ", read_pointer);
    $display("  opcode = %0d (%s)", instruction_word.opc, instruction_word.opc.name);
    $display("  operand_a = %0d",   instruction_word.op_a);
    $display("  operand_b = %0d", instruction_word.op_b);
    $display(" result_t = %0d\n", instruction_word.rezultat);
  endfunction: print_results

//functie checkResult--------------------
  function void checkResult;
  int exp_result;
  if( iw_test_reg[read_pointer].opc== instruction_word.opc)
    $display("Opcode is correct from register location %0d: ", read_pointer);
  else
    $display("Opcode is incorrect from register location %0d: ", read_pointer);

  if( iw_test_reg[read_pointer].op_a== instruction_word.op_a)
    $display("Operant_a is correct from register location %0d: ", read_pointer);
  else
    $display("Operant_a is incorrect from register location %0d: ", read_pointer);

  if( iw_test_reg[read_pointer].op_b== instruction_word.op_b)
      $display("Operant_b is correct from register location %0d: ", read_pointer);
    else
      $display("Operant_b is incorrect from register location %0d: ", read_pointer);

  case (iw_test_reg[read_pointer].opc)
    ZERO : exp_result = 0;
    ADD: exp_result = iw_test_reg[read_pointer].op_a + iw_test_reg[read_pointer].op_b;
    SUB: exp_result = iw_test_reg[read_pointer].op_a - iw_test_reg[read_pointer].op_b;
    PASSA: exp_result = iw_test_reg[read_pointer].op_a;
    PASSB: exp_result = iw_test_reg[read_pointer].op_b;
    MULT: exp_result = iw_test_reg[read_pointer].op_a * iw_test_reg[read_pointer].op_b;
    DIV:
         if(!iw_test_reg[read_pointer].op_b)
              exp_result = 0;
         else
              exp_result = iw_test_reg[read_pointer].op_a / iw_test_reg[read_pointer].op_b;
    MOD: if(!iw_test_reg[read_pointer].op_b)
              exp_result = 0;
         else
              exp_result = iw_test_reg[read_pointer].op_a % iw_test_reg[read_pointer].op_b;
    

  endcase


   // Compararea rezultatului așteptat cu rezultatul primit de la DUT
    if (exp_result == instruction_word.rezultat) begin
      $display("Result check: Approved");
      pass_count++; // Incrementăm contorul pentru operații reușite
    end else begin
      $display("Result check: Unapproved");
      fail_count++; // Incrementăm contorul pentru operații eșuate
    end
  endfunction:checkResult


  //functia saveTestData--------------------
  function void saveTestData;

  iw_test_reg[write_pointer] = '{opcode, operand_a,operand_b,0};
    $display("Read from register location %0d: ", write_pointer);
    $display("  opcode = %0d (%s)", iw_test_reg[write_pointer].opc, iw_test_reg[write_pointer].opc.name);
    $display("  operand_a = %0d",   iw_test_reg[write_pointer].op_a);
    $display("  operand_b = %0d", iw_test_reg[write_pointer].op_b);
  endfunction:saveTestData


//functie final report--------------------
  // Funcția final_report pentru afișarea rezumatului la sfârșit
  function void final_report;
    $display("\n--- FINAL REPORT ---");
    $display("Operations passed: %0d/%0d.", pass_count, WRITE_NUMBER);
    $display("Operations failed: %0d/%0d.", fail_count, WRITE_NUMBER);
  endfunction: final_report
endmodule: instr_register_test