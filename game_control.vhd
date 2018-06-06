-- 21/05 -> Checked keybord functionality

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.game_package.all;

entity game_control is
  port (
    CLOCK_50 : in std_logic;
    PS2_DAT : inout STD_LOGIC;
    PS2_CLK : inout STD_LOGIC;
	 SW	: in  std_logic_vector(9 downto 0);
	 HEX5 : out std_logic_vector(6 downto 0);
	 HEX4 : out std_logic_vector(6 downto 0);
	 HEX3 : out std_logic_vector(6 downto 0);
	 HEX2 : out std_logic_vector(6 downto 0);
    HEX1 : out std_logic_vector(6 downto 0);
    HEX0 : out std_logic_vector(6 downto 0);
	 LEDR : out std_logic_vector(9 downto 0)
  );
end game_control ;
architecture rtl of game_control is

  signal mesa : vetor;

  signal state, next_state : std_logic_vector (3 downto 0);
  signal key_on      : std_logic_vector (2  downto 0);
  signal key_on_prev      : std_logic_vector (2  downto 0);
  signal key_code    : std_logic_vector (47 downto 0);
  signal key_number  : std_logic_vector (7 downto 0);
  signal key_pressed : std_logic_vector (7  downto 0);

  signal n_players, t_cards, n_pairs : integer range 0 to 9;
  signal n_cards : integer range 0 to 79;
  signal rand_num: integer range 0 to 9;
  
  signal deck, game_table : vetor;
  signal table_map  : std_logic_vector(0 to 79);
  signal table_size : integer range 0 to 9;
  signal set_table  : std_logic;
  
  signal p1, p2, p3, p4 : std_logic_vector (3 downto 0);
  
  
  signal asdf : integer range 0 to 100;
  
  signal c_aux, l_aux : integer range 0 to 9;
  signal flag2 : std_logic;
  
  -- Singnals for block control.
  signal configure: std_logic := '0';
  signal config_ready : std_logic;
  signal seed_in : integer range 0 to 50000000;
begin
	

  kbdex_ctrl_inst : kbdex_ctrl
    generic map (
      clkfreq => 50000
    )
    port map (
      ps2_data => PS2_DAT,
      ps2_clk => PS2_CLK,
      clk => CLOCK_50,
      en => '1',
      resetn => '1',
      lights => "000",
      key_on => key_on,
      key_code => key_code
    );
  
  kbd_alphanum_inst : kbd_alphanum
    port map (
      clk => CLOCK_50,
      key_on => key_on,
      key_code => key_code,
      HEX1 => key_pressed(7 downto 4),
      HEX0 => key_pressed(3 downto 0)
	);
	
	translate : ascii_2_num 
	  port map (
			key_pressed,
			key_number
	);
	
	settings : config_table 
		port map (
			CLOCK_50,
			configure,
			key_on,
			key_number,
			config_ready,
			n_players, t_cards, n_pairs,
			n_cards,
			seed_in
		);
	
	process
		variable counter  : integer range 0 to 50000000;
		variable i, aux, lin1, col1, lin2, col2, index : integer range 0 to 100;
		variable rand, rand1, rand2, lin, col, flag 	 : integer range 0 to 100;
		
		variable seed: positive := 61631;
		constant M: integer := 502321;
		constant A: integer := 6521;
		constant B: integer := 88977;
	begin 
	wait until CLOCK_50'event and CLOCK_50 = '1';
		if (key_on /= "000" and key_on_prev = "000") or set_table = '1' then	-- nao havia tecla pressionada no clock anterior e foi pressionada agora
		
			case state is
				when "0000" =>
					-- Sinaliza "game_config" para que execute.
					configure <= '1';
					next_state <= "0001";
				when "0001" =>
					-- Aguarda "game_config" sinalizar que terminou a execucao.
					if (config_ready = '1') then
						configure <= '0';		 -- Deixa "game_config" em espera.
						next_state <= "0010";
					end if;
				when "0010" =>
					-- ZERAMENTO DO DECK.
					i := 0;
					while (i < 80) loop
						deck(i) <= 0;
						i := i + 1;
					end loop; 
					
					-- FLAG PARA INICILIZAR A MESA.
					set_table <= '1';
					next_state <= "0011";
					
				when "0011" => 
					-- INICIALIZAÇAO DO DECK.
					i := 0;
					while (i < 80) loop
						if t_cards = 1 and i < 8 then
							deck(i) <= i*10;
						elsif t_cards = 2 and i < 10 then 
							deck(i) <= i;
						elsif t_cards = 3 then 
							deck(i) <= i;
						end if;
					
						-- Zera o mapeamento das posicoes da mesa.
						table_map(i) <= '0';
						i := i + 1;
					end loop;
				
					next_state <= "0100";
					i := 0;
					set_table <= '1';
					
				when "0100" =>			
					flag2 <= not flag2;
					if (flag2 = '1') then
						p1 <= std_logic_vector(to_unsigned((i mod 10), 4));
						p2 <= std_logic_vector(to_unsigned((i/10 mod 10), 4));
					
						p3 <= std_logic_vector(to_unsigned((rand mod 10), 4));
						p4 <= std_logic_vector(to_unsigned((rand/10 mod 10), 4));
					
						if i < n_cards then
							if flag = 0 then -- determina indice inicial posicao da carta
								seed := (seed*A + B) mod M;
								rand := (seed mod n_cards); -- rand eh o indice na mesa

								aux := i/2;	-- indice no deck
								flag := 1;	-- posicao selecionada
							else
								if table_map(rand) = '0' then -- nao tem carta naquela posicao
									table_map(rand) <= '1';    -- Marca posicao como ocupada
									game_table(rand) <= deck(aux);
									i := i + 1;
									flag := 0;
								else -- a posicao ja tem uma carta
									rand := rand + 1; -- vai pra prox posicao
									rand := (rand mod n_cards);
									--if rand >= n_cards then rand := 0;-- ultrapassou o limite de cartas
									--end if;
								end if;
							end if;
						else
							asdf <= i;
							-- Quando pronta a mesa, passa para o proximo estado
							next_state <= "0101";
							set_table <= '1';
						end if;
					end if;
	
				when "0101" =>
					c_aux <= to_integer(unsigned(SW(3 downto 0)));
					l_aux <= to_integer(unsigned(SW(7 downto 4))); 
					
					p1 <= std_logic_vector(to_unsigned((game_table(l_aux*8 + c_aux) mod 10), 4));
					p2 <= std_logic_vector(to_unsigned((game_table(l_aux*8 + c_aux)/10 mod 10), 4));
					p3 <= "000" & table_map(l_aux*8 + c_aux);
					if SW(9) = '1' then next_state <= "0111";
						set_table <= '0';
					end if;				
					
				when others =>
					next_state <= "0000";
			end case;
		end if;
		-- FIM DA MAQUINA DE ESTADOS
		
		key_on_prev <= key_on;	-- atualiza key_on_prev para processar apenas uma vez por input
	end process;
	
	state <= next_state;
	
	-- DISPLAYS PARA MOSTRAR AS OPCOES SELECIONADAS
	print0 : bin2dec 
		port map (
		  key_number(3 downto 0),
		  HEX0
	) ;
	
	print1 : bin2dec 
		port map (
		  p2,
		  HEX1
	) ;
	
	print2 : bin2dec 
		port map (
		  std_logic_vector(to_unsigned(n_players, 4)),
		  HEX2
	) ;
	
	
	print3 : bin2dec 
		port map (
		  std_logic_vector(to_unsigned(t_cards, 4)),
		  HEX3
	) ;
	
	print4 : bin2dec 
		port map (
		  std_logic_vector(to_unsigned(n_pairs, 4)),
		  HEX4
	) ;
	
	print5 : bin2dec 
		port map (
		  std_logic_vector(to_unsigned((asdf/10 mod 10), 4)),
		  HEX5
	) ;
	
	LEDR(9 downto 6) <= state;
	--HEX3 <= "1111111";
	-- FIM DISPLAYS
	
end rtl;
