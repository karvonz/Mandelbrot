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
use work.constants.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FSM is
    Port ( clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           done : in STD_LOGIC;
           start : out STD_LOGIC;
           x : out STD_LOGIC_VECTOR (XDATA-1 downto 0);
           y : out STD_LOGIC_VECTOR (YDATA-1 downto 0));
end FSM;

architecture Behavioral of FSM is
type type_etat is (init, xincrement,yincrement,calcul,finish);
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

process(etat_present, done)
begin
    case etat_present is 
        when init=> etat_futur<=calcul;
        when calcul=> etat_present<=xincrement;
        when xincrement=> if (done ='1' and endline='1') then  --TODO changer par endline=pixel...
                            etat_futur<=yincrement;
                          elsif done='1' then
                            etat_futur<=calcul;
                          else
                            etat_futur<=xincrement;
                          end if;
        when yincrement => if(done='1' and ys=YMAX) then
                                etat_futur<=finish;
                            elsif done='1' then
                                etat_futur<=calcul;
                            else 
                                etat_futur<=yincrement;
                            end if;
        when finish => etat_futur<=init;
    end case;
end process;

process(etat_present)
begin
    case etat_present is
        when init=> start<='0';
                    x<=(others=>'0');
                    y<=(others=>'0');
        when calcul=> start<='1';
                    x<=std_logic_vector(xs);
                    y<=std_logic_vector(ys);
        when xincrement=> start<='0';
                          x<=std_logic_vector(xs);
                          y<=std_logic_vector(ys);
        when yincrement=> start<='0';
                          x<=std_logic_vector(xs);
                          y<=std_logic_vector(ys);
        when finish=> start<='0';
                          x<=std_logic_vector(xs);
                          y<=std_logic_vector(ys);
    end case;
end process;

                        
end Behavioral;
