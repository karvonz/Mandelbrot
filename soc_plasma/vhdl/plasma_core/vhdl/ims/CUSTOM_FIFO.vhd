library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CUSTOM_FIFO is
   generic (
		ADD_WIDTH : integer := 4;  	-- FIFO word width
		WIDTH     : integer := 32
	); -- Address Width
	port (
		rst 		 : in  std_logic;  	   		-- System global Reset
		clk 		 : in  std_logic;  		   	-- System Clock
		flush     : in  STD_LOGIC;
		holdn     : in  STD_LOGIC;

		INPUT_1 	 : IN  STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
		write_en	 : in  STD_LOGIC;
		in_full	 : OUT  STD_LOGIC;

		OUTPUT_1	 : OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
		read_en	 : in  STD_LOGIC;
		out_empty : OUT  STD_LOGIC;

		Next_Empty 	: out 	std_logic
	);
end CUSTOM_FIFO;


architecture ARCH_CUSTOM_FIFO of CUSTOM_FIFO is

	-- constant values
	constant MAX_ADDR  : UNSIGNED(ADD_WIDTH -1 downto 0)  := (others => '1');

   signal R_ADD   : UNSIGNED(ADD_WIDTH - 1 downto 0);  -- Read Address
   signal W_ADD   : UNSIGNED(ADD_WIDTH - 1 downto 0);  -- Write Address
   signal D_ADD   : UNSIGNED(ADD_WIDTH - 1 downto 0);  -- Diff Address

   --signal WEN_INT : std_logic;  		-- Internal Write Enable

	signal  sFull  :  std_logic;  		-- Full Flag
	signal  sEmpty :  std_logic; 	-- Empty Flag

	-- DECLARATION DE LA MEMOIRE
	TYPE data_array IS ARRAY (integer range <>) OF std_logic_vector(WIDTH -1  DOWNTO 0);
	SIGNAL data : data_array(0 to (2** add_width) );  -- Local data
    
begin

	-- PROCESSUS DECRIVANT LE COMPORTEMENT DE LA MEMOIRE RAM
	PROCESS (clk, rst)
		VARIABLE COUNTER         : UNSIGNED(ADD_WIDTH-1 downto 0);  -- Diff Address
		VARIABLE NextReadAdress  : UNSIGNED(ADD_WIDTH-1 downto 0);  -- Diff Address
		VARIABLE a : integer := 0;
	BEGIN
		IF rst = '0' THEN
			W_ADD <= (others =>'0');
			R_ADD <= (others =>'0');
			D_ADD <= (others =>'0');
			
			FOR a IN 0 TO (2** add_width) LOOP
				data( a ) <= (others => '0');
			END LOOP;

		ELSIF clk'event AND clk = '1' THEN

			COUNTER := UNSIGNED( D_ADD );
			
			if WRITE_EN = '1' and ( sFULL = '0') then
				W_ADD   <= W_ADD + 1;
				COUNTER := COUNTER + 1;
			end if;
			
			NextReadAdress := R_ADD;
			
			if READ_EN = '1' and ( sEMPTY = '0') then
				--REPORT "FIFO DATA READ ACTION";
				NextReadAdress  := NextReadAdress + 1;
				COUNTER         := COUNTER - 1;
			end if;

			R_ADD <= NextReadAdress;
			D_ADD <= COUNTER;
			
			IF WRITE_EN = '1' THEN
				--REPORT "FIFO DATA WRITE ACTION";
				data( to_integer( W_add ) ) <= INPUT_1;
			END IF;

			-- AFFECTATION DIRECTE DE LA SORTIE DE LA FIFO
		END IF;
	END PROCESS;
	
	OUTPUT_1 <= data( to_integer( R_ADD ) );
	--OUTPUT_1 <= data( to_integer( NextReadAdress ) );

	--FULL    <=  '1' when (D_ADD(ADD_WIDTH - 1 downto 0) = MAX_ADDR)  else '0';
	-- ON REGARDE SI LA FIFO EST FULL
	sFULL   <=  '1' when (D_ADD = MAX_ADDR)  else '0';
	in_FULL <= sFULL;

	-- ON REGARDE SI LA FIFO EST EMPTY
	sEMPTY    <=  '1' when UNSIGNED(D_ADD) = TO_UNSIGNED(0, ADD_WIDTH) else '0';
	out_EMPTY <=  sEMPTY;

	--wen_int <=  '1' when (WRITE_EN = '1' and ( sFULL = '0')) else '0';

	-- ON REAGRDE SI LA FIFO SERA EMPTY AU PROCHAIN CYCLE D'HORLOGE
	process(D_ADD, READ_EN, WRITE_EN, sEMPTY)
	begin
		IF (UNSIGNED(D_ADD) = TO_UNSIGNED(1, ADD_WIDTH)) AND (READ_EN = '1' AND WRITE_EN = '0') THEN
			Next_Empty <= '1';
		ELSIF (UNSIGNED(D_ADD) = TO_UNSIGNED(0, ADD_WIDTH)) AND (READ_EN = '1' AND WRITE_EN = '1') THEN
			Next_Empty <= '1';
		ELSIF (sEMPTY = '1') AND (WRITE_EN = '1' AND READ_EN = '0') THEN
			Next_Empty <= '0';
		ELSE
			Next_Empty <= sEMPTY;
		END IF;
   end process;
        
end ARCH_CUSTOM_FIFO;
