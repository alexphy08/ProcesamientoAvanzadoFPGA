library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_leds is
    Port (
        sysclk : in  std_logic;
        sw     : in  std_logic_vector(1 downto 0);
        btn    : in  std_logic_vector(3 downto 0);
        led    : out std_logic_vector(3 downto 0);
        tick   : out std_logic
    );
end top_leds;

architecture Behavioral of top_leds is
    signal tick_s : std_logic;
    signal mode_s : std_logic_vector(2 downto 0);
begin
    mode_s <= '0' & sw;   -- 00 IDLE, 01 RIGHT, 10 LEFT, 11 VALUE

    u_tick : entity work.tick_generator
        generic map (CLK_FREQ_HZ => 125_000_000, HALF_PERIOD_MS => 125)
        port map (clk => sysclk, rst => '1', tick => tick_s);

    u_fsm : entity work.fsm_controller
        port map (
            clk => sysclk, rst => '1',
            mode => mode_s, tick => tick_s, val => btn,
            leds => led,
            s_axis_tdata  => (others => '0'),
            s_axis_tkeep  => (others => '0'),
            s_axis_tvalid => '0',
            s_axis_tready => open,
            s_axis_tlast  => '0'
        );

    tick <= tick_s;
end Behavioral;
