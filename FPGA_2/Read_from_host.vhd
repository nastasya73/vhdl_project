library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;



entity Read_from_host IS
Port ( 
    clk             : IN  STD_LOGIC;
    rst             : IN  STD_LOGIC;
    Rx_en           : IN  STD_LOGIC;
    kbd_dataf       : IN  STD_LOGIC;
    kbd_clkf        : IN  STD_LOGIC;
    busy            : OUT STD_LOGIC;
    T_Data          : OUT STD_LOGIC;	--WHEN T=0, IO = OUT; WHEN T=1, IO = IN;
    T_Clk           : OUT STD_LOGIC;	--WHEN T=0, IO = OUT; WHEN T=1, IO = IN;
    KbdData         : OUT STD_LOGIC;
    KbdClk          : OUT STD_LOGIC;
	 Data_exit       : OUT STD_LOGIC;
	 data_from_host  : OUT STD_LOGIC_VECTOR (7 downto 0) 
	
);
  END Read_from_host;



ARCHITECTURE Behavioral OF Read_from_host IS
Component Sin_clock is
	port ( clk			: in std_logic;
			 rst			: in std_logic;
			 freq			: in std_logic_vector (2 downto 0);
			 enable_clk	: in std_logic;
			 sin_clk		: out std_logic);
end Component;

TYPE state_type IS (S0, S1, S2, S22, S222, S3, S33, S4, S5, S55, S555, S6, S7, S8, S88, S9, S10, S11);
SIGNAL state, next_state: state_type ;

SIGNAL cnt          : std_logic_vector(12 DOWNTO 0):=(OTHERS=>'0');
SIGNAL startCount   : std_logic:='0';
SIGNAL ENDCount     : std_logic:='0';

SIGNAL shIFtcnt     : std_logic_vector(3 DOWNTO 0):=(OTHERS=>'0');
SIGNAL dataReg      : std_logic_vector(10 DOWNTO 0):=(OTHERS=> '0');

SIGNAL dataValid    : std_logic:='0';

SIGNAL INt_busy     : std_logic;
SIGNAL INt_T_Clk    : std_logic;
SIGNAL INt_T_Data   : std_logic;
SIGNAL INt_KbdData  : std_logic;
SIGNAL INt_KbdClk   : std_logic;

SIGNAL sin_clk       : std_logic;
SIGNAL start_sin_clk : std_logic;
SIGNAL freq		 		: std_logic_vector (2 downto 0) := (others => '0');

BEGIN
c1: Sin_clock
	 PORT MAP( clk 			=> CLK,
				  rst 			=> rst,
				  freq			=> freq,
				  enable_clk   => start_sin_clk,
				  sin_clk      => sin_clk);
				  
Sequential: PROCESS (clk,rst)
BEGIN
    IF (rst = '1') THEN
        state <= S0;
    ELSIF (clk='1' and clk'Event) THEN
        state <= next_state;
    END IF;
END PROCESS;

PROCESS (clk,rst)                                      -- отсчитываем начальные 100 мкс (для начала передачи на клаву)     
BEGIN
    IF (rst = '1') THEN
        cnt      <= (OTHERS=>'0');
        ENDCount <= '0';
    ELSIF (clk = '1' and clk'Event) THEN              
       -- ENDCount <= '0';
       -- cnt      <= (OTHERS=>'0');                
        IF(startCount = '1') THEN
            cnt      <= cnt+'1';
            IF (cnt = X"08CA") THEN          -- 100 us
                cnt      <= (OTHERS=>'0');
                ENDCount <= '1';
				ELSE ENDCount <= '0';
            END IF;
			--ELSE ENDCount <= '0';
				 --cnt      <= (OTHERS=>'0'); 
        END IF;
    END IF;
END PROCESS;

CntrlFSM :  PROCESS (state, kbd_clkf, kbd_dataf,sin_clk,Rx_en,ENDCount)
BEGIN
    CASE state IS
        WHEN S0 =>
            INt_busy       <= '0';
            INt_T_Clk      <= '1';
            INt_T_Data     <= '1';
            INt_KbdData    <= '1';
            INt_KbdClk     <= '0';
								
				dataValid  		<= '0';
				
            IF (Rx_en = '1') THEN
                next_state <= S1;
            ELSIF (Rx_en = '0') THEN
                next_state <= S0;
            END IF;
            
				
        WHEN S1 =>							
            INt_busy       <= '0';
            INt_T_Clk      <= '1';
            INt_T_Data     <= '1';
            INt_KbdData    <= '1';
            INt_KbdClk     <= '0';
				--ENDCount			<= '0';
				
            IF ((kbd_clkf = '0')) THEN  
                next_state <= S2;
					 startCount <= '1';
            ELSE
                next_state <= S0;
            END IF;
				
				
			WHEN S2 =>							
            INt_busy       <= '0';
            INt_T_Clk      <= '1';
            INt_T_Data     <= '1';
            INt_KbdData    <= '1';
            INt_KbdClk     <= '0';
				
				IF (ENDCount = '1') THEN
                startCount <= '0';
                next_state <= S22;
					 --ENDCount	<= '0';
            ELSE
                startCount <= '1';
                next_state <= S2;
            END IF;
				
			WHEN S22 =>							
            INt_busy       <= '0';
            INt_T_Clk      <= '1';
            INt_T_Data     <= '1';
            INt_KbdData    <= '1';
            INt_KbdClk     <= '0';
				--ENDCount			<= '0';
				
            IF ((kbd_clkf = '0')) THEN  
                next_state <= S222;
            ELSE
                next_state <= S0;
            END IF;
				

        WHEN S222 =>
            INt_busy    <= '1';
            INt_T_Clk   <= '1';
            INt_T_Data  <= '1';
            INt_KbdData <= '1';
            INt_KbdClk  <= '1';
				
            IF (kbd_clkf = '1') THEN
                next_state <= S3;
            ELSE
                next_state <= S222;
            END IF;


        WHEN S3 =>
            INt_busy       <= '1';
            INt_T_Clk      <= '1';
            INt_T_Data     <= '1';
            INt_KbdClk     <= '1';
            INt_KbdData    <= '1';
				
				start_sin_clk 	<= '1';
				next_state 		<= S33;
				
				
		 WHEN S33 =>
            INt_busy       <= '1';
            INt_T_Clk      <= '1';
            INt_T_Data     <= '1';
            INt_KbdClk     <= '1';
            INt_KbdData    <= '1';
								
				start_sin_clk 	<= '0';
				next_state 		<= S4;


        WHEN S4 =>
            INt_busy       <= '1';
            INt_T_Clk      <= '0';
            INt_T_Data     <= '1';
            INt_KbdClk     <= sin_clk;
            INt_KbdData    <= '1';
				
				
				start_sin_clk 	<= '0';
            next_state <= S555;


        WHEN S5 =>
            INt_busy       <= '1';
            INt_T_Clk      <= '0';
            INt_T_Data     <= '1';
            INt_KbdClk     <= sin_clk;
            INt_KbdData    <= '1';
				
            IF ((sin_clk = '1')) THEN    
                next_state <= S55;
            ELSE
                next_state <= S5;
            END IF;
				
				
			WHEN S55 =>
            INt_busy       <= '1';
            INt_T_Clk      <= '0';
            INt_T_Data     <= '1';
            INt_KbdClk     <= sin_clk;
            INt_KbdData    <= '1';
				
            IF ((sin_clk = '0')) THEN    
                next_state <= S555;
            ELSE
                next_state <= S55;
            END IF;
				
				
			WHEN S555 =>
            INt_busy       <= '1';
            INt_T_Clk      <= '0';
            INt_T_Data     <= '1';
            INt_KbdClk     <= sin_clk;
            INt_KbdData    <= '1';
				
            IF ((sin_clk = '1')) THEN    
                next_state <= S6;
            ELSE
                next_state <= S555;
            END IF;


        WHEN S6 =>
            INt_busy       <= '1';
            INt_T_Clk      <= '0';
            INt_T_Data     <= '1';
            INt_KbdClk     <= sin_clk;
            INt_KbdData    <= '1';
				
				dataReg			<= kbd_dataf & dataReg(10 downto 1);
				shIFtcnt 		<= shIFtcnt + '1';
            next_state 		<= S7;

				
			WHEN S7 =>
            INt_busy       <= '1';
            INt_T_Clk      <= '0';
            INt_T_Data     <= '1';
            INt_KbdClk     <= sin_clk;
            INt_KbdData    <= '1';
				
				IF (shIFtcnt = X"A") THEN 
                 next_state <= S8;
					  shIFtcnt <= X"0";
            ELSE
                 next_state <= S55;
            END IF;
				
			 WHEN S8 =>
            INt_busy       <= '1';
            INt_T_Clk      <= '0';
            INt_T_Data     <= '0';
            INt_KbdClk     <= sin_clk;
            INt_KbdData    <= '0';
				
            IF ((sin_clk = '0')) THEN    
                next_state <= S88;
            ELSE
                next_state <= S8;
            END IF;
				
			WHEN S88 =>
            INt_busy       <= '1';
            INt_T_Clk      <= '0';
            INt_T_Data     <= '0';
            INt_KbdClk     <= sin_clk;
            INt_KbdData    <= '0';
				
            IF ((sin_clk = '1')) THEN    
                next_state <= S9;
            ELSE
                next_state <= S88;
            END IF;


			 WHEN S9 =>
            INt_busy       <= '1';
            INt_T_Clk      <= '0';
            INt_T_Data     <= '0';
            INt_KbdClk     <= sin_clk;
            INt_KbdData    <= '1';
				
            next_state 		<= S10;
				
				
			 WHEN S10 =>
            INt_busy       <= '1';
            INt_T_Clk      <= '0';
            INt_T_Data     <= '1';
            INt_KbdClk     <= sin_clk;
            INt_KbdData    <= '1';
				
            next_state 		<= S11;
				
				
			 WHEN S11 =>
            INt_busy       <= '1';
            INt_T_Clk      <= '0';
            INt_T_Data     <= '1';
            INt_KbdClk     <= sin_clk;
            INt_KbdData    <= '1';
				
				IF (kbd_dataf = '1') THEN
					next_state <=  S0;
					dataValid  <= '1';
				ElSE start_sin_clk <= '1';
						next_state <=  S11;
				END IF;
		
    END case;
END PROCESS;


OUTput: PROCESS (clk,rst)
BEGIN
    IF (rst = '1') THEN
        busy    <= '0';
        T_Clk   <= '1';
        T_Data  <= '1';
        KbdData <= '0';
        KbdClk  <= '0';
		  Data_exit <= '0';
    ELSIF (clk='1' and clk'Event) THEN
        busy    <= INt_busy;
        T_Clk   <= INt_T_Clk;
        T_Data  <= INt_T_Data;
        KbdData <= INt_KbdData;
        KbdClk  <= INt_KbdClk;
		  IF (dataValid = '1') then
				data_from_host <= dataReg (8 downto 1);
				Data_exit <= '1';
		  ELSE Data_exit <= '0';
		  END IF;
    END IF;
END PROCESS;


END Behavioral;


