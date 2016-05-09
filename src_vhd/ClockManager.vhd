library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library WORK;
use WORK.CONSTANTS.ALL;

entity ClockManager is
    Port ( clock : in std_logic;
           reset : in std_logic;
           ce_param : out std_logic);
end ClockManager;

architecture Behavioral of ClockManager is

signal cpt : integer := 0;

begin
    process (clock, reset)
    begin
        if (reset = '1') then
            cpt<=0;
                
        elsif (rising_edge(clock)) then 
            if (cpt< PARAM_DELAY) then 
                cpt<= cpt + 1;
                ce_param<='0';
                
            else
                cpt<=0;
                ce_param<='1';
            end if;
        end if;
    end process;
end Behavioral;