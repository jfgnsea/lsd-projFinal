library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FiltroDigital_Tb is
end FiltroDigital_Tb;

architecture Behavior of FiltroDigital_Tb is

	signal s_clock: std_logic;
	signal s_key:	std_logic_vector(2 downto 0);

begin

	uut:	entity	work.FiltroDigital(Behavior)
						port map(CLOCK_50	=> s_clock,
									

end Behavior;