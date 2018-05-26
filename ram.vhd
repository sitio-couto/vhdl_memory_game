library ieee;
use ieee.std_logic_1164.all;

entity ram is
  port (
    Clock : in std_logic;
    Address : in std_logic_vector(9 downto 0);
    DataIn : in std_logic_vector(31 downto 0);
    DataOut : out std_logic_vector(31 downto 0);
    WrEn : in std_logic
  );
end ram;

architecture rtl of ram is

component ram_block
  port (
    Clock : in std_logic;
    Address : in std_logic_vector(6 downto 0);
    Data : in std_logic_vector(7 downto 0);
    Q : out std_logic_vector(7 downto 0);
    WrEn : in std_logic
  );
end component;

	signal sel_block : std_logic_vector (2 downto 0);
	signal addr_block : std_logic_vector (6 downto 0);
	signal line1_out, line2_out : std_logic_vector (31 downto 0);
	signal WrEn_line1, WrEn_line2 : std_logic;
	
begin
	sel_block <= Address(9 downto 7);
	addr_block <= Address(6 downto 0);
	
	g1 : for i in 3 downto 0 generate 
	
		block_line1 : ram_block port map(
			 Clock,
			 Addr_block,
			 DataIn(8*i + 7 downto 8*i),
			 line1_out(8*i + 7 downto 8*i),
			 WrEn_line1
		);
		
		block_line2 : ram_block port map(
			 Clock,
			 Addr_block,
			 DataIn(8*i + 7 downto 8*i),
			 line2_out(8*i + 7 downto 8*i),
			 WrEn_line2
		);
		
	end generate;
	
	with sel_block select WrEn_line1 <=
		WrEn when "000",
		'0' when others;
	
	with sel_block select WrEn_line2 <=
		WrEn when "001",
		'0' when others;

		
	with sel_block select DataOut <=
		line1_out when "000",
		line2_out when "001",
		"ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" when others;
  
end rtl;


