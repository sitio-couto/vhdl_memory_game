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
		pa, pb, pc, pd, pe, pf : out std_logic_vector (3 downto 0)
	);
end play_table;
architecture rtl of play_table is
	signal wait_keypress : std_logic := '0';
	signal key_on_prev, state, next_state : std_logic_vector (2 downto 0) := "000";

	signal table_map : std_logic_vector (79 downto 0);
	signal c_aux, l_aux : integer range 0 to 9;
	signal flag2, row_set : std_logic;
	signal is_card_available : std_logic;
	signal curr_player : integer range 0 to 100;
	signal player_score : vetor;
begin

	-- MAQUINA DE ESTADOS (controla entidade).
	process
		variable lin1, col1, lin2, col2 : integer range  0 to 9;
		variable i, card_count, row_qtd : integer range 0 to 100;
		variable flag_pair, cards_found : integer range 0 to 100;
	begin
	wait until CLOCK_50'event and CLOCK_50 = '1';
	if (key_on /= "000" and key_on_prev = "000") or wait_keypress = '0' then
	
		case state is
		when "000" =>
			game_over <= '0';
			if (play_game = '1') then
				wait_keypress <= '1';
				next_state <= "001";
			end if;
		when "001" =>
			-- preparando jogo
			curr_player <= 1;
			row_set <= '0';
			card_count := 1;
			cards_found := 0;
			flag_pair := 0;
			
			lin1 := 0;
			lin2 := 0;
			col1 := 0;
			col2 := 0;
			
			i := 0;
			while (i < 80) loop
				table_map(i) <= '0';
				i := i + 1;
			end loop;
			is_card_available <= '1';
			
			wait_keypress <= '1';
			next_state <= "010";
			
		when "010" =>-- selecionando cartas
		
			if (enter_on = '1') then
				if (card_count = 1 ) then -- seleciona carta 1
					if (table_map((lin1-1)*8 + col1) = '1') then -- carta eh valida
						pd <= std_logic_vector(to_unsigned((game_table((lin1-1)*8 + col1)/10 mod 10), 4));
						pc <= std_logic_vector(to_unsigned((game_table((lin1-1)*8 + col1) mod 10), 4));
						table_map((lin1-1)*8 + col1) <= '0'; -- torna carta indisponivel pois a selecionamos
						card_count := 2;
					end if;
				else -- selecionando segunda carta
					if (table_map((lin2-1)*8 + col2) = '1') then -- carta eh valida
						pb <= std_logic_vector(to_unsigned((game_table((lin2-1)*8 + col2)/10 mod 10), 4));
						pa <= std_logic_vector(to_unsigned((game_table((lin2-1)*8 + col2) mod 10), 4));
						table_map((lin2-1)*8 + col2) <= '0'; -- torna carta indisponivel pois a selecionamos
						card_count := 1;
						next_state <= "011";
					end if;
				end if;
			else
				if (row_set = '0') then -- selecionando linha
					row_qtd := n_cards/8;
					if (card_count = 1) then -- selecionando primeira carta
						lin1 := to_integer(unsigned(key_number(3 downto 0)));
						pf <= std_logic_vector(to_unsigned(lin1, 4));
						if (lin1 >= 1 and lin1 <= row_qtd) then -- verifica se linha foi escolhida corretamente
							row_set <= '1';
						end if;
					else 
						lin2 := to_integer(unsigned(key_number(3 downto 0)));
						pf <= std_logic_vector(to_unsigned(lin2, 4));
						if (lin2 >= 1 and lin2 <= row_qtd) then -- verifica se linha foi escolhida corretamente
							row_set <= '1';
						end if;
					end if;
				else -- selecionando coluna
					if (card_count = 1) then -- selecionando primeira carta
						col1 := to_integer(unsigned(key_number(3 downto 0)));
						pe <= std_logic_vector(to_unsigned(col1, 4));
						if (col1 >= 1 and col1 <= 8) then -- verifica se coluna foi escolhida corretamente
							row_set <= '0';
						end if;
					else 
						col2 := to_integer(unsigned(key_number(3 downto 0)));
						pe <= std_logic_vector(to_unsigned(col2, 4));
						if (col2 >= 1 and col2 <= 8) then -- verifica se coluna foi escolhida corretamente
							row_set <= '0';
						end if;
					end if;
				end if;		
			end if;
				
			if (card_count = 1) then
				is_card_available <= table_map((lin1-1)*8 + col1);
			else
				is_card_available <= table_map((lin2-1)*8 + col2);
			end if;

		when "011" =>-- verificar pares, atribuir pontos, passar turno

			if (game_table((lin1-1)*8 + col1) = game_table((lin2-1)*8 + col2)) then -- o jogador escolheu cartas iguais
				player_score(curr_player) <= player_score(curr_player) + 1;
				cards_found := cards_found + 2;
				flag_pair := 1;
			else -- o jogador escolheu cartas diferentes e errou
				table_map(lin1*8 + col1) <= '1'; -- torna as cartas disponiveis novamente
				table_map(lin2*8 + col2) <= '1';
			end if;
			
			if (cards_found = n_cards) then -- todas as cartas foram encontradas
				next_state <= "111"; -- fim de jogo
			else
				next_state <= "100"; -- mostra pontuacao e atualiza valores pro prox jogador;
				pe <= "0000";
				pd <= std_logic_vector(to_unsigned(curr_player, 4));
				pc <= std_logic_vector(to_unsigned((player_score(curr_player) mod 10), 4));
				pb <= "0000";
				if (flag_pair = 0) then -- jogador nao acertou
					pd <= std_logic_vector(to_unsigned(((player_score(curr_player) + 1)/10 mod 10), 4));
					if (curr_player = n_players) then -- passa o turno
						curr_player <= 1;
					else
						curr_player <= curr_player + 1;
					end if;
				else
					pd <= std_logic_vector(to_unsigned((player_score(curr_player)/10 mod 10), 4));
				end if;
				pa <= std_logic_vector(to_unsigned(curr_player, 4));
			end if;
			flag_pair := 0;	
		
		when "100" =>
			next_state <= "010"; -- volta pro estado de jogo

			row_set <= '0';
			card_count := 1;
			wait_keypress <= '1';
			flag_pair := 0;
			
			lin1 := 0;
			lin2 := 0;
			col1 := 0;
			col2 := 0;
			
			pa <= "0000";	
			pb <= "0000";	
			pc <= "0000";	
			pd <= "0000";	
			pe <= "0000";	
			pf <= "0000";
		
		when others =>
			game_over <= '1';
			if (play_game = '0') then
				next_state <= "000";
			end if;
		end case;
	
	end if;		
		key_on_prev <= key_on;	-- Atualiza key_on_prev para processar apenas uma vez por input.
		state <= next_state;		-- Atualiza estado.
	end process;
end rtl; 