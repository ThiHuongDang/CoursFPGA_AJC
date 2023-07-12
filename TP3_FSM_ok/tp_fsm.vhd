library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity tp_fsm is
    generic (
      constant  Nb_cycle: positive :=3 --  number of times LED blinks
    );
    port ( 
		clk			: in std_logic; 
        resetn		: in std_logic;
        restart     : in std_logic;
		led_out     : out std_logic_vector (2 downto 0)
     );
end tp_fsm;



architecture behavioral of tp_fsm is

    type state is (idle, rouge, blue, vert); --a modifier avec vos etats
    
    signal current_state  : state;  --etat dans lequel on se trouve actuellement
    signal next_state     : state;	   --etat dans lequel on passera au prochain coup d'horloge
    signal end_counter    : std_logic;
    signal end_counter_cycle: std_logic;
    signal valide: std_logic:='0';
    signal counter_cycle: natural range 0 to Nb_cycle*2; 
    signal led_output: std_logic_vector (2 downto 0):="000";
    
    -- Module of counter_unit programme
component counter_unit
        generic (
          constant cte : positive  -------100000000 -- number of clock cycle 100 Mhz (1s)
          );
		port ( 
			clk			: in std_logic; 
			resetn		: in std_logic;
			end_counter : out std_logic
		 );
	end component;
	

	begin
uut: counter_unit
        generic map (
        Cte => 100000000
        )
        port map (
            clk => clk, 
            resetn => resetn,
            end_counter => end_counter
		
        );
	--- process of creating the second counter: Counter_cycle
		process(clk,resetn)
		begin
            if(resetn='1') then  
                current_state <= idle;
                   counter_cycle<=0;                 
               
			elsif(rising_edge(clk)) then
				current_state <= next_state;                -- states of infite state machine
				    if (end_counter='1') and (end_counter_cycle='0') then
				        counter_cycle <= counter_cycle+1;                           --- counter_cycle counte the cycle of end_counter (counter_unit)
				        elsif (end_counter='0') then 
				        counter_cycle <= counter_cycle;                            --- counter_cycle keeps the same value during one cycle of end_counter
				        end if;
				    if (end_counter='1')and (end_counter_cycle='1')then ----- condition to refresh the cycle counter =0
				     counter_cycle <=0;
				    end if;
				    
              end if;
               
      
       
		end process;
		-- end_counter_cycle is output of the second counter: end_counter_cycle = 1 when number of on/off cycles is reached  
		 --We count each on and off state of the LED, so we count up to 2*Nb_cycle
			end_counter_cycle <='1' when (counter_cycle=2*Nb_cycle-1)
		else '0';
		-- Find when a state of FMS changed
		--Valide <= '1' when ((counter_cycle = (Nb_Cycle*2-1) and End_counter = '1')and (end_counter_cycle='1')) 
		Valide <= '1' when  ((End_counter = '1')and (end_counter_cycle='1')) 
               else '0';
		
	led_out<=led_output; -- output signal of LED
		
		-- FSM
		process(current_state, resetn, restart, valide,counter_cycle) --a completer avec vos signaux
		begin		
           case current_state is
              when idle =>        --- initial state 
              if (restart ='0') then
                if (valide ='0') then
                    if (counter_cycle mod 2 =0) then   --- LED conditions on/off
                        led_output<="000";  --- led is off if the cycle is even
                    else
                     led_output <= "111"; -- led is on if the cycle is odd
                     end if;
                    next_state<=idle;
                 else
			     	next_state <= rouge; -- valide = '1', change to next state (next color)
                end if;
               else 
               next_state <= idle; -- restart ='1', comme back to idle
             -- led_output <="000";
               end if;
              -- Same idea as the idle state
             when rouge =>
              if (restart ='0') then
                if (valide ='0') then
                    if (counter_cycle mod 2 =0) then
                        led_output<="000";
                    else
                     led_output <= "001";
                     end if;
                     next_state <= rouge;
                 else
			     	next_state <= blue;
                end if;
               else 
               next_state <= idle;
             --  led_output<="000";
               end if;
              
              when blue =>
              if (restart ='0') then
                if (valide ='0') then
                    if (counter_cycle mod 2 =0) then
                        led_output<="000";
                    else
                     led_output <= "100";
                     end if;
                     next_state<=blue;
                 else
			     	next_state <= vert; 
                end if;
               else 
               next_state <= idle;
               end if;
              
               when vert =>
              if (restart ='0') then
                if (valide ='0') then
                    if (counter_cycle mod 2 =0) then
                        led_output<="000";
                    else
                     led_output <= "010";
                      end if;
                     next_state<= vert;
                    
                 else
			     	next_state <= rouge; --prochain etat
                end if;
               else 
               next_state <= idle;
               end if;
              
              when others =>
               next_state <= idle;
               led_output<="000";
              
              end case;
          
          
		end process;
		
		
end behavioral;