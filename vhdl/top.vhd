-- Library and Use statements for IEEE packages
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity top is
	generic (
		BITS : INTEGER := 8 -- Input number of bits to EC
	);
	port (
		-- enter port declarations here
		reset : in STD_LOGIC;
		byte_in : in STD_LOGIC_VECTOR(BITS-1 downto 0);
		bit_valid : out STD_LOGIC;
		bit_out : out STD_LOGIC;
		byte_out : out STD_LOGIC_VECTOR(BITS-1 downto 0);
		byte_ready : out STD_LOGIC; -- byte ready for wr
		dbg_io1 : out STD_LOGIC
	);
end entity top;

architecture arch of top is
	-- insert local declarations here
	signal clk_48 : STD_LOGIC;
	signal glob_clk : STD_LOGIC;
	signal rx_clk : STD_LOGIC;
	signal man_in : STD_LOGIC;
	signal clk_4_tx : STD_LOGIC;
	signal byte_clk : STD_LOGIC;
	signal tx_byte : STD_LOGIC_VECTOR (BITS+1 downto 0);
	signal rx_byte : STD_LOGIC_VECTOR (BITS+1 downto 0);

	-- takes 48MHz -> 16MHz
	component PLL_clk is
		port (
			ref_clk_i : in std_logic;
			rst_n_i : in std_logic;
			outcore_o : out std_logic;
			outglobal_o : out std_logic
		);
	end component PLL_clk;

	component manchester_receiver is
		generic (
			OVERSAMPLE : natural := 16; -- oversample factor (must match PLL output)
			BAUD : natural := 1000000; -- Manchester bit rate
			BITS : INTEGER := 10 -- Number of bits being processed out
		);
		port (
			clk_ovs : in std_logic; -- oversample clock from PLL (OVERSAMPLE BAUD)
			reset : in std_logic;
			man_in : in std_logic; -- Manchester encoded input
			bit_valid : out std_logic; -- one-cycle pulse when bit_out is valid
			bit_out : out std_logic; -- decoded bit
			byte_out : out std_logic_vector(BITS-1 downto 0);
			byte_ready : out std_logic -- pulse when byte_out is valid
		);
	end component manchester_receiver;

	component SB_HFOSC is
		generic (
			CLKHF_DIV : STRING := "0b00"
		);
		port (
			CLKHFEN : in STD_LOGIC;
			CLKHFPU : in STD_LOGIC;
			CLKHF : out STD_LOGIC
		);
	end component SB_HFOSC;

	component manchester_encoder is
		generic(
			BITS : INTEGER := 10 -- Number of bits being encoded
		);
		port (
			clk : in STD_LOGIC;
			message : in STD_LOGIC_VECTOR(BITS-1 downto 0);
			dout : out STD_LOGIC;
			reset : in STD_LOGIC
		);
	end component manchester_encoder;

	component clk_divider is
		generic (
			Freq_in : positive := 16000000
		);
		port (
			clk_in : in std_logic;
			reset : in std_logic;
			clk_out : out std_logic
		);
	end component clk_divider;

	component EC_RX is

		port(
			EC_clk : in STD_LOGIC;
			EC_ENA : in STD_LOGIC;
			reset : in STD_LOGIC;
			LT_in : in STD_LOGIC_VECTOR (9 DOWNTO 0);
			EC_out : out STD_LOGIC_VECTOR(7 DOWNTO 0)
		);
	end component;

	component EC_TX is

		port(
			EC_in : in STD_LOGIC_VECTOR(7 DOWNTO 0);
			EC_clk : in STD_LOGIC;
			EC_ENA : in STD_LOGIC;
			reset : in STD_LOGIC;
			LT_out : out STD_LOGIC_VECTOR (9 DOWNTO 0)
		);
	end component;
begin
	-- Component instantiation statement
	RX_PLL_clk: component PLL_clk
	port map (
		ref_clk_i => clk_48,
		rst_n_i => not reset,
		outcore_o => rx_clk,
		outglobal_o => glob_clk
	);
	uut: component manchester_receiver
	generic map (
		OVERSAMPLE => 16, -- oversample factor (must match PLL output) must be even number. oversample - 2
		BAUD => 1000000, -- Manchester bit rate
		BITS => 10
	)
	port map (
		clk_ovs => rx_clk,
		reset => reset,
		man_in => man_in,
		bit_valid => bit_valid,
		bit_out => bit_out,
		byte_out => RX_byte,
		byte_ready => byte_clk
	);
	u_osc: component SB_HFOSC
	generic map (
		CLKHF_DIV => "0b00"
	)
	port map (
		CLKHFEN => '1',
		CLKHFPU => '1',
		CLKHF => clk_48
	);
	txt: component manchester_encoder
	generic map (
		BITS => 10
	)
	port map (
		clk => clk_4_tx,
		message => TX_byte,
		dout => man_in,
		reset => reset
	);
	tx_clk: component clk_divider
	generic map (
		Freq_in => 16
	)
	port map (
		clk_in => rx_clk,
		reset => reset,
		clk_out => clk_4_tx
	);
	ECTX : component EC_TX
	port map (
		EC_in => byte_in,
		EC_clk => byte_clk,
		EC_ENA => not reset,
		reset => reset,
		LT_out => TX_byte
	);

	ECRX : component EC_RX
	port map(
		EC_clk => byte_clk,
		EC_ENA => not reset,
		reset => reset,
		LT_in => RX_byte,
        EC_out => byte_out
	);

	-- Generate statement
	dbg_io1 <= rx_clk;
	byte_ready <= byte_clk;
end architecture arch;
