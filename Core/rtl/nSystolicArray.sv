/*nxm Systolic Array
Components: rows x cols grid of MAC Units, Memory Unit to store and load W and B
Parameters:
    n :         multiplier bit size
    m :         accumulator bit size
    rows :      number of rows of MACs in grid
    cols :      number of columns of MACs in grid

Inputs: 
    [n-1:0] X [rows-1:0]            (Input Activation)
    [n-1:0] W [rows-1:0][cols-1:0]  (Weights Matrix)
    [m-1:0] B [cols-1:0]            (Bias Matrix)

Outputs: 
    [m-1:0] Y [cols-1:0]            (Output Activation)
*/

module n_systolicArray #(
    parameter n = 4,
    parameter m = 12,
    parameter rows = 2,
    parameter cols = 4
)
(
    input logic clk,
    input logic n_rst,
    input logic [n-1:0] X [rows-1:0],
    input logic [n-1:0] W [rows-1:0][cols-1:0],
    input logic [m-1:0] B [cols-1:0],
    output logic [m-1:0] Y [cols-1:0]
);

    //Internal wire Meshes
    logic [n-1:0] inp_mesh [rows-1:0][cols:0]; //passes the input across to horizontal MACs
    logic [m-1:0] sum_mesh [rows:0][cols-1:0]; //passes partial sums to vertical MACs

    //hookup module IO to internal meshes
    generate
        genvar i;

        //assign the first column of the input mesh to the inputs X
        for(i = 0; i < rows; i++) begin
            assign inp_mesh[i][0] = X[i];
        end

        //assign the first row of the sum mest to the bias B
        for(i = 0; i < cols; i++) begin
            assign sum_mesh[0][i] = B[i];
        end

        //assign the output Y to the final row of the sum mesh
        for(i = 0; i < cols; i++) begin
            assign Y[i] = sum_mesh[rows][i];
        end
    endgenerate


    generate
        genvar j;

        for(i = 0; i < rows; i++) begin
            for(j = 0; j < cols; j++) begin
                n_MAC #(
                    .n(n),
                    .m(12)
                ) MAC_inst (
                    .A(inp_mesh[i][j]),     //A: Input X0:Xn
                    .B(W[i][j]),            //B: Static Weights from matrix
                    .C(sum_mesh[i][j]),     //C: Output of previous MAC
                    .clk(clk),              //clk: Clock (fairly self explanatory)
                    .n_rst(n_rst),          //n_rst: active low synchronous reset
                    .Q(sum_mesh[i+1][j])    //Q: Output of MAC, Input of next MAC
                );

                assign inp_mesh[i][j+1] = inp_mesh[i][j]; //make inputs carry to horizontal MAC
            end
        end
    endgenerate
endmodule