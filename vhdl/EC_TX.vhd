-- Library and Use statements for IEEE packages
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EC_TX is

	port(
		EC_in : in STD_LOGIC_VECTOR(7 DOWNTO 0);
		EC_clk : in STD_LOGIC;
		EC_ENA : in STD_LOGIC;
		reset : in STD_LOGIC;
		LT_out : out STD_LOGIC_VECTOR (9 DOWNTO 0)
	);
end EC_TX;

ARCHITECTURE EC_arch OF EC_TX IS
	-- insert local declarations here
BEGIN
	process
	
	begin
		IF reset = '1' THEN
			LT_out <= (others => '0');
		ELSIF EC_ENA = '1' THEN
			if rising_edge(EC_clk) THEN
				LT_out <= EC_in & "01";
			end if;
		end if;
	end process;


END EC_arch;