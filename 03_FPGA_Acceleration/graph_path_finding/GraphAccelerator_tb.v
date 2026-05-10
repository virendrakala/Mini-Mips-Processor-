module GraphAccelerator_tb;

    // Inputs
    reg clk;
    reg [4:0] edge_source;
    reg [4:0] edge_dest;
    reg adjacency_val;
    reg [4:0] path_length;
    reg input_done;
    reg [4:0] start_vertex;
    reg [4:0] end_vertex;
    reg start_arm;
    reg stop_arm;

    // Outputs
    wire is_there_path;
    wire done;
    wire [31:0] arm_cycles;

    // Instantiate the Unit Under Test (UUT)
    GraphAccelerator uut (
        .clk(clk),
        .edge_source(edge_source),
        .edge_dest(edge_dest),
        .adjacency_val(adjacency_val),
        .path_length(path_length),
        .input_done(input_done),
        .start_vertex(start_vertex),
        .end_vertex(end_vertex),
        .start_arm(start_arm),
        .stop_arm(stop_arm),
        .is_there_path(is_there_path),
        .done(done),
        .arm_cycles(arm_cycles)
    );

    // Clock generation (10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    integer i, j;

    initial begin
        // Initialize Inputs
        edge_source = 0; edge_dest = 0; adjacency_val = 0;
        path_length = 0; input_done = 0; start_vertex = 0; end_vertex = 0;
        start_arm = 0; stop_arm = 0;

        #100;

        $display("Loading 32-node Ring Graph (1024 edges)...");

        // Load Adjacency Matrix for Ring Graph [cite: 371, 393]
        for (i = 0; i < 32; i = i + 1) begin
            for (j = 0; j < 32; j = j + 1) begin
                edge_source = i;
                edge_dest = j;

                // Connect i to i+1 and i-1
                if (j == ((i + 1) % 32) || j == ((i + 31) % 32))
                    adjacency_val = 1;
                else
                    adjacency_val = 0;

                #10;
            end
        end

        // Trigger hardware computation [cite: 372, 411]
        $display("Triggering Matrix Computations for path_length = 31...");
        path_length = 31;
        input_done = 1;
        #10;
        input_done = 0;

        // Wait for FSM to complete matrix multiplications
        wait(done == 1);
        #10;

        // Display results
        $display("-------------------------------------------");
        $display("Computation Finished!");

        // Test a specific path: Node 0 to Node 1
        start_vertex = 0;
        end_vertex = 1;
        #10;

        $display("Path of length 31 from Node 0 to Node 1 exists? : %b", is_there_path);

        // In a bipartite ring graph, node 0 can reach all odd nodes in an odd number of steps (like 31).
        if (is_there_path == 1)
            $display("SIMULATION PASSED! The graph accelerator works beautifully.");
        else
            $display("SIMULATION FAILED! Expected a path to exist.");
        $display("-------------------------------------------");

        $finish;
    end

endmodule
