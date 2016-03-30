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
           start : out STD_LOGIC;
           xinc : out STD_LOGIC;
           yinc : out STD_LOGIC);
end FSM;

architecture Behavioral of FSM is
type type_etat is (init, xincrement,yincrement,calcul,finish);
Signal etat_present, etat_futur : type_etat;
signal xcount : integer range 0 to XRES-1:=0;
signal ycount : integer range 0 to YRES-1:=0;
begin

process(clock,reset)
begin
    if reset='1' then
        etat_present<=init;
    elsif rising_edge(clock) then
        etat_present<=etat_futur;
    end if;
end process;

process(etat_present, done, ycount, xcount)
begin
    case etat_present is 
        when init=> etat_futur<=xincrement;
        when calcul=> if done ='0' then
                        etat_futur<=calcul;
                      else
                        if ycount = YRES-1 then
                            etat_futur<=finish;
                        elsif xcount = XRES-1 then
                            etat_futur<=yincrement;
                        else
                            etat_futur<=xincrement;
                        end if;
                       end if;
        when xincrement=> etat_futur<=calcul;
        when yincrement => etat_futur<=calcul;
        when finish => etat_futur<=finish;  --TODO changer par init + changement du nbr d'itÃƒÂ©ration
    end case;
end process;

process(clock, reset,ycount,xcount,done)
begin
if reset='1' then 
	xcount<=0;
	ycount<=0;
elsif rising_edge(clock) then
	if(done='1') then
		if ycount = YRES-1 then
			xcount <= 0;
			ycount <= 0;
		elsif xcount = XRES-1 then
			xcount <= 0;
			ycount <= ycount+1;
		else
			xcount<=xcount+1;
		end if;
	end if;
end if;
end process;

process(etat_present,xs,ys,xcount,ycount)
begin
    case etat_present is
        when init=> start<='0';
						  xinc<='0';
						  yinc<='0';
        when calcul=> start<='0';
						  xinc<='0';
						  yinc<='0';
        when xincrement=> start<='0';
						  xinc<='1';
						  yinc<='0';
        when yincrement=> start<='0';
						  xinc<='0';
						  yinc<='1';
        when finish=> start<='0';
						    xinc<='0';
						    yinc<='0';

    end case;
end process;

                        
end Behavioral;
