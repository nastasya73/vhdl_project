library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--USE ieee.std_logic_arith.ALL;

entity Rom2 is
PORT ( clk			: in std_logic;
		 rst			: in std_logic;
		 A 			: IN std_logic_vector (5 downto 0);
		 Data_in 	: in std_logic_vector (0 to 127);
		 data_enable: in std_logic;
		 data_exit	: out std_logic;
		 D 			: OUT std_logic_vector (7 downto 0));
end Rom2;

architecture Behavioral of Rom2 is

	TYPE ROM_ARRAY_fif IS ARRAY (0 TO 15 ) OF STD_LOGIC_VECTOR (7 DOWNTO 0 );
	CONSTANT ar : ROM_ARRAY_fif := (X"03", X"13", X"23", X"33", X"43", X"53", X"63", X"73", X"83", X"93", X"14", X"24", X"34", X"44", X"54", X"64");

	TYPE ROM_ARRAY IS ARRAY (0 TO 31 ) OF STD_LOGIC_VECTOR (7 DOWNTO 0 );
	signal rom : ROM_ARRAY;
	
	signal data_in_s: std_logic_vector (0 to 127);
	signal data_enable_s: std_logic;
	signal data_enable_zero: std_logic;
	signal y	:  std_logic_vector (7 downto 0);
	--shared variable l: integer := 0;

begin
	
	
	process (clk, rst, data_enable, A)
	
	begin
	
	if rst = '1' then
		data_enable_s <= '0';
		data_exit <= '0';
	elsif (clk'event and clk = '1') then 
	
		if (data_enable = '1' and data_enable_zero = '1') then 
			data_in_s 			<= Data_in;
			data_enable_s 		<= '1';
			data_exit 			<= '0';
			data_enable_zero	<= '0';
		elsif (data_enable = '0') then
			data_enable_zero <= '1';
		end if;
		
		--if (data_enable_s = '1') then
			for i in 0 to 31 loop
				rom(i) <= ar(to_integer(unsigned(data_in_s(i*4 to i*4+3))));
				if i = 31 then data_exit <= '1';
				else data_exit		<= '0';
				end if;
			end loop;
			
			data_exit		<= '0';
			data_enable_s  <= '0';
			
		--end if;
	end if;
end process;

D <= rom(to_integer(unsigned(A)));

end Behavioral;
