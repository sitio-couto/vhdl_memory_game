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
  signal key_code    : std_logic_vector (47 downto 0);
  signal key_number  : std_logic_vector (7 downto 0);
  signal key_pressed : std_logic_vector (7  downto 0);

  signal n_players, t_cards, n_pairs : integer range 0 to 9;
  signal n_cards : integer range 0 to 32;
  
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
	
	print3 : bin2dec 
		port map (
		  std_logic_vector(to_unsigned(n_cards, 4)),
		  HEX3
	) ;
	
	process (key_on)
	begin 
		if key_on /= "000" then
 		case state is
			when "0000" =>
				n_players <= to_integer(unsigned(key_number(3 downto 0)));
				if n_players /= 0 then 
					next_state <= "0001";
				end if;
			when "0001" =>
				t_cards <= to_integer(unsigned(key_number(3 downto 0)));
				if t_cards /= 0 and t_cards < 4 then 
					next_state <= "0010";
				end if;
			when "0010" =>
				n_pairs <= to_integer(unsigned(key_number(3 downto 0)));
				
				if t_cards = 0 then next_state <= "0000";
				
				elsif t_cards = 1 then -- Se for apenas cor (8 pares);
					if n_pairs < 3 and n_pairs /= 0 then 
						next_state <= "0011"; -- Valido
					end if;
				elsif t_cards = 2 then -- Se for apenas numero (10 pares)
					if n_pairs < 3 and n_pairs /= 0 then 
						next_state <= "0011"; -- Valido
					end if;
				elsif t_cards = 3 then -- Se for numeros e cores (80 pares)
					if n_pairs < 4 and n_pairs /= 0 then 
						next_state <= "0011"; -- Valido
					end if;
				end if;
			when others =>
				next_state <= "0000";
			end case;
		end if;
	end process;
	
   state <= next_state;
	
	LEDR(9 downto 6) <= state;
	
end rtl;







--	process
--	begin 
--	wait until CLOCK_50'event and CLOCK_50 = '1';
--		if key_on_flag = '1' then 
--			if key_on = '0' then key_on_flag <= '0';
--			end if;
--		elsif reset = '1' then
--			next_state <= "000";
--		else
-- 		case state is
--			when "000" =>
--				n_players <= unsigned(key_number(3 downto 0));
--				if n_players = 0 then next_state <= "000";
--				elsif n_players > 4 then next_state <= "000";
--				else next_state <= "001";
--				end if;
--			when "001" =>
--				t_cards <= unsigned(key_number(3 downto 0));
--				if t_cards = 0 then next_state <= "001";
--				elsif t_cards > 3 then next_state <= "001";
--				else next_state <= "010";
--				end if;
--			when "010" =>
--				addr <= "000000010";
--				save <= '1';
--				d_in <= key_number;
--				next_state <="001";
--				if key_on /= 0 then next_state <="011";
--				end if;
--			when "011" =>
--				if w = '1' then next_state <= "100";
--				else if b= next_state = "001";
--				end if;
--			when "100" =>
--				if w = '1' then next_state <= "000";
--				else next_state <= "011";
--				end if;
--			when others =>
--				if w = '1' then next_state <= "000";
--				else next_state <= "001";
--				end if;
--			end case;
--		end if;
--	end process;