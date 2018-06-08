LIBRARY ieee ;
USE ieee.std_logic_1164.all;

ENTITY ascii_2_num IS
PORT (key_pressed: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		numeric : OUT std_logic_vector (7 downto 0);
		enter_on : OUT std_logic
		);
END ascii_2_num;
ARCHITECTURE Behavior OF ascii_2_num IS
BEGIN

WITH key_pressed SELECT numeric <= 
		 x"00" when x"30",
		 x"01" when x"31",
		 x"02" when x"32", 
		 x"03" when x"33", 
		 x"04" when x"34",
		 x"05" when x"35",
		 x"06" when x"36",
		 x"07" when x"37",
		 x"08" when x"38",
		 x"09" when x"39",
		 x"00" when others;
		 
WITH key_pressed SELECT enter_on <=
		 '1' when x"0D",
		 '0' when others;
		 
END Behavior ;