library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package data_transmission_pkg is
    -- Constants
    constant START_CODE_VALID    : std_logic_vector(5 downto 0) := "101010"; -- Example valid start code
    constant START_BIT_VAL       : std_logic := '0';
    
    -- Types
    type bcd_array is array (natural range <>) of std_logic_vector(3 downto 0);
    -- The natural range <> allows the array to have a flexible size,
    -- where natural is a non-negative integer type. 
    -- The size of the array is not fixed here, and it will be determined when an instance of this type is declared.
end package data_transmission_pkg;