`timescale 1ns / 1ps

module advanced_calc_top_tb;

    // Inputs
    reg i_rstn;
    reg i_clk;
    reg [4:0] i_key_in;

    // Outputs
    wire [3:0] o_key_out;
    wire [7:0] o_seg_d;
    wire [7:0] o_seg_com;
    wire [3:0] o_led_op;

    // Instantiate the Unit Under Test (UUT)
    advanced_calc_top uut (
        .i_rstn(i_rstn), 
        .i_clk(i_clk), 
        .i_key_in(i_key_in), 
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
        i_key_in = 0;

        // Reset the system
        #10 i_rstn = 1;
        #10 i_rstn = 0;
        #10 i_rstn = 1;

        // Wait for the system to stabilize
        #100;

        // Add your test cases here
        i_key_in = 5'b00001; // Simulating key press
        #10 i_key_in = 5'b00000; // Releasing key

        // Additional test cases can be added here

        // Finish the simulation
        #1000 $finish;
    end
endmodule
