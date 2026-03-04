module segment_digit(
    i_rstn   ,
    i_clk    ,
    i_pls_1k ,
    i_bcd8d  ,
    i_err    ,
    o_seg_d  ,
    o_seg_com
);

/* ------------- */
/*   7-Segment   */
/* ------------- */
/*   ┌──A──┐     */
/*   F     B     */
/*   │──G──│     */
/*   E     C     */
/*   └──D──┘  H  */
/* ------------- */

// Input
input           i_rstn     ;
input           i_clk      ;
input           i_pls_1k   ;
input   [34:0]  i_bcd8d    ;
input           i_err      ;

// Output
output  [7:0]   o_seg_d    ;
output  [7:0]   o_seg_com  ;

// Register
reg  [3:0] r_bias     ;
reg  [2:0] r_cnt_com  ;
reg  [7:0] r_seg_com  ;
reg  [7:0] r_seg_d    ;

// Wire
wire  [3:0] w_bcd_sel   ;
wire  [6:0] w_seg_digit ;
wire  [6:0] w_seg_err   ;
wire  [7:0] w_seg_com   ;
wire  [7:0] w_bias      ;


always @(posedge i_clk or negedge i_rstn) begin
    if (!i_rstn) begin
        r_cnt_com <= 3'd0 ;
    end
    else if(i_pls_1k) begin
        if (r_cnt_com == 3'd7) begin
            r_cnt_com <= 3'd0 ;
        end
        else begin
            r_cnt_com <= r_cnt_com + 1 ;
        end
    end
end

always @(posedge i_clk or negedge i_rstn) begin
    if (!i_rstn) begin
        r_seg_com <= 8'h0;
        r_seg_d   <= 8'h0;
    end 
    else if (i_pls_1k) begin
        if (i_err) begin
            r_seg_com <= {3'b000, w_seg_com[4:0]} ;
            r_seg_d   <= {  1'b1, w_seg_err     } ;
        end
        else begin
            casez (i_bcd8d[31: 0])
                32'b0000_0000_0000_0000_0000_0000_0000_0000: r_seg_com <=  8'b00000001                 ;
                32'b0000_0000_0000_0000_0000_0000_0000_????: r_seg_com <= {7'b0000000, w_seg_com[  0]} ;
                32'b0000_0000_0000_0000_0000_0000_????_????: r_seg_com <= {6'b000000,  w_seg_com[1:0]} ;
                32'b0000_0000_0000_0000_0000_????_????_????: r_seg_com <= {5'b00000,   w_seg_com[2:0]} ;
                32'b0000_0000_0000_0000_????_????_????_????: r_seg_com <= {4'b0000,    w_seg_com[3:0]} ;
                32'b0000_0000_0000_????_????_????_????_????: r_seg_com <= {3'b000,     w_seg_com[4:0]} ;
                32'b0000_0000_????_????_????_????_????_????: r_seg_com <= {2'b00,      w_seg_com[5:0]} ;
                32'b0000_????_????_????_????_????_????_????: r_seg_com <= {1'b0,       w_seg_com[6:0]} ;
                default: r_seg_com <= w_seg_com ;
            endcase
            if (r_seg_com == w_bias) r_seg_d <= {1'b1, w_seg_digit} ;
            else                     r_seg_d <= {1'b0, w_seg_digit} ;
        end
    end
end

// 7-Segment : Error
assign w_seg_err =
    (r_cnt_com == 0) ? 7'b0000000 : // 
    (r_cnt_com == 1) ? 7'b0000000 : // 
    (r_cnt_com == 2) ? 7'b0000000 : // 
    (r_cnt_com == 3) ? 7'b1111001 : // E
    (r_cnt_com == 4) ? 7'b1010000 : // r
    (r_cnt_com == 5) ? 7'b1010000 : // r
    (r_cnt_com == 6) ? 7'b1011100 : // o
                       7'b1010000 ; // r

// BCD
assign w_bcd_sel =
    (r_cnt_com == 0) ? i_bcd8d[31:28] : // 
    (r_cnt_com == 1) ? i_bcd8d[27:24] : // 
    (r_cnt_com == 2) ? i_bcd8d[23:20] : // 
    (r_cnt_com == 3) ? i_bcd8d[19:16] : // 
    (r_cnt_com == 4) ? i_bcd8d[15:12] : // 
    (r_cnt_com == 5) ? i_bcd8d[11: 8] : // 
    (r_cnt_com == 6) ? i_bcd8d[ 7: 4] : // 
                       i_bcd8d[ 3: 0] ; // 

// Bias
assign w_bias = 
    (i_bcd8d[34:31] == 0) ? 8'b00000001 :
    (i_bcd8d[34:31] == 1) ? 8'b00000010 :
    (i_bcd8d[34:31] == 2) ? 8'b00000100 :
    (i_bcd8d[34:31] == 3) ? 8'b00001000 :
    (i_bcd8d[34:31] == 4) ? 8'b00010000 :
    (i_bcd8d[34:31] == 5) ? 8'b00100000 :
    (i_bcd8d[34:31] == 6) ? 8'b01000000 :
    (i_bcd8d[34:31] == 7) ? 8'b10000000 :
                            8'b00000000 ;

// 7-Segment : Digit 0 ~ 9
assign w_seg_digit =
    (w_bcd_sel == 4'h0) ? 7'b0111111 : // 0
    (w_bcd_sel == 4'h1) ? 7'b0000110 : // 1
    (w_bcd_sel == 4'h2) ? 7'b1011011 : // 2
    (w_bcd_sel == 4'h3) ? 7'b1001111 : // 3
    (w_bcd_sel == 4'h4) ? 7'b1100110 : // 4
    (w_bcd_sel == 4'h5) ? 7'b1101101 : // 5
    (w_bcd_sel == 4'h6) ? 7'b1111101 : // 6
    (w_bcd_sel == 4'h7) ? 7'b0100111 : // 7
    (w_bcd_sel == 4'h8) ? 7'b1111111 : // 8
    (w_bcd_sel == 4'h9) ? 7'b1101111 : // 9
                          7'b0000000 ; // x

assign w_seg_com =
    (r_cnt_com == 0) ? 8'b10000000 : // 
    (r_cnt_com == 1) ? 8'b01000000 : // 
    (r_cnt_com == 2) ? 8'b00100000 : // 
    (r_cnt_com == 3) ? 8'b00010000 : // 
    (r_cnt_com == 4) ? 8'b00001000 : // 
    (r_cnt_com == 5) ? 8'b00000100 : // 
    (r_cnt_com == 6) ? 8'b00000010 : // 
                       8'b00000001 ; // 

assign o_seg_d   = r_seg_d   ;
assign o_seg_com = r_seg_com ;

endmodule