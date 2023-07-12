library ieee;
use ieee.std_logic_1164.all;

entity tb_TOP is
end tb_TOP;

architecture behavioral of tb_TOP is

	signal resetn      : std_logic := '1';
	signal bouton0     : std_logic := '0';
	signal bouton1     : std_logic := '0' ;
	signal clk         : std_logic := '0';
	signal led_out: std_logic_vector (2 downto 0) :="000";
	
	
	-- Les constantes suivantes permette de definir la frequence de l'horloge 
	constant hp : time := 5 ns;      --demi periode de 5ns
	constant period : time := 2*hp;  --periode de 10ns, soit une frequence de 100Hz
	
	
	component TOP
		port ( 
			clk			: in std_logic; 
			resetn		: in std_logic;
			bouton0      : in std_logic;
			bouton1      : in std_logic;
			led_out      : out std_logic_vector
		 );
	end component;
	
	

	begin
	dut: TOP
        port map (
            clk => clk, 
            resetn => resetn,
            bouton0 => bouton0,
            bouton1 => bouton1,
			led_out => led_out
        );
		
	--Simulation du signal d'horloge en continue
	process
    begin
		wait for hp;
	   clk <= not clk;
	   end process;
	   
	---- resetn   
    process
	begin        
	resetn <= '1';
	wait for period;    
		resetn <= '0';
		wait for 100000000*hp ; -- wait to finish all the clock cycle
	   
	end process;
-- ckeck bouton0
 process
 begin
 wait for 500*period;
 bouton1 <= not bouton1;
  end process;
  
--- check bouton0
  process
   begin
	wait for 700*period;
	 bouton0 <= not bouton0;
	end process;
	   	
end behavioral;