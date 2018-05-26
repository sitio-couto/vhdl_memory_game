library ieee;
use ieee.std_logic_1164.all;

entity ff_t is
  port(
    T   : in std_logic;
    Clk : in std_logic;
	 Q   : out std_logic;
    Q_n : out std_logic;
	 Preset : in std_logic;
	 Clear  : in std_logic
  );
end ff_t;

architecture structural of ff_t is
	signal temp : std_logic;
begin
	PROCESS 
	BEGIN
		wait until Clk'event and Clk = '1';
		if (Clear = '1') then 
			temp <= '0';
		elsif (Preset = '1') then
			temp <= '1';
		elsif (T = '1') then
			temp <= not temp;
		elsif (T = '0') then
			temp <= temp;
		end if;
	END PROCESS ;
			
	Q_n <= not temp;	
	Q <= temp;		
end structural;
