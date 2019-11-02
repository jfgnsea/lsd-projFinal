library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Average is
	generic( waitCycles: natural := 5);
	port( clock	:	in  std_logic;
			reset	:	in	 std_logic;
			enable:	in  std_logic;
			in0	:	in  std_logic_vector(7 downto 0);
			in1	:	in  std_logic_vector(7 downto 0);
			in2	:	in  std_logic_vector(7 downto 0);
			in3	:	in  std_logic_vector(7 downto 0);
			in4	:	in  std_logic_vector(7 downto 0);
			avg	:	out std_logic_vector(7 downto 0));
end Average;

architecture Behavior of Average is
	-- sinal de 11 bits para evitar overflow,e consequentemente perda de dados, na soma dos 5 numeros
	signal S_sum :unsigned(10 downto 0) := (others => '0'); 
	signal s_avgReg : unsigned(10 downto 0) := (others => '0');
	signal s_avg	:	unsigned(7 downto 0) := (others => '0');
	type array_values is array(0 to 4) of unsigned(7 downto 0);
	signal values : array_values;
	signal count, cycle: integer := 0;

begin
	process(clock, enable, reset)
	begin
		if(reset ='1') then
			s_sum <= (others => '0');
			s_avgReg <= (others => '0');
			s_avg <= (others => '0');
			count <= 0;
			cycle <= 0;
			
		elsif(rising_edge(clock)) then
			if(cycle = waitCycles) then
				if (count = 0) then
					values(0) <= unsigned(in0);
					values(1) <= unsigned(in1);
					values(2) <= unsigned(in2);
					values(3) <= unsigned(in3);
					values(4) <= unsigned(in4);
					count <= 1;

				elsif(count = 6) then
					s_avgReg <=  s_sum/5;
				else
					s_sum <= s_sum +values(count-1);
					count <= count +1;
				end if;
			else
				cycle <= cycle +1;
			end if;
			
			s_avg <= s_avgReg(7 downto 0);
			
			if(enable ='1') then
				count <= 0;
				s_sum<=(others => '0');
				cycle <= 0;
			end if;
			
		end if;
	end process;
	
	avg <= std_logic_vector(s_avgReg(7 downto 0));
	
end Behavior;