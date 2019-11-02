library ieee;
use ieee.std_logic_1164.all;

entity Mux2 is
	port(	sel	:	in  std_logic;
			in0	:	in  std_logic_vector(7 downto 0);
			in1	:	in  std_logic_vector(7 downto 0);
			out0	:	out std_logic_vector(7 downto 0));
end Mux2;

architecture Behavior of Mux2 is
begin
	out0 <= 	in1 when (sel ='1') else
				in0;
end Behavior;