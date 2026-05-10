module MatrixVectorAccelerator_tb;

    reg clk;
    reg [3:0] row_idx;
    reg [3:0] col_idx;
    reg [31:0] val_in;
    reg is_matrix;
    reg input_done;
    reg start_arm;
    reg stop_arm;
    reg [3:0] read_row_idx;

    wire [31:0] y_out;
    wire done;
    wire [31:0] arm_cycles_out;

    MatrixVectorAccelerator uut (
        .clk(clk), .row_idx(row_idx), .col_idx(col_idx), .val_in(val_in),
        .is_matrix(is_matrix), .input_done(input_done), .start_arm(start_arm),
        .stop_arm(stop_arm), .read_row_idx(read_row_idx), .y_out(y_out),
        .done(done), .arm_cycles_out(arm_cycles_out)
    );

    initial begin clk = 0; forever #5 clk = ~clk; end

    integer r, c;
    initial begin
        row_idx = 0; col_idx = 0; val_in = 0; is_matrix = 0;
        input_done = 0; start_arm = 0; stop_arm = 0; read_row_idx = 0;

        #100;
        $display("Loading Matrix and Vector...");

        // Load Matrix
        for(r = 0; r < 16; r = r + 1) begin
            for(c = 0; c < 16; c = c + 1) begin
                @(negedge clk);
                is_matrix = 1; row_idx = r; col_idx = c; val_in = (r + c) % 5;
            end
        end

        // Load Vector
        for(r = 0; r < 16; r = r + 1) begin
            @(negedge clk);
            is_matrix = 0; row_idx = r; val_in = r % 4;
        end

        @(negedge clk); input_done = 1;
        $display("Computation Started...");

        wait (done == 1'b1);
        #20;
        
        $display("Computation Finished!");
        read_row_idx = 0; #10;
        $display("Y[0] output: %0d", y_out);
        read_row_idx = 15; #10;
        $display("Y[15] output: %0d", y_out);
        
        if (y_out == 36) $display(">>> SIMULATION PASSED! Hardware is accurate. <<<");
        else $display(">>> SIMULATION FAILED. <<<");

        $finish;
    end
endmodule
