LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

entity code2ascii is
	port (
		capital_en  : in std_logic;
		key_code    : in std_logic_vector(15 downto 0);
		key_ascii   : out std_logic_vector(7 downto 0)
	);
end code2ascii;

architecture tradution of code2ascii is 
	signal capsnkey : std_logic_vector (19 downto 0); 
begin 

	capsnkey <= "000" & capital_en & key_code;

	with capsnkey select
		key_ascii <= -- a - z
						 x"61" when x"0001C",
						 x"62" when x"00032",
						 x"63" when x"00021",
						 x"64" when x"00023",
						 x"65" when x"00024",
						 x"66" when x"0002B",
						 x"67" when x"00034",
						 x"68" when x"00033",
						 x"69" when x"00043",
						 x"6A" when x"0003B",
						 x"6B" when x"00042",
						 x"6C" when x"0004B",
						 x"6D" when x"0003A",
						 x"6E" when x"00031",
						 x"6F" when x"00044",
						 x"70" when x"0004D",
						 x"71" when x"00015",
						 x"72" when x"0002D",
						 x"73" when x"0001B",
						 x"74" when x"0002C",
						 x"75" when x"0003C",
						 x"76" when x"0002A",
						 x"77" when x"0001D",
						 x"78" when x"00022",
						 x"79" when x"00035",
						 x"7A" when x"0001A",
						 
						 -- 0 - 9 (teclado)
						 x"30" when x"00045",
						 x"31" when x"00016",
						 x"32" when x"0001E",
						 x"33" when x"00026",
						 x"34" when x"00025",
						 x"35" when x"0002E",
						 x"36" when x"00036",
						 x"37" when x"0003D",
						 x"38" when x"0003E",
						 x"39" when x"00046", 
						 
						 -- 0 - 9 (keypad)
						 x"30" when x"00070",
						 x"31" when x"00069",
						 x"32" when x"00072",
						 x"33" when x"0007A",
						 x"34" when x"0006B",
						 x"35" when x"00073",
						 x"36" when x"00074",
						 x"37" when x"0006C",
						 x"38" when x"00075",
						 x"39" when x"0007D",  
						 
						 -- A - Z (Capital)
						 x"41" when x"1001C",
						 x"42" when x"10032",
						 x"43" when x"10021",
						 x"44" when x"10023",
						 x"45" when x"10024",
						 x"46" when x"1002B",
						 x"47" when x"10034",
						 x"48" when x"10033",
						 x"49" when x"10043",
						 x"4A" when x"1003B",
						 x"4B" when x"10042", 
						 x"4C" when x"1004B",
						 x"4D" when x"1003A",
						 x"4E" when x"10031",
						 x"4F" when x"10044",
						 x"50" when x"1004D",
						 x"51" when x"10015",
						 x"52" when x"1002D",
						 x"53" when x"1001B",
						 x"54" when x"1002C",
						 x"55" when x"1003C",
						 x"56" when x"1002A",
						 x"57" when x"1001D",
						 x"58" when x"10022",
						 x"59" when x"10035",
						 x"5A" when x"1001A",
						
						 -- 0 - 9 (teclada com Capital ativo)
						 x"30" when x"10045",--0
						 x"31" when x"10016",--1
						 x"32" when x"1001E",--2
						 x"33" when x"10026",--3
						 x"34" when x"10025",--4
						 x"35" when x"1002E",--5
						 x"36" when x"10036",--6
						 x"37" when x"1003D",--7
						 x"38" when x"1003E",--8
						 x"39" when x"10046",--9 
						
						 -- 0 - 9 (keypad com Capital ativo)
						 x"30" when x"10070",--0
						 x"31" when x"10069",--1
						 x"32" when x"10072",--2
						 x"33" when x"1007A",--3
						 x"34" when x"1006B",--4
						 x"35" when x"10073",--5
						 x"36" when x"10074",--6
						 x"37" when x"1006C",--7
						 x"38" when x"10075",--8
						 x"39" when x"1007D",--9
						 
						 -- tecla Enter
						 x"0D" when x"1005A", -- Com capital
						 x"0D" when x"0005A", -- Sem capital
						 x"0D" when x"1E05A", -- KP com capital
						 x"0D" when x"0E05A", -- KP sem capital
						 
						 -- Arrows
						 --cima
						 x"0F" when x"1E075", -- Com capital
						 x"0F" when x"0E075", -- Sem capital
						 --esquerda
						 x"0A" when x"1E06B", -- com capital
						 x"0A" when x"0E06B", -- sem capital
						 --direita
						 x"0B" when x"1E074", -- Com capital
						 x"0B" when x"0E074", -- Sem capital
						 --baixo
						 x"0C" when x"1E072", -- com capital
						 x"0C" when x"0E072", -- sem capital

						
						 x"00" when others; 
						 
						
end tradution;