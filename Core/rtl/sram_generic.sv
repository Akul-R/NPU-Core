/*
Module: SRAM (generic)
Description:
    SRAM module to store data. Will serve as a template for the high speed buffers needed in the NPU core design.
    Fully parameterisable so that it can be resused for different components

Parameters:
    bit_width: size of each piece of data in bits (for example, 4 bit number)
    length: dictates how many bit_width sized numbers the buffer can hold

Inputs:
    write_data: data from RAM to be stored in buffer.
    write_en: allows buffer to update and store write_data
    n_rst: active low, asynchronous reset signal, resets buffer to hold all zeros.

Outputs:
    read_data: data stored in buffer outputs from here
*/

module sram #(
    parameter length = 4,
    parameter bit_width = 4
)
(
    input logic write_en,
    input logic [bit_width-1:0] write_data [length-1:0],
    input logic clk,
    input logic n_rst,

    output logic [bit_width-1:0] read_data [length-1:0]
);

    logic [bit_width-1:0] ram [length-1:0];

    always_ff @(posedge clk) begin
        if(!n_rst) begin
            for (int i = 0; i < length; i++) begin
                ram[i] <= '0;
            end
        end
        else if(write_en) begin
            ram <= write_data;
        end
    end

    assign read_data = ram;
endmodule
