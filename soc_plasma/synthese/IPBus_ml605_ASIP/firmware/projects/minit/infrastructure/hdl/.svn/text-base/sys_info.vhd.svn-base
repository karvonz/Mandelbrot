
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.package_types.all;
use work.package_comm.all;
use work.package_modules.all;

entity sys_info is
  generic(
    module:            type_mod_define;
    sys_id:            std_logic_vector(31 downto 0) := x"00000000";
    board_id:          std_logic_vector(31 downto 0) := x"00000000";
    slave_id:          std_logic_vector(31 downto 0) := x"00000000";
    firmware_id:       std_logic_vector(31 downto 0) := x"00000000");
  port(
    clk:               in std_logic;
    rst:               in std_logic;
    comm_cntrl:        in type_comm_cntrl;
    comm_reply:        out type_comm_reply;
    test_out:          out std_logic_vector(31 downto 0));
end entity sys_info;

architecture behave of sys_info is

  -- Ensures comm cycle only takes 1 clk40 period.
  signal write_once       : std_logic;
  signal read_once        : std_logic;

  signal test: std_logic_vector(31 downto 0);
  signal module_en: std_logic;

begin

  -- Does module base address match incoming address?
  module_en <= '1' when (comm_cntrl.add and (not module.addr_mask)) = module.addr_base else '0';

  wishbone: process(clk, rst)
  begin

    if (rst = '1') then

      -- Clear comm bus
      write_once <= '0';
      read_once <= '0';
      comm_reply <= comm_reply_null;
      test <= (others => '0');

    elsif (clk'event and clk = '1') then

      if (comm_cntrl.stb = '1') and (module_en = '1') then
        -- Bus active and module selected
        comm_reply.ack <= '1';
        comm_reply.err <= '0';
        if comm_cntrl.wen = '1' then          
          -- Write active
          if (write_once ='0') then
            write_once <= '1';
            case comm_cntrl.add(7 downto 0) is
            when x"04" => 
              test <= comm_cntrl.wdata;
            when others =>
              null;
            end case;
          end if;
        else  
          -- Read active
          if (read_once ='0') then
            read_once <= '1';
            case comm_cntrl.add(7 downto 0) is
            when x"00" =>
              comm_reply.rdata <= sys_id;
            when x"01" =>
              comm_reply.rdata <= board_id;
            when x"02" =>
              comm_reply.rdata <= slave_id;
            when x"03" =>
              comm_reply.rdata <= firmware_id;
            when x"04" =>
              comm_reply.rdata <= test;
            when others =>
              comm_reply.rdata <= (others => '0');  -- spare registers
            end case;
          end if;
        end if;
      else
        -- No bus access
        write_once <= '0';
        read_once <= '0';
        comm_reply <= comm_reply_null;
      end if;

    end if;
  end process wishbone;

  test_out <= test;

end architecture behave;



