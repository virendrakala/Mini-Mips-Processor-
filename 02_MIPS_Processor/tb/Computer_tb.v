`timescale 1ns / 1ps
module Computer_tb;
    reg reset, clk, done_storing, copied_io_regs;
    reg [7:0] ins_addr; reg [31:0] ins;
    wire done, io_stall;
    wire [31:0] out_reg1, out_reg2, out_reg3, out_reg4, total_cycles, proc_cycles, io_regs_index_out;
    wire waiting_for_input; reg [31:0] input_value; reg input_value_valid;

    Computer uut (
        .reset(reset), .ins_addr(ins_addr), .ins(ins), .clk(clk), .done_storing(done_storing), .done(done), 
        .out_reg1(out_reg1), .out_reg2(out_reg2), .out_reg3(out_reg3), .out_reg4(out_reg4),
        .total_cycles(total_cycles), .proc_cycles(proc_cycles),
        .io_stall(io_stall), .copied_io_regs(copied_io_regs), .io_regs_index_out(io_regs_index_out),
        .waiting_for_input(waiting_for_input), .input_value(input_value), .input_value_valid(input_value_valid)
    );

    initial begin clk = 0; forever #5 clk = ~clk; end
    integer print_count = 1;
    
    always @(posedge clk) begin
        if (io_stall && !copied_io_regs) begin
            if (io_regs_index_out > 0) begin $display("out%0d=%0d (Hex: %0h)", print_count, $signed(out_reg1), out_reg1); print_count = print_count + 1; end
            if (io_regs_index_out > 1) begin $display("out%0d=%0d (Hex: %0h)", print_count, $signed(out_reg2), out_reg2); print_count = print_count + 1; end
            if (io_regs_index_out > 2) begin $display("out%0d=%0d (Hex: %0h)", print_count, $signed(out_reg3), out_reg3); print_count = print_count + 1; end
            if (io_regs_index_out > 3) begin $display("out%0d=%0d (Hex: %0h)", print_count, $signed(out_reg4), out_reg4); print_count = print_count + 1; end
            #20; copied_io_regs = 1;
        end else if (!io_stall && copied_io_regs) begin
            #20; copied_io_regs = 0;
        end
    end

    initial begin
        reset = 1; done_storing = 0; copied_io_regs = 0; input_value_valid = 0; input_value = 0;
        #7; reset = 0;
        
        $display("Starting Lab 9 Assignment 2 Load/Store Simulation...");
        
       // MIPS Machine Code for Load/Store Subword Testing
        ins_addr = 0;  ins = 32'h200803ec; #10; // addi $8, $0, 1004 (print syscall setup)
        ins_addr = 1;  ins = 32'h3c01fe76; #10; // lui $1, 0xfe76
        ins_addr = 2;  ins = 32'h342154dc; #10; // ori $1, $1, 0x54dc
        ins_addr = 3;  ins = 32'h20020200; #10; // addi $2, $0, 512
        ins_addr = 4;  ins = 32'hac410000; #10; // sw $1, 0($2)
        ins_addr = 5;  ins = 32'h8c430000; #10; // lw $3, 0($2)
        ins_addr = 6;  ins = 32'h0103000c; #10; // syscall $8, $3 (Print Word)
        ins_addr = 7;  ins = 32'h80430000; #10; // lb $3, 0($2)
        ins_addr = 8;  ins = 32'h0103000c; #10; // syscall $8, $3 (Print Byte 0)
        ins_addr = 9;  ins = 32'h90430001; #10; // lbu $3, 1($2)
        ins_addr = 10; ins = 32'h0103000c; #10; // syscall $8, $3 (Print Byte 1 Unsigned)
        ins_addr = 11; ins = 32'h80430002; #10; // lb $3, 2($2)
        ins_addr = 12; ins = 32'h0103000c; #10; // syscall $8, $3 (Print Byte 2)
        ins_addr = 13; ins = 32'h90430003; #10; // lbu $3, 3($2)
        ins_addr = 14; ins = 32'h0103000c; #10; // syscall $8, $3 (Print Byte 3 Unsigned)
        ins_addr = 15; ins = 32'h84430000; #10; // lh $3, 0($2)
        ins_addr = 16; ins = 32'h0103000c; #10; // syscall $8, $3 (Print Half 0)
        ins_addr = 17; ins = 32'h94430002; #10; // lhu $3, 2($2)
        ins_addr = 18; ins = 32'h0103000c; #10; // syscall $8, $3 (Print Half 1 Unsigned)
        ins_addr = 19; ins = 32'h200400aa; #10; // addi $4, $0, 0x00aa
        ins_addr = 20; ins = 32'ha0440001; #10; // sb $4, 1($2)  <-- FIXED THIS LINE
        ins_addr = 21; ins = 32'h8c430000; #10; // lw $3, 0($2)
        ins_addr = 22; ins = 32'h0103000c; #10; // syscall $8, $3 (Print Word after SB)
        ins_addr = 23; ins = 32'h2004bbcc; #10; // addi $4, $0, 0xbbcc
        ins_addr = 24; ins = 32'ha4440002; #10; // sh $4, 2($2)
        ins_addr = 25; ins = 32'h8c430000; #10; // lw $3, 0($2)
        ins_addr = 26; ins = 32'h0103000c; #10; // syscall $8, $3 (Print Word after SH)
        ins_addr = 27; ins = 32'h200803e9; #10; // addi $8, $0, 1001 
        ins_addr = 28; ins = 32'h0100000c; #10; // syscall $8, $0 (Exit)
        
        done_storing = 1;
        wait(done == 1);
        
        if (io_regs_index_out > 0) begin 
            $display("out%0d=%0d (Hex: %0h)", print_count, $signed(out_reg1), out_reg1); 
            print_count = print_count + 1; 
        end
        
        $display("-------------------------------------------");
        $display("Total cycles: %0d, computation cycles: %0d", total_cycles, proc_cycles);
        $finish;
    end
endmodule
