library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity LCD_Ex2 is
	PORT(
			clk 			:IN STD_LOGIC;
			rst			:IN STD_LOGIC;
			data_in		:in std_logic_vector (0 to 127);
			data_enable	:in std_logic;
			rw, rs, e 	:OUT STD_LOGIC;
			lcd_data 	:OUT STD_LOGIC_VECTOR(7 downto 0));
end LCD_Ex2;

architecture Behavioral of LCD_Ex2 is
	signal lcd_enable  : std_logic;
	signal lcd_bus     : std_logic_vector(9 downto 0);
	signal lcd_busy    : std_logic;
	signal address     : std_logic_vector (5 downto 0);
	signal data        : std_logic_vector(7 downto 0);
	signal data_exit	 : std_logic; 
	signal data_enable_zero: std_logic;-- := '1'; 

	Component lcd_controller is
		PORT(
		 clk        : IN    STD_LOGIC;  --system clock
		 reset_n    : IN    STD_LOGIC;  --active low reinitializes lcd
		 lcd_enable : IN    STD_LOGIC;  --latches data into lcd controller
		 lcd_bus    : IN    STD_LOGIC_VECTOR(9 DOWNTO 0);  --data and control signals
		 busy       : OUT   STD_LOGIC;  --lcd controller busy/idle feedback
		 rw, rs, e  : OUT   STD_LOGIC;  --read/write, setup/data, and enable for lcd
		 lcd_data   : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0)); --data signals for lcd
	end component;
	
	Component ROM2 is
		Port ( 	clk			: in std_logic;
					rst			: in std_logic;
					A 				: IN std_logic_vector (5 downto 0);
					Data_in 		: in std_logic_vector (0 to 127);
					data_enable : in std_logic;
					data_exit	: out std_logic;
					D 				: OUT std_logic_vector (7 downto 0));
	end component;

begin
	c1: lcd_controller
		PORT MAP(clk 			 => clk, 
					reset_n 		 => rst, 
					lcd_enable	 => lcd_enable,
					lcd_bus 		 => lcd_bus,
					busy 			 => lcd_busy,
					rw 			 => rw,
					rs				 => rs,
					e 				 => e,
					lcd_data 	 => lcd_data);
	c2: ROM2
		PORT MAP(clk 			 => clk,
					rst			 => rst,
					A 				 => address,
					Data_in 		 => Data_in,
					data_enable  => data_enable,
					data_exit 	 => data_exit,
					D 				 => data);

	process(clk)
		
		variable char : integer range 0 to 34 := 0;
		begin
			if(clk'event and clk = '1') then				
				if(lcd_busy = '0' and lcd_enable = '0') then
					lcd_enable <= '1';
					
					--if(char = 34) then 
						--lcd_enable <= '0';
						--char := 0;
						--lcd_bus <= "00" & X"01";
					--end if;	
					
					case char is  
						when 0 => 
									address <= "00" & X"0";
									--lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);
						when 1 => 
									address <= "00" & X"1";
									lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);
						when 2 =>
									address <= "00" & X"2";
									lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);
						when 3 => 
									address <= "00" & X"3";
									lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);					
						when 4 => 
									address <= "00" & X"4";
									lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);
						when 5 =>
									address <= "00" & X"5";
									lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);
						when 6 => 
									address <= "00" & X"6";
									lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);
						when 7 => 
									address <= "00" & X"7";
									lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);	
						when 8 => 
									address <= "00" & X"8";
									lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);	
						when 9 => 
									address <= "00" & X"9";
									lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);	
						when 10 => 
									address <= "00" & X"A";
									lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);	
						when 11 => 
									address <= "00" & X"B";
									lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);	
						when 12 => 
									address <= "00" & X"C";
									lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);	
						when 13 => 
									address <= "00" & X"D";
									lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);
						when 14 => 
									address <= "00" & X"E";
									lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);
						when 15 => 
									address <= "00" & X"F";
									lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);		
						when 16 => 
									address <= "01" & X"0";
									lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);
											
						when 17 => 
									lcd_bus <= "00" & X"C0";
						when 18 => 
									address <= "01" & X"1";
									lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);	
						when 19 => 
									address <= "01" & X"2";
									lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);	
						when 20 => 
									address <= "01" & X"3";
									lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);	
						when 21 => 
									address <= "01" & X"4";
									lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);	
						when 22 => 
									address <= "01" & X"5";
									lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);	
						when 23 => 
									address <= "01" & X"6";
									lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);
						when 24 => 
									address <= "01" & X"7";
									lcd_bus <= "10" & data (3 downto 0) & data (7 downto 4);
						when 25 => 
									address <= "01" & X"8";
									lcd_bus <= "10" & data (3 downto 0) & data (7 downto 4);		
						when 26 => 
									address <= "01" & X"9";
									lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);	
						when 27 => 
									address <= "01" & X"A";
									lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);	
						when 28 => 
									address <= "01" & X"B";
									lcd_bus <= "10" & data (3 downto 0) & data (7 downto 4);
						when 29 => 
									address <= "01" & X"C";
									lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);
						when 30 => 
									address <= "01" & X"D";
									lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);	
						when 31 => 
									address <= "01" & X"E";
									lcd_bus <= "10" & data (3 downto 0) & data (7 downto 4);	
						when 32 => 
									address <= "01" & X"F";
									lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);	
						when 33 => lcd_bus <= "10" & data(3 downto 0) & data (7 downto 4);
									--address <= "00" & X"0";
									 --data(3 downto 0) & data (7 downto 4);
						when 34 => lcd_bus <= "00" & X"02";
									  --lcd_enable <= '0';
					end case;
				
					if(char < 34) then
						char := char + 1;	
					elsif (char = 34) then
						char := 0;
						lcd_enable <= '0';
					end if;
					
									
					
					if (data_enable = '0') then 
						data_enable_zero <= '1';
					elsif ((data_enable = '1') and (data_enable_zero ='1'))then 
						lcd_bus <= "00" & X"01";
						data_enable_zero <= '0';
						char := 0;
					end if;
					
				else
					lcd_enable <= '0';
				end if;

			end if;
	end process;
end Behavioral;


