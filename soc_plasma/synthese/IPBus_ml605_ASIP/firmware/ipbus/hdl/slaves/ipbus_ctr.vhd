-- Ipbus slave bus cycle counter for testing
--
-- Simply counts up one for each bus access - for detecting erroneous multiple bus cycles
-- Top sixteen bits count writes, bottom count reads.
-- Writes to this location do nothing except increment the counter.
--
-- Dave Newbold, March 2011

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;

entity ipbus_ctr is
	port(
		clk: in STD_LOGIC;
		reset: in STD_LOGIC;
		ipbus_in: in ipb_wbus;
		ipbus_out: out ipb_rbus
	);
	
end ipbus_ctr;

architecture rtl of ipbus_ctr is

	COMPONENT fifo_256_words
	PORT (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    valid : OUT STD_LOGIC;
    data_count : OUT STD_LOGIC_VECTOR(8 DOWNTO 0)
	);
	END COMPONENT;

	COMPONENT rgb2ycbcr_16b
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		din : IN std_logic_vector(31 downto 0);
		ivalid : IN std_logic;          
		dou : OUT std_logic_vector(31 downto 0);
		ovalid : OUT std_logic
		);
	END COMPONENT;

	signal w_ctr, r_ctr: unsigned(31 downto 0);
	signal ack: std_logic;

    SIGNAL ififo_din        : STD_LOGIC_VECTOR(31 DOWNTO 0);	-- DATA FROM THE PC
    SIGNAL ififo_wr_en      : STD_LOGIC;
    SIGNAL ififo_rd_en      : STD_LOGIC;
    SIGNAL ififo_dout       : STD_LOGIC_VECTOR(31 DOWNTO 0);	-- DATA FOR THE VHDL DESIGN
    SIGNAL ififo_valid      : STD_LOGIC;
    SIGNAL ififo_data_count : STD_LOGIC_VECTOR( 8 DOWNTO 0);

    SIGNAL ofifo_din        : STD_LOGIC_VECTOR(31 DOWNTO 0);	-- DATA FROM THE PC
    SIGNAL ofifo_wr_en      : STD_LOGIC;
    SIGNAL ofifo_rd_en      : STD_LOGIC;
    SIGNAL ofifo_dout       : STD_LOGIC_VECTOR(31 DOWNTO 0);	-- DATA FOR THE VHDL DESIGN
    SIGNAL ofifo_valid      : STD_LOGIC;
    SIGNAL ofifo_data_count : STD_LOGIC_VECTOR( 8 DOWNTO 0);

	signal address: integer;

begin

	process(clk)
	begin
		if rising_edge(clk) then
			if reset='1' then
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
	address <= to_integer(unsigned(ipbus_in.ipb_addr(2 downto 0)));


	process(clk)
	begin
		if rising_edge(clk) then

			ififo_din   <= ipbus_in.ipb_wdata;
			ififo_wr_en <= '0';
			ofifo_rd_en <= '0';

			if ipbus_in.ipb_strobe='1' and ipbus_in.ipb_write='1' then
				CASE address IS
					WHEN 0 => ipbus_out.ipb_rdata <= x"FFFFFFFF"; -- CODE SPECIFIQUE AU COMPOSANT VHDL CABLE
					WHEN 1 => ipbus_out.ipb_rdata <= STD_LOGIC_VECTOR(RESIZE( UNSIGNED(ififo_data_count), 32)); -- CODE SPECIFIQUE AU COMPOSANT VHDL CABLE
					WHEN 2 => ipbus_out.ipb_rdata <= STD_LOGIC_VECTOR(RESIZE( UNSIGNED(ofifo_data_count), 32)); -- CODE SPECIFIQUE AU COMPOSANT VHDL CABLE
					WHEN 3 => ififo_wr_en         <= '1'; -- CODE SPECIFIQUE AU COMPOSANT VHDL CABLE
					WHEN 4 => ipbus_out.ipb_rdata <= ofifo_dout; -- CODE SPECIFIQUE AU COMPOSANT VHDL CABLE
								 ofifo_rd_en         <= '1';
					WHEN 5 => ipbus_out.ipb_rdata <= r_ctr; -- CODE SPECIFIQUE AU COMPOSANT VHDL CABLE
					WHEN 6 => ipbus_out.ipb_rdata <= w_ctr; -- CODE SPECIFIQUE AU COMPOSANT VHDL CABLE
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
    clk        => clk,
    rst        => reset,
    din        => ififo_din,	-- DATA FROM THE PC
    wr_en      => ififo_wr_en,
    rd_en      => ififo_rd_en,
    dout       => ififo_dout,	-- DATA FOR THE VHDL DESIGN
    full       => open,
    empty      => open,
    valid      => ififo_valid,
    data_count => ififo_data_count
	);

	ofifo : fifo_256_words
	PORT MAP (
    clk        => clk,
    rst        => reset,
    din        => ofifo_din,	-- DATA FROM THE VHDL DESIGN
    wr_en      => ofifo_wr_en,
    rd_en      => ofifo_rd_en,
    dout       => ofifo_dout,	-- DATA FOR THE PC
    full       => open,
    empty      => open,
    valid      => ofifo_valid,
    data_count => ofifo_data_count
	);
	
	ififo_rd_en <= ififo_valid;
	
	design: rgb2ycbcr_16b PORT MAP(
		clk => clk,
		rst => reset,
		din => ififo_dout,
		dou => ofifo_din,
		ivalid => ififo_valid,
		ovalid => ofifo_wr_en
	);


	ipbus_out.ipb_ack <= ack;
	ipbus_out.ipb_err <= '0';

end rtl;
