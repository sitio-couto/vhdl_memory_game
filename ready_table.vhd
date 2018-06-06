library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.game_package.all;

entity ready_table is
  port (
		 CLOCK_50    : in std_logic;
		 set_table 	 : in std_logic;
		 table_ready : out std_logic;
		 t_cards     : in integer range 0 to 9;
		 n_cards     : in integer range 0 to 79;
		 seed_in     : in integer range 0 to 50000000;
		 game_table  : out vetor;
		 LEDR			 : out std_logic_vector (1 downto 0)
	 );
end ready_table;
architecture rtl of ready_table is
	signal clk_flag : std_logic;
	signal state, next_state : std_logic_vector (1 downto 0) := "00";
	signal table_map : std_logic_vector(0 to 79);
	signal deck : vetor;
begin

	LEDR <= state;

	process
		variable i, rand, aux, flag : integer range 0 to 100;
		
		variable seed : positive := 61631;
		constant M: integer := 502321;
		constant A: integer := 6521;
		constant B: integer := 88977;
	begin
	wait until CLOCK_50'event and CLOCK_50 = '1';

		case state is
		when "00" =>
			table_ready <= '0';
		
			if (set_table = '1') then
				next_state <= "01";
			end if;
		
		when "01" =>
			-- ZERAMENTO DO DECK.
			i := 0;
			while (i < 80) loop
				deck(i) <= 0;
				i := i + 1;
				
				-- Zera o mapeamento das posicoes da mesa.
				table_map(i) <= '0';
				i := i + 1;
			end loop; 
			
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
				
				i := i + 1;
			end loop;
						
			i := 0;
			flag := 0;
			seed := seed_in;
			next_state <= "10";
			
		when "10" =>
			clk_flag <= not clk_flag;
			
			if (clk_flag = '1') then
			
				if i < n_cards then
					if flag = 0 then -- randomiza indice inicial posicao da carta
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
						end if;
					end if;
				else
					-- Quando pronta a mesa, passa para o proximo estado
					next_state <= "11";
				end if;
			end if;

		when "11" =>
			table_ready <= '1';
			
			if (set_table <= '0') then
				next_state <= "00";
			end if;
			
		when others =>
		end case;
		
	end process;

	state <= next_state;
	
end rtl;