library	IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all; 
use IEEE.STD_LOGIC_ARITH.all; 

entity DIVIDER_32b_4x is 
	generic(SIZE: INTEGER := 32);
	port(
		reset		: in  STD_LOGIC; 
		start		: in  STD_LOGIC; 
		clk		: in  STD_LOGIC; 
		INPUT_1	: in  STD_LOGIC_VECTOR((SIZE - 1) downto 0); 
		INPUT_2	: in  STD_LOGIC_VECTOR((SIZE - 1) downto 0); 
		OUTPUT_1	: out STD_LOGIC_VECTOR((SIZE - 1) downto 0); 
		OUTPUT_2	: out STD_LOGIC_VECTOR((SIZE - 1) downto 0);
		ready		: out STD_LOGIC 
	); 
end DIVIDER_32b_4x; 

architecture behav of DIVIDER_32b_4x is 
	signal buf	: STD_LOGIC_VECTOR((2 * SIZE - 1) downto 0); 
	signal dbuf	: STD_LOGIC_VECTOR((SIZE - 1) downto 0); 
	signal sm	: INTEGER range 0 to (SIZE/4); 

	alias buf1 is buf((2 * SIZE - 1) downto SIZE); 
	alias buf2 is buf((SIZE - 1) downto 0); 
begin 

	process(reset, start, clk) 
		variable tbuf1	: STD_LOGIC_VECTOR((2*SIZE - 1) downto 0); 
		variable tbuf2	: STD_LOGIC_VECTOR((2*SIZE - 1) downto 0); 
		variable tbuf3	: STD_LOGIC_VECTOR((2*SIZE - 1) downto 0); 
	begin 
	if reset = '1' then 
		OUTPUT_1 <= (others => '0'); 
		OUTPUT_2 <= (others => '0'); 
		sm     	<= 0; 
		ready  	<= '0'; 
	elsif rising_edge(clk) then 
			case sm is 
				when 0 => 
					OUTPUT_1 <= buf2; 
					OUTPUT_2 <= buf1; 
					ready 	<= '0';
					buf2  	<= (others => 'X'); 
					dbuf  	<= INPUT_2; 
					buf1  	<= (others => 'X'); 
					if start = '1' then 
						buf1 <= (others => '0'); 
						buf2 <= INPUT_1; 
						sm   <= sm + 1;
					else
						sm <= sm;
					end if;

				when others => 
				
					-- PREMIERE ITERATION DEROULEE DE LA DIVISION
					if buf((2 * SIZE - 2) downto (SIZE - 1)) >= dbuf then 
						tbuf1((2 * SIZE - 1) downto SIZE) := '0' & (buf((2 * SIZE - 3) downto (SIZE - 1)) - dbuf((SIZE - 2) downto 0)); 
						tbuf1((SIZE - 1)     downto    0) := buf2((SIZE - 2) downto 0) & '1'; -- ON POUSSE LE RESULTAT
					else 
						tbuf1 := buf((2 * SIZE - 2) downto 0) & '0';
					end if; 

					-- QUATRIEME ITERATION DEROULEE DE LA DIVISION
					if tbuf1((2 * SIZE - 2) downto (SIZE - 1)) >= dbuf then 
						tbuf2((2 * SIZE - 1) downto SIZE)  := '0' & (tbuf1((2 * SIZE - 3) downto (SIZE - 1)) - dbuf((SIZE - 2) downto 0)); 
						tbuf2((SIZE - 1)     downto    0)  := tbuf1((SIZE - 2) downto 0) & '1'; 
					else 
						tbuf2 := tbuf1((2 * SIZE - 2) downto 0) & '0'; 
					end if; 

					-- TROISIEME ITERATION DEROULEE DE LA DIVISION
					if tbuf2((2 * SIZE - 2) downto (SIZE - 1)) >= dbuf then 
						tbuf3((2 * SIZE - 1) downto SIZE)  := '0' & (tbuf2((2 * SIZE - 3) downto (SIZE - 1)) - dbuf((SIZE - 2) downto 0)); 
						tbuf3((SIZE - 1)     downto    0)  := tbuf2((SIZE - 2) downto 0) & '1'; 
					else 
						tbuf3 := tbuf2((2 * SIZE - 2) downto 0) & '0'; 
					end if; 

					-- QUATRIEME ITERATION DEROULEE DE LA DIVISION
					if tbuf3((2 * SIZE - 2) downto (SIZE - 1)) >= dbuf then 
						buf1((2 * SIZE - 1) downto SIZE)  <= '0' & (tbuf3((2 * SIZE - 3) downto (SIZE - 1)) - dbuf((SIZE - 2) downto 0)); 
						buf2((SIZE - 1)     downto    0)  <= tbuf3((SIZE - 2) downto 0) & '1'; 
					else 
						buf <= tbuf3((2 * SIZE - 2) downto 0) & '0'; 
					end if; 

					-- QUEL VA ETRE NOTRE PROCHAIN ETAT ?
					if sm /= (SIZE/4) then 
						sm    <= sm + 1; 
						ready <= '0';
					else 
						sm    <= 0; 
						ready <= '1';
					end if; 
				end case; 
		end if; 
	end process; 

end behav;
