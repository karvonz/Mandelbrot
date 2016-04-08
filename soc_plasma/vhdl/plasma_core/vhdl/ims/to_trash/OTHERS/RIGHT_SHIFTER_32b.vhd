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

entity RIGHT_SHIFTER_32b is       
   port (
		INPUT_1   : in  std_logic_vector(31 downto 0);           
      INPUT_2   : in  std_logic_vector(31 downto 0);
      OUTPUT_1  : out std_logic_vector(31 downto 0)
	);
end RIGHT_SHIFTER_32b;

architecture synthesis of RIGHT_SHIFTER_32b is 
	SIGNAL n : std_logic_vector(4  downto 0);
begin 

	n <= INPUT_2(4  downto 0);

	process(n,INPUT_1) 
   begin 
     case n is  
       when "00000" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(30 downto 0); -- INPUT_1 
       when "00001" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(30 downto 1); 
       when "00010" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(30 downto 2);  
       when "00011" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(30 downto 3);       
       when "00100" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(30 downto 4);      
       when "00101" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(30 downto 5);      
       when "00110" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(30 downto 6);      
       when "00111" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                      INPUT_1(31)&INPUT_1(30 downto 7);      
       when "01000" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                               INPUT_1(31)&INPUT_1(31)&INPUT_1(30 downto 8);      
       when "01001" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                               INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(30 downto 9);      
       when "01010" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                               INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(30 downto 10);      
       when "01011" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                               INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(30 downto 11);      
       when "01100" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                               INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(30 downto 12);      
       when "01101" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                               INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(30 downto 13);      
       when "01110" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                               INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(30 downto 14);      
       when "01111" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                               INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(30 downto 15);                 
       when "10000" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                 INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                         INPUT_1(30 downto 16);     
       when "10001" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                 INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                         INPUT_1(31)&INPUT_1(30 downto 17);   
       when "10010" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                 INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                         INPUT_1(31)&INPUT_1(31)&INPUT_1(30 downto 18);   
       when "10011" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                 INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                         INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(30 downto 19);      
       when "10100" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                 INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                         INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(30 downto 20);     
       when "10101" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                 INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                         INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(30 downto 21);    
       when "10110" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                 INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                         INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(30 downto 22);       
       when "10111" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                 INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                         INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(30 downto 23);       
       when "11000" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                 INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                         INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(30 downto 24);   
       when "11001" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                 INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                         INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(30 downto 25);   
       when "11010" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                 INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                         INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                         INPUT_1(30 downto 26);     
       when "11011" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                 INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                         INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                         INPUT_1(31)&INPUT_1(30 downto 27);       
       when "11100" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                 INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                         INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                         INPUT_1(31)&INPUT_1(31)&INPUT_1(30 downto 28);       
       when "11101" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                 INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                         INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                         INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(30 downto 29);       
       when "11110" => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                 INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                         INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                         INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(30);      
       when others  => OUTPUT_1 <= INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                 INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                         INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)& 
                                         INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31)&INPUT_1(31);   
     end case;         
	end process;   

end synthesis;
