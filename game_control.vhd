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
  
  signal p1, p2, p3, p4 : std_logic_vector (3 downto 0);
  
  
  signal asdf : integer range 0 to 100;
  
  signal c_aux, l_aux : integer range 0 to 9;
  signal flag2 : std_logic;
  
  -- Singnals for block control.
  signal configure : std_logic := '0';
  signal config_ready : std_logic;
  signal seed_in : integer range 0 to 50000000;
  
  signal set_table : std_logic := '0';
  signal table_ready : std_logic;
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
		
	ramdomize : ready_table 
		port map (
			CLOCK_50,
			set_table,
			table_ready,
			t_cards,
			n_cards,
			seed_in,
			game_table,
		   LEDR(1 downto 0)
		);
	
	process
		variable i, aux, lin1, col1, lin2, col2, index : integer range 0 to 100;
		variable rand, rand1, rand2, lin, col, flag 	 : integer range 0 to 100;
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
				
					-- FLAG PARA INICILIZAR A MESA.
					set_table <= '1';
					next_state <= "0011";
					
				when "0011" => 
					
					if (table_ready = '1') then
						set_table <= '0';
						next_state <= "0100";
					end if;
	
				when "0100" =>
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
		  p1,
		  HEX0
	) ;
	
	print1 : bin2dec 
		port map (
		  p2,
		  HEX1
	) ;
	
	print2 : bin2dec 
		port map (
		  std_logic_vector(to_unsigned(c_aux, 4)),
		  HEX2
	) ;
	
	
	print3 : bin2dec 
		port map (
		  std_logic_vector(to_unsigned(l_aux, 4)),
		  HEX3
	) ;
	
	print4 : bin2dec 
		port map (
		  std_logic_vector(to_unsigned(n_cards, 4)),
		  HEX4
	) ;
	
	print5 : bin2dec 
		port map (
		  "0000",
		  HEX5
	) ;
	
	LEDR(9 downto 6) <= state;
	--HEX3 <= "1111111";
	-- FIM DISPLAYS
	
end rtl;
