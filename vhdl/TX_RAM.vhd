-- Library and Use statements for IEEE packages
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_signed.all;


entity TX_RAM is
	port (
		-- enter port declarations here
		wr_clk : in STD_LOGIC;
		rd_clk : in STD_LOGIC;
		reset : in STD_LOGIC;
		wr_en : in STD_LOGIC;
		rd_en : in STD_LOGIC;
		wr_data : in STD_LOGIC_VECTOR (9 downto 0);
		rd_data : out STD_LOGIC_VECTOR (9 downto 0);
		tx_length : in STD_LOGIC_VECTOR (10 downto 0)
	);
end entity TX_RAM;

architecture arch of TX_RAM is
	SIGNAL w_count : STD_LOGIC_VECTOR (10 downto 0) := "00000000000";
	SIGNAL r_count : STD_LOGIC_VECTOR (10 downto 0) := "00000000000";
	SIGNAL wr_addr_i : STD_LOGIC_VECTOR (10 downto 0);
	SIGNAL rd_addr_i : STD_LOGIC_VECTOR (10 downto 0);

	component ram is
		generic (
			addr_width : natural := 9; -- 512x8
			data_width : natural := 8
		);
		port (
			write_en : in  std_logic;
			waddr    : in  std_logic_vector (addr_width - 1 downto 0);
			wclk     : in  std_logic;
			raddr    : in  std_logic_vector (addr_width - 1 downto 0);
			rclk     : in  std_logic;
			din      : in  std_logic_vector (data_width - 1 downto 0);
			dout     : out std_logic_vector (data_width - 1 downto 0)
		);
	end component;


    begin

process (wr_clk, reset)
	begin
		if (reset = '1') then
			w_count <= (others => '0');
		elsif falling_edge(wr_clk) then
			if wr_en = '1' then
				if (w_count = tx_length) then
					w_count <= (others => '0');
				else
					w_count <= w_count + 1;
				end if;
			end if;
		end if;
	end process;
process (rd_clk, reset)
	begin
		if (reset = '1') then
			r_count <= (others => '0');
		elsif falling_edge(rd_clk) then
			if rd_en = '1' then
				if (r_count = tx_length) then
					r_count <= (others => '0');
				else
					r_count <= r_count + 1;
				end if;
			end if;
		end if;
	end process;

	RAM_TX : component ram
	generic map(
		addr_width => 11, -- 2048x10
		data_width => 10
	)
	port map(
		write_en => wr_en,
		waddr => wr_addr_i,
		wclk => wr_clk,
		raddr => rd_addr_i, 
		rclk => rd_clk,
		din => wr_data,
		dout => rd_data
	);
	wr_addr_i <= w_count;
	rd_addr_i <= r_count;
end architecture arch;
