library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;



ENTITY CTRL_2 IS
PORT ( 
    clk             : IN    STD_LOGIC;
    rst             : IN    STD_LOGIC;
    busy_read       : IN    STD_LOGIC;
    busy_send       : IN    STD_LOGIC;
	 
    validData       : IN    STD_LOGIC; 
	 Data_From_Host  : IN    STD_LOGIC_VECTOR (7 DOWNTO 0);
	 
    dataINIBuff     : IN    STD_LOGIC;                      -- = 0, если в буфере естьданные для хоста
    Data_From_Buf   : IN    STD_LOGIC_VECTOR (7 DOWNTO 0);
	
	 
    Tx_en           : OUT   STD_LOGIC;
    Rx_en           : OUT   STD_LOGIC;
	 
    rd_en           : OUT   STD_LOGIC;
    Data_To_Host    : OUT   STD_LOGIC_VECTOR (7 DOWNTO 0);
	 
	 wr_en           : OUT   STD_LOGIC;
    Data_To_OBuff   : OUT   STD_LOGIC_VECTOR (7 DOWNTO 0)
	 
	
);
END CTRL_2;

ARCHITECTURE Behavioral OF CTRL_2 IS

SIGNAL ValidDataINIbuff : std_logic;
SIGNAL GetDataIBuff     : std_logic;
SIGNAL StartTransmit    : std_logic;
SIGNAL on_power    : std_logic := '0';
BEGIN

PROCESS(Rst,Clk)
BEGIN
    IF(rst = '1') THEN
		 
        rd_en            <= '0';
        wr_en            <= '0';
        Tx_en            <= '0';
        Rx_en            <= '0';
		  on_power			 <= '0';
        ValidDataINIbuff <= '0';
        startTransmit    <= '0';
        GetDataIBuff     <= '0';
        Data_To_Host     <= (OTHERS => '0');
        Data_To_OBuff    <= (OTHERS => '0');
    ELSIF(clk = '1') and (clk'event) THEN
        IF(busy_read = '0') and ( busy_send = '0') THEN
            IF (startTransmit = '1') THEN
                Tx_en            <= '1';
                Rx_en            <= '0';
                rd_en            <= '0';
                wr_en            <= '0';
                ValidDataINIbuff <= '0';
                GetDataIBuff     <= '0';
                startTransmit    <= '1';
            ELSIF (GetDataIBuff = '1') THEN
					 Data_To_Host     <= Data_From_Buf;
                Tx_en            <= '0';
                Rx_en            <= '0';
                rd_en            <= '0';
                wr_en            <= '0';
                ValidDataINIbuff <= '0';
                GetDataIBuff     <= '0';
                startTransmit    <= '1';
            ELSIF (ValidDataINIbuff = '1') THEN
                Tx_en            <= '0';
                Rx_en            <= '0';
                rd_en            <= '0';
                wr_en            <= '0';
                ValidDataINIbuff <= '0';
                GetDataIBuff     <= '1';
                startTransmit    <= '0';
            ELSIF(dataINIbuff = '0') THEN
                rd_en            <= '1';
                wr_en            <= '0';
                Tx_en            <= '0';
                Rx_en            <= '0';
                ValidDataINIbuff <= '1';
                GetDataIBuff     <= '0';
                startTransmit    <= '0';
            ELSE
                rd_en            <= '0';
                wr_en            <= '0';
                Tx_en            <= '0';
                Rx_en            <= '1';
					 
                startTransmit    <= '0';
                GetDataIBuff     <= '0';
                ValidDataINIbuff <= '0';
            END IF;
        ELSIF(busy_send = '1') THEN
            wr_en            <= '0';
            rd_en            <= '0';
            ValidDataINIbuff <= '0';
            startTransmit    <= '0';
            Tx_en            <= '0';
            Rx_en            <= '0';
				
				startTransmit    <= '0';
        ELSIF(busy_read = '1') THEN
            Tx_en 			  <= '0';
            Rx_en 			  <= '1';
            rd_en 			  <= '0';
            wr_en 			  <= '0';
				
            IF (validData = '1') THEN
                Data_To_OBuff <= Data_From_Host;
                wr_en         <= '1';
            END IF;
        END IF;
    END IF;
END PROCESS;


END Behavioral;


