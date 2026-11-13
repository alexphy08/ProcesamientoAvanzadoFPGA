// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
// Date        : Thu Nov  5 13:25:58 2026
// Host        : DESKTOP-N301Q0S running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               c:/Kevin/lab_fsm/lab_fsm.gen/sources_1/bd/hardware/ip/hardware_stream_transform_0_0/hardware_stream_transform_0_0_sim_netlist.v
// Design      : hardware_stream_transform_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "hardware_stream_transform_0_0,stream_transform,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* ip_definition_source = "module_ref" *) 
(* x_core_info = "stream_transform,Vivado 2024.2" *) 
(* NotValidForBitStream *)
module hardware_stream_transform_0_0
   (aclk,
    aresetn,
    s_axis_tdata,
    s_axis_tkeep,
    s_axis_tvalid,
    s_axis_tready,
    s_axis_tlast,
    m_axis_tdata,
    m_axis_tkeep,
    m_axis_tvalid,
    m_axis_tready,
    m_axis_tlast);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 aclk CLK" *) (* x_interface_mode = "slave aclk" *) (* x_interface_parameter = "XIL_INTERFACENAME aclk, ASSOCIATED_BUSIF m_axis:s_axis, ASSOCIATED_RESET aresetn, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN hardware_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *) input aclk;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 aresetn RST" *) (* x_interface_mode = "slave aresetn" *) (* x_interface_parameter = "XIL_INTERFACENAME aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input aresetn;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 s_axis TDATA" *) (* x_interface_mode = "slave s_axis" *) (* x_interface_parameter = "XIL_INTERFACENAME s_axis, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN hardware_processing_system7_0_0_FCLK_CLK0, LAYERED_METADATA undef, INSERT_VIP 0" *) input [31:0]s_axis_tdata;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 s_axis TKEEP" *) input [3:0]s_axis_tkeep;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 s_axis TVALID" *) input s_axis_tvalid;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 s_axis TREADY" *) output s_axis_tready;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 s_axis TLAST" *) input s_axis_tlast;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 m_axis TDATA" *) (* x_interface_mode = "master m_axis" *) (* x_interface_parameter = "XIL_INTERFACENAME m_axis, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN hardware_processing_system7_0_0_FCLK_CLK0, LAYERED_METADATA undef, INSERT_VIP 0" *) output [31:0]m_axis_tdata;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 m_axis TKEEP" *) output [3:0]m_axis_tkeep;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 m_axis TVALID" *) output m_axis_tvalid;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 m_axis TREADY" *) input m_axis_tready;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 m_axis TLAST" *) output m_axis_tlast;

  wire \<const0> ;
  wire aclk;
  wire aresetn;
  wire [31:1]\^m_axis_tdata ;
  wire m_axis_tlast;
  wire m_axis_tready;
  wire m_axis_tvalid;
  wire [31:0]s_axis_tdata;
  wire [3:0]s_axis_tkeep;
  wire s_axis_tlast;
  wire s_axis_tready;
  wire s_axis_tvalid;

  assign m_axis_tdata[31:1] = \^m_axis_tdata [31:1];
  assign m_axis_tdata[0] = \<const0> ;
  assign m_axis_tkeep[3:0] = s_axis_tkeep;
  GND GND
       (.G(\<const0> ));
  hardware_stream_transform_0_0_stream_transform U0
       (.aclk(aclk),
        .aresetn(aresetn),
        .m_axis_tdata(\^m_axis_tdata ),
        .m_axis_tlast(m_axis_tlast),
        .m_axis_tready(m_axis_tready),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tlast(s_axis_tlast),
        .s_axis_tready(s_axis_tready),
        .s_axis_tvalid(s_axis_tvalid),
        .valid_reg_reg_0(m_axis_tvalid));
endmodule

(* ORIG_REF_NAME = "stream_transform" *) 
module hardware_stream_transform_0_0_stream_transform
   (m_axis_tdata,
    m_axis_tlast,
    valid_reg_reg_0,
    s_axis_tready,
    s_axis_tdata,
    aclk,
    s_axis_tlast,
    m_axis_tready,
    s_axis_tvalid,
    aresetn);
  output [30:0]m_axis_tdata;
  output m_axis_tlast;
  output valid_reg_reg_0;
  output s_axis_tready;
  input [31:0]s_axis_tdata;
  input aclk;
  input s_axis_tlast;
  input m_axis_tready;
  input s_axis_tvalid;
  input aresetn;

  wire \_inferred__1/i__carry__0_n_0 ;
  wire \_inferred__1/i__carry__0_n_1 ;
  wire \_inferred__1/i__carry__0_n_2 ;
  wire \_inferred__1/i__carry__0_n_3 ;
  wire \_inferred__1/i__carry__1_n_0 ;
  wire \_inferred__1/i__carry__1_n_1 ;
  wire \_inferred__1/i__carry__1_n_2 ;
  wire \_inferred__1/i__carry__1_n_3 ;
  wire \_inferred__1/i__carry__2_n_0 ;
  wire \_inferred__1/i__carry__2_n_1 ;
  wire \_inferred__1/i__carry__2_n_2 ;
  wire \_inferred__1/i__carry__2_n_3 ;
  wire \_inferred__1/i__carry__3_n_0 ;
  wire \_inferred__1/i__carry__3_n_1 ;
  wire \_inferred__1/i__carry__3_n_2 ;
  wire \_inferred__1/i__carry__3_n_3 ;
  wire \_inferred__1/i__carry__4_n_0 ;
  wire \_inferred__1/i__carry__4_n_1 ;
  wire \_inferred__1/i__carry__4_n_2 ;
  wire \_inferred__1/i__carry__4_n_3 ;
  wire \_inferred__1/i__carry__5_n_0 ;
  wire \_inferred__1/i__carry__5_n_1 ;
  wire \_inferred__1/i__carry__5_n_2 ;
  wire \_inferred__1/i__carry__5_n_3 ;
  wire \_inferred__1/i__carry__6_n_2 ;
  wire \_inferred__1/i__carry__6_n_3 ;
  wire \_inferred__1/i__carry_n_0 ;
  wire \_inferred__1/i__carry_n_1 ;
  wire \_inferred__1/i__carry_n_2 ;
  wire \_inferred__1/i__carry_n_3 ;
  wire aclk;
  wire aresetn;
  wire data_reg;
  wire i__carry__0_i_1_n_0;
  wire i__carry__0_i_2_n_0;
  wire i__carry__0_i_3_n_0;
  wire i__carry__0_i_4_n_0;
  wire i__carry__1_i_1_n_0;
  wire i__carry__1_i_2_n_0;
  wire i__carry__1_i_3_n_0;
  wire i__carry__1_i_4_n_0;
  wire i__carry__2_i_1_n_0;
  wire i__carry__2_i_2_n_0;
  wire i__carry__2_i_3_n_0;
  wire i__carry__2_i_4_n_0;
  wire i__carry__3_i_1_n_0;
  wire i__carry__3_i_2_n_0;
  wire i__carry__3_i_3_n_0;
  wire i__carry__3_i_4_n_0;
  wire i__carry__4_i_1_n_0;
  wire i__carry__4_i_2_n_0;
  wire i__carry__4_i_3_n_0;
  wire i__carry__4_i_4_n_0;
  wire i__carry__5_i_1_n_0;
  wire i__carry__5_i_2_n_0;
  wire i__carry__5_i_3_n_0;
  wire i__carry__5_i_4_n_0;
  wire i__carry__6_i_1_n_0;
  wire i__carry__6_i_2_n_0;
  wire i__carry__6_i_3_n_0;
  wire i__carry_i_1_n_0;
  wire i__carry_i_2_n_0;
  wire i__carry_i_3_n_0;
  wire i__carry_i_4_n_0;
  wire [30:0]m_axis_tdata;
  wire m_axis_tlast;
  wire m_axis_tready;
  wire p_0_in;
  wire [31:0]s_axis_tdata;
  wire s_axis_tlast;
  wire s_axis_tready;
  wire s_axis_tvalid;
  wire valid_reg_i_1_n_0;
  wire valid_reg_reg_0;
  wire [31:1]y;
  wire [3:2]\NLW__inferred__1/i__carry__6_CO_UNCONNECTED ;
  wire [3:3]\NLW__inferred__1/i__carry__6_O_UNCONNECTED ;

  (* ADDER_THRESHOLD = "35" *) 
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-8 {cell *THIS*}}" *) 
  CARRY4 \_inferred__1/i__carry 
       (.CI(1'b0),
        .CO({\_inferred__1/i__carry_n_0 ,\_inferred__1/i__carry_n_1 ,\_inferred__1/i__carry_n_2 ,\_inferred__1/i__carry_n_3 }),
        .CYINIT(s_axis_tdata[0]),
        .DI({s_axis_tdata[3],s_axis_tdata[0],s_axis_tdata[2:1]}),
        .O(y[4:1]),
        .S({i__carry_i_1_n_0,i__carry_i_2_n_0,i__carry_i_3_n_0,i__carry_i_4_n_0}));
  (* ADDER_THRESHOLD = "35" *) 
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-8 {cell *THIS*}}" *) 
  CARRY4 \_inferred__1/i__carry__0 
       (.CI(\_inferred__1/i__carry_n_0 ),
        .CO({\_inferred__1/i__carry__0_n_0 ,\_inferred__1/i__carry__0_n_1 ,\_inferred__1/i__carry__0_n_2 ,\_inferred__1/i__carry__0_n_3 }),
        .CYINIT(1'b0),
        .DI(s_axis_tdata[7:4]),
        .O(y[8:5]),
        .S({i__carry__0_i_1_n_0,i__carry__0_i_2_n_0,i__carry__0_i_3_n_0,i__carry__0_i_4_n_0}));
  (* ADDER_THRESHOLD = "35" *) 
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-8 {cell *THIS*}}" *) 
  CARRY4 \_inferred__1/i__carry__1 
       (.CI(\_inferred__1/i__carry__0_n_0 ),
        .CO({\_inferred__1/i__carry__1_n_0 ,\_inferred__1/i__carry__1_n_1 ,\_inferred__1/i__carry__1_n_2 ,\_inferred__1/i__carry__1_n_3 }),
        .CYINIT(1'b0),
        .DI(s_axis_tdata[11:8]),
        .O(y[12:9]),
        .S({i__carry__1_i_1_n_0,i__carry__1_i_2_n_0,i__carry__1_i_3_n_0,i__carry__1_i_4_n_0}));
  (* ADDER_THRESHOLD = "35" *) 
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-8 {cell *THIS*}}" *) 
  CARRY4 \_inferred__1/i__carry__2 
       (.CI(\_inferred__1/i__carry__1_n_0 ),
        .CO({\_inferred__1/i__carry__2_n_0 ,\_inferred__1/i__carry__2_n_1 ,\_inferred__1/i__carry__2_n_2 ,\_inferred__1/i__carry__2_n_3 }),
        .CYINIT(1'b0),
        .DI(s_axis_tdata[15:12]),
        .O(y[16:13]),
        .S({i__carry__2_i_1_n_0,i__carry__2_i_2_n_0,i__carry__2_i_3_n_0,i__carry__2_i_4_n_0}));
  (* ADDER_THRESHOLD = "35" *) 
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-8 {cell *THIS*}}" *) 
  CARRY4 \_inferred__1/i__carry__3 
       (.CI(\_inferred__1/i__carry__2_n_0 ),
        .CO({\_inferred__1/i__carry__3_n_0 ,\_inferred__1/i__carry__3_n_1 ,\_inferred__1/i__carry__3_n_2 ,\_inferred__1/i__carry__3_n_3 }),
        .CYINIT(1'b0),
        .DI(s_axis_tdata[19:16]),
        .O(y[20:17]),
        .S({i__carry__3_i_1_n_0,i__carry__3_i_2_n_0,i__carry__3_i_3_n_0,i__carry__3_i_4_n_0}));
  (* ADDER_THRESHOLD = "35" *) 
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-8 {cell *THIS*}}" *) 
  CARRY4 \_inferred__1/i__carry__4 
       (.CI(\_inferred__1/i__carry__3_n_0 ),
        .CO({\_inferred__1/i__carry__4_n_0 ,\_inferred__1/i__carry__4_n_1 ,\_inferred__1/i__carry__4_n_2 ,\_inferred__1/i__carry__4_n_3 }),
        .CYINIT(1'b0),
        .DI(s_axis_tdata[23:20]),
        .O(y[24:21]),
        .S({i__carry__4_i_1_n_0,i__carry__4_i_2_n_0,i__carry__4_i_3_n_0,i__carry__4_i_4_n_0}));
  (* ADDER_THRESHOLD = "35" *) 
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-8 {cell *THIS*}}" *) 
  CARRY4 \_inferred__1/i__carry__5 
       (.CI(\_inferred__1/i__carry__4_n_0 ),
        .CO({\_inferred__1/i__carry__5_n_0 ,\_inferred__1/i__carry__5_n_1 ,\_inferred__1/i__carry__5_n_2 ,\_inferred__1/i__carry__5_n_3 }),
        .CYINIT(1'b0),
        .DI(s_axis_tdata[27:24]),
        .O(y[28:25]),
        .S({i__carry__5_i_1_n_0,i__carry__5_i_2_n_0,i__carry__5_i_3_n_0,i__carry__5_i_4_n_0}));
  (* ADDER_THRESHOLD = "35" *) 
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-8 {cell *THIS*}}" *) 
  CARRY4 \_inferred__1/i__carry__6 
       (.CI(\_inferred__1/i__carry__5_n_0 ),
        .CO({\NLW__inferred__1/i__carry__6_CO_UNCONNECTED [3:2],\_inferred__1/i__carry__6_n_2 ,\_inferred__1/i__carry__6_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,s_axis_tdata[29:28]}),
        .O({\NLW__inferred__1/i__carry__6_O_UNCONNECTED [3],y[31:29]}),
        .S({1'b0,i__carry__6_i_1_n_0,i__carry__6_i_2_n_0,i__carry__6_i_3_n_0}));
  LUT1 #(
    .INIT(2'h1)) 
    \data_reg[31]_i_1 
       (.I0(aresetn),
        .O(p_0_in));
  LUT3 #(
    .INIT(8'hD0)) 
    \data_reg[31]_i_2 
       (.I0(valid_reg_reg_0),
        .I1(m_axis_tready),
        .I2(s_axis_tvalid),
        .O(data_reg));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[10] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[10]),
        .Q(m_axis_tdata[9]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[11] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[11]),
        .Q(m_axis_tdata[10]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[12] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[12]),
        .Q(m_axis_tdata[11]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[13] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[13]),
        .Q(m_axis_tdata[12]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[14] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[14]),
        .Q(m_axis_tdata[13]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[15] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[15]),
        .Q(m_axis_tdata[14]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[16] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[16]),
        .Q(m_axis_tdata[15]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[17] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[17]),
        .Q(m_axis_tdata[16]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[18] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[18]),
        .Q(m_axis_tdata[17]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[19] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[19]),
        .Q(m_axis_tdata[18]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[1] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[1]),
        .Q(m_axis_tdata[0]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[20] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[20]),
        .Q(m_axis_tdata[19]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[21] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[21]),
        .Q(m_axis_tdata[20]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[22] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[22]),
        .Q(m_axis_tdata[21]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[23] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[23]),
        .Q(m_axis_tdata[22]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[24] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[24]),
        .Q(m_axis_tdata[23]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[25] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[25]),
        .Q(m_axis_tdata[24]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[26] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[26]),
        .Q(m_axis_tdata[25]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[27] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[27]),
        .Q(m_axis_tdata[26]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[28] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[28]),
        .Q(m_axis_tdata[27]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[29] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[29]),
        .Q(m_axis_tdata[28]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[2] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[2]),
        .Q(m_axis_tdata[1]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[30] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[30]),
        .Q(m_axis_tdata[29]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[31] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[31]),
        .Q(m_axis_tdata[30]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[3] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[3]),
        .Q(m_axis_tdata[2]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[4] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[4]),
        .Q(m_axis_tdata[3]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[5] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[5]),
        .Q(m_axis_tdata[4]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[6] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[6]),
        .Q(m_axis_tdata[5]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[7] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[7]),
        .Q(m_axis_tdata[6]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[8] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[8]),
        .Q(m_axis_tdata[7]),
        .R(p_0_in));
  FDRE #(
    .INIT(1'b0)) 
    \data_reg_reg[9] 
       (.C(aclk),
        .CE(data_reg),
        .D(y[9]),
        .Q(m_axis_tdata[8]),
        .R(p_0_in));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry__0_i_1
       (.I0(s_axis_tdata[7]),
        .I1(s_axis_tdata[8]),
        .O(i__carry__0_i_1_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry__0_i_2
       (.I0(s_axis_tdata[6]),
        .I1(s_axis_tdata[7]),
        .O(i__carry__0_i_2_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry__0_i_3
       (.I0(s_axis_tdata[5]),
        .I1(s_axis_tdata[6]),
        .O(i__carry__0_i_3_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry__0_i_4
       (.I0(s_axis_tdata[4]),
        .I1(s_axis_tdata[5]),
        .O(i__carry__0_i_4_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry__1_i_1
       (.I0(s_axis_tdata[11]),
        .I1(s_axis_tdata[12]),
        .O(i__carry__1_i_1_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry__1_i_2
       (.I0(s_axis_tdata[10]),
        .I1(s_axis_tdata[11]),
        .O(i__carry__1_i_2_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry__1_i_3
       (.I0(s_axis_tdata[9]),
        .I1(s_axis_tdata[10]),
        .O(i__carry__1_i_3_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry__1_i_4
       (.I0(s_axis_tdata[8]),
        .I1(s_axis_tdata[9]),
        .O(i__carry__1_i_4_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry__2_i_1
       (.I0(s_axis_tdata[15]),
        .I1(s_axis_tdata[16]),
        .O(i__carry__2_i_1_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry__2_i_2
       (.I0(s_axis_tdata[14]),
        .I1(s_axis_tdata[15]),
        .O(i__carry__2_i_2_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry__2_i_3
       (.I0(s_axis_tdata[13]),
        .I1(s_axis_tdata[14]),
        .O(i__carry__2_i_3_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry__2_i_4
       (.I0(s_axis_tdata[12]),
        .I1(s_axis_tdata[13]),
        .O(i__carry__2_i_4_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry__3_i_1
       (.I0(s_axis_tdata[19]),
        .I1(s_axis_tdata[20]),
        .O(i__carry__3_i_1_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry__3_i_2
       (.I0(s_axis_tdata[18]),
        .I1(s_axis_tdata[19]),
        .O(i__carry__3_i_2_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry__3_i_3
       (.I0(s_axis_tdata[17]),
        .I1(s_axis_tdata[18]),
        .O(i__carry__3_i_3_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry__3_i_4
       (.I0(s_axis_tdata[16]),
        .I1(s_axis_tdata[17]),
        .O(i__carry__3_i_4_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry__4_i_1
       (.I0(s_axis_tdata[23]),
        .I1(s_axis_tdata[24]),
        .O(i__carry__4_i_1_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry__4_i_2
       (.I0(s_axis_tdata[22]),
        .I1(s_axis_tdata[23]),
        .O(i__carry__4_i_2_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry__4_i_3
       (.I0(s_axis_tdata[21]),
        .I1(s_axis_tdata[22]),
        .O(i__carry__4_i_3_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry__4_i_4
       (.I0(s_axis_tdata[20]),
        .I1(s_axis_tdata[21]),
        .O(i__carry__4_i_4_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry__5_i_1
       (.I0(s_axis_tdata[27]),
        .I1(s_axis_tdata[28]),
        .O(i__carry__5_i_1_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry__5_i_2
       (.I0(s_axis_tdata[26]),
        .I1(s_axis_tdata[27]),
        .O(i__carry__5_i_2_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry__5_i_3
       (.I0(s_axis_tdata[25]),
        .I1(s_axis_tdata[26]),
        .O(i__carry__5_i_3_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry__5_i_4
       (.I0(s_axis_tdata[24]),
        .I1(s_axis_tdata[25]),
        .O(i__carry__5_i_4_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry__6_i_1
       (.I0(s_axis_tdata[30]),
        .I1(s_axis_tdata[31]),
        .O(i__carry__6_i_1_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry__6_i_2
       (.I0(s_axis_tdata[29]),
        .I1(s_axis_tdata[30]),
        .O(i__carry__6_i_2_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry__6_i_3
       (.I0(s_axis_tdata[28]),
        .I1(s_axis_tdata[29]),
        .O(i__carry__6_i_3_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry_i_1
       (.I0(s_axis_tdata[3]),
        .I1(s_axis_tdata[4]),
        .O(i__carry_i_1_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry_i_2
       (.I0(s_axis_tdata[3]),
        .I1(s_axis_tdata[0]),
        .O(i__carry_i_2_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    i__carry_i_3
       (.I0(s_axis_tdata[2]),
        .O(i__carry_i_3_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    i__carry_i_4
       (.I0(s_axis_tdata[0]),
        .I1(s_axis_tdata[1]),
        .O(i__carry_i_4_n_0));
  FDRE #(
    .INIT(1'b0)) 
    last_reg_reg
       (.C(aclk),
        .CE(data_reg),
        .D(s_axis_tlast),
        .Q(m_axis_tlast),
        .R(p_0_in));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT2 #(
    .INIT(4'hB)) 
    s_axis_tready_INST_0
       (.I0(m_axis_tready),
        .I1(valid_reg_reg_0),
        .O(s_axis_tready));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'hF200)) 
    valid_reg_i_1
       (.I0(valid_reg_reg_0),
        .I1(m_axis_tready),
        .I2(s_axis_tvalid),
        .I3(aresetn),
        .O(valid_reg_i_1_n_0));
  FDRE #(
    .INIT(1'b0)) 
    valid_reg_reg
       (.C(aclk),
        .CE(1'b1),
        .D(valid_reg_i_1_n_0),
        .Q(valid_reg_reg_0),
        .R(1'b0));
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
