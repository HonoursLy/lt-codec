library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clk_divider is
	generic (
		DIVISOR : positive := 2 -- must be >= 2
	);
	port (
		clk_in : in std_logic;
		reset : in std_logic;
		clk_out : out std_logic
	);
end entity clk_divider;

architecture rtl of clk_divider is
	signal counter : unsigned(31 downto 0) := (others => '0');
	signal clk_reg : std_logic := '1';
begin
	process (clk_in, reset) is
	begin
		if reset = '1' then
			counter <= (others => '0');
			clk_reg <= '0';
		elsif rising_edge(clk_in) then
			if counter = (DIVISOR / 2 - 1) then
				counter <= (others => '0');
				clk_reg <= not clk_reg;
			else
				counter <= counter + 1;
			end if;
		end if;
	end process;

	clk_out <= clk_reg;
end architecture rtl;
