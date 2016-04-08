
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;
USE work.package_types.ALL;
USE work.package_comm.ALL;

PACKAGE package_modules IS

  ----------------------------------------------------------------------------
  -- Allows user TO specify a base/end address that can be later 
  -- used by ENTITY "module_select" TO extract a portion OF the 
  -- address space.
  ----------------------------------------------------------------------------

  
  TYPE type_mod_define is RECORD
    addr_base: std_logic_vector(31 DOWNTO 0);
    addr_end: std_logic_vector(31 DOWNTO 0);
    addr_mask: std_logic_vector(31 DOWNTO 0);
  END RECORD;

  COMPONENT module_select IS
    GENERIC(
        module:                 type_mod_define;
        module_add_width_req:   std_logic_vector(31 DOWNTO 0));
    PORT(
        rst_in:             IN std_logic;
        clk_in:               IN std_logic;
        comm_cntrl_in:       IN type_comm_cntrl;
        comm_reply_out:      OUT type_comm_reply;
        comm_cntrl_out:      OUT type_comm_cntrl;
        comm_reply_in:       IN type_comm_reply);
  END COMPONENT;

  ----------------------------------------------------------------------------
  -- IN many applications require ram AND regs.  Prefer TO have a single
  -- module defined.  USE this module TO split address space into 2 parts.
  ----------------------------------------------------------------------------

  COMPONENT sub_modules IS
    GENERIC(
        module:                 type_mod_define;
        module_add_width_req:   std_logic_vector(31 DOWNTO 0);
        comm_units:             natural := 2);
    PORT(
        rst_in:             IN std_logic;
        clk_in:               IN std_logic;
        comm_cntrl_in:          IN type_comm_cntrl;
        comm_reply_out:          OUT type_comm_reply;
        comm_bus_cntrl_out:      OUT type_comm_bus_cntrl(comm_units-1 DOWNTO 0);
        comm_bus_reply_in:      IN type_comm_bus_reply(comm_units-1 DOWNTO 0));
  END COMPONENT;

  CONSTANT module_null:             type_mod_define := (addr_base=> x"00000000",  addr_end=>x"00000000", addr_mask=>x"00000000");
  CONSTANT module_sys_info:         type_mod_define := (addr_base=> x"00001000",  addr_end=>x"00001FFF", addr_mask=>x"000000FF");
  CONSTANT module_reg_array_in:     type_mod_define := (addr_base=> x"00002000",  addr_end=>x"00002FFF", addr_mask=>x"000000FF");
  CONSTANT module_reg_array_out:    type_mod_define := (addr_base=> x"00003000",  addr_end=>x"00003FFF", addr_mask=>x"000000FF");
  CONSTANT module_si5326_i2c:       type_mod_define := (addr_base=> x"00004000",  addr_end=>x"00004FFF", addr_mask=>x"000000FF");
  CONSTANT module_snap12_tx0_i2c:   type_mod_define := (addr_base=> x"00005000",  addr_end=>x"00005FFF", addr_mask=>x"000000FF");
  CONSTANT module_snap12_rx0_i2c:   type_mod_define := (addr_base=> x"00006000",  addr_end=>x"00006FFF", addr_mask=>x"000000FF");
  CONSTANT module_snap12_rx2_i2c:   type_mod_define := (addr_base=> x"00007000",  addr_end=>x"00007FFF", addr_mask=>x"000000FF");
  CONSTANT module_ttc:              type_mod_define := (addr_base=> x"00008000",  addr_end=>x"00008FFF", addr_mask=>x"000000FF");

  CONSTANT module_daq:              type_mod_define := (addr_base=> x"00009000",  addr_end=>x"000090FF", addr_mask=>x"000000FF");
  CONSTANT module_control:          type_mod_define := (addr_base=> x"00009100",  addr_end=>x"000091FF", addr_mask=>x"000000FF");
  
  CONSTANT module_gtx0_ch0_reg:     type_mod_define := (addr_base=> x"000C0000",  addr_end=>x"000C01FF", addr_mask=>x"000001FF");
  CONSTANT module_gtx0_drp:         type_mod_define := (addr_base=> x"000C0600",  addr_end=>x"000C07FF", addr_mask=>x"000001FF");
  CONSTANT module_gtx0_ch0_ram:     type_mod_define := (addr_base=> x"000C1000",  addr_end=>x"000C1FFF", addr_mask=>x"00000FFF");
  CONSTANT module_gtx0_ch1_reg:     type_mod_define := (addr_base=> x"000C2000",  addr_end=>x"000C21FF", addr_mask=>x"000001FF");
  CONSTANT module_gtx0_ch1_ram:     type_mod_define := (addr_base=> x"000C3000",  addr_end=>x"000C3FFF", addr_mask=>x"00000FFF");
  CONSTANT module_gtx:              type_mod_define := (addr_base=> x"000C0000",  addr_end=>x"000FFFFF", addr_mask=>x"0003FFFF");

  CONSTANT module_algo:             type_mod_define := (addr_base=> x"00100000",  addr_end=>x"0011FFFF", addr_mask=>x"0001FFFF");

END package_modules;

-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
-- USE ieee.numeric_std.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
LIBRARY work;
USE work.package_modules.ALL;
USE work.package_comm.ALL;


ENTITY module_select IS
   GENERIC(
      module:                 type_mod_define;
      module_add_width_req:   std_logic_vector(31 DOWNTO 0));
   PORT(
      rst_in:             IN std_logic;
      clk_in:               IN std_logic;
      comm_cntrl_in:       IN type_comm_cntrl;
      comm_reply_out:      OUT type_comm_reply;
      comm_cntrl_out:      OUT type_comm_cntrl;
      comm_reply_in:       IN type_comm_reply);
END module_select;

ARCHITECTURE behave OF module_select IS
   SIGNAL   byte_addr: std_logic_vector(31 DOWNTO 0);
   SIGNAL   byte_addr_offset: std_logic_vector(31 DOWNTO 0);

begin

   ASSERT (module_add_width_req <= (module.addr_end + x"00000001" -  module.addr_base))
      report "Insufficient address width."
      SEVERITY failure;

   -- Originally had TO modify addres TO make it 32bit.
   byte_addr <= comm_cntrl_in.add;
   byte_addr_offset <= byte_addr - module.addr_base;

   mod_sel: PROCESS (clk_in, rst_in)
   BEGIN
      IF rst_in = '1' THEN
        comm_cntrl_out <= comm_cntrl_null;
        comm_reply_out <= comm_reply_null;
      ELSIF (clk_in'event AND clk_in = '1') THEN
         -- Always forward write data AND write enable
            comm_cntrl_out.wdata <= comm_cntrl_in.wdata;
            comm_cntrl_out.wen <= comm_cntrl_in.wen;
         -- IF module selected THEN subtract base address AND forward 
         -- read/write enables ELSE BLOCK transmission.
         IF (byte_addr >= module.addr_base) AND (byte_addr <= module.addr_end) THEN
            -- Cntrl
            comm_cntrl_out.stb <= comm_cntrl_in.stb;
            comm_cntrl_out.add <= byte_addr_offset;
            -- Reply
            comm_reply_out <= comm_reply_in;
         ELSE
            comm_cntrl_out <= comm_cntrl_null;
            comm_reply_out <= comm_reply_null;
         END IF;
      END IF;
   END PROCESS;

END behave;

-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.package_comm.ALL;
USE work.package_modules.ALL;

ENTITY sub_modules IS
   GENERIC(
      module:                 type_mod_define;
      module_add_width_req:   std_logic_vector(31 DOWNTO 0);
      comm_units:             natural := 2);
   PORT(
      rst_in:             IN std_logic;
      clk_in:               IN std_logic;
      comm_cntrl_in:          IN type_comm_cntrl;
      comm_reply_out:          OUT type_comm_reply;
      comm_bus_cntrl_out:      OUT type_comm_bus_cntrl(comm_units-1 DOWNTO 0);
      comm_bus_reply_in:      IN type_comm_bus_reply(comm_units-1 DOWNTO 0));
END sub_modules;

ARCHITECTURE behave OF sub_modules IS

   -- Local versions OF the comm signals.  signals only 
   -- allowed through 'module_select' IF module selected.
   SIGNAL comm_cntrl_mod:    type_comm_cntrl;
   SIGNAL comm_reply_mod:    type_comm_reply;

begin

   module_select_inst: ENTITY work.module_select(behave)
   GENERIC MAP(
      module                  => module,
      module_add_width_req    => module_add_width_req) 
   PORT MAP(
      rst_in                 => rst_in, 
      clk_in                   => clk_in,
      comm_cntrl_in           => comm_cntrl_in,
      comm_reply_out          => comm_reply_out,
      comm_cntrl_out          => comm_cntrl_mod,
      comm_reply_in           => comm_reply_mod);
      
   comm_mini_hub_inst: ENTITY work.comm_mini_hub
   GENERIC MAP(
      comm_units              => comm_units)
   PORT MAP(
      rst_in                  => rst_in, 
      clk_in                  => clk_in,
      comm_cntrl_in           => comm_cntrl_mod,
      comm_reply_out          => comm_reply_mod,      
      comm_bus_cntrl_out      => comm_bus_cntrl_out,
      comm_bus_reply_in       => comm_bus_reply_in);

END behave;

