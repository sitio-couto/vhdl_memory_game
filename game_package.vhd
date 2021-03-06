library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package game_package is
	
  type vetor is array (0 to 100) of integer range 0 to 100;
	
	
	component vga_ball is
	  port (    
		 CLOCK_50                  : in  std_logic;
		 KEY                       : in  std_logic_vector(1 downto 0);
		 VGA_R, VGA_G, VGA_B       : out std_logic_vector(7 downto 0);
		 VGA_HS, VGA_VS            : out std_logic;
		 VGA_BLANK_N, VGA_SYNC_N   : out std_logic;
		 VGA_CLK                   : out std_logic;
		 game_table : in vetor;
		 table_map_out : in std_logic_vector (79 downto 0);
		 linha, coluna : in integer range 0 to 9;
		 n_cards : in integer range 0 to 79
		 );
	end component;
	
	
  component kbd_alphanum is
    port (
      clk : in std_logic;
      key_on : in std_logic_vector(2 downto 0);
      key_code : in std_logic_vector(47 downto 0);
      HEX1 : out std_logic_vector(3 downto 0); 
      HEX0 : out std_logic_vector(3 downto 0) 
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
		    numeric : OUT std_logic_vector (7 downto 0);
			 enter_on : OUT std_logic
	 );
  end component;
  
  component bin2dec is
	 port (SW : in std_logic_vector (3 downto 0);
			 HEX0 : out std_logic_vector (6 downto 0)
	 );
  end component;
  
   component config_table is
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
	end component;
  
  component ready_table is
	 port (
		 reset_game  : in std_logic;
		 CLOCK_50    : in std_logic;
		 set_table 	 : in std_logic;
		 table_ready : out std_logic;
		 t_cards     : in integer range 0 to 9;
		 n_cards     : in integer range 0 to 79;
		 seed_in     : in integer range 0 to 50000000;
		 game_table  : out vetor
	  );
	end component;

	component play_table is
		port (
		   reset_game : in std_logic;
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
	end component;
	
end game_package;
