library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity initialize is
  generic( num : integer );
  port (
	 initialization : out std_logic_vector(9 downto 0)
  );
end initialize;

architecture rtl of initialize is
begin
	initialization <= std_logic_vector(to_unsigned(num, 10));
end rtl;
