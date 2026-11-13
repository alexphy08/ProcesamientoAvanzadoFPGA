------------------------------------------------------------------------
-- IP RTL create by Fabian Castano
------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Entity creation
entity fsm_controller is
    Port (
        clk  : in  std_logic;
        rst  : in  std_logic;
        
        mode : in  <???>(2 downto 0);
        tick : in  std_logic;
        val  : in  std_logic_vector(3 downto 0);
        
        leds : out std_logic_vector(3 downto 0);

        -- AXI4-Stream slave input
        s_axis_tdata  : in  std_logic_vector(31 downto 0);
        s_axis_tkeep  : in  std_logic_vector(3 downto 0);
        s_axis_tvalid : in  std_logic;
        s_axis_tready : out std_logic;
        s_axis_tlast  : in  std_logic
    );
end fsm_controller;

architecture Behavioral of fsm_controller is

    type state_type is (IDLE, RIGHT, <???>, VALUE, DMA);

    signal state    : state_type := IDLE;
    signal tick_prev : std_logic := '0';

    signal led_reg : std_logic_vector(3 downto 0) := "0000";

begin

    s_axis_tready <= '1' when mode = "100" and tick = '1' and tick_prev = '0' else '0';
    <???> <= led_reg;

    process(clk)
    begin
        if <???>(clk) then

            if rst = '0' then
                state     <= IDLE;
                tick_prev <= '0';
                led_reg   <= "0000";
                
            else
                -- Default: update the selected operating mode
                case mode is
                    when "000"   => state <= IDLE;
                    when "001"   => state <= <???>; 
                    when "010"   => state <= LEFT;
                    when "011"   => state <= VALUE;
                    when "100"   => state <= DMA;
                    when others  => state <= IDLE;
                end case;

                -- Remember the previous tick level
                tick_prev <= tick;

                -- Detect only the rising edge of tick
                if tick = '1' and tick_prev = '0' then

                    case state is
                        when IDLE =>
                            led_reg <= "0001";

                        when RIGHT =>
                            if led_reg = "1000" then
                                led_reg <= "0001";
                            else
                                led_reg <= <???>(2 downto 0) & '0';
                            end if;

                        when LEFT =>
                            if led_reg = "0001" then
                                led_reg <= "1000";
                            else
                                led_reg <= '0' & led_reg(3 downto 1);
                            end if;
                            
                        when <???> =>
                            led_reg <= val;
                        
                        when DMA =>
                            if s_axis_tvalid = '1' and tick = '1' and tick_prev = '0' then
                                <???> <= s_axis_tdata(3 downto 0);
                            end if;
                    end case;

                end if;
            end if;
        end if;
    end process;

end Behavioral;
