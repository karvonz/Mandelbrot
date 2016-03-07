----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.03.2016 11:43:23
-- Design Name: 
-- Module Name: FSM - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use work.constants.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FSM is
    Port ( clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           done : in STD_LOGIC;
           start : out STD_LOGIC;
           x : out STD_LOGIC_VECTOR (xdata-1 downto 0);
           y : out STD_LOGIC_VECTOR (ydata-1 downto 0));
           gqdfgq
end FSM;

architecture Behavioral of FSM is

begin


end Behavioral;
