----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:59:20 05/21/2016 
-- Design Name: 
-- Module Name:    mux - Behavioral 
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use work.CONSTANTS.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use work.CONSTANTS.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity muxperso is
    Port ( ADDR1 : in  STD_LOGIC_vector(ADDR_BIT_MUX-1 downto 0);
           data_write1 : in  STD_LOGIC;
           data_in1 : in  STD_LOGIC_VECTOR(ITER_RANGE-1 downto 0);
			  ADDR2 : in  STD_LOGIC_vector(ADDR_BIT_MUX-1 downto 0);
           data_write2 : in  STD_LOGIC;
           data_in2 : in  STD_LOGIC_VECTOR(ITER_RANGE-1 downto 0);
--			  ADDR3 : in  STD_LOGIC_vector(ADDR_BIT_MUX-1 downto 0);
--           data_write3 : in  STD_LOGIC;
--           data_in3 : in  STD_LOGIC_VECTOR(ITER_RANGE-1 downto 0);
--			  ADDR4 : in  STD_LOGIC_vector(ADDR_BIT_MUX-1 downto 0);
--           data_write4 : in  STD_LOGIC;
--           data_in4 : in  STD_LOGIC_VECTOR(ITER_RANGE-1 downto 0);
			  ADDR : out  STD_LOGIC_vector(ADDR_BIT-1 downto 0);
			  data_write : out STD_LOGIC;
			  data_out : out STD_LOGIC_VECTOR(ITER_RANGE-1 downto 0)); 
end muxperso;

architecture Behavioral of muxperso is

begin
ADDR<= std_logic_vector( unsigned("00" & ADDR1) + to_unsigned(38400, ADDR_BIT)) when (data_write1 = '1') else std_logic_vector(unsigned("00" & ADDR2) + to_unsigned(38400, ADDR_BIT)) ;
data_out<=data_in1 when(data_write1 = '1') else data_in2;
data_write<='1' when (data_write1 = '1') else data_write2;
end Behavioral;

