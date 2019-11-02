library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ShiftRegister_Tb is
end ShiftRegister_Tb;

architecture Behavior of ShiftRegister_Tb is

	signal s_clk, s_enable, s_reset:	std_logic;
	signal s_in: unsigned(7 downto 0):="00000000"; 
	signal s_o0, s_o1, s_o2, s_o3, s_o4: std_logic_vector(7 downto 0);
	constant clk_t: time := 20 ns;

begin
	uut:	entity	work.ShiftRegister(structure)
						port map(clock	=>	s_clk,
									enable=> s_enable,
									reset	=> s_reset,
									input	=> std_logic_vector(s_in),
									out0	=> s_o0,
									out1	=> s_o1,
									out2	=> s_o2,
									out3	=> s_o3,
									out4	=> s_o4);
									
	clk_proc: process
	begin
		s_clk <= '0';
		wait for clk_t/2;
		s_clk <= '1';
		wait for clk_t/2;
		
	end process;
	
	en_proc: process
	begin
		s_enable <= '0';
		wait for clk_t*5;
		s_enable <= '1';
		wait for clk_t;
	end process;
		
	
	stim_proc: process
	begin
		s_in <= s_in +1;
		wait for clk_t;
	end process;
	
		stop_proc: process
		begin
			wait for 1000 ns;
			wait;
		end process;
end Behavior;