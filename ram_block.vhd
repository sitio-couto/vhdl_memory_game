library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_block is
  port (
    Clock : in std_logic;
    Address : in std_logic_vector(6 downto 0);
    Data : in std_logic_vector(7 downto 0);
    Q : out std_logic_vector(7 downto 0);
    WrEn : in std_logic
  );
end ram_block;

architecture direct of ram_block is
	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector(7 downto 0);
	type memory_t is array(127 downto 0) of word_t;

	-- Declare the RAM signal.	
	signal ram : memory_t;

begin

	process
	begin
	wait until Clock'event and Clock = '1'; 
		if(WrEn = '1') then
			ram(to_integer(unsigned(Address))) <= Data;
		end if;
	end process;

	Q <= ram(to_integer(unsigned(Address)));

end direct;