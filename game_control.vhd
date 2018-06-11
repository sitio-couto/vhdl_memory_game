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
	 LEDR : out std_logic_vector(9 downto 0);
	 
    KEY                       : in  std_logic_vector(0 downto 0);
    VGA_R, VGA_G, VGA_B       : out std_logic_vector(7 downto 0);
    VGA_HS, VGA_VS            : out std_logic;
    VGA_BLANK_N, VGA_SYNC_N   : out std_logic;
    VGA_CLK                   : out std_logic
  );
end game_control ;
architecture rtl of game_control is
  signal state, next_state : std_logic_vector (3 downto 0) := "0000";

  signal enter_on : std_logic;
  signal key_on, key_on_prev : std_logic_vector (2  downto 0);
  signal key_pressed, key_number : std_logic_vector (7  downto 0);
  signal key_code    : std_logic_vector (47 downto 0);

  signal n_players, t_cards, n_pairs : integer range 0 to 9;
  signal n_cards : integer range 0 to 79;
  signal game_table : vetor;
  signal table_map_out: std_logic_vector (79 downto 0);
  
  signal linha, coluna : integer range 0 to 9;
  
  signal p1, p2, p3, p4, p5, p6 : std_logic_vector (3 downto 0);
  signal pa, pb, pc, pd, pe, pf : std_logic_vector (3 downto 0);

  -- Signals for block control.
  signal configure : std_logic := '0';
  signal config_ready : std_logic;
  signal seed_in : integer range 0 to 50000000;

  signal set_table : std_logic := '0';
  signal table_ready : std_logic;

  signal play_game : std_logic := '0';
  signal game_over : std_logic;

begin

	vga : vga_ball
		port map (    
			 CLOCK_50,
			 KEY,
			 VGA_R, VGA_G, VGA_B,
			 VGA_HS, VGA_VS,
			 VGA_BLANK_N, VGA_SYNC_N,
			 VGA_CLK,	
			 game_table,
			 table_map_out,
			 linha, coluna,
			 n_cards
		);
	
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
			key_number,
			enter_on
	);

  -- Bloco para configuracoes.
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

  -- Bloco para o preparo da mesa.
	randomize : ready_table
	  port map (
			 CLOCK_50,
			 set_table,
			 table_ready,
			 t_cards,
			 n_cards,
			 seed_in,
			 game_table
		 );

  -- Block para execucao do gameplay.
	gameplay : play_table
		port map (
			CLOCK_50,
			play_game,
			enter_on,
			key_on,
			key_number,
			game_over,
			n_players,
			n_cards,
			game_table,
			pa, pb, pc, pd, pe, pf,
			table_map_out,
			linha, coluna
		);

	process
		variable l, c : integer range 0 to 100;
	begin
	wait until CLOCK_50'event and CLOCK_50 = '1';

		case state is
		when "0000" =>
			-- Sinaliza "config_table" para executar.
			configure <= '1';
			next_state <= "0001";
		when "0001" =>
			-- Imprime opcoes de configuracao.
			p1 <= std_logic_vector(to_unsigned(n_players mod 10, 4));
			p2 <= "1111";
			p3 <= std_logic_vector(to_unsigned(t_cards mod 10, 4));
			p4 <= "1110";
			p5 <= std_logic_vector(to_unsigned(n_cards mod 10, 4));
			p6 <= std_logic_vector(to_unsigned(n_cards/10 mod 10, 4));
			-- Aguarda "config_table" terminar de executar.
			if (config_ready = '1') then
				configure <= '0'; -- Sinaliza "config_table" que recebeu a resposta.
				next_state <= "0010";
			end if;
		when "0010" =>
			-- Pausa para o usuario ver as opcoes selecionadas.
			if (enter_on = '1') then next_state <= "0011";
			end if;
		when "0011" =>
      -- Sinaliza "ready_table" para executar.
			set_table <= '1';
			next_state <= "0100";
		when "0100" =>
      -- Aguarda "ready_table" terminar de executar.
			if (table_ready = '1') then
				set_table <= '0'; -- Sinaliza "ready_table" que recebeu a resposta.
				next_state <= "0101";
			end if;
		when "0101" =>
      -- Sinaliza "play_table" para executar.
			play_game <= '1';
			next_state <= "0110";
		when "0110" =>
      -- Recebe valores de "play_table" para o display.
			p1 <= pa;
			p2 <= pb;
			p3 <= pc;
			p4 <= pd;
			p5 <= pe;
			p6 <= pf;

      -- Aguarda "play_table" terminar de executar.
			if (game_over = '1') then
				play_game <= '0'; -- Sinaliza "play_table" que recebeu a resposta.
				next_state <= "1111";
			end if;
		when others => next_state <= "0000";
		end case;

		state <= next_state; -- Atualiza estado;
	end process;


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
		  p3,
		  HEX2
	) ;


	print3 : bin2dec
		port map (
		  p4,
		  HEX3
	) ;

	print4 : bin2dec
		port map (
		  p5,
		  HEX4
	) ;

	print5 : bin2dec
		port map (
		  p6,
		  HEX5
	) ;

	LEDR(9 downto 6) <= state;

end rtl;
