/*
Module: Control Unit and Memory Module Test Bench

Description: A simple testbench to verify the control unit and memory unit modules function correctly together.
Version History:
    V1.0 - Test Bench supports Control Unit and Instruction Memory (IMEM) unit
*/

module control_unit_memory_tb();
    parameter rows = 4;
    parameter tests = 100;
    parameter pc_depth = 5;
    parameter instr_size = 8;

    //control unit 
    logic clk;
    logic n_rst;
    logic core_en;

    logic inp_read_en;
    logic [4:0] inp_read_addr;
    logic weight_read_en;
    logic bias_read_en;

    logic array_n_rst;
    logic done;

    //Imem
    logic write_en;
    logic [instr_size-1:0] write_data;

    logic [pc_depth-1:0] read_addr;
    logic [instr_size-1:0] read_data;

    control_unit #(
        .rows(rows),
        .pc_depth(pc_depth)
    ) c0 (
        .i_data(read_data),
        .i_addr(read_addr),
        .*
    );

    i_mem #(
        .pc_depth(pc_depth),
        .instr_size(instr_size)
    ) i0 (.*);

    initial begin
        clk = 0;
        forever begin
            #5ns clk = ~clk;
        end
    end

    initial begin
        n_rst = 0;
        core_en = 0;
        write_en = 0;
        write_data = 0;

        #20ns n_rst = 1;

        //program imem
        @(posedge clk);
        write_en = 1;
        write_data = 8'b001_00110;

        // //instruction 0: 000 00000 - NOP
        // @(posedge clk);
        // write_data = 8'b000_00000;

        // //instruction 1: 001 00110 - Load Weights at addr 6
        // @(posedge clk);
        // write_data = 8'b001_00110;

        //instruction 2: 010 00111 - Load Biases at addr 7
        @(posedge clk);
        write_data = 8'b010_00111;

        //instruction 3: 011 00011 - Execute with 3 sets of inputs
        @(posedge clk);
        write_data = 8'b011_00011;

        //instruction 4: 100 00000 - Halt
        @(posedge clk);
        write_data = 8'b100_00000;

        //instruction 5: 100 00000 - Halt
        @(posedge clk);
        write_data = 8'b100_00000;

        //instruction 6: 100 00000 - Halt
        @(posedge clk);
        write_data = 8'b100_00000;

        //instruction 7: 011 00111 - Execute with 7 sets of inputs
        @(posedge clk);
        write_data = 8'b011_00111;

        //instruction 8: 100 00000 - Halt
        @(posedge clk);
        write_data = 8'b100_00000;

        @(posedge clk);
        write_en = 0;
        write_data = 0;

        #20ns core_en = 1;

        for(int i = 0; i < 7; i++) begin
            $display("INSTR %2d: %b", i, i0.ram[i]);
        end


    end

endmodule