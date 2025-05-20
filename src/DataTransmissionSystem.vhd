library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.data_transmission_pkg.ALL;

entity DataTransmissionSystem is
    Port (
        clk  : in  std_logic;
        rst  : in  std_logic;
        mod  : in  std_logic_vector(1 downto 0);
        SS   : out std_logic; -- Start Detected
        SM   : out std_logic; -- Message In Progress
        SC   : out std_logic ; -- Checksum Valid;
        data_line_debug : out std_logic  -- << Add this
    );
end DataTransmissionSystem;

architecture Structural of DataTransmissionSystem is
    
    signal data_line : std_logic; -- the bridge between generator and detector
    
    component PacketGenerator is
        Port (
            clk     : in  std_logic;
            rst     : in  std_logic;
            mod     : in  std_logic_vector(1 downto 0);
            tx_bit  : out std_logic
        );
    end component;
    
    component PacketDetector is
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
    GEN_INST: PacketGenerator
        port map (
            clk     => clk,
            rst     => rst,
            mod     => mod,
            tx_bit  => data_line
        );
    
    DET_INST: PacketDetector
        port map (
            clk     => clk,
            rst     => rst,
            rx_bit  => data_line,
            SS      => SS,
            SM      => SM,
            SC      => SC
        );

    data_line_debug <= data_line; -- expose internal signal
end Structural;