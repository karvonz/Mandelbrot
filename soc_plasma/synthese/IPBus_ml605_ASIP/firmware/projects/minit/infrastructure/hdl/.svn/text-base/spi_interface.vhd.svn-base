
----------------------------------------------------------------------------------
-- Company: Imperial College London

-- Engineer: Greg Iles

-- Description: SPI interace to UC

-- Revision : 
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
-- use ieee.std_logic_arith;
-- use ieee.numeric_std;

entity spi_interface is
port(
    clk:                in std_logic;
    rst:                in std_logic;
    so:                 out std_logic;
    si:                 in std_logic;
    sck:                in std_logic;
    cs_b:               in std_logic);
end spi_interface;

architecture behave of spi_interface is

  signal sck_sreg, si_sreg, cs_sreg: std_logic_vector(2 downto 0);
  signal add_byte: std_logic;
  signal si_error, si_active, si_byte_valid: std_logic;
  signal si_byte: std_logic_vector(7 downto 0);
  signal si_index: integer range 0 to 7;
  signal si_timeout: integer range 0 to 65535;
  constant timeout_max: integer := 10000;
  signal add_int: integer range 0 to 65535;
  signal add: std_logic_vector(15 downto 0);

  signal r_nw: std_logic;
  signal rd_byte, wt_byte: std_logic_vector(7 downto 0);
  signal wt_byte_valid: std_logic;

  signal so_byte: std_logic_vector(7 downto 0);
  signal so_byte_valid, so_finished: std_logic;
  signal so_index: integer range 0 to 7;
  signal so_data, so_valid: std_logic;


  type type_rx_state is (RX_IDLE, RX_BYTE, RX_ACTIVE);
  signal rx_state: type_rx_state;
  
  type type_tx_state is (TX_IDLE, TX_BYTE);
  signal tx_state: type_tx_state;
  
  type type_scntrl_state is (SCNTRL_IDLE, SCNTRL_ADD, SCNTRL_DATA);
  signal scntrl_state: type_scntrl_state;

begin

  so <= so_data when so_valid = '1' else 'Z';

  sreg_proc: process(clk, rst)
  begin
    if rst = '1' then
      si_sreg <= (others => '0');
      cs_sreg <= (others => '0');
      sck_sreg <= (others => '0');
    elsif (clk'event and clk = '1') then
      -- Oversample SPI clk to avoid metasatbility 
      -- problems and get delayed values.  
      -- FPGA clk >> SPI clk (i.e. 125MHz >> 10MHz)
      si_sreg <= si_sreg(1 downto 0) & si;
      cs_sreg <= cs_sreg(1 downto 0) & not cs_b;
      sck_sreg <= sck_sreg(1 downto 0) & sck;
    end if;
  end process;
  
  
  si_byte_proc: process(clk, rst)
  begin
    if rst = '1' then

    elsif (clk'event and clk = '1') then
      case rx_state is
      when RX_IDLE => 
        -- Clear any error
        si_error <= '1';
        -- Look to see if CS asserted
        if cs_sreg(2 downto 1) = "01" then
          rx_state <= RX_ACTIVE;
          si_timeout <= timeout_max;
          si_active <= '1';
        end if;
      when RX_ACTIVE => 
        -- Clear any byte received signal;
        si_byte_valid <= '0';
        -- Are we still in valid transaction?
        if (si_timeout = 0) then
           -- Transaction ended unexpectedly
          rx_state <= RX_IDLE;
          si_error <= '1';
        elsif (cs_sreg(1) = '0')  then
          -- Transaction ended OK
          rx_state <= RX_IDLE;
        else
          si_timeout <= si_timeout - 1;
          if sck_sreg(2 downto 1) = "01" then
            -- Rising edge of sck.  
            -- Beginning of new byte
            si_byte(7) <= si_sreg(1);
            si_index <= 6;
            si_timeout <= 0;
            rx_state <= RX_BYTE;
            si_timeout <= timeout_max;
            -- Clear any error
            si_error <= '0';
          else
            -- Stay in idle
            rx_state <= RX_ACTIVE;
          end if;
        end if;  
      when RX_BYTE => 
        -- Check for si_timeout (i.e has something gone wrong...)
        if si_timeout = 0 then
          si_error <= '1';
          rx_state <= RX_IDLE;
        elsif (cs_sreg(1) = '0')  then
          -- Transaction ended prematurely
          si_error <= '1';
          rx_state <= RX_IDLE;
        else
          si_timeout <= si_timeout - 1;
          if sck_sreg(2 downto 1) = "01" then
            -- Rising edge of sck.  
            -- Load bits one by one...
            si_byte(si_index) <= si_sreg(1);
            if si_index = 0 then
              -- End of byte
              rx_state <= RX_ACTIVE;
              si_byte_valid <= '1';
            else  
              si_index <= si_index - 1;
              rx_state <= RX_BYTE;
            end if;
          end if;
        end if;    
      when others =>
        rx_state <= RX_IDLE;
      end case;
    end if;
  end process;
  

  scntrl_proc: process(clk, rst)
  begin
    if rst = '1' then
      add_byte <= '0';
      add <= (others => '0');
      r_nw <= '0';
    elsif (clk'event and clk = '1') then
      case scntrl_state is
      when SCNTRL_IDLE => 
        if (si_byte_valid <= '1') and (si_active = '1') then
          -- Begining of new transaction.
          case si_byte is
          when "00000011" => 
            -- READ
            scntrl_state <= SCNTRL_ADD;
            add_byte <= '1';
            r_nw <= '1';
          when "00000010" => 
            -- WRITE
            scntrl_state <= SCNTRL_ADD;
            add_byte <= '1';
            r_nw <= '0';
          when "00000101" => 
            -- RDSR
            null;
          when "01000010" => 
            -- WRHF
            null;
          when others =>
            scntrl_state <= SCNTRL_IDLE;
          end case;
        end if;
      when SCNTRL_ADD => 
        if (si_active = '0') then
          -- Transaction error.  Return to idle.
          scntrl_state <= SCNTRL_IDLE;
        elsif (si_byte_valid = '1') then 
          if add_byte = '1' then
            add(15 downto 8) <= si_byte;
            add_byte <= '0';
          else
            add(7 downto 0) <= si_byte;
            scntrl_state <= SCNTRL_DATA;
          end if;
        end if;
      when SCNTRL_DATA => 
        if (si_active = '0') then
          -- End transaction.  Return to idle.
          scntrl_state <= SCNTRL_IDLE;
        elsif (si_byte_valid = '1') then
          -- Increment add counter
          add <= add + x"0001";
          if r_nw = '0' then  
            -- WRITE DATA
            wt_byte <= si_byte;
            wt_byte_valid <= '1';
          else
            -- READ DATA
            so_byte <= rd_byte;
            so_byte_valid <= '1';            
          end if;
        end if;
      when others =>
          scntrl_state <= SCNTRL_IDLE;
      end case;     

    end if;
  end process;


  so_byte_proc: process(clk, rst)
  begin
    if rst = '1' then
      tx_state <= TX_IDLE;
      so_finished <= '0';
      so_index <= 0;
    elsif (clk'event and clk = '1') then
      case tx_state is
      when TX_IDLE => 
        -- Check clk present and cs still asserted before starting transmission.
        if so_byte_valid = '1' and cs_sreg(1) = '1' then
          if sck_sreg(2 downto 1) = "10" then
            so_data <= so_byte(7);
            so_valid <= '1';
            so_index <= 6;
          end if;
        end if;
      when TX_BYTE => 
        if cs_sreg(1) = '0' then
          -- Abort transaction.  Master de-asserted CS
          tx_state <= TX_IDLE;
          so_finished <= '1';
        else
          if so_index = 0 then
            so_finished <= '1';
          elsif sck_sreg(2 downto 1) = "01" then
            so_data <= so_byte(so_index);
            so_valid <= '1';
            so_index <= so_index -1;
          end if;
        end if;    
      when others =>
        tx_state <= TX_IDLE;
      end case;
    end if;
  end process;

end behave;

