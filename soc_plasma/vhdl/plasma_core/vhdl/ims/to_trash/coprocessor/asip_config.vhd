library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

package asip_config is

	-- INSTRUCTION TYPE (00)
	constant ENABLE_UNIMP        : integer := 0 ; -- "000";
	constant ENABLE_BICC         : integer := 1 ; -- "010";
	constant ENABLE_SETHI        : integer := 1 ; -- "100";
	constant ENABLE_FBFCC        : integer := 0 ; -- "110";
	constant ENABLE_CBCCC        : integer := 0 ; -- "111";

	-- INSTRUCTION TYPE (01)
	constant ENABLE_CALL         : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (10)
	constant ENABLE_IADD         : integer := 1 ; -- "000000";
	constant ENABLE_IAND         : integer := 1 ; -- "000001";
	constant ENABLE_IOR          : integer := 1 ; -- "000010";
	constant ENABLE_IXOR         : integer := 1 ; -- "000011";
	constant ENABLE_ISUB         : integer := 1 ; -- "000100";
	constant ENABLE_ANDN         : integer := 1 ; -- "000101";
	constant ENABLE_ORN          : integer := 0 ; -- "000110";
	constant ENABLE_IXNOR        : integer := 0 ; -- "000111";
	constant ENABLE_ADDX         : integer := 1 ; -- "001000";
	constant ENABLE_CUSTOM_1     : integer := 0 ; -- "001001";
	constant ENABLE_UMUL         : integer := 0 ; -- "001010";
	constant ENABLE_SMUL         : integer := 1 ; -- "001011";
	constant ENABLE_SUBX         : integer := 0 ; -- "001100";
	constant ENABLE_CUSTOM_2     : integer := 0 ; -- "001101";
	constant ENABLE_UDIV         : integer := 0 ; -- "001110";
	constant ENABLE_SDIV         : integer := 1 ; -- "001111";
	constant ENABLE_ADDCC        : integer := 0 ; -- "010000";
	constant ENABLE_ANDCC        : integer := 1 ; -- "010001";
	constant ENABLE_ORCC         : integer := 1 ; -- "010010";
	constant ENABLE_XORCC        : integer := 0 ; -- "010011";
	constant ENABLE_SUBCC        : integer := 1 ; -- "010100";
	constant ENABLE_ANDNCC       : integer := 0 ; -- "010101";
	constant ENABLE_ORNCC        : integer := 0 ; -- "010110";
	constant ENABLE_XNORCC       : integer := 0 ; -- "010111";
	constant ENABLE_ADDXCC       : integer := 0 ; -- "011000";
	constant ENABLE_CUSTOM_3     : integer := 0 ; -- "011001";
	constant ENABLE_UMULCC       : integer := 0 ; -- "011010";
	constant ENABLE_SMULCC       : integer := 0 ; -- "011011";
	constant ENABLE_SUBXCC       : integer := 0 ; -- "011100";
	constant ENABLE_CUSTOM_4     : integer := 0 ; -- "011101";
	constant ENABLE_UDIVCC       : integer := 0 ; -- "011110";
	constant ENABLE_SDIVCC       : integer := 0 ; -- "011111";
	constant ENABLE_TADDCC       : integer := 0 ; -- "100000";
	constant ENABLE_TSUBCC       : integer := 0 ; -- "100001";
	constant ENABLE_TADDCCTV     : integer := 0 ; -- "100010";
	constant ENABLE_TSUBCCTV     : integer := 0 ; -- "100011";
	constant ENABLE_MULSCC       : integer := 0 ; -- "100100";
	constant ENABLE_ISLL         : integer := 1 ; -- "100101";
	constant ENABLE_ISRL         : integer := 1 ; -- "100110";
	constant ENABLE_ISRA         : integer := 1 ; -- "100111";
	constant ENABLE_RDY          : integer := 1 ; -- "101000";
	constant ENABLE_RDPSR        : integer := 1 ; -- "101001";
	constant ENABLE_RDWIM        : integer := 0 ; -- "101010";
	constant ENABLE_RDTBR        : integer := 0 ; -- "101011";
	constant ENABLE_CUSTOM_5     : integer := 0 ; -- "101100";
	constant ENABLE_CUSTOM_6     : integer := 0 ; -- "101101";
	constant ENABLE_CUSTOM_7     : integer := 0 ; -- "101110";
	constant ENABLE_CUSTOM_8     : integer := 0 ; -- "101111";
	constant ENABLE_WRY          : integer := 1 ; -- "110000";
	constant ENABLE_WRPSR        : integer := 1 ; -- "110001";
	constant ENABLE_WRWIM        : integer := 1 ; -- "110010";
	constant ENABLE_WRTBR        : integer := 1 ; -- "110011";
	constant ENABLE_FPOP1        : integer := 0 ; -- "110100";
	constant ENABLE_FPOP2        : integer := 0 ; -- "110101";
	constant ENABLE_CPOP1        : integer := 0 ; -- "110110";
	constant ENABLE_CPOP2        : integer := 0 ; -- "110111";
	constant ENABLE_JMPL         : integer := 1 ; -- "111000";
	constant ENABLE_RETT         : integer := 0 ; -- "111001";
	constant ENABLE_TICC         : integer := 0 ; -- "111010";
	constant ENABLE_FLUSH        : integer := 1 ; -- "111011";
	constant ENABLE_SAVE         : integer := 1 ; -- "111100";
	constant ENABLE_RESTORE      : integer := 1 ; -- "111101";
	constant ENABLE_UMAC         : integer := 0 ; -- "111110";
	constant ENABLE_SMAC         : integer := 0 ; -- "111111";

	-- INSTRUCTION TYPE (11)
	constant ENABLE_LD           : integer := 1 ; -- "000000";
	constant ENABLE_LDUB         : integer := 0 ; -- "000001";
	constant ENABLE_LDUH         : integer := 0 ; -- "000010";
	constant ENABLE_LDD          : integer := 0 ; -- "000011";
	constant ENABLE_ST           : integer := 1 ; -- "000100";
	constant ENABLE_STB          : integer := 0 ; -- "000101";
	constant ENABLE_STH          : integer := 0 ; -- "000110";
	constant ENABLE_ISTD         : integer := 1 ; -- "000111";
	constant ENABLE_LDSB         : integer := 0 ; -- "001001";
	constant ENABLE_LDSH         : integer := 0 ; -- "001010";
	constant ENABLE_LDSTUB       : integer := 0 ; -- "001101";
	constant ENABLE_SWAP         : integer := 0 ; -- "001111";
	constant ENABLE_LDA          : integer := 0 ; -- "010000";
	constant ENABLE_LDUBA        : integer := 0 ; -- "010001";
	constant ENABLE_LDUHA        : integer := 0 ; -- "010010";
	constant ENABLE_LDDA         : integer := 0 ; -- "010011";
	constant ENABLE_STA          : integer := 1 ; -- "010100";
	constant ENABLE_STBA         : integer := 0 ; -- "010101";
	constant ENABLE_STHA         : integer := 0 ; -- "010110";
	constant ENABLE_STDA         : integer := 0 ; -- "010111";
	constant ENABLE_LDSBA        : integer := 0 ; -- "011001";
	constant ENABLE_LDSHA        : integer := 0 ; -- "011010";
	constant ENABLE_LDSTUBA      : integer := 0 ; -- "011101";
	constant ENABLE_SWAPA        : integer := 0 ; -- "011111";
	constant ENABLE_LDF          : integer := 0 ; -- "100000";
	constant ENABLE_LDFSR        : integer := 0 ; -- "100001";
	constant ENABLE_LDDF         : integer := 0 ; -- "100011";
	constant ENABLE_STF          : integer := 0 ; -- "100100";
	constant ENABLE_STFSR        : integer := 0 ; -- "100101";
	constant ENABLE_STDFQ        : integer := 0 ; -- "100110";
	constant ENABLE_STDF         : integer := 0 ; -- "100111";
	constant ENABLE_LDC          : integer := 0 ; -- "110000";
	constant ENABLE_LDCSR        : integer := 0 ; -- "110001";
	constant ENABLE_LDDC         : integer := 0 ; -- "110011";
	constant ENABLE_STC          : integer := 0 ; -- "110100";
	constant ENABLE_STCSR        : integer := 0 ; -- "110101";
	constant ENABLE_STDCQ        : integer := 0 ; -- "110110";
	constant ENABLE_STDC         : integer := 0 ; -- "110111";
	constant ENABLE_CASA         : integer := 0 ; -- "111100";

end;

package body asip_config is

	-- NOTHING FOR NOW ;-)

end;

