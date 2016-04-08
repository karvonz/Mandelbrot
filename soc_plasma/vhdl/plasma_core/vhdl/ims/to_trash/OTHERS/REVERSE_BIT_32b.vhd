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

entity REVERSE_BIT_32b is       
   port (
		INPUT_1   : in  std_logic_vector(31 downto 0);           
		OUTPUT_1  : out std_logic_vector(31 downto 0)
	);
end REVERSE_BIT_32b;

architecture synthesis of REVERSE_BIT_32b is 
	SIGNAL n : std_logic_vector(4  downto 0);
	
  FUNCTION bit_reverse(s1:std_logic_vector) return std_logic_vector is
     variable rr : std_logic_vector(s1'high downto s1'low);
  begin
    for ii in s1'high downto s1'low loop
      rr(ii) := s1(s1'high-ii);
    end loop;
    return rr;
  end bit_reverse; 
  
begin 

-- Reverse bit order in an integer

-- #include <stdio.h>

-- static unsigned long reverse(unsigned long x) {
 -- unsigned long h = 0;
 -- int i = 0;

 -- for(h = i = 0; i < 32; i++) {
  -- h = (h << 1) + (x & 1); 
  -- x >>= 1; 
 -- }

 -- return h;
-- }


	OUTPUT_1(31 downto 0) <= bit_reverse(INPUT_1);

end synthesis;
