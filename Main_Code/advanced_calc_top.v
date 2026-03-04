module advanced_calc_top(
    i_rstn    ,
    i_clk     ,
    i_key_in  ,
    o_key_out ,
    o_seg_d   ,
    o_seg_com ,
    o_led_op
);

// Input
input        i_rstn      ;
input        i_clk       ;
input  [4:0] i_key_in    ;

// Output
output [3:0] o_key_out   ; // 
output [7:0] o_seg_d     ; // 
output [7:0] o_seg_com   ; // 
output [3:0] o_led_op    ; // Operation LED

wire         w_pls_1k     ;
wire  [ 4:0] w_bcd_data   ;
wire  [35:0] w_bcd8d      ;
wire  [ 2:0] w_state      ;
wire  [ 2:0] w_type       ;
wire         w_err        ;
wire         w_key_valid  ;

// Instance
clk_pls U_CLK_PLS(
    .i_clk    (i_clk),
    .i_rstn   (i_rstn),
    .o_pls_1k (w_pls_1k)
);

advanced_calc_fsm U_CALC_FSM (
    .i_clk       (i_clk     ),
    .i_rstn      (i_rstn    ),
    .i_key_valid (w_key_valid),
    .i_bcd_in    (w_bcd_data),
    .i_err_in    (w_err     ),
    .o_type      (w_type    ),
    .o_state     (w_state   )
);

/* |               bcd_data[4:0]              | */
/* |  D: + | 07: 7  | 08: 8 | 09: 9  |  X: F1 | */
/* |  C: - | 04: 4  | 05: 5 | 06: 6  |  X: F2 | */
/* |  B: * | 01: 1  | 02: 2 | 03: 3  |  X: F3 | */
/* |  A: / |  E:Esc | 00: 0 |  F:Ent | 10: .  | */

/* |      Operator     | */
/* |   /   *   -   +   | */
/* |   0   1   2   3   | */

key_func_top U_KEY_FUNC_TOP (
    .i_rstn      (i_rstn   ),
    .i_clk       (i_clk    ),
    .i_pls_1k    (w_pls_1k ),
    .i_key_in    (i_key_in ),
    .o_key_out   (o_key_out),
    .o_bcd_data  (w_bcd_data),
    .o_key_valid (w_key_valid)
);

// Calculator - Make bcd8d : Segment input
main_calculate U_CALCULATE (
    .i_rstn      (i_rstn     ),
    .i_clk       (i_clk      ),
    .i_key_valid (w_key_valid),
    .i_bcd_data  (w_bcd_data ),
    .i_state     (w_state    ),
    .i_type      (w_type     ),
    .o_seg_data  (w_bcd8d    ),
    .o_led_op    (o_led_op   ),
    .o_err       (w_err      )
);

// 7-Segment
segment_digit U_SEG (
    .i_rstn    (i_rstn   ),
    .i_clk     (i_clk    ),
    .i_pls_1k  (w_pls_1k ),
    .i_bcd8d   (w_bcd8d  ),
    .i_err     (w_err    ),
    .o_seg_d   (o_seg_d  ),
    .o_seg_com (o_seg_com)  
);

endmodule