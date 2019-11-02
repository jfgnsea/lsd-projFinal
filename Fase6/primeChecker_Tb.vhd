library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity primeChecker_Tb is
end primeChecker_Tb;

architecture arch of primeChecker_Tb is

    signal s_clock, s_enable, s_reset:std_logic;
    signal s_in: unsigned(7 downto 0) := "00000000";
    signal s_prime: std_logic;

begin

    uut:    entity  work.primeChecker(arch)
                    generic map(NumCyclesWait => 0)
                    port map(clock => s_clock,
                            enable => s_enable,
                            reset => s_reset,
                            input => std_logic_vector(s_in),
                            isPrime => s_prime);

    clk_proc:process
    begin
        s_clock <= '0';
        wait for 10 ns;
        s_clock <= '1';
        wait for 10 ns;
    end process;

    input_proc:process
    begin
        s_in <= s_in +1;
        s_enable <= '0';
        wait for 64700 ns;
        s_enable <= '1';
        wait for 20 ns;
    end process;

    reset_proc: process
    begin
        wait for 166000000 ns;
        std.env.stop(1);
    end process;
        


end arch ; -- arch