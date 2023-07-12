library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity LEDdriver is

    port ( 
		clk			    : in std_logic; 
        resetn		    : in std_logic;
        up_date         : in std_logic;
        color_code_fsm  : in std_logic_vector (2 downto 0);
        end_cycle       : inout std_logic :='0';
	    led_out         : out  std_logic_vector (2 downto 0)
     );
end LEDdriver;



architecture behavioral of LEDdriver is

    type state is (idle, led_on); --a modifier avec vos etats
    signal current_state : state;  --etat dans lequel on se trouve actuellement
    signal next_state : state;	   --etat dans lequel on passera au prochain coup d'horloge
    signal end_counter: std_logic;
    signal  color_out: std_logic_vector(2 downto 0);
    signal led_output:  std_logic_vector (2 downto 0);
    signal count_cycle:  natural range 0 to 1;
    signal end_counter_cycle : std_logic :='0';
    
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
        Cte =>  100000000 ----100000000 (1s with 100 MHz clock)
        )
        port map (
            clk => clk, 
            resetn => resetn,
            end_counter => end_counter	
        );
   ----------------------------------------
   --------   Process for creating signal end_cycle: end_cycle =1 à la fin d'un cycle allumé/étenit de la LED
   ----------------------------------------  
		process(clk,resetn)
		begin
           if(resetn='1') then  
             current_state <=idle;
             count_cycle <=0;  --- if resetn is active, count_cycle =0
	   	elsif(rising_edge(clk)) then
			current_state<=next_state;
			if (end_counter = '1') and (end_counter_cycle='0') then
			count_cycle <= count_cycle +1;  ----- count_cycle increase the value when end_counter =1 ultil it reaches the max value of counter
			end if;  
			if end_counter ='0' then       ------- counter keeps the value if end_counter =0
			count_cycle <= count_cycle;
			end if;
			if (end_counter ='1') and (end_counter_cycle ='1') then   ---- count_cycle come back to 0 when the counter reaches the max value
			count_cycle <=0;      
			end if;
	
		end if;
				end process;
				
		end_counter_cycle<='1' when count_cycle=1  --- define signal end_counter_cycle
		else '0';
	    end_cycle <= end_counter_cycle and end_counter;     --- define end_cycle    
 
 ------------------
 ------------------ Process to define color of LED: the LED changes the color if the up_date signal is 1 otherwise LED desn't change the color
 ------------------
   process (resetn,clk,up_date)
	begin
	if resetn='1' then
        color_out <= "000";
	elsif (rising_edge(clk)) then
	   if up_date ='1' then
	   color_out <= color_code_fsm;
	   else
	   color_out <= color_out;
	  end if;
	   end if;
	end process;
	
	
   ---------------------------------------------------
	-- FSM to control on/off the led: LED changes from on to off ( off to on) when end_counter =1 
	----------------------------------------------------
		process(current_state,end_counter) --a completer avec vos signaux
		begin		
           case current_state is
           when idle =>                                         --- initial state : led is off
             led_output <="000";
            if (end_counter='1') then
            next_state <= led_on;                     --- if end_counter =1 , LED changes the state
            else
            next_state <= current_state;              ---- if end_counter =0, LED keeps the current state
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
		
	
led_out<= (color_out and led_output);    -- LED on/off with corresponding color

	
	
end behavioral;