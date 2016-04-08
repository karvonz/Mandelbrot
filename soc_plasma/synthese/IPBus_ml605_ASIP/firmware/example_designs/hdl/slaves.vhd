-- The ipbus slaves live in this entity - modify according to requirements
--
-- Ports can be added to give ipbus slaves access to the chip top level.
--
-- Dave Newbold, February 2011

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.ALL;
use work.bus_arb_decl.all;

entity slaves is port(
	ipb_clk, rst : in STD_LOGIC;
	i_uart  : in STD_LOGIC;
	o_uart  : out STD_LOGIC;
	ipb_in  : in ipb_wbus;
	ipb_out : out ipb_rbus;
-- Top level ports from here
	gpio : out STD_LOGIC_VECTOR(7 downto 0);
	oob_moti: out trans_moti;
	oob_tomi: in trans_tomi
	);

end slaves;

architecture rtl of slaves is

	CONSTANT NSLV: positive := 4;
	SIGNAL ipbw: ipb_wbus_array(NSLV-1 downto 0);
	SIGNAL ipbr, ipbr_d: ipb_rbus_array(NSLV-1 downto 0);
	SIGNAL dummy: std_logic_vector(31 downto 0); -- arghh, VHDL

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

-- Slave 0: firmware ID etc

  slave0: entity work.ipbus_ver
    port map(
      ipbus_in => ipbw(0),
      ipbus_out => ipbr(0));

-- Slave 1: 32b register

	slave1: entity work.ipbus_reg
		generic map(addr_width => 0)
		port map(
			clk => ipb_clk,
			reset => rst,
			ipbus_in => ipbw(1),
			ipbus_out => ipbr(1),
			q(3 downto 0) => dummy(3 downto 0),
			q(31 downto 4) => dummy(31 downto 4));
			
-- Slave 2: 4k word RAM
--	slave2: entity work.ipbus_ram
--		generic map(addr_width => 12)
--		port map(
--			clk => ipb_clk,
--			reset => rst,
--			ipbus_in => ipbw(2),
--			ipbus_out => ipbr(2));
			
-- Slave 3: bus counter

	slave3: entity work.ipbus_ldpc_asip_v2
		generic map(addr_width => 12)
		port map(
			clk       => ipb_clk,
			reset     => rst,
			i_uart    => i_uart,
			o_uart    => o_uart,
			gpio      => gpio,
			ipbus_in  => ipbw(3),
			ipbus_out => ipbr(3)
		);

--	slave3: entity work.ipbus_ctr
--		port map(
--			clk => ipb_clk,
--			reset => rst,
--			ipbus_in => ipbw(3),
--			ipbus_out => ipbr(3));
			
-- Slave 4: OOB test block

--  slave4: entity work.ipbus_oob_test
--    port map(
--    clk => ipb_clk,
--      reset => rst,
--      ipbus_in => ipbw(4),
--      ipbus_out => ipbr(4),
--      moti => oob_moti,
--      tomi => oob_tomi);

end rtl;


