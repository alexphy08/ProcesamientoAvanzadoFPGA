library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity semaforo is 
  port(
    clk : in std_logic;
    btnR : in std_logic;
    led : out std_logic_vector(2 downto 0)
);
end entity;

architecture behavioral of semaforo is
type states is (sr_1,sr_2,sa,sv);
  signal estado_semaforo : states;

begin 
  process(clk,btnR)
    begin
      if btnR = '1' then
        estado_semaforo <= sr_1;
      elsif rising_edge(clk) then
        case estado_semaforo is
          when sr_1 => led(0) <= '1';
                       led(1) <= '0';          
                       led(2) <= '0';
                       estado_semaforo <= sr_2;

          when sr_2 => led(0) <= '1';
                       led(1) <= '0';          
                       led(2) <= '0';
                       estado_semaforo <= sv;

          when sv =>   led(0) <= '0';
                       led(1) <= '0';          
                       led(2) <= '1';
                       estado_semaforo <= sa;

          when sa =>   led(0) <= '0';
                       led(1) <= '1';          
                       led(2) <= '0';
                       estado_semaforo <= sr_1;

        when others => estado_semaforo <= sr_1;
        end case;
      end if;
    end process;
end behavioral;