-- Address decode logic for ipbus fabric
--
-- This file has been AUTOGENERATED from the address table - do not hand edit
--
-- We assume the synthesis tool is clever enough to recognise exclusive conditions
-- in the if statement.
--
-- Dave Newbold, February 2011

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.ipbus.all;

package ipbus_addr_decode is

  function ipbus_addr_sel(signal addr : in std_logic_vector(31 downto 0)) return integer;

end ipbus_addr_decode;

package body ipbus_addr_decode is

  function ipbus_addr_sel(signal addr : in std_logic_vector(31 downto 0)) return integer is
    variable sel : integer;
  begin
  if    std_match(addr, "----------------0--0----------00") then
          sel := 0; -- reg0 / base 0x00000000 / mask 0x00000000
  elsif std_match(addr, "----------------0--0----------01") then
          sel := 1; -- reg1 / base 0x00000001 / mask 0x00000000
  elsif std_match(addr, "----------------0--1------------") then
          sel := 2; -- ram / base 0x00001000 / mask 0x00000fff
  elsif std_match(addr, "----------------0--0----------10") then
          sel := 3; -- bus_ctr / base 0x00000002 / mask 0x00000000
  elsif std_match(addr, "----------------1--0------------") then
          sel := 4; -- oob_test / base 0x00008000 / mask 0x000007ff
  else
          sel := 99;
  end if;

		return sel;
	end ipbus_addr_sel;
 
end ipbus_addr_decode;
