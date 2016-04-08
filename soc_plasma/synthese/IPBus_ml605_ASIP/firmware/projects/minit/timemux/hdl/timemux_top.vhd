
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use ieee.std_logic_unsigned.all; 

library tmcalotrigger_lib;
use tmcalotrigger_lib.linkinterface.all;

library std;
use std.textio.all;

library work;
use work.package_types.all;

library unisim;
use unisim.vcomponents.all;


entity timemux_top is
  generic(
    det_pp_links : integer := 3;
    pp_mp_links : integer := 4;
    bits_per_word: integer:= 32;
    words_per_bx : integer := 3;
    bx_per_orbit : integer := 32);
  port(
    clk_in          : in std_logic;
    rst_in          : in std_logic := '0';
    bx_cnt_in       : in std_logic_vector(11 downto 0); 
    pp_card_id      : in std_logic_vector(7 downto 0); 
    link_start_in   : in std_logic;
    link_stop_in    : in std_logic;
    link_valid_in   : in std_logic;
    link_data_in    : in all_links((det_pp_links-1) downto 0);
    link_valid_out  : out std_logic_vector((pp_mp_links-1) downto 0);
    link_data_out   : out all_links((pp_mp_links-1) downto 0));
end entity timemux_top;

-- The following architecture was my first attempt at a time multiplexer for the TMT.
-- It is more flexible because all the data is stored in registers rather than a ram
-- (i.e. no port width restrictions).  It simulates, but doesn't synthesise.  Xilinx 
-- XST just aborts without error message.  Precision is better and does report an error 
-- message about the array indices, but I didn't fully understand it.  I suspect using
-- variables for the indices is not allowed.  If teh varaibles were removed ant the 
-- indices written in terms of just constants/generics/loop indecies it might just work.
-- Couldn't be bothered to investigate at present.  Did a quick alt version based on RAMs 
-- instead.  Note designs are fundementally different.  First version effectively does the 
-- mux as the data is entered into regs.  The ram based version has the mux on the ram 
-- output.

--architecture behave of timemux_top is
--  -- Ugly, but perhaps most flexible is to store event_index data in single std_logic_vector
--  
--  constant event_size: integer := bits_per_word * words_per_bx * det_pp_links;
--  
--  type type_event_buf_dat is array (pp_mp_links-1 downto 0) of std_logic_vector(event_size-1 downto 0);
--  signal event_buf_data: type_event_buf_dat;
--    
--  type type_event_buf_index is array (pp_mp_links-1 downto 0) of integer range words_per_bx*det_pp_links downto 0;
--  signal event_buf_index: type_event_buf_index;
--  
--  type type_event_buf_bx is array(pp_mp_links-1 downto 0) of std_logic_vector(11 downto 0);
--  signal event_buf_bx: type_event_buf_bx;
--  
--  signal event_buf_rdy: std_logic_vector(pp_mp_links-1 downto 0);
--  signal event_index: integer range pp_mp_links-1 downto 0;
--  signal word_index: integer range words_per_bx-1 downto 0;
--  signal ready: std_logic;
--  signal bx_cnt: std_logic_vector(11 downto 0);
--  
--begin
--
--  -- Eventually bx_cnt must be synced with data, but just generate here for now
--  bx_cnt_proc: process(rst_in, clk_in)
--    variable bx_int: integer range bx_per_orbit-1 downto 0;
--  begin
--    if rst_in = '1' then
--      bx_int := 0;
--      bx_cnt <= (others => '0');
--    elsif (clk_in = '1') and (clk_in'event) then
--      if link_stop_in = '1' then
--        if bx_int < bx_per_orbit-1 then
--          bx_int := bx_int + 1;
--        else
--          bx_int := 0;
--        end if;
--      end if;
--      bx_cnt <= std_logic_vector(to_unsigned(bx_int,12));
--    end if;
--  end process;
--  
--  
--  mux_in: process(rst_in, clk_in)
--    variable word_offset : integer range (bits_per_word*words_per_bx) downto 0;
--    variable upp_index, low_index: integer range (bits_per_word*det_pp_links*words_per_bx) downto 0;
--  begin
--    if rst_in = '1' then
--      
--      event_index <= 0;
--      word_index <= 0;
--      ready <= '0';
--      
--      event_buf_rst: for i in 0 to pp_mp_links-1 loop
--        event_buf_data(i) <=  (others => '0');
--        event_buf_rdy(i) <= '0';  
--      end loop;
--      
--    elsif (clk_in = '1') and (clk_in'event) then
--    
--      if link_stop_in = '1' then 
--        -- Get ready for next event_index 
--        -- Bit ugly resetting counter on stop rather 
--        -- than start, but saves latency and/or comb logic.
--        word_index <= 0; 
--        -- Startup fix
--        ready <= '1';
--        -- Increment event_index counter
--        if event_index = pp_mp_links-1 then
--          event_index <= 0;
--        else
--          event_index <= event_index+1;
--        end if;
--      else
--        if (link_valid_in = '1') and (ready = '1') then
--          word_index <= word_index + 1; 
--        end if;
--      end if;
--      
--      -- Place event_index data into buffer
--      if link_valid_in = '1' then
--        word_offset := bits_per_word*word_index;
--        for i in 0 to det_pp_links-1 loop
--          upp_index := (bits_per_word*words_per_bx*i) + 31 + word_offset;
--          low_index := (bits_per_word*words_per_bx*i) +  0 + word_offset;
--          event_buf_data(event_index)(upp_index downto low_index) <= link_data_in(i).data;  
--          if word_index = 0 then
--            -- Indicate to output that buffer "ready" for readout
--            event_buf_rdy(event_index) <= '1';
--            -- Store bx when data first stored
--            event_buf_bx(event_index) <= bx_cnt;
--          else
--            event_buf_rdy(event_index) <= '0';            
--          end if;
--        end loop;
--      end if;
--  
--    end if;
--  end process;
--
--  
--  mux_out: process(rst_in, clk_in)
--    variable upp_index, low_index: integer range (bits_per_word*det_pp_links*words_per_bx) downto 0;
--  begin
--    if rst_in = '1' then
--      
--      for j in 0 to pp_mp_links-1 loop
--        event_buf_index(j) <= words_per_bx*det_pp_links;
--        link_data_out(j).data <= (others => '0');
--        link_valid_out(j) <= '0';                
--      end loop;  
--      
--    elsif (clk_in = '1') and (clk_in'event) then
--  
--      for j in 0 to pp_mp_links-1 loop
--        if event_buf_rdy(j) = '1' then
--          -- Set to number of words read into event buffer
--          -- Perhaps this ought to be data driven (i.e. set by data being read in)
--          event_buf_index(j) <= 0;
--          -- Tag data with header container bunch crossing.
--          link_data_out(j).data <= x"FFFF0" & event_buf_bx(j); 
--          link_valid_out(j) <= '1';
--        else
--          -- Has buffer finished reading out? 
--          if event_buf_index(j) < words_per_bx*det_pp_links then
--            event_buf_index(j)  <= event_buf_index(j) + 1;
--            upp_index := bits_per_word*event_buf_index(j) + 31;  
--            low_index := bits_per_word*event_buf_index(j) + 0;      
--            link_data_out(j).data <= event_buf_data(j)(upp_index downto low_index); 
--            link_valid_out(j) <= '1';
--          else
--            link_data_out(j).data <= (others => '0');    
--            link_valid_out(j) <= '0';        
--          end if;
--        end if;  
--      end loop;
--      
--    end if;
--  end process;
--
--end architecture behave;



architecture behave of timemux_top is

  signal wt_index : integer range 0 to 511;   

  signal wt_data: type_vector_of_stdlogicvec_x32(det_pp_links-1 downto 0);
  signal rd_data: type_vector_of_stdlogicvec_x32(det_pp_links-1 downto 0);

  signal rd_add: type_vector_of_stdlogicvec_x9(det_pp_links-1 downto 0);
  signal wt_add: std_logic_vector(8 downto 0);

  signal event_index : integer range 0 to pp_mp_links-1;   
  type type_rd_sel is array (pp_mp_links-1 downto 0) of integer range 0 to pp_mp_links-1;
  signal rd_sel : type_rd_sel;
  
  signal word_index: integer range words_per_bx-1 downto 0;
  signal ready: std_logic;

  signal hdr: type_vector_of_stdlogicvec_x32(pp_mp_links-1 downto 0);

begin

  wt_index_proc: process(rst_in, clk_in)
    variable bx_int: integer range bx_per_orbit-1 downto 0;
  begin
    if rst_in = '1' then
      wt_index <= 0;
    elsif (clk_in = '1') and (clk_in'event) then
      if wt_index > 0 then
        wt_index <= wt_index - 1;
      else
        wt_index <= 511;
      end if;
    end if;
  end process;

  wt_add <= std_logic_vector(to_unsigned(wt_index,9));

  tmux_buf_gen: for i in 0 to det_pp_links-1 generate

    wt_data(i) <= link_data_in(i).data;
    --rd_add(i) <= wt_add + std_logic_vector(to_unsigned((3*i), 9));

    tmux_buf: RAMB16_S36_S36
      generic map(
        SIM_COLLISION_CHECK  => "ALL",
        WRITE_MODE_A => "WRITE_FIRST",
        WRITE_MODE_B => "WRITE_FIRST")
      port map(
        DOA    => open,
        DOB    => rd_data(i),
        DOPA   => open,
        DOPB   => open,
        ADDRA  => wt_add,
        ADDRB  => rd_add(i),
        CLKA   => clk_in, 
        CLKB   => clk_in,
        DIA    => wt_data(i),
        DIB    => (others => '0'),
        DIPA   => (others => '0'),
        DIPB   => (others => '0'),
        ENA    => '1',
        ENB    => '1',
        SSRA   => '0',
        SSRB   => '0',
        WEA    => '1',
        WEB    => '0');

  end generate;

  word_index_proc: process(rst_in, clk_in)
  begin
    if rst_in = '1' then
      word_index <= 0;
      ready <= '0';
    elsif (clk_in = '1') and (clk_in'event) then
      if link_stop_in = '1' then 
        -- Get ready for next event_index 
        -- Bit ugly resetting counter on stop rather 
        -- than start, but saves latency and/or comb logic.
        word_index <= 0; 
        -- Startup fix
        ready <= '1';
      else
        if (link_valid_in = '1') and (ready = '1') then
          word_index <= word_index + 1; 
        end if;
      end if;
    end if;
  end process;
     

  rd_sel_proc: process(rst_in, clk_in)
  begin
    if rst_in = '1' then
      event_index <= 0;
    elsif (clk_in = '1') and (clk_in'event) then
      -- Marker to indicate event being sent on output 
      -- chan 0 and thus all other channels    
      if (word_index = 0) and (ready = '1') then
        if event_index < pp_mp_links-1 then 
           event_index <= event_index + 1;
         else
           event_index <= 0;  
         end if;
      end if;
      -- rd_add needs to be 1 clk cycle bhehind wt_add to avoid mem clash
      -- Hence, reg rd_add here for 1 clk.
      reg_rd_add: for i in 0 to det_pp_links-1 loop
        rd_add(i) <= wt_add + std_logic_vector(to_unsigned((words_per_bx*i), 9));
      end loop;
      -- The multiplexing bit (i.e. divert data from rams to correct MP)
      mux_rd_data: for j in 0 to pp_mp_links-1 loop
        if event_index >= j  then 
          rd_sel(j) <= event_index - j; 
        else
          rd_sel(j) <= pp_mp_links + event_index - j;
        end if;
      end loop;
      -- Header.  Could be built on the fly, but perhaps simplet to 
      -- understand if we have one for each MP path.
      -- Bits 31:24 = PP Card (max 256)
      -- Bits 23:16 = MP Card destination (max 256)
      -- Bits 11:00 = BX ID (max 4095 - fixed in LHC to 3564)
      build_hdr: for j in 0 to pp_mp_links-1 loop
        hdr(j) <= pp_card_id & std_logic_vector(to_unsigned(j, 8)) & x"0" & bx_cnt_in;
      end loop;
    end if;
  end process;


  tmux_gen: for j in 0 to pp_mp_links-1 generate
    link_data_out(j).data <= rd_data(rd_sel(j)) when (rd_sel(j) < det_pp_links ) else
                             hdr(j) when (rd_sel(j)=pp_mp_links-1) and (word_index=1) else (others => '0');
    link_valid_out(j) <= '1' when (rd_sel(j) < det_pp_links ) else '0';
  end generate;
  

end architecture behave;


