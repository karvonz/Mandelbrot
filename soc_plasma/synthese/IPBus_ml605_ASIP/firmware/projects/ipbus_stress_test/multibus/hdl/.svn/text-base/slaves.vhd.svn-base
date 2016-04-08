-- The ipbus slaves live in this entity - modify according to requirements
--
-- Ports can be added to give ipbus slaves access to the chip top level.
--
-- Dave Newbold, February 2011

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.ALL;

entity slaves is port(
	ipb_clk, rst : in STD_LOGIC;
	ipb_in : in ipb_wbus;
	ipb_out : out ipb_rbus;
-- Top level ports from here
	gpio : out STD_LOGIC_VECTOR(3 downto 0)
	);

end slaves;

architecture rtl of slaves is

	constant NSLV: positive := 2;
	signal ipbw: ipb_wbus_array(NSLV-1 downto 0);
	signal ipbr, ipbr_d: ipb_rbus_array(NSLV-1 downto 0);
	signal dummy: std_logic_vector(31 downto 0); -- arghh, VHDL

begin

  fabric: entity work.ipbus_fabric
    generic map(NSLV => NSLV)
    port map(
      ipb_clk => ipb_clk,
      rst => rst,
      ipb_in => ipb_in,
      ipb_out => ipb_out,
      ipb_to_slaves => ipbw,
      ipb_from_slaves => ipbr
    );

-- Slave 0: fixed constant

	ipbr(0).ipb_rdata <= X"deadbeef";
	ipbr(0).ipb_ack <= ipbw(0).ipb_strobe;
	ipbr(0).ipb_err <= '0';

-- Slave 1: 32b register

	slave1: entity work.ipbus_reg
		generic map(addr_width => 0)
		port map(
			clk => ipb_clk,
			reset => rst,
			ipbus_in => ipbw(1),
			ipbus_out => ipbr(1),
			q(3 downto 0) => gpio,
			q(31 downto 4) => dummy(31 downto 4));
			
end rtl;


