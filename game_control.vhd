-- 21/05 -> Checked keybord functionality

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity game_control is
  port (
    CLOCK_50 : in std_logic;
    PS2_DAT : inout STD_LOGIC;
    PS2_CLK : inout STD_LOGIC;
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
  component kbd_alphanum is
    port (
      clk : in std_logic;
      key_on : in std_logic_vector(2 downto 0);
      key_code : in std_logic_vector(47 downto 0);
      HEX1 : out std_logic_vector(3 downto 0); -- GFEDCBA
      HEX0 : out std_logic_vector(3 downto 0) -- GFEDCBA
    );
  end component;
  
  component kbdex_ctrl is
    generic(
      clkfreq : integer
    );
    port(
      ps2_data : inout std_logic;
      ps2_clk : inout std_logic;
      clk :	in std_logic;
      en : in std_logic;
      resetn : in std_logic;
      lights : in std_logic_vector(2 downto 0);
      key_on : out std_logic_vector(2 downto 0);
      key_code : out std_logic_vector(47 downto 0)
    );
  end component;
  		  
  component ram is
    port (
      Clock : in std_logic;
      Address : in std_logic_vector(9 downto 0);
      DataIn : in std_logic_vector(31 downto 0);
      DataOut : out std_logic_vector(31 downto 0);
      WrEn : in std_logic
    );
  end component;
  
  component ascii_2_num is
    port (key_pressed: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		    numeric : OUT std_logic_vector (7 downto 0)
	 );
  end component;
  
  component bin2dec is
	 port (SW : in std_logic_vector (3 downto 0);
			 HEX0 : out std_logic_vector (6 downto 0)
	 );
  end component;
  
  signal key_en, reset : std_logic;
  signal state, next_state : std_logic_vector (3 downto 0);
  signal key_on      : std_logic_vector (2  downto 0);
  signal key_on_prev      : std_logic_vector (2  downto 0);
  signal key_code    : std_logic_vector (47 downto 0);
  signal key_number  : std_logic_vector (7 downto 0);
  signal key_pressed : std_logic_vector (7  downto 0);

  signal n_players, t_cards, n_pairs : integer range 0 to 9;
  signal n_cards : integer range 0 to 32;
  signal key_state: std_logic;
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
	
	with n_pairs select n_cards <=
		 8 when 1,
		16 when 2,
		32 when 3,
		 0 when others;

	process
		variable counter : integer range 0 to 50000000; 
	begin 
	wait until CLOCK_50'event and CLOCK_50 = '1';
		--CONTADOR PARA GERAR NUMEROS ALEATORIOS
		counter := counter + 1;
		
		if (counter = 50000000) then 
			counter := 0;
		end if;
		--FIM CONTADOR
	
		-- MAQUINA DE ESTADOS E PROCESSAMENTO DO INPUT DO TECLADO
		if key_on /= "000" and key_on_prev = "000" then	-- nao havia tecla pressionada no clock anterior e foi pressionada agora
 		case state is
			when "0000" =>
				n_players <= to_integer(unsigned(key_number(3 downto 0)));
				if to_integer(unsigned(key_number(3 downto 0))) > 1 and to_integer(unsigned(key_number(3 downto 0))) < 5 then 
					next_state <= "0001";
				end if;
			when "0001" =>
				t_cards <= to_integer(unsigned(key_number(3 downto 0)));
				if to_integer(unsigned(key_number(3 downto 0))) > 0 and to_integer(unsigned(key_number(3 downto 0))) < 4 then 
					next_state <= "0010";
				end if;
			when "0010" =>
				n_pairs <= to_integer(unsigned(key_number(3 downto 0)));
				
				if t_cards = 1 then -- Se for apenas cor (8 pares);
					if to_integer(unsigned(key_number(3 downto 0))) < 3 and to_integer(unsigned(key_number(3 downto 0))) /= 0 then 
						next_state <= "0011"; -- Valido
					end if;
				elsif t_cards = 2 then -- Se for apenas numero (10 pares)
					if to_integer(unsigned(key_number(3 downto 0))) < 3 and to_integer(unsigned(key_number(3 downto 0))) /= 0 then 
						next_state <= "0011"; -- Valido
					end if;
				elsif t_cards = 3 then -- Se for numeros e cores (80 pares)
					if to_integer(unsigned(key_number(3 downto 0))) < 4 and to_integer(unsigned(key_number(3 downto 0))) /= 0 then 
						next_state <= "0011"; -- Valido
					end if;
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
		  std_logic_vector(to_unsigned(n_players, 4)),
		  HEX0
	) ;
	
	print1 : bin2dec 
		port map (
		  std_logic_vector(to_unsigned(t_cards, 4)),
		  HEX1
	) ;
	
	print2 : bin2dec 
		port map (
		  std_logic_vector(to_unsigned(n_pairs, 4)),
		  HEX2
	) ;
	
	print4 : bin2dec 
		port map (
		  std_logic_vector(to_unsigned((n_cards mod 10), 4)),
		  HEX4
	) ;
	
	print5 : bin2dec 
		port map (
		  std_logic_vector(to_unsigned((n_cards/10 mod 10), 4)),
		  HEX5
	) ;
	
	LEDR(9 downto 6) <= state;
	HEX3 <= "1111111";
	-- FIM DISPLAYS
	
end rtl;
