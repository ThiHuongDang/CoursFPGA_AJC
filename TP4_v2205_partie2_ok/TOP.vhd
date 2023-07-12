library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity TOP is
    port ( 
		clk			: in std_logic; 
        resetn		: in std_logic;
        bouton0      : in std_logic;
        bouton1      : in std_logic;
	    led_out       : out  std_logic_vector (2 downto 0)
     );
end TOP;

architecture behavioral of TOP is

    signal up_date: std_logic;
    signal Q1,Q2: std_logic;
    signal color_code_in: std_logic_vector(1 downto 0);
    signal color_code, dout: std_logic_vector (2 downto 0);
    signal end_cycle    : std_logic;
    signal full, empty: std_logic;
    -----------
    -- Call the counter_unit programme
    -------
component LEDdriver
		port ( 
	    clk			    : in std_logic; 
        resetn		    : in std_logic;
        color_code_fsm  : in std_logic_vector (2 downto 0);
        up_date         : in std_logic;
        end_cycle       : inout std_logic;
	    led_out         : out  std_logic_vector (2 downto 0)
		 );
	end component;
	-----
	--------- declaration FIFO
	--------- 
 component fifo_generator_0
   PORT (
           clk                       : IN  std_logic := '0';
           srst                      : IN  std_logic := '0';
           wr_en                     : IN  std_logic := '0';
           rd_en                     : IN  std_logic := '0';
           din                       : IN  std_logic_vector(2 DOWNTO 0) := (OTHERS => '0');
           dout                      : OUT std_logic_vector(2 DOWNTO 0) := (OTHERS => '0');
           full                      : OUT std_logic := '0';
           empty                     : OUT std_logic := '1');

    end component;
    
    
	begin
	
	------- Installation module LEDdriver
LED_driver: LEDdriver
        port map (
            clk => clk, 
            resetn => resetn,
            color_code_fsm => dout,
            up_date => '1',          ---- fix up_date = 1 always
            end_cycle  => end_cycle,
            led_out=> led_out	
        );
    ------------Installation FIFO  -  
FIFO: fifo_generator_0
        port map (
             clk => clk, 
             srst => resetn,
             wr_en => up_date,
             rd_en => end_cycle,
             din  =>  color_code,
             dout=> dout,
             full => full,
             empty => empty	
        );
    ------------------------------------          
    --- Process for creating write_enable (wr_en) signal of FIFO
    --------------------------------------
	process ( resetn,clk)
	begin
   if resetn='1' then
	       Q1 <='0'; 
	       Q2 <= '0';   
	elsif (rising_edge(clk)) then
	        Q1<=bouton0;  
	        Q2<=Q1; 
	 else
	       Q1 <= Q1; 
	       Q2 <=Q2;      
	end if;
	end process;
	
	up_date<= not Q2 and Q1;

	--------------------------------------------------
	----- bouton1 to chose the color code: if bouton1 is pressed, led's color is green otherwise led's color is blue
--------------------------
	process (resetn, clk)
	begin
	 if resetn='1' then
	 color_code_in <= "00"; -- LED is off if resetn is active
	elsif (rising_edge(clk)) then
	   if bouton1='1' then --  bouton1 is pressed
	  color_code_in <="10"; --  Green
	  else                  -- bouton1 is not pressed
	  color_code_in <="11";   --- Blue
	  end if;
	end if;
	end process;
	
--- Convert color code from 2 bits to 3 bits	
color_code <= "000" when (color_code_in = "00") -- "00" LED is off
    else "001" when (color_code_in = "01") -- "01" Red
        else "010" when (color_code_in ="10") -- "10" Green
             else "100" ;                     -- Blue  
	         
	
end behavioral;