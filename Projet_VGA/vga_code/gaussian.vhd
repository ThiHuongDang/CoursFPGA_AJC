library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity gaussian is
generic (
			constant data_width : integer := 8; --- taille de signal  dout : out std_logic_vector(data_width-1 downto 0)
            constant addr_cnt	:integer := 22 --- pas utilise
);
port (
		clk : in std_logic;
		resetn : in std_logic;
		en     : in std_logic;
		r33, r32, r31, r23,r22,r21,r13,r12,r11 : in std_logic_vector(data_width-1 downto 0); --- 9 pixels de, un pixel a taille de 8 bits: 3 bits pour rouge, 3 pour verte, 2 pour bleu
		in_data_valid : in std_logic;
		out_data_valid : out std_logic;
		dout : out std_logic_vector(data_width-1 downto 0)
	  );
end gaussian;

architecture gaussian of gaussian is


	signal s_dout : std_logic_vector(data_width - 1 downto 0);
	
	signal s_in_valid: std_logic;
	signal s_out_valid: std_logic;

	signal mul_10 : unsigned(4 downto 0) := "00001"; --- elements dans la matrice Gaussian
	signal mul_16 : unsigned(4 downto 0) := "00010";  --- --- elements dans la matrice Gaussian
	signal mul_26 : unsigned(4 downto 0) := "00100";   --- elements dans la matrice Gaussian

   
--   signal mul_10 : unsigned(4 downto 0) := "00000"; --- elements dans la matrice unit�
--  signal mul_16 : unsigned(4 downto 0) := "00000";  --- --- elements dans la matrice unit�
--  signal mul_26 : unsigned(4 downto 0) := "00001";   --- elements dans la matrice unit�

	---- les signax de multiplications, adders
	signal s_r33, s_r32, s_r31, s_r23,s_r22,s_r21,s_r13,s_r12,s_r11 : unsigned(r11'range) ;
	signal s_mul_11,s_mul_12,s_mul_13,s_mul_21,s_mul_22,s_mul_23,s_mul_31,s_mul_32,s_mul_33 : unsigned(s_r11'length + mul_26'length - 1 downto 0) ;
	signal s_add_11_13, s_add_31_33, s_add_12_32, s_add_21_23, s_add_22: unsigned(s_mul_11'length downto 0);
	signal s_add_11_13_31_33, s_add_12_32_21_23,s_add_add_22: unsigned(s_add_11_13'length downto 0);
	signal s_add_other,s_add_add_add_22 : unsigned(s_add_11_13_31_33'length downto 0);
	signal s_add_all : unsigned(s_add_other'length downto 0);
	signal s_en: std_logic;
--	signal s_tmp_all : std_logic_vector(s_add_other'length downto 0);
---- Les signaux de valide chaque etape
	signal step1_valid, step2_valid, step3_valid, step4_valid, step5_valid : std_logic;
	
begin
	--external module input signal
	s_en <= en;
	s_r11	<=	unsigned(r11);
	s_r12	<=	unsigned(r12);
	s_r13	<=	unsigned(r13);
	s_r21	<=	unsigned(r21);
	s_r22	<=	unsigned(r22);
	s_r23	<=	unsigned(r23);
	s_r31	<=	unsigned(r31);
	s_r32	<=	unsigned(r32);
	s_r33	<=	unsigned(r33);
	

	s_in_valid <= in_data_valid;
		
	--external module output signal
	out_data_valid <= s_out_valid;	
	dout	<=	s_dout;	
	s_out_valid <= step5_valid;
	
	s_dout <= std_logic_vector(resize(shift_right(s_add_all, 4), s_dout'length));
--    s_dout <= std_logic_vector(resize(shift_right(s_add_all, 0), s_dout'length));
	--gaussian filter
	--	|1 2 1|
	--	|2 4 2|	/ 16
	--	|1 2 1|
	
	step1: process(clk, resetn)
	begin
		if resetn = '1' then
			s_mul_11 <= (others => '0');		s_mul_23 <= (others => '0');
			s_mul_12 <= (others => '0');        s_mul_31 <= (others => '0');
			s_mul_13 <= (others => '0');        s_mul_32 <= (others => '0');
			s_mul_21 <= (others => '0');        s_mul_33 <= (others => '0');
			s_mul_22 <= (others => '0');		
			
			step1_valid<= '0';
		elsif rising_edge(clk) then
		if s_en ='1' then
			s_mul_11 <= s_r11 * mul_10;	s_mul_13 <= s_r13 * mul_10;   s_mul_31 <= s_r31 * mul_10;	s_mul_33 <= s_r33 * mul_10;
			s_mul_21 <= s_r21 * mul_16; s_mul_12 <= s_r12 * mul_16;   s_mul_23 <= s_r23 * mul_16;   s_mul_32 <= s_r32 * mul_16;
			s_mul_22 <= s_r22 * mul_26;
			step1_valid <= s_in_valid;
			else
			s_mul_11 <= (others => '0');		s_mul_23 <= (others => '0');
			s_mul_12 <= (others => '0');        s_mul_31 <= (others => '0');
			s_mul_13 <= (others => '0');        s_mul_32 <= (others => '0');
			s_mul_21 <= (others => '0');        s_mul_33 <= (others => '0');
			s_mul_22 <= (others => '0');
			end if;
		end if;
	end process;
	
	step2: process(clk, resetn)
	begin
		if resetn = '1' then
			step2_valid <= '0';
			s_add_11_13 <= (others => '0');
			s_add_31_33 <= (others => '0');
			s_add_12_32 <= (others => '0');
			s_add_21_23 <= (others => '0');
			s_add_22	<= (others => '0');
			
		elsif rising_edge(clk) then
		if s_en <='1' then
			s_add_11_13	<= resize(s_mul_11,s_add_11_13'length) + resize(s_mul_13,s_add_11_13'length);
			s_add_31_33 <= resize(s_mul_31,s_add_31_33'length) + resize(s_mul_33,s_add_31_33'length);
			s_add_12_32 <= resize(s_mul_12,s_add_12_32'length) + resize(s_mul_32,s_add_12_32'length);
			s_add_21_23 <= resize(s_mul_21,s_add_21_23'length) + resize(s_mul_23,s_add_21_23'length);
			s_add_22	<= resize(s_mul_22, s_add_22'length);
			step2_valid <= step1_valid;
			end if;
			
		end if;
	end process;
	
	step3: process(clk, resetn)
	begin
		if resetn = '1' then
			step3_valid <= '0';
			s_add_11_13_31_33 <= (others => '0');
			s_add_12_32_21_23 <= (others => '0');
			s_add_add_22	<= (others => '0');
			
		elsif rising_edge(clk) then
		if s_en ='1' then
			s_add_11_13_31_33 <= resize(s_add_11_13	,s_add_11_13_31_33'length)+ resize(s_add_31_33 ,s_add_11_13_31_33'length);
			s_add_12_32_21_23 <= resize(s_add_12_32 ,s_add_12_32_21_23'length)+ resize(s_add_21_23 ,s_add_12_32_21_23'length);
			s_add_add_22<= '0'&s_add_22;
			step3_valid <= step2_valid;
			
			end if;
		end if;
	end process;
	
	step4: process(clk, resetn)
	begin
		if resetn = '1' then
			step4_valid <= '0';
			s_add_other <= (others => '0');
			s_add_add_add_22	<= (others => '0');
			
		elsif rising_edge(clk) then
		if s_en ='1' then
			s_add_other <= resize(s_add_11_13_31_33, s_add_other'length) + resize(s_add_12_32_21_23 , s_add_other'length);
			s_add_add_add_22 <= '0'&s_add_add_22;
			step4_valid <= step3_valid;
			end if;
		end if;
	end process;
	
	step5: process(clk, resetn)
	begin
		if resetn = '1' then
			step5_valid <= '0';
			s_add_all <= (others => '0');			
		elsif rising_edge(clk) then
		if s_en ='1' then
			s_add_all <= resize(s_add_other, s_add_all'length) +  resize(s_add_add_add_22, s_add_all'length) ;
			step5_valid <= step4_valid;
		end if;
		end if;
	end process;
end gaussian;
