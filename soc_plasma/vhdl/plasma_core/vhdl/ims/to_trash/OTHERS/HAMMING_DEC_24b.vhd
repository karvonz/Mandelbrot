----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:04:29 02/20/2011 
-- Design Name: 
-- Module Name:    hamming_decoder_26bit - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity hamming_decoder_26b is
	port (
		INPUT_1  : in  STD_LOGIC_VECTOR(31 downto 0);
		OUTPUT_1 : out STD_LOGIC_VECTOR(31 downto 0)
	);
end hamming_decoder_26b;

architecture Behavioral of hamming_decoder_26b is

	SUBTYPE parity_ham_26bit IS std_logic_vector(5 DOWNTO 0);
	SUBTYPE data_ham_26bit IS std_logic_vector(25 DOWNTO 0);
	SUBTYPE coded_ham_26bit IS std_logic_vector(31 DOWNTO 0);

---------------------
-- HAMMING DECODER --
---------------------
PROCEDURE hamming_decoder_26bit(data_parity_in:coded_ham_26bit;
	SIGNAL error_out     : OUT std_logic_vector(1 DOWNTO 0);
	SIGNAL decoded       : OUT data_ham_26bit) IS

	VARIABLE coded       : coded_ham_26bit;
	VARIABLE syndrome    : integer RANGE 0 TO 31;
	VARIABLE parity      : parity_ham_26bit;
	VARIABLE parity_in   : parity_ham_26bit;
	VARIABLE syn         : parity_ham_26bit;
	VARIABLE data_in     : data_ham_26bit;
	VARIABLE P0, P1      : std_logic;
BEGIN

	data_in   := data_parity_in(31 DOWNTO 6);
	parity_in := data_parity_in(5 DOWNTO 0);

	parity(5)	:=	data_in(11) XOR data_in(12) XOR data_in(13) XOR data_in(14) XOR data_in(15) XOR 
					data_in(16) XOR data_in(17) XOR data_in(18) XOR data_in(19) XOR data_in(20) XOR 
					data_in(21) XOR data_in(22) XOR data_in(23) XOR data_in(24) XOR data_in(25);
   
					
	parity(4)	:=	data_in(4) XOR data_in(5) XOR data_in(6) XOR data_in(7) XOR data_in(8) XOR 
					data_in(9) XOR data_in(10) XOR data_in(18) XOR data_in(19) XOR data_in(20) XOR 
					data_in(21) XOR data_in(22) XOR data_in(23) XOR data_in(24) XOR data_in(25);
   
					
	parity(3)	:=	data_in(1) XOR data_in(2) XOR data_in(3) XOR data_in(7) XOR data_in(8) XOR 
					data_in(9) XOR data_in(10) XOR data_in(14) XOR data_in(15) XOR data_in(16) XOR 
					data_in(17) XOR data_in(22) XOR data_in(23) XOR data_in(24) XOR data_in(25);
   
					
	parity(2)	:=	data_in(0) XOR data_in(2) XOR data_in(3) XOR data_in(5) XOR data_in(6) XOR 
					data_in(9) XOR data_in(10) XOR data_in(12) XOR data_in(13) XOR data_in(16) XOR 
					data_in(17) XOR data_in(20) XOR data_in(21) XOR data_in(24) XOR data_in(25);
   
					
	parity(1)	:=	data_in(0) XOR data_in(1) XOR data_in(3) XOR data_in(4) XOR data_in(6) XOR 
					data_in(8) XOR data_in(10) XOR data_in(11) XOR data_in(13) XOR data_in(15) XOR 
					data_in(17) XOR data_in(19) XOR data_in(21) XOR data_in(23) XOR data_in(25);
   
					
	parity(0)	:=	data_in(0) XOR data_in(1) XOR data_in(2) XOR data_in(3) XOR data_in(4) XOR 
					data_in(5) XOR data_in(6) XOR data_in(7) XOR data_in(8) XOR data_in(9) XOR 
					data_in(10) XOR data_in(11) XOR data_in(12) XOR data_in(13) XOR data_in(14) XOR 
					data_in(15) XOR data_in(16) XOR data_in(17) XOR data_in(18) XOR data_in(19) XOR 
					data_in(20) XOR data_in(21) XOR data_in(22) XOR data_in(23) XOR data_in(24) XOR 
					data_in(25) XOR parity(1) XOR parity(2) XOR parity(3) XOR parity(4) XOR 
					parity(5) ;

	coded(0)	:=	data_parity_in(0);
	coded(1)	:=	data_parity_in(1);
	coded(2)	:=	data_parity_in(2);
	coded(4)	:=	data_parity_in(3);
	coded(8)	:=	data_parity_in(4);
	coded(16)	:=	data_parity_in(5);
	coded(3)	:=	data_parity_in(6);
	coded(5)	:=	data_parity_in(7);
	coded(6)	:=	data_parity_in(8);
	coded(7)	:=	data_parity_in(9);
	coded(9)	:=	data_parity_in(10);
	coded(10)	:=	data_parity_in(11);
	coded(11)	:=	data_parity_in(12);
	coded(12)	:=	data_parity_in(13);
	coded(13)	:=	data_parity_in(14);
	coded(14)	:=	data_parity_in(15);
	coded(15)	:=	data_parity_in(16);
	coded(17)	:=	data_parity_in(17);
	coded(18)	:=	data_parity_in(18);
	coded(19)	:=	data_parity_in(19);
	coded(20)	:=	data_parity_in(20);
	coded(21)	:=	data_parity_in(21);
	coded(22)	:=	data_parity_in(22);
	coded(23)	:=	data_parity_in(23);
	coded(24)	:=	data_parity_in(24);
	coded(25)	:=	data_parity_in(25);
	coded(26)	:=	data_parity_in(26);
	coded(27)	:=	data_parity_in(27);
	coded(28)	:=	data_parity_in(28);
	coded(29)	:=	data_parity_in(29);
	coded(30)	:=	data_parity_in(30);
	coded(31)	:=	data_parity_in(31);

	-- syndorme generation
	syn(5 DOWNTO 1) := parity(5 DOWNTO 1) XOR parity_in(5 DOWNTO 1);
	P0 := '0';
	P1 := '0';
	FOR i IN 0 TO 5 LOOP
		P0 := P0 XOR parity(i);
		P1 := P1 XOR parity_in(i);
	END LOOP;
	syn(0) := P0 XOR P1;

	CASE syn(5 DOWNTO 1) IS
		WHEN "00011" => syndrome := 3;
		WHEN "00101" => syndrome := 5;
		WHEN "00110" => syndrome := 6;
		WHEN "00111" => syndrome := 7;
		WHEN "01001" => syndrome := 9;
		WHEN "01010" => syndrome := 10;
		WHEN "01011" => syndrome := 11;
		WHEN "01100" => syndrome := 12;
		WHEN "01101" => syndrome := 13;
		WHEN "01110" => syndrome := 14;
		WHEN "01111" => syndrome := 15;
		WHEN "10001" => syndrome := 17;
		WHEN "10010" => syndrome := 18;
		WHEN "10011" => syndrome := 19;
		WHEN "10100" => syndrome := 20;
		WHEN "10101" => syndrome := 21;
		WHEN "10110" => syndrome := 22;
		WHEN "10111" => syndrome := 23;
		WHEN "11000" => syndrome := 24;
		WHEN "11001" => syndrome := 25;
		WHEN "11010" => syndrome := 26;
		WHEN "11011" => syndrome := 27;
		WHEN "11100" => syndrome := 28;
		WHEN "11101" => syndrome := 29;
		WHEN "11110" => syndrome := 30;
		WHEN "11111" => syndrome := 31;
		WHEN OTHERS =>  syndrome := 0;
	END CASE;

	IF syn(0) = '1'  THEN
		coded(syndrome) := NOT(coded(syndrome));
		error_out <= "01";    -- There is an error
	ELSIF syndrome/= 0 THEN     -- There are more than one error
		coded := (OTHERS => '0');-- FATAL ERROR
		error_out <= "11";
	ELSE
		error_out <= "00"; -- No errors detected
	END IF;
	decoded(0)	<=	coded(3);
	decoded(1)	<=	coded(5);
	decoded(2)	<=	coded(6);
	decoded(3)	<=	coded(7);
	decoded(4)	<=	coded(9);
	decoded(5)	<=	coded(10);
	decoded(6)	<=	coded(11);
	decoded(7)	<=	coded(12);
	decoded(8)	<=	coded(13);
	decoded(9)	<=	coded(14);
	decoded(10)	<=	coded(15);
	decoded(11)	<=	coded(17);
	decoded(12)	<=	coded(18);
	decoded(13)	<=	coded(19);
	decoded(14)	<=	coded(20);
	decoded(15)	<=	coded(21);
	decoded(16)	<=	coded(22);
	decoded(17)	<=	coded(23);
	decoded(18)	<=	coded(24);
	decoded(19)	<=	coded(25);
	decoded(20)	<=	coded(26);
	decoded(21)	<=	coded(27);
	decoded(22)	<=	coded(28);
	decoded(23)	<=	coded(29);
	decoded(24)	<=	coded(30);
	decoded(25)	<=	coded(31);

END;

	SIGNAL error_out : std_logic_vector(1 DOWNTO 0);
	SIGNAL decoded   : std_logic_vector(25 DOWNTO 0);

begin

	PROCESS(INPUT_1,error_out,decoded)
	BEGIN
		hamming_decoder_26bit( INPUT_1, error_out, decoded);
		OUTPUT_1 <= "0000" & error_out & decoded;
	END PROCESS;

end Behavioral;

