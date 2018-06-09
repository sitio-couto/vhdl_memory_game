library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.game_package.all;

entity play_table is
	port (
		CLOCK_50   : in std_logic;
		play_game  : in std_logic;
		enter_on   : in std_logic;
		key_on     : in std_logic_vector (2 downto 0);
		key_number : in std_logic_vector (7 downto 0);
		game_over  : out std_logic;
		n_players  : in integer range 0 to 9;
		n_cards    : in integer range 0 to 100;
		game_table : in vetor;
		pa, pb, pc, pd, pe, pf : out std_logic_vector (3 downto 0);
		LEDR		  : out std_logic_vector (5 downto 0)
	);
end play_table;
architecture rtl of play_table is
	signal  key_on_prev : std_logic_vector (2 downto 0);
	signal state, next_state : std_logic_vector (3 downto 0) := "0000";
	signal wait_keypress : std_logic := '0';
	
	signal clk_flag : std_logic := '0';
	signal aux_player : std_logic_vector (3 downto 0);
	signal card_flag, match : std_logic := '0';
	signal table_map : std_logic_vector (79 downto 0);
	signal c_aux, l_aux : integer range 0 to 9;
	signal flag2, row_set : std_logic;
	signal curr_player : integer range 0 to 5;
	signal player_score : vetor;
begin

	LEDR(3 downto 0) <= aux_player;
	LEDR(4) <= wait_keypress;
	
	with curr_player select aux_player <= 
		"0001" when 0,
		"0010" when 1,
		"0100" when 2,
		"1000" when 3,
		"0000" when others;
	
	-- MAQUINA DE ESTADOS (controla entidade).
	process
		variable l, c, lin1, col1, lin2, col2 : integer range  0 to 9;
		variable i, max, winner, cards_found : integer range 0 to 100;
	begin
	wait until CLOCK_50'event and CLOCK_50 = '1';
	if (key_on /= "000" and key_on_prev = "000") or wait_keypress = '0' then

		case state is
		when "0000" =>
			game_over <= '0';
			if (play_game = '1') then
				next_state <= "0001";
			end if;
		when "0001" =>
			-- preparando jogo
			curr_player <= 0;
			card_flag <= '0';
			match <= '0';
			cards_found := 0;
			
			l := 0;
			c := 0;
			lin1 := 0;
			lin2 := 0;
			col1 := 0;
			col2 := 0;
			max  := 0;
			winner := 0;
			
			i := 0;
			while (i < 80) loop
				table_map(i) <= '1';
				i := i + 1;
			end loop;
			
			wait_keypress <= '1';
			next_state <= "0010";
			
		when "0010" => -- Seleciona uma linha.
			
			if (enter_on = '1') and (table_map(l*8 + c) = '1') then
				wait_keypress <= '0';
				next_state <= "0100";
			elsif (enter_on = '0') and (to_integer(unsigned(key_number(3 downto 0))) >= 0) and (to_integer(unsigned(key_number(3 downto 0))) < n_cards/8) then
				l := to_integer(unsigned(key_number(3 downto 0)));
				LEDR(5) <= table_map(l*8 + c);
				pf <= key_number(3 downto 0);
				next_state <= "0011";
			end if;

		when "0011" => -- Seleciona coluna.
		
			if (enter_on = '1') and (table_map(l*8 + c) = '1')then
				wait_keypress <= '0';
				next_state <= "0100";
			elsif (enter_on = '0') and (to_integer(unsigned(key_number(3 downto 0))) >= 0) and (to_integer(unsigned(key_number(3 downto 0))) < 8) then 
				c := to_integer(unsigned(key_number(3 downto 0)));
				LEDR(5) <= table_map(l*8 + c);
				pe <= key_number(3 downto 0);
				next_state <= "0010";
			end if;		
		
		when "0100" =>
			
			if (card_flag = '0') then
				pa <= std_logic_vector(to_unsigned(game_table(l*8 + c) mod 10, 4));
				pb <= std_logic_vector(to_unsigned(game_table(l*8 + c)/10 mod 10, 4));
				lin1 := l;
				col1 := c;
				wait_keypress <= '1';
				next_state <= "0010";
--				next_state <= "1110";-- CALL TABLE_MAP UPDATE STATE.
			else
				pc <= std_logic_vector(to_unsigned(game_table(l*8 + c) mod 10, 4));
				pd <= std_logic_vector(to_unsigned(game_table(l*8 + c)/10 mod 10, 4));
				lin2 := l;
				col2 := c;
				wait_keypress <= '1';
				next_state <= "0110";
			end if;
			
			table_map(l*8 + c) <= '0';
			card_flag <= not card_flag;
			
		when "0110" =>
			clk_flag <= not clk_flag;
			if (clk_flag = '1') then
					if (game_table(lin1*8 + col1) = game_table(lin2*8 + col2)) then
					player_score(curr_player) <= player_score(curr_player) + 1;
					cards_found := cards_found + 2;
					LEDR(5) <= table_map(l*8 + c); -- CALL TABLE_MAP UPDATE STATE.
				else
					table_map(lin1*8 + col1) <= '1';
					table_map(lin2*8 + col2) <= '1';
					curr_player <= (curr_player + 1) mod n_players;	
				end if;
				
				i := curr_player;
				wait_keypress <= '0';
				next_state <= "0111";
			end if;
		when "0111" =>
			curr_player <= curr_player mod n_players;
		
			pf <= "1111";
			pe <= std_logic_vector(to_unsigned(i, 4));
			pd <= std_logic_vector(to_unsigned(player_score(i)/10 mod 10, 4));
			pc <= std_logic_vector(to_unsigned(player_score(i) mod 10, 4));
			pb <= "1111";
			pa <= std_logic_vector(to_unsigned(curr_player, 4));
		
			wait_keypress <= '1';
			next_state <= "1000";
		when "1000" =>
			-- Estado de espera.
			if (enter_on = '1') and (cards_found = n_cards) then 
				next_state <= "1001";
			elsif (enter_on = '1') then
				wait_keypress <= '1';
				next_state <= "0010";
				pf <= "0000";
				pe <= "0000";
				pd <= "0000";
				pc <= "0000";
				pb <= "0000";
				pa <= "0000";
				LEDR(5) <= table_map(l*8 + c);
			end if;
			
		when "1001" =>
			i := 0 ;
			while (i < 5) loop
				if (player_score(i) > max) then
					max := player_score(i);
					winner := i;
				end if;
				i := i + 1; 
			end loop;
			
			next_state <= "1010";
		when "1010" =>
			pa <= std_logic_vector(to_unsigned(max mod 10, 4));
			pb <= std_logic_vector(to_unsigned(max/10 mod 10, 4));
			pc <= std_logic_vector(to_unsigned(winner, 4));
			pd <= "1111";
			pe <= "0000";
			pf <= "0000";
			
			if (enter_on = '1') then 
				wait_keypress <= '0';
				next_state <= "1111";
			end if;
--		when "1110" =>
--			LEDR(5) <= table_map(l*8 + c);
--			wait_keypress <= '1';
--			next_state <= "0010";
		when others =>
			game_over <= '1';
			if (play_game = '0') then
				next_state <= "0000";
			end if;
		end case;
	
	end if;
		key_on_prev <= key_on;
		state <= next_state;		-- Atualiza estado.
	end process;
end rtl; 