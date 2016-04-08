library	IEEE; 
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_UNSIGNED.all; 
use IEEE.STD_LOGIC_ARITH.all; 

entity DIVIDER_32b_4x_fast is 
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
end DIVIDER_32b_4x_fast; 

ARCHITECTURE behav of DIVIDER_32b_4x_fast IS 
	signal buf	: STD_LOGIC_VECTOR((2 * SIZE - 1) downto 0); 
	signal dbuf	: STD_LOGIC_VECTOR((SIZE - 1) downto 0); 
	signal sm	: INTEGER range 0 to (SIZE/4); 

	alias buf1 is buf((2 * SIZE - 1) downto SIZE); 
	alias buf2 is buf((SIZE - 1) downto 0); 
begin 

	process(reset, start, clk) 
		variable tbuf2		: STD_LOGIC_VECTOR((2*SIZE - 1) downto 0); 
		variable tbuf1v	: STD_LOGIC_VECTOR((2*SIZE - 1) downto 0); 
		variable tbuf1f	: STD_LOGIC_VECTOR((2*SIZE - 1) downto 0); 
		variable tbuf2vv	: STD_LOGIC_VECTOR((2*SIZE - 1) downto 0); 
		variable tbuf2vf	: STD_LOGIC_VECTOR((2*SIZE - 1) downto 0); 
		variable tbuf2fv	: STD_LOGIC_VECTOR((2*SIZE - 1) downto 0); 
		variable tbuf2ff	: STD_LOGIC_VECTOR((2*SIZE - 1) downto 0); 
		variable tbuf3v	: STD_LOGIC_VECTOR((2*SIZE - 1) downto 0); 
		variable tbuf3f	: STD_LOGIC_VECTOR((2*SIZE - 1) downto 0); 
		variable tbuf4vv	: STD_LOGIC_VECTOR((2*SIZE - 1) downto 0); 
		variable tbuf4vf	: STD_LOGIC_VECTOR((2*SIZE - 1) downto 0); 
		variable tbuf4fv	: STD_LOGIC_VECTOR((2*SIZE - 1) downto 0); 
		variable tbuf4ff	: STD_LOGIC_VECTOR((2*SIZE - 1) downto 0); 
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
					tbuf1v((2 * SIZE - 1) downto SIZE) := '0' & (buf((2 * SIZE - 3) downto (SIZE - 1)) - dbuf((SIZE - 2) downto 0)); 
					tbuf1v((SIZE - 1)     downto    0) := buf2((SIZE - 2) downto 0) & '1'; -- ON POUSSE LE RESULTAT
					tbuf1f                             := buf((2 * SIZE - 2) downto 0) & '0';

					-- QUATRIEME ITERATION DEROULEE DE LA DIVISION
					tbuf2vv((2 * SIZE - 1) downto SIZE)  := '0' & (tbuf1v((2 * SIZE - 3) downto (SIZE - 1)) - dbuf((SIZE - 2) downto 0)); 
					tbuf2vv((SIZE - 1)     downto    0)  := tbuf1v((SIZE - 2) downto 0) & '1'; 
					tbuf2vf                              := tbuf1v((2 * SIZE - 2) downto 0) & '0'; 

					tbuf2fv((2 * SIZE - 1) downto SIZE)  := '0' & (tbuf1f((2 * SIZE - 3) downto (SIZE - 1)) - dbuf((SIZE - 2) downto 0)); 
					tbuf2fv((SIZE - 1)     downto    0)  := tbuf1f((SIZE - 2) downto 0) & '1'; 
					tbuf2ff                              := tbuf1f((2 * SIZE - 2) downto 0) & '0'; 

					if buf((2 * SIZE - 2) downto (SIZE - 1)) >= dbuf then 
						if tbuf1v((2 * SIZE - 2) downto (SIZE - 1)) >= dbuf then 
							tbuf2 := tbuf2vv;
						else 
							tbuf2 := tbuf2vf;
						end if; 
					else 
						if tbuf1v((2 * SIZE - 2) downto (SIZE - 1)) >= dbuf then 
							tbuf2 := tbuf2fv;
						else 
							tbuf2 := tbuf2ff;
						end if; 
					end if; 


					-- TROISIEME ITERATION DEROULEE DE LA DIVISION
					tbuf3v((2 * SIZE - 1) downto SIZE)  := '0' & (tbuf2((2 * SIZE - 3) downto (SIZE - 1)) - dbuf((SIZE - 2) downto 0)); 
					tbuf3v((SIZE - 1)     downto    0)  := tbuf2((SIZE - 2) downto 0) & '1'; 
					tbuf3f                              := tbuf2((2 * SIZE - 2) downto 0) & '0'; 


					-- QUATRIEME ITERATION DEROULEE DE LA DIVISION
					tbuf4vv((2 * SIZE - 1) downto SIZE)  := '0' & (tbuf3v((2 * SIZE - 3) downto (SIZE - 1)) - dbuf((SIZE - 2) downto 0)); 
					tbuf4vv((SIZE - 1)     downto    0)  := tbuf3v((SIZE - 2) downto 0) & '1'; 
					tbuf4vf 										 := tbuf3v((2 * SIZE - 2) downto 0) & '0'; 

					tbuf4fv((2 * SIZE - 1) downto SIZE)  := '0' & (tbuf3f((2 * SIZE - 3) downto (SIZE - 1)) - dbuf((SIZE - 2) downto 0)); 
					tbuf4fv((SIZE - 1)     downto    0)  := tbuf3f((SIZE - 2) downto 0) & '1'; 
					tbuf4ff 										 := tbuf3f((2 * SIZE - 2) downto 0) & '0'; 

					if tbuf2((2 * SIZE - 2) downto (SIZE - 1)) >= dbuf then 
						if tbuf3v((2 * SIZE - 2) downto (SIZE - 1)) >= dbuf then 
							buf <= tbuf4vv; 
						else 
							buf <= tbuf4vf; 
						end if; 
					else 
						if tbuf3f((2 * SIZE - 2) downto (SIZE - 1)) >= dbuf then 
							buf <= tbuf4fv; 
						else 
							buf <= tbuf4ff; 
						end if; 
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
