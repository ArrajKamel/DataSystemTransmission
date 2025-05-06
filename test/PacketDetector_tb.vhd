library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.data_transmission_pkg.ALL;

entity PacketDetector_tb is
end PacketDetector_tb;

architecture Behavioral of PacketDetector_tb is

    -- DUT signals
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '0';
    signal rx_bit      : std_logic := '0';
    signal SS, SM, SC  : std_logic;

    -- Constants for clock period
    constant CLK_PERIOD : time := 10 ns;

    -- Component under test
    component PacketDetector
        Port (
            clk     : in  std_logic;
            rst     : in  std_logic;
            rx_bit  : in  std_logic;
            SS      : out std_logic;
            SM      : out std_logic;
            SC      : out std_logic
        );
    end component;

begin

    -- Instantiate DUT
    DUT: PacketDetector
        port map (
            clk => clk,
            rst => rst,
            rx_bit => rx_bit,
            SS => SS,
            SM => SM,
            SC => SC
        );

    -- Clock generation
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
        -- Helper procedures
        procedure apply_reset is
        begin
            rst <= '1';
            wait for 2 * CLK_PERIOD;
            rst <= '0';
            wait for 2 * CLK_PERIOD;
        end procedure;

        procedure send_bit(b : std_logic) is
        begin
            rx_bit <= b;
            wait for CLK_PERIOD;
        end procedure;

        procedure send_sequence(seq : std_logic_vector) is
        begin
            for i in seq'range loop
                send_bit(seq(i));
            end loop;
        end procedure;

        -- Example valid start + data + checksum pattern
        constant START_SEQ  : std_logic_vector(5 downto 0) := START_CODE_VALID ; -- replace with actual START_CODE_VALID
        constant DATA_SEQ_4 : std_logic_vector(15 downto 0) := "1010001111001101"; -- example 4 nibbles
        -- constant DATA_SEQ_5 : std_logic_vector(19 downto 0) := "10100011110011011011"; -- example 5 nibbles
        -- constant DATA_SEQ_6 : std_logic_vector(23 downto 0) := "101000111100110110111010"; -- example 6 nibbles
        constant CHECKSUM   : std_logic_vector(3 downto 0) := "1000"; -- example checksum

    begin
        -- Initialize
        apply_reset;

        -- Test 1: Valid 4-nibble packet
        send_bit('0'); -- START_BIT_VAL (assuming '0')
        send_sequence(START_SEQ(5 downto 0)); -- 6 bits start code
        send_sequence(DATA_SEQ_4);
        send_sequence(CHECKSUM);
        wait for 5 * CLK_PERIOD;

        -- -- Test 2: Valid 5-nibble packet
        -- apply_reset;
        -- send_bit('0');
        -- send_sequence(START_SEQ(5 downto 0));
        -- send_sequence(DATA_SEQ_5);
        -- send_sequence(CHECKSUM);
        -- wait for 5 * CLK_PERIOD;

        -- -- Test 3: Valid 6-nibble packet
        -- apply_reset;
        -- send_bit('0');
        -- send_sequence(START_SEQ(5 downto 0));
        -- send_sequence(DATA_SEQ_6);
        -- send_sequence(CHECKSUM);
        -- wait for 5 * CLK_PERIOD;

        -- Test 4: Invalid start code
        apply_reset;
        send_bit('0');
        send_sequence("111111"); -- wrong start code
        send_sequence(DATA_SEQ_4);
        send_sequence(CHECKSUM);
        wait for 5 * CLK_PERIOD;

        -- Test 5: Checksum mismatch
        apply_reset;
        send_bit('0');
        send_sequence(START_SEQ(5 downto 0));
        send_sequence(DATA_SEQ_4);
        send_sequence("0000"); -- wrong checksum
        wait for 5 * CLK_PERIOD;

        -- End simulation
        wait;
    end process;

end Behavioral;
