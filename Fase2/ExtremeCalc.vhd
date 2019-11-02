library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity ExtremeCalc is
	generic( waitCycles: natural := 5);
	port(	clock	:	in  std_logic;
			reset	:	in	 std_logic;
			enable:	in  std_logic;
			in0	:	in  std_logic_vector(7 downto 0);
			in1	:	in  std_logic_vector(7 downto 0);
			in2	:	in  std_logic_vector(7 downto 0);
			in3	:	in  std_logic_vector(7 downto 0);
			in4	:	in  std_logic_vector(7 downto 0);
			max	:	out std_logic_vector(7 downto 0);
			min	:	out std_logic_vector(7 downto 0));
 end entity ExtremeCalc;

architecture Behavior of ExtremeCalc is

	signal s_max, s_maxReg : unsigned(7 downto 0) := "00000000";
	signal s_min, s_minReg : unsigned(7 downto 0) := "11111111";
	type array_values is array(0 to 4) of unsigned(7 downto 0);
	signal values : array_values;
	signal count, cycle : integer := 0;

begin

	process (clock, enable, reset)
	begin
		if(reset ='1') then
			s_max <= "00000000";
			s_maxReg <= "00000000";
			s_min <= "11111111";
			s_minReg <= "11111111";
			count <= 0;
			
		elsif(rising_edge(clock)) then 
			if(cycle = waitCycles) then
				if (count= 5) then
					values(0) <= unsigned(in0);
					values(1) <= unsigned(in1);
					values(2) <= unsigned(in2);
					values(3) <= unsigned(in3);
					values(4) <= unsigned(in4);
					s_maxReg <= unsigned(in0);
					s_minReg <= unsigned(in0);
					count<=4;				
					
				end if;
			
				if (count <=4 and count >0) then
					
					-- determina o maximo e o minimo
					if(values(count)>s_maxReg or values(count)=s_maxReg ) then
						s_maxReg <= values(count);
					end if;
					
					if(values(count)<=s_minReg or values(count)=s_minReg) then
						s_minReg <= values(count);
					end if;
					count <= count -1;
					
				end if;
			
			else 
			
				cycle <= cycle +1;
			end if;
			
			if(enable = '1') then
				s_maxreg <= "00000000";
				s_minReg <= "11111111";
				count <= 5;
				cycle <= 0;
			end if;
			
			
			s_max <= s_maxReg;
			s_min <= s_minReg;
			
		
		end if; 
	end process;

max	<= std_logic_vector(s_max);
min 	<= std_logic_vector(s_min);


end Behavior;