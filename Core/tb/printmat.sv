//Helper Function for the systolic array test bench
//------------DO NOT COMPILE THIS FILE----------------

task automatic print_mat(int test);
    int halfway = rows / 2;
    int maxrows;

    $display("-----------------------TEST %4d-------------------------", test);
    $display("--------------------------------------------------------\n");

    if(rows > cols)
        maxrows = rows;
    else
        maxrows = cols;

    for(int i = 0; i < rows; i++) begin
        if(i == rows/2)
            $write("INPUT(X)");
        else
            $write("    ");
    end

    $write("   * ");

    for(int i = 0; i < cols; i++) begin
        if(i == rows/2)
            $write("WEIGHTS(W)");
        else
            $write("    ");
    end

    $write("  + ");

    for(int i = 0; i < cols; i++) begin
        if(i == rows/2)
            $write("BIAS(B)");
        else
            $write("     ");
    end

    $write(" = ");

    for(int i = 0; i < cols; i++) begin
        if(i == rows/2)
            $write("OUTPUT(Y)");
        else
            $write("     ");
    end

    $write("\n\n");

    for(int i = 0; i < maxrows; i++) begin
        //print X
        if(i == halfway-1) begin
            $write("[");
            for(int j = 0; j < rows; j++) begin
                $write("%5d", X[j]);
            end
            $write("]");
        end

        else begin
            $write("  ");
            for(int j = 0; j < rows; j++) begin
                $write("     ");
            end
        end

        //print *
        if(i == halfway-1) begin
            $write(" * ");
        end else begin
            $write("   ");
        end

        //print left wall of W
        if(i > rows-1)
            $write(" ");
        else
            $write("|");

        //print W
        for(int j = 0; j < cols; j++) begin
            if(i > rows-1)
                $write("     ");
            else
                $write("%5d", W[i][j]);
        end

        //print right wall of W
        if(i > rows-1)
            $write(" ");
        else
            $write("|");

        //print +
        if(i == halfway-1) begin
            $write(" + ");
        end else begin
            $write("   ");
        end

        //print B
        if(i == halfway-1) begin
            $write("[");
            for(int j = 0; j < cols; j++) begin
                $write("%5d", B[j]);
            end
            $write("]");
        end

        //print =
        if(i == halfway-1) begin
            $write(" = ");
        end else begin
            $write("   ");
        end

        //print Y
        if(i == halfway-1) begin
            $write("[");
            for(int j = 0; j < cols; j++) begin
                $write("%5d", Y[j]);
            end
            $write("]");
        end
        $write("\n");
    end
    $write("\n\n");

endtask