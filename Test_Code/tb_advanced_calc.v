`timescale 1ns / 1ps

module advanced_calc_top_tb;

// Inputs
reg i_rstn;
reg i_clk;
// reg [4:0] i_key_in;
reg [4:0] i_bcd_data;
reg i_key_valid;

// Outputs
wire [3:0] o_key_out;
wire [7:0] o_seg_d;
wire [7:0] o_seg_com;
wire [3:0] o_led_op;

// Instantiate the Unit Under Test (UUT)
advanced_calc_top uut (
    .i_rstn(i_rstn), 
    .i_clk(i_clk), 
//    .i_key_in(i_key_in), 
    .i_bcd_data(i_bcd_data),
    .i_key_valid(i_key_valid).
    .o_key_out(o_key_out), 
    .o_seg_d(o_seg_d), 
    .o_seg_com(o_seg_com), 
    .o_led_op(o_led_op)
);

// Clock process
initial begin
    i_clk = 0;
    forever #10 i_clk = ~i_clk;
end

// Test process
initial begin
    // Initialize Inputs
    i_rstn = 0;

    // Reset the system
    #10 i_rstn = 1;
    #10 i_rstn = 0;
    #10 i_rstn = 1;

    // Wait for the system to stabilize
    #100;

    // 1 2 3 
    #10 i_bcd_data = 5'h1; i_key_valid = 1'b1;
    #10 i_bcd_data = 5'h2; i_key_valid = 1'b1;
    #10 i_bcd_data = 5'h3; i_key_valid = 1'b1;

    // +
    #10 i_bcd_data = 5'h13; i_key_valid = 1'b1;

    // 4 5 6
    #10 i_bcd_data = 5'h4; i_key_valid = 1'b1;
    #10 i_bcd_data = 5'h5; i_key_valid = 1'b1;
    #10 i_bcd_data = 5'h6; i_key_valid = 1'b1;

    // =
    #10 i_bcd_data = 5'h15; i_key_valid = 1'b1;

    // ESC
    #10 i_bcd_data = 5'h14; i_key_valid = 1'b1;

    // Finish the simulation
    #1000 $finish;
end
endmodule
