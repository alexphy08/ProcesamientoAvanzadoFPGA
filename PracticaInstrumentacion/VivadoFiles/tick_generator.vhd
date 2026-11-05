----------------------------------------------------------------------------------
-- RTL Create by Fabian Castano
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tick_generator is
    generic (
        CLK_FREQ_HZ : positive := 125_000_000;
        HALF_PERIOD_MS : positive := 125
            );
    Port (
        clk    : in  std_logic;
        rst    : in  std_logic;
        tick   : out std_logic
         );
end tick_generator;

architecture Behavioral of tick_generator is
    constant COUNT_MAX : positive := 
        (CLK_FREQ_HZ / 1000) * HALF_PERIOD_MS;
    signal count    : natural range 0 to COUNT_MAX -1 := 0;
    signal tick_reg : std_logic := '0';
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                count    <= 0;
                tick_reg <= '0';

            elsif count = COUNT_MAX - 1 then
                count    <= 0;
                tick_reg <= not tick_reg;

            else
                count <= count + 1;
            end if;
        end if;
    end process;
    
    tick <= tick_reg;
    
end Behavioral;
