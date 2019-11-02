library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity resetModule is
	generic(N : positive :=4);
	port(	clock	:	in  std_logic;
			resetIn:	in  std_logic;
			resetOut:out std_logic);
end resetModule;

architecture arch of resetModule is

	signal s_shiftReg: std_logic_vector((N-1) downto 0) := (others => '0');

begin
	assert(N >= 2);
	
	shift_proc: process(resetIn, clock)
	begin
		if(resetIn ='1') then 
			s_shiftReg <= (others => '0');
		elsif (rising_edge(clock)) then
			s_shiftReg((N-1) downto 1) <= s_shiftReg((N-2) downto 0);
			s_shiftReg(0) <= '1';
		end if;
	end process;
	
	resetOut <= not s_shiftReg(N-1);
end arch;