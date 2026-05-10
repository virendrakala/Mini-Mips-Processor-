module GraphAccelerator(
    input clk,
    input [4:0] edge_source,
    input [4:0] edge_dest,
    input adjacency_val,
    input [4:0] path_length,
    input input_done,
    input [4:0] start_vertex,
    input [4:0] end_vertex,
    input start_arm,
    input stop_arm,
    output is_there_path,
    output done,
    output reg [31:0] arm_cycles
);

    // Adjacency Matrices [cite: 353-360]
    reg [31:0] A [0:31];
    reg [31:0] B [0:31];
    reg [31:0] C [0:31];
    reg [31:0] A_transposed [0:31];

    // FSM and Path Loop Counters
    reg [3:0] state = 0;
    reg [4:0] current_k = 1;

    // Outputs [cite: 343-345]
    assign done = (state == 7);
    assign is_there_path = B[start_vertex][end_vertex];

    integer init_i;
    initial begin
        for(init_i=0; init_i<32; init_i=init_i+1) begin
            A[init_i] = 0; B[init_i] = 0; C[init_i] = 0; A_transposed[init_i] = 0;
        end
    end

    always @(posedge clk) begin
        // --- State 0: Accept Adjacency Matrix ---
        if (state == 0) begin
            if (!input_done) begin
                A[edge_source][edge_dest] <= adjacency_val;
                A_transposed[edge_dest][edge_source] <= adjacency_val;
            end else begin
                state <= 1;
            end
        end
        // --- State Transitions ---
        else if (state == 1) begin
            current_k <= 1;
            if (path_length == 1) state <= 7; // Path length 1 requires no multiplication
            else state <= 2;
        end
        else if (state == 2) state <= 3;
        else if (state == 3) state <= 4;
        else if (state == 4) state <= 5;
        else if (state == 5) state <= 6;
        else if (state == 6) begin
            if (current_k + 1 == path_length) state <= 7; // Done!
            else begin
                current_k <= current_k + 1;
                state <= 2; // Loop back for next multiplication power [cite: 318]
            end
        end

        // --- ARM Cycle Counter [cite: 320] ---
        if (start_arm && !stop_arm) arm_cycles <= arm_cycles + 1;
        else if (!start_arm) arm_cycles <= 0;
    end

    // Parallel Matrix Copying and Multiplication [cite: 315-318]
    genvar i, j;
    generate
        for (i = 0; i < 32; i = i + 1) begin : compute_rows
            always @(posedge clk) begin
                if (state == 1) B[i] <= A[i];      // State 1: Copy A to B
                if (state == 6) B[i] <= C[i];      // State 6: Copy C to B
            end

            for (j = 0; j < 32; j = j + 1) begin : compute_cols
                // Bitwise AND of Row B[i] and Column A[j] [cite: 291-295]
                wire [31:0] and_res = B[i] & A_transposed[j];
                wire bit_res = (and_res != 0); // 1 if non-zero, 0 otherwise

                always @(posedge clk) begin
                    if (state == 2 && i < 8) C[i][j] <= bit_res;
                    else if (state == 3 && i >= 8 && i < 16) C[i][j] <= bit_res;
                    else if (state == 4 && i >= 16 && i < 24) C[i][j] <= bit_res;
                    else if (state == 5 && i >= 24 && i < 32) C[i][j] <= bit_res;
                end
            end
        end
    endgenerate

endmodule
