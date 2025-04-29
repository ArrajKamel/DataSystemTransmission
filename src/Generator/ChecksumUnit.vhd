library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ChecksumUnit is
    Port (
        data    : in  std_logic_vector(23 downto 0);
        length  : in  integer range 4 to 6;
        sum     : out std_logic_vector(3 downto 0)
    );
end ChecksumUnit;

architecture Behavioral of ChecksumUnit is
begin
     process(data, length)
       variable temp_sum : std_logic_vector(3 downto 0);
   begin
       temp_sum := "0000";
       
       for i in 0 to length-1 loop
           temp_sum := temp_sum xor data((i+1)*4-1 downto i*4);
       end loop;
       
       if (length = 4 and data(3 downto 0) = "0100") then
           sum <= not temp_sum;
       else
           sum <= temp_sum;
       end if;
   end process;
end Behavioral;