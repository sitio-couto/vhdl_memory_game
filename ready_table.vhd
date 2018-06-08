library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.game_package.all;

entity ready_table is
  port (
		 CLOCK_50    : in std_logic;
		 set_table 	 : in std_logic;
		 table_ready : out std_logic;
		 t_cards     : in integer range 0 to 9;
		 n_cards     : in integer range 0 to 79;
		 seed_in     : in integer range 0 to 50000000;
		 game_table  : out vetor;
		 LEDR			 : out std_logic_vector (1 downto 0)
	 );
end ready_table;
architecture rtl of ready_table is
	signal clk_flag : std_logic;
	signal state, next_state : std_logic_vector (1 downto 0) := "00";
	signal table_map : std_logic_vector(0 to 79);
	signal deck : vetor;
begin

	LEDR <= state;

	process
		variable i, rand, aux, flag : integer range 0 to 100;
		
		variable seed : positive := 61631;
		constant M: integer := 502321;
		constant A: integer := 6521;
		constant B: integer := 88977;
	begin
	wait until CLOCK_50'event and CLOCK_50 = '1';

		case state is
		when "00" =>
		
			table_ready <= '0';
			if (set_table = '1') then
				next_state <= "01";
			end if;

		when "11" =>
		
			table_ready <= '1';
			if (set_table <= '0') then
				next_state <= "00";
			end if;
			
		when others =>
		end case;
		
		state <= next_state;
	end process;
	
end rtl;