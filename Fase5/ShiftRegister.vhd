library ieee;
use ieee.std_logic_1164.all;

entity ShiftRegister is
	port(	clock	:	in  std_logic;
			enable:	in  std_logic;
			reset	:	in  std_logic;
			input	:	in  std_logic_vector(7 downto 0);
			out0	:	out std_logic_vector(7 downto 0);
			out1	:	out std_logic_vector(7 downto 0);
			out2	:	out std_logic_vector(7 downto 0);
			out3	:	out std_logic_vector(7 downto 0);
			out4	:	out std_logic_vector(7 downto 0));
end ShiftRegister;

architecture Behavior of ShiftRegister is

	signal s_r0, s_r1, s_r2, s_r3, s_r4:	std_logic_vector(7 downto 0);

begin

	reg0:	entity	work.Reg8(Behavior)
						port map(clock	=>	clock,
									enable=> enable,
									reset	=> reset,
									input	=>	input,
									output=> s_r0);
	
	reg1:	entity	work.Reg8(Behavior)
						port map(clock	=>	clock,
									enable=> enable,
									reset	=> reset,
									input	=>	s_r0,
									output=> s_r1);

	reg2:	entity	work.Reg8(Behavior)
						port map(clock	=>	clock,
									enable=> enable,
									reset	=> reset,
									input	=>	s_r1,
									output=> s_r2);
									
	reg3:	entity	work.Reg8(Behavior)
						port map(clock	=>	clock,
									enable=> enable,
									reset	=> reset,
									input	=>	s_r2,
									output=> s_r3);
									
	reg4:	entity	work.Reg8(Behavior)
						port map(clock	=>	clock,
									enable=> enable,
									reset	=> reset,
									input	=>	s_r3,
									output=> s_r4);
	
	out0 <= s_r0;
	out1 <= s_r1;
	out2 <= s_r2;
	out3 <= s_r3;
	out4 <= s_r4;

end Behavior;