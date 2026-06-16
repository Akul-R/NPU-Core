/*
Test bench for Systolic Array with rows x cols MAC units
Inputs: 
    [n-1:0] X [rows-1:0]            (Input Activation)
    [n-1:0] W [rows-1:0][cols-1:0]  (Weights Matrix)
    [m-1:0] B [cols-1:0]            (Bias Matrix)

Outputs: 
    [m-1:0] Y [cols-1:0]            (Output Activation)

Version History:
V1 - Simple Testbench with static Weight and Bias Matrices for simple debugging
*/

module nSystolic_tb();
    //parameters
    parameter n = 4;
    parameter m = 12;
    parameter rows = 4;
    parameter cols = 4;
    parameter tests = 500;

    //inputs
    logic clk;
    logic n_rst;
    logic [n-1:0] X [rows-1:0];
    logic [n-1:0] W [rows-1:0][cols-1:0];
    logic [m-1:0] B [cols-1:0];

    //outputs
    logic [m-1:0] Y [cols-1:0];

    //instantiate systolic array
    n_systolicArray #(
        .n(n),
        .m(m),
        .rows(rows),
        .cols(cols)
    ) s0 (.*);

    //generate clock
    initial begin
        clk = 0;
        forever begin
            #5ns clk = ~clk;
        end
    end

    //main verification block
    initial begin
        int correct;
        int incorrect;
        int fails;
        int clock_count;
        logic [m-1:0] expected_ans [cols-1:0];
        
        correct = 0;
        incorrect = 0;

        n_rst = 0;
        //defining static weights and bias matrix
        //for easier debugging, weight values are equal to column number + 1
        for(int i = 0; i < rows; i++) begin
            for(int j = 0; j < cols; j++) begin
                W[i][j] = j+1;
            end
        end

        //for easier debugging, bias values are all set to constant (3)
        for(int j = 0; j < cols; j++) begin
            B[j] = 3;
        end

        //----------------------------------------------------------------------------------
        //----------------------------------------------------------------------------------
        //----------------------------------------------------------------------------------

        $display("-----------------SYSTOLIC ARRAY TEST--------------------");
        $display("--------------------------------------------------------");

        //main testing loop
        for(int test = 0; test < tests; test++) begin
            fails = 0;
            clock_count = 0;
            //generate random X values for input activations
            for(int i = 0; i < rows; i++) begin
                X[i] = $urandom;
            end

            //calculate expected results
            //Y = (X0*W0 + X1*W1...) + B0
            for(int j = 0; j < cols; j++) begin
                expected_ans[j] = 0;

                //go row by row and add X*W
                for(int i = 0; i < rows; i++) begin
                    expected_ans[j] = expected_ans[j] + (X[i]*W[i][j]);
                end

                //add bias to get expected result
                expected_ans[j] = expected_ans[j] + B[j];
            end

            //release reset to start the array with the defined values
            @(posedge clk);
            #1ns n_rst = 1;

            //result is received after n clock cycles where n is the number of MACs in one
            //column of the array (rows)

            while(clock_count < rows) begin
                @(posedge clk);
                #1ps clock_count++;
            end

            for(int j = 0; j < cols; j++) begin
                if(expected_ans[j] != Y[j]) begin
                    fails++;
                    $display("[FAIL] | TEST: %4d | EXPECTED: %5d | GOT: %5d", test, expected_ans[j], Y[j]);
                end
            end

            if(fails > 0) begin
                incorrect++;
                $display("[FAIL] | TEST: %4d", test);
                $display("--------------------------------------------------------");
            end
            else begin
                correct++;
                $display("[PASS] | TEST: %4d", test);
            end

            //end of test, hold reset until next test starts.
            @(negedge clk);
            n_rst = 0;
        end

        $display("-------------SYSTOLIC ARRAY TESTS COMPLETE--------------");
        $display("ROWS: %5d | COLS: %5d | SIZE: %2d BITS", rows, cols, n);
        $display("PASSED: %5d | FAILED: %5d", correct, incorrect);
        $finish;
    end
endmodule
            



