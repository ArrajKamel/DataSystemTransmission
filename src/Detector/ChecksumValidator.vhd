library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ChecksumValidator is
    Port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        data_in     : in  std_logic_vector(23 downto 0);
        data_len    : in  integer range 4 to 6;
        rx_bit      : in  std_logic;
        collecting  : in  std_logic;
        checksum_ok : out std_logic
    );
end ChecksumValidator;

architecture Behavioral of ChecksumValidator is
    signal computed_sum : std_logic_vector(3 downto 0);
    signal received_sum : std_logic_vector(3 downto 0);
    signal bit_counter : integer range 0 to 3;
begin
    -- Compute checksum continuously
    process(data_in, data_len)
        variable temp_sum : std_logic_vector(3 downto 0);
    begin
        temp_sum := "0000";
        for i in 0 to data_len-1 loop
            temp_sum := temp_sum xor data_in((i+1)*4-1 downto i*4);
        end loop;
        computed_sum <= temp_sum;
    end process;
    
    -- Receive checksum bits
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' or collecting = '1' then
                received_sum <= (others => '0');
                bit_counter <= 0;
                checksum_ok <= '0';
            else
                if bit_counter < 4 then
                    received_sum(bit_counter) <= rx_bit;
                    bit_counter <= bit_counter + 1;
                    
                    if bit_counter = 3 then
                        checksum_ok <= '1' when received_sum = computed_sum else '0';
                    end if;
                end if;
            end if;
        end if;
    end process;
end Behavioral;