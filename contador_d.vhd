library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_d is
 port(
       clk : in std_logic;
       btnR : in std_logic;
       an : out std_logic_vector(3 downto 0);
       seg : out std_logic_vector(6 downto 0)
 );
end entity;

architecture behavioral of contador_d is

signal bcd  : std_logic_vector(3 downto 0);
signal display : std_logic_vector(6 downto 0);

signal display_1 : std_logic_vector(3 downto 0);
signal display_2 : std_logic_vector(3 downto 0);
signal display_3 : std_logic_vector(3 downto 0);
signal display_4 : std_logic_vector(3 downto 0);

type state is (d1,d2,d3,d4);
  signal estado_d : state;

begin
  seg <= display;
  display_1 <= "0000";
  display_2 <= "0001";
  display_3 <= "0010";
  display_4 <= "0011";

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

process(clk,btnR)
  begin
    if (btnR = "1") then
      an <= "0000";
      bcd <= "1000";
      estado_d <= d1;
    elsif (rising_edge(clk)) then
      case estado_d is
        when d1 => an <= "1110";
                   bcd <= display_1;
                   estado_d <= d2;

        when d2 => an <= "1101";
                   bcd <= display_2;
                   estado_d <= d3;

        when d3 => an <= "1011";
                   bcd <= display_3;
                   estado_d <= d4;

        when d4 => an <= "0111";
                   bcd <= display_4;
                   estado_d <= d1;

        when others => estado_d <= d1;

       end case;
    end if;
end process; 
end architecture; 
