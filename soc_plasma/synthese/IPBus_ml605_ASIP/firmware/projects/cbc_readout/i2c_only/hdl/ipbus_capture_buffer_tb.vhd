--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:54:03 05/20/2011
-- Design Name:   
-- Module Name:   /automount/users/phdgc/IPBus/cbc_readout/i2c_only/ipbus_capture_buffer_tb.vhd
-- Project Name:  ipbus_demo_sp601
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ipbus_capture_buffer
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

use work.ipbus.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY ipbus_capture_buffer_tb IS
END ipbus_capture_buffer_tb;
 
ARCHITECTURE behavior OF ipbus_capture_buffer_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ipbus_capture_buffer
    PORT(
         ipbus_clk_i : IN  std_logic;
         ipbus_i : IN  ipb_wbus;
         ipbus_o : OUT ipb_rbus;
         reset_i : IN  std_logic;
         cap_clk_i : IN  std_logic;
         cap_d_i : IN  std_logic;
         cap_go_i : IN  std_logic;
         cap_edge_i : IN  std_logic
        );
    END COMPONENT;
    

    -- Wishbone signals
    signal ipbus_o : ipb_rbus;
    signal ipbus_i : ipb_wbus;

    --Inputs
   signal ipbus_clk_i : std_logic := '0';
   signal reset_i : std_logic := '0';
--   signal cap_clk_i : std_logic := '0';
   signal cap_d_i : std_logic := '0';
   signal cap_go_i : std_logic := '0';
   signal cap_edge_i : std_logic := '0';
 
   constant ipbus_clk_i_period : time := 10 ns;

    -- test data. 10* 32-bit words = 80 hex characters
    constant c_cbc_data : std_logic_vector(319 downto 0) :=
      x"0000F0F00123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF01234560";
--      01234567890123456789012345678901234567890123456789012345678901234567890123456789
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ipbus_capture_buffer PORT MAP (
          ipbus_clk_i => ipbus_clk_i,
          ipbus_i => ipbus_i,
          ipbus_o => ipbus_o,
          reset_i => reset_i,
          cap_clk_i => ipbus_clk_i,
          cap_d_i => cap_d_i,
          cap_go_i => cap_go_i,
          cap_edge_i => cap_edge_i
        );

   -- Clock process definitions
   ipbus_clk_i_process :process
   begin
		ipbus_clk_i <= '0';
		wait for ipbus_clk_i_period/2;
		ipbus_clk_i <= '1';
		wait for ipbus_clk_i_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin

     -- set wishbone to idle
     ipbus_i.ipb_wdata <= (others => '0');
     ipbus_i.ipb_addr <= (others => '0');
     ipbus_i.ipb_strobe <= '0';
     ipbus_i.ipb_write <= '0';
     reset_i <= '1';

     -- hold reset state for 100 ns.
      wait for 100 ns;	
     reset_i <= '0';
     
      wait for ipbus_clk_i_period*10;

      -- insert stimulus here 

     wait until rising_edge(ipbus_clk_i);
     cap_go_i <= '1';
     wait until rising_edge(ipbus_clk_i);
     cap_go_i <= '0';
     
     for bit in c_cbc_data'range loop
       wait until rising_edge(ipbus_clk_i);  
       cap_d_i <= c_cbc_data(bit);
     end loop;  -- bit

     wait;
   end process;

END;
