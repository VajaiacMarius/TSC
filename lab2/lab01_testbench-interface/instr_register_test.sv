/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/

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
   output result_t       rezultat,
   input  instruction_t  instruction_word

  );

  timeunit 1ns/1ns;
  parameter  RD_NR = 20;
  parameter  WR_NR = 20;
  int seed = 555;

   instruction_t  iw_reg_test [0:31];
  
  //17.03.2024 ==============================
   // Variabile pentru rezultatele așteptate și rezultatele primite
  result_t expected_result;
  result_t received_result;

  // Inițializare pentru rezultatul așteptat (poate fi modificat după necesități)
  initial begin
    expected_result = 0; // De exemplu, inițializăm rezultatul așteptat cu 0
  end


  initial begin
    $display("\n\n***********************************************************");
    $display(    "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(    "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(    "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(    "***********************************************************");

    $display("\nReseting the instruction register...");
    write_pointer  = 5'h00;         // initialize write pointer
    read_pointer   = 5'h1F;         // initialize read pointer
    load_en        = 1'b0;          // initialize load control line
    reset_n       <= 1'b0;          // assert reset_n (active low)
    repeat (2) @(posedge clk) ;     // hold in reset for 2 clock cycles
    reset_n        = 1'b1;          // deassert reset_n (active low)

    $display("\nWriting values to register stack...");
    @(posedge clk) load_en = 1'b1;  // enable writing to register
    //repeat (3) begin  11.03.2024 
    repeat(RD_NR) begin 
      @(posedge clk) randomize_transaction;
      @(negedge clk) print_transaction;
                     save_test_data;
    end
    @(posedge clk) load_en = 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    //for (int i=0; i<=2; i++) begin  11.03.2024
    for (int i=0; i<=WR_NR; i++) begin
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      @(posedge clk) read_pointer = i;
      @(negedge clk) print_results;
      //save_test_data;--------------------------
      //check_results; Aici apelam verificarea functiei check_results (TEMA!!! )
 // Atribuirea rezultatului așteptat

      case(instruction_word.opc)
        ZERO: expected_result = 0;
        PASSA: expected_result = instruction_word.op_a;
        PASSB: expected_result = instruction_word.op_b;
        ADD: expected_result = instruction_word.op_a + instruction_word.op_b;
        SUB: expected_result = instruction_word.op_a - instruction_word.op_b;
        MULT: expected_result = instruction_word.op_a * instruction_word.op_b;
        DIV: if (instruction_word.op_b == 0) begin
               expected_result = 0; // Împărțire la zero, atribuirea unei valori de eroare
             end else begin
               expected_result = instruction_word.rezultat; // Rezultatul așteptat este cel primit din DUT
             end
        MOD: if (instruction_word.op_b == 0) begin
             expected_result = 0;
               end else begin
        expected_result = instruction_word.op_a % instruction_word.op_b; end
      endcase

 // Verificarea rezultatului
      received_result = instruction_word.rezultat;

      check_res(received_result, expected_result); // Verificare rezultat

    end

    @(posedge clk) ;
    $display("\n***********************************************************");
    $display(  "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(  "***********************************************************\n");
    $finish;
  end

  function void randomize_transaction;
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    //
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab
    //
    static int temp = 0;
    operand_a     <= $random(seed)%16;                 // between -15 and 15
    operand_b     <= $unsigned($random)%16;            // between 0 and 15
    opcode        <= opcode_t'($unsigned($random)%8);  // between 0 and 7, cast to opcode_t type
    write_pointer <= temp++;
  endfunction: randomize_transaction

  function void print_transaction;
    $display("Writing to register location %0d: ", write_pointer);
    $display("  opcode = %0d (%s)", opcode, opcode.name);
    $display("  operand_a = %0d",   operand_a);
    $display("  operand_b = %0d\n", operand_b);
     $display("  result_t = %0d\n", instruction_word.rezultat);
  endfunction: print_transaction

  function void print_results;
    $display("Read from register location %0d: ", read_pointer);
    $display("  opcode = %0d (%s)", instruction_word.opc, instruction_word.opc.name);
    $display("  operand_a = %0d",   instruction_word.op_a);
    $display("  operand_b = %0d\n", instruction_word.op_b);
    $display("  result_t = %0d\n", instruction_word.rezultat);
  endfunction: print_results

  // Funcția check_res pentru compararea rezultatelor----------------------------------------------
  function void check_res(result_t received_result, result_t expected_result);
    if (received_result == expected_result) begin
      $display("Test PASSED: rezultatul primit din test se aseamana cu cel din DUT.\n");
    end else begin
      $display("Test FAILED: rezultatele sunt diferite.\n");
      $display("Received result: %d", received_result);
      $display("Expected result: %d", expected_result);
    end
  endfunction

  function void save_test_data();
      case (opcode)
        ZERO: expected_result =  'b0; //rezultatul este setat la 0
        PASSA: expected_result=  operand_a; //rezultatul este operandul A
        PASSB: expected_result = operand_b;//rezultatul este operandul B
        ADD: expected_result = '{operand_a + operand_b};
        SUB:expected_result = '{operand_a - operand_b};
        MULT: expected_result = '{operand_a * operand_b};
        DIV:begin 
        if(operand_b == 0) begin
           expected_result <= 'b0;
        end else begin
        expected_result = '{operand_a / operand_b}; end
        end
        MOD: expected_result = '{operand_a % operand_b};  
        iw_reg_test[i]=expected_result;
      endcase 
    always@(posedge clk, negedge reset_n)   // write into register 
    if (!reset_n) begin
      foreach (iw_reg[i])
        iw_reg[i] = '{opc:ZERO,default:0};  // reset to all zeros 
    end

     $display("Read from test_save_data %0d: ", read_pointer);
    $display("  opcode_test = %0d (%s)", opcode,opcode.name);
    $display("  operand_a_test = %0d",   operand_a);
    $display("  operand_b_test = %0d\n", operand_b);
    $display("  result_t_test = %0d\n", rezultat);
    endfunction
endmodule: instr_register_test
