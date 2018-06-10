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
	signal state, next_state : std_logic_vector (3 downto 0) := "0000";

	signal deck : vetor;
	signal deck_flag : std_logic;
	signal n_pairs : integer range 0 to 100;
	signal table_map, deck_map : std_logic_vector (0 to 79);
begin

	with t_cards select n_pairs <=
		8 when 1,
	  10 when 2,
	  79 when 3,
	   1 when others;

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
		when "0000" =>
		
			table_ready <= '0';
			if (set_table = '1') then
				next_state <= "0001";
			end if;
			
		when "0001" =>
			
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
				deck_map(i) <= '0';
				
				i := i + 1;
			end loop;
			
			i := 0;
			seed := seed_in;
			deck_flag <= '1';
			
			next_state <= "0010";
			
		when "0010" =>
	
			seed := (seed*A + B) mod M;
			rand_deck := (seed mod n_pairs);
			next_state <= "0011";
		
		when "0011" =>
		
			if (deck_map(rand_deck) = '0') then
				deck_map(rand_deck) <= '1';
				next_state <= "0100";
			else
				rand_deck := (rand_deck + 1) mod n_pairs;
			end if;
	
		when "0100" =>
			
			seed := (seed*A + B) mod M;
			rand_table:= seed mod n_cards;
			next_state <= "0110";
		
		when "0110" =>
		
			if (table_map(rand_table) = '0') then
				table_map(rand_table) <= '1';
				next_state <= "0111";
			else
				rand_table := (rand_table + 1) mod n_cards;
			end if;
		
		when "0111" =>
		
			i := i + 1;
			deck_flag <= not deck_flag;
			game_table(rand_table) <= deck(rand_deck);
			if (i = n_cards) then next_state <= "1111";
			else next_state <= "1000";
			end if;
	
		when "1000" =>
		
			if (deck_flag = '0') then next_state <= "0100";
			else next_state <= "0010";
			end if;
		
		when others =>
			table_ready <= '1';
			if (set_table <= '0') then
				next_state <= "0000";
			end if;
		end case;
		
	end if;
		clk_flag  <= not clk_flag;
		state <= next_state;
	end process;
	
end rtl;