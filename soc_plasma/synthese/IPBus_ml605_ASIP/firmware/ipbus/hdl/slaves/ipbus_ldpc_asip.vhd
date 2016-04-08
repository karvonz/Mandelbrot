-- Generic ipbus ram block for testing
--
-- generic addr_width defines number of significant address bits
--
-- In order to allow Xilinx block RAM to be inferred:
-- 	Reset does not clear the RAM contents (not implementable in Xilinx)
--		There is one cycle of latency on the read / write
--
-- Note that the synthesis tool should automatically infer block or distributed RAM
-- according to the size requested. It is likely that it will NOT choose
-- an efficient implementation in terms of area / speed / power, so don't use this
-- method to infer large RAMs (noting also that reads are enabled at all times).
-- It's best to use the block ram core generator explicitly.
--
-- Occupies addr_width bits of ipbus address space
-- This RAM cannot be used with 100% bus utilisation due to the wait state
--
-- Dave Newbold, March 2011
--
-- $Id: ipbus_ram.vhd 324 2011-04-25 19:37:43Z phdmn $

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;

entity ipbus_ldpc_asip is
	generic(addr_width : positive);
	port(
		clk      : in  STD_LOGIC;
		reset    : in  STD_LOGIC;
		i_uart   : in  STD_LOGIC;
		o_uart   : out STD_LOGIC;
		gpio     : out STD_LOGIC_VECTOR(7 DOWNTO 0);
		ipbus_in : in  ipb_wbus;
		ipbus_out: out ipb_rbus
	);
	
end ipbus_ldpc_asip;

architecture rtl of ipbus_ldpc_asip is

	COMPONENT fifo_256_words
	PORT (
		clk   : IN  STD_LOGIC;
		rst   : IN  STD_LOGIC;
		din   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		wr_en : IN  STD_LOGIC;
		rd_en : IN  STD_LOGIC;
		dout  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		full  : OUT STD_LOGIC;
		empty : OUT STD_LOGIC;
    almost_empty : OUT STD_LOGIC;
		valid : OUT STD_LOGIC;
		data_count : OUT STD_LOGIC_VECTOR(8 DOWNTO 0)
	);
	END COMPONENT;

	COMPONENT fifo_1024_words
	PORT (
		clk   : IN  STD_LOGIC;
		rst   : IN  STD_LOGIC;
		din   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		wr_en : IN  STD_LOGIC;
		rd_en : IN  STD_LOGIC;
		dout  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		full  : OUT STD_LOGIC;
		empty : OUT STD_LOGIC;
    almost_empty : OUT STD_LOGIC;
		valid : OUT STD_LOGIC;
		data_count : OUT STD_LOGIC_VECTOR(10 DOWNTO 0)
	);
	END COMPONENT;

	COMPONENT fifo_2048_words
	PORT (
		clk   : IN  STD_LOGIC;
		rst   : IN  STD_LOGIC;
		din   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		wr_en : IN  STD_LOGIC;
		rd_en : IN  STD_LOGIC;
		dout  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		full  : OUT STD_LOGIC;
		empty : OUT STD_LOGIC;
    almost_empty : OUT STD_LOGIC;
		valid : OUT STD_LOGIC;
		data_count : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
	);
	END COMPONENT;

	COMPONENT fifo_4096_words
	PORT (
		clk   : IN  STD_LOGIC;
		rst   : IN  STD_LOGIC;
		din   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		wr_en : IN  STD_LOGIC;
		rd_en : IN  STD_LOGIC;
		dout  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		full  : OUT STD_LOGIC;
		empty : OUT STD_LOGIC;
    almost_empty : OUT STD_LOGIC;
		valid : OUT STD_LOGIC;
		data_count : OUT STD_LOGIC_VECTOR(12 DOWNTO 0)
	);
	END COMPONENT;

	COMPONENT fifo_16384_words
   PORT (
		rst : IN STD_LOGIC;
		wr_clk : IN STD_LOGIC;
		rd_clk : IN STD_LOGIC;
		din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		wr_en : IN STD_LOGIC;
		rd_en : IN STD_LOGIC;
		dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		full : OUT STD_LOGIC;
		empty : OUT STD_LOGIC;
		almost_empty : OUT STD_LOGIC;
		valid : OUT STD_LOGIC;
		rd_data_count : OUT STD_LOGIC_VECTOR(16 DOWNTO 0);
		wr_data_count : OUT STD_LOGIC_VECTOR(14 DOWNTO 0)
   );
	END COMPONENT;

	COMPONENT plasma
   GENERIC(
		memory_type : string := "DUAL_PORT_";
		log_file    : string := "UNUSED";
		ethernet    : std_logic  := '0';
		eUart       : std_logic  := '1';
      use_cache   : std_logic  := '0'
	);
	PORT(
		clk          : IN std_logic;
		reset        : IN std_logic;
		uart_read    : IN std_logic;
		uart_write   : OUT std_logic;

		--
		-- FIFO QUI CONTIENT LES INFORMATIONS DE PROGRAMMATION
		--
		fifo_1_out_data  : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
		fifo_1_compteur  : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
		fifo_1_empty     : IN  STD_LOGIC;
		fifo_1_alm_empty : IN  STD_LOGIC;
		fifo_1_valid     : IN STD_LOGIC;
		fifo_1_full      : IN  STD_LOGIC;
		fifo_1_read_en   : OUT STD_LOGIC;

		--
		-- FIFO QUI CONTIENT LES LLRs A TRAITER
		--
		fifo_d_out_data  : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
		fifo_d_compteur  : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
		fifo_d_empty     : IN  STD_LOGIC;
		fifo_d_alm_empty : IN  STD_LOGIC;
		fifo_d_valid     : IN  STD_LOGIC;
		fifo_d_full      : IN  STD_LOGIC;
		fifo_d_read_en   : OUT STD_LOGIC;
	 
		--
		-- FIFO QUI CONTIENDRA LES DECISIONS DURES
		--
		fifo_2_in_data   : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		fifo_2_write_en  : OUT STD_LOGIC;
		fifo_2_full      : IN  STD_LOGIC;
		
		gpioA_in : IN std_logic_vector(31 downto 0);          
		gpio0_out : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;

	signal w_ctr, r_ctr: unsigned(31 downto 0);
	signal ack: std_logic;
	signal sel: integer;

	SIGNAL ififo_din        : STD_LOGIC_VECTOR(31 DOWNTO 0);	-- DATA FROM THE PC
   SIGNAL ififo_wr_en      : STD_LOGIC;
   SIGNAL ififo_rd_en      : STD_LOGIC;
   SIGNAL ififo_empty      : STD_LOGIC;
   SIGNAL ififo_almty      : STD_LOGIC;
   SIGNAL ififo_full       : STD_LOGIC;
   SIGNAL ififo_dout       : STD_LOGIC_VECTOR(31 DOWNTO 0);	-- DATA FOR THE VHDL DESIGN
   SIGNAL ififo_valid      : STD_LOGIC;
   SIGNAL ififo_data_count : STD_LOGIC_VECTOR( 8 DOWNTO 0);
   SIGNAL ififo_compteur   : STD_LOGIC_VECTOR(31 DOWNTO 0);	-- DATA FOR THE VHDL DESIGN

	SIGNAL dfifo_din        : STD_LOGIC_VECTOR(31 DOWNTO 0);	-- DATA FROM THE PC
   SIGNAL dfifo_wr_en      : STD_LOGIC;
   SIGNAL dfifo_rd_en      : STD_LOGIC;
   SIGNAL dfifo_empty      : STD_LOGIC;
   SIGNAL dfifo_almty      : STD_LOGIC;
   SIGNAL dfifo_full       : STD_LOGIC;
   SIGNAL dfifo_dout       : STD_LOGIC_VECTOR( 7 DOWNTO 0);	-- DATA FOR THE VHDL DESIGN
   SIGNAL dfifo_valid      : STD_LOGIC;
   SIGNAL dfifo_data_count : STD_LOGIC_VECTOR(14 DOWNTO 0);
   SIGNAL dfifo_compteur   : STD_LOGIC_VECTOR(31 DOWNTO 0);	-- DATA FOR THE VHDL DESIGN

   SIGNAL ofifo_din        : STD_LOGIC_VECTOR(31 DOWNTO 0);	-- DATA FROM THE PC
   SIGNAL ofifo_wr_en      : STD_LOGIC;
   SIGNAL ofifo_rd_en      : STD_LOGIC;
   SIGNAL ofifo_empty      : STD_LOGIC;
   SIGNAL ofifo_almty      : STD_LOGIC;
   SIGNAL ofifo_full       : STD_LOGIC;
   SIGNAL ofifo_dout       : STD_LOGIC_VECTOR(31 DOWNTO 0);	-- DATA FOR THE VHDL DESIGN
   SIGNAL ofifo_valid      : STD_LOGIC;
   SIGNAL ofifo_data_count : STD_LOGIC_VECTOR(11 DOWNTO 0);
   SIGNAL ofifo_compteur   : STD_LOGIC_VECTOR(31 DOWNTO 0);	-- DATA FOR THE VHDL DESIGN

   SIGNAL soft_reset       : STD_LOGIC;
   SIGNAL reset_signal     : STD_LOGIC;
   SIGNAL gpio_sig         : STD_LOGIC_VECTOR(31 DOWNTO 0);	-- DATA FOR THE VHDL DESIGN

	signal address: integer;

BEGIN

	reset_signal <= soft_reset or reset;

	process(clk)
	begin
		if rising_edge(clk) then
			if reset_signal='1' then
				w_ctr <= (others=>'0');
				r_ctr <= (others=>'0');
			elsif ipbus_in.ipb_strobe='1' then
				if ipbus_in.ipb_write='1' then
					w_ctr <= w_ctr + 1;
				else
					r_ctr <= r_ctr + 1;
				end if;
			end if;
--			ipbus_out.ipb_rdata <= std_logic_vector(w_ctr) & std_logic_vector(r_ctr);
--			ack <= ipbus_in.ipb_strobe and not ack;
		end if;
	end process;

	-- CONNECTION DES SIGNAUX
	sel <= to_integer(unsigned(ipbus_in.ipb_addr(addr_width-1 downto 0)));


	process(clk)
	begin
		if rising_edge(clk) then

			ififo_din   <= ipbus_in.ipb_wdata;
			ififo_wr_en <= '0';
			dfifo_din   <= ipbus_in.ipb_wdata;
			dfifo_wr_en <= '0';
			ofifo_rd_en <= '0';
			soft_reset  <= '0';

			if ipbus_in.ipb_strobe='1' and ipbus_in.ipb_write='1' then
				CASE sel IS
					WHEN 4 => ififo_wr_en <= not ack; -- CODE SPECIFIQUE AU COMPOSANT VHDL CABLE
					WHEN 5 => dfifo_wr_en <= not ack; -- CODE SPECIFIQUE AU COMPOSANT VHDL CABLE
					WHEN 9 => soft_reset  <= not ack;
					WHEN OTHERS => NULL;
				end case;
			end if;
			
			if ipbus_in.ipb_strobe='1' and ipbus_in.ipb_write='0' then
				CASE sel IS
					WHEN  0 => ipbus_out.ipb_rdata <= x"9ABCDEF0";                                               -- CODE SPECIFIQUE AU COMPOSANT VHDL CABLE
					WHEN  1 => ipbus_out.ipb_rdata <= STD_LOGIC_VECTOR(RESIZE( UNSIGNED(ififo_data_count), 32)); -- CODE SPECIFIQUE AU COMPOSANT VHDL CABLE
					WHEN  2 => ipbus_out.ipb_rdata <= STD_LOGIC_VECTOR(RESIZE( UNSIGNED(dfifo_data_count), 32)); -- CODE SPECIFIQUE AU COMPOSANT VHDL CABLE
					WHEN  3 => ipbus_out.ipb_rdata <= STD_LOGIC_VECTOR(RESIZE( UNSIGNED(ofifo_data_count), 32)); -- CODE SPECIFIQUE AU COMPOSANT VHDL CABLE
--					WHEN  4 => ififo_wr_en         <= '1';                                                       -- CODE SPECIFIQUE AU COMPOSANT VHDL CABLE
--					WHEN  5 => dfifo_wr_en         <= '1';                                                       -- CODE SPECIFIQUE AU COMPOSANT VHDL CABLE
					WHEN  6 => ipbus_out.ipb_rdata <= ofifo_dout;                                                -- CODE SPECIFIQUE AU COMPOSANT VHDL CABLE
								  ofifo_rd_en         <= not ack;
					WHEN  7 => ipbus_out.ipb_rdata <= std_logic_vector(r_ctr); -- CODE SPECIFIQUE AU COMPOSANT VHDL CABLE
					WHEN  8 => ipbus_out.ipb_rdata <= std_logic_vector(w_ctr); -- CODE SPECIFIQUE AU COMPOSANT VHDL CABLE
--					WHEN  9 => soft_reset <= '1';
					WHEN 10 => ipbus_out.ipb_rdata <= "0000000000000000000000000000000" & ififo_empty; -- CODE SPECIFIQUE AU COMPOSANT VHDL CABLE
					WHEN 11 => ipbus_out.ipb_rdata <= "0000000000000000000000000000000" & ififo_full;  -- CODE SPECIFIQUE AU COMPOSANT VHDL CABLE
					WHEN 12 => ipbus_out.ipb_rdata <= "0000000000000000000000000000000" & ififo_valid; -- CODE SPECIFIQUE AU COMPOSANT VHDL CABLE
					WHEN 13 => ipbus_out.ipb_rdata <= "0000000000000000000000000000000" & dfifo_empty; -- CODE SPECIFIQUE AU COMPOSANT VHDL CABLE
					WHEN 14 => ipbus_out.ipb_rdata <= "0000000000000000000000000000000" & dfifo_full;  -- CODE SPECIFIQUE AU COMPOSANT VHDL CABLE
					WHEN 15 => ipbus_out.ipb_rdata <= "0000000000000000000000000000000" & dfifo_valid; -- CODE SPECIFIQUE AU COMPOSANT VHDL CABLE
					WHEN 16 => ipbus_out.ipb_rdata <= "0000000000000000000000000000000" & ofifo_empty; -- CODE SPECIFIQUE AU COMPOSANT VHDL CABLE
					WHEN 17 => ipbus_out.ipb_rdata <= "0000000000000000000000000000000" & ofifo_full;  -- CODE SPECIFIQUE AU COMPOSANT VHDL CABLE
					WHEN 18 => ipbus_out.ipb_rdata <= "0000000000000000000000000000000" & ofifo_valid; -- CODE SPECIFIQUE AU COMPOSANT VHDL CABLE
 					WHEN 19 => ipbus_out.ipb_rdata <= STD_LOGIC_VECTOR( TO_UNSIGNED(  256, 32) );
 					WHEN 20 => ipbus_out.ipb_rdata <= STD_LOGIC_VECTOR( TO_UNSIGNED(16384, 32) );
 					WHEN 21 => ipbus_out.ipb_rdata <= STD_LOGIC_VECTOR( TO_UNSIGNED( 2048, 32) );
					WHEN OTHERS => NULL;
--					reg(sel) <= ipbus_in.ipb_wdata;
				end case;
			end if;

--			ipbus_out.ipb_rdata <= reg(sel);
			ack <= ipbus_in.ipb_strobe and not ack;
			
		end if;
	end process;



	ififo : fifo_256_words
	PORT MAP (
    clk          => clk,
    rst          => reset_signal,
    din          => ififo_din,	-- DATA FROM THE PC
    wr_en        => ififo_wr_en,
    rd_en        => ififo_rd_en,
    dout         => ififo_dout,	-- DATA FOR THE VHDL DESIGN
    full         => ififo_full,
    empty        => ififo_empty,
	 almost_empty => ififo_almty,
    valid        => ififo_valid,
    data_count   => ififo_data_count
	);

	dfifo : fifo_16384_words
	PORT MAP (
    wr_clk       => clk,
    rd_clk       => clk,
    rst          => reset_signal,
    din          => dfifo_din,	-- DATA FROM THE PC
    wr_en        => dfifo_wr_en,
    rd_en        => dfifo_rd_en,
    dout         => dfifo_dout,	-- DATA FOR THE VHDL DESIGN
    full         => dfifo_full,
    empty        => dfifo_empty,
	 almost_empty => dfifo_almty,
    valid        => dfifo_valid,
    rd_data_count   => open,
    wr_data_count   => dfifo_data_count
	);  
  
	ofifo : fifo_2048_words
	PORT MAP (
    clk          => clk,
    rst          => reset_signal,
    din          => ofifo_din,	-- DATA FROM THE VHDL DESIGN
    wr_en        => ofifo_wr_en,
    rd_en        => ofifo_rd_en,
    dout         => ofifo_dout,	-- DATA FOR THE PC
    full         => ofifo_full,
    empty        => ofifo_empty,
	 almost_empty => ofifo_almty,
    valid        => ofifo_valid,
    data_count   => ofifo_data_count
	);
		
	Inst_plasma: plasma
	GENERIC MAP (
		memory_type => "XILINX_16X",
		log_file    => "UNUSED",
      ethernet    => '0',
		eUart       => '1',
      use_cache   => '0'
	)
	PORT MAP(
		clk           => clk,
		reset         => reset_signal,
		uart_write    => o_uart,
		uart_read     => i_uart, --open,

		fifo_1_out_data  => ififo_dout,
		fifo_1_compteur  => ififo_compteur,
		fifo_1_empty     => ififo_empty,
		fifo_1_alm_empty => ififo_almty,
		fifo_1_valid     => ififo_valid,
		fifo_1_full      => ififo_full,
		fifo_1_read_en   => ififo_rd_en,

		fifo_d_out_data  => dfifo_dout,
		fifo_d_compteur  => dfifo_compteur,
		fifo_d_empty     => dfifo_empty,
		fifo_d_alm_empty => dfifo_almty,
		fifo_d_valid     => dfifo_valid,
		fifo_d_full      => dfifo_full,
		fifo_d_read_en   => dfifo_rd_en,

		fifo_2_in_data   => ofifo_din,
		fifo_2_write_en  => ofifo_wr_en,
		fifo_2_full      => ofifo_full,

		gpio0_out       => open,
		gpioA_in        => x"00000000" --open
	);
	
--	gpio <= gpio_sig(3 downto 0);

	gpio(7) <= '1' WHEN TO_INTEGER(UNSIGNED(ififo_data_count)) >=   864/4 ELSE '0';
	gpio(6) <= '1' WHEN TO_INTEGER(UNSIGNED(ififo_data_count)) >=   864/2 ELSE '0';
	gpio(5) <= '1' WHEN TO_INTEGER(UNSIGNED(ififo_data_count)) >= 1*864/2 ELSE '0';
	gpio(4) <= '1' WHEN TO_INTEGER(UNSIGNED(ififo_data_count)) >= 2*864/2 ELSE '0';
	gpio(3) <= '1' WHEN TO_INTEGER(UNSIGNED(ififo_data_count)) >= 3*864/2 ELSE '0';
	gpio(2) <= '1' WHEN TO_INTEGER(UNSIGNED(ififo_data_count)) >= 4*864   ELSE '0';
	gpio(1) <= '1' WHEN TO_INTEGER(UNSIGNED(ififo_data_count)) >= 5*864   ELSE '0';
	gpio(0) <= '1' WHEN TO_INTEGER(UNSIGNED(ififo_data_count)) >= 6*864   ELSE '0';

	ififo_compteur    <= STD_LOGIC_VECTOR(RESIZE( UNSIGNED(ififo_data_count), 32));
	dfifo_compteur    <= STD_LOGIC_VECTOR(RESIZE( UNSIGNED(dfifo_data_count), 32));
	ofifo_compteur    <= STD_LOGIC_VECTOR(RESIZE( UNSIGNED(ofifo_data_count), 32));

	ipbus_out.ipb_ack <= ack;
	ipbus_out.ipb_err <= '0';

end rtl;
