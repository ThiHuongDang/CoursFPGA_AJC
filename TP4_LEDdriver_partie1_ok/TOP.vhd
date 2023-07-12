library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Define the ports 
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
-- Define the internal signal
    signal up_date: std_logic; -- up_date signal
    signal Q1,Q2: std_logic;  -- signals of two registres which creat the pulse up_date singal: one cycle of clock
    signal color_code_in: std_logic_vector(1 downto 0); 
    signal color_code   : std_logic_vector (2 downto 0);
  
    -- Call the modules
    
component LEDdriver
		port ( 
	    clk			    : in std_logic; 
        resetn		    : in std_logic;
        color_code      : in std_logic_vector (2 downto 0);
        up_date         : in std_logic;
	    led_out         : out  std_logic_vector (2 downto 0)
		 );
	end component;
	
	begin
LED_driver: LEDdriver
        port map (
            clk => clk, 
            resetn => resetn,
            color_code => color_code,
            up_date => up_date,
            led_out=> led_out	
        );
        
    ---process with 2 registres to make update value is a pulse singal    
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

	 up_date<= not Q2 and Q1; -- define up_date value


	----- bouton1 to chose the color code: if bouton1 is pressed, led's color is green otherwise led's color is blue
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