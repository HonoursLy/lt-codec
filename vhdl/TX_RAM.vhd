-- Library and Use statements for IEEE packages
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.std_logic_signed.ALL;
ENTITY TX_RAM IS
	PORT (
		-- enter port declarations here
		wr_clk : IN STD_LOGIC;
		rd_clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		wr_en : IN STD_LOGIC;
		rd_en : IN STD_LOGIC;
		wr_data : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		rd_data : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
		tx_length : IN STD_LOGIC_VECTOR (10 DOWNTO 0)
	);
END ENTITY TX_RAM;

ARCHITECTURE arch OF TX_RAM IS
	SIGNAL w_count : STD_LOGIC_VECTOR (10 DOWNTO 0) := "00000000000";
	SIGNAL r_count : STD_LOGIC_VECTOR (10 DOWNTO 0) := "00000000000";
	SIGNAL wr_addr_i : STD_LOGIC_VECTOR (10 DOWNTO 0);
	SIGNAL rd_addr_i : STD_LOGIC_VECTOR (10 DOWNTO 0);

	COMPONENT bram_2048x10
		PORT (
			-- Write port
			wclk : IN STD_LOGIC;
			we : IN STD_LOGIC;
			waddr : IN STD_LOGIC_VECTOR(10 DOWNTO 0); -- 2048 deep
			din : IN STD_LOGIC_VECTOR(9 DOWNTO 0);

			-- Read port
			rclk : IN STD_LOGIC;
			re : IN STD_LOGIC;
			raddr : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
			dout : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
		);
	END COMPONENT;

BEGIN

	PROCESS (wr_clk, reset)
	BEGIN
		IF (reset = '1') THEN
			w_count <= (OTHERS => '0');
		ELSIF falling_edge(wr_clk) THEN
			IF wr_en = '1' THEN
				IF (w_count = tx_length) THEN
					w_count <= (OTHERS => '0');
				ELSE
					w_count <= w_count + 1;
				END IF;
			END IF;
		END IF;
	END PROCESS;
	PROCESS (rd_clk, reset)
	BEGIN
		IF (reset = '1') THEN
			r_count <= (OTHERS => '0');
		ELSIF falling_edge(rd_clk) THEN
			IF rd_en = '1' THEN
				IF (r_count = tx_length) THEN
					r_count <= (OTHERS => '0');
				ELSE
					r_count <= r_count + 1;
				END IF;
			END IF;
		END IF;
	END PROCESS;

	RAM_TX : COMPONENT ram
		GENERIC MAP(
			addr_width => 11, -- 2048x10
			data_width => 10
		)
		PORT MAP(
			wclk => wr_clk,
			we => wr_en,
			waddr => wr_addr_i,
			din => wr_data,
			rclk => rd_clk,
			re => rd_en,
			raddr => rd_addr_i,
			dout => rd_data
		);

		wr_addr_i <= w_count;
		rd_addr_i <= r_count;
	END ARCHITECTURE arch;