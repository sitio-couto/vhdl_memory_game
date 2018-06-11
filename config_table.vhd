library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity config_table is
  port (
	 CLOCK_50     : in std_logic;
	 configure    : in std_logic;
	 key_on       : in std_logic_vector(2 downto 0);
	 key_number   : in std_logic_vector (7 downto 0);
	 config_ready : out std_logic;
	 n_players, t_cards, n_pairs : out integer range 0 to 9;
	 n_cards : out integer range 0 to 79;
	 seed_in : out integer range 0 to 50000000
  );
end config_table;

architecture rtl of config_table is
	signal wait_keypress : std_logic := '0';
	signal key_on_prev, state, next_state : std_logic_vector (2 downto 0);
	signal t_cards_aux, n_pairs_aux : integer range 0 to 9;
begin
	
	-- Auxiliares para fazer leitura e escrita.
	t_cards <= t_cards_aux;
   n_pairs <= n_pairs_aux;
	
	-- Define numero de cartas na mesa.
	with n_pairs_aux select n_cards <=
		 8 when 1,
		16 when 2,
		24 when 3,
		32 when 4,
		 0 when others;

	-- MAQUINA DE ESTADOS (controla entidade).
	process
		variable counter : integer range 0 to 50000000;
		variable max_cards : integer range 0 to 5;
	begin
	wait until CLOCK_50'event and CLOCK_50 = '1';
		
		-- Contador para gerar numeros aleatorios.
		counter := counter + 1;
		if (counter = 50000000) then counter := 0;
		end if;
		------------------------------------------
	
		if (key_on /= "000" and key_on_prev = "000") or wait_keypress = '0' then-- nao havia tecla pressionada no clock anterior e foi pressionada agora
			case state is
			when "000" =>
			
				-- Reseta sinal de resposta.
				config_ready <= '0';
				-- Fica em espera ate "game_control" mandar executar.
				if (configure = '1') then
					n_players <= 0;
					t_cards_aux <= 0;
					n_pairs_aux <= 0;
				
					wait_keypress <= '1';		-- Seta flag para esperar input do usuario.
					next_state <= "001";
				end if;
			
			when "001" =>
				-- Le e testa se o numero de jogadores selecionados e valido.
				n_players <= to_integer(unsigned(key_number(3 downto 0)));
				if (to_integer(unsigned(key_number(3 downto 0))) > 1) and (to_integer(unsigned(key_number(3 downto 0))) < 5) then 
					next_state <= "010"; -- Muda estado so o valor for valido.
				end if;
				-- obtem um valor aleatorio a partir do clock.
				seed_in <= counter;
			when "010" =>
				-- Recebe tipo de cartas e testa se e um valor valido.
				t_cards_aux <= to_integer(unsigned(key_number(3 downto 0)));
				if (to_integer(unsigned(key_number(3 downto 0))) > 0) and (to_integer(unsigned(key_number(3 downto 0))) < 4) then 
					next_state <= "011";
				end if;
			when "011" => 
				-- Recebe e testa se o numero de cartas desejado eh valido.
				n_pairs_aux <= to_integer(unsigned(key_number(3 downto 0)));
				if (t_cards_aux = 1) or (t_cards_aux = 2) then				
					if (to_integer(unsigned(key_number(3 downto 0))) < 3) and (to_integer(unsigned(key_number(3 downto 0))) > 0) then 
						next_state    <= "100"; -- Valor valido.
						wait_keypress <= '0';   -- Nao recebe mais inputs do teclado.
					end if;
				else 
					if (to_integer(unsigned(key_number(3 downto 0))) < 5) and (to_integer(unsigned(key_number(3 downto 0))) > 0) then 
						next_state    <= "100"; -- Valor valido.
						wait_keypress <= '0';   -- Nao recebe mais inputs do teclado.
					end if;
				end if;
			when "100" =>
			
				-- Sinaliza "game_control" que as configuracoes estao prontas.
				config_ready <= '1';
				-- Aguarda "game_control" receber a resposta.
				if (configure = '0') then
					next_state <= "000"; -- Volta ao estado de espera.
				end if;
			
			when others =>
			end case;
		end if;
		
		key_on_prev <= key_on;	-- Atualiza key_on_prev para processar apenas uma vez por input.
		state <= next_state;		-- Atualiza estado.
	end process;
	
end rtl;

	