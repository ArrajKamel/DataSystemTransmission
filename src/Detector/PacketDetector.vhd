-- PacketDetector.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.data_transmission_pkg.ALL;

entity PacketDetector is
    Port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        rx_bit  : in  std_logic;
        SS      : out std_logic;
        SM      : out std_logic;
        SC      : out std_logic
    );
end PacketDetector;

architecture Behavioral of PacketDetector is
    -- Subcomponents
    component StartDetector is
        Port (
            clk     : in  std_logic;
            rst     : in  std_logic;
            rx_bit  : in  std_logic;
            start_detected : out std_logic;
            data_ready     : out std_logic
        );
    end component;
    
    component DataCollector is
        Port (
            clk         : in  std_logic;
            rst         : in  std_logic;
            rx_bit     : in  std_logic;
            data_ready : in  std_logic;
            data_out   : out std_logic_vector(23 downto 0);
            data_len   : out integer range 4 to 6;
            collecting : out std_logic
        );
    end component;
    
    component ChecksumValidator is
        Port (
            clk         : in  std_logic;
            rst         : in  std_logic;
            data_in     : in  std_logic_vector(23 downto 0);
            data_len    : in  integer range 4 to 6;
            rx_bit     : in  std_logic;
            collecting  : in  std_logic;
            checksum_ok : out std_logic
        );
    end component;
    
    -- Internal signals
    signal start_detected  : std_logic;
    signal data_ready     : std_logic;
    signal s_collected_data : std_logic_vector(23 downto 0);
    signal s_collected_len  : integer range 4 to 6;
    signal s_collecting     : std_logic;
    signal checksum_valid : std_logic;

begin
    -- Instantiate subcomponents
    START_DET: StartDetector
        port map (
            clk     => clk,
            rst     => rst,
            rx_bit  => rx_bit,
            start_detected => start_detected,
            data_ready    => data_ready
        );
    
    DATA_COLL: DataCollector
        port map (
            clk         => clk,
            rst         => rst,
            rx_bit      => rx_bit,
            data_ready  => data_ready,
            data_out    => s_collected_data,
            data_len    => s_collected_len,
            collecting => s_collecting
        );
    
    CHECKSUM_VAL: ChecksumValidator
        port map (
            clk         => clk,
            rst         => rst,
            data_in     => s_collected_data,
            data_len    => s_collected_len,
            rx_bit      => rx_bit,
            collecting  => s_collecting,
            checksum_ok => checksum_valid
        );
    
    -- Output assignments
    SS <= start_detected;
    SM <= collecting;
    SC <= checksum_valid when not collecting else '0';
end Behavioral;