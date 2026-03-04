module advanced_calc_fsm (
    i_clk       ,
    i_rstn      ,
    i_key_valid ,
    i_bcd_in    ,
    i_err_in    ,
    o_type      ,
    o_state
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
localparam  ST_INIT      = 3'd0, // INIT
            ST_NUM_A     = 3'd1, // NUM A
            ST_NUM_B     = 3'd2, // NUM B
            ST_RESULT    = 3'd3, // CALCULATE
            ST_KEEP_CALC = 3'd4, // NEXT CALCULATE
            ST_ERROR     = 3'd5; // ERROR

// Input
input       i_clk       ; 
input       i_rstn      ; 
input       i_key_valid ; // Key Valid
input [4:0] i_bcd_in    ; // Key Data
input       i_err_in    ; // Error occured

// Output
output [2:0] o_type     ; 
output [2:0] o_state    ; 

// State Register
reg [2:0]   c_state ; // Current State
reg [2:0]   n_state ; // Next State

// Register
reg [2:0]   r_type      ; // Key Type


// State Register Update
always @(posedge i_clk or negedge i_rstn) begin
    if (!i_rstn) begin
        c_state <= ST_INIT;
    end
    else begin
        c_state <= n_state;
    end
end

// Key Input : State Change Enable Signal (i_bcd_in)
always @(posedge i_clk or negedge i_rstn) begin
    if (!i_rstn) begin
        r_type <= TYPE_DEF;
    end
    else begin
        if (i_err_in == 1'b1)                        r_type <= TYPE_ERR  ; // Error
        else if ((i_bcd_in == 5'h14 && i_key_valid)) r_type <= TYPE_ESC  ; // ESC
        else if ((i_bcd_in == 5'h15 && i_key_valid)) r_type <= TYPE_ENT  ; // Enter
        else if ((i_bcd_in == 5'h1A && i_key_valid)) r_type <= TYPE_DOT  ; // Dot
        else if ((i_bcd_in <= 5'h9  && i_key_valid)) r_type <= TYPE_NUM  ; // Num
        else if ((i_bcd_in <= 5'h13 &&  
                  i_bcd_in >= 5'h10) && i_key_valid) r_type <= TYPE_OPER ; // Oper
        else                                         r_type <= TYPE_DEF  ; // Default
    end
end

assign o_type = r_type;

// Next State Logic
always @(*) begin
    // Always Check (Error -> Enter -> Oper/Num)
    case (c_state)
        ST_INIT: begin
            if (r_type == TYPE_ESC) begin
                n_state = ST_INIT;
            end
            else if (r_type == TYPE_ERR) begin
                n_state = ST_ERROR;
            end
            else if (r_type == TYPE_ENT) begin
                n_state = ST_RESULT;
            end
            else begin
                n_state = ST_NUM_A;
            end
        end
        ST_NUM_A: begin
            if (r_type == TYPE_ESC) begin
                n_state = ST_INIT;
            end
            else if (r_type == TYPE_ERR) begin
                n_state = ST_ERROR;
            end
            else if (r_type == TYPE_OPER) begin
                n_state = ST_NUM_B;
            end
            else begin
                n_state = ST_NUM_A;
            end
        end
        ST_NUM_B: begin
            if (r_type == TYPE_ESC) begin
                n_state = ST_INIT;
            end
            else if (r_type == TYPE_ERR) begin
                n_state = ST_ERROR;
            end
            else if (r_type == TYPE_ENT) begin
                n_state = ST_RESULT;
            end
            else if (r_type == TYPE_OPER) begin
                n_state = ST_KEEP_CALC;
            end
            else begin
                n_state = ST_NUM_B;
            end
        end
        ST_KEEP_CALC: begin
            if (r_type == TYPE_ESC) begin
                n_state = ST_INIT;
            end
            else if (r_type == TYPE_ERR) begin
                n_state = ST_ERROR;
            end
            else if (r_type == TYPE_NUM) begin
                n_state = ST_NUM_B;
            end
            else begin
                n_state = ST_KEEP_CALC;
            end
        end
        ST_RESULT: begin
            if (r_type == TYPE_ESC) begin
                n_state = ST_INIT;
            end
            else if (r_type == TYPE_ERR) begin
                n_state = ST_ERROR;
            end
            // After Any Key Pressed -> INIT
            else if (r_type > TYPE_ESC && r_type <= TYPE_OPER) begin
                n_state = ST_INIT;
            end
            else begin
                n_state = ST_RESULT;
            end
        end
        ST_ERROR: begin
            if (r_type >= TYPE_ESC && r_type <= TYPE_OPER) begin
                n_state = ST_INIT;
            end
            else begin
                n_state = ST_ERROR;
            end
        end
        default: n_state = ST_INIT;
    endcase
end

// Output Logic
assign o_state = c_state;

endmodule