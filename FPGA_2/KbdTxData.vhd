library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;



entity KbdTxData IS
Port ( 
    clk             : IN  STD_LOGIC;
    rst             : IN  STD_LOGIC;
    Tx_en           : IN  STD_LOGIC;
    kbd_dataf       : IN  STD_LOGIC;
    kbd_clkf        : IN  STD_LOGIC;
    Data            : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
    busy            : OUT STD_LOGIC;
    T_Data          : OUT STD_LOGIC;	--WHEN T=0, IO = OUT; WHEN T=1, IO = IN;
    T_Clk           : OUT STD_LOGIC;	--WHEN T=0, IO = OUT; WHEN T=1, IO = IN;
    KbdData         : OUT STD_LOGIC;
    KbdClk          : OUT STD_LOGIC
);
  END KbdTxData;



ARCHITECTURE Behavioral OF KbdTxData IS

Component Sin_clock is
	port ( clk			: in std_logic;
			 rst			: in std_logic;
			 freq			: in std_logic_vector (2 downto 0);
			 enable_clk	: in std_logic;
			 sin_clk		: out std_logic);
end Component;

TYPE state_type IS (S0, S1, S2, S222, S22, S3, S33, S4, S5, S6);
SIGNAL state, next_state: state_type ;

SIGNAL data_to_host : STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL startCount   : std_logic:='0';
SIGNAL ENDCount     : std_logic:='0';
SIGNAL cnt          : std_logic_vector(11 DOWNTO 0):=(OTHERS=>'0');
SIGNAL cnt_end      : std_logic_vector(11 DOWNTO 0):= X"3E8";

SIGNAL shIFt        : std_logic:='0';
SIGNAL ENDshIFt     : std_logic:='0';
SIGNAL shIFtcnt     : std_logic_vector(3 DOWNTO 0):=(OTHERS=>'0');
SIGNAL dataReg      : std_logic_vector(10 DOWNTO 0):=(OTHERS=>'0');

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

-- Counter
Counter: PROCESS (clk,rst)
BEGIN
    IF (rst = '1') THEN
        cnt      <= (OTHERS=>'0');
        ENDCount <= '0';
    ELSIF (clk = '1' and clk'Event) THEN
	 
		  IF (state = S2) THEN
				cnt_end <= X"3E8";
		  ELSIF (state = S4) THEN
				cnt_end <= X"4E2";
		  END IF;
		  
        IF(startCount = '1') THEN
            cnt      <= cnt+'1';
            IF (cnt = cnt_end) THEN          
                cnt      <= (OTHERS=>'0');
                ENDCount <= '1';
            END IF;
			ELSE cnt  <= (OTHERS=>'0');
					ENDCount <= '0';   
        END IF;
    END IF;
END PROCESS;


Dataproc:PROCESS(clk,rst)
BEGIN
    IF (rst = '1') THEN
        dataReg  <= "11111111111";
        shIFtcnt <= "0000";
        ENDshIFt <= '0';
    ELSIF (clk = '1' and clk'Event) THEN
        IF (state = S1) THEN
            dataReg(10) <= '1';
				dataReg(9)  <= not(data_to_host(7) xor data_to_host(6) xor data_to_host(5) xor data_to_host(4) xor data_to_host(3) xor data_to_host(2) xor data_to_host(1) xor data_to_host(0));
				dataReg(8 downto 1) <= data_to_host; 
				dataReg(0) <= '0';
            shIFtcnt <= "0000";
            ENDshIFt <= '0';
        ELSIF (shIFtcnt = "1010") THEN
            shIFtcnt <= "0000";
            ENDshIFt <= '1';
        ELSIF (shIFt = '1') THEN
            ENDshIFt <= '0';
            shIFtcnt <= shIFtcnt + '1';
            dataReg  <= dataReg(0) & dataReg(10 DOWNTO 1);
        END IF;
		  
		  IF (Tx_en = '1') then data_to_host <= data;
		  END IF;
    END IF;
END PROCESS;




CntrlFSM :  PROCESS (state, ENDCount, Tx_en, ENDshIFt, sin_clk) --kbd_clkf, kbd_dataf,
BEGIN
    CASE state IS
        WHEN S0 =>
            INt_busy       <= '0';
            INt_T_Clk      <= '1';
            INt_T_Data     <= '1';
            
				INt_KbdClk     <= '1';
            INt_KbdData    <= '1';
				
				shIFt          <= '0';
            startCount     <= '0';
				IF (Tx_en = '1') THEN
                next_state <= S1;
            ELSIF (Tx_en='0') THEN
                next_state <= S0;
            END IF;
				
		 WHEN S1 =>
            INt_busy       <= '0';
            INt_T_Clk      <= '1';
            INt_T_Data     <= '1';
            
				INt_KbdClk     <= '1';
            INt_KbdData    <= '1';
				
				shIFt          <= '0';
            startCount     <= '0';
				IF ((kbd_dataf = '1') and (kbd_clkf = '1')) THEN
                next_state <= S2;
            ELSE
                next_state <= S0;
            END IF;

        WHEN S2 => 					--  старт синхрочасам на генерацию синхроимпульсов (t = 5-25 мкс)
            INt_busy    <= '1';
            INt_T_Clk   <= '0';
            INt_T_Data  <= '0';
				
				INt_KbdClk  <= '1';
				INt_KbdData <= dataReg(0);
            
            shIFt       <= '0';
				startCount  <= '1';
				
            IF (ENDCount = '1') THEN               -- возможно стоит сделать счётчик по меньше 
                startCount <= '0';
                next_state <= S222;
					 start_sin_clk <= '1';
            ELSE
                startCount <= '1';
                next_state <= S2;
            END IF;
		
		WHEN S222 => 					--  старт синхрочасам на генерацию синхроимпульсов (t = 5-25 мкс)
            INt_busy    <= '1';
            INt_T_Clk   <= '0';
            INt_T_Data  <= '0';
				
				INt_KbdClk  <= '0';
				INt_KbdData <= dataReg(0);
            
            shIFt       <= '0';
				startCount  <= '0';
				
				start_sin_clk <= '0';
				next_state <= S22;
				
		 WHEN S22 => 					--  старт синхрочасам на генерацию синхроимпульсов (t = 5-25 мкс)
            INt_busy    <= '1';
            INt_T_Clk   <= '0';
            INt_T_Data  <= '0';
				
				INt_KbdClk  <= sin_clk;
				INt_KbdData <= dataReg(0);
            
            shIFt       <= '0';
				startCount  <= '0';
				
				start_sin_clk <= '0';
				next_state <= S33;


        WHEN S3 => 							-- ждём положительный фронт clk
            INt_busy       <= '1';
            INt_T_Clk      <= '0';
            INt_T_Data     <= '0';
            
            INt_KbdClk     <= sin_clk;
            INt_KbdData    <= dataReg(0);
				
				shIFt          <= '0';
            startCount 		<= '0';
				
				--start_sin_clk  <= '0';
            IF ((sin_clk = '0')) THEN
                next_state <= S33;
            ELSE
                next_state <= S3;
            END IF;
				
		  WHEN S33 => 							-- ждём положительный фронт clk
            INt_busy       <= '1';
            INt_T_Clk      <= '0';
            INt_T_Data     <= '0';
            
            INt_KbdClk     <= sin_clk;
            INt_KbdData    <= dataReg(0);
				
				shIFt          <= '0';
            startCount 		<= '0';
				
				--start_sin_clk  <= '0';
            IF (sin_clk = '1') THEN
                next_state <= S4;
            ELSE
                next_state <= S33;
            END IF;


        WHEN S4 => 								-- не меняем состояние линии data не менее 5 мкс
            INt_busy       <= '1';
            INt_T_Clk      <= '0';
            INt_T_Data     <= '0';
				
            INt_KbdClk     <= sin_clk;
            INt_KbdData    <= dataReg(0);
				
				shIFt          <= '0';
            startCount 		<= '1';
            IF (ENDCount = '1') THEN
                startCount <= '0';
                next_state <= S5;
            ELSE
                startCount <= '1';
                next_state <= S4;
            END IF;


        WHEN S5 =>
            INt_busy       <= '1';
            INt_T_Clk      <= '0';
            INt_T_Data     <= '0';
				
            INt_KbdClk     <= sin_clk;
            INt_KbdData    <= dataReg(0);
				
            startCount 		<= '0';
				IF (ENDshIFt = '1') THEN
                 shIFt      <= '0';
                 next_state <= S6;
            ELSE
                 shIFt      <= '1';
                 next_state <= S3;
            END IF;
				
		 WHEN S6 =>
            INt_busy       <= '1';
            INt_T_Clk      <= '0';
            INt_T_Data     <= '0';
				
            INt_KbdClk     <= '1';
            INt_KbdData    <= '1';
				
				shIFt          <= '0';
            startCount 		<= '0';
				
            next_state 		<= S0;
				
    END case;
END PROCESS;


OUTput: PROCESS (clk,rst)
BEGIN
    IF (rst = '1') THEN
        busy    <= '0';
        T_Clk   <= '1';
        T_Data  <= '1';
        KbdData <= '1';
        KbdClk  <= '1';
    ELSIF (clk='1' and clk'Event) THEN
        busy    <= INt_busy;
        T_Clk   <= INt_T_Clk;
        T_Data  <= INt_T_Data;
        KbdData <= INt_KbdData;
        KbdClk  <= INt_KbdClk;
    END IF;
END PROCESS;


END Behavioral;



