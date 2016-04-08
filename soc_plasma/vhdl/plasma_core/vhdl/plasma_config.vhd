library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

package asip_config is

	-- INSTRUCTION TYPE (000000)
	constant ENABLE_SLL          : integer := 1 ; -- "000000";
	constant ENABLE_SRL          : integer := 1 ; -- "000010";
	constant ENABLE_SRA          : integer := 1 ; -- "000011";
	constant ENABLE_SLLV         : integer := 1 ; -- "000100";
	constant ENABLE_SRLV         : integer := 1 ; -- "000110";
	constant ENABLE_SRAV         : integer := 1 ; -- "000111";
	constant ENABLE_JR           : integer := 1 ; -- "001000";
	constant ENABLE_JALR         : integer := 1 ; -- "001001";
	constant ENABLE_MOVZ         : integer := 1 ; -- "001010";
	constant ENABLE_MOVN         : integer := 1 ; -- "001011";
	constant ENABLE_SYSCALL      : integer := 1 ; -- "001100";
	constant ENABLE_BREAK        : integer := 1 ; -- "001101";
	constant ENABLE_SYNC         : integer := 1 ; -- "001111";
	constant ENABLE_MFHI         : integer := 1 ; -- "010000";
	constant ENABLE_MTHI         : integer := 1 ; -- "010001";
	constant ENABLE_MFLO         : integer := 1 ; -- "010010";
	constant ENABLE_MTLO         : integer := 1 ; -- "010011";
	constant ENABLE_MULT         : integer := 1 ; -- "011000";
	constant ENABLE_MULTU        : integer := 1 ; -- "011001";
	constant ENABLE_DIV          : integer := 1 ; -- "011010";
	constant ENABLE_DIVU         : integer := 1 ; -- "011011";
	constant ENABLE_ADD          : integer := 1 ; -- "100000";
	constant ENABLE_ADDU         : integer := 1 ; -- "100001";
	constant ENABLE_SUB          : integer := 1 ; -- "100010";
	constant ENABLE_SUBU         : integer := 1 ; -- "100011";
	constant ENABLE_AND          : integer := 1 ; -- "100100";
	constant ENABLE_OR           : integer := 1 ; -- "100101";
	constant ENABLE_XOR          : integer := 1 ; -- "100110";
	constant ENABLE_NOR          : integer := 1 ; -- "100111";
	constant ENABLE_SLT          : integer := 1 ; -- "101010";
	constant ENABLE_SLTU         : integer := 1 ; -- "101011";
	constant ENABLE_DADDU        : integer := 1 ; -- "101101";
	constant ENABLE_TGEU         : integer := 1 ; -- "110001";
	constant ENABLE_TLT          : integer := 1 ; -- "110010";
	constant ENABLE_TLTU         : integer := 1 ; -- "110011";
	constant ENABLE_TEQ          : integer := 1 ; -- "110100";
	constant ENABLE_TNE          : integer := 1 ; -- "110110";

	-- INSTRUCTION TYPE (000001)
	constant ENABLE_BLTZ         : integer := 1 ; -- "00000";
	constant ENABLE_BGEZ         : integer := 1 ; -- "00001";
	constant ENABLE_BLTZL        : integer := 1 ; -- "00010";
	constant ENABLE_BGEZL        : integer := 1 ; -- "00011";
	constant ENABLE_BLTZAL       : integer := 1 ; -- "10000";
	constant ENABLE_BGEZAL       : integer := 1 ; -- "10001";
	constant ENABLE_BLTZALL      : integer := 1 ; -- "10010";
	constant ENABLE_BGEZALL      : integer := 1 ; -- "10011";

	-- INSTRUCTION TYPE (000010)
	constant ENABLE_J            : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (000011)
	constant ENABLE_JAL          : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (000100)
	constant ENABLE_BEQ          : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (000101)
	constant ENABLE_BNE          : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (000110)
	constant ENABLE_BLEZ         : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (000111)
	constant ENABLE_BGTZ         : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (001000)
	constant ENABLE_ADDI         : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (001001)
	constant ENABLE_ADDIU        : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (001010)
	constant ENABLE_SLTI         : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (001011)
	constant ENABLE_SLTIU        : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (001100)
	constant ENABLE_ANDI         : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (001101)
	constant ENABLE_ORI          : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (001110)
	constant ENABLE_XORI         : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (001111)
	constant ENABLE_LUI          : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (010000)
	constant ENABLE_COP0         : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (010001)
	constant ENABLE_COP1         : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (010010)
	constant ENABLE_COP2         : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (010011)
	constant ENABLE_COP3         : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (010100)
	constant ENABLE_BEQL         : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (010101)
	constant ENABLE_BNEL         : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (010110)
	constant ENABLE_BLEZL        : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (010111)
	constant ENABLE_BGTZL        : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (100000)
	constant ENABLE_LB           : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (100001)
	constant ENABLE_LH           : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (100010)
	constant ENABLE_LWL          : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (100011)
	constant ENABLE_LW           : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (100100)
	constant ENABLE_LBU          : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (100101)
	constant ENABLE_LHU          : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (100110)
	constant ENABLE_LWR          : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (101000)
	constant ENABLE_SB           : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (101001)
	constant ENABLE_SH           : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (101010)
	constant ENABLE_SWL          : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (101011)
	constant ENABLE_SW           : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (101110)
	constant ENABLE_SWR          : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (101111)
	constant ENABLE_CACHE        : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (110000)
	constant ENABLE_LL           : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (110001)
	constant ENABLE_LWC1         : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (110010)
	constant ENABLE_LWC2         : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (110011)
	constant ENABLE_LWC3         : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (110101)
	constant ENABLE_LDC1         : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (110110)
	constant ENABLE_LDC2         : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (110111)
	constant ENABLE_LDC3         : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (111000)
	constant ENABLE_SC           : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (111001)
	constant ENABLE_SWC1         : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (111010)
	constant ENABLE_SWC2         : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (111011)
	constant ENABLE_SWC3         : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (111101)
	constant ENABLE_SDC1         : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (111110)
	constant ENABLE_SDC2         : integer := 1 ; -- "";

	-- INSTRUCTION TYPE (111111)
	constant ENABLE_SDC3         : integer := 1 ; -- "";

end;

package body asip_config is

	-- NOTHING FOR NOW ;-)

end;

