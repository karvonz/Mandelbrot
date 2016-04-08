
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY work;
USE work.package_types.ALL;
USE work.package_comm.ALL;
USE work.package_modules.ALL;

  PACKAGE package_reg IS
  
  COMPONENT reg_array_in IS
    GENERIC(
        module:                    type_mod_define;
        number_of_words:           natural := 16);
    PORT( 
        rstb_in:                   IN std_logic;
        clk_in:                     IN std_logic;
        comm_cntrl:                IN type_comm_cntrl;
        comm_reply:                OUT type_comm_reply;
        data_array_in:             IN type_vector_of_stdlogicvec_x32(number_of_words-1 DOWNTO 0));
  END COMPONENT;
  
  COMPONENT reg_array_out IS
    GENERIC(
        module:                    type_mod_define;
        number_of_words:           natural := 16);
    PORT( 
        rstb_in:                   IN std_logic;
        clk_in:                     IN std_logic;
        comm_cntrl:                IN type_comm_cntrl;
        comm_reply:                OUT type_comm_reply;
        data_array_out:            OUT type_vector_of_stdlogicvec_x32(number_of_words-1 DOWNTO 0));
  END COMPONENT;
  
  COMPONENT reg_array_inout IS
    GENERIC(
        module:                    type_mod_define;
        module_active:             std_logic;
        number_of_rw_words:        natural := 16;
        number_of_ro_words:        natural := 16);
    PORT( 
        rstb_in:                   IN std_logic;
        clk_in:                     IN std_logic;
        comm_cntrl:                IN type_comm_cntrl;
        comm_reply:                OUT type_comm_reply;
        rw_default_array_in:       IN type_vector_of_stdlogicvec_x32(number_of_rw_words-1 DOWNTO 0);
        rw_data_array_out:         OUT type_vector_of_stdlogicvec_x32(number_of_rw_words-1 DOWNTO 0);
        ro_data_array_in:          IN type_vector_of_stdlogicvec_x32(number_of_ro_words-1 DOWNTO 0));
  END COMPONENT;

END package_reg;



-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
LIBRARY work;
USE work.package_types.ALL;
USE work.package_comm.ALL;
USE work.package_modules.ALL;

ENTITY reg_array_in IS
   GENERIC(
      module:                    type_mod_define;
      number_of_words:           natural := 16);
   PORT( 
      rstb_in:                   IN std_logic :='0';
      clk_in:                     IN std_logic :='0';
      comm_cntrl:                IN type_comm_cntrl;
      comm_reply:                OUT type_comm_reply;
      data_array_in:             IN type_vector_of_stdlogicvec_x32(number_of_words-1 DOWNTO 0) := (others=>(others=>'0'))
	  );
END reg_array_in;

ARCHITECTURE behave OF reg_array_in IS

   SIGNAL index: natural RANGE 0 TO 63 := 0;
   SIGNAL data_array: type_vector_of_stdlogicvec_x32(number_of_words-1 DOWNTO 0) := (others=>(others=>'0'));

   -- Ensures comm cycle only takes 1 clk_in period.
   SIGNAL read_once: std_logic := '0';

   SIGNAL comm_enable: std_logic := '0';

begin

  ASSERT (number_of_words <= 64)
    report "A maximum OF 64 32bit words is supported."
    SEVERITY failure;
  
  -- Does module base address match incoming address?
  comm_enable <= '1' WHEN (comm_cntrl.add AND (NOT module.addr_mask)) = module.addr_base ELSE '0';
  
  -- Comm interface uses byte adress. We require 32bit data words.
  index <= to_integer(unsigned(comm_cntrl.add(7 DOWNTO 2)));
  
  mem_access: PROCESS(rstb_in, clk_in)
  BEGIN
    IF (rstb_in = '0') THEN

      -- Clear comm BUS
      read_once <= '0';
      comm_reply <= comm_reply_null;

    ELSIF (clk_in = '1' AND clk_in'event) THEN

      IF (comm_cntrl.stb = '1' AND comm_enable = '1') THEN
        -- BUS active AND module selected
        comm_reply.ack <= '1';
        comm_reply.err <= '0';
        IF comm_cntrl.wen = '0' THEN
          --  Read active
          IF (read_once ='0') THEN
              read_once <= '1';
              comm_reply.rdata <= data_array(index);
          END IF;
        END IF;
      ELSE
        -- No BUS transaction
        read_once <= '0';
        comm_reply <= comm_reply_null;
      END IF;

      -- REGISTER inputs
      data_array <= data_array_in;

    END IF;
  END PROCESS;

END behave;

-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
LIBRARY work;
USE work.package_types.ALL;
USE work.package_comm.ALL;
USE work.package_modules.ALL;

ENTITY reg_array_out IS
   GENERIC(
      module:                    type_mod_define;
      number_of_words:           natural := 16);
   PORT( 
      rstb_in:                   IN std_logic :='0';
      clk_in:                     IN std_logic :='0';
      comm_cntrl:                IN type_comm_cntrl;
      comm_reply:                OUT type_comm_reply;
      data_array_out:            OUT type_vector_of_stdlogicvec_x32(number_of_words-1 DOWNTO 0) := (others=>(others=>'0'))
	  );
END reg_array_out;

ARCHITECTURE behave OF reg_array_out IS

   SIGNAL index: natural RANGE 0 TO 63 := 0;
   SIGNAL data_array: type_vector_of_stdlogicvec_x32(number_of_words-1 DOWNTO 0) := (others=>(others=>'0'));

   -- Ensures comm cycle only takes 1 clk_in period.
   SIGNAL write_once       : std_logic :='0';
   SIGNAL read_once        : std_logic :='0';

   SIGNAL comm_enable: std_logic :='0';

begin

  ASSERT (number_of_words <= 64)
    report "A maximum OF 64 32bit words is supported."
    SEVERITY failure;
  
  -- Does module base address match incoming address?
  comm_enable <= '1' WHEN (comm_cntrl.add AND (NOT module.addr_mask)) = module.addr_base ELSE '0';
  
  -- Comm interface uses byte adress. We require 32bit data words.
  index <= to_integer(unsigned(comm_cntrl.add(7 DOWNTO 2)));
  
  mem_access: PROCESS(rstb_in, clk_in)
  BEGIN
    IF (rstb_in = '0') THEN

      -- Clear comm BUS
      write_once <= '0';
      read_once <= '0';
      comm_reply <= comm_reply_null;
      -- Clear RAM
      data_array <= (OTHERS => x"00000000");

    ELSIF (clk_in = '1' AND clk_in'event) THEN

      IF (comm_cntrl.stb = '1' AND comm_enable = '1') THEN
        -- BUS active AND module selected
        comm_reply.ack <= '1';
        comm_reply.err <= '0';
        IF comm_cntrl.wen = '1' THEN
          --  Write active
          IF (write_once ='0') THEN
              write_once <= '1';
              data_array(index) <= comm_cntrl.wdata;
          END IF;
        ELSE
          -- Read active
          IF (read_once ='0') THEN
              read_once <= '1';
              comm_reply.rdata <= data_array(index);
          END IF;
        END IF;
      ELSE
        -- No BUS transaction
        read_once <= '0';
        write_once <= '0';
        comm_reply <= comm_reply_null;
      END IF;

    END IF;
  END PROCESS;
  
  data_array_out <= data_array;

END behave;

-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   
-------------------------------------------------------------------------------------------------   


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
LIBRARY work;
USE work.package_types.ALL;
USE work.package_comm.ALL;
USE work.package_modules.ALL;

ENTITY reg_array_inout IS
   GENERIC(
      module:                    type_mod_define;
      module_active:             std_logic := '1';
      number_of_rw_words:        natural := 16;
      number_of_ro_words:        natural := 16);
   PORT( 
      rstb_in:                   IN std_logic := '0';
      clk_in:                     IN std_logic := '0';
      comm_cntrl:                IN type_comm_cntrl;
      comm_reply:                OUT type_comm_reply;
      rw_default_array_in:       IN type_vector_of_stdlogicvec_x32(number_of_rw_words-1 DOWNTO 0) := (others=>(others=>'0'));
      rw_data_array_out:         OUT type_vector_of_stdlogicvec_x32(number_of_rw_words-1 DOWNTO 0) := (others=>(others=>'0'));
      ro_data_array_in:          IN type_vector_of_stdlogicvec_x32(number_of_ro_words-1 DOWNTO 0) := (others=>(others=>'0'))
	  );
END reg_array_inout;

ARCHITECTURE behave OF reg_array_inout IS

  SIGNAL index: natural RANGE 0 TO 63 := 0;
  SIGNAL rw_data_array: type_vector_of_stdlogicvec_x32(number_of_rw_words-1 DOWNTO 0)  := (others=>(others=>'0'));

  -- Ensures comm cycle only takes 1 clk_in period.
  SIGNAL read_once         : std_logic :='0';
  SIGNAL write_once        : std_logic := '0';

  TYPE reg_access_type IS (READ_ONLY, READ_WRITE, NONE);
  SIGNAL reg_access: reg_access_type;

  SIGNAL comm_enable: std_logic := '0';

begin

  ASSERT (number_of_ro_words + number_of_rw_words <= 64)
    report "A maximum OF 64 32bit words is supported."
    SEVERITY failure;
  
  -- Does module base address match incoming address?
  comm_enable_proc: PROCESS(comm_cntrl)
  BEGIN
    IF module_active='1' THEN
      IF (comm_cntrl.add AND (NOT module.addr_mask)) = module.addr_base THEN
        comm_enable <= '1';
      ELSE
        comm_enable <= '0';
      END IF;
    ELSE
      comm_enable <= '1';
    END IF;
  END PROCESS;

  -- Comm interface uses byte adress. We require 32bit data words.
  index <= to_integer(unsigned(comm_cntrl.add(7 DOWNTO 2)));
  
  mem_type: PROCESS(rstb_in, index)
  BEGIN
    IF rstb_in = '0' THEN
        reg_access <= NONE;
    ELSE
      IF index < number_of_ro_words THEN 
        reg_access <= READ_ONLY;
      ELSIF index < (number_of_ro_words + number_of_rw_words) THEN
        reg_access <= READ_WRITE;
      ELSE
        reg_access <= NONE;
      END IF;
    END IF;
  END PROCESS;
  
  --------------------------------------------------------------------------
  -- Regs
  --------------------------------------------------------------------------
  
  mem_access: PROCESS(rstb_in, clk_in)
  BEGIN
    IF (rstb_in = '0') THEN
  
      -- Clear comm BUS
      write_once <= '0';
      read_once <= '0';
      comm_reply <= comm_reply_null;
      -- Clear RAM
      rw_data_array <= rw_default_array_in;
  
    ELSIF (clk_in = '1' AND clk_in'event) THEN
  
      IF (comm_cntrl.stb = '1' AND comm_enable = '1') THEN
        -- BUS active AND module selected
        comm_reply.ack <= '1';
        comm_reply.err <= '0';
        IF comm_cntrl.wen = '1' THEN
          -- Write active
          IF (write_once ='0') THEN
            write_once <= '1';
            CASE reg_access IS
              WHEN READ_WRITE => 
                rw_data_array(index - number_of_ro_words) <= comm_cntrl.wdata;
              WHEN OTHERS =>
                NULL;
            END CASE;
          END IF;
        ELSE
          --Read active  
          IF (read_once ='0') THEN
            read_once <= '1';
            CASE reg_access IS
              WHEN READ_ONLY =>
                comm_reply.rdata <= ro_data_array_in(index);
              WHEN READ_WRITE => 
                comm_reply.rdata <= rw_data_array(index - number_of_ro_words);
              WHEN OTHERS =>
                comm_reply.rdata <= (OTHERS => '0');
            END CASE;
          END IF;
        END IF;
      ELSE
        -- clk_in cycle without read comm transaction
        read_once <= '0';
        write_once <= '0';
        comm_reply <= comm_reply_null;
      END IF;
        
    END IF;
  END PROCESS;
  
  rw_data_array_out <= rw_data_array;

END behave;



