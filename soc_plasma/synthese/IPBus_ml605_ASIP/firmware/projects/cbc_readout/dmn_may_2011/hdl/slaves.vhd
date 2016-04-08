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
	scl_o: out std_logic;
	sda_enb: out std_logic;
	sda_i: in std_logic;
	cbc_scl_o: out std_logic;
	cbc_sda_i: in std_logic;
	cbc_sda_o: out std_logic);

end slaves;

architecture rtl of slaves is

	constant NSLV: positive := 4;
	signal ipbw: ipb_wbus_array(NSLV-1 downto 0);
	signal ipbr, ipbr_d: ipb_rbus_array(NSLV-1 downto 0);
	signal dummy: std_logic_vector(31 downto 0); -- arghh, VHDL
	signal scl, cbc_scl: std_logic;

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
			q => open);
			
-- Slave 2: i2c

	slave2: entity work.i2c_master_top port map(
		wb_clk_i => ipb_clk,
		wb_rst_i => rst,
		arst_i => '1',
		wb_adr_i => ipbw(2).ipb_addr(2 downto 0),
		wb_dat_i => ipbw(2).ipb_wdata(7 downto 0),
		wb_dat_o => ipbr(2).ipb_rdata(7 downto 0),
		wb_we_i => ipbw(2).ipb_write,
		wb_stb_i => ipbw(2).ipb_strobe,
		wb_cyc_i => '1',
		wb_ack_o => ipbr(2).ipb_ack,
		wb_inta_o => open,
		scl_pad_i => scl,
		scl_pad_o => open,
		scl_padoen_o => scl,
		sda_pad_i => sda_i,
		sda_pad_o => open,
		sda_padoen_o => sda_enb
	);

	scl_o <= scl;
		
	ipbr(2).ipb_err <= '0';

-- Slave 3: i2c

	slave3: entity work.i2c_master_top port map(
		wb_clk_i => ipb_clk,
		wb_rst_i => rst,
		arst_i => '1',
		wb_adr_i => ipbw(3).ipb_addr(2 downto 0),
		wb_dat_i => ipbw(3).ipb_wdata(7 downto 0),
		wb_dat_o => ipbr(3).ipb_rdata(7 downto 0),
		wb_we_i => ipbw(3).ipb_write,
		wb_stb_i => ipbw(3).ipb_strobe,
		wb_cyc_i => '1',
		wb_ack_o => ipbr(3).ipb_ack,
		wb_inta_o => open,
		scl_pad_i => cbc_scl,
		scl_pad_o => open,
		scl_padoen_o => cbc_scl,
		sda_pad_i => cbc_sda_i,
		sda_pad_o => open,
		sda_padoen_o => cbc_sda_o
	);

	cbc_scl_o <= cbc_scl;
		
	ipbr(2).ipb_err <= '0';

end rtl;
