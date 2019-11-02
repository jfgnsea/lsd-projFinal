library ieee;
use ieee.std_logic_1164.all;

entity Mux3 is
	port(	sel	:	in  std_logic_vector(1 downto 0);
			in0	:	in  std_logic_vector(7 downto 0);
			in1	:	in  std_logic_vector(7 downto 0);
			in2	:	in  std_logic_vector(7 downto 0);
			output:	out std_logic_vector(7 downto 0));
end Mux3;

architecture Behavior of Mux3 is
begin
	
	output <=	in0 when (sel="01") else
					in1 when (sel="10") else
					in2 when (sel="11") else
					(others => '0');
	
end Behavior;