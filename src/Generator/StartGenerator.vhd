library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.data_transmission_pkg.ALL;

entity StartGenerator is
    Port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        my_mod     : in  std_logic_vector(1 downto 0);
        start   : out std_logic_vector(6 downto 0)
    );
end StartGenerator;

architecture Behavioral of StartGenerator is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                start <= (others => '0');
            else
                -- Bit 0 is always START_BIT_VAL ('0')
                start(0) <= START_BIT_VAL;
                
                -- Bits 1-6 depend on mode
                case my_mod is
                    when "00" | "01" | "11" => 
                        start(6 downto 1) <= START_CODE_VALID;
                    when "10" =>
                        start(6 downto 1) <= not START_CODE_VALID; -- intentionally generate invalid start code
                    when others =>
                        start(6 downto 1) <= (others => '0');
                end case;
            end if;
        end if;
    end process;
end Behavioral;