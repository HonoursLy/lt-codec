library IEEE;
use IEEE.std_logic_1164.all;


entity transmitter is
	port (
		clk : in STD_LOGIC;
		message : in STD_LOGIC_VECTOR(7 downto 0);
		dout : out STD_LOGIC;
		reset : in STD_LOGIC
		-- Make clock four times length
		-- Add pin for when new parallel is ready
	);
end entity transmitter;

architecture arch of transmitter is
	signal internal : STD_LOGIC := '0';
	signal parallel : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
begin
	process (clk, internal) is
		variable count : INTEGER range 0 to 8;
	begin
		if (reset = '1') then
			dout <= '0';
			internal <= '0';
			parallel <= "00000000";
			count := 6;

		else
			dout <= internal xor clk;
			if (clk'event and clk = '1') then
				count := count + 1;
				if (count = 7) then
					parallel <= message;
				elsif (count = 8) then
					count := 0;
				end if;
				internal <= parallel(count);
			end if;

		end if;

	end process;

end architecture arch;
