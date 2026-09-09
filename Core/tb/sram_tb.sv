
module sram_tb();
    parameter length = 4;
    parameter bit_width = 4;
    parameter tests = 100;

    logic clk;
    logic n_rst;

    logic write_en;
    logic [bit_width-1:0] write_data [length-1:0];

    logic [bit_width-1:0] read_data [length-1:0];

    sram #(
        .length(length),
        .bit_width(bit_width)
    ) s0 (.*);

    //set up clock
    initial begin
        clk = 0;
        forever begin
            #5ns clk = ~clk;
        end
    end

    //start test
    initial begin
        int correct;
        int incorrect;
        logic [bit_width-1:0] expected [length-1:0];

        n_rst = 0;
        write_en = 0;

        for(int j = 0; j < tests; j++) begin
            n_rst = 0;
            write_en = 0;

            //check if reset works as expected
            for(int i = 0; i < length; i++) begin
                if(read_data[i] == 0) begin
                    correct++;
                end
                else begin
                    incorrect++;
                    $display("FAIL RESET TEST [%4d] | EXPECTED: 0 | GOT: %4d", j, read_data[i]);
                end
            end


            for(int i = 0; i < length; i++) begin
                write_data[i] = $urandom;
                expected[i] = write_data[i];
            end

            @(posedge clk);
            #1ns n_rst = 1;
            write_en = 1;

            #10ns
            for(int i = 0; i < length; i++) begin
                if(read_data[i] == expected[i]) begin
                    correct++;
                end
                else begin
                    incorrect++;
                    $display("FAIL TEST [%4d] | EXPECTED: %4d | GOT: %4d", j, expected[i], read_data[i]);
                end
            end
        end

        $display("TEST FINISHED | INCORRECT: %4d | CORRECT: %4d", incorrect, correct);
        $finish;
    end
endmodule







