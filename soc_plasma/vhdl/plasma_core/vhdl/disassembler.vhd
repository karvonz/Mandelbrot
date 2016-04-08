---------------------------------------------------------------------
-- TITLE: Controller / Opcode Decoder
-- AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
-- DATE CREATED: 2/8/01
-- FILENAME: control.vhd
-- PROJECT: Plasma CPU core
-- COPYRIGHT: Software placed into the public domain by the author.
--    Software 'as is' without warranty.  Author liable for nothing.
-- NOTE:  MIPS(tm) is a registered trademark of MIPS Technologies.
--    MIPS Technologies does not endorse and is not associated with
--    this project.
-- DESCRIPTION:
--    Controls the CPU by decoding the opcode and generating control 
--    signals to the rest of the CPU.
--    This entity decodes the MIPS(tm) opcode into a 
--    Very-Long-Word-Instruction.  
--    The 32-bit opcode is converted to a 
--       6+6+6+16+4+2+4+3+2+2+3+2+4 = 60 bit VLWI opcode.
--    Based on information found in:
--       "MIPS RISC Architecture" by Gerry Kane and Joe Heinrich
--       and "The Designer's Guide to VHDL" by Peter J. Ashenden
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mlite_pack.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity disassembler is
   port(
		clk     : in  std_logic;
		reset   : in  std_logic;
		pause   : in std_logic;
		opcode  : in  std_logic_vector(31 downto 0);
		pc_addr : in  std_logic_vector(31 downto 2)
	);
end; --entity control

architecture logic of disassembler is

	-- synthesis_off
	type carr is array (0 to 9) of character;
	constant darr : carr := ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9');

	function tohex( n : std_logic_vector(3 downto 0) ) return character is
	begin
		case n is
			when "0000" => return('0');
  			when "0001" => return('1');
  			when "0010" => return('2');
  			when "0011" => return('3');
  			when "0100" => return('4');
  			when "0101" => return('5');
  			when "0110" => return('6');
		  	when "0111" => return('7');
  			when "1000" => return('8');
  			when "1001" => return('9');
  			when "1010" => return('a');
  			when "1011" => return('b');
  			when "1100" => return('c');
  			when "1101" => return('d');
  			when "1110" => return('e');
  			when "1111" => return('f');
  			when others => return('X');
  		end case;
	end;

   -- converts an integer into a character
   -- for 0 to 9 the obvious mapping is used, higher
   -- values are mapped to the characters A-Z
   -- (this is usefull for systems with base > 10)
   -- (adapted from Steve Vogwell's posting in comp.lang.vhdl)

   function chr(int: integer) return character is
    variable c: character;
   begin
        case int is
          when  0 => c := '0';
          when  1 => c := '1';
          when  2 => c := '2';
          when  3 => c := '3';
          when  4 => c := '4';
          when  5 => c := '5';
          when  6 => c := '6';
          when  7 => c := '7';
          when  8 => c := '8';
          when  9 => c := '9';
          when 10 => c := 'A';
          when 11 => c := 'B';
          when 12 => c := 'C';
          when 13 => c := 'D';
          when 14 => c := 'E';
          when 15 => c := 'F';
          when 16 => c := 'G';
          when 17 => c := 'H';
          when 18 => c := 'I';
          when 19 => c := 'J';
          when 20 => c := 'K';
          when 21 => c := 'L';
          when 22 => c := 'M';
          when 23 => c := 'N';
          when 24 => c := 'O';
          when 25 => c := 'P';
          when 26 => c := 'Q';
          when 27 => c := 'R';
          when 28 => c := 'S';
          when 29 => c := 'T';
          when 30 => c := 'U';
          when 31 => c := 'V';
          when 32 => c := 'W';
          when 33 => c := 'X';
          when 34 => c := 'Y';
          when 35 => c := 'Z';
          when others => c := '?';
        end case;
        return c;
    end chr;

   function chr_one_zero(int: std_logic) return character is
    variable c: character;
   begin
        case int is
          when  '0'   => c := '0';
          when  '1'   => c := '1';
          when others => c := '?';
        end case;
        return c;
    end chr_one_zero;

   -- converts std_logic_vector into a string (binary base)
   -- (this also takes care of the fact that the range of
   --  a string is natural while a std_logic_vector may
   --  have an integer range)
   function bin_char(slv: std_logic_vector) return string is
     	variable result : string (1 to slv'length);
     	variable r      : integer;
		variable bitv   : std_logic;
   begin
     r := 1;
     for i in slv'range loop
			bitv := slv(i);
        result(r) := chr_one_zero( bitv );
        r := r + 1;
     end loop;
     return result;
   end bin_char;



	function tostd(v:std_logic_vector) return string is
		variable s : string(1 to 2);
		variable val : integer;
	begin
	    val := to_integer( unsigned(v) );
		s(1) := darr(val / 10);
		s(2) := darr(val mod 10);
	  return(s);
	end;

	function tosth(v:std_logic_vector) return string is
		constant vlen : natural := v'length; --'
		constant slen : natural := (vlen+3)/4;
		variable vv : std_logic_vector(vlen-1 downto 0);
		variable s : string(1 to slen);
	begin
		vv := v;
  		for i in slen downto 1 loop
    		s(i) := tohex(vv(3 downto 0));
    		vv(vlen-5 downto 0) := vv(vlen-1 downto 4);
  		end loop;
  		return(s);
	end;

	function tostf(v:std_logic_vector) return string is
		constant vlen : natural := v'length; --'
		constant slen : natural := (vlen+3)/4;
		variable vv : std_logic_vector(vlen-1 downto 0);
		variable s : string(1 to slen);
	begin
		vv := v;
  		for i in slen downto 1 loop
    		s(i) := tohex(vv(3 downto 0));
    		vv(vlen-5 downto 0) := vv(vlen-1 downto 4);
  		end loop;
  		return("0x" & s);
	end;

	-----------------------------------------------------------------------------
	function tostrd(n : integer) return string is
		variable len : integer := 0;
		variable tmp : string(10 downto 1);
		variable v   : integer := n;
	begin
  		for i in 0 to 9 loop 
     		tmp(i+1) := darr(v mod 10);
     		if tmp(i+1) /= '0'  then
       		len := i;
     		end if;
     		v := v/10;
  		end loop;
		if( n < 0) then 
			tmp(len+1) := '-';
			len        := len + 1;
		end if;
  		return(tmp(len+1 downto 1));
	end;
	-----------------------------------------------------------------------------


	-----------------------------------------------------------------------------
	function tostrud(n : integer) return string is
		variable len : integer := 0;
		variable tmp : string(10 downto 1);
		variable v   : integer := n;
	begin
  		for i in 0 to 9 loop 
     		tmp(i+1) := darr(v mod 10);
     		if tmp(i+1) /= '0'  then
       		len := i;
     		end if;
     		v := v/10;
  		end loop;
  		return(tmp(len+1 downto 1));
	end;
	-----------------------------------------------------------------------------


	--
	--
	--
	--function no_code return string is
	--begin
  	--	return "XXXXXX";
	--end;


	--
	--
	--
	function intr2_code(v, f:std_logic_vector) return string is
	begin
  		return bin_char(v) & " " & bin_char(f) & " - ";
	end;

	--
	--
	--
	function intr_code(v:std_logic_vector) return string is
	begin
  		return bin_char(v) & " " & "XXXXXX" & " - ";
	end;


	--
	--
	--
	function ins2st( opcode : std_logic_vector(31 downto 0) ) return string is
--   uart_proc: process(clk, enable_write, data_in)
         file store_file          : text open write_mode is "assembler.log";
         variable hex_file_line   : line;
         variable hex_output_line : line;				-- BLG
         variable c               : character;
         variable index           : natural;
         variable line_length     : natural := 0;
		   variable op, func       : std_logic_vector(5 downto 0);
   		variable rs, rt, rd     : std_logic_vector(5 downto 0);
  		 	variable rtx            : std_logic_vector(4 downto 0);
  		 	variable imm            : std_logic_vector(15 downto 0);
  		 	variable target         : std_logic_vector(25 downto 0);
  		 	variable alu_function   : alu_function_type;
  		 	variable shift_function : shift_function_type;
  		 	variable mult_function  : mult_function_type;
  		 	variable a_source       : a_source_type;
  			variable b_source       : b_source_type;
   		variable c_source       : c_source_type;
   		variable pc_source      : pc_source_type;
   		variable branch_function: branch_function_type;
   		variable mem_source     : mem_source_type;
   		variable regA, regB, regC : integer;


  		 	variable re    : std_logic_vector(4 downto 0);
			variable vRE   : integer;
	begin
   	alu_function    := ALU_NOTHING;
   	shift_function  := SHIFT_NOTHING;
   	mult_function   := MULT_NOTHING;

   	a_source        := A_FROM_REG_SOURCE;
   	b_source        := B_FROM_REG_TARGET;
   	c_source        := C_FROM_NULL;
   	pc_source       := FROM_INC4;
   	branch_function := BRANCH_EQ;
   	mem_source      := MEM_FETCH;
   	op   := opcode(31 downto 26);

   	func   := opcode(5 downto 0);
   	imm    := opcode(15 downto 0);
   	target := opcode(25 downto 0);

		-- ON RECUEPERE LES NUMEROS DES REGISTRES CONCERNES
   	rs   := '0' & opcode(25 downto 21);
   	rt   := '0' & opcode(20 downto 16);
   	rd   := '0' & opcode(15 downto 11);
   	rtx  := opcode(20 downto 16);
		
		re   := opcode(10 downto 6);

		-- On recupere le numero des registres
		regA := to_integer( unsigned(rd) );
		regB := to_integer( unsigned(rt) );
		regC := to_integer( unsigned(rs) );
		vRE  := to_integer( unsigned(re) );

   	case op is
   		when "000000" =>   --SPECIAL
      		case func is
      			when "000000" =>
						if( (regC = 0) and (regB = 0) and (vRE = 0) )then
							return intr2_code(op, func) & " NOP";
						else
							return intr2_code(op, func) & " SLL    r[" & tostrd( regC ) & "] = r[" & tostrd( regB ) & "] << " & tostrd( vRE ) & ";";
						end if;
				-- when "000001" =>
	      		when "000010" =>  return intr2_code(op, func) & " SRL    r[" & tostrd( regC ) & "] = u[" & tostrd( regB ) & "] >> " & tostrd( vRE ) & ";";
	      		when "000011" =>  return intr2_code(op, func) & " SRA    r[" & tostrd( regC ) & "] = r[" & tostrd( regB ) & "] >> " & tostrd( vRE ) & ";";
		      	when "000100" =>  return intr2_code(op, func) & " SLLV   r[" & tostrd( regC ) & "] = r[" & tostrd( regB ) & "] << r[" & tostrd( regC ) & "];";
				-- when "000101" => 
		      	when "000110" =>  return intr2_code(op, func) & " SRLV   r[" & tostrd( regC ) & "] = u[" & tostrd( regB ) & "] >> r[" & tostrd( regC ) & "];";
		      	when "000111" =>  return intr2_code(op, func) & " SRAV   r[" & tostrd( regC ) & "] = r[" & tostrd( regB ) & "] >> r[" & tostrd( regC ) & "];";
		      	when "001000" =>  return intr2_code(op, func) & " JR     s->pc_next=r[" & tostrd( regC ) & "];";
		      	when "001001" =>  return intr2_code(op, func) & " JALR   r[" & tostrd( regC ) & "]=s->pc_next; s->pc_next=r[" & tostrd( regC ) & "];";
		      	when "001010" =>  return intr2_code(op, func) & " MOVZ   if(!r[" & tostrd( regB ) & "]) r[" & tostrd( regC ) & "] = r[" & tostrd( regC ) & "]; /*IV*/";
		      	when "001011" =>  return intr2_code(op, func) & " MOVN   if( r[" & tostrd( regB ) & "]) r[" & tostrd( regC ) & "] = r[" & tostrd( regC ) & "]; /*IV*/";
   		   	when "001100" =>  return intr2_code(op, func) & " SYSCALL";
		      	when "001101" =>  return intr2_code(op, func) & " BREAK (code = " & tostrd ( to_integer(unsigned(opcode(25 downto 6))) ) & ")"; -- s->wakeup=1;";
		      	when "001111" =>  return intr2_code(op, func) & " SYNC   s->wakeup=1;";
		      	when "010000" =>  return intr2_code(op, func) & " MFHI   r[" & tostrd( regC ) & "] = s->hi;";
		      	when "010001" =>  return intr2_code(op, func) & " MTHI   s->hi = r[" & tostrd( regC ) & "];";
		      	when "010010" =>  return intr2_code(op, func) & " MFLO   r[" & tostrd( regC ) & "] = s->lo;";
		      	when "010011" =>  return intr2_code(op, func) & " MTLO   s->lo = r[" & tostrd( regC ) & "];";
				-- when "010100" =>
				-- when "010101" =>
				-- when "010110" =>
				-- when "010111" =>
      			when "011000" =>  return intr2_code(op, func) & " MULT   s->lo = r[" & tostrd( regC ) & "] * r[" & tostrd( regB ) & "]; s->hi=0;\n";
  			    	when "011001" =>  return intr2_code(op, func) & " MULTU  s->lo = r[" & tostrd( regC ) & "] * r[" & tostrd( regB ) & "]; s->hi=0;\n";
   		   	when "011010" =>  return intr2_code(op, func) & " DIV    s->lo = r[" & tostrd( regC ) & "] / r[" & tostrd( regB ) & "]; s->hi=r[" & tostrd( regC ) & "]%r[" & tostrd( regB ) & "];";
  		   	 	when "011011" =>  return intr2_code(op, func) & " DIVU   s->lo = r[" & tostrd( regC ) & "] / r[" & tostrd( regB ) & "]; s->hi=r[" & tostrd( regC ) & "]%r[" & tostrd( regB ) & "];";
				-- when "011100" =>
				-- when "011101" =>
				-- when "011110" =>
				-- when "011111" =>
   		   	when "100000" =>  return intr2_code(op, func) & " ADD    r[" & tostrd( regC ) & "] = r[" & tostrd( regC ) & "]   + r[" & tostrd( regB ) & "];";
   		   	when "100001" =>  return intr2_code(op, func) & " ADDU   r[" & tostrd( regC ) & "] = r[" & tostrd( regC ) & "]   + r[" & tostrd( regB ) & "];";
   		   	when "100010" =>  return intr2_code(op, func) & " SUB    r[" & tostrd( regC ) & "] = r[" & tostrd( regC ) & "]   - r[" & tostrd( regB ) & "];";
   		   	when "100011" =>  return intr2_code(op, func) & " SUBU   r[" & tostrd( regC ) & "] = r[" & tostrd( regC ) & "]   - r[" & tostrd( regB ) & "];";
   		   	when "100100" =>  return intr2_code(op, func) & " AND    r[" & tostrd( regC ) & "] = r[" & tostrd( regC ) & "]   & r[" & tostrd( regB ) & "];";
   		   	when "100101" =>  return intr2_code(op, func) & " OR     r[" & tostrd( regC ) & "] = r[" & tostrd( regC ) & "]   | r[" & tostrd( regB ) & "];";
   		   	when "100110" =>  return intr2_code(op, func) & " XOR    r[" & tostrd( regC ) & "] = r[" & tostrd( regC ) & "]   ^ r[" & tostrd( regB ) & "];";
  			    	when "100111" =>  return intr2_code(op, func) & " NOR    r[" & tostrd( regC ) & "] = ~(r[" & tostrd( regC ) & "] | r[" & tostrd( regB ) & "]);";
				-- when "101000" =>
				-- when "101001" =>
   		   	when "101010" =>  return intr2_code(op, func) & " SLT    r[" & tostrd( regC ) & "] = r[" & tostrd( regC ) & "]   < r[" & tostrd( regB ) & "];";
   		   	when "101011" =>  return intr2_code(op, func) & " SLTU   r[" & tostrd( regC ) & "] = u[" & tostrd( regC ) & "]   < u[" & tostrd( regB ) & "];";
				-- when "101100" =>
  			    	when "101101" =>  return intr2_code(op, func) & " DADDU  r[" & tostrd( regC ) & "] = r[" & tostrd( regC ) & "]   + u[" & tostrd( regB ) & "];";
				-- when "101110" =>
				-- when "101111" =>
				-- when "110000" =>
			      when "110001" =>  return intr2_code(op, func) & " TGEU";
  			 	   when "110010" =>  return intr2_code(op, func) & " TLT";
  			 	   when "110011" =>  return intr2_code(op, func) & " TLTU";
  			 	   when "110100" =>  return intr2_code(op, func) & " TEQ ";
				-- when "110101" =>
  			 	   when "110110" =>  return intr2_code(op, func) & " TNE ";
				-- when "110111" =>
				-- when "111000" =>
				-- when "111001" =>
				-- when "111010" =>
				-- when "111011" =>
				-- when "111100" =>
				-- when "111101" =>
				-- when "111110" =>
				-- when "111111" =>
	      		when others   =>  return intr2_code(op, func) & " UNKNOW INSTRUCTION (1)";
											ASSERT false REPORT "ON LANCE UN CRASH VOLONTAIRE (INSTR = CRASH)" SEVERITY FAILURE;
   		   end case;
   		when "000001" =>   --REGIMM
      		case rtx is
      			when "10000" =>  return intr2_code(op, rtx) & " BLTZAL  r[31] = s->pc_next; branch=r[" & tostrd( regC ) & "] < 0;";
      			when "00000" =>  return intr2_code(op, rtx) & " BLTZ    branch=r[" & tostrd( regC ) & "]<0;";
      			when "10001" =>  return intr2_code(op, rtx) & " BGEZAL  r[31] = s->pc_next; branch=r[" & tostrd( regC ) & "] >= 0;";
      			when "00001" =>  return intr2_code(op, rtx) & " BGEZ    branch=r[" & tostrd( regC ) & "]>=0;";
	      		when "10010" =>  return intr2_code(op, rtx) & " BLTZALL r[31] = s->pc_next; lbranch=r[" & tostrd( regC ) & "] < 0;";
	      		when "00010" =>  return intr2_code(op, rtx) & " BLTZL   lbranch = r[" & tostrd( regC ) & "]<0;";
	      		when "10011" =>  return intr2_code(op, rtx) & " BGEZALL r[31] = s->pc_next; lbranch=r[" & tostrd( regC ) & "] >= 0;";
	      		when "00011" =>  return intr2_code(op, rtx) & " BGEZL   lbranch = r[" & tostrd( regC ) & "] >= 0;";
	      		when others  =>  return intr2_code(op, rtx) & " UNKNOW INSTRUCTION (2)";
										  ASSERT false REPORT "ON LANCE UN CRASH VOLONTAIRE (INSTR = CRASH)" SEVERITY FAILURE;
      		end case;

   		when "000010" =>  return intr_code(op) & " J      s->pc_next=(s->pc&0xf0000000)| " & tostrd ( to_integer(unsigned(target)) ) & ";"; --target;";
   		when "000011" =>  return intr_code(op) & " JAL    r[31]=s->pc_next; s->pc_next=(s->pc&0xf0000000)| "& tostrd ( to_integer(unsigned(target)) ) & ";"; --target;";
   		when "000100" =>  return intr_code(op) & " BEQ    branch = r[" & tostrd( regC ) & "] == r[" & tostrd( regB ) & "];";
   		when "000101" =>  return intr_code(op) & " BNE    branch = r[" & tostrd( regC ) & "] != r[" & tostrd( regB ) & "];";
   		when "000110" =>  return intr_code(op) & " BLEZ   branch = r[" & tostrd( regC ) & "] <= 0;";
   		when "000111" =>  return intr_code(op) & " BGTZ   branch = r[" & tostrd( regC ) & "] > 0;";
   		when "001000" =>  return intr_code(op) & " ADDI   r[" & tostrd( regB ) & "]  = r[" & tostrd( regC ) & "] + (short)" & tostrd ( to_integer(signed(imm)) ) & ";";
   		when "001001" =>  return intr_code(op) & " ADDIU  u[" & tostrd( regB ) & "]  = u[" & tostrd( regC ) & "] + (short)" & tostrud( to_integer(signed(imm)) ) & ";";
   		when "001010" =>  return intr_code(op) & " SLTI   r[" & tostrd( regB ) & "]  = r[" & tostrd( regC ) & "] < (short)" & tostrd ( to_integer(signed(imm)) ) & ";";
   		when "001011" =>  return intr_code(op) & " SLTIU  u[" & tostrd( regB ) & "]  = u[" & tostrd( regC ) & "] < (unsigned long)(short)" & tostrud( to_integer(signed(imm)) ) & ";";
   		when "001100" =>  return intr_code(op) & " ANDI   r[" & tostrd( regB ) & "]  = r[" & tostrd( regC ) & "] & " & tostrud( to_integer(signed(imm)) ) & ";";
   		when "001101" =>  return intr_code(op) & " ORI    r[" & tostrd( regB ) & "]  = r[" & tostrd( regC ) & "] | " & tostrud( to_integer(signed(imm)) ) & ";";
   		when "001110" =>  return intr_code(op) & " XORI   r[" & tostrd( regB ) & "]  = r[" & tostrd( regC ) & "] ^ " & tostrud( to_integer(signed(imm)) ) & ";";
   		when "001111" =>  return intr_code(op) & " LUI    r[" & tostrd( regB ) & "]  = (" & tostrud( to_integer(signed(imm)) ) & " << 16);";
   		when "010000" =>  return intr_code(op) & " COP0";
	   	when "010001" =>  return intr_code(op) & " COP1";
	   	when "010010" =>  return intr_code(op) & " COP2";
	   	when "010011" =>  return intr_code(op) & " COP3";
	   	when "010100" =>  return intr_code(op) & " BEQL   lbranch=r[" & tostrd( regC ) & "] == r[" & tostrd( regB ) & "];";
	   	when "010101" =>  return intr_code(op) & " BNEL   lbranch=r[" & tostrd( regC ) & "] != r[" & tostrd( regB ) & "];";
	   	when "010110" =>  return intr_code(op) & " BLEZL  lbranch=r[" & tostrd( regC ) & "] <= 0;";
	  		when "010111" =>  return intr_code(op) & " BGTZL  lbranch=r[" & tostrd( regC ) & "] >  0;";
		-- when "011000" =>
		-- when "011001" =>
		-- when "011010" =>
		-- when "011011" =>
		-- when "011100" =>
		-- when "011101" =>
		-- when "011110" =>
		-- when "011111" =>
	   	when "100000" =>  return intr_code(op) & " LB     r[" & tostrd( regB ) & "] =* (signed char*)ptr;";
	   	when "100001" =>  return intr_code(op) & " LH     r[" & tostrd( regB ) & "] =* (signed short*)ptr;";
	   	when "100010" =>  return intr_code(op) & " LWL    //Not Implemented";
	   	when "100011" =>  return intr_code(op) & " LW     r[" & tostrd( regB ) & "] =* (long*)ptr;";
	   	when "100100" =>  return intr_code(op) & " LBU    r[" & tostrd( regB ) & "] =* (unsigned char*)ptr;";
	   	when "100101" =>  return intr_code(op) & " LHU    r[" & tostrd( regB ) & "] =* (unsigned short*)ptr;";
	   	when "100110" =>  return intr_code(op) & " LWR    //Not Implemented";
		-- when "100111" =>
	   	when "101000" =>  return intr_code(op) & " SB     *(char*) ptr = (char)r[" & tostrd( regB ) & "];";
	   	when "101001" =>  return intr_code(op) & " SH     *(short*)ptr = (short)r[" & tostrd( regB ) & "];";
	   	when "101010" =>  return intr_code(op) & " SWL    //Not Implemented";
--   		when "101011" =>  return intr_code(op) & " SW     *(long*) ptr = r[" & tostrd( regB ) & "];";
   		when "101011" =>  return intr_code(op) & " SW     *(long*) r[" & tostrd( regC ) & "] + (" & tostrd ( to_integer(signed(imm)) ) & ") = r[" & tostrd( regB ) & "];";
   		when "101110" =>  return intr_code(op) & " SWR    //Not Implemented";
   		when "101111" =>  return intr_code(op) & " CACHE";
   		when "110000" =>  return intr_code(op) & " LL     r[" & tostrd( regB ) & "]=*(long*)ptr;";
   		when "110001" =>  return intr_code(op) & " LWC1";
   		when "110010" =>  return intr_code(op) & " LWC2";
   		when "110011" =>  return intr_code(op) & " LWC3";
   		when "110101" =>  return intr_code(op) & " LDC1";
   		when "110110" =>  return intr_code(op) & " LDC2"; 
   		when "110111" =>  return intr_code(op) & " LDC3";
   		when "111000" =>  return intr_code(op) & " SC     *(long*)ptr=r[" & tostrd( regB ) & "]; r[" & tostrd( regB ) & "]=1;";
   		when "111001" =>  return intr_code(op) & " SWC1";
   		when "111010" =>  return intr_code(op) & " SWC2";
   		when "111011" =>  return intr_code(op) & " SWC3"; 
   		when "111101" =>  return intr_code(op) & " SDC1";
   		when "111110" =>  return intr_code(op) & " SDC2"; 
   		when "111111" =>  return intr_code(op) & " SDC3";
	     	when others  =>   return intr_code(op) & " UNKNOW INSTRUCTION (3) " & bin_char(op);
   	end case;
	return "- UNKNOW INSTRUCTION (4)";
end;
-- synthesis_on

	SIGNAL last_pc_addr : std_logic_vector(31 downto 2);
begin

	-- synthesis_off
	control_logger: process( clk ) 
         file store_file          : text open write_mode is "assembler.log";
         variable hex_file_line   : line;
         variable hex_output_line : line;				-- BLG
	      variable l:                line;
      	variable comment: string(1 to 1024);
	begin
		if (clk'event) and (clk='1') then
			if pause = '0' then
				last_pc_addr <= pc_addr;
				if reset = '0' then
					write(l, now, right, 15);
					write(l, " : " & "@dr = " & tostf(last_pc_addr & "00") & " - " & ins2st( opcode ));
					WRITEline(output, l);
				end if;
			end if;
		else
			-- NOTHING TO DO...
		end if;
	end process;
	-- synthesis_on

end; --architecture logic
