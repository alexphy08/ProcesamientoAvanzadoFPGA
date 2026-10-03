library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador is
  port(
    clk : in std_logic;
    btnR : in std_logic;
    led : out std_logic_vector(15 downto 0)
);
end entity;

architecture behavioral of contador is
  signal count : std_logic_vector(15 downto 0);

begin
 
led <= count;

  contar : process(clk,btnR)  
    begin
      if rising_edge(clk) then 
        if btnR = "1" then
          count <= (others => '0');
        else 
          count <= count + 1;
        end if;
      end if;
  end process;
end architecture;