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
            my_mod : in  std_logic_vector(1 downto 0);
            SS  : out std_logic;
            SM  : out std_logic;
            SC  : out std_logic';
            data_line_debug : out std_logic  -- << Add this
        );
    end component;

    -- Signals
    signal clk_tb  : std_logic := '0';
    signal rst_tb  : std_logic := '1';
    signal mod_tb  : std_logic_vector(1 downto 0) := (others => '0');
    signal SS_tb   : std_logic;
    signal SM_tb   : std_logic;
    signal SC_tb   : std_logic;

    constant clk_period : time := 10 ns;

begin

    -- Instantiate DUT
    DUT: DataTransmissionSystem
        port map (
            clk => clk_tb,
            rst => rst_tb,
            my_mod => mod_tb,
            SS  => SS_tb,
            SM  => SM_tb,
            SC  => SC_tb,
            data_line_debug => data_line_tb
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
    begin
        -- Hold reset for two clock cycles
        wait for 2 * clk_period;
        rst_tb <= '0';

        -- Mode 00: Valid Packet
        mod_tb <= "00";

        -- Let the system run long enough to transmit & detect (5 us should be safe)
        wait for 5 us;

        -- Stop simulation (you can continue later for other modes)
        wait;
    end process;

end behavior;
