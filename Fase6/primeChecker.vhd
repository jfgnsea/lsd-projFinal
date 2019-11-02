library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity primeChecker is
	generic(NumCyclesWait :integer := 0);
    port(clock: in  std_logic;
			enable: in  std_logic;
			reset   : in  std_logic;
			input   : in std_logic_vector(7 downto 0);
			isPrime : out std_logic);
end primeChecker;



architecture arch1 of primeChecker is

	signal cycle: integer := 0;

	signal div: unsigned(7 downto 0) := to_unsigned(2,8);
	signal s_q, s_rem: std_logic_vector(7 downto 0);
	signal s_start: std_logic;
	signal s_ready, s_ovfl: std_logic;

	signal prime, primeOut: std_logic :='0';
	
	signal division: std_logic:='1';


begin

	divider0:	entity	work.Divider8(Behavioral)
								port map(clock => clock,
											reset => reset,
											start => s_start,
											m => "00000000"&input,
											n => std_logic_vector(div),
											quotient => s_q,
											remainder => s_rem,
											ready => s_ready,
											ovfl => s_ovfl);
	
	
	
	process(clock, s_ready)
	begin
		if(rising_edge(clock)) then
			if(cycle = NumCyclesWait) then
				prime <= '1';
				if((s_ready ='1' or s_ovfl='1') and div < unsigned(input)) then
					if(unsigned(s_rem) = "00000000") then
						prime <= '0';
						division <= '0';
					else
						prime<= '1';
						div <=  div +1;
						division <= '1';
					end if;
				end if;
				
				if(division = '1') then
					s_start <= '1';
					division <= '0';
				else
					s_start <= '0';
				end if;
				
			else
				cycle <= cycle +1;
			end if;
			
			if(enable = '1') then
				primeOut <= prime;
				prime <= '1';
				div <=  to_unsigned(2,8);
				cycle <= 0;
				division <= '1';
			end if;
			
		end if;	
	end process;
								
	isPrime <= primeOut;
	
end arch1;

architecture table of primeChecker is
	
	
	signal prime : std_logic;
	
	type TROM is array (0 to 255) of std_logic; 
	constant lookUp_Table : TROM := (
													'0','0','1','1','0','1','0','1','0','0','0','1','0','1','0','0','0','1','0','1','0','0','0','1','0','0','0','0','0','1','0','1',
													'0','0','0','0','0','1','0','0','0','1','0','1','0','0','0','1','0','0','0','0','0','1','0','0','0','0','0','1','0','1','0','0',
													'0','0','0','1','0','0','0','1','0','1','0','0','0','0','0','1','0','0','0','1','0','0','0','0','0','1','0','0','0','0','0','0',
													'0','1','0','0','0','1','0','1','0','0','0','1','0','1','0','0','0','1','0','0','0','0','0','0','0','0','0','0','0','0','0','1',
													'0','0','0','1','0','0','0','0','0','1','0','1','0','0','0','0','0','0','0','0','0','1','0','1','0','0','0','0','0','1','0','0',
													'0','0','0','1','0','0','0','1','0','0','0','0','0','1','0','0','0','0','0','1','0','1','0','0','0','0','0','0','0','0','0','1',
													'0','1','0','0','0','1','0','1','0','0','0','0','0','0','0','0','0','0','0','1','0','0','0','0','0','0','0','0','0','0','0','1',
													'0','0','0','1','0','1','0','0','0','1','0','0','0','0','0','1','0','1','0','0','0','0','0','0','0','0','0','1','0','0','0','0'
													);

	begin

	process(clock, reset)
	begin
		if(rising_edge(clock)) then
			if(reset ='1') then
				prime <= '0';
			elsif(enable ='1') then
				prime <= lookUp_Table(to_integer(unsigned(input)));
			end if;
		end if;
	end process;
	isPrime <= prime; 
end table;