/*Module: Control Unit
Description:
    Control unit for core. Reads instructions and loads data into modules
    accordingly. Will be based on an FSM. This control unit is for a weight
    stationary design (weights loaded in initially and remain static).
Components:
    Will have a simple instruction set to do different operations. Instructions
    are 8 bits long with a 3 bit opcode and 5 bit address.
    Interfaces with memory for activations (inp), weights and biases.
*/

module control_unit #(
    parameter rows = 4
)
(
    input logic clk,
    input logic n_rst,

    //connections to Instruction Mem (I-MEM)
    output logic [4:0] i_addr,
    input logic [7:0] i_data,

    //connections to memory units
    output logic inp_read_en,
    output logic [4:0] inp_read_addr,
    output logic weight_read_en,
    output logic bias_read_en,

    //connections to systolic array
    output logic array_n_rst,
    output logic done
);

    //FSM states
    typedef enum logic [2:0] {
        RESET = 3'b000,
        FETCH = 3'b001,
        DECODE = 3'b010,
        EXECUTE = 3'b011,
        HALTED = 3'b100
    } state_t;

    state_t current_state, next_state;

    logic [4:0] pc;                 //program counter, will upgrade to a FIFO in future
    logic [4:0] cycle_counter;      //counts the number of cycles since start of operation
    logic [4:0] inp_stream_len;     //how many n bit inputs are to be processed
    logic [4:0] inp_addr_counter;   //tracks current address of input memory
    
    logic [2:0] opcode;             //3 bit opcode
    logic [4:0] argument;           //5 bit argument (usually address)

    assign opcode = i_data[7:5];
    assign argument = i_data[4:0];

    assign i_addr = pc;

    always_ff @(posedge clk or negedge n_rst) begin
        if(!n_rst) begin
            current_state <= RESET;
        end
        else begin
            current_state <= next_state;
        end
    end

    //next state logic
    always_ff @(posedge clk or negedge n_rst) begin
        if(!n_rst) begin
            //set everything to 0 essentially (reset)
            pc <= 0;
            cycle_counter <= 0;
            array_n_rst <= 0;

            inp_read_en <= 0;
            inp_read_addr <= 0;
            weight_read_en <= 0;
            bias_read_en <= 0;

            done <= 0;
            next_state = RESET;
        end
        else begin
            case(current_state)
                RESET: begin
                    pc <= 0;
                    inp_addr_counter <= 0;
                    next_state <= FETCH;
                end

                FETCH: begin
                    done <= 0;
                    next_state <= DECODE;
                end

                DECODE: begin
                    case(opcode)
                        3'b001: begin //load weights
                            weight_read_en <= 1;
                            pc <= pc + 1;
                            next_state <= FETCH;
                        end

                        3'b010: begin //load biases
                            bias_read_en <= 1;
                            pc <= pc + 1;
                            next_state <= FETCH;
                        end

                        3'b011: begin //execute with inputs
                            inp_stream_len <= argument;
                            inp_read_addr <= 0;
                            inp_read_en <= 1;
                            array_n_rst <= 1;
                            next_state <= EXECUTE;
                        end

                        3'b100: begin //halted
                            next_state <= HALTED;
                        end

                        default: begin //no op, idle state
                            pc <= pc + 1;
                            next_state <= FETCH;
                        end
                    endcase
                end

                EXECUTE: begin
                    weight_read_en <= 0;
                    bias_read_en <= 0;

                    if(cycle_counter < (inp_stream_len*rows)) begin
                        inp_read_addr <= inp_addr_counter;
                        inp_addr_counter <= inp_addr_counter + 1;
                        cycle_counter <= cycle_counter + 1;
                        next_state <= EXECUTE;
                    end
                    else begin
                        done <= 1;
                        inp_read_en <= 0;
                        pc <= pc + 1;
                        next_state <= FETCH;
                    end
                end

                HALTED: begin
                    next_state <= HALTED;
                end

                default: begin
                    next_state <= RESET;
                end
            endcase
        end
    end
endmodule


                    

