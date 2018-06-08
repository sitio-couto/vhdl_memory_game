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
		game_table : vetor
	);
end play_table;
architecture rtl of play_table is
	signal wait_keypress : std_logic := '0';
	signal key_on_prev, state, next_state : std_logic_vector (2 downto 0) := "000";

	signal c_aux, l_aux : integer range 0 to 9;
	signal flag2, row_set : std_logic;
	signal is_card_available : std_logic;
	signal curr_player : integer range 0 to 100;
begin

	-- MAQUINA DE ESTADOS (controla entidade).
	process
		variable lin1, col1, lin2, col2 : integer range  0 to 100;
		variable card_count, row_qtd : integer range 0 to 100;
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
			
			is_card_available <= '1';

			if (enter_on = '1') then
				wait_keypress <= '0';
				next_state <= "010";
			end if;
		when "010" =>
			game_over <= '1';
			if (play_game = '0') then
				next_state <= "000";
			end if;
		when others =>
		end case;
	
	end if;		
		key_on_prev <= key_on;	-- Atualiza key_on_prev para processar apenas uma vez por input.
		state <= next_state;		-- Atualiza estado.
	end process;
end rtl; 