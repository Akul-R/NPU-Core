//Full Adder
//Inputs: A (Input 1), B (Input 2), CIN (Carry In)
//Outputs: Q (Result), COUT (Carry Out)

module f_adder(
    input logic A,
    input logic B,
    input logic CIN,
    output logic Q,
    output logic COUT
);

    always_comb begin
        Q = (A^B)^CIN;
        COUT = (A&B) | ((A^B)&CIN);
    end

endmodule