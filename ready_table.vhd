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
		 game_table  : out vetor
	 );
end ready_table;
architecture rtl of ready_table is
	signal clk_flag : std_logic := '0';
	signal state, next_state : std_logic_vector (2 downto 0) := "000";
	signal table_map : std_logic_vector(0 to 79);
	signal index : integer range 0 to 100;
	signal deck, deck_count : vetor;
begin

	process
		variable i, rand, divider : integer range 0 to 100 := 0;
	
		variable seed : positive := 61631;
		constant M: integer := 502321;
		constant A: integer := 6521;
		constant B: integer := 88977;
	begin
	wait until CLOCK_50'event and CLOCK_50 = '1';

		case state is
		when "000" =>
		
			table_ready <= '0';
			if (set_table = '1') then
				next_state <= "001";
			end if;
			
		when "001" =>
			
			i := 0;
			while (i < 80) loop
				if (t_cards = 1) and (i < 8) then
					deck(i) <= i*10;
				elsif (t_cards = 2 and i < 10) or (t_cards = 3) then
					deck(i) <= i;
				else 
					deck(i) <= 0;
				end if;
				
				deck_count(i) <= 0;
				
				i := i + 1;
			end loop;
			
			index <= 0;
			seed := seed_in; 
			divider := n_cards/2;
			 
			next_state <= "010";
			
		when "010" =>
		
			seed := (seed*A + B) mod M;
			rand := (seed mod divider);
			next_state <= "011";
		
		when "011" =>
		
			if (deck_count(rand) < 2) then
				next_state <= "100";
			else
				rand := (rand + 1) mod divider;
			end if;
	
		when "100" =>
		
			deck_count(rand) <= deck_count(rand) + 1;
			game_table(index) <= deck(rand);
			index <= index + 1;
			if (index < (n_cards - 1)) then next_state <= "010";
			else next_state <= "111";
			end if;
		
		when "111" =>
		
			table_ready <= '1';
			if (set_table <= '0') then
				next_state <= "000";
			end if;
			
		when others =>
		end case;
		
		state <= next_state;
	end process;
	
end rtl;