------------------------------------------------------------------------------- 
--                                                                           -- 
--  Simple Cordic                                                            -- 
--  Copyright (C) 1999 HT-LAB                                                -- 
--                                                                           -- 
--  Contact/Feedback : http://www.ht-lab.com/feedback.htm                    -- 
--  Web: http://www.ht-lab.com                                               -- 
--                                                                           -- 
------------------------------------------------------------------------------- 
--                                                                           -- 
--  This library is free software; you can redistribute it and/or            -- 
--  modify it under the terms of the GNU Lesser General Public               -- 
--  License as published by the Free Software Foundation; either             -- 
--  version 2.1 of the License, or (at your option) any later version.       -- 
--                                                                           -- 
--  This library is distributed in the hope that it will be useful,          -- 
--  but WITHOUT ANY WARRANTY; without even the implied warranty of           -- 
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU        -- 
--  Lesser General Public License for more details.                          -- 
--                                                                           -- 
--  Full details of the license can be found in the file "copying.txt".      -- 
--                                                                           -- 
--  You should have received a copy of the GNU Lesser General Public         -- 
--  License along with this library; if not, write to the Free Software      -- 
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA  -- 
--                                                                           -- 
------------------------------------------------------------------------------- 
-- Cordic Top                                                                -- 
--                                                                           -- 
-- Simple SIN/COS Cordic example                                             -- 
-- 32 bits fixed format Sign,2^0, 2^-1,2^-2 etc.                             -- 
-- angle input +/-0.5phi                                                     -- 
--                                                                           -- 
------------------------------------------------------------------------------- 
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all; 
 
entity COSINUS_SINUS_32b is     
   port(clk    : in  std_logic;                     
        reset  : in  std_logic;                     -- Active low reset 
        angle  : in  std_logic_vector(31 downto 0); -- input radian  
        sin    : out std_logic_vector(31 downto 0);  -- THIS OUTPUT ¨PROVIDES THE SINUS RESULT
        cos    : out std_logic_vector(31 downto 0);        
        start  : in  std_logic;  
        done   : out std_logic);               
end COSINUS_SINUS_32b; 
 
 
architecture synthesis of COSINUS_SINUS_32b is 
   constant xinit_c  : std_logic_vector(31 downto 0):=X"26dd3b44"; 
    constant yinit_c : std_logic_vector(31 downto 0):=X"00000000"; 
 
    component addsub is 
      port(abus   : in  std_logic_vector(31 downto 0); 
           bbus   : in  std_logic_vector(31 downto 0); 
           obus   : out std_logic_vector(31 downto 0);          
           as     : in  std_logic);          --add=1, subtract=0           
    end component; 
     
    component shiftn is 
      port(ibus   : in  std_logic_vector(31 downto 0);           
           obus   : out std_logic_vector(31 downto 0);          
           n      : in  std_logic_vector(4 downto 0));   --shift by n              
    end component; 
     
    component atan32 is --ARCTAN(x) lut 
      port (ZA    : in Std_Logic_Vector(4 downto 0); 
            ZData : out Std_Logic_Vector(31 downto 0)); 
    end component;  
     
    component fsm is 
      port(clk    : in  std_logic;                     
           reset  : in  std_logic;                          -- Active low reset            
           start  : in  std_logic; 
				cnt   : in std_logic_vector(4 downto 0);  
           init   : out std_logic;     
           load   : out std_logic;     
           done   : out std_logic);       
    end component; 
          
    signal cnt_s  : std_logic_vector(4 downto 0); -- bit counter, 2^5 
 
    signal newx_s : std_logic_vector(31 downto 0); 
    signal newy_s : std_logic_vector(31 downto 0); 
    signal newz_s : std_logic_vector(31 downto 0); 
 
    signal xreg_s : std_logic_vector(31 downto 0); 
    signal yreg_s : std_logic_vector(31 downto 0); 
    signal zreg_s : std_logic_vector(31 downto 0); 
 
    signal sxreg_s: std_logic_vector(31 downto 0); 
    signal syreg_s: std_logic_vector(31 downto 0); 
 
    signal atan_s : std_logic_vector(31 downto 0); -- arctan LUT 
 
    signal init_s : std_logic; 
    signal load_s : std_logic; 
    signal as_s   : std_logic; 
    signal nas_s  : std_logic; 
  
begin 
  
    SHIFT1: shiftn  port map (xreg_s,sxreg_s,cnt_s); 
    SHIFT2: shiftn  port map (yreg_s,syreg_s,cnt_s); 
 
    nas_s <= not as_s; 
    ADD1  : addsub  port map (xreg_s,syreg_s,newx_s,as_s);   -- xreg 
    ADD2  : addsub  port map (yreg_s,sxreg_s,newy_s,nas_s);  -- yreg 
 
    LUT   : atan32 port map(cnt_s,atan_s); 
 
    ADD3  : addsub port map (zreg_s,atan_s(31 downto 0),newz_s,as_s);    -- zreg 
 
    FSM1  : fsm port map (clk,reset,start,cnt_s,init_s,load_s,done);  
  
    -- COS(X) Register 
    process (clk,newx_s)  
    begin 
        if (rising_edge(clk)) then 
           if init_s='1' then xreg_s(31 downto 0) <= xinit_c; -- fails in vh2sc xinit_c(31 downto 0); -- 0.607      
           elsif load_s='1' then xreg_s <= newx_s;                    
           end if; 
        end if;    
    end process;    
 
    -- SIN(Y) Register 
    process (clk,newy_s)  
    begin 
        if (rising_edge(clk)) then 
           if init_s='1' then yreg_s <= yinit_c; -- 0.0000    fails  in vh2sc yinit_c(31 downto 0) 
           elsif load_s='1' then yreg_s <= newy_s;                    
           end if; 
        end if;    
    end process;    
 
    -- Z Register 
    process (clk,newz_s,angle)  
    begin 
        if (rising_edge(clk)) then 
           if init_s='1' then zreg_s <= angle;          -- x 
           elsif load_s='1' then zreg_s <= newz_s;                    
           end if; 
        end if;    
    end process;    
 
    as_s <= zreg_s(31); -- MSB=Sign bit    
 
    process (clk,load_s,init_s) -- bit counter 
    begin 
        if (rising_edge(clk)) then    
           if init_s='1' then cnt_s<=(others=> '0'); 
            elsif (load_s='1') then cnt_s <= cnt_s + '1'; 
           end if;    
        end if;    
    end process;  
 
    sin  <= yreg_s; 
    cos  <= xreg_s; 
 
end synthesis; 

         
------------------------------------------------------------------------------- 
--                                                                           -- 
--  Simple Cordic                                                            -- 
--  Copyright (C) 1999 HT-LAB                                                -- 
--                                                                           -- 
--  Contact/Feedback : http://www.ht-lab.com/feedback.htm                    -- 
--  Web: http://www.ht-lab.com                                               -- 
--                                                                           -- 
------------------------------------------------------------------------------- 
--                                                                           -- 
--  This library is free software; you can redistribute it and/or            -- 
--  modify it under the terms of the GNU Lesser General Public               -- 
--  License as published by the Free Software Foundation; either             -- 
--  version 2.1 of the License, or (at your option) any later version.       -- 
--                                                                           -- 
--  This library is distributed in the hope that it will be useful,          -- 
--  but WITHOUT ANY WARRANTY; without even the implied warranty of           -- 
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU        -- 
--  Lesser General Public License for more details.                          -- 
--                                                                           -- 
--  Full details of the license can be found in the file "copying.txt".      -- 
--                                                                           -- 
--  You should have received a copy of the GNU Lesser General Public         -- 
--  License along with this library; if not, write to the Free Software      -- 
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA  -- 
--                                                                           -- 
------------------------------------------------------------------------------- 
-- Adder/Subtracter                                                          -- 
-- no overflow.                                                              -- 
--                                                                           -- 
------------------------------------------------------------------------------- 
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all; 
 
entity addsub is 
    port (abus   : in  std_logic_vector(31 downto 0); 
          bbus   : in  std_logic_vector(31 downto 0); 
          obus   : out std_logic_vector(31 downto 0);          
          as     : in  std_logic);          --add=1, subtract=0           
end addsub; 
 
architecture synthesis of addsub is 
 
begin 
 
  process(as,abus,bbus) 
    begin 
      if as='1' then  
         obus <= abus + bbus; 
      else 
         obus <= abus - bbus; 
    end if;         
  end process;   
       
end synthesis;


------------------------------------------------------------------------------- 
--                                                                           -- 
--  Simple Cordic                                                            -- 
--  Copyright (C) 1999 HT-LAB                                                -- 
--                                                                           -- 
--  Contact/Feedback : http://www.ht-lab.com/feedback.htm                    -- 
--  Web: http://www.ht-lab.com                                               -- 
--                                                                           -- 
------------------------------------------------------------------------------- 
--                                                                           -- 
--  This library is free software; you can redistribute it and/or            -- 
--  modify it under the terms of the GNU Lesser General Public               -- 
--  License as published by the Free Software Foundation; either             -- 
--  version 2.1 of the License, or (at your option) any later version.       -- 
--                                                                           -- 
--  This library is distributed in the hope that it will be useful,          -- 
--  but WITHOUT ANY WARRANTY; without even the implied warranty of           -- 
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU        -- 
--  Lesser General Public License for more details.                          -- 
--                                                                           -- 
--  Full details of the license can be found in the file "copying.txt".      -- 
--                                                                           -- 
--  You should have received a copy of the GNU Lesser General Public         -- 
--  License along with this library; if not, write to the Free Software      -- 
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA  -- 
--                                                                           -- 
------------------------------------------------------------------------------- 
 
library ieee; 
use ieee.std_logic_1164.all; 
 
entity atan32 is 
  port ( za    : in std_logic_vector(4 downto 0); 
         zdata : out std_logic_vector(31 downto 0)); 
end atan32; 
 
 
Architecture synthesis of atan32 Is 
Begin 
  process(ZA) 
  begin 
    Case ZA is	                            
       when "00000" => ZData <= X"3243f6a8"; 
       when "00001" => ZData <= X"1dac6705"; 
       when "00010" => ZData <= X"0fadbafc"; 
       when "00011" => ZData <= X"07f56ea6"; 
       when "00100" => ZData <= X"03feab76"; 
       when "00101" => ZData <= X"01ffd55b"; 
       when "00110" => ZData <= X"00fffaaa"; 
       when "00111" => ZData <= X"007fff55"; 
       when "01000" => ZData <= X"003fffea"; 
       when "01001" => ZData <= X"001ffffd"; 
       when "01010" => ZData <= X"000fffff"; 
       when "01011" => ZData <= X"0007ffff"; 
       when "01100" => ZData <= X"0003ffff"; 
       when "01101" => ZData <= X"0001ffff"; 
       when "01110" => ZData <= X"0000ffff"; 
       when "01111" => ZData <= X"00007fff"; 
       when "10000" => ZData <= X"00003fff"; 
       when "10001" => ZData <= X"00001fff"; 
       when "10010" => ZData <= X"00000fff"; 
       when "10011" => ZData <= X"000007ff"; 
       when "10100" => ZData <= X"000003ff"; 
       when "10101" => ZData <= X"000001ff"; 
       when "10110" => ZData <= X"000000ff"; 
       when "10111" => ZData <= X"0000007f"; 
       when "11000" => ZData <= X"0000003f"; 
       when "11001" => ZData <= X"0000001f"; 
       when "11010" => ZData <= X"0000000f"; 
       when "11011" => ZData <= X"00000007"; 
       when "11100" => ZData <= X"00000003"; 
       when "11101" => ZData <= X"00000001"; 
       when "11110" => ZData <= X"00000000"; 
       when "11111" => ZData <= X"00000000"; 
       When others  => ZData <= "--------------------------------"; 
    end case; 
  end process; 
end synthesis; 


------------------------------------------------------------------------------- 
--                                                                           -- 
--  Simple Cordic                                                            -- 
--  Copyright (C) 1999 HT-LAB                                                -- 
--                                                                           -- 
--  Contact/Feedback : http://www.ht-lab.com/feedback.htm                    -- 
--  Web: http://www.ht-lab.com                                               -- 
--                                                                           -- 
------------------------------------------------------------------------------- 
--                                                                           -- 
--  This library is free software; you can redistribute it and/or            -- 
--  modify it under the terms of the GNU Lesser General Public               -- 
--  License as published by the Free Software Foundation; either             -- 
--  version 2.1 of the License, or (at your option) any later version.       -- 
--                                                                           -- 
--  This library is distributed in the hope that it will be useful,          -- 
--  but WITHOUT ANY WARRANTY; without even the implied warranty of           -- 
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU        -- 
--  Lesser General Public License for more details.                          -- 
--                                                                           -- 
--  Full details of the license can be found in the file "copying.txt".      -- 
--                                                                           -- 
--  You should have received a copy of the GNU Lesser General Public         -- 
--  License along with this library; if not, write to the Free Software      -- 
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA  -- 
--                                                                           -- 
------------------------------------------------------------------------------- 
                                                
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all; 
 
 
ENTITY fsm IS 
   PORT(  
      clk   : IN     std_logic; 
      reset : IN     std_logic; -- Active low reset 
      start : IN     std_logic; 
      cnt   : IN     std_logic_vector (4 DOWNTO 0); 
      init  : OUT    std_logic; 
      load  : OUT    std_logic; 
      done  : OUT    std_logic); 
END fsm ; 
 
 
architecture synthesis of fsm is 
          
 type   states is (s0,s1,s2,s3); 
 signal state,nextstate : states;      
 
begin 
          
 Process (clk,reset)      -- Process to create current state variables  
  begin 
   if (reset='0') then       -- Reset State 
       state <= s0;               
   elsif (rising_edge(clk)) then    
       state <= nextstate;   -- Set Current state 
   end if;    
 end process;   
    
 process(state,start,cnt) 
  begin   
   case state is 
      when s0 =>                               -- Step 1 load regs 
           if  start='1' then nextstate <= s1;  
                         else nextstate <= s0; -- Wait for start signal  
           end if;  
            
      when s1 =>                               -- latch result register 
           if  cnt="11111" then nextstate <= s2; -- done 
                             else nextstate <= s1; -- wait 
           end if;                             
            
      when s2 =>                                                                               
           if  start='0' then nextstate <= s0;  
                         else nextstate <= s2; -- Wait for start signal  
           end if;  
            
      when others => nextstate <= s0;               
   end case;                    
 end process;     
  
 process(state) 
  begin   
   case state is 
      when s0 =>done <= '0'; init <= '1'; load <= '0';                                                    
      when s1 =>done <= '0'; init <= '0'; load <= '1';     
      when s2 =>done <= '1'; init <= '0'; load <= '0';            
      when others => done <= '-'; init <= '-'; load <= '-';                
   end case;                    
 end process;   
 
end synthesis;

------------------------------------------------------------------------------- 
--                                                                           -- 
--  Simple Cordic                                                            -- 
--  Copyright (C) 1999 HT-LAB                                                -- 
--                                                                           -- 
--  Contact/Feedback : http://www.ht-lab.com/feedback.htm                    -- 
--  Web: http://www.ht-lab.com                                               -- 
--                                                                           -- 
------------------------------------------------------------------------------- 
--                                                                           -- 
--  This library is free software; you can redistribute it and/or            -- 
--  modify it under the terms of the GNU Lesser General Public               -- 
--  License as published by the Free Software Foundation; either             -- 
--  version 2.1 of the License, or (at your option) any later version.       -- 
--                                                                           -- 
--  This library is distributed in the hope that it will be useful,          -- 
--  but WITHOUT ANY WARRANTY; without even the implied warranty of           -- 
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU        -- 
--  Lesser General Public License for more details.                          -- 
--                                                                           -- 
--  Full details of the license can be found in the file "copying.txt".      -- 
--                                                                           -- 
--  You should have received a copy of the GNU Lesser General Public         -- 
--  License along with this library; if not, write to the Free Software      -- 
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA  -- 
--                                                                           -- 
------------------------------------------------------------------------------- 
-- Shift Right preserving sign bit                                           -- 
--                                                                           -- 
-------------------------------------------------------------------------------    
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all; 
 
entity shiftn is       
    port (ibus   : in  std_logic_vector(31 downto 0);           
          obus   : out std_logic_vector(31 downto 0);      
          n      : in  std_logic_vector(4  downto 0));          --shift by n           
end shiftn; 
 
architecture synthesis of shiftn is 
 
begin 
 
  process(n,ibus) 
    begin 
      case n is  
        when "00000" => obus <= ibus(31)&ibus(30 downto 0); -- ibus 
        when "00001" => obus <= ibus(31)&ibus(31)&ibus(30 downto 1); 
        when "00010" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(30 downto 2);  
        when "00011" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(30 downto 3);       
        when "00100" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(30 downto 4);      
        when "00101" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(30 downto 5);      
        when "00110" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(30 downto 6);      
        when "00111" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                       ibus(31)&ibus(30 downto 7);      
        when "01000" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                ibus(31)&ibus(31)&ibus(30 downto 8);      
        when "01001" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                ibus(31)&ibus(31)&ibus(31)&ibus(30 downto 9);      
        when "01010" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(30 downto 10);      
        when "01011" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(30 downto 11);      
        when "01100" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(30 downto 12);      
        when "01101" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(30 downto 13);      
        when "01110" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(30 downto 14);      
        when "01111" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(30 downto 15);                 
        when "10000" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                  ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                          ibus(30 downto 16);     
        when "10001" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                  ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                          ibus(31)&ibus(30 downto 17);   
        when "10010" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                  ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                          ibus(31)&ibus(31)&ibus(30 downto 18);   
        when "10011" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                  ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                          ibus(31)&ibus(31)&ibus(31)&ibus(30 downto 19);      
        when "10100" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                  ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                          ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(30 downto 20);     
        when "10101" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                  ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                          ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(30 downto 21);    
        when "10110" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                  ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                          ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(30 downto 22);       
        when "10111" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                  ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                          ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(30 downto 23);       
        when "11000" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                  ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                          ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(30 downto 24);   
        when "11001" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                  ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                          ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(30 downto 25);   
        when "11010" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                  ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                          ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                          ibus(30 downto 26);     
        when "11011" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                  ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                          ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                          ibus(31)&ibus(30 downto 27);       
        when "11100" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                  ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                          ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                          ibus(31)&ibus(31)&ibus(30 downto 28);       
        when "11101" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                  ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                          ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                          ibus(31)&ibus(31)&ibus(31)&ibus(30 downto 29);       
        when "11110" => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                  ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                          ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                          ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(30);      
        when others  => obus <= ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                  ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                          ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31)& 
                                          ibus(31)&ibus(31)&ibus(31)&ibus(31)&ibus(31);   
      end case;         
  end process;   
       
end synthesis;
