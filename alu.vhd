library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
  port (
    sw : in std_logic_vector(12 downto 0);
    led : out std_logic_vector(11 downto 0)
);
end entity;

architecture behavioral of alu is

signal A : std_logic_vector(3 downto 0);
signal B : std_logic_vector(3 downto 0);
signal selector : std_logic_vector(3 downto 0);
signal state : std_logic_vector(7 downto 0);
signal output : std_logic_vector(3 downto 0);
signal mode : std_logic;

begin
 
A <= sw(3 downto 0);
B <= sw(7 downto 4);
selector <= sw(11 downto 8);
mode <= sw(12);

led(3 downto 0) <= output;
led(11 downto 4) <= state;

output <=     A when selector = "0000" and mode = '1' else
              A + B when selector = "0000" and mode = '0' else
              B when selector = "0001" and mode = '1' else
              A - B when selector = "0001" and mode = '0' else
              not(A) when selector = "0010" and mode = '1' else
              B - A when selector = "0010" and mode = '0' else
              not(B) when selector = "0011" and mode = '1' else
              A + 1 when selector = "0011" and mode = '0' else
              A and B when selector = "0100" and mode = '1' else
              B + 1 when selector = "0100" and mode = '0' else
              A or B when selector = "0101" and mode = '1' else
              A - 1 when selector = "0101" and mode = '0' else
              not(A and B) when selector = "0110" and mode = '1' else
              B - 1 when selector = "0110" and mode = '0' else
              not(A or B) when selector = "0111" and mode = '1' else
              not(A) when selector = "0111" and mode = '0' else
              A srl 1 when selector = "1000" and mode = "1" else
              not(B) when selector = "1000" and mode = "0" else
              A sll 1 when selector = "1001" and mode = "1" else
              not(A) + 1 when selector = "1001" and mode = "0" else
              shift_right(A,1) when selector = "1010" and mode = "1" else
              not(B) + 1 when selector = "1010" and mode = "0" else
              shift_left(A,1) when selector = "1011" and mode = "1" else
              A when selector = "1011" and mode = "0" else
              1 when selector = "1100" and mode = "1" else
              B when selector = "1100" and mode = "0" else
              0 when selector = "1101" and mode = "1" else
              0 when selector = "1101" and mode = "0" else
              not(A) and B when selector = "1110" and mode = "1" else
              0 when selector = "1110" and mode = "0" else
              not(A) or B when selector = "1111" and mode = "1" else
              0 when selector = "1111" and mode = "0" else
              "0000"; 
end Behavioral;