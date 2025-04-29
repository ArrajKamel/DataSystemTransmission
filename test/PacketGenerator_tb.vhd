library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PacketGenerator_tb is
end PacketGenerator_tb;

architecture tb of PacketGenerator_tb is

    -- Signals
    signal clk_tb     : std_logic := '0';
    signal rst_tb     : std_logic := '0';
    signal mod_tb     : std_logic_vector(1 downto 0) := (others => '0');
    signal tx_bit_tb  : std_logic;

    -- Clock period
    constant CLK_PERIOD : time := 10 ns;

    -- DUT Declaration
    component PacketGenerator is
        Port (
            clk     : in  std_logic;
            rst     : in  std_logic;
            mod     : in  std_logic_vector(1 downto 0);
            tx_bit  : out std_logic
        );
    end component;

begin

    -- DUT Instantiation
    UUT: PacketGenerator
        port map (
            clk     => clk_tb,
            rst     => rst_tb,
            mod     => mod_tb,
            tx_bit  => tx_bit_tb
        );

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk_tb <= '0';
            wait for CLK_PERIOD / 2;
            clk_tb <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Test Stimulus
    stim_proc : process
    begin
        -- Initial reset
        rst_tb <= '1';
        wait for 2 * CLK_PERIOD;
        rst_tb <= '0';

        -- Test Mode "00": 4-digit, valid packet
        mod_tb <= "00";
        report "Testing Mode 00 (Valid, 4 digits)";
        wait for 400 ns;

        -- Test Mode "01": 5-digit, valid packet
        mod_tb <= "01";
        report "Testing Mode 01 (Valid, 5 digits)";
        wait for 400 ns;

        -- Test Mode "10": 6-digit, INVALID start code
        mod_tb <= "10";
        report "Testing Mode 10 (Invalid Start Code)";
        wait for 400 ns;

        -- Test Mode "11": 4-digit, INVALID checksum
        mod_tb <= "11";
        report "Testing Mode 11 (Invalid Checksum)";
        wait for 400 ns;

        report "All test cases completed.";

        wait;
    end process;

end tb;
