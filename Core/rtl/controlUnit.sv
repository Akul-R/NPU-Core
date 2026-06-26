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

    logic [4:0] pc;                 //program counter
    logic [4:0] cycle_counter;      //counts the number of cycles since start of operation
    logic [4:0] inp_stream_len;     //how many n bit inputs are to be processed
    logic [4:0] inp_addr_counter;   //tracks current address of input memory
    
    logic [2:0] opcode;             //3 bit opcode
    logic [4:0] argument;           //5 bit argument (usually address)

    assign opcode = i_data[7:5];
    assign argument = i_data[4:0];

    assign i_addr = pc;

    always_comb begin
        next_state = current_state;
        
        case (current_state)
            RESET: next_state = FETCH;
            
            FETCH: next_state = DECODE;
            
            DECODE: begin
                case (opcode)
                    3'b001:  next_state = FETCH; 
                    3'b010:  next_state = FETCH;   
                    3'b011:  next_state = EXECUTE; 
                    3'b100:  next_state = HALTED;
                    default: next_state = FETCH;
                endcase
            end
            
            EXECUTE: begin
                if (done) next_state = FETCH;
                else               next_state = EXECUTE;
            end
            
            HALTED: next_state = HALTED;
        endcase
    end

    //next state logic
    always_ff @(posedge clk or negedge n_rst) begin
        if(!n_rst) begin
            //set everything to 0 (reset)
            current_state <= RESET;
            pc <= 0;
            cycle_counter <= 0;
            array_n_rst <= 0;

            inp_read_en <= 0;
            inp_read_addr <= 0;
            weight_read_en <= 0;
            bias_read_en <= 0;

            done <= 0;
        end
        else begin
            current_state <= next_state;
            case(current_state)
                (RESET): begin
                    pc <= 0;
                    inp_addr_counter <= 0;
                end

                (FETCH): begin
                    done <= 0;
                end

                (DECODE): begin
                    case(opcode)
                        3'b001: begin //load weights
                            weight_read_en <= 1;
                            pc <= pc + 1;
                        end

                        3'b010: begin //load biases
                            bias_read_en <= 1;
                            pc <= pc + 1;
                        end

                        3'b011: begin //execute with inputs
                            weight_read_en <= 0;
                            bias_read_en <= 0;
                            inp_stream_len <= argument;
                            inp_read_addr <= 0;
                            inp_read_en <= 1;
                            array_n_rst <= 1;
                        end

                        3'b100: begin //halted
                            pc <= pc;
                        end

                        default: begin //no op, idle state
                            pc <= pc + 1;
                        end
                    endcase
                end

                (EXECUTE): begin
                    weight_read_en <= 0;
                    bias_read_en <= 0;

                    if(cycle_counter < inp_stream_len) begin
                        inp_read_addr <= inp_addr_counter*rows;
                        inp_addr_counter <= inp_addr_counter + 1;
                        cycle_counter <= cycle_counter + 1;
                    end
                    else begin
                        inp_addr_counter <= 0;
                        inp_read_addr <= 0;
                        done <= 1;
                        inp_read_en <= 0;
                        pc <= pc + 1;
                    end
                end

            endcase
        end
    end
endmodule


                    

