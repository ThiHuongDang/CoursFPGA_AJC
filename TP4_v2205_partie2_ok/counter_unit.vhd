library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
entity counter_unit is
    generic (
      constant cte : positive -- number of clock cycle
    );
    port ( 
        clk     : in std_logic;
        resetn  : in std_logic;
        end_counter : out std_logic
      
     );
end counter_unit;

architecture behavioral of counter_unit is

    signal Q : std_logic_vector (27 downto 0); 
    signal end_counter_int : std_logic :='0'; 
    
begin
process(clk,resetn)
begin
--
if (resetn = '1') then 
          Q <= (others => '0');
    elsif (rising_edge(clk)) then
         Q <= Q + 1;
     if (end_counter_int='1') then
           Q <= (others =>'0');
        
       end if;

    end if;
end process; 

end_counter_int <= '1' when Q = cte-1
                else '0';
end_counter <= end_counter_int;
 
end behavioral;