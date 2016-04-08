library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library grlib;
--use grlib.stdlib.all;

--library gaisler;
--use gaisler.arith.all;

library ims;
use ims.coprocessor.all;
--use ims.conversion.all;

entity RESOURCE_CUSTOM_6 is
	port (
		rst        : in  std_ulogic;
		clk        : in  std_ulogic;
		holdn      : in  std_ulogic;
		inp  	   : in  async32_in_type;
		outp 	   : out async32_out_type
	);
end;

architecture rtl of RESOURCE_CUSTOM_6 is
	signal A 		: std_logic_vector(31 downto 0);
	signal B 		: std_logic_vector(31 downto 0);
  	signal wBuffer  : std_logic_vector(1  downto 0);
  	signal rBuffer  : std_logic_vector(1  downto 0);
	
    COMPONENT ASYNC_RGB_2_YUV
    PORT(
         rst        : IN  std_logic;
         clk        : IN  std_logic;
         flush      : IN  std_logic;
         holdn      : IN  std_logic;
         INPUT_1    : IN  std_logic_vector(31 downto 0);
         write_en   : IN  std_logic;
         in_full    : OUT  std_logic;
         OUTPUT_1   : OUT  std_logic_vector(31 downto 0);
         read_en    : IN  std_logic;
         out_empty  : OUT  std_logic;
         Next_Empty : OUT  std_logic
        );
    END COMPONENT;
 	
    COMPONENT CUSTOM_FIFO
    PORT(
         rst        : IN  std_logic;
         clk        : IN  std_logic;
         flush      : IN  std_logic;
         holdn      : IN  std_logic;
         INPUT_1    : IN  std_logic_vector(31 downto 0);
         write_en   : IN  std_logic;
         in_full    : OUT  std_logic;
         OUTPUT_1   : OUT  std_logic_vector(31 downto 0);
         read_en    : IN  std_logic;
         out_empty  : OUT  std_logic;
         Next_Empty : OUT  std_logic
        );
    END COMPONENT;
 	
   signal INPUT_1    : std_logic_vector(31 downto 0) := (others => '0');
   signal write_en   : std_logic;
   signal read_en    : std_logic;
   signal in_full    : std_logic;
   signal OUTPUT_1   : std_logic_vector(31 downto 0);
   signal out_empty  : std_logic;
   signal Next_Empty : std_logic;
	
begin

	write_en <= (wBuffer(0) AND holdn);
	read_en  <= (rBuffer(1) AND holdn);
	
	--uut: CUSTOM_FIFO PORT MAP (
	uut: ASYNC_RGB_2_YUV PORT MAP (
        rst        => rst,
        clk        => clk,
        flush      => '0',
        holdn      => '0',
        INPUT_1    => inp.op1(31 downto 0),
        write_en   => write_en,
        in_full    => in_full,
        OUTPUT_1   => outp.result,
        read_en    => read_en,
        out_empty  => out_empty,
        Next_Empty => Next_Empty
    );

		
		
	-------------------------------------------------------------------------
	-- synthesis translate_off 
  	process
  	begin
    	wait for 1 ns;
		printmsg("(IMS) RESOURCE_CUSTOM_6 : ALLOCATION OK !");
    	wait;
  	end process;
	-- synthesis translate_on 
	-------------------------------------------------------------------------

	-- type async32_in_type is record
	-- op1        : std_logic_vector(32 downto 0); -- operand 1
	-- op2        : std_logic_vector(32 downto 0); -- operand 2
	-- signed     : std_logic;
	-- write_data : std_logic;
	-- read_data  : std_logic;
	-- end record;

	-- type async32_out_type is record
	-- ready           : std_logic;
	-- nready          : std_logic;
	-- icc             : std_logic_vector(3  downto 0);
	-- result          : std_logic_vector(31 downto 0);
	-- end record;

	-------------------------------------------------------------------------
  	reg : process(clk)
  		variable vready  : std_logic;
		variable vnready : std_logic;
  	begin 
    	vready  := '0';
		vnready := '0';
    	
		if rising_edge(clk) then 
			if (rst = '0') then
				--assert false report "STATE XXX => RESET";
				--elsif (inp.flush = '1') then
				--assert false report "STATE XXX => (inp.flush = '1')";
				--state <= "000";
			elsif (holdn = '0') then
				--assert false report "STATE XXX => (holdn = '1')";
				--state <= state;
				rBuffer <= rBuffer;
				wBuffer <= wBuffer;

			else
				rBuffer <= rBuffer(0) & inp.read_data;
				wBuffer <= wBuffer(0) & inp.write_data;
				
				if( wBuffer(0) = '1' ) then
					--printmsg("(IOs) DATA ARE SENDED TO THE INTERFACE (1)");
					--printmsg("(IOs) - COMPUTATION INPUT_A IS (" & to_int_str(inp.op1(31 downto 0),6) & " )");
					--printmsg("(IOs) - COMPUTATION INPUT_B IS (" & to_int_str(inp.op2(31 downto 0),6) & " )");
					A <= inp.op1(31 downto 0);
					B <= inp.op2(31 downto 0);
				end if;
				
				if( rBuffer(1) = '1' ) then
					--printmsg("(IOs) DATA READ FROM THE INTERFACE");
					--printmsg("(IOs) - COMPUTATION INPUT_A IS (" & to_int_str(A,6) & " )");
					--printmsg("(IOs) - COMPUTATION INPUT_B IS (" & to_int_str(B,6) & " )");
					A <= "00000000000000000000000000000000";
				end if;
				
    			outp.ready  <= vready;
				outp.nready <= vnready;
			end if; 	-- if reset
    	end if;		-- if clock
  	end process;
	-------------------------------------------------------------------------
	
   --outp.result <= A;
   outp.icc    <= "0000";

end;
