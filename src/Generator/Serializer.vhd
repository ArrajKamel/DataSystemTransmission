library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Serializer is
    Port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        start        : in  std_logic_vector(6 downto 0);
        data         : in  std_logic_vector(23 downto 0);
        length       : in  integer range 4 to 6;
        sum          : in  std_logic_vector(3 downto 0);
        inputs_ready : in  boolean;
        tx_bit       : out std_logic
    );
end Serializer;

architecture Behavioral of Serializer is

    type state_type is (IDLE, TRANSMIT_START, TRANSMIT_DATA, TRANSMIT_CHECKSUM);
    signal state : state_type;
    signal s_bit_counter : integer range 0 to 31;
    signal s_packet_buffer : std_logic_vector(30 downto 0); -- Max packet size (7+24+4)
    signal s_packet_length : integer range 0 to 35;

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= IDLE;
                tx_bit <= '1';
                s_bit_counter <= 0;
            else
                case state is
                    when IDLE =>
                        if inputs_ready then 
                            s_packet_buffer(6 downto 0) <= start; -- from 0 to 6

                            for i in 0 to length - 1 loop -- from 7 to 22 (in case length = 4)
                                s_packet_buffer(7 + i*4 + 3 downto 7 + i*4) <= data(i*4 + 3 downto i*4);
                            end loop;

                            s_packet_buffer(6+length*4+4+1 downto 6+length*4+2) <= sum; -- from 23 to 26 (in case length = 4)
                            s_packet_length <= 7 + length*4 + 4; -- 27 in case length = 4 (in case length = 4)
                            state <= TRANSMIT_START;
                            s_bit_counter <= 0;
                        end if ;
                    
                    when TRANSMIT_START =>
                        tx_bit <= s_packet_buffer(s_bit_counter);
                        s_bit_counter <= s_bit_counter + 1;
                        
                        if s_bit_counter = 6 then
                            state <= TRANSMIT_DATA;
                        end if;
                    
                    when TRANSMIT_DATA =>
                        tx_bit <= s_packet_buffer(s_bit_counter);
                        s_bit_counter <= s_bit_counter + 1;
                        
                        if s_bit_counter = 6 + length*4 then
                            state <= TRANSMIT_CHECKSUM;
                        end if;
                    
                    when TRANSMIT_CHECKSUM =>
                        tx_bit <= s_packet_buffer(s_bit_counter);
                        s_bit_counter <= s_bit_counter + 1;
                        
                        if s_bit_counter = s_packet_length-1 then
                            state <= IDLE;
                        end if;
                end case;
            end if;
        end if;
    end process;
end Behavioral;