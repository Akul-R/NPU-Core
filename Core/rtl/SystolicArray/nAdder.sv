//n Bit Adder
//Inputs: A[0:n-1], B[0:n-1], CIN
//Outputs: Q[0:n-1], COUT

module n_adder #(
    parameter n = 4
)
(
    input logic [n-1:0] A,
    input logic [n-1:0] B,
    input logic CIN,
    output logic [n-1:0] Q,
    output logic COUT
);

    logic [n:0] CARRY; //Carry wires between each full adder
    assign CARRY[0] = CIN;

    generate
        for(genvar i = 0; i < n; i++) begin
            f_adder adder_inst(
                .A(A[i]),
                .B(B[i]),
                .CIN(CARRY[i]),
                .Q(Q[i]),
                .COUT(CARRY[i+1])
            );
        end
    endgenerate

    assign COUT = CARRY[n];
endmodule