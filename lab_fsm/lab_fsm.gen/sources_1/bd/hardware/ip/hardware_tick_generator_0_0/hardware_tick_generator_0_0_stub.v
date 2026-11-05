// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
// Date        : Thu Nov  5 13:56:53 2026
// Host        : DESKTOP-F0DLAU4 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub {c:/Users/Laboratorio PC
//               3/Documents/crisFPGA/ProcesamientoAvanzadoFPGA/lab_fsm/lab_fsm.gen/sources_1/bd/hardware/ip/hardware_tick_generator_0_0/hardware_tick_generator_0_0_stub.v}
// Design      : hardware_tick_generator_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* CHECK_LICENSE_TYPE = "hardware_tick_generator_0_0,tick_generator,{}" *) (* core_generation_info = "hardware_tick_generator_0_0,tick_generator,{x_ipProduct=Vivado 2024.2,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=tick_generator,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VHDL,x_ipSimLanguage=VHDL,CLK_FREQ_HZ=100000000,HALF_PERIOD_MS=125}" *) (* downgradeipidentifiedwarnings = "yes" *) 
(* ip_definition_source = "module_ref" *) (* x_core_info = "tick_generator,Vivado 2024.2" *) 
module hardware_tick_generator_0_0(clk, rst, tick)
/* synthesis syn_black_box black_box_pad_pin="rst,tick" */
/* synthesis syn_force_seq_prim="clk" */;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk CLK" *) (* x_interface_mode = "slave clk" *) (* x_interface_parameter = "XIL_INTERFACENAME clk, ASSOCIATED_RESET rst, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN hardware_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *) input clk /* synthesis syn_isclock = 1 */;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 rst RST" *) (* x_interface_mode = "slave rst" *) (* x_interface_parameter = "XIL_INTERFACENAME rst, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input rst;
  output tick;
endmodule
