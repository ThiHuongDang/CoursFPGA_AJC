library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
entity counter_unit is
    port ( 
        clk : in std_logic;
        resetn : in std_logic;
        restart: in std_logic;
        end_counter : out std_logic;
        led0_b : out std_logic
     );
end counter_unit;

architecture behavioral of counter_unit is

    --Declaration des signaux internes
    --constant cte : positive := X"BEB C200";
    --constant cte : positive := 200000000;
    constant cte : positive := 20;
    signal Q : std_logic_vector(27 downto 0); 
    signal end_counter_int : std_logic; 
    --signal end_counter:  std_logic;
    --signal Cmd: std_logic;
    signal led_out:  std_logic :='0'; 


begin
process(clk,resetn,restart)
begin
    if (resetn = '1' or restart='1') then -- 1
       Q <= (others => '0');
      led_out <= (led_out);
    elsif (rising_edge(clk)) then
      Q <= Q + 1;
     if (end_counter_int='1') then
           Q <= (others => '0');
          led_out <= not (led_out);
        
       end if;

    end if;
end process; 

 end_counter_int <= '1' when Q = cte-1
                else '0';
end_counter <= end_counter_int;
led0_b <= led_out;
     
end behavioral;