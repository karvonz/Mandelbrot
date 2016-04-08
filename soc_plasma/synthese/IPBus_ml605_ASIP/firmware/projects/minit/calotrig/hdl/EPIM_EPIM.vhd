----------------------------------------------------------------------------------
-- company: 
-- engineer: 
-- 
-- create date:    15:00:28 03/09/2010 
-- design name: 
-- module name:    epim - epim 
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
use ieee.numeric_std.all;

use tmcalotrigger_lib.constants.all;
use tmcalotrigger_lib.types.all;

---- uncomment the following library declaration if instantiating
---- any xilinx primitives in this code.
library unisim;
use unisim.vcomponents.all;

entity epim is
	port(
		async_reset:		in	std_logic := '1';
		clk:				in	std_logic := '0';
		targetgreaterselect:	in	std_logic_vector( 1 downto 0 );
		targetlesserselect:	in	std_logic_vector( 1 downto 0 );
		lutselect:			in	std_logic_vector( 1 downto 0 );
		eandh:				in	t2x2sums;
		et:					in	std_logic_vector( clinearizedwidth+2 downto 0 );
		pass:				out	std_logic;
		epimlut_address:		in	std_logic_vector( 9 downto 0 );
		epimlut_data:			in	std_logic_vector( 15 downto 0 );
		epimlut_clk:			in	std_logic;
		epimlut_enable:			in	std_logic
	);
end epim;



architecture v5 of epim is
	signal	targetgreater	:	std_logic_vector( clinearizedwidth+2 downto 0 )	:=	(others=>'0');
	signal	targetlesser	:	std_logic_vector( clinearizedwidth+2 downto 0 )	:=	(others=>'0');

	signal	epimlut_address_in	:	std_logic_vector( 13 downto 0 )	:=	(others=>'0');
	signal	epimlut_input		:	std_logic_vector( 13 downto 0 )	:=	(others=>'0');
	signal	epimlut_output		:	std_logic_vector( 15 downto 0 )	:=	(others=>'0');

	signal	not_epimlut_enable	:	std_logic;

	signal	tempeandh_a		:	t2x2sums;
--	signal	tempeandh_b		:	t2x2sums;
	signal	tempet_a		:	std_logic_vector( clinearizedwidth+2 downto 0 );
--	signal	tempet_b		:	std_logic_vector( clinearizedwidth+2 downto 0 );

	
begin
	
	not_epimlut_enable <= not epimlut_enable;

	epimlut_input( 13 downto 0 )	<=		"0000"&et( clinearizedwidth+2 downto clinearizedwidth+2-9 )	when	lutselect = "11"
					else	"0000"&eandh.hcal( clinearizedwidth+1 downto clinearizedwidth+1-9 )	when	lutselect = "10"
					else	"0000"&eandh.ecal( clinearizedwidth+1 downto clinearizedwidth+1-9 )	when	lutselect = "01"
					else	(others=>'X');
			
	epimlut_address_in <= "0000"&epimlut_address;
			
	lut: ramb18
	generic map(
	  read_width_a => 18,
	  read_width_b => 18)
	port map(
		 --doa : out std_logic_vector(15 downto 0);
		 dob	=> epimlut_output,
		 --dopa : out std_logic_vector(1 downto 0);
		 --dopb : out std_logic_vector(1 downto 0);
		 addra	=> epimlut_address_in,
		 addrb	=> epimlut_input,
		 clka	=> epimlut_clk,
		 clkb	=> clk,
		 dia	=> epimlut_data,
		 dib	=> (others=>'0'),
		 dipa	=> (others=>'0'),
		 dipb	=> (others=>'0'),
		 ena 	=> epimlut_enable,
		 enb 	=> not_epimlut_enable ,
		 regcea => '1',
		 regceb => '1',
		 ssra	=> '0' ,
		 ssrb	=> '0' ,
		 wea	=> "11",
		 web	=> "00" 
	);
	
	tempeandh_a	<=	eandh when rising_edge(clk);
--	tempeandh_b	<=	tempeandh_a when rising_edge(clk);
	tempet_a	<=	et when rising_edge(clk);
--	tempet_b	<=	tempet_a when rising_edge(clk);
	
	targetgreater	<=			tempet_a			when	targetgreaterselect = "11"
					else	'0'&tempeandh_a.hcal	when	targetgreaterselect = "10"
					else	'0'&tempeandh_a.ecal	when	targetgreaterselect = "01"
					else	epimlut_output( clinearizedwidth+2 downto 0 );
				
	targetlesser	<=			tempet_a			when	targetlesserselect = "11"
					else	'0'&tempeandh_a.hcal	when	targetlesserselect = "10"
					else	'0'&tempeandh_a.ecal	when	targetlesserselect = "01"
					else	epimlut_output( clinearizedwidth+2 downto 0 );
			
	process ( async_reset , clk ) 
 	begin
		if ( async_reset='1' ) then
			pass <= '0';
		elsif ( rising_edge(clk) ) then

			-- report "epim compare : " &  integer'image(to_integer(unsigned(targetgreater))) & " > " &  integer'image(to_integer(unsigned(targetlesser)));

			if ( targetgreater > targetlesser ) then
				pass <= '1';	
			else
				pass <= '0';		
			end if;
		end if;
	end process;
				
end v5;









architecture v6 of epim is
	signal	targetgreater	:	std_logic_vector( clinearizedwidth+2 downto 0 )	:=	(others=>'0');
	signal	targetlesser	:	std_logic_vector( clinearizedwidth+2 downto 0 )	:=	(others=>'0');

	signal	epimlut_input		:	std_logic_vector( 9 downto 0 )	:=	(others=>'0');
	signal	epimlut_output		:	std_logic_vector( 15 downto 0 )	:=	(others=>'0');

	signal	not_epimlut_enable	:	std_logic;

	signal	tempeandh_a		:	t2x2sums;
--	signal	tempeandh_b		:	t2x2sums;
	signal	tempet_a		:	std_logic_vector( clinearizedwidth+2 downto 0 );
--	signal	tempet_b		:	std_logic_vector( clinearizedwidth+2 downto 0 );

	
begin
	
	not_epimlut_enable <= not epimlut_enable;

	epimlut_input( 9 downto 0 )	<=		et( clinearizedwidth+2 downto clinearizedwidth+2-9 )	when	lutselect = "11"
					else	eandh.hcal( clinearizedwidth+1 downto clinearizedwidth+1-9 )	when	lutselect = "10"
					else	eandh.ecal( clinearizedwidth+1 downto clinearizedwidth+1-9 )	when	lutselect = "01"
					else	(others=>'X');
							
	lut: ramb16bwe_s18_s18
	port map(
		 --doa : out std_logic_vector(15 downto 0);
		 dob	=> epimlut_output,
		 --dopa : out std_logic_vector(1 downto 0);
		 --dopb : out std_logic_vector(1 downto 0);
		 addra	=> epimlut_address,
		 addrb	=> epimlut_input,
		 clka	=> epimlut_clk,
		 clkb	=> clk,
		 dia	=> epimlut_data,
		 dib	=> (others=>'0'),
		 dipa	=> (others=>'0'),
		 dipb	=> (others=>'0'),
		 ena 	=> epimlut_enable,
		 enb 	=> not_epimlut_enable ,
		 ssra	=> '0' ,
		 ssrb	=> '0' ,
		 wea	=> "11",
		 web	=> "00" 
	);
	
	tempeandh_a	<=	eandh when rising_edge(clk);
--	tempeandh_b	<=	tempeandh_a when rising_edge(clk);
	tempet_a	<=	et when rising_edge(clk);
--	tempet_b	<=	tempet_a when rising_edge(clk);
	
	targetgreater	<=			tempet_a			when	targetgreaterselect = "11"
					else	'0'&tempeandh_a.hcal	when	targetgreaterselect = "10"
					else	'0'&tempeandh_a.ecal	when	targetgreaterselect = "01"
					else	epimlut_output( clinearizedwidth+2 downto 0 );
				
	targetlesser	<=			tempet_a			when	targetlesserselect = "11"
					else	'0'&tempeandh_a.hcal	when	targetlesserselect = "10"
					else	'0'&tempeandh_a.ecal	when	targetlesserselect = "01"
					else	epimlut_output( clinearizedwidth+2 downto 0 );
			
	process ( async_reset , clk ) 
 	begin
		if ( async_reset='1' ) then
			pass <= '0';
		elsif ( rising_edge(clk) ) then

			-- report "epim compare : " &  integer'image(to_integer(unsigned(targetgreater))) & " > " &  integer'image(to_integer(unsigned(targetlesser)));

			if ( targetgreater > targetlesser ) then
				pass <= '1';	
			else
				pass <= '0';		
			end if;
		end if;
	end process;
				
end v6;
