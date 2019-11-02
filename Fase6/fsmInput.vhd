library ieee;
use ieee.std_logic_1164.all;

entity fsmInput is
	port(	clock	:	in  std_logic;
			reset	:	in  std_logic:='0';
			in0	:	in  std_logic:='0';
			out0	:	out std_logic);
end fsmInput;

ARCHITECTURE BEHAVIOR OF fsmInput IS
    TYPE type_fstate IS (state1,state2);
    SIGNAL fstate : type_fstate;
    SIGNAL reg_fstate : type_fstate;
BEGIN
    PROCESS (clock,reg_fstate)
    BEGIN
        IF (clock='1' AND clock'event) THEN
            fstate <= reg_fstate;
        END IF;
    END PROCESS;

    PROCESS (fstate,reset,in0)
    BEGIN
        IF (reset='1') THEN
            reg_fstate <= state1;
            out0 <= '0';
        ELSE
            out0 <= '0';
            CASE fstate IS
                WHEN state1 =>
                    IF ((in0 = '1')) THEN
                        reg_fstate <= state2;
                    ELSIF ((in0 = '0')) THEN
                        reg_fstate <= state1;
                    -- Inserting 'else' block to prevent latch inference
                    ELSE
                        reg_fstate <= state1;
                    END IF;

                    out0 <= '0';
                WHEN state2 =>
                    IF ((in0 = '1')) THEN
                        reg_fstate <= state1;
                    ELSIF ((in0 = '0')) THEN
                        reg_fstate <= state2;
                    -- Inserting 'else' block to prevent latch inference
                    ELSE
                        reg_fstate <= state2;
                    END IF;

                    out0 <= '1';
                WHEN OTHERS => 
                    out0 <= 'X';
                    report "Reach undefined state";
            END CASE;
        END IF;
    END PROCESS;
END BEHAVIOR;