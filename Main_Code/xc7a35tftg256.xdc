#=============================================================================================#
# XDC File                                                                                    #
# Target Project : Advanced Calculator                                                        #
# Target Board   : XC7A35T-FTG256-1                                                           #
# Author         : An JiYoon (ZY)                                                             #
#=============================================================================================#

#---------------------------------------------------------------------------------------------
# | CLK |
#---------------------------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN D4     IOSTANDARD LVCMOS33 } [get_ports { i_clk }]

#---------------------------------------------------------------------------------------------
# | RESET |
#---------------------------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN D3     IOSTANDARD LVCMOS33 } [get_ports { i_rstn }]

#---------------------------------------------------------------------------------------------
# | TLED | - Top 4 LED
#---------------------------------------------------------------------------------------------
# set_property -dict { PACKAGE_PIN C11    IOSTANDARD LVCMOS33 } [get_ports { o_TLED[0] }]
# set_property -dict { PACKAGE_PIN D10    IOSTANDARD LVCMOS33 } [get_ports { o_TLED[1] }]
# set_property -dict { PACKAGE_PIN D9     IOSTANDARD LVCMOS33 } [get_ports { o_TLED[2] }]
# set_property -dict { PACKAGE_PIN C9     IOSTANDARD LVCMOS33 } [get_ports { o_TLED[3] }]

#---------------------------------------------------------------------------------------------
# | KLED | - Left 4 LED
#---------------------------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN C13    IOSTANDARD LVCMOS33 } [get_ports { o_led_op[0] }]
set_property -dict { PACKAGE_PIN H16    IOSTANDARD LVCMOS33 } [get_ports { o_led_op[1] }]
set_property -dict { PACKAGE_PIN F15    IOSTANDARD LVCMOS33 } [get_ports { o_led_op[2] }]
set_property -dict { PACKAGE_PIN C16    IOSTANDARD LVCMOS33 } [get_ports { o_led_op[3] }]

#---------------------------------------------------------------------------------------------
# | LED | - Bottom 8 LED
#---------------------------------------------------------------------------------------------
# set_property -dict { PACKAGE_PIN G12    IOSTANDARD LVCMOS33 } [get_ports { o_LED[0] }]
# set_property -dict { PACKAGE_PIN G14    IOSTANDARD LVCMOS33 } [get_ports { o_LED[1] }]
# set_property -dict { PACKAGE_PIN F13    IOSTANDARD LVCMOS33 } [get_ports { o_LED[2] }]
# set_property -dict { PACKAGE_PIN F14    IOSTANDARD LVCMOS33 } [get_ports { o_LED[3] }]
# set_property -dict { PACKAGE_PIN E12    IOSTANDARD LVCMOS33 } [get_ports { o_LED[4] }]
# set_property -dict { PACKAGE_PIN E13    IOSTANDARD LVCMOS33 } [get_ports { o_LED[5] }]
# set_property -dict { PACKAGE_PIN C14    IOSTANDARD LVCMOS33 } [get_ports { o_LED[6] }]
# set_property -dict { PACKAGE_PIN D14    IOSTANDARD LVCMOS33 } [get_ports { o_LED[7] }]

#---------------------------------------------------------------------------------------------
# | SW |
#---------------------------------------------------------------------------------------------
# set_property -dict { PACKAGE_PIN H13     IOSTANDARD LVCMOS33 } [get_ports { i_MODE  }]
# set_property -dict { PACKAGE_PIN H14     IOSTANDARD LVCMOS33 } [get_ports { i_CLEAR }]

#---------------------------------------------------------------------------------------------
# | ROTARY |
#---------------------------------------------------------------------------------------------
# set_property -dict { PACKAGE_PIN J15     IOSTANDARD LVCMOS33 } [get_ports { i_ROTARY[0] }]
# set_property -dict { PACKAGE_PIN H12     IOSTANDARD LVCMOS33 } [get_ports { i_ROTARY[1] }]
# set_property -dict { PACKAGE_PIN J16     IOSTANDARD LVCMOS33 } [get_ports { i_ROTARY[2] }]
# set_property -dict { PACKAGE_PIN F12     IOSTANDARD LVCMOS33 } [get_ports { i_ROTARY[3] }]

#---------------------------------------------------------------------------------------------
# | DIP_SW |
#---------------------------------------------------------------------------------------------
# set_property -dict { PACKAGE_PIN ?     IOSTANDARD LVCMOS33 } [get_ports { ? }]

#---------------------------------------------------------------------------------------------
# | Numpad |
#---------------------------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN D15     IOSTANDARD LVCMOS33 } [get_ports { i_key_in[4] }]
set_property -dict { PACKAGE_PIN C12     IOSTANDARD LVCMOS33 } [get_ports { i_key_in[3] }]
set_property -dict { PACKAGE_PIN D16     IOSTANDARD LVCMOS33 } [get_ports { i_key_in[2] }]
set_property -dict { PACKAGE_PIN G15     IOSTANDARD LVCMOS33 } [get_ports { i_key_in[1] }]
set_property -dict { PACKAGE_PIN E15     IOSTANDARD LVCMOS33 } [get_ports { i_key_in[0] }]

#---------------------------------------------------------------------------------------------
# | Numpad |
#---------------------------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN D11     IOSTANDARD LVCMOS33 } [get_ports { o_key_out[3] }]
set_property -dict { PACKAGE_PIN E16     IOSTANDARD LVCMOS33 } [get_ports { o_key_out[2] }]
set_property -dict { PACKAGE_PIN G16     IOSTANDARD LVCMOS33 } [get_ports { o_key_out[1] }]
set_property -dict { PACKAGE_PIN D13     IOSTANDARD LVCMOS33 } [get_ports { o_key_out[0] }]

#---------------------------------------------------------------------------------------------
# | Segment Select |
#---------------------------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN D8      IOSTANDARD LVCMOS33 } [get_ports { o_seg_com[7] }]
set_property -dict { PACKAGE_PIN C8      IOSTANDARD LVCMOS33 } [get_ports { o_seg_com[6] }]
set_property -dict { PACKAGE_PIN H11     IOSTANDARD LVCMOS33 } [get_ports { o_seg_com[5] }]
set_property -dict { PACKAGE_PIN G11     IOSTANDARD LVCMOS33 } [get_ports { o_seg_com[4] }]
set_property -dict { PACKAGE_PIN A9      IOSTANDARD LVCMOS33 } [get_ports { o_seg_com[3] }]
set_property -dict { PACKAGE_PIN B9      IOSTANDARD LVCMOS33 } [get_ports { o_seg_com[2] }]
set_property -dict { PACKAGE_PIN A10     IOSTANDARD LVCMOS33 } [get_ports { o_seg_com[1] }]
set_property -dict { PACKAGE_PIN B10     IOSTANDARD LVCMOS33 } [get_ports { o_seg_com[0] }]

#---------------------------------------------------------------------------------------------
# | Segment Data |
#---------------------------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN A13     IOSTANDARD LVCMOS33 } [get_ports { o_seg_d[7] }]
set_property -dict { PACKAGE_PIN B12     IOSTANDARD LVCMOS33 } [get_ports { o_seg_d[6] }]
set_property -dict { PACKAGE_PIN A12     IOSTANDARD LVCMOS33 } [get_ports { o_seg_d[5] }]
set_property -dict { PACKAGE_PIN B11     IOSTANDARD LVCMOS33 } [get_ports { o_seg_d[4] }]
set_property -dict { PACKAGE_PIN B15     IOSTANDARD LVCMOS33 } [get_ports { o_seg_d[3] }]
set_property -dict { PACKAGE_PIN A15     IOSTANDARD LVCMOS33 } [get_ports { o_seg_d[2] }]
set_property -dict { PACKAGE_PIN B14     IOSTANDARD LVCMOS33 } [get_ports { o_seg_d[1] }]
set_property -dict { PACKAGE_PIN A14     IOSTANDARD LVCMOS33 } [get_ports { o_seg_d[0] }]
