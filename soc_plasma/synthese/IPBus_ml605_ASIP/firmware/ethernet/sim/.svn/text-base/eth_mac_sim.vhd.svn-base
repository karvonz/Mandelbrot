-- A simulated MAC core. Uses the FLI mechanism to send / receive packets
-- via a tun/tap virtual interface.
--
-- There is a 'one-in, one-out' assumption for packets, i.e. multiple packets
-- can be processed at the same time. A timeout applies in case the firmware
-- decides not to reply to a packet.
--
-- Dave Newbold, March 2011
--
-- $Id$

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity eth_mac_sim is port(
  clk125, rst: in std_logic;
  txd: in std_logic_vector(7 downto 0);
  txdvld: in std_logic;
  txack: out std_logic;
  rxd: out std_logic_vector(7 downto 0);
  rxdvld, rxgoodframe, rxbadframe: out std_logic);

end eth_mac_sim;

architecture behavioural of eth_mac_sim is

  procedure get_mac_data(
    variable mac_data_out, mac_data_valid: out integer)
  is begin
    report "ERROR: get_mac_data can't get here";
  end;
  
  attribute FOREIGN of get_mac_data : procedure is "get_mac_data mac_fli.so";
  
  procedure store_mac_data(
    variable mac_data_in: in integer)
  is begin
    report "ERROR: store_mac_data can't get here";
  end;
  
  attribute FOREIGN of store_mac_data : procedure is "store_mac_data mac_fli.so";
  
  procedure put_packet
  is begin
    report "ERROR: put_packet can't get here";
  end;
  
  attribute FOREIGN of put_packet : procedure is "put_packet mac_fli.so";

  constant timeout: integer := 8192;

  signal txdvld_d, rxdvld_d, rxdvld_int: std_logic;
  signal rxen: std_logic;
  signal timer: integer;
  
  
begin

  rxbadframe <= '0';
  rxdvld <= rxdvld_int;
  rxgoodframe <= rxdvld_d and not rxdvld_int;

  packet_rx: process(clk125)    
    variable data, datav: integer;
  begin
    if rising_edge(clk125) then

      if rst='1' then
        rxen <= '1';
        timer <= 0;
      elsif rxen='1' then
        get_mac_data(mac_data_out => data, mac_data_valid => datav);
        rxd <= std_logic_vector(to_unsigned(data,8));
        if datav=1 then
          rxdvld_int <= '1';
        else
          rxdvld_int <= '0';
          if rxdvld_d='1' then
            rxen <= '0';
          end if;          
        end if;
      else
        if (txdvld='0' and txdvld_d='1') or timer=timeout then
          rxen <= '1';
          timer <= 0;
        else
          timer <= timer + 1;
        end if;
      end if;
    
      rxdvld_d <= rxdvld_int;                    
    
    end if;
  end process;  

  packet_tx: process(clk125)
    variable data: integer;
  begin
      if rising_edge(clk125) then
                    
        txdvld_d <= txdvld;

        if txdvld='1' then
          data := to_integer(unsigned(txd));
          store_mac_data(mac_data_in => data);
        elsif txdvld_d='1' then
          put_packet;
        end if;
          
      end if;
  end process;
          
  txack <= txdvld and not txdvld_d;

end behavioural;
