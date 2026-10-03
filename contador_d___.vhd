library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_d____ is
 port(
       clk : in std_logic;
       sw : in std_logic_vector(3 downto 0);
       seg : out std_logic_vector(6 downto 0)
 );
end entity;

architecture behavioral of contador_d____ is

signal bcd  : std_logic_vector(3 downto 0);
signal display : std_logic_vector(6 downto 0);

begin
  bcd <= sw;
  seg <= display;

  display <= "1000000" when bcd = "0000" else
             "1111001" when bcd = "0001" else
             "0100100" when bcd = "0010" else
             "0110000" when bcd = "0011" else
             "0011001" when bcd = "0100" else
             "0010010" when bcd = "0101" else
             "0000010" when bcd = "0110" else
             "1111000" when bcd = "0111" else
             "0000000" when bcd = "1000" else
             "0010000" when bcd = "1001" else
             "1111111" ;
end architecture;