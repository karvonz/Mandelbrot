
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY unisim;
USE unisim.vcomponents.ALL;


ENTITY minit_gtx_txusrclk IS
GENERIC (    
    performance_mode    : string   := "MAX_SPEED";
    clkfx_divide        : integer := 5;
    clkfx_multiply      : integer := 4;
    dfs_frequency_mode  : string := "LOW";
    dll_frequency_mode  : string := "LOW");
PORT (
    clk_in                    : IN  std_logic;
    dcm_reset_in              : IN  std_logic;
    clk_d2_out                : OUT std_logic;
    clk_x1_out                : OUT std_logic;
    clk_x2_out                : OUT std_logic;
    clk_fx_out                : OUT std_logic;
    dcm_locked_out            : OUT std_logic);
END minit_gtx_txusrclk;

ARCHITECTURE rtl OF minit_gtx_txusrclk IS

    SIGNAL clk_x1, clk_x1_int  : std_logic;
    SIGNAL clk_x2, clk_x2_int  : std_logic;
    SIGNAL clk_d2, clk_d2_int  : std_logic;
    SIGNAL clk_fx, clk_fx_int  : std_logic;
    SIGNAL clk_x2_delta_delay  : std_logic;

begin

    clock_divider_i : dcm_base
    GENERIC MAP
    (
      clkdv_divide          => 2.0,
      clkfx_divide          => clkfx_divide,
      clkfx_multiply        => clkfx_multiply,
      dfs_frequency_mode    => dfs_frequency_mode,
      dll_frequency_mode    => dll_frequency_mode,  -- Was HIGH should probably be LOW
      dcm_performance_mode  => performance_mode
    )    
    PORT MAP
    (
      clk0       =>  clk_x1,
      clk180     =>  open,
      clk270     =>  open,
      clk2x      =>  clk_x2,
      clk2x180   =>  open,
      clk90      =>  open,
      clkdv      =>  clk_d2,
      clkfx      =>  clk_fx,
      clkfx180   =>  open,
      locked     =>  dcm_locked_out,
      clkfb      =>  clk_x1_int,
      clkin      =>  clk_in,
      rst        =>  dcm_reset_in);

    dcm_x1_bufg_i : bufg
    PORT MAP(
      i  =>  clk_x1,
      o  =>  clk_x1_int);
    
    dcm_d2_bufg_i : bufg 
    PORT MAP (
      i  =>  clk_d2,
      o  =>  clk_d2_int);

    dcm_x2_bufg_i : bufg 
    PORT MAP (
      i  =>  clk_x2,
      o  =>  clk_x2_int);

    dcm_fx_bufg_i : bufg 
    PORT MAP (
      i  =>  clk_fx,
      o  =>  clk_fx_int);

   -- This is TO fix delta delays between clks...
   clk_x2_delta_delay <= clk_x2_int AFTER 0.1 ns;

   PROCESS(clk_x2_delta_delay)
   BEGIN
      clk_d2_out <= clk_d2_int; 
      clk_x1_out <= clk_x1_int; 
      clk_x2_out <= clk_x2_int; 
      clk_fx_out <= clk_fx_int; 
   END PROCESS;

END rtl;

