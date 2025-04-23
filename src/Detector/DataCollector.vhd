library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DataCollector is
    Port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        rx_bit      : in  std_logic;
        data_ready  : in  std_logic;
        data_out    : out std_logic_vector(23 downto 0);
        data_len    : out integer range 4 to 6;
        collecting  : out std_logic
    );
end DataCollector;

architecture Behavioral of DataCollector is
    type state_type is (IDLE, COLLECT_DATA);
    signal state : state_type:= IDLE;
    signal s_bit_counter : integer range 0 to 31;
    signal s_word_counter : integer range 0 to 6;
    signal s_shift_reg : std_logic_vector(3 downto 0);
    signal s_temp_data : std_logic_vector(23 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= IDLE;
                data_out <= (others => '0');
                data_len <= 4;
                collecting <= '0';
                s_bit_counter <= 0;
                s_word_counter <= 0;
                s_temp_data <= (others => '0');
            else
                case state is
                    when IDLE => -- Waiting for data_ready from StartDetector
                        collecting <= '0';
                        if data_ready = '1' then
                            state <= COLLECT_DATA;
                            collecting <= '1';
                            s_bit_counter <= 0;
                            s_word_counter <= 0;
                        end if;
                    
                    when COLLECT_DATA => --Actively shifting in serial bits and packing them into temp_data.
                        s_shift_reg <= s_shift_reg(2 downto 0) & rx_bit;
                        s_bit_counter <= s_bit_counter + 1;
                        
                        if s_bit_counter = 3 then
                            s_temp_data((s_word_counter+1)*4-1 downto s_word_counter*4) <= s_shift_reg;
                            s_word_counter <= s_word_counter + 1;
                            s_bit_counter <= 0;
                            
                            if (s_word_counter = 3 and rx_bit = '0') or 
                               (s_word_counter = 4 and rx_bit = '1') or 
                               s_word_counter = 5 then
                                    state <= IDLE;
                                    data_out <= s_temp_data;
                                    data_len <= s_word_counter + 1;
                                    collecting <= '0';
                            end if;
                        end if;
                end case;
            end if;
        end if;
    end process;
end Behavioral;