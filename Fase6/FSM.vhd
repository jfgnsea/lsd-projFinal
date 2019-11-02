library ieee;
use ieee.std_logic_1164.all;

entity FSM is
	port(	clock	:	in  std_logic;
			start	:	in  std_logic;
			reset	:	in  std_logic;
			genEn :	out std_logic;
			selMux:	out std_logic_vector(1 downto 0));
end FSM;

architecture Behavior of FSM is

	type t_states is (E0, E1, E2, E3);
	signal state, reg_state : t_states := E0;

begin
	
	process(clock, reg_state)
	begin
		if(clock='1' AND clock'event) then
			state <= reg_state;
		end if;
	end process;
	
	process(state, reset, start)
	begin
		if(reset ='1') then
			reg_state <= E0;
			selMux <= "00";
			genEn <= '0';
			
		else
			case state is
				-- Estado inicial. Não é mostrado nenhum output ate ser clicado start e ser escolhido um metodo de filtragem.
				when E0 =>
					if(start = '1') then
						reg_state <= E1;				
					else 
						reg_state <= E0;
					end if;
					
					selMux <= "00";
					genEn	<= '0';
				
				-- Estado em que o output e o maximo
				when E1 =>
					if(start = '1') then
						reg_state <= E2;				
					else 
						reg_state <= E1;
					end if;
					
					selMux <= "01";
					genEn <= '1';
					
				-- estado em que o output e o minimo
				when E2 =>
					if(start = '1') then
						reg_state <= E3;				
					else 
						reg_state <= E2;
					end if;
					
					selMux <= "10";
					genEn <= '1';
				
				-- estado em que o output e a media	
				when E3 =>
					if(start = '1') then
						reg_state <= E1;				
					else 
						reg_state <= E3;
					end if;
					
					selMux <= "11";
					genEn <= '1';
					
				when others =>
					reg_state <= E0;
					selMux <= "00";
					genEn <= '0';
					
			end case;
		end if;
	end process;
	
end Behavior;