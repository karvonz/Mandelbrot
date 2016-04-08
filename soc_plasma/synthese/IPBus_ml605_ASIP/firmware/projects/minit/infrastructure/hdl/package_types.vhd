 
LIBRARY ieee;		   
USE ieee.std_logic_1164.ALL;		   
USE ieee.numeric_std.ALL;
		   
PACKAGE package_types is		   

-- TYPE type_stdlogicvec_array is ARRAY(natural RANGE <>) OF std_logic_vector(natural RANGE <>);
TYPE type_vector_of_stdlogicvec_x64 is ARRAY(natural RANGE <>) OF std_logic_vector(63 DOWNTO 0);
TYPE type_vector_of_stdlogicvec_x34 is ARRAY(natural RANGE <>) OF std_logic_vector(33 DOWNTO 0);
TYPE type_vector_of_stdlogicvec_x32 is ARRAY(natural RANGE <>) OF std_logic_vector(31 DOWNTO 0);
TYPE type_vector_of_stdlogicvec_x26 is ARRAY(natural RANGE <>) OF std_logic_vector(25 DOWNTO 0);
TYPE type_vector_of_stdlogicvec_x20 is ARRAY(natural RANGE <>) OF std_logic_vector(19 DOWNTO 0);
TYPE type_vector_of_stdlogicvec_x17 is ARRAY(natural RANGE <>) OF std_logic_vector(16 DOWNTO 0);
TYPE type_vector_of_stdlogicvec_x16 is ARRAY(natural RANGE <>) OF std_logic_vector(15 DOWNTO 0);
TYPE type_vector_of_stdlogicvec_x15 is ARRAY(natural RANGE <>) OF std_logic_vector(14 DOWNTO 0);
TYPE type_vector_of_stdlogicvec_x14 is ARRAY(natural RANGE <>) OF std_logic_vector(13 DOWNTO 0);
TYPE type_vector_of_stdlogicvec_x13 is ARRAY(natural RANGE <>) OF std_logic_vector(12 DOWNTO 0);
TYPE type_vector_of_stdlogicvec_x12 is ARRAY(natural RANGE <>) OF std_logic_vector(11 DOWNTO 0);
TYPE type_vector_of_stdlogicvec_x9 is ARRAY(natural RANGE <>) OF std_logic_vector(8 DOWNTO 0);
TYPE type_vector_of_stdlogicvec_x8 is ARRAY(natural RANGE <>) OF std_logic_vector(7 DOWNTO 0);
TYPE type_vector_of_stdlogicvec_x5 is ARRAY(natural RANGE <>) OF std_logic_vector(4 DOWNTO 0);
TYPE type_vector_of_stdlogicvec_x4 is ARRAY(natural RANGE <>) OF std_logic_vector(3 DOWNTO 0);
TYPE type_vector_of_stdlogicvec_x3 is ARRAY(natural RANGE <>) OF std_logic_vector(2 DOWNTO 0);
TYPE type_vector_of_stdlogicvec_x2 is ARRAY(natural RANGE <>) OF std_logic_vector(1 DOWNTO 0);

CONSTANT LHC_BUNCH_COUNT: integer := 512;

END package_types;		 
