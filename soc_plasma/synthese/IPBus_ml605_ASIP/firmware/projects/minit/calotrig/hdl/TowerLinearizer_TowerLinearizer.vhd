----------------------------------------------------------------------------------
-- company: 
-- engineer: 
-- 
-- create date:    15:00:28 03/09/2010 
-- design name: 
-- module name:    towerlinearizer - towerlinearizer 
-- project name: 
-- target devices: 
-- tool versions: 
-- description: 
--
-- dependencies: 
--
-- revision: 
-- revision 0.01 - file created
-- additional comments: 
--
----------------------------------------------------------------------------------
library ieee;
library tmcalotrigger_lib;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use tmcalotrigger_lib.constants.all;
use tmcalotrigger_lib.types.all;
use tmcalotrigger_lib.linkinterface.all;

---- uncomment the following library declaration if instantiating
---- any xilinx primitives in this code.
library unisim;
use unisim.vcomponents.all;

entity towerlinearizer is
	port(
		async_reset:		in	std_logic := '1';
		clk:				in	std_logic := '0';
		ecallut_address:	in	std_logic_vector( 9 downto 0 );
		ecallut_data:		in	std_logic_vector( 15 downto 0 );
		ecallut_clk:		in	std_logic;
		ecallut_enable:		in	std_logic;
		hcallut_address:	in	std_logic_vector( 9 downto 0 );
		hcallut_data:		in	std_logic_vector( 15 downto 0 );
		hcallut_clk:		in	std_logic;
		hcallut_enable:		in	std_logic;
		link_in:			in	link_type;
		linearized_towers:	out tlineartowers
	);
end towerlinearizer;





architecture v5 of towerlinearizer is

	signal ecallut_address_in , hcallut_address_in : std_logic_vector( 13 downto 0 );

	signal a_in , b_in , c_in , d_in : std_logic_vector( 13 downto 0 );
	signal a_out , b_out , c_out , d_out : std_logic_vector( 15 downto 0 );
	signal	not_ecallut_enable , not_hcallut_enable	:	std_logic;
	
begin
		
	a_in <= "000000" & link_in.data( 7 downto 0 );
	b_in <= "000000" & link_in.data( 15 downto 8 );
	c_in <= "000000" & link_in.data( 23 downto 16 );
	d_in <= "000000" & link_in.data( 31 downto 24 );

	ecallut_address_in <= "0000"&ecallut_address;
	hcallut_address_in <= "0000"&hcallut_address;
	
	not_ecallut_enable <= not (async_reset and ecallut_enable );
	not_hcallut_enable <= not (async_reset and hcallut_enable );
	
	alut: ramb18
        generic map(
          sim_collision_check => "NONE",
          -- init_file => "linearizer-init-values.txt",
          init_00 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_01 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_02 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_03 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_04 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_05 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_06 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_07 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_08 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_09 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_0a => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_0b => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_0c => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_0d => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_0e => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_0f => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_10 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_11 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_12 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_13 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_14 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_15 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_16 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_17 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_18 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_19 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_1a => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_1b => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_1c => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_1d => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_1e => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_1f => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_20 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_21 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_22 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_23 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_24 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_25 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_26 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_27 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_28 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_29 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_2a => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_2b => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_2c => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_2d => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_2e => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_2f => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_30 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_31 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_32 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_33 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_34 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_35 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_36 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_37 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_38 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_39 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_3a => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_3b => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_3c => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_3d => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_3e => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_3f => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          read_width_a => 18,
	  read_width_b => 18)
	port map(
		 --doa : out std_logic_vector(15 downto 0);
		 dob	=> a_out,
		 --dopa : out std_logic_vector(1 downto 0);
		 --dopb : out std_logic_vector(1 downto 0);
		 addra	=> ecallut_address_in,
		 addrb	=> a_in,
		 clka	=> ecallut_clk,
		 clkb	=> clk,
		 dia	=> ecallut_data,
		 dib	=> (others=>'0'),
		 dipa	=> (others=>'0'),
		 dipb	=> (others=>'0'),
		 ena 	=> ecallut_enable,
		 enb 	=> not_ecallut_enable ,
		 regcea => '1',
		 regceb => '1',		 
		 ssra	=> '0' ,
		 ssrb	=> '0' ,
		 wea	=> "11",
		 web	=> "00" 
	);

	blut: ramb18
        generic map(
          sim_collision_check => "NONE",
          -- init_file => "linearizer-init-values.txt",
          init_00 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_01 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_02 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_03 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_04 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_05 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_06 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_07 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_08 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_09 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_0a => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_0b => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_0c => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_0d => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_0e => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_0f => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_10 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_11 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_12 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_13 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_14 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_15 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_16 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_17 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_18 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_19 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_1a => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_1b => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_1c => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_1d => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_1e => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_1f => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_20 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_21 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_22 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_23 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_24 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_25 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_26 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_27 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_28 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_29 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_2a => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_2b => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_2c => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_2d => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_2e => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_2f => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_30 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_31 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_32 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_33 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_34 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_35 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_36 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_37 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_38 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_39 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_3a => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_3b => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_3c => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_3d => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_3e => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_3f => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          read_width_a => 18,
	  read_width_b => 18)
	port map(
		 --doa : out std_logic_vector(15 downto 0);
		 dob	=> b_out,
		 --dopa : out std_logic_vector(1 downto 0);
		 --dopb : out std_logic_vector(1 downto 0);
		 addra	=> ecallut_address_in,
		 addrb	=> b_in,
		 clka	=> ecallut_clk,
		 clkb	=> clk,
		 dia	=> ecallut_data,
		 dib	=> (others=>'0'),
		 dipa	=> (others=>'0'),
		 dipb	=> (others=>'0'),
		 ena 	=> ecallut_enable,
		 enb 	=> not_ecallut_enable,
		 regcea => '1',
		 regceb => '1',
		 ssra	=> '0',
		 ssrb	=> '0',
		 wea	=> "11",
		 web	=> "00" 
	);

	clut: ramb18
        generic map(
          sim_collision_check => "NONE",
          -- init_file => "linearizer-init-values.txt",
          init_00 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_01 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_02 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_03 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_04 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_05 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_06 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_07 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_08 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_09 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_0a => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_0b => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_0c => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_0d => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_0e => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_0f => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_10 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_11 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_12 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_13 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_14 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_15 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_16 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_17 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_18 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_19 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_1a => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_1b => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_1c => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_1d => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_1e => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_1f => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_20 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_21 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_22 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_23 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_24 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_25 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_26 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_27 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_28 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_29 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_2a => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_2b => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_2c => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_2d => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_2e => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_2f => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_30 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_31 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_32 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_33 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_34 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_35 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_36 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_37 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_38 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_39 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_3a => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_3b => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_3c => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_3d => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_3e => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_3f => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          read_width_a => 18,
	  read_width_b => 18)
	port map(
		 --doa : out std_logic_vector(15 downto 0);
		 dob	=> c_out,
		 --dopa : out std_logic_vector(1 downto 0);
		 --dopb : out std_logic_vector(1 downto 0);
		 addra	=> hcallut_address_in,
		 addrb	=> c_in,
		 clka	=> hcallut_clk,
		 clkb	=> clk,
		 dia	=> hcallut_data,
		 dib	=> (others=>'0'),
		 dipa	=> (others=>'0'),
		 dipb	=> (others=>'0'),
		 ena 	=> hcallut_enable,
		 enb 	=> not_hcallut_enable,
		 regcea => '1',
		 regceb => '1',
		 ssra	=> '0' ,
		 ssrb	=> '0' ,
		 wea	=> "11",
		 web	=> "00" 
	);

	dlut: ramb18
        generic map(
          sim_collision_check => "NONE",
          -- init_file => "linearizer-init-values.txt",
          init_00 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_01 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_02 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_03 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_04 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_05 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_06 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_07 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_08 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_09 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_0a => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_0b => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_0c => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_0d => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_0e => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_0f => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_10 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_11 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_12 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_13 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_14 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_15 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_16 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_17 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_18 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_19 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_1a => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_1b => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_1c => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_1d => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_1e => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_1f => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_20 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_21 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_22 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_23 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_24 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_25 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_26 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_27 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_28 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_29 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_2a => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_2b => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_2c => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_2d => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_2e => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_2f => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_30 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_31 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_32 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_33 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_34 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_35 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_36 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_37 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_38 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_39 => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_3a => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_3b => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_3c => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_3d => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_3e => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          init_3f => x"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
          read_width_a => 18,
	  read_width_b => 18)
	port map(
		 --doa : out std_logic_vector(15 downto 0);
		 dob	=> d_out,
		 --dopa : out std_logic_vector(1 downto 0);
		 --dopb : out std_logic_vector(1 downto 0);
		 addra	=> hcallut_address_in,
		 addrb	=> d_in,
		 clka	=> hcallut_clk,
		 clkb	=> clk,
		 dia	=> hcallut_data,
		 dib	=> (others=>'0'),
		 dipa	=> (others=>'0'),
		 dipb	=> (others=>'0'),
		 ena 	=> hcallut_enable,
		 enb 	=> not_hcallut_enable ,
		 regcea => '1',
		 regceb => '1',
		 ssra	=> '0' ,
		 ssrb	=> '0' ,
		 wea	=> "11",
		 web	=> "00" 
	);	

	linearized_towers.ecala <= a_out( clinearizedwidth-1 downto 0 );
	linearized_towers.ecalb <= b_out( clinearizedwidth-1 downto 0 );
	linearized_towers.hcala <= c_out( clinearizedwidth-1 downto 0 );
	linearized_towers.hcalb <= d_out( clinearizedwidth-1 downto 0 );

	
end v5;






architecture v6 of towerlinearizer is

	signal a_in , b_in , c_in , d_in : std_logic_vector( 9 downto 0 );
	signal a_out , b_out , c_out , d_out : std_logic_vector( 15 downto 0 );
	signal	not_ecallut_enable , not_hcallut_enable	:	std_logic;
	
begin
		
	a_in <= "00" & link_in.data( 7 downto 0 );
	b_in <= "00" & link_in.data( 15 downto 8 );
	c_in <= "00" & link_in.data( 23 downto 16 );
	d_in <= "00" & link_in.data( 31 downto 24 );

	not_ecallut_enable <= not (async_reset and ecallut_enable );
	not_hcallut_enable <= not (async_reset and hcallut_enable );
	
	alut: ramb16bwe_s18_s18
	port map(
		 --doa : out std_logic_vector(15 downto 0);
		 dob	=> a_out,
		 --dopa : out std_logic_vector(1 downto 0);
		 --dopb : out std_logic_vector(1 downto 0);
		 addra	=> ecallut_address,
		 addrb	=> a_in,
		 clka	=> ecallut_clk,
		 clkb	=> clk,
		 dia	=> ecallut_data,
		 dib	=> (others=>'0'),
		 dipa	=> (others=>'0'),
		 dipb	=> (others=>'0'),
		 ena 	=> ecallut_enable,
		 enb 	=> not_ecallut_enable ,
		 ssra	=> '0' ,
		 ssrb	=> '0' ,
		 wea	=> "11",
		 web	=> "00" 
	);

	blut: ramb16bwe_s18_s18
	port map(
		 --doa : out std_logic_vector(15 downto 0);
		 dob	=> b_out,
		 --dopa : out std_logic_vector(1 downto 0);
		 --dopb : out std_logic_vector(1 downto 0);
		 addra	=> ecallut_address,
		 addrb	=> b_in,
		 clka	=> ecallut_clk,
		 clkb	=> clk,
		 dia	=> ecallut_data,
		 dib	=> (others=>'0'),
		 dipa	=> (others=>'0'),
		 dipb	=> (others=>'0'),
		 ena 	=> ecallut_enable,
		 enb 	=> not_ecallut_enable ,
		 ssra	=> '0' ,
		 ssrb	=> '0' ,
		 wea	=> "11",
		 web	=> "00" 
	);

	clut: ramb16bwe_s18_s18
	port map(
		 --doa : out std_logic_vector(15 downto 0);
		 dob	=> c_out,
		 --dopa : out std_logic_vector(1 downto 0);
		 --dopb : out std_logic_vector(1 downto 0);
		 addra	=> hcallut_address,
		 addrb	=> c_in,
		 clka	=> hcallut_clk,
		 clkb	=> clk,
		 dia	=> hcallut_data,
		 dib	=> (others=>'0'),
		 dipa	=> (others=>'0'),
		 dipb	=> (others=>'0'),
		 ena 	=> hcallut_enable,
		 enb 	=> not_hcallut_enable ,
		 ssra	=> '0' ,
		 ssrb	=> '0' ,
		 wea	=> "11",
		 web	=> "00" 
	);

	dlut: ramb16bwe_s18_s18
	port map(
		 --doa : out std_logic_vector(15 downto 0);
		 dob	=> d_out,
		 --dopa : out std_logic_vector(1 downto 0);
		 --dopb : out std_logic_vector(1 downto 0);
		 addra	=> hcallut_address,
		 addrb	=> d_in,
		 clka	=> hcallut_clk,
		 clkb	=> clk,
		 dia	=> hcallut_data,
		 dib	=> (others=>'0'),
		 dipa	=> (others=>'0'),
		 dipb	=> (others=>'0'),
		 ena 	=> hcallut_enable,
		 enb 	=> not_hcallut_enable ,
		 ssra	=> '0' ,
		 ssrb	=> '0' ,
		 wea	=> "11",
		 web	=> "00" 
	);	

	linearized_towers.ecala <= a_out( clinearizedwidth-1 downto 0 );
	linearized_towers.ecalb <= b_out( clinearizedwidth-1 downto 0 );
	linearized_towers.hcala <= c_out( clinearizedwidth-1 downto 0 );
	linearized_towers.hcalb <= d_out( clinearizedwidth-1 downto 0 );

	
end v6;
