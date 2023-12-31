library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

use ieee.numeric_std.all;
--use std.textio.all;
--use work.txt_util.all;
-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
--use ieee.numeric_std.all;
 
entity rom_tb is
--generic (
--			constant data_width : integer := 8;
--            constant addr_cnt	:integer := 22;
--			constant rom_depth  : integer := 640*480
			--			
			--constant data_width : integer := 8;
            --constant addr_cnt	:integer := 10;
			--constant rom_depth  : integer := 256
--);
end rom_tb;
 
architecture behavior of rom_tb is 
 
	--file gaussian_file: text open write_mode is "gaussian.dat";	
	component image_process is
	port (
		clk : in std_logic;
		--en : in std_logic;
		resetn : in std_logic;		
		VGA_HS_O : out  STD_LOGIC;
        VGA_VS_O : out  STD_LOGIC;
        VGA_R : out  STD_LOGIC_VECTOR (3 downto 0);
        VGA_B : out  STD_LOGIC_VECTOR (3 downto 0);
        VGA_G : out  STD_LOGIC_VECTOR (3 downto 0)
	  );
	end component;


   --inputs
   signal clk : std_logic ;
   signal resetn : std_logic ;
   signal VGA_R, VGA_G, VGA_B  :   std_logic_vector(3 downto 0);
    signal VGA_HS_O, VGA_VS_O   :   std_logic ;
 	--outputs
--	signal s_r33, s_r32, s_r31: std_logic_vector(data_width-1 downto 0);
--	signal s_r23, s_r22, s_r21: std_logic_vector(data_width-1 downto 0);
--	signal s_r13, s_r12, s_r11: std_logic_vector(data_width-1 downto 0);
	
--	signal s_gaussian_valid : std_logic;
--	signal s_gaussian_data : std_logic_vector(data_width - 1 downto 0);
   -- clock period definitions
   constant clk_period : time := 8 ns;
   
   

begin
	
   med: image_process
   port map (
        clk => clk,
      --  en => en,
        resetn => resetn,
	    VGA_R => VGA_R,
        VGA_B => VGA_B,
        VGA_G => VGA_g,
        VGA_HS_O => VGA_HS_O,
        VGA_VS_O => VGA_VS_O
        );

   -- clock process definitions
   clk_process :process
   begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
   end process;
 
	rst_process: process
	begin
		resetn <= '1';
		wait for clk_period * 10;
		resetn <= '0';
	
		wait;
	end process;
	
	
	


end;
