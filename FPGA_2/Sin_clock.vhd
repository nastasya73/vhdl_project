-- freq 

-- 000 - 10,00 ÊÃö (100 mks)
-- 001 - 11,11 ÊÃö  (90 mks)
-- 010 - 12,50 ÊÃö  (80 mks)
-- 011 - 14,29 ÊÃö  (70 mks)
-- 100 - 16,70 ÊÃö  (60 mks)
-----------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity Sin_clock is
	port ( clk			: in std_logic;
			 rst			: in std_logic;
			 freq			: in std_logic_vector (2 downto 0);
			 enable_clk	: in std_logic;
			 sin_clk		: out std_logic);
end Sin_clock;

architecture Behavioral of Sin_clock is

constant freq_fpga  : std_logic_vector(11 DOWNTO 0):= X"032"; -- 50 Ìãö
signal freq_cnt	  : std_logic_vector(11 DOWNTO 0):= X"3E8"; -- 20 mks
signal cnt          : std_logic_vector(11 DOWNTO 0) :=(OTHERS=>'0');
signal cnt_2        : std_logic_vector(11 DOWNTO 0) :=(OTHERS=>'0');

signal cnt_half_period   : std_logic_vector(3 DOWNTO 0):=(OTHERS=>'0');
signal enable_clk_s		 : std_logic := '0';
signal sin_clk_s			 : std_logic := '0';
signal per_2			    : std_logic := '0';

begin

p1: process (clk, rst) 
		begin
		
		case freq is
			when "001" => freq_cnt <= X"5DC"; --30*freq_fpga;
			when "010" => freq_cnt <= X"6D6"; --35*freq_fpga;
			when "011" => freq_cnt <= X"7D0"; --40*freq_fpga;
			when "100" => freq_cnt <= X"8CA"; --45*freq_fpga;
			when "101" => freq_cnt <= X"9C4"; --50*freq_fpga;
			when others => freq_cnt <= X"8CA"; --45*freq_fpga;
		end case;
	end process;

p2: process (clk, rst) 
		begin 
			IF (rst = '1') THEN
				cnt_half_period  <= (OTHERS=>'0');
				cnt_2 			  <= (OTHERS=>'0');
				cnt  				  <= (OTHERS=>'0');
				enable_clk_s 	  <= '0';		
			ELSIF (clk = '1' and clk'Event) THEN
			
				IF (enable_clk_s ='1') THEN
				
					IF (cnt_half_period < X"B") THEN
					
						IF (cnt < freq_cnt) THEN 
							cnt  		<= cnt+'1';
							sin_clk  <= '0';
						ELSE per_2 <= '1';
						end if;
						
						
						IF ((per_2 = '1') and (cnt_2 < freq_cnt)) THEN 
							cnt_2 	<= cnt_2 +'1';
							sin_clk 	<= '1';
						ELSIF ((per_2 = '1') and (cnt_2 = freq_cnt)) THEN
							 per_2 <= '0';
							 cnt   <= (OTHERS=>'0');
							 cnt_2 <= (OTHERS=>'0');
							 cnt_half_period <= cnt_half_period +'1';
						END IF;
						
						
					ELSIF (cnt_half_period = X"B") THEN
							cnt_half_period <= X"0";
							enable_clk_s	 <= '0';
					END IF;
					  
            END IF;
				
				
				IF enable_clk = '1' THEN
					enable_clk_s <= '1';
				END IF;
				
			END IF;
End process;



end Behavioral;
