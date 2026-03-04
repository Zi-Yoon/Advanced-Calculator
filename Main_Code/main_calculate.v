module main_calculate (
    i_rstn      ,
    i_clk       ,
    i_key_valid ,
    i_bcd_data  ,
    i_state     ,
    i_type      ,
    o_seg_data  ,
    o_led_op    ,
    o_err
);

// Input Key Type
localparam  TYPE_DEF  = 3'd0,
            TYPE_ERR  = 3'd1,
            TYPE_ESC  = 3'd2,
            TYPE_ENT  = 3'd3,
            TYPE_DOT  = 3'd4,
            TYPE_NUM  = 3'd5,
            TYPE_OPER = 3'd6;
            
// State
localparam  ST_INIT     = 3'd0, // INIT
            ST_NUM_A    = 3'd1, // NUM A
            ST_NUM_B    = 3'd2, // NUM B
            ST_RESULT   = 3'd3, // CALCULATE
            ST_KEEP_CAL = 3'd4, // NEXT CALCULATE
            ST_ERROR    = 3'd5; // ERROR

// Input
input         i_rstn      ;
input         i_clk       ;
input         i_key_valid ;
input  [ 4:0] i_bcd_data  ;
input  [ 2:0] i_state     ;
input  [ 2:0] i_type      ;

// Output
output [35:0] o_seg_data    ; // Result
output [ 3:0] o_led_op      ;
output reg    o_err         ;

// Key & State Register
reg [ 2:0]    r_state     ; 
reg           r_first_cal ;
// reg        r_key_valid_now  ; 
// reg        r_key_valid_next ; 

// Dot Location Registe r
reg [ 3:0] r_check_loc   ; // Check Dot Location
reg [ 3:0] r_front_bias_a ; // A Dot Location
reg [ 3:0] r_back_bias_a  ; // A Dot Location
reg [ 3:0] r_temp_bias_a  ; // A Dot Location
reg [ 3:0] r_front_bias_b ; // B Dot Location
reg [ 3:0] r_back_bias_b  ; // B Dot Location
reg [ 3:0] r_temp_bias_b  ; // A Dot Location
reg [ 3:0] r_bias_result ; // Calculating Dot Location
reg        r_dot_valid   ; // Dot Error Checker


// Operator Register
reg [ 1:0] r_oper_a ; 
reg [ 1:0] r_oper_b ;

// Result Register
reg [53:0] r_result ;     // Real Number Result

// BCD Register (4 bit = 1 Digit)
reg [31:0] r_bcd_a      ; // Received A BCD Data
reg [31:0] r_bcd_b      ; // Received B BCD Data
reg [31:0] r_bcd_result ; // r_result ==(BCD Data)==> r_bcd_result

// Number Wire
wire [26:0] w_num_a     ; // r_bcd_a ==(Real Data)==> w_num_a
wire [26:0] w_num_b     ; // r_bcd_b ==(Real Data)==> w_num_b
wire [53:0] w_ex_num_a  ; // r_bcd_a ==(Real Data x 100,000,000)==> w_ex_num_a
wire [53:0] w_ex_num_b  ; // r_bcd_b ==(Real Data x 100,000,000)==> w_ex_num_b
wire        w_neg       ; // w_ex_num_a < w_ex_num_b ? 1 : 0

// Bias Number Wire
wire [26:0] w_bias_a    ; // w_bias_a = 10 ^ r_front_bias_a
wire [26:0] w_bias_b    ; // w_bias_b = 10 ^ r_bias_b
wire [26:0] w_mul_bias  ;
wire [26:0] w_div_bias  ;

// Calculating Wire
wire [53:0] w_calc_digit [15:0] ;

wire [35:0] w_seg_data ;

wire [26:0] w_calc [15:0] ;
wire [ 3:0] w_bcd  [15:0] ;

// r_state : State Register Update
always @(posedge i_clk or negedge i_rstn) begin
    if (!i_rstn) begin
        r_state <= 0;
    end
    else begin
        r_state <= i_state;
    end
end

// Main Logic
always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
        r_result      <= 54'd0 ;
        r_bcd_a       <= 32'd0 ;
        r_oper_a      <=  2'd0 ;
        r_oper_b      <=  2'd0 ;
        r_bcd_b       <= 32'd0 ;
        r_front_bias_a <=  4'd0 ;
        r_back_bias_a  <=  4'd0 ;
        r_temp_bias_a  <=  4'd0 ;
        r_front_bias_b <=  4'd0 ;
        r_back_bias_b  <=  4'd0 ;
        r_temp_bias_b  <=  4'd0 ;
        r_dot_valid   <=  1'b1 ;
        r_first_cal   <=  1'b1 ;
        r_check_loc   <=  4'd0 ;
        r_bcd_result  <= 32'd0 ;
        r_bias_result <=  4'd0 ;
    end
    else begin
        // Init
        if (r_state == ST_INIT) begin 
            r_result      <= 54'd0 ;
            r_bcd_a       <= 32'd0 ;
            r_oper_a      <=  2'd0 ;
            r_oper_b      <=  2'd0 ;
            r_bcd_b       <= 32'd0 ;
            r_front_bias_a <=  4'd0 ;
            r_back_bias_a  <=  4'd0 ;
            r_temp_bias_a  <=  4'd0 ;
            r_front_bias_b <=  4'd0 ;
            r_back_bias_b  <=  4'd0 ;
            r_temp_bias_b  <=  4'd0 ;
            r_dot_valid   <=  1'b1 ;
            r_first_cal   <=  1'b1 ;
            r_check_loc   <=  4'd0 ;
            r_bcd_result  <= 32'd0 ;
            r_bias_result <=  4'd0 ;
        end
        // Number A - One Digit Moving Left
        else if (r_state == ST_NUM_A) begin
            // Dot Input
            if ((i_type == TYPE_DOT) && (r_dot_valid == 1'b1)) begin
                r_front_bias_a <= r_check_loc ;
                r_dot_valid    <= 1'b0 ;
            end
            // Update Number
            else if (i_type == TYPE_NUM) begin
                if (r_front_bias_a == 0) r_temp_bias_a <= 0;
                else r_temp_bias_a <= r_check_loc - r_front_bias_a + 1 ;
                r_bcd_a     <= {r_bcd_a[27:0], i_bcd_data[3:0]} ;
                r_check_loc <= r_check_loc + 1'b1 ;
            end
            // Oper Input
            else if (i_type == TYPE_OPER) begin
                if (r_front_bias_a == 0) r_back_bias_a <= 0;
                else r_back_bias_a <= r_check_loc - r_front_bias_a ;
                r_temp_bias_a <= 4'd0           ;
                r_check_loc <= 4'd0             ;
                r_dot_valid <= 1'b1             ;
                r_oper_a    <= i_bcd_data[1:0]  ;
            end
        end
        // Number B - One Digit Moving Left
        else if (r_state == ST_NUM_B) begin
            // Dot Input
            if ((i_type == TYPE_DOT) && (r_dot_valid == 1'b1)) begin
                r_front_bias_b <= r_check_loc ; 
                r_dot_valid    <= 1'b0 ;
            end
            else if (i_type == TYPE_NUM) begin
                if (r_front_bias_b == 0) r_temp_bias_b <= 0;
                else r_temp_bias_b <= r_check_loc - r_front_bias_b + 1 ;
                r_bcd_b <= {r_bcd_b[27:0], i_bcd_data[3:0]} ;
                r_check_loc <= r_check_loc + 1'b1 ;
            end
            // Make Result - Oper or Ent
            else if (i_type == TYPE_OPER || i_type == TYPE_ENT) begin
                if (r_front_bias_b == 0) r_back_bias_b <= 0;
                else r_back_bias_b <= r_check_loc - r_front_bias_b ;
                if (i_type == TYPE_OPER) r_oper_b <= i_bcd_data[1:0] ;
                r_check_loc <= 4'd0 ;
                r_dot_valid <= 1'b1 ;
                case (r_oper_a)
                    0 : r_result <= (w_num_a * w_div_bias) / w_num_b ; // /
                    1 : r_result <= (w_num_a * w_num_b) * w_mul_bias ; // *
                    2 : r_result <= w_ex_num_a - w_ex_num_b  ;         // - 
                    3 : r_result <= w_ex_num_a + w_ex_num_b  ;         // + 
                    default : r_result <= 0 ;
                endcase
            end
        end
        // Calculate
        else if (r_state == ST_KEEP_CAL) begin
            r_front_bias_a <= 0;
            r_temp_bias_a  <= 0;
            r_front_bias_b <= 0;
            r_temp_bias_b  <= 0;
            r_oper_a <= r_oper_b ;
            r_bcd_b  <= 0;
            if      (w_bcd[ 0] != 0) begin 
                r_bcd_a <= {w_bcd[ 0], w_bcd[ 1], w_bcd[ 2], w_bcd[ 3], w_bcd[ 4], w_bcd[ 5], w_bcd[ 6], w_bcd[ 7]} ;
                r_back_bias_a <= 0 ;
            end
            else if (w_bcd[ 1] != 0) begin 
                r_bcd_a <= {w_bcd[ 1], w_bcd[ 2], w_bcd[ 3], w_bcd[ 4], w_bcd[ 5], w_bcd[ 6], w_bcd[ 7], w_bcd[ 8]} ;
                r_back_bias_a <= 1 ;
            end
            else if (w_bcd[ 2] != 0) begin 
                r_bcd_a <= {w_bcd[ 2], w_bcd[ 3], w_bcd[ 4], w_bcd[ 5], w_bcd[ 6], w_bcd[ 7], w_bcd[ 8], w_bcd[ 9]} ;
                r_back_bias_a <= 2 ;
            end
            else if (w_bcd[ 3] != 0) begin 
                r_bcd_a <= {w_bcd[ 3], w_bcd[ 4], w_bcd[ 5], w_bcd[ 6], w_bcd[ 7], w_bcd[ 8], w_bcd[ 9], w_bcd[10]} ;
                r_back_bias_a <= 3 ;
            end
            else if (w_bcd[ 4] != 0) begin 
                r_bcd_a <= {w_bcd[ 4], w_bcd[ 5], w_bcd[ 6], w_bcd[ 7], w_bcd[ 8], w_bcd[ 9], w_bcd[10], w_bcd[11]} ;
                r_back_bias_a <= 4 ;
            end
            else if (w_bcd[ 5] != 0) begin 
                r_bcd_a <= {w_bcd[ 5], w_bcd[ 6], w_bcd[ 7], w_bcd[ 8], w_bcd[ 9], w_bcd[10], w_bcd[11], w_bcd[12]} ;
                r_back_bias_a <= 5 ;
            end
            else if (w_bcd[ 6] != 0) begin 
                r_bcd_a <= {w_bcd[ 6], w_bcd[ 7], w_bcd[ 8], w_bcd[ 9], w_bcd[10], w_bcd[11], w_bcd[12], w_bcd[13]} ;
                r_back_bias_a <= 6 ;
            end
            else if (w_bcd[ 7] != 0) begin 
                r_bcd_a <= {w_bcd[ 7], w_bcd[ 8], w_bcd[ 9], w_bcd[10], w_bcd[11], w_bcd[12], w_bcd[13], w_bcd[14]} ;
                r_back_bias_a <= 7 ;
            end
            else                     begin 
                r_bcd_a <= {w_bcd[ 7], w_bcd[ 8], w_bcd[ 9], w_bcd[10], w_bcd[11], w_bcd[12], w_bcd[13], w_bcd[14]} ;
                r_back_bias_a <= 7 ;
            end
        end
        // Result
        else if (r_state == ST_RESULT) begin
            r_front_bias_a <= 0;
            r_temp_bias_a  <= 0;
            r_front_bias_b <= 0;
            r_temp_bias_b  <= 0;
            if      (w_bcd[ 0] != 0) begin 
                r_bcd_result <= {w_bcd[ 0], w_bcd[ 1], w_bcd[ 2], w_bcd[ 3], w_bcd[ 4], w_bcd[ 5], w_bcd[ 6], w_bcd[ 7]} ;
                r_bias_result <= 0 ;
            end
            else if (w_bcd[ 1] != 0) begin 
                r_bcd_result <= {w_bcd[ 1], w_bcd[ 2], w_bcd[ 3], w_bcd[ 4], w_bcd[ 5], w_bcd[ 6], w_bcd[ 7], w_bcd[ 8]} ;
                r_bias_result <= 1 ;
            end
            else if (w_bcd[ 2] != 0) begin 
                r_bcd_result <= {w_bcd[ 2], w_bcd[ 3], w_bcd[ 4], w_bcd[ 5], w_bcd[ 6], w_bcd[ 7], w_bcd[ 8], w_bcd[ 9]} ;
                r_bias_result <= 2 ;
            end
            else if (w_bcd[ 3] != 0) begin 
                r_bcd_result <= {w_bcd[ 3], w_bcd[ 4], w_bcd[ 5], w_bcd[ 6], w_bcd[ 7], w_bcd[ 8], w_bcd[ 9], w_bcd[10]} ;
                r_bias_result <= 3 ;
            end
            else if (w_bcd[ 4] != 0) begin 
                r_bcd_result <= {w_bcd[ 4], w_bcd[ 5], w_bcd[ 6], w_bcd[ 7], w_bcd[ 8], w_bcd[ 9], w_bcd[10], w_bcd[11]} ;
                r_bias_result <= 4 ;
            end
            else if (w_bcd[ 5] != 0) begin 
                r_bcd_result <= {w_bcd[ 5], w_bcd[ 6], w_bcd[ 7], w_bcd[ 8], w_bcd[ 9], w_bcd[10], w_bcd[11], w_bcd[12]} ;
                r_bias_result <= 5 ;
            end
            else if (w_bcd[ 6] != 0) begin 
                r_bcd_result <= {w_bcd[ 6], w_bcd[ 7], w_bcd[ 8], w_bcd[ 9], w_bcd[10], w_bcd[11], w_bcd[12], w_bcd[13]} ;
                r_bias_result <= 6 ;
            end
            else if (w_bcd[ 7] != 0) begin 
                r_bcd_result <= {w_bcd[ 7], w_bcd[ 8], w_bcd[ 9], w_bcd[10], w_bcd[11], w_bcd[12], w_bcd[13], w_bcd[14]} ;
                r_bias_result <= 7 ;
            end
            else                     begin 
                r_bcd_result <= {w_bcd[ 7], w_bcd[ 8], w_bcd[ 9], w_bcd[10], w_bcd[11], w_bcd[12], w_bcd[13], w_bcd[14]} ;
                r_bias_result <= 7 ;
            end
        end
        // Error
        else if (r_state == ST_ERROR) begin
            r_result      <= 54'd0 ;
            r_bcd_a       <= 32'd0 ;
            r_oper_a      <=  2'd0 ;
            r_oper_b      <=  2'd0 ;
            r_bcd_b       <= 32'd0 ;
            r_front_bias_a <=  4'd0 ;
            r_back_bias_a  <=  4'd0 ;
            r_temp_bias_a  <=  4'd0 ;
            r_front_bias_b <=  4'd0 ;
            r_back_bias_b  <=  4'd0 ;
            r_temp_bias_b  <=  4'd0 ;
            r_dot_valid   <=  1'b1 ;
            r_first_cal   <=  1'b1 ;
            r_check_loc   <=  4'd0 ;
            r_bcd_result  <= 32'd0 ;
            r_bias_result <=  4'd0 ;
        end
    end
end

// o_err : Check Error
always @(posedge i_clk or negedge i_rstn) begin
    // Reset
    if (!i_rstn) begin
        o_err <= 1'b0;
    end
    // Double Dot
    else if ((i_type == TYPE_DOT) && (r_dot_valid == 0)) begin
        o_err <= 1'b1;
    end
    else if ((r_check_loc > 4'd8)) begin
        o_err <= 1'b1;
    end
    else if (w_calc_digit[7] > 54'd99999999) begin
        o_err <= 1'b1;
    end
    else if (r_oper_a == 2'd2 && w_neg) begin
        o_err <= 1'b1;
    end 
    else if (i_key_valid) begin
        o_err <= 1'b0;
    end
end

// Num  :  1 2 3 4 5 6 7 8 
// Bias : 

// Bias for Multiplication
assign w_mul_bias = ((r_back_bias_a + r_temp_bias_b) == 0) ? 100000000 : 
                    ((r_back_bias_a + r_temp_bias_b) == 1) ? 10000000  : 
                    ((r_back_bias_a + r_temp_bias_b) == 2) ? 1000000   : 
                    ((r_back_bias_a + r_temp_bias_b) == 3) ? 100000    : 
                    ((r_back_bias_a + r_temp_bias_b) == 4) ? 10000     : 
                    ((r_back_bias_a + r_temp_bias_b) == 5) ? 1000      : 
                    ((r_back_bias_a + r_temp_bias_b) == 6) ? 100       : 
                    ((r_back_bias_a + r_temp_bias_b) == 7) ? 10        : 1 ;

assign w_div_bias = ((8 - r_back_bias_a + r_temp_bias_b) == 0) ? 1        : 
                    ((8 - r_back_bias_a + r_temp_bias_b) == 1) ? 10       : 
                    ((8 - r_back_bias_a + r_temp_bias_b) == 2) ? 100      : 
                    ((8 - r_back_bias_a + r_temp_bias_b) == 3) ? 1000     : 
                    ((8 - r_back_bias_a + r_temp_bias_b) == 4) ? 10000    : 
                    ((8 - r_back_bias_a + r_temp_bias_b) == 5) ? 100000   : 
                    ((8 - r_back_bias_a + r_temp_bias_b) == 6) ? 1000000  : 
                    ((8 - r_back_bias_a + r_temp_bias_b) == 7) ? 10000000 : 100000000 ;

// Bias A
assign w_bias_a =   (r_back_bias_a == 0) ? 100000000 : 
                    (r_back_bias_a == 1) ? 10000000  : 
                    (r_back_bias_a == 2) ? 1000000   : 
                    (r_back_bias_a == 3) ? 100000    : 
                    (r_back_bias_a == 4) ? 10000     : 
                    (r_back_bias_a == 5) ? 1000      : 
                    (r_back_bias_a == 6) ? 100       : 
                    (r_back_bias_a == 7) ? 10        : 1 ;

// Bias B
assign w_bias_b =   (r_temp_bias_b == 0) ? 100000000 : 
                    (r_temp_bias_b == 1) ? 10000000  : 
                    (r_temp_bias_b == 2) ? 1000000   : 
                    (r_temp_bias_b == 3) ? 100000    : 
                    (r_temp_bias_b == 4) ? 10000     : 
                    (r_temp_bias_b == 5) ? 1000      : 
                    (r_temp_bias_b == 6) ? 100       : 
                    (r_temp_bias_b == 7) ? 10        : 1 ;

// Number A
assign w_num_a =  (r_bcd_a[31:28] * 10000000) +
                  (r_bcd_a[27:24] * 1000000 ) +
                  (r_bcd_a[23:20] * 100000  ) +
                  (r_bcd_a[19:16] * 10000   ) +
                  (r_bcd_a[15:12] * 1000    ) +
                  (r_bcd_a[11: 8] * 100     ) +
                  (r_bcd_a[ 7: 4] * 10      ) +
                  (r_bcd_a[ 3: 0] * 1       ) ;

// Number B
assign w_num_b =  (r_bcd_b[31:28] * 10000000) +
                  (r_bcd_b[27:24] * 1000000 ) +
                  (r_bcd_b[23:20] * 100000  ) +
                  (r_bcd_b[19:16] * 10000   ) +
                  (r_bcd_b[15:12] * 1000    ) +
                  (r_bcd_b[11: 8] * 100     ) +
                  (r_bcd_b[ 7: 4] * 10      ) +
                  (r_bcd_b[ 3: 0] * 1       ) ;

// Expanded Number A
assign w_ex_num_a = w_num_a * w_bias_a ;

// Expanded Number B
assign w_ex_num_b = w_num_b * w_bias_b ;

// Check Negative
assign w_neg = (w_ex_num_a < w_ex_num_b) ? 1 : 0;

// Calculating
assign w_calc_digit[ 0] = (r_result / 1000000000) / 1000000 ; // 1
assign w_calc_digit[ 1] = (r_result / 1000000000) / 100000 ; // 12
assign w_calc_digit[ 2] = (r_result / 1000000000) / 10000 ; // 123
assign w_calc_digit[ 3] = (r_result / 1000000000) / 1000 ; // 1234
assign w_calc_digit[ 4] = (r_result / 1000000000) / 100 ; // 12345
assign w_calc_digit[ 5] = (r_result / 1000000000) / 10 ; // 123456
assign w_calc_digit[ 6] = r_result / 1000000000 ; // 1234567
assign w_calc_digit[ 7] = r_result / 100000000 ; // 12345678
assign w_calc_digit[ 8] = r_result / 10000000 ; // 123456781
assign w_calc_digit[ 9] = r_result / 1000000 ; // 1234567812
assign w_calc_digit[10] = r_result / 100000 ; // 12345678123
assign w_calc_digit[11] = r_result / 10000 ; // 123456781234
assign w_calc_digit[12] = r_result / 1000 ; // 1234567812345
assign w_calc_digit[13] = r_result / 100 ; // 12345678123456
assign w_calc_digit[14] = r_result / 10 ; // 123456781234567
assign w_calc_digit[15] = r_result / 1 ; // 1234567812345678

assign w_bcd[ 0] = w_calc_digit[ 0]                           ; // 1___ ____ ____ ____
assign w_bcd[ 1] = w_calc_digit[ 1] - (w_calc_digit[ 0] * 10) ; // _2__ ____ ____ ____
assign w_bcd[ 2] = w_calc_digit[ 2] - (w_calc_digit[ 1] * 10) ; // __3_ ____ ____ ____
assign w_bcd[ 3] = w_calc_digit[ 3] - (w_calc_digit[ 2] * 10) ; // ___4 ____ ____ ____
assign w_bcd[ 4] = w_calc_digit[ 4] - (w_calc_digit[ 3] * 10) ; // ____ 5___ ____ ____
assign w_bcd[ 5] = w_calc_digit[ 5] - (w_calc_digit[ 4] * 10) ; // ____ _6__ ____ ____
assign w_bcd[ 6] = w_calc_digit[ 6] - (w_calc_digit[ 5] * 10) ; // ____ __7_ ____ ____
assign w_bcd[ 7] = w_calc_digit[ 7] - (w_calc_digit[ 6] * 10) ; // ____ ___8 ____ ____
assign w_bcd[ 8] = w_calc_digit[ 8] - (w_calc_digit[ 7] * 10) ; // ____ ____ 1___ ____
assign w_bcd[ 9] = w_calc_digit[ 9] - (w_calc_digit[ 8] * 10) ; // ____ ____ _2__ ____
assign w_bcd[10] = w_calc_digit[10] - (w_calc_digit[ 9] * 10) ; // ____ ____ __3_ ____
assign w_bcd[11] = w_calc_digit[11] - (w_calc_digit[10] * 10) ; // ____ ____ ___4 ____
assign w_bcd[12] = w_calc_digit[12] - (w_calc_digit[11] * 10) ; // ____ ____ ____ 5___
assign w_bcd[13] = w_calc_digit[13] - (w_calc_digit[12] * 10) ; // ____ ____ ____ _6__
assign w_bcd[14] = w_calc_digit[14] - (w_calc_digit[13] * 10) ; // ____ ____ ____ __7_
assign w_bcd[15] = w_calc_digit[15] - (w_calc_digit[14] * 10) ; // ____ ____ ____ ___8

// Display Digit
assign w_seg_data = (r_state == ST_INIT    ) ? 36'd0                         :
                    (r_state == ST_NUM_A   ) ? {r_temp_bias_a, r_bcd_a } :
                    (r_state == ST_NUM_B   ) ? {r_temp_bias_b, r_bcd_b     } :
                    (r_state == ST_KEEP_CAL) ? {r_back_bias_a, r_bcd_a     } : 
                    (r_state == ST_RESULT  ) ? {r_bias_result, r_bcd_result} : 36'd0 ;

// Output
assign o_seg_data = w_seg_data ;

// Operation LED
assign o_led_op =   (r_oper_a == 2'd0 && r_state == ST_NUM_B) ? 4'b1110 :
                    (r_oper_a == 2'd1 && r_state == ST_NUM_B) ? 4'b1101 :
                    (r_oper_a == 2'd2 && r_state == ST_NUM_B) ? 4'b1011 :
                    (r_oper_a == 2'd3 && r_state == ST_NUM_B) ? 4'b0111 : 4'b1111 ;

endmodule
