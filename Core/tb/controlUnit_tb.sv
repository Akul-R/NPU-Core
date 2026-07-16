
module control_unit_tb();

    parameter rows = 4;
    parameter tests = 100;

    logic clk;
    logic n_rst;
    
    logic [4:0] i_addr;
    logic [7:0] i_data;

    logic inp_read_en;
    logic [4:0] inp_read_addr;
    logic weight_read_en;
    logic bias_read_en;

    logic array_n_rst;
    logic done;

    control_unit #(
        .rows(rows)
    ) c0 (.*);

    //setup clock
    initial begin
        clk = 0;
        forever begin
            #5ns clk = ~clk;
        end
    end

    //simulate instruction memory
    initial begin
        i_data = 8'b000_0000; //no op
        forever begin
            @(i_addr) begin
                case(i_addr)
                    0 : begin 
                        i_data = 8'b000_00000;
                        n_rst = 1;
                    end
                    1 : i_data = 8'b001_00110;   //load weights at addr 6
                    2 : i_data = 8'b010_00111;   //load biases at addr 7
                    3 : i_data = 8'b011_00011;   //execute with 3 consecutive inputs
                    4 : i_data = 8'b100_00000;   //halted
                    7 : begin
                        i_data = 8'b000_00000;
                        n_rst = 0;
                    end
                    default : i_data = 8'b000_00000;
                endcase
            end
        end
    end

    initial begin
        n_rst = 0;
        #10ns n_rst = 1;
    end
endmodule
                






