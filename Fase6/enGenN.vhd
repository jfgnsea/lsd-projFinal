library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity enGenN is
    generic(n   :   positive := 10);
    port(clkin  :   in  std_logic;
			enable :	  in  std_logic;
         enout  :   out std_logic);
end  enGenN;

architecture Behav of enGenN is

    signal s_enOut   : std_logic;
    signal s_count   : integer := 0;

begin
	 
    process(clkin)
    begin
      if(rising_edge(clkin)) then
		
			if(enable ='1') then
				if(s_count = n) then
					s_count <= 0;
					s_enOut <= '1';
				else
					s_enOut <= '0';
					s_count <= s_count + 1;
				end if;
				
			 else 
				s_count <= 0;
				s_enOut <= '0';
			 end if;
      end if;
    end process;

    enout <= s_enOut;

end Behav;
