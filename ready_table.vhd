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
	signal clk_flag, deck_flag : std_logic := '0';
	signal state, next_state : std_logic_vector (2 downto 0) := "000";

	signal deck : vetor;
	signal deck_map : std_logic_vector(0 to 39);
	signal table_map : std_logic_vector(0 to 79);
begin

	process
		variable i, rand_deck, rand_table : integer range 0 to 100 := 0;
	
		variable seed : positive := 61631;
		constant M: integer := 502321;
		constant A: integer := 6521;
		constant B: integer := 88977;
	begin
	wait until CLOCK_50'event and CLOCK_50 = '1';
	if (clk_flag = '1') then
	
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
				
				table_map(i) <= '0';
				
				i := i + 1;
			end loop;
			
			i := 0;
			seed := seed_in;
			deck_flag <= '1';
			
			next_state <= "010";
			
		when "010" =>
			seed := (seed*A + B) mod M;
			
			if (deck_flag = '1') then
				i := i + 1;
				rand_deck := (seed mod (n_cards/2));
				next_state <= "011";
			else	next_state <= "100";
			end if;
			
			rand_table := (seed mod n_cards);
		
		when "011" =>
		
			if (deck_map(rand_deck) = '0') then
				deck_map(rand_deck) <= '1';
				next_state <= "100";
			else
				rand_deck := (rand_deck + 1) mod (n_cards/2);
			end if;
	
		when "100" =>
			
			if (table_map(rand_table) = '0') then
				table_map(rand_table) <= '1';
				next_state <= "101";
			else
				rand_table := (rand_table + 1) mod n_cards;
			end if;

		when "101" =>
		
			deck_flag <= not deck_flag;
			game_table(rand_table) <= deck(rand_deck);
			
			if (i = n_cards/2) then next_state <= "111";
			else next_state <= "010";
			end if;
			
		when "111" =>
		
			table_ready <= '1';
			if (set_table <= '0') then
				next_state <= "000";
			end if;
			
		when others =>
		end case;
		
	end if;
		clk_flag  <= not clk_flag;
		state <= next_state;
	end process;
	
end rtl;