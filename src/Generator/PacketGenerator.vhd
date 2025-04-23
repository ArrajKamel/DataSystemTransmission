library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.data_transmission_pkg.ALL;

entity PacketGenerator is
    Port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        mod     : in  std_logic_vector(1 downto 0);
        tx_bit  : out std_logic
    );
end PacketGenerator;

architecture Behavioral of PacketGenerator is

    component StartGenerator is
        Port (
            clk     : in  std_logic;
            rst     : in  std_logic;
            mod     : in  std_logic_vector(1 downto 0);
            start   : out std_logic_vector(6 downto 0)
        );
    end component;
    
    component DataGenerator is
        Port (
            clk     : in  std_logic;
            rst     : in  std_logic;
            mod     : in  std_logic_vector(1 downto 0);
            data    : out std_logic_vector(23 downto 0);
            length  : out integer range 4 to 6
        );
    end component;
    
    component ChecksumUnit is
        Port (
            data    : in  std_logic_vector(23 downto 0);
            length  : in  integer range 4 to 6;
            sum     : out std_logic_vector(3 downto 0)
        );
    end component;
    
    signal s_inputs_ready : boolean := false;

    component Serializer is
        Port (
            clk          : in  std_logic;
            rst          : in  std_logic;
            start        : in  std_logic_vector(6 downto 0);
            data         : in  std_logic_vector(23 downto 0);
            length       : in  integer range 4 to 6;
            sum          : in  std_logic_vector(3 downto 0);
            inputs_ready : in  std_logic;
            tx_bit       : out std_logic
        );
    end component;
    
    signal s_start_seg  : std_logic_vector(6 downto 0);
    signal s_data_seg   : std_logic_vector(23 downto 0);
    signal s_data_len   : integer range 4 to 6;
    signal s_checksum   : std_logic_vector(3 downto 0);

begin
    START_GEN: StartGenerator
        port map (
            clk     => clk,
            rst     => rst,
            mod     => mod,
            start   => s_start_seg
        );
    
    DATA_GEN: DataGenerator
        port map (
            clk     => clk,
            rst     => rst,
            mod     => mod,
            data    => s_data_seg,
            length  => s_data_len
        );
    
    CHECKSUM_GEN: ChecksumUnit
        port map (
            data    => s_data_seg,
            length  => s_data_len,
            sum     => s_checksum
        );

    s_inputs_ready <= (s_start_seg /= "0000000" and s_data_seg /= (others => '0') and s_checksum /= "0000");

    SERIALIZER: Serializer
        port map (
            clk     => clk,
            rst     => rst,
            start   => s_start_seg,
            data    => s_data_seg,
            length  => s_data_len,
            sum     => s_checksum,
            inputs_ready   => s_inputs_ready,
            tx_bit  => tx_bit
        );
end Behavioral;