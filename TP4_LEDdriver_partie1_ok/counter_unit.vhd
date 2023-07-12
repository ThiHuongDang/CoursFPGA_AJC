library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
entity counter_unit is
    generic (
     constant cte : positive   -- number of clock cycle need to count
    );
    port ( 
        clk : in std_logic;
        resetn : in std_logic;
        end_counter : out std_logic 
      
     );
end counter_unit;

architecture behavioral of counter_unit is
   -- Define the internal signals 
    --signal Q : std_logic_vector(27 downto 0); 
    signal Q : std_logic_vector (27 downto 0);  -- counter clock cycle
    signal end_counter_int : std_logic :='0'; 
    
begin
process(clk,resetn)
begin
--
if (resetn = '1') then 
        Q <= (others => '0'); -- the counter goes to Zero if reset is active
   
    elsif (rising_edge(clk)) then
         Q <= Q + 1;     -- if resetn is not active, the counter will count up on each rising clock 
     if (end_counter_int='1') then
          Q <= (others => '0'); --- the counter goes to zero if the number of clock cycles is reached
       
       end if;

    end if;
end process; 

end_counter_int <= '1' when Q = cte-1
                else '0';
end_counter <= end_counter_int;  --- define the ouput value of module counter_unit
 
end behavioral;