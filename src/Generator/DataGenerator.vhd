library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.data_transmission_pkg.ALL;

entity DataGenerator is
    Port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        mod     : in  std_logic_vector(1 downto 0);
        data    : out std_logic_vector(23 downto 0);
        length  : out integer range 4 to 6
    );
end DataGenerator;

architecture Behavioral of DataGenerator is
    
    type data_array is array (0 to 3) of bcd_array(0 to 5);
    -- Predefined BCD data for different modes
    constant MODE_DATA : data_array := (
        -- Mode 00: 4 digits (16 bits)
        0 => ("0001", "0010", "0011", "0100", "0000", "0000"),
        -- Mode 01: 5 digits (20 bits)
        1 => ("0101", "0110", "0111", "1000", "1001", "0000"),
        -- Mode 10: 6 digits (24 bits) - but start code will be invalid
        2 => ("0001", "0010", "0011", "0100", "0101", "0110"),
        -- Mode 11: 4 digits with correct data but checksum will be wrong
        3 => ("0001", "0010", "0011", "0100", "0000", "0000")
    );
begin
    process(clk)
        variable mode_idx : integer;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                data <= (others => '0');
                length <= 4;
            else
                mode_idx := to_integer(unsigned(mod));
                
                for i in 0 to 5 loop
                    if i < 6 then
                        data((i+1)*4-1 downto i*4) <= MODE_DATA(mode_idx)(i);
                    end if;
                end loop;
                
                case mod is
                    when "00" => length <= 4;
                    when "01" => length <= 5;
                    when "10" => length <= 6;
                    when "11" => length <= 4;
                    when others => length <= 4;
                end case;
            end if;
        end if;
    end process;
end Behavioral;