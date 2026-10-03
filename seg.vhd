library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity seg is
    Port ( 
        bcd  : in  STD_LOGIC_VECTOR (3 downto 0); -- Entrada binaria de 4 bits
        salida : out STD_LOGIC_VECTOR (6 downto 0)  -- Salida a los segmentos (a,b,c,d,e,f,g)
    );
end entity;

architecture behavioral of seg is
begin    
        salida  <= "1111110" when bcd = "0000" else
                   "0110000" when bcd = "0001" else
                   "1101101" when bcd = "0010" else
                   "1111001" when bcd = "0011" else
                   "0110011" when bcd = "0100" else
                   "1011011" when bcd = "0101" else
                   "1011111" when bcd = "0110" else
                   "1110000" when bcd = "0111" else
                   "1111111" when bcd = "1000" else
                   "1111011" when bcd = "1001" else
                   "0000000";    
end behavioral;