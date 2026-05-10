module VectorAccelerator(
    input clk,
    input [8:0] index,
    input [31:0] value,
    input vector_id,
    input input_done,
    input start_arm,
    input stop_arm,
    output [31:0] reduction_out,
    output done,
    output [31:0] arm_cycles_out
);

    // 512-dimensional arrays defined [cite: 416-419]
    reg [31:0] v0 [0:511];
    reg [31:0] v1 [0:511];
    reg [31:0] v2 [0:511];

    reg [3:0] state = 4'd0;
    reg [31:0] arm_cycles = 32'd0;
    reg is_done = 1'b0;

    assign arm_cycles_out = arm_cycles;
    assign done = is_done;
    assign reduction_out = v2[0]; // v2[0] holds the final reduction sum

    // Main FSM Control Logic [cite: 381-390]
    always @(posedge clk) begin
        case (state)
            4'd0: if (input_done) state <= 4'd1; // Wait for vectors to be loaded
            4'd1: state <= 4'd2; // Vector addition
            4'd2: state <= 4'd3; // Reduction Level 1
            4'd3: state <= 4'd4; // Reduction Level 2
            4'd4: state <= 4'd5; // Reduction Level 3
            4'd5: state <= 4'd6; // Reduction Level 4
            4'd6: state <= 4'd7; // Reduction Level 5
            4'd7: state <= 4'd8; // Reduction Level 6
            4'd8: state <= 4'd9; // Reduction Level 7
            4'd9: state <= 4'd10; // Reduction Level 8
            4'd10: state <= 4'd11; // Reduction Final Level
            4'd11: begin
                is_done <= 1'b1; // Mark computation as complete
                if (start_arm && !stop_arm) begin
                    arm_cycles <= arm_cycles + 1; // Count ARM processor cycles [cite: 374-377]
                end
            end
        endcase
    end

    // Generate block: Inputting elements into v0 and v1 [cite: 382-384]
    genvar j;
    generate
        for (j = 0; j < 512; j = j + 1) begin : load_vectors
            always @(posedge clk) begin
                if (state == 4'd0 && !input_done && index == j) begin
                    if (vector_id == 1'b0) v0[j] <= value;
                    else v1[j] <= value;
                end
            end
        end
    endgenerate

    // Generate block: Parallel Addition (State 1) and Reduction Tree (States 2-10) [cite: 354-362]
    genvar i;
    generate 
        for (i = 0; i < 512; i = i + 1) begin : compute_reduction
            always @(posedge clk) begin
                if (state == 4'd1) begin
                    v2[i] <= v0[i] + v1[i]; // v2[i] = v0[i] + v1[i] [cite: 335]
                end
                // 9-cycle reduction tree logic [cite: 357-360]
                else if (state == 4'd2 && i < 256) begin
                    v2[i] <= v2[2*i] + v2[2*i+1];
                end
                else if (state == 4'd3 && i < 128) begin
                    v2[i] <= v2[2*i] + v2[2*i+1];
                end
                else if (state == 4'd4 && i < 64) begin
                    v2[i] <= v2[2*i] + v2[2*i+1];
                end
                else if (state == 4'd5 && i < 32) begin
                    v2[i] <= v2[2*i] + v2[2*i+1];
                end
                else if (state == 4'd6 && i < 16) begin
                    v2[i] <= v2[2*i] + v2[2*i+1];
                end
                else if (state == 4'd7 && i < 8) begin
                    v2[i] <= v2[2*i] + v2[2*i+1];
                end
                else if (state == 4'd8 && i < 4) begin
                    v2[i] <= v2[2*i] + v2[2*i+1];
                end
                else if (state == 4'd9 && i < 2) begin
                    v2[i] <= v2[2*i] + v2[2*i+1];
                end
                else if (state == 4'd10 && i == 0) begin
                    v2[i] <= v2[2*i] + v2[2*i+1];
                end
            end
        end
    endgenerate

endmodule

