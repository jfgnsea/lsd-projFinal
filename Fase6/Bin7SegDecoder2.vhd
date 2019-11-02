library IEEE; 
use IEEE.STD_LOGIC_1164.all; 
 
entity Bin7SegDecoder2 is     
	port(	binInput : in  std_logic_vector(1 downto 0);
			enable	: in	std_logic;
			decOut_n : out std_logic_vector(6 downto 0)); 
end Bin7SegDecoder2; 
 
architecture Behavioral of Bin7SegDecoder2 is
begin     
		decOut_n <= "1111111" when (enable	 =	'0')	else
						"1111001" when (binInput = "01") else  --1                 
						"0100100" when (binInput = "10") else  --2 
						"0110000" when (binInput = "11") else  --3                 
						"1000000";                             --0

end Behavioral; 