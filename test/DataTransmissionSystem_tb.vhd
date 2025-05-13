library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DataTransmissionSystem_tb is
end DataTransmissionSystem_tb;

architecture behavior of DataTransmissionSystem_tb is
    -- Component under test
    component DataTransmissionSystem
        Port (
            clk : in  std_logic;
            rst : in  std_logic;
            mod : in  std_logic_vector(1 downto 0);
            SS  : out std_logic;
            SM  : out std_logic;
            SC  : out std_logic
        );
    end component;

    -- Signals
    signal clk_tb  : std_logic := '0';
    signal rst_tb  : std_logic := '1';
    signal mod_tb  : std_logic_vector(1 downto 0) := (others => '0');
    signal SS_tb   : std_logic;
    signal SM_tb   : std_logic;
    signal SC_tb   : std_logic;

    -- Clock period
    constant clk_period : time := 10 ns;

begin
    -- Instantiate DUT
    DUT: DataTransmissionSystem
        port map (
            clk => clk_tb,
            rst => rst_tb,
            mod => mod_tb,
            SS  => SS_tb,
            SM  => SM_tb,
            SC  => SC_tb
        );

    -- Clock generation
    clk_process :process
    begin
        while true loop
            clk_tb <= '0';
            wait for clk_period/2;
            clk_tb <= '1';
            wait for clk_period/2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
        procedure run_test(
            mode_value : std_logic_vector(1 downto 0);
            expected_SS : std_logic;
            expected_SM : std_logic;
            expected_SC : std_logic
        ) is
        begin
            mod_tb <= mode_value;
            rst_tb <= '1';
            wait for clk_period * 2;
            rst_tb <= '0';

            wait for 5000 ns; -- enough time for transmission & detection

            assert SS_tb = expected_SS
                report "SS mismatch for mode=" & to_hstring(mode_value)
                severity error;
            assert SM_tb = expected_SM
                report "SM mismatch for mode=" & to_hstring(mode_value)
                severity error;
            assert SC_tb = expected_SC
                report "SC mismatch for mode=" & to_hstring(mode_value)
                severity error;

            report "Test PASSED for mode=" & to_hstring(mode_value);
        end procedure;
    begin
        wait for clk_period * 5;

        -- Mode 00: Valid packet
        run_test("00", '1', '1', '1');

        -- Mode 01: Valid packet, different data
        run_test("01", '1', '1', '1');

        -- Mode 10: Invalid start
        run_test("10", '0', '0', '0');

        -- Mode 11: Invalid checksum
        run_test("11", '1', '1', '0');

        report "All test cases completed.";
        wait;
    end process;

end behavior;
