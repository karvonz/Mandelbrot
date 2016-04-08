--! @file ibus_pulser.vhd
--
-------------------------------------------------------------------------------
-- --
-- (c) University of Bristol, High Energy Physics Group --
-- --
-------------------------------------------------------------------------------
--
--
-- This file is part of IPBus.
--
--    IPBus is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    IPBus is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with IPBus.  If not, see <http://www.gnu.org/licenses/>.
--
--    IPBus is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    IPBus is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with IPBus.  If not, see <http://www.gnu.org/licenses/>.
--
--
--! Standard library
library IEEE;

--! Standard logic defintions.
use IEEE.STD_LOGIC_1164.all;

use ieee.numeric_std.all;

--! IPBus definitions
use work.ipbus.all;

--! @brief  Generic ipbus slave pulser - When addressed pulses the output lines for one
-- clock cycle.
--
--
--! @author David.Cussans@bristol.ac.uk
--
--! @date 20/May/2011
--
--! @version 0.1
--
--! @details -- Based on ipbus_reg.vhd
--! N.B. Makes the assumption that the address space is pre-decoded by ipbus_fabric
--! i.e. if ipbus_in.ipb_strobe goes high, we respond.
--!
--! We use one cycle of read / write latency to ease timing (probably not necessary)
--! The q outputs change immediately on write (no latency).
--
--
--! <b>Dependencies:</b>\n
--!
--! <b>References:</b>\n
--!
--! <b>Modified by:</b>\n
--! Author: <name>
-------------------------------------------------------------------------------
--! \n\n<b>Last changes:</b>\n
--! <date> <initials> <log>\n
--! <extended description>
-------------------------------------------------------------------------------
--! @todo <next thing to do> \n
--! <another thing to do> \n
--
-------------------------------------------------------------------------------

entity ipbus_pulser is
  port(
    clk_i: in STD_LOGIC;                --! IPBUS clock. Rising edge active
    reset_i: in STD_LOGIC;              --! Not used.
    ipbus_i: in ipb_wbus;
    ipbus_o: out ipb_rbus;
    q_o: out STD_LOGIC_VECTOR(31 downto 0)  --! Output signal.
    );
	
end ipbus_pulser;

architecture rtl of ipbus_pulser is

  signal s_ack: std_logic := '0';
  
begin

  p_register: process(clk_i)
  begin
    if rising_edge(clk_i) then

      if (ipbus_i.ipb_strobe='1' and ipbus_i.ipb_write='1') then
         q_o <= ipbus_i.ipb_wdata;
      else
        q_o <= (others => '0');
      end if;
            
      ipbus_o.ipb_rdata <= ( others => '0') ;  -- Always return zero when read
      s_ack <= ipbus_i.ipb_strobe and not s_ack;
      
    end if;
  end process p_register;
  
  ipbus_o.ipb_ack <= s_ack;
  ipbus_o.ipb_err <= '0';
  
end rtl;
