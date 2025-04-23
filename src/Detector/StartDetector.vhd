library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.data_transmission_pkg.ALL;

entity StartDetector is
    Port (
        clk             : in  std_logic;
        rst             : in  std_logic;
        rx_bit          : in  std_logic;
        start_detected  : out std_logic;
        data_ready     : out std_logic -- indicates downstream components can now begin processing incoming data.
    );
end StartDetector;

architecture Behavioral of StartDetector is

    type state_type is (IDLE, CHECK_START_BIT, CHECK_START_CODE, VALID_START);
    signal state : state_type;
    signal s_shift_reg : std_logic_vector(5 downto 0):= (others => '0');
    signal s_bit_counter : integer range 0 to 5;
    
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= IDLE;
                start_detected <= '0';
                data_ready <= '0';
                s_shift_reg <= (others => '0');
                s_bit_counter <= 0;
            else
                case state is
                    when IDLE =>
                        start_detected <= '0';
                        data_ready <= '0';
                        if rx_bit = START_BIT_VAL then
                            state <= CHECK_START_BIT;
                        end if;
                    
                    when CHECK_START_BIT =>
                        -- First bit was '0', now collect next 6 bits
                        s_shift_reg <= s_shift_reg(4 downto 0) & rx_bit;
                        s_bit_counter <= s_bit_counter + 1;
                        
                        if s_bit_counter = 5 then
                            state <= CHECK_START_CODE;
                            s_bit_counter <= 0;
                        end if;
                    
                    when CHECK_START_CODE =>
                        if s_shift_reg = START_CODE_VALID then
                            state <= VALID_START;
                            start_detected <= '1';
                            data_ready <= '1';
                        else
                            state <= IDLE;
                        end if;
                    
                    when VALID_START =>
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;
end Behavioral;