// Code your design here
module CORDIC(clock, cosine, sine, x_start, y_start, angle);

  parameter width = 16;
  parameter SCALE_FACTOR = 32'h26DD3B6A; // Approx. (0.60725 * 2^32) in fixed-point

  // Inputs
  input clock;
  input signed [width-1:0] x_start, y_start; 
  input signed [31:0] angle;

  // Outputs
  output signed [width-1:0] sine, cosine;

  // Generate table of atan values
  wire signed [31:0] atan_table [0:30];
  
  assign atan_table[00] = 'b00100000000000000000000000000000; // atan(2^0) = 45 degrees
  assign atan_table[01] = 'b00010010111001000000010100011101; // atan(2^-1) = 26.565 degrees
  assign atan_table[02] = 'b00001001111110110011100001011011; // atan(2^-2)
  assign atan_table[03] = 'b00000101000100010001000111010100;
  assign atan_table[04] = 'b00000010100010110000110101000011;
  assign atan_table[05] = 'b00000001010001011101011111100001;
  assign atan_table[06] = 'b00000000101000101111011000011110;
  assign atan_table[07] = 'b00000000010100010111110001010101;
  assign atan_table[08] = 'b00000000001010001011111001010011;
  assign atan_table[09] = 'b00000000000101000101111100101110;
  assign atan_table[10] = 'b00000000000010100010111110011000;
  assign atan_table[11] = 'b00000000000001010001011111001100;
  assign atan_table[12] = 'b00000000000000101000101111100110;
  assign atan_table[13] = 'b00000000000000010100010111110011;
  assign atan_table[14] = 'b00000000000000001010001011111001;
  assign atan_table[15] = 'b00000000000000000101000101111100;
  assign atan_table[16] = 'b00000000000000000010100010111110;
  assign atan_table[17] = 'b00000000000000000001010001011111;
  assign atan_table[18] = 'b00000000000000000000101000101111;
  assign atan_table[19] = 'b00000000000000000000010100010111;
  assign atan_table[20] = 'b00000000000000000000001010001011;
  assign atan_table[21] = 'b00000000000000000000000101000101;
  assign atan_table[22] = 'b00000000000000000000000010100010;
  assign atan_table[23] = 'b00000000000000000000000001010001;
  assign atan_table[24] = 'b00000000000000000000000000101000;
  assign atan_table[25] = 'b00000000000000000000000000010100;
  assign atan_table[26] = 'b00000000000000000000000000001010;
  assign atan_table[27] = 'b00000000000000000000000000000101;
  assign atan_table[28] = 'b00000000000000000000000000000010;
  assign atan_table[29] = 'b00000000000000000000000000000001;
  assign atan_table[30] = 'b00000000000000000000000000000000;

  reg signed [width:0] x [0:width-1];
  reg signed [width:0] y [0:width-1];
  reg signed [31:0] z [0:width-1];

  // Quadrant correction
  wire [1:0] quadrant;
  assign quadrant = angle[31:30];

  always @(posedge clock)
  begin
    case(quadrant)
      2'b00,
      2'b11: begin
        x[0] <= x_start;
        y[0] <= y_start;
        z[0] <= angle;
      end

      2'b01: begin
        x[0] <= -y_start;
        y[0] <= x_start;
        z[0] <= {2'b00,angle[29:0]};
      end

      2'b10: begin
        x[0] <= y_start;
        y[0] <= -x_start;
        z[0] <= {2'b11,angle[29:0]};
      end
    endcase
  end

  // Run through iterations
  genvar i;
  generate
  for (i=0; i < (width-1); i=i+1)
  begin: xyz
    wire z_sign;
    wire signed [width:0] x_shr, y_shr;

    assign x_shr = x[i] >>> i; // Signed shift right
    assign y_shr = y[i] >>> i;
    assign z_sign = z[i][31];

    always @(posedge clock)
    begin
      x[i+1] <= z_sign ? x[i] + y_shr : x[i] - y_shr;
      y[i+1] <= z_sign ? y[i] - x_shr : y[i] + x_shr;
      z[i+1] <= z_sign ? z[i] + atan_table[i] : z[i] - atan_table[i];
    end
  end
  endgenerate

  // Apply scaling correction
  wire signed [31:0] x_scaled, y_scaled;
  assign x_scaled = (x[width-1] * SCALE_FACTOR) >>> 32;
  assign y_scaled = (y[width-1] * SCALE_FACTOR) >>> 32;

  // Assign integer output
  assign cosine = x_scaled[width-1:0];
  assign sine = y_scaled[width-1:0];

endmodule
