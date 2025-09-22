-- Library and Use statements for IEEE packages
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity top is
	port (
		-- enter port declarations here
		reset : in STD_LOGIC;
		byte_in : in STD_LOGIC_VECTOR(7 downto 0);
		bit_valid : out STD_LOGIC;
		bit_out : out STD_LOGIC;
		byte_out : out STD_LOGIC_VECTOR(7 downto 0);
		byte_ready : out STD_LOGIC; -- byte ready for wr
		rx_clk_out : out STD_LOGIC
	);
end entity top;

architecture arch of top is
	-- insert local declarations here
	signal clk_48 : STD_LOGIC;
	signal glob_clk : STD_LOGIC;
	signal rx_clk : STD_LOGIC;
	signal man_in : STD_LOGIC;
	signal clk_4_tx : STD_LOGIC;

	-- takes 48MHz -> 16MHz
	component PLL_clk is
		port (
			ref_clk_i : in std_logic;
			rst_n_i : in std_logic;
			outcore_o : out std_logic;
			outglobal_o : out std_logic
		);
	end component PLL_clk;

	component manchester_decoder is
		generic (
			OVERSAMPLE : natural := 16; -- oversample factor (must match PLL output)
			BAUD : natural := 1000000 -- Manchester bit rate
		);
		port (
			clk_ovs : in std_logic; -- oversample clock from PLL (OVERSAMPLE BAUD)
			reset : in std_logic;
			man_in : in std_logic; -- Manchester encoded input
			bit_valid : out std_logic; -- one-cycle pulse when bit_out is valid
			bit_out : out std_logic; -- decoded bit
			byte_out : out std_logic_vector(7 downto 0);
			byte_ready : out std_logic -- pulse when byte_out is valid
		);
	end component manchester_decoder;

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

	component transmitter is
		port (
			clk : in STD_LOGIC;
			message : in STD_LOGIC_VECTOR(7 downto 0);
			dout : out STD_LOGIC;
			reset : in STD_LOGIC
			-- Make clock four times length
			-- Add pin for when new parallel is ready
		);
	end component transmitter;

	component clk_divider is
		generic (
			DIVISOR : positive := 2 -- must be >= 2
		);
		port (
			clk_in : in std_logic;
			reset : in std_logic;
			clk_out : out std_logic
		);
	end component clk_divider;
begin
	-- insert synthesizable code here

	-- Process statement

	-- Concurrent signal assignment

	-- Conditional signal assignment

	-- Selected signal assignment

	-- Component instantiation statement
	RX_PLL_clk: component PLL_clk
	port map (
		ref_clk_i => clk_48,
		rst_n_i => reset,
		outcore_o => rx_clk,
		outglobal_o => glob_clk
	);
	uut: component manchester_decoder
	generic map (
		OVERSAMPLE => 16, -- oversample factor (must match PLL output) must be even number. oversample - 2
		BAUD => 1000000 -- Manchester bit rate
	)
	port map (
		clk_ovs => rx_clk,
		reset => reset,
		man_in => man_in,
		bit_valid => bit_valid,
		bit_out => bit_out,
		byte_out => byte_out,
		byte_ready => byte_ready
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
	txt: component transmitter
	port map (
		clk => clk_4_tx,
		message => byte_in,
		dout => man_in,
		reset => reset
	);
	tx_clk: component clk_divider
	generic map (
		DIVISOR => 16 -- must be >= 2
	)
	port map (
		clk_in => rx_clk,
		reset => reset,
		clk_out => clk_4_tx
	);
	-- Generate statement
	rx_clk_out <= rx_clk;
end architecture arch;
