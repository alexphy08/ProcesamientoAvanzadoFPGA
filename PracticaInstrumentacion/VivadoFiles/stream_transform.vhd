------------------------------------------------------------------------
-- IP RTL create by Fabian Castano
------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity stream_transform is
    Port (
        -- clock and rest
        aclk       : in  std_logic;
        aresetn    : in  std_logic;

        -- AXI4-Stream slave input
        s_axis_tdata  : in  std_logic_vector (31 downto 0);
        s_axis_tkeep  : in  std_logic_vector(3 downto 0);
        s_axis_tvalid : in  std_logic;
        s_axis_tready : out std_logic;
        s_axis_tlast  : in  std_logic;

        -- AXI4-Stream master output
        m_axis_tdata  : out std_logic_vector(31 downto 0);
        m_axis_tkeep  : out std_logic_vector(3 downto 0);
        m_axis_tvalid : out std_logic;
        m_axis_tready : in  std_logic;
        m_axis_tlast  : out std_logic
     );
end stream_transform;

architecture Behavioral of stream_transform is

    signal data_reg    : std_logic_vector(31 downto 0) := (others => '0');
    signal last_reg    : std_logic := '0';
    signal valid_reg   : std_logic := '0';

    signal input_ready : std_logic;

begin

    -- Accept a new word when the output register is empty,
    -- or when the current output word is being accepted.
    input_ready <= (not valid_reg) or m_axis_tready;

    s_axis_tready <= input_ready;

    m_axis_tdata  <= data_reg;
    m_axis_tkeep  <= s_axis_tkeep;
    m_axis_tlast  <= last_reg;
    m_axis_tvalid <= valid_reg;

    -- processing data
    process (aclk)
        variable x : unsigned(31 downto 0);
        variable y : unsigned(31 downto 0);
    begin
        if rising_edge(aclk) then
            if aresetn = '0' then
                data_reg  <= (others => '0');
                last_reg  <= '0';
                valid_reg <= '0';
            
            elsif input_ready = '1' then
                -- A new input word is accepted only when valid is high
                if s_axis_tvalid = '1' then
                    x := unsigned(s_axis_tdata);

                    if x(0) = '1' then
                        -- Odd: add 5
                        y := x + to_unsigned(5, 32);
                    else
                        -- Even: subtract 2
                        y := x - to_unsigned(2, 32);
                    end if;

                    data_reg  <= std_logic_vector(y);
                    last_reg  <= s_axis_tlast;
                    valid_reg <= '1';
                
                else
                    -- No input word available
                    valid_reg <= '0';
                end if;
            end if;
        end if;
    end process;

end Behavioral;
