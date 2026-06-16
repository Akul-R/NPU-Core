//N bit array multiplier
//Inputs: A[N-1:0], B[N-1:0]
//Outputs: Q[(N*2)-1:0]

module n_multiplier #(
    parameter n = 4
)
(
    input logic [n-1:0] A,
    input logic [n-1:0] B,
    output logic [(n*2)-1:0] Q
);

    assign Q = A*B;

endmodule