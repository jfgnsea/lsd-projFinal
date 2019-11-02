library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.vga_config.all;

entity vga_unit is
	port(	clockIn:	in  std_logic;
			
			-- estados internos
			selInput: in  std_logic;
			selOutput:	in std_logic_vector(1 downto 0);
			
			-- digitos do numero de entrada do sistema
			in0: in std_logic_vector(3 downto 0);
			in1: in std_logic_vector(3 downto 0);
			in2: in std_logic_vector(3 downto 0);
			
			-- digitos do numero de saida do sistema
			out0: in std_logic_vector(3 downto 0);
			out1: in std_logic_vector(3 downto 0);
			out2: in std_logic_vector(3 downto 0);
			
			--primality
			isPrime: in std_logic;
			
			--portas VGA 
		  vga_clk     : out std_logic;
		  vga_hs      : out std_logic;
		  vga_vs      : out std_logic;
		  vga_sync_n  : out std_logic;
		  vga_blank_n : out std_logic;
		  vga_r       : out std_logic_vector(7 downto 0);
		  vga_g       : out std_logic_vector(7 downto 0);
		  vga_b       : out std_logic_vector(7 downto 0));
end vga_unit;

architecture arch of vga_unit is

	-- sinal com o clock vga
	signal clock: std_logic;

	  -- the VGA stuff
  constant xm_coord  	: integer := 12;             -- x coordinate of the leftmost pixel of the main window
  constant xs_coord  	: integer := xm_coord+512+8; -- x coordinate of the leftmost pixel of the side window
  constant y_coord   	: integer := 76;             -- y coordinate of the bottom pixel of the two windows
  constant border_size  : integer := 5;				  -- Outline of the rectangles
  signal vga_data_0  	: vga_data_t;
  signal vga_data_1  	: vga_data_t;
  signal vga_rgb_0   	: vga_rgb_t;
  signal border_1    	: std_logic;       		    -- '1' when border
  signal input_value 	: std_logic;
  signal output_value  	: std_logic;
  -- Borders
  signal s_border_output_0 : std_logic;
  signal s_border_input_0: std_logic;

  -- Letters
  signal s_letter_row   : std_logic_vector(3 downto 0);
  signal s_letter_column: std_logic_vector(3 downto 0);
  signal s_char00         : std_logic_vector(6 downto 0);
  signal s_char00_2       : std_logic_vector(6 downto 0);
  signal s_value_digit_row 			  : std_logic_vector(3 downto 0);
  signal s_value_digit_column 		  : std_logic_vector(3 downto 0);
  signal s_value_display				  : std_logic;
  signal m_inside_1  	: std_logic;                 -- '1' when inside main window
  signal s_inside_1  	: std_logic;                 -- '1' when inside side window
  signal outside_1   	: std_logic;                 -- '1' when outside 800x600 area
  signal y_1        	   : unsigned(8 downto 0);      -- y coordinate relative to the bottom of the main window
  
  --letters
  signal s_letters :std_logic;
  
	--
	
	type a_inSel is array (0 to 6) of std_logic_vector(6 downto 0);
	type a_outSel is array (0 to 5) of std_logic_vector(6 downto 0);
	type a_prime is array (0 to 4) of std_logic_vector(6 downto 0);
	
	signal inSel : a_inSel;
	signal outSel : a_outSel;
	signal prime: a_prime;
  
 begin
 
 -- VGA Entities


  clk : entity work.vga_clock_generator(v1)
					port map(clock_50 => clockIn,
								vga_clock => clock);
	
  vc : entity work.vga_controller(v1)
              port map(clock => clock,
							  reset => '0',
							  vga_data_0 => vga_data_0);
				  
  vo : entity work.vga_output(v1)
              port map(clock => clock,
                       vga_data => vga_data_0,
							  vga_rgb => vga_rgb_0,
                       vga_clk => vga_clk,
                       vga_hs => vga_hs,
							  vga_vs => vga_vs,
							  vga_sync_n => vga_sync_n,
							  vga_blank_n => vga_blank_n,
                       vga_r => vga_r,
							  vga_g => vga_g,
							  vga_b => vga_b);
							  
	-- Letters and Digits Entities
  letter_FONT : entity 	work.font_16x16_bold(v1)
								port map(clock =>clock,
											char_0=>s_char00, 
											row_0=>s_letter_row,    
											column_0=>s_letter_column, 
											data_1=>s_letters);
							
	digits_FONT : entity 	work.font_16x16_bold(v1)
							port map(clock =>clock,
									char_0=>s_char00_2, 
									row_0=>s_value_digit_row,    
									column_0=>s_value_digit_column, 
									data_1=>s_value_display);

	delay : process(clock) is
	begin
		if rising_edge(clock) then
			vga_data_1 <= vga_data_0;
		end if;
	end process;
	
	data:process(clock)
	begin
		if(rising_edge(clock)) then
		
			--fonte de input
			if(selInput = '1') then --ROM
				inSel(0) <= "1010010";
				inSel(1) <= "1001111";
				inSel(2) <= "1001101";
				inSel(3) <= "0100000";
				inSel(4) <= "0100000";
				inSel(5) <= "0100000";
				inSel(6) <= "0100000";
			else           --GERADOR
				inSel(0) <= "1000111";
				inSel(1) <= "1000101";
				inSel(2) <= "1010010";
				inSel(3) <=	"1000001";
				inSel(4) <=	"1000100";
				inSel(5) <= "1001111";
				inSel(6) <= "1010010";
			end if;
			
			-- FILTRO
			if(selOutput = "01") then --MAXIMO
				outSel(0) <= "1001101";
				outSel(1) <= "1000001";
				outSel(2) <= "1011000";
				outSel(3) <= "1001001";
				outSel(4) <= "1001101";
				outSel(5) <= "1001111";
			elsif(selOutput = "10") then --MINIMO
				outSel(0) <= "1001101";
				outSel(1) <= "1001001";
				outSel(2) <= "1001110";
				outSel(3) <= "1001001";
				outSel(4) <= "1001101";
				outSel(5) <= "1001111";
			elsif(selOutput = "11") then --MEDIA
				outSel(0) <= "1001101";
				outSel(1) <= "1000101";
				outSel(2) <= "1000100";
				outSel(3) <= "1001001";
				outSel(4) <= "1000001";
				outSel(5) <= "0100000";
			else
				outSel(0) <= "0100000";
				outSel(1) <= "0100000";
				outSel(2) <= "0100000";
				outSel(3) <= "0100000";
				outSel(4) <= "0100000";
				outSel(5) <= "0100000";
			end if;
			
			if(isPrime = '1') then --PRIMO
				prime(0) <= "1010000";
				prime(1) <= "1010010";
				prime(2) <= "1001001";
				prime(3) <= "1001101";
				prime(4) <= "1001111";
			else
				prime(0) <= "0100000";
				prime(1) <= "0100000";
				prime(2) <= "0100000";
				prime(3) <= "0100000";
				prime(4) <= "0100000";
			end if;
			
		end if;
	end process;
	
	
	sequential : process(clock) is
	begin
		if rising_edge(clock) then
			border_1 <= '0'; 				-- not in border by default
			input_value <= '0'; 			-- no input number rectangle by default
			output_value <= '0'; 		-- no output number rectangle by default
			s_border_input_0 <= '0';	
			s_border_output_0 <= '0';
			
			-- in border
			if vga_data_0.x < 4 or vga_data_0.x >= vga_width-4 or vga_data_0.y < 4 or vga_data_0.y >= vga_height-4 then
				border_1 <= '1'; 
			
			--	
			-- input number
			--
		
			-- I
			elsif(vga_data_0.x>=50  and vga_data_0.x<=82  and vga_data_0.y>=82 and vga_data_0.y<=114) then
				s_char00<="1001001";
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 82)/2,4));
				s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x - 50)/2,4));
			
			-- N
			elsif(vga_data_0.x>=82  and vga_data_0.x<=114  and vga_data_0.y>=82 and vga_data_0.y<=114) then
				s_char00<="1001110";
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 82)/2,4));
				s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x - 82)/2,4));
		
			-- P
			elsif(vga_data_0.x>=114  and vga_data_0.x<=146  and vga_data_0.y>=82 and vga_data_0.y<=114) then
				s_char00<="1010000";
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 82)/2,4));
				s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x - 114)/2,4));
			
			-- U
			elsif(vga_data_0.x>=146  and vga_data_0.x<=178  and vga_data_0.y>=82 and vga_data_0.y<=114) then
				s_char00<="1010101";
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 82)/2,4));
				s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x - 146)/2,4));
			
			-- T
			elsif(vga_data_0.x>=178  and vga_data_0.x<=210  and vga_data_0.y>=82 and vga_data_0.y<=114) then
				s_char00<="1010100";
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 82)/2,4));
				s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x - 178)/2,4));
			
			--
			-- output number
			--
			
			--O
			elsif(vga_data_0.x<=vga_width - 221  and vga_data_0.x>=vga_width - 253  and vga_data_0.y>= 82 and vga_data_0.y<=114) then
				s_char00<="1001111";
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 82)/2,4));
				s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x - (vga_width - 221))/2,4));
			--U
			elsif(vga_data_0.x<=vga_width - 189  and vga_data_0.x>=vga_width - 221  and vga_data_0.y>= 82 and vga_data_0.y<=114) then
				s_char00<="1010101";
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 82)/2,4));
				s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x - (vga_width - 189))/2,4));
		
			--T
			elsif(vga_data_0.x<=vga_width - 157  and vga_data_0.x>=vga_width - 189  and vga_data_0.y>= 82 and vga_data_0.y<=114) then
				s_char00<="1010100";
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 82)/2,4));
				s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x - (vga_width - 157))/2,4));
			--P
			elsif(vga_data_0.x<=vga_width - 125  and vga_data_0.x>=vga_width - 157  and vga_data_0.y>= 82 and vga_data_0.y<=114) then
				s_char00<="1010000";
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 82)/2,4));
				s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x - (vga_width - 125))/2,4));
			--U
         	elsif(vga_data_0.x<=vga_width - 93  and vga_data_0.x>=vga_width - 125  and vga_data_0.y>= 82 and vga_data_0.y<=114) then
				s_char00<="1010101";
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 82)/2,4));
            s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x - (vga_width - 93))/2,4));
			--T
			elsif(vga_data_0.x<=vga_width - 61  and vga_data_0.x>=vga_width - 93  and vga_data_0.y>= 82 and vga_data_0.y<=114) then
				s_char00<="1010100";
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 82)/2,4));
				s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x - (vga_width - 61))/2,4));
				
			--
			-- fonte de input
			--
			
			-- G/R
			elsif(vga_data_0.x>=77  and vga_data_0.x<=109  and vga_data_0.y<=vga_height-68 and vga_data_0.y>=vga_height-100) then
				s_char00<=inSel(0);
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 82)/2,4));
				s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x - 77)/2,4));
		
			-- E/O
			elsif(vga_data_0.x>=109  and vga_data_0.x<=141  and vga_data_0.y<=vga_height-68 and vga_data_0.y>=vga_height-100) then
				s_char00<=inSel(1);
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 82)/2,4));
				s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x - 109)/2,4));
			
			-- R/M
			elsif(vga_data_0.x>=141  and vga_data_0.x<=173  and vga_data_0.y<=vga_height-68 and vga_data_0.y>=vga_height-100) then
				s_char00<=inSel(2);
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 82)/2,4));
				s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x - 141)/2,4));
			
			-- A
			elsif(vga_data_0.x>=173  and vga_data_0.x<=205  and vga_data_0.y<=vga_height-68 and vga_data_0.y>=vga_height-100) then
				s_char00<=inSel(3);
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 82)/2,4));
				s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x - 173)/2,4));
			
			-- D
			elsif(vga_data_0.x>=205  and vga_data_0.x<=237  and vga_data_0.y<=vga_height-68 and vga_data_0.y>=vga_height-100) then
				s_char00<=inSel(4);
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 82)/2,4));
				s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x - 205)/2,4));

			-- O	
			elsif(vga_data_0.x>=237  and vga_data_0.x<=269  and vga_data_0.y<=vga_height-68 and vga_data_0.y>=vga_height-100) then
				s_char00<=inSel(5);
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 82)/2,4));
				s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x - 237)/2,4));
			
			--R	
			elsif(vga_data_0.x>=269  and vga_data_0.x<=301  and vga_data_0.y<=vga_height-68 and vga_data_0.y>=vga_height-100) then
				s_char00<=inSel(6);
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 82)/2,4));
				s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x - 269)/2,4));
				
			--
			--Filtro
			--
			
			-- M
			elsif(vga_data_0.x<=vga_width-237 and vga_data_0.x>=vga_width-269  and vga_data_0.y<=vga_height-68 and vga_data_0.y>=vga_height-100) then
				s_char00<=outSel(0);
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 82)/2,4));
				s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x-(vga_width-269))/2,4));
				
			-- A/I/E
			elsif(vga_data_0.x<=vga_width-205 and vga_data_0.x>=vga_width-237  and vga_data_0.y<=vga_height-68 and vga_data_0.y>=vga_height-100) then
				s_char00<=outSel(1);
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 82)/2,4));
				s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x - (vga_width-237))/2,4));

			-- X/N/D
			elsif(vga_data_0.x<=vga_width-173 and vga_data_0.x>=vga_width-205  and vga_data_0.y<=vga_height-68 and vga_data_0.y>=vga_height-100) then
				s_char00<=outSel(2);
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 82)/2,4));
				s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x - (vga_width-205))/2,4));
			
			-- I
			elsif(vga_data_0.x<=vga_width-141 and vga_data_0.x>=vga_width-173  and vga_data_0.y<=vga_height-68 and vga_data_0.y>=vga_height-100) then
				s_char00<=outSel(3);
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 82)/2,4));
				s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x - (vga_width-173))/2,4));
			
			-- M/M/A
			elsif(vga_data_0.x<=vga_width-109 and vga_data_0.x>=vga_width-141  and vga_data_0.y<=vga_height-68 and vga_data_0.y>=vga_height-100) then
				s_char00<=outSel(4);
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 82)/2,4));
				s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x - (vga_width-141))/2,4));
			--	O
			elsif(vga_data_0.x<=vga_width-77 and vga_data_0.x>=vga_width-109  and vga_data_0.y<=vga_height-68 and vga_data_0.y>=vga_height-100) then
				s_char00<=outSel(5);
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 82)/2,4));
				s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x - (vga_width-109))/2,4));
			
			--
			-- Primality 
			--

			-- P
			elsif(vga_data_0.x>=336 and vga_data_0.x<=368 and vga_data_0.y>=209 and vga_data_0.y<=241) then
				s_char00<=prime(0);
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 209)/2,4));
				s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x - 336)/2,4));

			-- R
			elsif(vga_data_0.x>=368 and vga_data_0.x<=400  and vga_data_0.y>=209 and vga_data_0.y<=241) then
				s_char00<=prime(1);
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 209)/2,4));
				s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x - 368)/2,4));
			
			-- I
			elsif(vga_data_0.x>=400 and vga_data_0.x<=432  and vga_data_0.y>=209 and vga_data_0.y<=241) then
				s_char00<=prime(2);
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 209)/2,4));
				s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x - 400)/2,4));
			
			-- M
			elsif(vga_data_0.x>=432 and vga_data_0.x<=464  and vga_data_0.y>=209 and vga_data_0.y<=241) then
				s_char00<=prime(3);
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 209)/2,4));
				s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x - 432)/2,4));
			
			-- O
			elsif(vga_data_0.x>=464 and vga_data_0.x<=496  and vga_data_0.y>=209 and vga_data_0.y<=241) then
				s_char00<=prime(4);
				s_letter_row <= std_logic_vector(to_unsigned((vga_data_0.y - 209)/2,4));
				s_letter_column <= std_logic_vector(to_unsigned((vga_data_0.x - 464)/2,4));		

			--INPUT NUMBER DIGITS
			
			-- DIGIT 0(RIGHT MOST)
			elsif(vga_data_0.x>=149 and vga_data_0.x<=197  and vga_data_0.y>=201 and vga_data_0.y<=249) then
				s_char00_2<="011"& in0;
				s_value_digit_row <= std_logic_vector(to_unsigned((vga_data_0.y - 201)/3,4));
				s_value_digit_column <= std_logic_vector(to_unsigned((vga_data_0.x - 149)/3,4));
				
			-- DIGIT 1
			elsif(vga_data_0.x>=101 and vga_data_0.x<=149  and vga_data_0.y>=201 and vga_data_0.y<=249) then
				s_char00_2<="011"& in1; 
				s_value_digit_row <= std_logic_vector(to_unsigned((vga_data_0.y - 201)/3,4));
				s_value_digit_column <= std_logic_vector(to_unsigned((vga_data_0.x - 101)/3,4));
				
			-- DIGIT 2(LEFT MOST)
			elsif(vga_data_0.x>=53 and vga_data_0.x<=101  and vga_data_0.y>=201 and vga_data_0.y<=249) then
				s_char00_2<="011"& in2;
				s_value_digit_row <= std_logic_vector(to_unsigned((vga_data_0.y - 201)/3,4));
				s_value_digit_column <= std_logic_vector(to_unsigned((vga_data_0.x - 53)/3,4));
			
			
			--OUTPUT NUMBER DIGITS
			
			-- DIGIT 2(LEFT MOST)
			elsif(vga_data_0.x<=vga_width-149 and vga_data_0.x>=vga_width-197  and vga_data_0.y>=201 and vga_data_0.y<=249) then
				s_char00_2<="011"& out2; 
				s_value_digit_row <= std_logic_vector(to_unsigned((vga_data_0.y - 201)/3,4));
				s_value_digit_column <= std_logic_vector(to_unsigned((vga_data_0.x - (vga_width-149))/3,4));
				
			-- DIGIT 1
			elsif(vga_data_0.x<=vga_width-101 and vga_data_0.x>=vga_width-149  and vga_data_0.y>=201 and vga_data_0.y<=249) then
				s_char00_2<="011"& out1; 
				s_value_digit_row <= std_logic_vector(to_unsigned((vga_data_0.y - 201)/3,4));
				s_value_digit_column <= std_logic_vector(to_unsigned((vga_data_0.x -(vga_width- 101))/3,4));
				
			-- DIGIT 0(RIGHT MOST)
			elsif(vga_data_0.x<=vga_width-53 and vga_data_0.x>=vga_width-101  and vga_data_0.y>=201 and vga_data_0.y<=249) then
				s_char00_2<="011"& out0; 
				s_value_digit_row <= std_logic_vector(to_unsigned((vga_data_0.y - 201)/3,4));
				s_value_digit_column <= std_logic_vector(to_unsigned((vga_data_0.x -(vga_width- 53))/3,4));
				
			end if;	
			
			--###################BACKGROUND RECTANGLES#####################--
			
			-- INPUT NUMBER
			if(vga_data_0.x>=50  and vga_data_0.x<=200  and vga_data_0.y>=150 and vga_data_0.y<=300) then
				if(s_value_display = '0') then
					input_value<='1';
				end if;			
			
			-- OUTPUT NUMBER
			elsif(vga_data_0.x<=vga_width-50  and vga_data_0.x>=vga_width-200  
			and vga_data_0.y>=150 and vga_data_0.y<=300) then
				if(s_value_display = '0') then
					output_value<='1';
				end if;

				
			--################BORDERS##################--	
			
			-- OUTPUT NUMBER BORDER
			elsif(vga_data_0.x<=vga_width-50+border_size  and vga_data_0.x>=vga_width-200-border_size  
			and vga_data_0.y>=150-border_size and vga_data_0.y<=300+border_size) then
				if(s_value_display = '0' and output_value = '0') then
					s_border_output_0 <= '1';
				end if;
				
			--
			-- INPUT NUMBER BORDER
			elsif(vga_data_0.x>=50-border_size  and vga_data_0.x<=200+border_size
			and vga_data_0.y>=150-border_size and vga_data_0.y<=300+border_size) then
				if(s_value_display = '0' and input_value = '0') then
					s_border_input_0 <= '1';
				end if;	
			end if;
			
			--#################Coloração######################--
			
			vga_rgb_0.r <= x"00"; vga_rgb_0.g <= x"CC"; vga_rgb_0.b <= x"00"; -- blue by default
			if border_1 = '1' then
				vga_rgb_0.r <= x"FF"; vga_rgb_0.g <= x"FF"; vga_rgb_0.b <= x"FF"; -- the border is white
				
			elsif input_value = '1' then -- colors of the input number retangle
				vga_rgb_0.r <= x"00";
				vga_rgb_0.g <= x"00";
				vga_rgb_0.b <= x"00";
				
			elsif output_value ='1' then   -- colors of the output number retangle
				vga_rgb_0.r <= x"00";
				vga_rgb_0.g <= x"00";
				vga_rgb_0.b <= x"00";
				
			elsif s_value_display ='1' then -- color of the digits in bothe the input and output numbers
				vga_rgb_0.r <= x"FF";
				vga_rgb_0.g <= x"FF";
				vga_rgb_0.b <= x"33";
				
			elsif s_letters = '1' then --color of the letters
				vga_rgb_0.r <= x"FF";
				vga_rgb_0.g <= x"FF";
				vga_rgb_0.b <= x"FF";
				
			-- BORDERS
			
			elsif s_border_input_0 = '1' then -- input rectangle border
				vga_rgb_0.r <= x"FF";
				vga_rgb_0.g <= x"FF";
				vga_rgb_0.b <= x"FF";

			
			elsif s_border_output_0 = '1' then -- output rectangle border
				vga_rgb_0.r <= x"FF";
				vga_rgb_0.g <= x"FF";
				vga_rgb_0.b <= x"FF";
			end if;		
		end if;
	end process;
 
 end arch;