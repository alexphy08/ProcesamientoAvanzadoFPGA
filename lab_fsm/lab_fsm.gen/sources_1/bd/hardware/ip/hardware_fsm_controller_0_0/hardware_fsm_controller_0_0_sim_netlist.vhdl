-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
-- Date        : Thu Nov  5 13:25:58 2026
-- Host        : DESKTOP-N301Q0S running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim
--               c:/Kevin/lab_fsm/lab_fsm.gen/sources_1/bd/hardware/ip/hardware_fsm_controller_0_0/hardware_fsm_controller_0_0_sim_netlist.vhdl
-- Design      : hardware_fsm_controller_0_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity hardware_fsm_controller_0_0_fsm_controller is
  port (
    Q : out STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axis_tready : out STD_LOGIC;
    tick : in STD_LOGIC;
    clk : in STD_LOGIC;
    mode : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axis_tvalid : in STD_LOGIC;
    s_axis_tdata : in STD_LOGIC_VECTOR ( 3 downto 0 );
    val : in STD_LOGIC_VECTOR ( 3 downto 0 );
    rst : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of hardware_fsm_controller_0_0_fsm_controller : entity is "fsm_controller";
end hardware_fsm_controller_0_0_fsm_controller;

architecture STRUCTURE of hardware_fsm_controller_0_0_fsm_controller is
  signal \^q\ : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal led_reg : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal \led_reg[0]_i_2_n_0\ : STD_LOGIC;
  signal \led_reg[0]_i_3_n_0\ : STD_LOGIC;
  signal \led_reg[1]_i_2_n_0\ : STD_LOGIC;
  signal \led_reg[2]_i_2_n_0\ : STD_LOGIC;
  signal \led_reg[3]_i_2_n_0\ : STD_LOGIC;
  signal \led_reg[3]_i_4_n_0\ : STD_LOGIC;
  signal p_0_in : STD_LOGIC;
  signal state : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal \state[0]_i_1_n_0\ : STD_LOGIC;
  signal \state[1]_i_1_n_0\ : STD_LOGIC;
  signal \state[2]_i_1_n_0\ : STD_LOGIC;
  signal tick_prev : STD_LOGIC;
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \led_reg[1]_i_1\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \led_reg[2]_i_1\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of s_axis_tready_INST_0 : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \state[0]_i_1\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \state[1]_i_1\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \state[2]_i_1\ : label is "soft_lutpair0";
begin
  Q(3 downto 0) <= \^q\(3 downto 0);
\led_reg[0]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"B8BBB888"
    )
        port map (
      I0 => s_axis_tdata(0),
      I1 => state(2),
      I2 => \led_reg[0]_i_2_n_0\,
      I3 => state(1),
      I4 => \led_reg[0]_i_3_n_0\,
      O => led_reg(0)
    );
\led_reg[0]_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => val(0),
      I1 => state(0),
      I2 => \^q\(1),
      O => \led_reg[0]_i_2_n_0\
    );
\led_reg[0]_i_3\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"0002FFFF"
    )
        port map (
      I0 => \^q\(3),
      I1 => \^q\(0),
      I2 => \^q\(2),
      I3 => \^q\(1),
      I4 => state(0),
      O => \led_reg[0]_i_3_n_0\
    );
\led_reg[1]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axis_tdata(1),
      I1 => state(2),
      I2 => \led_reg[1]_i_2_n_0\,
      O => led_reg(1)
    );
\led_reg[1]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"AFA0C0C0"
    )
        port map (
      I0 => val(1),
      I1 => \^q\(2),
      I2 => state(1),
      I3 => \^q\(0),
      I4 => state(0),
      O => \led_reg[1]_i_2_n_0\
    );
\led_reg[2]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => s_axis_tdata(2),
      I1 => state(2),
      I2 => \led_reg[2]_i_2_n_0\,
      O => led_reg(2)
    );
\led_reg[2]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"AFA0C0C0"
    )
        port map (
      I0 => val(2),
      I1 => \^q\(3),
      I2 => state(1),
      I3 => \^q\(1),
      I4 => state(0),
      O => \led_reg[2]_i_2_n_0\
    );
\led_reg[3]_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => rst,
      O => p_0_in
    );
\led_reg[3]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"0000A8AA"
    )
        port map (
      I0 => tick,
      I1 => state(1),
      I2 => s_axis_tvalid,
      I3 => state(2),
      I4 => tick_prev,
      O => \led_reg[3]_i_2_n_0\
    );
\led_reg[3]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"B8BBB888B888B888"
    )
        port map (
      I0 => s_axis_tdata(3),
      I1 => state(2),
      I2 => \led_reg[3]_i_4_n_0\,
      I3 => state(1),
      I4 => \^q\(2),
      I5 => state(0),
      O => led_reg(3)
    );
\led_reg[3]_i_4\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"8888888888888B88"
    )
        port map (
      I0 => val(3),
      I1 => state(0),
      I2 => \^q\(1),
      I3 => \^q\(0),
      I4 => \^q\(2),
      I5 => \^q\(3),
      O => \led_reg[3]_i_4_n_0\
    );
\led_reg_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk,
      CE => \led_reg[3]_i_2_n_0\,
      D => led_reg(0),
      Q => \^q\(0),
      R => p_0_in
    );
\led_reg_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk,
      CE => \led_reg[3]_i_2_n_0\,
      D => led_reg(1),
      Q => \^q\(1),
      R => p_0_in
    );
\led_reg_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk,
      CE => \led_reg[3]_i_2_n_0\,
      D => led_reg(2),
      Q => \^q\(2),
      R => p_0_in
    );
\led_reg_reg[3]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk,
      CE => \led_reg[3]_i_2_n_0\,
      D => led_reg(3),
      Q => \^q\(3),
      R => p_0_in
    );
s_axis_tready_INST_0: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00000200"
    )
        port map (
      I0 => tick,
      I1 => mode(1),
      I2 => mode(0),
      I3 => mode(2),
      I4 => tick_prev,
      O => s_axis_tready
    );
\state[0]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => mode(0),
      I1 => mode(2),
      O => \state[0]_i_1_n_0\
    );
\state[1]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => mode(1),
      I1 => mode(2),
      O => \state[1]_i_1_n_0\
    );
\state[2]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"10"
    )
        port map (
      I0 => mode(1),
      I1 => mode(0),
      I2 => mode(2),
      O => \state[2]_i_1_n_0\
    );
\state_reg[0]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk,
      CE => '1',
      D => \state[0]_i_1_n_0\,
      Q => state(0),
      R => p_0_in
    );
\state_reg[1]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk,
      CE => '1',
      D => \state[1]_i_1_n_0\,
      Q => state(1),
      R => p_0_in
    );
\state_reg[2]\: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk,
      CE => '1',
      D => \state[2]_i_1_n_0\,
      Q => state(2),
      R => p_0_in
    );
tick_prev_reg: unisim.vcomponents.FDRE
    generic map(
      INIT => '0'
    )
        port map (
      C => clk,
      CE => '1',
      D => tick,
      Q => tick_prev,
      R => p_0_in
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity hardware_fsm_controller_0_0 is
  port (
    clk : in STD_LOGIC;
    rst : in STD_LOGIC;
    mode : in STD_LOGIC_VECTOR ( 2 downto 0 );
    tick : in STD_LOGIC;
    val : in STD_LOGIC_VECTOR ( 3 downto 0 );
    leds : out STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axis_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_tkeep : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axis_tvalid : in STD_LOGIC;
    s_axis_tready : out STD_LOGIC;
    s_axis_tlast : in STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of hardware_fsm_controller_0_0 : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of hardware_fsm_controller_0_0 : entity is "hardware_fsm_controller_0_0,fsm_controller,{}";
  attribute downgradeipidentifiedwarnings : string;
  attribute downgradeipidentifiedwarnings of hardware_fsm_controller_0_0 : entity is "yes";
  attribute ip_definition_source : string;
  attribute ip_definition_source of hardware_fsm_controller_0_0 : entity is "module_ref";
  attribute x_core_info : string;
  attribute x_core_info of hardware_fsm_controller_0_0 : entity is "fsm_controller,Vivado 2024.2";
end hardware_fsm_controller_0_0;

architecture STRUCTURE of hardware_fsm_controller_0_0 is
  attribute x_interface_info : string;
  attribute x_interface_info of clk : signal is "xilinx.com:signal:clock:1.0 clk CLK";
  attribute x_interface_mode : string;
  attribute x_interface_mode of clk : signal is "slave clk";
  attribute x_interface_parameter : string;
  attribute x_interface_parameter of clk : signal is "XIL_INTERFACENAME clk, ASSOCIATED_BUSIF s_axis, ASSOCIATED_RESET rst, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN hardware_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0";
  attribute x_interface_info of rst : signal is "xilinx.com:signal:reset:1.0 rst RST";
  attribute x_interface_mode of rst : signal is "slave rst";
  attribute x_interface_parameter of rst : signal is "XIL_INTERFACENAME rst, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  attribute x_interface_info of s_axis_tlast : signal is "xilinx.com:interface:axis:1.0 s_axis TLAST";
  attribute x_interface_info of s_axis_tready : signal is "xilinx.com:interface:axis:1.0 s_axis TREADY";
  attribute x_interface_info of s_axis_tvalid : signal is "xilinx.com:interface:axis:1.0 s_axis TVALID";
  attribute x_interface_info of s_axis_tdata : signal is "xilinx.com:interface:axis:1.0 s_axis TDATA";
  attribute x_interface_mode of s_axis_tdata : signal is "slave s_axis";
  attribute x_interface_parameter of s_axis_tdata : signal is "XIL_INTERFACENAME s_axis, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN hardware_processing_system7_0_0_FCLK_CLK0, LAYERED_METADATA undef, INSERT_VIP 0";
  attribute x_interface_info of s_axis_tkeep : signal is "xilinx.com:interface:axis:1.0 s_axis TKEEP";
begin
U0: entity work.hardware_fsm_controller_0_0_fsm_controller
     port map (
      Q(3 downto 0) => leds(3 downto 0),
      clk => clk,
      mode(2 downto 0) => mode(2 downto 0),
      rst => rst,
      s_axis_tdata(3 downto 0) => s_axis_tdata(3 downto 0),
      s_axis_tready => s_axis_tready,
      s_axis_tvalid => s_axis_tvalid,
      tick => tick,
      val(3 downto 0) => val(3 downto 0)
    );
end STRUCTURE;
