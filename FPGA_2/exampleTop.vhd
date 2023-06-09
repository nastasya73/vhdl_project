library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

ENTITY testTop IS
    PORT (  clk    : IN    std_logic; 
            rst    : IN    std_logic; 
				btn	 : IN		std_logic; 
				btn_1	 : IN		std_logic; 
            LED    : OUT   std_logic_vector (7 DOWNTO 0); 
            KBData : INOUT std_logic; 
            KBClk  : INOUT std_logic;
				KBData_2 : INOUT std_logic; 
            KBClk_2  : INOUT std_logic;
				lcd_rw 	:  OUT  std_logic;   				--read & write control
				lcd_e  	:  OUT  std_logic;   				--enable control
				lcd_rs 	:  OUT  std_logic;   				--data or command control
				LCD_DATA	: OUT   std_logic_vector(7 downto 0));
END testTop;

ARCHITECTURE Behavioral OF testTop IS

    COMPONENT KbdCore
        PORT (  clk             : IN    STD_LOGIC;
                rst             : IN    STD_LOGIC;
                rdOBuff         : IN    STD_LOGIC;
                wrIBuffer       : IN    STD_LOGIC;
                dataFromHost    : IN    STD_LOGIC_VECTOR(7 downto 0);
                KBData          : INOUT STD_LOGIC;
                KBClk           : INOUT STD_LOGIC;
					 period			  : OUT   STD_LOGIC_VECTOR(11 downto 0);
                statusReg       : OUT   STD_LOGIC_VECTOR(7 downto 0);
                dataToHost      : OUT   STD_LOGIC_VECTOR(7 downto 0));
    END COMPONENT;
	 
	 COMPONENT CORE
        PORT ( clk              : IN    STD_LOGIC;
					rst              : IN    STD_LOGIC;
					rdOBuff          : IN    STD_LOGIC; --��������� ������ �� ����� �� ������
					wrIBuff          : IN    STD_LOGIC; -- ���������� ������ ��� �����
					DataToIBuff      : IN    STD_LOGIC_VECTOR(7 downto 0); -- ������ ��� �����
					KBData           : INOUT STD_LOGIC;
					KBClk            : INOUT STD_LOGIC;
					emptyOBuff		  : OUT   STD_LOGIC;-- ���� �� ������ �� �����
					DataFromOBuff	  : OUT   STD_LOGIC_VECTOR(7 downto 0); --������ �� �����
					statusReg        : OUT   STD_LOGIC_VECTOR(7 downto 0));
					--read_data_1: OUT   STD_LOGIC_VECTOR(7 downto 0));
    END COMPONENT;
	 
	 COMPONENT Main
			PORT(	 CLK 				  : IN  std_logic;
					 RESET 			  : IN  std_logic;
					 ENCR_DECR 		  : IN  STD_LOGIC;
					 DATA_WRITE 	  : IN  std_logic;
					 INPUT_TEXT 	  : IN  std_logic_vector(0 to 127);
					 AVAILABLE 		  : OUT std_logic;
					 OUTPUT_TEXT 	  : OUT std_logic_vector(0 to 127));
    END COMPONENT;
	 
	 COMPONENT LCD_ex2
		  port ( clk 				  : IN  std_logic;    				--clock i/p
					rst  			     : IN  std_logic;  
					data_in			  : IN  std_logic_vector (0 to 127);
					data_enable		  : IN  std_logic;
					rw, rs, e 		  : OUT STD_LOGIC;
					lcd_data 		  : OUT STD_LOGIC_VECTOR(7 downto 0));  	--data line
	 END COMPONENT;

   SIGNAL dataToHost    : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL dataFromHost  : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL statusReg     : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL wr_en         : STD_LOGIC;
   SIGNAL rd_en         : STD_LOGIC;
	
	SIGNAL btn_on   		: STD_LOGIC;
	--SIGNAL cnt   		   : STD_LOGIC;
	
	--aes
	SIGNAL ENCR_DECR  		: std_logic;-- := '0';
   SIGNAL DATA_WRITE 		: std_logic; --:= '0';
   SIGNAL INPUT_TEXT 		: std_logic_vector(0 to 127); -- := (others => '0');
 
   SIGNAL AVAILABLE 			: std_logic;
   SIGNAL OUTPUT_TEXT 		: std_logic_vector(0 to 127);
	
	signal OUTPUT_TEXT_en: std_logic_vector(0 to 127);
	--lcd
	SIGNAL for_lcd  	 		: std_logic_vector(0 to 127);
	SIGNAL rd_en_lcd     	: STD_LOGIC:='0';
	SIGNAL sr_p     : STD_LOGIC_VECTOR(4 DOWNTO 0);
	
	SIGNAL for_lcd_en  	 		: std_logic_vector(0 to 127);
	
	
	SIGNAL statusReg_kb  	: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL emptyOBuff_kb 	: STD_LOGIC;
   SIGNAL wr_en_kb      	: STD_LOGIC;
   SIGNAL rd_en_kb      	: STD_LOGIC;
	SIGNAL DataToIBuff_kb   	: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL DataFromOBuff_kb : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL read_data_1	   	: STD_LOGIC_VECTOR(7 DOWNTO 0);
	
	
	SIGNAL cnt  				: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL rec_cnt 			: STD_LOGIC_VECTOR(1 DOWNTO 0);
	
	signal cnt_buf : STD_LOGIC_VECTOR(7 DOWNTO 0);
	
	SIGNAL cnt_input			: std_logic_vector (1 downto 0) := "00";
	SIGNAL data_exit_lcd		: std_logic;
	SIGNAL aval_aes			: std_logic;
	SIGNAL data_sig			: std_logic;
	
	SIGNAL buff_count	   	: STD_LOGIC_VECTOR(7 DOWNTO 0);
	
	
BEGIN

    KBD_Mod : KbdCore
        port map (  clk             =>  clk, 
                    rst             =>  rst,
                    rdOBuff         =>  rd_en,
                    wrIBuffer       =>  wr_en,
                    dataFromHost    =>  dataFromHost,
                    KBData          =>  KBData,
                    KBClk           =>  KBClk,
                    statusReg       =>  statusReg,
                    dataToHost      =>  dataToHost);
		
		KB: CORE
        port map (  clk             =>  clk, 
                    rst             =>  rst,
                    rdOBuff         =>  rd_en_kb,
                    wrIBuff         =>  wr_en_kb,
                    DataToIBuff     =>  DataToIBuff_kb,
                    KBData          =>  KBData_2,
                    KBClk           =>  KBClk_2,
                    statusReg       =>  statusReg_kb,
						  emptyOBuff		=>  emptyOBuff_kb,
                    DataFromOBuff   =>  DataFromOBuff_kb);
						 -- read_data_1 => read_data_1);
		
		AES: Main
			port map (	CLK 				=> CLK,
							RESET 			=> rst,
							ENCR_DECR 		=> ENCR_DECR,
							DATA_WRITE 		=> DATA_WRITE,
							INPUT_TEXT 		=> INPUT_TEXT,
							AVAILABLE 		=> AVAILABLE,
							OUTPUT_TEXT 	=> OUTPUT_TEXT);
							
		Display: LCD_ex2
			port map (  clk 				=> clk,
							rst  			   => rst,
							data_in			=> for_lcd,
							data_enable		=> rd_en_lcd,
							rw	      		=> lcd_rw,		
							e 	     		   => lcd_e,				
							rs	      		=> lcd_rs,				
							LCD_DATA	      => LCD_DATA);
        
    -- read FIFO whenever the 8th bit status register is '0' 
  PROCESS (clk,rst)
    BEGIN
    IF (rst = '1') THEN
        rd_en <= '0';
		  cnt_buf <= (others => '0');
		  btn_on <= '0';
		  wr_en <= '0';
		  data_sig <= '0';
		  buff_count <= (others => '0');
    ELSIF RISING_EDGE(clk) THEN
        IF (statusReg(7) = '0') THEN
            rd_en <= '1';
				cnt    	<= "01";
				data_sig <= '0';
			ELSIF (cnt = "01") THEN
				rd_en  <= '0';
				cnt 		<= "10";
				data_sig <= '0';
			ELSIF (cnt = "10") THEN
				rd_en  <= '1';
				cnt 		<= "11";
				--DataToIBuff_kb <= dataToHost;
				for_lcd_en <= dataToHost & for_lcd_en (0 to 119); --(3 downto 0) & dataToHost(7 downto 4)
				cnt_buf 	  <= cnt_buf + '1';
				data_sig <= '0';
				IF (cnt_buf = X"0F") THEN
					buff_count    <= buff_count + '1';
					cnt_buf 	  <= X"00";
					data_sig   <= '1';
					OUTPUT_TEXT_en <= dataToHost & for_lcd_en (0 to 119);
					--for_lcd 			<= dataToHost & for_lcd_en (0 to 119);
					for_lcd_en 		<= (others => '0');
					--rd_en_lcd 		<= '1';
				ELSE data_sig <= '0';
				--rd_en_lcd 		<= '0';
				END IF;
				
			ELSIF (cnt = "11") THEN
				cnt 		<= "00";
				rd_en  <= '0';
				data_sig <= '0';
        ELSE
				data_sig <= '0';
            rd_en  <= '0';
        END IF;	
		  
		  
		  IF (emptyOBuff_kb = '0') THEN
            rd_en_kb  <= '1';
				rec_cnt   <= "01";
			ELSIF (rec_cnt = "01") THEN
				rd_en_kb  <= '0';
				rec_cnt   <= "10";
			ELSIF (rec_cnt = "10") THEN
				rd_en_kb  <= '1';
				rec_cnt   <= "11";
			ELSIF (rec_cnt = "11") THEN
				rec_cnt <= "00";
				dataFromHost <= DataFromOBuff_kb;
				rd_en_kb  <= '0';
				wr_en <= '1';
        ELSE
            rd_en_kb  <= '0';
				wr_en <= '0';
        END IF;	  	 
		  
		  IF (btn = '1') THEN
				dataFromHost <= X"EE";
				wr_en	<= '1';
	     ELSIF (btn_1 = '1') THEN
				dataFromHost <= X"ED";
				wr_en	<= '1';
				btn_on <= '1';
		  ELSIF ((btn_on = '1') and (dataToHost = X"FA")) THEN
				dataFromHost <= X"02";
				wr_en	<= '1';
				btn_on <= '0';
			ELSE --dataFromHost <= X"00";
				  wr_en	<= '0';
			END IF;	
		  
    END IF; 
    END PROCESS;
    
	aes_encr: PROCESS (clk,rst)
	 begin
	 IF (rst = '1') THEN
			--wr_en_kb	<= '0';
			--cnt_buf        <= (others => '0');
			--for_lcd <= (others => '0');
			cnt_input 		<= "00";
			DATA_WRITE 		<= '0';
			ENCR_DECR  		<= '0';
			data_exit_lcd  <= '0';
			aval_aes 		<= '0';
			INPUT_TEXT 		<= (others => '0');
	 ELSIF RISING_EDGE(clk) THEN
			IF (cnt_input = "00") then
				DATA_WRITE 		<= '1';
				INPUT_TEXT 		<= X"000102030405060708090a0b0c0d0e0f";
				cnt_input 		<= "01";
				--data_exit_lcd  <= '0';
				aval_aes 		<= '0';
				rd_en_lcd 	<= '0';
			ELSIF ((cnt_input = "01") and (aval_aes = '1') and (data_sig = '1')) then
				INPUT_TEXT		<= OUTPUT_TEXT_en;--DataFromOBuff_h & zero; -- (others => '0'));
				DATA_WRITE 		<= '1';
				ENCR_DECR  		<= '0';
				cnt_input  		<= "10";
				--buff_count    <= buff_count + '1';
				--data_exit_lcd 	<= '0';
				rd_en_lcd 	<= '0';
				aval_aes 		<= '0';
				wr_en_kb 	   <= '0';
			ELSIF ((cnt_input = "10") and (aval_aes = '1')) then
				cnt_input  		<= "01";
				data_exit_lcd  <= '1';
				for_lcd 			<= OUTPUT_TEXT (0 to 7) & for_lcd(0 to 119);
			   rd_en_lcd 		<= '1';
				wr_en_kb 	   <= '1';
				DataToIBuff_kb <= OUTPUT_TEXT (0 to 7);
			ELSE DATA_WRITE 	<= '0';
				  --data_exit_lcd<= '0';
				  rd_en_lcd 	<= '0';
				  wr_en_kb 	   <= '0';
			END IF;
			
			if (AVAILABLE = '1') then
				aval_aes <= '1';
			end if;
			--aval_aes <= '1' when (AVAILABLE = '1') else '0';
			--data_sig <= '1' when (cnt = "11") else '0';
			--if (cnt_buf = X"10") then
				--data_sig <= '1';
			--else data_sig <= '0';
			--end if;
			
			--IF (data_exit_lcd = '1') THEN
				--IF (cnt_buf = X"10") THEN
				--	data_exit_lcd  <= '0';
				--	wr_en_kb 	   <= '0';
				--	cnt_buf			<= X"00";
				--ELSE wr_en_kb 	   <= '1';
					--DataToIBuff_kb <= OUTPUT_TEXT_en (120 to 127);
				--	OUTPUT_TEXT_en <= OUTPUT_TEXT_en (120 to 127) & OUTPUT_TEXT_en (0 to 119);
				--	cnt_buf 			<= cnt_buf + '1';
					
					--case cnt_buf is 
							--when X"00" => DataToIBuff_kb <= OUTPUT_TEXT_en (
				--END IF;
			--END IF;
			
		END IF;
		END PROCESS;
	 
    -- link the data coming out from KbdCore to leds
    LED <= DataFromOBuff_kb;
	 

END Behavioral;

