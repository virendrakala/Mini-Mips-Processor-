`timescale 1ns / 1ps

module VectorAccelerator_tb;

    // Inputs
    reg clk;
    reg [8:0] index;
    reg [31:0] value;
    reg vector_id;
    reg input_done;
    reg start_arm;
    reg stop_arm;

    // Outputs
    wire [31:0] reduction_out;
    wire done;
    wire [31:0] arm_cycles_out;

    // Instantiate the Unit Under Test (UUT)
    VectorAccelerator uut (
        .clk(clk),
        .index(index),
        .value(value),
        .vector_id(vector_id),
        .input_done(input_done),
        .start_arm(start_arm),
        .stop_arm(stop_arm),
        .reduction_out(reduction_out),
        .done(done),
        .arm_cycles_out(arm_cycles_out)
    );

    // Clock generation (100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test Stimulus
    integer i;
    initial begin
        // Initialize Inputs
        index = 0;
        value = 0;
        vector_id = 0;
        input_done = 0;
        
        // We aren't testing ARM cycle counting in this pure HW testbench
        start_arm = 0; 
        stop_arm = 0;

        // Wait 100 ns for global reset to settle
        #100;
        $display("Starting Vector Accelerator Testbench...");

        // Load 512 elements into v0 and v1 sequentially
        // Mimicking the C code logic: v0[i] = (i%10)-5, v1[i] = (i%10)-2
        for (i = 0; i < 512; i = i + 1) begin
            // Load into v0
            @(negedge clk);
            index = i;
            vector_id = 0;
            value = (i % 10) - 5;
            
            // Load into v1
            @(negedge clk);
            vector_id = 1;
            value = (i % 10) - 2;
        end

        // Trigger the 12-State FSM computation
        @(negedge clk);
        input_done = 1;
        $display("Finished loading 1024 elements. Parallel computation started...");

        // Wait for the FSM to reach State 11 (done == 1)
        wait (done == 1'b1);
        
        // Let the signals settle for viewing in the waveform
        #20; 
        
        $display("Computation Done!");
        $display("-------------------------------------------------");
        $display("Final Reduction Sum: %0d", $signed(reduction_out));
        $display("Expected Sum:        1008"); 
        $display("-------------------------------------------------");
        
        if ($signed(reduction_out) == 1008)
            $display(">>> SIMULATION PASSED! Hardware is perfectly accurate. <<<");
        else
            $display(">>> SIMULATION FAILED! Check your reduction tree logic. <<<");

        $finish;
    end
endmodule
