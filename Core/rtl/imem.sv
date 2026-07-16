/*
Module: Instruction Memory
Description:
    Memory Unit to store instructions. As PC increments, the next instruction is fetched from here.
Version History:
    V1.0: Stores 32x 8 bit instructions (3 bit opcode, 5 bit address)
*/

module i_mem #(
    parameter pc_depth = 5,                  //in bits so 2^5 (32 instructions)
    parameter instr_size = 8                //size of each instruction (3 bit opcode, 5 bit address)
)
(
    input logic clk,
    input logic n_rst,

    input logic write_en,                    //enables new instruction to be written
    input logic [instr_size-1:0] write_data,

    input logic [pc_depth-1:0] read_addr,
    output logic [instr_size-1:0] read_data
);

    localparam depth = 1 << pc_depth;

    logic [instr_size-1:0] ram [depth-1:0];
    logic [pc_depth-1:0] write_ptr;

    //synchronous write
    always_ff @(posedge clk) begin
        if(!n_rst) begin
            write_ptr <= 0;
        end
        else begin
            if(write_en) begin
                ram[write_ptr] <= write_data;
                write_ptr <= write_ptr + 1;
            end
        end
    end

    //asynchronous read (needs 0 latency)
    assign read_data = ram[read_addr];

endmodule
