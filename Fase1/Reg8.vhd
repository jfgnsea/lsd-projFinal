library ieee;
use ieee.std_logic_1164.all;

entity Reg8 is
	port(	clock	:	in  std_logic;
			enable:	in  std_logic;
			reset	:	in  std_logic;
			input	:	in  std_logic_vector(7 downto 0);
			output:	out std_logic_vector(7 downto 0));
end Reg8;

architecture Behavior of Reg8 is

	signal s_out: std_logic_vector(7 downto 0);

begin
	
	process(clock, enable, reset)
	begin
		if(reset = '1') then
			s_out <= "00000000";
		elsif(rising_edge(clock)) then
			if(enable = '1') then
				s_out <= input;
			else
				s_out <= s_out;
			end if;
		end if;
	end process;
	
	output <= s_out;
end Behavior;