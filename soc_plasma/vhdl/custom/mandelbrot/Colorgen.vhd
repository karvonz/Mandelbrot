library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.CONSTANTS.ALL;
use WORK.FUNCTIONS.ALL;

entity Colorgen is
    Port ( iters : in STD_LOGIC_VECTOR (ITER_RANGE-1 downto 0);
			  itermax : in STD_LOGIC_VECTOR (ITER_RANGE-1 downto 0);
           color : out STD_LOGIC_VECTOR (bit_per_pixel-1 downto 0));
end Colorgen;


architecture Behavioral of Colorgen is -- TODO : Améliorer colorgen (comparaison OpenGL)
	type  rom_type is array (0 to ITER_MAX-1) of std_logic_vector (bit_per_pixel-1 downto 0);
	constant color_scheme : rom_type := (
		x"000", 
x"002", 
x"004", 
x"006", 
x"008", 
x"00A", 
x"00C", 
x"00E", 
x"010", 
x"012", 
x"014", 
x"016", 
x"018", 
x"01A", 
x"01C", 
x"01E", 
x"020", 
x"022", 
x"024", 
x"026", 
x"028", 
x"02A", 
x"02C", 
x"02E", 
x"030", 
x"032", 
x"034", 
x"036", 
x"038", 
x"03A", 
x"03C", 
x"03E", 
x"040", 
x"042", 
x"044", 
x"046", 
x"048", 
x"04A", 
x"04C", 
x"04E", 
x"050", 
x"052", 
x"054", 
x"056", 
x"058", 
x"05A", 
x"05C", 
x"05E", 
x"060", 
x"062", 
x"064", 
x"066", 
x"068", 
x"06A", 
x"06C", 
x"06E", 
x"070", 
x"072", 
x"074", 
x"076", 
x"078", 
x"07A", 
x"07C", 
x"07E", 
x"080", 
x"082", 
x"084", 
x"086", 
x"088", 
x"08A", 
x"08C", 
x"08E", 
x"090", 
x"092", 
x"094", 
x"096", 
x"098", 
x"09A", 
x"09C", 
x"09E", 
x"0A0", 
x"0A2", 
x"0A4", 
x"0A6", 
x"0A8", 
x"0AA", 
x"0AC", 
x"0AE", 
x"0B0", 
x"0B2", 
x"0B4", 
x"0B6", 
x"0B8", 
x"0BA", 
x"0BC", 
x"0BE", 
x"0C0", 
x"0C2", 
x"0C4", 
x"0C6", 
x"0C8", 
x"0CA", 
x"0CC", 
x"0CE", 
x"0D0", 
x"0D2", 
x"0D4", 
x"0D6", 
x"0D8", 
x"0DA", 
x"0DC", 
x"0DE", 
x"0E0", 
x"0E2", 
x"0E4", 
x"0E6", 
x"0E8", 
x"0EA", 
x"0EC", 
x"0EE", 
x"0F0", 
x"0F2", 
x"0F4", 
x"0F6", 
x"0F8", 
x"0FA", 
x"0FC", 
x"0FE", 
x"100", 
x"102", 
x"104", 
x"106", 
x"108", 
x"10A", 
x"10C", 
x"10E", 
x"110", 
x"112", 
x"114", 
x"116", 
x"118", 
x"11A", 
x"11C", 
x"11E", 
x"120", 
x"122", 
x"124", 
x"126", 
x"128", 
x"12A", 
x"12C", 
x"12E", 
x"130", 
x"132", 
x"134", 
x"136", 
x"138", 
x"13A", 
x"13C", 
x"13E", 
x"140", 
x"142", 
x"144", 
x"146", 
x"148", 
x"14A", 
x"14C", 
x"14E", 
x"150", 
x"152", 
x"154", 
x"156", 
x"158", 
x"15A", 
x"15C", 
x"15E", 
x"160", 
x"162", 
x"164", 
x"166", 
x"168", 
x"16A", 
x"16C", 
x"16E", 
x"170", 
x"172", 
x"174", 
x"176", 
x"178", 
x"17A", 
x"17C", 
x"17E", 
x"180", 
x"182", 
x"184", 
x"186", 
x"188", 
x"18A", 
x"18C", 
x"18E", 
x"190", 
x"192", 
x"194", 
x"196", 
x"198", 
x"19A", 
x"19C", 
x"19E", 
x"1A0", 
x"1A2", 
x"1A4", 
x"1A6", 
x"1A8", 
x"1AA", 
x"1AC", 
x"1AE", 
x"1B0", 
x"1B2", 
x"1B4", 
x"1B6", 
x"1B8", 
x"1BA", 
x"1BC", 
x"1BE", 
x"1C0", 
x"1C2", 
x"1C4", 
x"1C6", 
x"1C8", 
x"1CA", 
x"1CC", 
x"1CE", 
x"1D0", 
x"1D2", 
x"1D4", 
x"1D6", 
x"1D8", 
x"1DA", 
x"1DC", 
x"1DE", 
x"1E0", 
x"1E2", 
x"1E4", 
x"1E6", 
x"1E8", 
x"1EA", 
x"1EC", 
x"1EE", 
x"1F0", 
x"1F2", 
x"1F4", 
x"1F6", 
x"1F8", 
x"1FA", 
x"1FC", 
x"1FE" 
);

begin
process(iters, itermax)
begin
	--color <= not iters;
	if (iters = itermax) then
		color<= (others=>'0');
	else
		color <= not color_scheme(to_integer(unsigned(iters)));
	end if;
end process;end Behavioral;


--Cut and paste following lines into Shared.vhd.
--	constant ITER_MAX : integer := 4095;
--	constant ITER_RANGE : integer := 12;
