// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
// Date        : Thu Nov  5 13:25:58 2026
// Host        : DESKTOP-N301Q0S running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               c:/Kevin/lab_fsm/lab_fsm.gen/sources_1/bd/hardware/ip/hardware_fsm_controller_0_0/hardware_fsm_controller_0_0_sim_netlist.v
// Design      : hardware_fsm_controller_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "hardware_fsm_controller_0_0,fsm_controller,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* ip_definition_source = "module_ref" *) 
(* x_core_info = "fsm_controller,Vivado 2024.2" *) 
(* NotValidForBitStream *)
module hardware_fsm_controller_0_0
   (clk,
    rst,
    mode,
    tick,
    val,
    leds,
    s_axis_tdata,
    s_axis_tkeep,
    s_axis_tvalid,
    s_axis_tready,
    s_axis_tlast);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk CLK" *) (* x_interface_mode = "slave clk" *) (* x_interface_parameter = "XIL_INTERFACENAME clk, ASSOCIATED_BUSIF s_axis, ASSOCIATED_RESET rst, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN hardware_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *) input clk;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 rst RST" *) (* x_interface_mode = "slave rst" *) (* x_interface_parameter = "XIL_INTERFACENAME rst, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input rst;
  input [2:0]mode;
  input tick;
  input [3:0]val;
  output [3:0]leds;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 s_axis TDATA" *) (* x_interface_mode = "slave s_axis" *) (* x_interface_parameter = "XIL_INTERFACENAME s_axis, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN hardware_processing_system7_0_0_FCLK_CLK0, LAYERED_METADATA undef, INSERT_VIP 0" *) input [31:0]s_axis_tdata;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 s_axis TKEEP" *) input [3:0]s_axis_tkeep;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 s_axis TVALID" *) input s_axis_tvalid;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 s_axis TREADY" *) output s_axis_tready;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 s_axis TLAST" *) input s_axis_tlast;

  wire clk;
  wire [3:0]leds;
  wire [2:0]mode;
  wire rst;
  wire [31:0]s_axis_tdata;
  wire s_axis_tready;
  wire s_axis_tvalid;
  wire tick;
  wire [3:0]val;

  hardware_fsm_controller_0_0_fsm_controller U0
       (.Q(leds),
        .clk(clk),
        .mode(mode),
        .rst(rst),
        .s_axis_tdata(s_axis_tdata[3:0]),
        .s_axis_tready(s_axis_tready),
        .s_axis_tvalid(s_axis_tvalid),
        .tick(tick),
        .val(val));
endmodule

(* ORIG_REF_NAME = "fsm_controller" *) 
module hardware_fsm_controller_0_0_fsm_controller
   (Q,
    s_axis_tready,
    tick,
    clk,
    mode,
    s_axis_tvalid,
    s_axis_tdata,
    val,
    rst);
  output [3:0]Q;
  output s_axis_tready;
  input tick;
  input clk;
  input [2:0]mode;
  input s_axis_tvalid;
  input [3:0]s_axis_tdata;
  input [3:0]val;
  input rst;

  wire [3:0]Q;
  wire clk;
  wire [3:0]led_reg;
  wire \led_reg[0]_i_2_n_0 ;
  wire \led_reg[0]_i_3_n_0 ;
  wire \led_reg[1]_i_2_n_0 ;
  wire \led_reg[2]_i_2_n_0 ;
  wire \led_reg[3]_i_2_n_0 ;
  wire \led_reg[3]_i_4_n_0 ;
  wire [2:0]mode;
  wire p_0_in;
  wire rst;
  wire [3:0]s_axis_tdata;
  wire s_axis_tready;
  wire s_axis_tvalid;
  wire [2:0]state;
  wire \state[0]_i_1_n_0 ;
  wire \state[1]_i_1_n_0 ;
  wire \state[2]_i_1_n_0 ;
  wire tick;
  wire tick_prev;
  wire [3:0]val;

  LUT5 #(
    .INIT(32'hB8BBB888)) 
    \led_reg[0]_i_1 
       (.I0(s_axis_tdata[0]),
        .I1(state[2]),
        .I2(\led_reg[0]_i_2_n_0 ),
        .I3(state[1]),
        .I4(\led_reg[0]_i_3_n_0 ),
        .O(led_reg[0]));
  LUT3 #(
    .INIT(8'hB8)) 
    \led_reg[0]_i_2 
       (.I0(val[0]),
        .I1(state[0]),
        .I2(Q[1]),
        .O(\led_reg[0]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'h0002FFFF)) 
    \led_reg[0]_i_3 
       (.I0(Q[3]),
        .I1(Q[0]),
        .I2(Q[2]),
        .I3(Q[1]),
        .I4(state[0]),
        .O(\led_reg[0]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \led_reg[1]_i_1 
       (.I0(s_axis_tdata[1]),
        .I1(state[2]),
        .I2(\led_reg[1]_i_2_n_0 ),
        .O(led_reg[1]));
  LUT5 #(
    .INIT(32'hAFA0C0C0)) 
    \led_reg[1]_i_2 
       (.I0(val[1]),
        .I1(Q[2]),
        .I2(state[1]),
        .I3(Q[0]),
        .I4(state[0]),
        .O(\led_reg[1]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \led_reg[2]_i_1 
       (.I0(s_axis_tdata[2]),
        .I1(state[2]),
        .I2(\led_reg[2]_i_2_n_0 ),
        .O(led_reg[2]));
  LUT5 #(
    .INIT(32'hAFA0C0C0)) 
    \led_reg[2]_i_2 
       (.I0(val[2]),
        .I1(Q[3]),
        .I2(state[1]),
        .I3(Q[1]),
        .I4(state[0]),
        .O(\led_reg[2]_i_2_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \led_reg[3]_i_1 
       (.I0(rst),
        .O(p_0_in));
  LUT5 #(
    .INIT(32'h0000A8AA)) 
    \led_reg[3]_i_2 
       (.I0(tick),
        .I1(state[1]),
        .I2(s_axis_tvalid),
        .I3(state[2]),
        .I4(tick_prev),
        .O(\led_reg[3]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hB8BBB888B888B888)) 
    \led_reg[3]_i_3 
       (.I0(s_axis_tdata[3]),
        .I1(state[2]),
        .I2(\led_reg[3]_i_4_n_0 ),
        .I3(state[1]),
        .I4(Q[2]),
        .I5(state[0]),
        .O(led_reg[3]));
  LUT6 #(
    .INIT(64'h8888888888888B88)) 
    \led_reg[3]_i_4 
       (.I0(val[3]),
        .I1(state[0]),
        .I2(Q[1]),
        .I3(Q[0]),
        .I4(Q[2]),
        .I5(Q[3]),
        .O(\led_reg[3]_i_4_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \led_reg_reg[0] 
       (.C(clk),
        .CE(\led_reg[3]_i_2_n_0 ),
        .D(led_reg[0]),
        .Q(Q[0]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \led_reg_reg[1] 
       (.C(clk),
        .CE(\led_reg[3]_i_2_n_0 ),
        .D(led_reg[1]),
        .Q(Q[1]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \led_reg_reg[2] 
       (.C(clk),
        .CE(\led_reg[3]_i_2_n_0 ),
        .D(led_reg[2]),
        .Q(Q[2]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \led_reg_reg[3] 
       (.C(clk),
        .CE(\led_reg[3]_i_2_n_0 ),
        .D(led_reg[3]),
        .Q(Q[3]),
        .R(p_0_in));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h00000200)) 
    s_axis_tready_INST_0
       (.I0(tick),
        .I1(mode[1]),
        .I2(mode[0]),
        .I3(mode[2]),
        .I4(tick_prev),
        .O(s_axis_tready));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \state[0]_i_1 
       (.I0(mode[0]),
        .I1(mode[2]),
        .O(\state[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \state[1]_i_1 
       (.I0(mode[1]),
        .I1(mode[2]),
        .O(\state[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT3 #(
    .INIT(8'h10)) 
    \state[2]_i_1 
       (.I0(mode[1]),
        .I1(mode[0]),
        .I2(mode[2]),
        .O(\state[2]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \state_reg[0] 
       (.C(clk),
        .CE(1'b1),
        .D(\state[0]_i_1_n_0 ),
        .Q(state[0]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \state_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(\state[1]_i_1_n_0 ),
        .Q(state[1]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \state_reg[2] 
       (.C(clk),
        .CE(1'b1),
        .D(\state[2]_i_1_n_0 ),
        .Q(state[2]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    tick_prev_reg
       (.C(clk),
        .CE(1'b1),
        .D(tick),
        .Q(tick_prev),
        .R(p_0_in));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
