library ieee;
use ieee.std_logic_1164.all;

entity tb_tp_fsm is
end tb_tp_fsm;

architecture behavioral of tb_tp_fsm is

	signal resetn      : std_logic := '1';
	signal restart     : std_logic := '0';
	signal clk         : std_logic := '0';
	--signal end_counter_cycle   : std_logic; 
	signal led_out: std_logic_vector( 2 downto 0) ;
	
	-- Les constantes suivantes permette de definir la frequence de l'horloge 
	constant hp : time := 5 ns;      --demi periode de 5ns
	constant period : time := 2*hp;  --periode de 10ns, soit une frequence de 100Hz
	
	
	component tp_fsm
		port ( 
			clk			: in std_logic; 
			resetn		: in std_logic;
			restart: in std_logic;
			LED_OUT : out std_logic_vector( 2 downto 0)		
		 );
	end component;
	
	

	begin
	dut: tp_fsm
        port map (
            clk => clk, 
            resetn => resetn,
            restart => restart,
			led_out => led_out
			
        );
		
	--Simulation du signal d'horloge en continue
	process
    begin
	wait for hp;
	clk <= not clk;
	end process;

	process
	begin        
	
		resetn <= '1';
		wait for period;    
		resetn <= '0';
	     
		wait for 10000 ms; -- wait to finish all the clock cycle 
	end process;
	
	
	
end behavioral;