library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_displays is
 port(
       clk : in std_logic;
       btnR : in std_logic;
       an : out std_logic_vector(3 downto 0);
       seg : out std_logic_vector(6 downto 0)
 );
end entity;

architecture behavioral of contador_displays is

signal bcd  : std_logic_vector(3 downto 0);
signal display : std_logic_vector(6 downto 0);
signal clk_int : std_logic;
signal contador_clk : integer;

signal contador1 : integer;
signal contador2 : integer;
signal contador3 : integer;
signal contador4 : integer;

signal display_1 : std_logic_vector(3 downto 0);
signal display_2 : std_logic_vector(3 downto 0);
signal display_3 : std_logic_vector(3 downto 0);
signal display_4 : std_logic_vector(3 downto 0);

type state is (d1,d2,d3,d4);
  signal estado_d : state;

begin
  seg <= display;
  display_1 <= std_logic_vector(to_unsigned(contador1,4));
  display_2 <= std_logic_vector(to_unsigned(contador2,4));
  display_3 <= std_logic_vector(to_unsigned(contador3,4));
  display_4 <= std_logic_vector(to_unsigned(contador4,4));

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

process(clk,btnR)
begin
  if (btnR = "1") then
    clk_int <= "0";
    contador_clk <= 0;
  elsif rising_edge(clk) then
    if contador_clk >= 32 then
      clk_int <= not clk_int;
      contador_clk <= 0;
    else
      contador_clk <= contador_clk + 1;
    end if;
  end if;
end process;

process(clk_int,btnR)
begin
  if btnR = "1" then
    contador1 <= 0;
    contador2 <= 0;
    contador3 <= 0;
    contador4 <= 0;
  elsif rising_edge(clk_int) then
    if contador1 < 9 then
      contador1 <= contador1 + 1;
    elsif contador2 < 9 then
      contador1 <= 0;
      contador2 <= contador2 + 1;
    elsif contador3 < 9 then
      contador1 <= 0;
      contador2 <= 0;
      contador3 <= contador3 + 1;
    elsif contador4 < 9 then
      contador1 <= 0;
      contador2 <= 0;
      contador3 <= 0;
      contador3 <= contador4 + 1;
    else
      contador1 <= 0;
      contador2 <= 0;
      contador3 <= 0;
      contador4 <= 0;
    end if;
  end if;
end process;
end architecture;