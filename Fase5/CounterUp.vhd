library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CounterUp is
	port(	clock	:	in  std_logic;
			enable:	in  std_logic;
			chgInRst:	in  std_logic;
			chgFilRst:	in std_logic;
			reset	:	in  std_logic;
			count	:	out std_logic_vector(5 downto 0));
end CounterUp;

architecture Behavior of Counterup is
	signal s_count: unsigned(5 downto 0);

begin

	process(clock, enable)
	begin
		if(rising_edge(clock)) then
			if(reset = '1' or chgInRst='1' or chgFilRst='1') then
				s_count <= (others => '0');
			elsif(enable ='1') then
				s_count <= s_count +1;
			else
				s_count <= s_count;
			end if;
		end if;
	end process;
	
	count <= std_logic_vector(s_count);

end Behavior;