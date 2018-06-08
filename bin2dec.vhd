LIBRARY ieee ;
USE ieee.std_logic_1164.all;

ENTITY bin2dec IS
PORT (SW: IN STD_LOGIC_VECTOR(3 DOWNTO 0) ;
		HEX0: OUT STD_LOGIC_VECTOR (6 DOWNTO 0)) ;
END bin2dec;
ARCHITECTURE Behavior OF bin2dec IS
BEGIN
WITH SW SELECT
HEX0 <= "1111001" WHEN "0001",
		  "0100100" WHEN "0010",
		  "0110000" WHEN "0011",
		  "0011001" WHEN "0100",
		  "0010010" WHEN "0101",
		  "0000010" WHEN "0110",
		  "1111000" WHEN "0111",
		  "0000000" WHEN "1000",
		  "0010000" WHEN "1001",
		  "1000000" WHEN "0000",
		  "0001100" WHEN "1111", -- P
		  "1000110" WHEN "1110", -- C
		  "0000110" WHEN OTHERS;
END Behavior ;
