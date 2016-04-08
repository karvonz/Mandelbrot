--! @file
--! @brief Wishbone accessible deserializer, copied from DMN Verilog
--! @author David Cussans
--! Institute: University of Bristol
--! @date 26 April 2011

library ieee;
use ieee.std_logic_1164.all; 

use ieee.numeric_std.all;

library work;
use work.ipbus.all;

--! Use UNISIM for Xilix primitives
Library UNISIM;
use UNISIM.vcomponents.all;

entity ipbus_capture_buffer is
  
  generic (
    g_DATA_WIDTH        : integer := 32;  --! Width of WB bus
    g_RAM_ADDRESS_WIDTH : integer := 3);  --! size of RAM = 2^ram_address_width
  port (
    -- Wishbone signals
    ipbus_clk_i : in std_logic;           --! Wishbone clock
    ipbus_i    : in  ipb_wbus;          --! Wishbone signals from master
    ipbus_o    : out ipb_rbus;          --! Wishbone signals to master
    -- Data to capture.
    reset_i : in  std_logic;         --! active high synchronous reset
    cap_clk_i        : in  std_logic;         --! Capture clock
    cap_d_i        : in  std_logic;         --! Data to capture
    cap_go_i   : in  std_logic;  --! Signal to start capturing data. Active high.
    cap_edge_i : in  std_logic --! Indicates edge of clock to use for capture. Low = rising , High = falling
    );  
  
end ipbus_capture_buffer;

architecture rtl of ipbus_capture_buffer is

  -- Internal signals for wishbone.
  signal s_readAddr : std_logic_vector(g_RAM_ADDRESS_WIDTH-1 downto 0);   --! Address into read-port of DPR
  signal s_ack : std_logic;            -- ! Wishbone ACK

  --! Shift register
  signal s_shiftReg : std_logic_vector(g_DATA_WIDTH-1 downto 0) := (others => '0');

  signal s_shiftRegCounter : unsigned(4 downto 0) := (others => '0');  -- ! Counts bits shifted in

  signal s_cap_d , s_cap_d0 , s_cap_d1 : std_logic := '0'; --! Input data after registering with IDDR2
  signal s_cap_clk_n : std_logic;       -- ! Inverted copy of cap_clk_i (for
                                        -- IDDR2 register)
  
  --! DPR signals
  signal s_wen : std_logic := '0';      -- ! Write enable for DPR
  signal  s_writeAddr : unsigned(g_RAM_ADDRESS_WIDTH-1 downto 0) := (others => '0');   --! Address into write-port of DPR
    
begin  -- rtl

  -- purpose: Generated Wishbone ACK 
  -- type   : combinational
  -- inputs : ipbus_clk_i , ipbus_i.ipb_strobe
  -- outputs:  s_ack
  p_wb_decode: process (ipbus_clk_i)
  begin  -- process p_wb_decode
    if rising_edge(ipbus_clk_i) then
      s_ack <= ipbus_i.ipb_strobe and not s_ack;
    end if;
  end process p_wb_decode;

  -- Generate Wishbone ACK and ERR signals.
  ipbus_o.ipb_ack <= s_ack;
  ipbus_o.ipb_err <= '0';

    --! Extract the DPR read-address from Wishbone Record.
  s_readAddr <= ipbus_i.ipb_addr(g_RAM_ADDRESS_WIDTH-1 downto 0);

  -- Instantiate Dual Port RAM
  cmp_capbuf: entity work.dpram
    generic map (
      data_width => g_DATA_WIDTH,
      ram_address_width => g_RAM_ADDRESS_WIDTH )
    Port map (
      Wren_a    =>  s_wen,
      clk       =>  cap_clk_i,
      data_a     =>  s_shiftReg,
      q_b=>  ipbus_o.ipb_rdata,       --! Connect DPR read port to WB 
      address_a =>  std_logic_vector(s_writeAddr),
      address_b => s_readAddr
      );


  -- purpose: Shift register to deserialize data from CBC
  -- type   : combinational
  -- inputs : cap_clk_i , cap_d_i
  -- outputs: s_shiftReg
  p_shiftReg: process (cap_clk_i , cap_d_i)
  begin  -- process p_shiftReg
    if rising_edge(cap_clk_i) then

      if (reset_i = '1')  then
        s_writeAddr <= (others => '0');
        s_shiftRegCounter <= (others => '0');
      else
        s_shiftReg <= s_shiftReg(g_DATA_WIDTH-2 downto 0) & s_cap_d;

        -- Increment bit-counter if a capture is in progress.
        if ( ( s_shiftRegCounter /= 0 ) or
           ( s_writeAddr /= 0 ) or
           ( cap_go_i = '1' ) ) then
          s_shiftRegCounter <=  s_shiftRegCounter + 1;
        end if;

        -- Increment write address if a complete word has been shifted.
        if (s_wen = '1' ) then
          s_writeAddr <= s_writeAddr + 1;
        end if;

      end if;                           -- s_reset=1

    end if;                             -- rising_edge(cap_clk_i)
    
  end process p_shiftReg;

  --! Generate write enable for DPRAM ( also increments write address
  s_wen <= '1' when (s_shiftRegCounter = "11111" ) else '0';

  s_cap_clk_n <= not cap_clk_i;         -- Make inverted copy of cap_clk
  
  --! DDR2 register to input data on rising and falling edge...
  cmp_ODDR2: IDDR2
    port map (
      D  => cap_d_i,
      Q0 => s_cap_d0,
      Q1 => s_cap_d1,
      C0 => cap_clk_i,
      C1 => s_cap_clk_n,
      CE => '1',
      R  => '0',
      S  => '0');

  --! Multiplex between rising and falling edge capture
  s_cap_d <=  s_cap_d0 when ( cap_edge_i = '0')  else s_cap_d1;
  
end rtl;
