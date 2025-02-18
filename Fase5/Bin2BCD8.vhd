library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity Bin2BCD8 is
	port(	i		:	in	 std_logic_vector(7 downto 0);
			c, d,u:	out std_logic_vector(3 downto 0));
		 
		 
end Bin2BCD8;

architecture Behav of Bin2BCD8 is

	signal s_in	:	unsigned(7 downto 0);
	signal s_cd :	unsigned(7 downto 0);
	signal s_u,s_d,s_c	:	unsigned(7 downto 0);


begin
	s_in	<=	unsigned(i);
	
	s_u	<=	s_in rem 10;
	s_cd	<=	s_in / 10;
	s_d	<= s_cd rem 10;
	s_c	<= s_cd / 10;

	u	<=	std_logic_vector(s_u(3 downto 0));
	d	<=	std_logic_vector(s_d(3 downto 0));
	c	<=	std_logic_vector(s_c(3 downto 0));
	
end Behav;