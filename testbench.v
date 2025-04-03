`timescale 1ns / 1ps
`include "CORDIC.v"
module CORDIC_Testbench;
    parameter width = 16;
    reg clock;
    reg signed [width-1:0] x_start, y_start;
    reg signed [31:0] angle;
    wire signed [width-1:0] sine, cosine;

    // Instantiate the CORDIC module
    CORDIC uut (
        .clock(clock),
        .x_start(x_start),
        .y_start(y_start),
        .angle(angle),
        .sine(sine),
        .cosine(cosine)
    );

    // Clock generation (50MHz)
    always #10 clock = ~clock;

    // CORDIC gain (Precomputed for 16 iterations)
    real cordic_gain = 1.64676;  

    // Convert degrees to Q32 fixed-point
    function signed [31:0] deg_to_q32;
        input integer degrees;
        deg_to_q32 = (degrees * 2147483648) / 180; // (2^31 / 180) scaling
    endfunction

    // Convert Q16 to floating-point for readability
    function real q16_to_real;
        input signed [15:0] value;
        q16_to_real = value / 16384.0;
    endfunction

    // Convert Q32 to degrees
    function real q32_to_degrees;
        input signed [31:0] value;
        q32_to_degrees = (value * 180.0) / 2147483648.0; // Reverse scaling
    endfunction

    // Initial block to apply test cases
    integer i, j;
    initial begin
        clock = 0;
        x_start = 16384;   // 1.0 in Q16 format (unit circle)
        y_start = 0;

        // Display CORDIC Gain
        $display("\nCORDIC Gain: %f\n", cordic_gain);

        // Test different angles
        for (i = 0; i < 5; i = i + 1) begin
            angle = deg_to_q32(i * 30); // Test: 0°, 30°, 45°, 60°, 90°

            // Run through iterations
            $display("\nTesting Angle: %d degrees", i * 30);
            $display("Iter | X (Cosine)  | Y (Sine)    | Z (Angle)");
            $display("-----------------------------------------------");

            for (j = 0; j < width; j = j + 1) begin
                #20; // Wait for next iteration
                $display("%2d   | %f  | %f  | %f", 
                    j, 
                    q16_to_real(uut.x[j]) / cordic_gain,  // Apply gain correction
                    q16_to_real(uut.y[j]) / cordic_gain,  // Apply gain correction
                    q32_to_degrees(uut.z[j])              // Convert Z to degrees
                );
            end

            #100; // Wait before next angle test
        end

        $finish;
    end
endmodule
