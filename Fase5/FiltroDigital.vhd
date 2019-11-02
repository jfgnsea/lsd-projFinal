library ieee;
use ieee.std_logic_1164.all;

entity FiltroDigital is
	port(	CLOCK_50	:	in  std_logic;
	
			KEY		:	in  std_logic_vector(3 downto 0);
			SW			:	in  std_logic_vector(0 downto 0);
			
			LEDG		:	out std_logic_vector(8 downto 0);
			LEDR		:	out std_logic_vector(9 downto 0);
			
			HEX0		:	out std_logic_vector(6 downto 0);
			HEX1		:	out std_logic_vector(6 downto 0);
			HEX2		:	out std_logic_vector(6 downto 0);
			HEX4		:	out std_logic_vector(6 downto 0);
			
			lcd_on   :  out std_logic;
			lcd_blon :  out std_logic;
			lcd_rw   :  out std_logic;
			lcd_en   :  out std_logic;
			lcd_rs   :  out std_logic;
			lcd_data	:	inout std_logic_vector(7 downto 0));
end FiltroDigital;

architecture Shell of FiltroDigital is

	--sinais limpos de bounce provenientes das KEYs
	signal s_b0, s_b1, s_b2: std_logic;
	--sinal de reset geral
	signal s_reset: std_logic;
	-- sinal do pulso de enable a 2hz
	signal s_2Hz: std_logic; 
	-- sinal de enable do enable Generator
	signal s_en:	std_logic;
	-- sinal que transmite o valor dou counter para servir de endereço a memoria rom
	signal s_adr: std_logic_vector(5 downto 0);
	-- sinal que tranmite o valor armazenado na memorio rom
	signal s_mem: std_logic_vector(7 downto 0);	
	-- sinal que transmite o valor random a introduzir no shift register
	signal s_rnd : std_logic_vector(7 downto 0);
	-- sinal que tranmite a cinfiguração da seleção da fonte de dados de entrada
	signal s_selInput: std_logic;
	-- sinal que transmite os dados de entrada
	signal s_input: std_logic_vector(7 downto 0);
	--sinais que ligam o shift registor aos restantes componentes
	signal data0, data1, data2, data3, data4 : std_logic_vector(7 downto 0) := "00000000";
	--sinal que transmite o valor maximo
	signal s_max : std_logic_vector(7 downto 0);
	--sinal que transmite o valor minimo
	signal s_min : std_logic_vector(7 downto 0);
	-- sinal que transmite o valor da media das ultimas 5 entradas
	signal s_avg: std_logic_vector(7 downto 0);
	--sinal que transmite a configuração da seleção da saida dos filtros
	signal s_selOutput: std_logic_vector(1 downto 0);
	--sinal que transmite o valor da saida
	signal s_out, s_outUnchecked: std_logic_vector(7 downto 0);
	--sinal que transmite se a saida é numero primo ou nao
	signal s_prime: std_logic;
	
	--sinais correspontes as unidades, dezenas e centenas do valor de saida
	signal s_ui, s_di, s_ci: std_logic_vector(3 downto 0);
	--sinais correspontes as unidades, dezenas e centenas do valor de saida convertidos para usar no lcd
	signal lcd_ui,lcd_di,lcd_ci: std_logic_vector(7 downto 0);

	
	--sinais correspontes as unidades, dezenas e centenas do valor de saida
	signal s_u, s_d, s_c: std_logic_vector(3 downto 0);
	--sinais correspontes as unidades, dezenas e centenas do valor de saida convertidos para usar no lcd
	signal lcd_u,lcd_d,lcd_c: std_logic_vector(7 downto 0);

begin

	-- Debouncing block.
	debouncer0	:	entity work.Debouncer(Behavioral)
							generic map(kHzClkFreq		=> 50000,
											mSecMinInWidth	=> 100,
											inPolarity		=> '0',
											outPolarity		=> '1')
							port map(refClk	=> CLOCK_50,
										dirtyIn	=> KEY(0),
										pulsedOut=> s_b0);
										
	debouncer1	:	entity work.Debouncer(Behavioral)
							generic map(kHzClkFreq		=> 50000,
											mSecMinInWidth	=> 100,
											inPolarity		=> '0',
											outPolarity		=> '1')
							port map(refClk	=> CLOCK_50,
										dirtyIn	=> KEY(1),
										pulsedOut=> s_b1);
										
	debouncer2	:	entity work.Debouncer(Behavioral)
							generic map(kHzClkFreq		=> 50000,
											mSecMinInWidth	=> 100,
											inPolarity		=> '0',
											outPolarity		=> '1')
							port map(refClk	=> CLOCK_50,
										dirtyIn	=> KEY(2),
										pulsedOut=> s_b2);
	
	--
	-- Modulo de reset
	--
	
	rst:	entity	work.resetModule(arch)
						generic map(N => 10)
						port map(clock	=> CLOCK_50,
									resetIn=> s_b0,
									resetOut => s_reset);

	-- gerador de pulso de 2hz
	enBlock	:	entity 	work.enGenN(Behav)
								generic map( n => 25000000)
								port map(clkIn	 => CLOCK_50,
											enable => s_en,
											enOut  => s_2Hz);
								
	-- Unidade central de controlo
	fsm:	entity	work.FSM(Behavior)
						port map(clock	=> CLOCK_50,
									start	=> s_b1,
									reset	=>	s_reset,
									genEn	=> s_en,
									selMux=> s_selOutput);
									
	-- maquina de estados que corresponde a seleção do metodo de enytrada de dados
	fsmIn:	entity	work.fsmInput(behavior)
							port map(clock	=> CLOCK_50,
										reset	=> s_reset,
										in0	=> s_b2,
										out0	=> s_selInput);
									
	--gerador pseudo random. para a seed foi usado um valor aleatorio gerado atraves de uma ferramenta online
	randomGen:	entity	work.pseudo_random_generator(light)
								generic map(N_BITS => 8,
												SEED =>  x"0EFFA8216165")
								port map(clock	=> CLOCK_50,
											enable=> s_2Hz,
											rnd	=> s_rnd);
										
	-- counter cujo resultado serve de endereço de leitura sequencial da rom
	counter:	entity	work.CounterUp(Behavior)
							port map(clock	=> CLOCK_50,
										enable=> s_2Hz,
										chgInRst=> s_b2,
										chgFilRst=> s_b1,
										reset	=> s_reset,
										count	=> s_adr);
									
	-- memoria rom com 64 numeros de 8 bits
	mem:	entity	work.ROM_64_8(behavior)
						port map(address => s_adr,
									choiceBit=> SW(0 downto 0),
									dataOut => s_mem);
									
	-- mux que seleciona entra a rom e o pseudo random generator
	mux2:	entity	work.Mux2(Behavior)
						port map(sel	=> s_selInput,
									in0	=> s_rnd,
									in1	=> s_mem,
									out0	=> s_input);
									
	-- Shift register 5x8bit
	shigtReg:	entity	work.ShiftRegister(Behavior)
								port map(clock	=>	CLOCK_50,
											enable=>	s_2Hz,
											reset	=>	s_reset,
											input	=>	s_input,
											out0	=> data0,
											out1	=> data1,
											out2	=> data2,
											out3	=> data3,
											out4	=> data4);
	
	-- bloco combinatorio. rsponsavel pelo calculo dos extremos e media
	--calculo da media
	avgCal:	entity	work.Average(Behavior)
							generic map( waitCycles => 2)
							port map(clock	=> CLOCK_50,
										reset	=> s_reset,
										enable=> s_2Hz,
										in0	=> data0,
										in1	=> data1,
										in2	=> data2,
										in3	=> data3,
										in4	=> data4,
										avg 	=> s_avg);
										
	-- calculo dos extremos
	extCalc:	entity	work.ExtremeCalc(Behavior)
							generic map( waitCycles => 2)
							port map(clock	=>	CLOCK_50,
										reset	=>	s_reset,
										enable=> s_2Hz,
										in0	=> data0,
										in1	=> data1,
										in2	=> data2,
										in3	=> data3,
										in4	=> data4,
										max	=> s_max,
										min	=> s_min);
	
	--Mux. determinação da saida dependendo do filtro escolhido
	mux3:		entity	work.Mux3(Behavior)
							port map(sel	=> s_selOutput,
										in0	=> s_max,
										in1	=> s_min,
										in2	=> s_avg,
										output=> s_outUnchecked);
										
	-- verificador de primos para testa a saida
	
	prmChecker:	entity	work.primeChecker(arch1)
								generic map(NumCyclesWait => 1000)
								port map(clock	=> CLOCK_50,
											enable=> s_2Hz,
											reset => s_reset,
											input => s_outUnchecked,
											isPrime=> s_prime);
	
	--
	-- buffer do valor filtrado de saida
	--
	
	bfr:	entity	work.Reg8(Behavior)
						port map(clock	=>	CLOCK_50,
									enable=> s_2Hz,
									reset	=> s_reset,
									input	=>	s_outUnchecked,
									output=> s_out);
	
	-- conversao do valor de saida para bcd
	bcdConv0:	entity	work.Bin2BCD8(Behav)
							port map(i	=> s_out,
										u	=> s_u,
										d	=> s_d,
										c	=> s_c);
	-- conversao do valor de entrada para bcd
	bcdConv1:	entity	work.Bin2BCD8(Behav)
						port map(i	=> s_input,
									u	=> s_ui,
									d	=> s_di,
									c	=> s_ci);
										
		
	--
	-- visualização nos displays hex
	--
		
	-- conversores de bcd para vetor de 7bits para mostrar o valor do filtro nos displays HEX
	-- valor das unidades
	display0    :   entity  work.Bin7SegDecoder(Behavioral)
                            port map(binInput => s_u,
                                     enable   => '1',
                                     decOut_n => HEX0);
												 
	-- valor das dezenas
	display1    :   entity  work.Bin7SegDecoder(Behavioral)
                            port map(binInput => s_d,
                                     enable   => '1',
                                     decOut_n => HEX1);
												 
	--valor das centenas
	display2    :   entity  work.Bin7SegDecoder(Behavioral)
                            port map(binInput => s_c,
                                     enable   => '1',
                                     decOut_n => HEX2);
												 
									
	-- modo de filtagem selecionado
	display4:	entity	work.Bin7SegDecoder2(Behavioral)
								port map(binInput => s_selOutput,
                                 enable   => '1',
                                 decOut_n => HEX4);
	
	--
	-- visualização dos valores e dos estados no lcd
	--
	
	-- conversaão dos componentes do valor de entrada
	bcdhex0i:	entity	work.BCD2HEX(Behavioral)
							port map(binInput	=> s_ui,
										enable	=> '1',
										decOut	=> lcd_ui);
										
	bcdhex1i:	entity	work.BCD2HEX(Behavioral)
							port map(binInput	=> s_di,
										enable	=> '1',
										decOut	=> lcd_di);
										
	bcdhex2i:	entity	work.BCD2HEX(Behavioral)
							port map(binInput	=> s_ci,
										enable	=> '1',
										decOut	=> lcd_ci);
	
	--conversão dos componentes do valor de saida para ascii de forma a serem visualizados no lcd
	bcdhex0:	entity	work.BCD2HEX(Behavioral)
							port map(binInput	=> s_u,
										enable	=> '1',
										decOut	=> lcd_u);
										
	bcdhex1:	entity	work.BCD2HEX(Behavioral)
							port map(binInput	=> s_d,
										enable	=> '1',
										decOut	=> lcd_d);
										
	bcdhex2:	entity	work.BCD2HEX(Behavioral)
							port map(binInput	=> s_c,
										enable	=> '1',
										decOut	=> lcd_c);
										
	--modulo que comunica com o lcd							
	lcd:	entity	work.lcd_unit(Behavior)
						port map(clock => clock_50,
									mainState => s_selOutput,
									inputState => s_selInput,
									uIn	=> lcd_u,
									dIn	=> lcd_d,
									cIn	=> lcd_c,
									uIni	=> lcd_ui,
									dIni	=> lcd_di,
									cIni	=> lcd_ci,
									isPrime=>s_prime,
									lcd_on=>lcd_on,
									lcd_blon=>lcd_blon,
									lcd_rw=>lcd_rw,
									lcd_en=>lcd_en,
									lcd_rs=>lcd_rs,
									lcd_data=>lcd_data);
	
	--									
	-- atribuição da entrada e saida aos leds
	--
	
	LEDR(7 downto 0)	<=	s_input; 
	LEDG(7 downto 0)	<= s_out;
	LEDG(8) <= s_prime;
	LEDR(8) <= '0';
	LEDR(9) <= s_selInput;
	
								
end Shell;		