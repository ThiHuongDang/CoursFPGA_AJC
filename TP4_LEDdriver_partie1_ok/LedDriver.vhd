library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity LEDdriver is
    port ( 
		clk			    : in std_logic; 
        resetn		    : in std_logic;
        up_date         : in std_logic;
        color_code      : in std_logic_vector (2 downto 0);
	    led_out         : out  std_logic_vector (2 downto 0)
     );
end LEDdriver;


architecture behavioral of LEDdriver is
  --- Define the internal signals
    type state is (idle, led_on); --a modifier avec vos etats
    signal current_state : state;  --etat dans lequel on se trouve actuellement
    signal next_state : state;	   --etat dans lequel on passera au prochain coup d'horloge
    signal end_counter: std_logic;  -- signal of counter_unit
    signal color_out: std_logic_vector(2 downto 0) :="000"; 
    signal led_output:  std_logic_vector (2 downto 0) :="000"; -- output signal of FSM
    
    -- Call the counter_unit programme
     component counter_unit
     generic (
      constant cte : positive
     );
		port ( 
			clk			: in std_logic; 
			resetn		: in std_logic;
			end_counter : inout std_logic
		 );
	end component;
	begin
uut: counter_unit
          generic map (
	       Cte => 100000000  --1s for 100 MHz clock
	       )
        port map (
            clk => clk, 
            resetn => resetn,
            end_counter => end_counter	
        );
        
    --- Process to define states of FSM    
		process(clk,resetn)
		begin
           if(resetn='1') then  
             current_state <=idle;
	   	elsif(rising_edge(clk)) then
			current_state<=next_state;
		end if;
				end process;
	-------			
	---- Process to define color of LED: the LED changes the color if the up_date signal is 1 otherwise LED desn't change the color
	            
   process (resetn,clk,up_date)
	begin
	if resetn='1' then
        color_out <= "000";
	elsif (rising_edge(clk)) then
	   if up_date ='1' then 
	   color_out <= color_code;  -- LED changes color if up_date=1
	   else
	   color_out <= color_out;  ---- LED keeps the color if up_date =0
	  end if;
	   end if;
	end process;
       --------
		-- FSM to control on/off the led: LED changes from on to off ( off to on) when end_counter =1 
		process(current_state,end_counter) --a completer avec vos signaux
		begin		
           case current_state is
           when idle =>                                         --- initial state: led off
             led_output <="000";    --- LED is off
             if (end_counter='1') then    --- 
            next_state <= led_on;     --- if end_counter=1, LED changes the states (from off to on)
            else 
            next_state <= current_state; --- if end_counter =0, LED doesn't change the state
            end if; 
            
             when led_on=>                                      ----led on     
            led_output <= "111";
           if (end_counter='1') then
             next_state <= idle;
            else
             next_state <= current_state;
            end if;
              end case;
		end process;
		
led_out<= (color_out and led_output); -- LED on/off with corresponding color

	
end behavioral;