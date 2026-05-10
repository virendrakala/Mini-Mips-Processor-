module MatrixVectorAccelerator(
    input clk,
    input [3:0] row_idx,
    input [3:0] col_idx,
    input [31:0] val_in,
    input is_matrix,
    input input_done,
    input start_arm,
    input stop_arm,
    input [3:0] read_row_idx, // To read the output vector Y
    output [31:0] y_out,
    output done,
    output [31:0] arm_cycles_out
);

    // Memory for 16x16 Matrix M, 16x1 Vector X, and 16x1 Vector Y
    reg [31:0] M [0:15][0:15];
    reg [31:0] X [0:15];
    reg [31:0] Y [0:15];
    
    // Intermediate parallel product array
    reg [31:0] prod [0:15];

    reg [3:0] state = 4'd0;
    reg [3:0] current_row = 4'd0;
    reg [31:0] arm_cycles = 32'd0;
    reg is_done = 1'b0;

    assign arm_cycles_out = arm_cycles;
    assign done = is_done;
    assign y_out = Y[read_row_idx]; // Multiplex the output based on C program request

    // Main FSM Logic
    always @(posedge clk) begin
        if (state == 4'd0) begin
            if (input_done) state <= 4'd1;
            current_row <= 4'd0;
        end
        else if (state == 4'd1) state <= 4'd2; // Parallel Multiplication
        else if (state == 4'd2) state <= 4'd3; // Reduction Level 1
        else if (state == 4'd3) state <= 4'd4; // Reduction Level 2
        else if (state == 4'd4) state <= 4'd5; // Reduction Level 3
        else if (state == 4'd5) state <= 4'd6; // Reduction Final Level
        else if (state == 4'd6) begin
            Y[current_row] <= prod[0];         // Save the row result
            current_row <= current_row + 1;    // Increment row
            state <= 4'd7;
        end
        else if (state == 4'd7) begin
            if (current_row == 4'd0) state <= 4'd8; // Overflowed back to 0 means 16 rows are done
            else state <= 4'd1; // Loop back for the next row
        end
        else if (state == 4'd8) begin
            is_done <= 1'b1;
            if (start_arm && !stop_arm) arm_cycles <= arm_cycles + 1;
        end
    end

    // Input Loading Logic
    integer r, c;
    always @(posedge clk) begin
        if (state == 4'd0 && !input_done) begin
            if (is_matrix) M[row_idx][col_idx] <= val_in;
            else X[row_idx] <= val_in;
        end
    end

    // Generate block for Parallel Math
    genvar i;
    generate 
        for (i = 0; i < 16; i = i + 1) begin : compute_math
            always @(posedge clk) begin
                if (state == 4'd1) begin
                    prod[i] <= M[current_row][i] * X[i]; // Parallel Inner Product Multiplication
                end
                else if (state == 4'd2 && i < 8) begin
                    prod[i] <= prod[2*i] + prod[2*i+1];
                end
                else if (state == 4'd3 && i < 4) begin
                    prod[i] <= prod[2*i] + prod[2*i+1];
                end
                else if (state == 4'd4 && i < 2) begin
                    prod[i] <= prod[2*i] + prod[2*i+1];
                end
                else if (state == 4'd5 && i == 0) begin
                    prod[i] <= prod[2*i] + prod[2*i+1];
                end
            end
        end
    endgenerate

endmodule
