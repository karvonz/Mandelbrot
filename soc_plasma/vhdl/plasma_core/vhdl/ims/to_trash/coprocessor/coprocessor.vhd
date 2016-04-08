------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003 - 2008, Gaisler Research
--  Copyright (C) 2008 - 2010, Aeroflex Gaisler
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-----------------------------------------------------------------------------
-- Package: 	arith
-- File:	arith.vhd
-- Author:	Jiri Gaisler, Gaisler Research
-- Description:	Declaration of mul/div components
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

package coprocessor is

type sequential32_in_type is record
  op1        : std_logic_vector(32 downto 0); -- operand 1
  op2        : std_logic_vector(32 downto 0); -- operand 2
  flush      : std_logic;
  signed     : std_logic;
  start      : std_logic;
  dInstr     : std_logic_vector(31 downto 0);
  aInstr     : std_logic_vector(31 downto 0);
  eInstr     : std_logic_vector(31 downto 0);
  mInstr     : std_logic_vector(31 downto 0);
  xInstr     : std_logic_vector(31 downto 0);
end record;

type sequential32_out_type is record
  ready       : std_logic;
  nready      : std_logic;
  icc         : std_logic_vector(3 downto 0);
  result      : std_logic_vector(31 downto 0);
  mResult     : std_logic_vector(31 downto 0);
end record;

type async32_in_type is record
  op1        : std_logic_vector(32 downto 0); -- operand 1
  op2        : std_logic_vector(32 downto 0); -- operand 2
  signed     : std_logic;
  write_data : std_logic;
  read_data  : std_logic;
end record;

type async32_out_type is record
  ready           : std_logic;
  nready          : std_logic;
  icc             : std_logic_vector(3 downto 0);
  result          : std_logic_vector(31 downto 0);
end record;

-- definition d'un type de base pour les operateurs arithmetiques pouvant se
-- realiser en un cycle d'horloge
type custom32_in_type is record
  op1   : std_logic_vector(32 downto 0); -- operand 1
  op2   : std_logic_vector(32 downto 0); -- operand 2
  instr : std_logic_vector(31 downto 0); -- operand 2
end record;

type custom32_out_type is record
  result          : std_logic_vector(31 downto 0);
end record;
-- fin de declaration

	component RESOURCE_CUSTOM_1
	port (
		inp  : in  custom32_in_type;
		outp : out custom32_out_type
	);
	end component;

	component RESOURCE_CUSTOM_2
	port (
		inp  : in  custom32_in_type;
		outp : out custom32_out_type
	);
	end component;

	component RESOURCE_CUSTOM_3
	port (
		inp  : in  custom32_in_type;
		outp : out custom32_out_type
	);
	end component;

	component RESOURCE_CUSTOM_4
	port (
		inp  : in  custom32_in_type;
		outp : out custom32_out_type
	);
	end component;

	component RESOURCE_CUSTOM_5
	port (
		inp  : in  custom32_in_type;
		outp : out custom32_out_type
	);
	end component;

	component RESOURCE_CUSTOM_6
	port (
		rst        : in  std_ulogic;
		clk        : in  std_ulogic;
		holdn      : in  std_ulogic;
		inp  	   : in  async32_in_type;
		outp 	   : out async32_out_type
	);
	end component;

	component RESOURCE_CUSTOM_7
	port (
		inp  : in  custom32_in_type;
		outp : out custom32_out_type
	);
	end component;

	component RESOURCE_CUSTOM_8
	port (
		inp  : in  custom32_in_type;
		outp : out custom32_out_type
	);
	end component;

	component RESOURCE_CUSTOM_A
	port (
		rst     : in  std_ulogic;
		clk     : in  std_ulogic;
		holdn   : in  std_ulogic;
		inp     : in  sequential32_in_type;
		outp    : out sequential32_out_type
	);
	end component;

	component RESOURCE_CUSTOM_B
	port (
		rst     : in  std_ulogic;
		clk     : in  std_ulogic;
		holdn   : in  std_ulogic;
		inp     : in  sequential32_in_type;
		outp    : out sequential32_out_type
	);
	end component;

	COMPONENT INTERFACE_COMB_1
	PORT (
		inp  : IN  custom32_in_type;
		outp : OUT custom32_out_type
	);
	END COMPONENT;
	
	COMPONENT INTERFACE_COMB_2
	PORT (
		inp  : IN  custom32_in_type;
		outp : OUT custom32_out_type
	);
	END COMPONENT;
	
	COMPONENT INTERFACE_COMB_3
	PORT (
		inp  : IN  custom32_in_type;
		outp : OUT custom32_out_type
	);
	END COMPONENT;
	
	COMPONENT INTERFACE_COMB_4
	PORT (
		rst    : in  std_ulogic;
		clk    : in  std_ulogic;
		holdn  : in  std_ulogic;
		cancel : IN  std_ulogic;
		inp    : IN  custom32_in_type;
		outp   : OUT custom32_out_type
	);
	END COMPONENT;
	
	COMPONENT INTERFACE_SEQU_1
	PORT (
		rst     : in  std_ulogic;
		clk     : in  std_ulogic;
		holdn   : in  std_ulogic;
		inp     : in  sequential32_in_type;
		outp    : out sequential32_out_type
	);
	END COMPONENT;

	COMPONENT INTERFACE_ASYN_1
	PORT (
		rst        : in  std_ulogic;
		clk        : in  std_ulogic;
		holdn      : in  std_ulogic;
		inp  	   : in  async32_in_type;
		outp 	   : out async32_out_type
	);
	END COMPONENT;

	
	-- synthesis translate_off 
	procedure printmsg(s : string);
	-- synthesis translate_on

end;

package body coprocessor is

	-- synthesis translate_off 
	PROCEDURE printmsg(s : string) is
		variable L : line;
	BEGIN
		L := new string'(s);
		writeline(output, L);
	END;
	-- synthesis translate_on
	
END;

