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
		table_map_out : out std_logic_vector (79 downto 0);
		linha, coluna : out integer range 0 to 9
	);
end play_table;
architecture rtl of play_table is
	signal key_on_prev : std_logic_vector (2 downto 0);
	signal state, next_state : std_logic_vector (3 downto 0) := "0000";
	signal wait_keypress : std_logic := '0';

	signal clk_flag, card_flag, return_cards : std_logic := '0';
	signal table_map : std_logic_vector (79 downto 0);
	signal curr_player, des : integer range 0 to 5;
	signal player_score : vetor;
begin

	table_map_out <= table_map;
	
	with key_number select des <=
		1 when x"10",
		2 when x"20",
		3 when x"30",
		4 when x"40",
		0 when others;

	-- MAQUINA DE ESTADOS (controla entidade).
	process
		variable l, c, lin1, col1, lin2, col2 : integer range  0 to 9;
		variable i, max, winner, cards_found  : integer range 0 to 100;
	begin
	wait until CLOCK_50'event and CLOCK_50 = '1';
	if (key_on /= "000" and key_on_prev = "000") or wait_keypress = '0' then

		case state is
		when "0000" =>
			-- Aguarda comando da unidade de controle.
			game_over <= '0';
			if (play_game = '1') then
				next_state <= "0001";
			end if;
		when "0001" =>
			-- Inicializacao de variaveis essenciais.
			curr_player <= 0;
			card_flag <= '0';
			cards_found := 0;

			l := 0;
			c := 0;
			lin1 := 0;
			lin2 := 0;
			col1 := 0;
			col2 := 0;
			max  := 0;
			winner := 0;
			
			linha <= 0;
			coluna <= 0;
			
			pf <= "1100";
			pe <= "1101";
			pd <= "1111";
			pc <= "0000";
			pb <= "0000";
			pa <= "0000";

			i := 0;
			while (i < 80) loop
				table_map(i) <= '1';
				i := i + 1;
			end loop;

			i := 0;
			while (i < 5) loop
				player_score(i) <= 0;
				i := i + 1;
			end loop;
			
			wait_keypress <= '1';
			next_state <= "0010";

		when "0010" => -- Seleciona uma linha.
			-- Caso a tecla pressionada seja enter, testa se ha carta.
			if (enter_on = '1') and (table_map(l*8 + c) = '1') then
				wait_keypress <= '0'; -- Proximo estado nao espera input.
				next_state <= "0100"; -- Vai para "vira carta"
				table_map(l*8 + c) <= '0'; -- Atualiza cartas viradas
			-- Se for uma seta, incrementa de acordo (da a volta caso sai das margens).
			elsif (des /= 0) then
				if (des = 1) then -- Cima
					if (l > 0) then l := l - 1;
					else l := (n_cards/8 - 1); 
					end if;
				elsif (des = 3) then -- Esquerda
					l := (l + 1) mod (n_cards/8);
				elsif (des = 2) then -- Baixo
					if (c > 0) then c := c - 1;
					else c := 7; 
					end if;
				elsif (des = 4) then -- Direita
					c := (c + 1) mod 8;
				end if;
				linha <= l;
				coluna <= c;
			-- Se nao for enter, e for um valor valido, regirstra uma linha.
			elsif (enter_on = '0') and (to_integer(unsigned(key_number(3 downto 0))) >= 0) and (to_integer(unsigned(key_number(3 downto 0))) < n_cards/8) then
				l := to_integer(unsigned(key_number(3 downto 0)));
				linha <= l;
				pf <= "1110"; -- Mostra C.
				next_state <= "0011"; -- Vai para selecao de coluna
			end if;

		when "0011" => -- Seleciona coluna.
			-- Caso a tecla pressionada seja enter, testa se ha carta.
			if (enter_on = '1') and (table_map(l*8 + c) = '1')then
				wait_keypress <= '0'; -- Proximo estado nao espera input.
				next_state <= "0100"; -- Vai para "vira carta"
				table_map(l*8 + c) <= '0'; -- Atualiza cartas viradas
			-- Se for uma seta, incrementa de acordo (da a volta caso sai das margens).
			elsif (des /= 0) then
				if (des = 1) then -- Cima
					if (l > 0) then l := l - 1;
					else l := (n_cards/8 - 1); 
					end if;
				elsif (des = 3) then -- Equerda
					l := (l + 1) mod (n_cards/8);
				elsif (des = 2) then -- Baixo
					if (c > 0) then c := c - 1;
					else c := 7; 
					end if;
				elsif (des = 4) then -- Direita
					c := (c + 1) mod 8;
				end if;
				linha <= l;
				coluna <= c;
			-- Se nao for enter, e for um valor valido, regirstra uma coluna.
			elsif (enter_on = '0') and (to_integer(unsigned(key_number(3 downto 0))) >= 0) and (to_integer(unsigned(key_number(3 downto 0))) < 8) then
				c := to_integer(unsigned(key_number(3 downto 0)));
				coluna <= c;
				pf <= "1100"; -- Mostra L.
				next_state <= "0010"; -- Vai para selecao de linha
			end if;

		when "0100" => -- Vira carta
			clk_flag <= not clk_flag;
			if (clk_flag = '1') then
				if (card_flag = '0') then -- Se for a primeira carta sendo selecionada.
					-- Salva posicao.
					lin1 := l;
					col1 := c;
					wait_keypress <= '1';
					next_state <= "0010"; -- Volta para selecao de linha
				else -- Se for a segunda carta sendo selecionada.
					-- Salva posicao.
					lin2 := l;
					col2 := c;
					next_state <= "0110"; -- Vai para "computa a jogada"
				end if;

				card_flag <= not card_flag;
			end if;

		when "0110" => -- computa a jogada
			clk_flag <= not clk_flag; -- Delay de clock pra evitar um erro que ele executava duas vezes o estado
			if (clk_flag = '1') then
					-- Caso as cartas viradas sejam iguais.
				if (game_table(lin1*8 + col1) = game_table(lin2*8 + col2)) then
					player_score(curr_player) <= player_score(curr_player) + 1; --incremeta o score
					cards_found := cards_found + 2; -- incremeta o numero de cartas encontradas
				else
					-- se diferentes, sinaliza para devolver as cartas
					return_cards <= '1';
					curr_player <= (curr_player + 1) mod n_players; -- passa pro proximo jogador
				end if;

				i := curr_player;     -- Guarda o jogador atual.
				next_state <= "0111";
			end if;
		when "0111" =>
			pf <= "1111"; -- Imprime P
			pe <= std_logic_vector(to_unsigned(i, 4)); -- Imprime jogador atual
			pd <= std_logic_vector(to_unsigned(player_score(i)/10 mod 10, 4)); -- imprime score
			pc <= std_logic_vector(to_unsigned(player_score(i) mod 10, 4));  -- imprime score
			pb <= "1111"; -- imprime P
			pa <= std_logic_vector(to_unsigned(curr_player, 4)); -- Imprime proximo jogador
			
			wait_keypress <= '1'; -- Proximo estado requer input
			next_state <= "1000"; -- Vai para "passa jogada"
		when "1000" => -- Passa jogada
			-- Devolve cartas se necessario antes de passar a jogada.
			if (return_cards = '1') then 
				return_cards <= '0'; -- Sinaliza que devolveu cartas
				table_map(lin1*8 + col1) <= '1'; -- Devolve primeira carta 
				table_map(lin2*8 + col2) <= '1'; -- Devolve segunda carta
			end if;
		
			-- Estado de espera (aguarda enter)
			if (cards_found = n_cards) then
				wait_keypress <= '0';
				next_state <= "1001"; -- Caso nao haja mais cartas, vai para "acha vencedor"
			else
				-- Caso haja cartas, reinicia displays
				pf <= "1100";
				pe <= "1101";
				pd <= "1111";
				pc <= std_logic_vector(to_unsigned(curr_player, 4)); -- Jogador atual.
				pb <= std_logic_vector(to_unsigned(player_score(i)/10 mod 10, 4)); -- imprime score
				pa <= std_logic_vector(to_unsigned(player_score(i) mod 10, 4));    -- imprime score
				wait_keypress <= '1';
				next_state <= "0010"; -- Vai para "selecao de linha"
			end if;

		when "1001" => -- acha Vencedor
			-- Este loop encotra o player vencedor e seu score
			i := 0 ;
			while (i < 5) loop
				if (player_score(i) > max) then
					max := player_score(i);
					winner := i;
				end if;
				i := i + 1;
			end loop;

			next_state <= "1010"; -- Vai para "game over"
		when "1010" => -- Game over
			pa <= std_logic_vector(to_unsigned(max mod 10, 4));
			pb <= std_logic_vector(to_unsigned(max/10 mod 10, 4));
			pc <= std_logic_vector(to_unsigned(winner, 4));
			pd <= "1111";
			pe <= "1101";
			pf <= "1101";

			wait_keypress <= '1';
			next_state <= "1011";
		when "1011" =>
			-- Aguarda o usuario pressionar enter.
			if (enter_on = '1') then
				wait_keypress <= '0';
				next_state <= "1111";
			end if;
		when others =>
			-- Avisa unidade de controle que terminou de executar.
			game_over <= '1';
			-- Ao receber a resposta de "game_control", volra ao inicio e fica em espera.
			if (play_game = '0') then
				next_state <= "0000";
			end if;
		end case;

	end if;
		key_on_prev <= key_on;
		state <= next_state;		-- Atualiza estado.
	end process;
end rtl;
