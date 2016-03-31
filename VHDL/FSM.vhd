----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.03.2016 11:43:23
-- Design Name: 
-- Module Name: FSM - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.CONSTANTS.all;
use work.CONFIG_MANDELBROT.all;
use IEEE.NUMERIC_STD.ALL;

entity FSM is
    Port ( clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           done : in STD_LOGIC;
			  stop : in std_logic;
           start : out STD_LOGIC);
end FSM;

architecture Behavioral of FSM is
type type_etat is (init, inc,finish, calcul);
Signal etat_present, etat_futur : type_etat;

begin

process(clock,reset)
begin
    if reset='1' then
        etat_present<=init;
    elsif rising_edge(clock) then
        etat_present<=etat_futur;
    end if;
end process;

--
--process(clock, reset, done)
--begin
--if reset='1' then 
--	xcount<=0;
--	ycount<=0;
--elsif rising_edge(clock) then
--	if(done='1') then
--		if ycount = YRES-1 then
--			xcount <= 0;
--			ycount <= 0;
--		elsif xcount = XRES-1 then
--			xcount <= 0;
--			ycount <= ycount+1;
--		else
--			xcount<=xcount+1;
--		end if;
--	end if;
--end if;
--end process;


process(etat_present, done, stop)
begin
    case etat_present is 
        when init=> etat_futur<=inc;
        when calcul=> if done = '0'  then
								 --if stop='1' then
								--	etat_futur<=finish;
								-- else
									etat_futur<=calcul;
								-- end if;
                      else
                        etat_futur<=inc;
                       end if;
        when inc=> etat_futur<=calcul;
		  when finish=>etat_futur<=finish;
    end case;
end process;


process(etat_present)
begin
    case etat_present is
        when init=> start<='0';
        when calcul=> start<='0';
        when inc=> start<='1';
		 when finish=>start<='0';

    end case;
end process;

                        
end Behavioral;