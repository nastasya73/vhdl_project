library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;


entity CORE is
PORT ( 
    clk                 : IN    STD_LOGIC;
    rst                 : IN    STD_LOGIC;
	 emptyOBuff				: OUT    STD_LOGIC;-- есть ли данные от хоста
	 DataFromOBuff			: OUT    STD_LOGIC_VECTOR(7 downto 0); --данные ОТ хоста
	 rdOBuff             : IN    STD_LOGIC; --считываем данные от хоста из буфера
    wrIBuff             : IN    STD_LOGIC; -- записываем данные для хоста
    DataToIBuff     		: IN    STD_LOGIC_VECTOR(7 downto 0); -- данные ДЛЯ хоста
	 
	 
	 --dataFromKB				: IN    STD_LOGIC;
	-- ClkFromKB				: IN    STD_LOGIC;
	 
    KBData              : INOUT STD_LOGIC;
    KBClk               : INOUT STD_LOGIC;
	 
	-- dataToKb_out		   : OUT STD_LOGIC;
	-- ClkToKb_out		   : OUT STD_LOGIC;
	 
    statusReg           : OUT   STD_LOGIC_VECTOR(7 downto 0)
    --data_Host           : OUT   STD_LOGIC_VECTOR(7 downto 0)
);
end CORE;


architecture Behavioral of CORE is

Component SendtoHost IS
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
  END component;

Component  Read_from_host 
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
END Component;


Component CTRL_2 IS
PORT ( 
    clk             : IN    STD_LOGIC;
    rst             : IN    STD_LOGIC;
    busy_read       : IN    STD_LOGIC;
    busy_send       : IN    STD_LOGIC;
	 
    validData       : IN    STD_LOGIC; 
	 Data_From_Host  : IN    STD_LOGIC_VECTOR (7 DOWNTO 0);
	 
    dataINIBuff     : IN    STD_LOGIC;                      -- = 0, если в буфере естьданные для хоста
    Data_From_Buf   : IN    STD_LOGIC_VECTOR (7 DOWNTO 0);
	 
	 T_Data_r        : IN STD_LOGIC;	
    T_Clk_r         : IN STD_LOGIC;	
    KbdData_r       : IN STD_LOGIC;
    KbdClk_r        : IN STD_LOGIC;
	 
	 T_Data_s        : IN STD_LOGIC;	
    T_Clk_s         : IN STD_LOGIC;	
    KbdData_s       : IN STD_LOGIC;
    KbdClk_s        : IN STD_LOGIC;
	 
    Tx_en           : OUT   STD_LOGIC;
    Rx_en           : OUT   STD_LOGIC;
	 
    rd_en           : OUT   STD_LOGIC;
    Data_To_Host    : OUT   STD_LOGIC_VECTOR (7 DOWNTO 0);
	 
	 wr_en           : OUT   STD_LOGIC;
    Data_To_OBuff   : OUT   STD_LOGIC_VECTOR (7 DOWNTO 0);
	 
	 T_Data          : OUT STD_LOGIC;	--WHEN T=0, IO = OUT; WHEN T=1, IO = IN;
    T_Clk           : OUT STD_LOGIC;	--WHEN T=0, IO = OUT; WHEN T=1, IO = IN;
    KbdData         : OUT STD_LOGIC;
    KbdClk          : OUT STD_LOGIC
);
END component;

Component KbdFilter
PORT(
    clk                 : IN  STD_LOGIC;
    rst                 : IN  STD_LOGIC;
    kbdClk              : IN  STD_LOGIC;
    kbdData             : IN  STD_LOGIC;
    kbdClkF             : OUT STD_LOGIC;
    kbdDataF            : OUT STD_LOGIC
);
end component;

COMPONENT IOBuffer
PORT (
    clk                 : IN    STD_LOGIC;
    rst                 : IN    STD_LOGIC;
    din                 : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en               : IN    STD_LOGIC;
    rd_en               : IN    STD_LOGIC;
    dOUT                : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
    full                : OUT   STD_LOGIC;
    empty               : OUT   STD_LOGIC
);
END COMPONENT;


COMPONENT IOBUF
PORT ( 
    I                  : IN    std_logic; 
    IO                 : INOUT std_logic; 
    O                  : OUT   std_logic; 
    T                  : IN    std_logic
);
END COMPONENT;
        
SIGNAL dataFromKB      : STD_LOGIC;
SIGNAL dataToKB        : STD_LOGIC;
SIGNAL ClkToKb         : STD_LOGIC;
SIGNAL ClkFromKb       : STD_LOGIC;
SIGNAL TData           : STD_LOGIC;  --when T=0, IO = OUT; when T=1, IO = IN;
SIGNAL TClk            : STD_LOGIC;  --when T=0, IO = OUT; when T=1, IO = IN;
SIGNAL ClkToKb_s       : STD_LOGIC;
SIGNAL dataToKb_s      : STD_LOGIC;
SIGNAL TData_s         : STD_LOGIC;  --when T=0, IO = OUT; when T=1, IO = IN;
SIGNAL TClk_s          : STD_LOGIC;
SIGNAL ClkToKb_r       : STD_LOGIC;
SIGNAL dataToKb_r      : STD_LOGIC;
SIGNAL TData_r         : STD_LOGIC;  --when T=0, IO = OUT; when T=1, IO = IN;
SIGNAL TClk_r          : STD_LOGIC;

SIGNAL Tx_en           : STD_LOGIC;
SIGNAL Rx_en           : STD_LOGIC;
SIGNAL busyRx          : STD_LOGIC;
SIGNAL busyTx          : STD_LOGIC;

--SIGNAL error_parity	  : STD_LOGIC;
--SIGNAL scan_en_out  	  : STD_LOGIC;
--SIGNAL buff_clear  	  : STD_LOGIC;

SIGNAL read_data_exit  : STD_LOGIC;
SIGNAL read_data       : STD_LOGIC_VECTOR(7 downto 0);
SIGNAL Data_for_send	  : STD_LOGIC_VECTOR(7 downto 0);

SIGNAL kbdDataF	     : STD_LOGIC;
SIGNAL kbdClkF         : STD_LOGIC;

SIGNAL emptyIBuff      : STD_LOGIC;
--SIGNAL emptyOBuff      : STD_LOGIC;
SIGNAL wrOBuff         : STD_LOGIC;
SIGNAL rdIBuff         : STD_LOGIC;
--SIGNAL wrIBuff         : STD_LOGIC;
--SIGNAL rdOBuff         : STD_LOGIC;
--SIGNAL DataFromOBuff   : STD_LOGIC_VECTOR(7 downto 0);
SIGNAL DataFromIBuff   : STD_LOGIC_VECTOR(7 downto 0);
SIGNAL DataToOBuff     : STD_LOGIC_VECTOR(7 downto 0);
--SIGNAL DataToIBuff     : STD_LOGIC_VECTOR(7 downto 0);


BEGIN
Send: SendtoHost 
PORT MAP(
    clk             => clk,
    rst             => rst,
    Tx_en           => Tx_en,
    kbd_dataf       => kbdDataF,
    kbd_clkf        => kbdClkF,
    Data            => Data_for_send,
    busy            => busyTx, --out
    T_Data          => TData_s,
    T_Clk           => TClk_s,
    KbdData         => dataToKb_s,
    KbdClk          => ClkToKb_s
);

Read_host: Read_from_host 
PORT MAP(
    clk             => clk,
    rst             => rst,
    Rx_en           => Rx_en, 
    kbd_dataf       => kbdDataF,
    kbd_clkf        => kbdClkF,
    busy            => busyRx,   --out
    T_Data          => TData_r,
    T_Clk           => TClk_r,
    KbdData         => dataToKb_r,
    KbdClk          => ClkToKb_r,
	 Data_exit		  => read_data_exit,
	 data_from_host  => read_data
);


ProcData:CTRL_2 
PORT MAP(
    clk             => clk,
    rst             => rst,
    busy_read       => busyRx,
    busy_send       => busyTx,
	 
    validData       => read_data_exit,
	 Data_From_Host  => read_data,
	 
    dataInIBuff     => emptyIBuff,  
    Data_From_Buf   => DataFromIBuff,
	 
	 T_Data_s        => TData_s,
    T_Clk_s         => TClk_s,
    KbdData_s       => dataToKb_s,
    KbdClk_s		  => ClkToKb_s,
	 
	 T_Data_r        => TData_r,
    T_Clk_r         => TClk_r,
    KbdData_r       => dataToKb_r,
    KbdClk_r		  => ClkToKb_r,
	 
	 Rx_en           => Rx_en,
    Tx_en           => Tx_en,
	 
    rd_en           => rdIBuff,
	 Data_To_Host    => Data_for_send,
	 	 
    wr_en           => wrOBuff,
    Data_To_OBuff   => DataToOBuff,
	 
	 T_Data          => TData,
    T_Clk           => TClk,
    KbdData         => dataToKb,
    KbdClk          => ClkToKb
);


Filter:KbdFilter 
PORT MAP(
    clk             => clk,
    rst             => rst,
    kbdClk          => clkFromKb,
    kbdData         => dataFromKb,
    kbdClkF         => kbdClkF,
    kbdDataF        => kbdDataF
);


OBuffer : IOBuffer 
PORT MAP (
    clk             => clk,
    rst             => rst,
    din             => DataToOBuff,
    wr_en           => wrOBuff,
    rd_en           => rdOBuff,
    dOUT            => DataFromOBuff,--dataToHost_s,
    full            => statusReg(0),
    empty           => emptyOBuff --statusReg_s(7)
);

IBuffer : IOBuffer 
PORT MAP (
    clk             => clk,
    rst             => rst,
    din             => DataToIBuff,--dataFromHost_s,
    wr_en           => wrIBuff,--wrIBuffer_s,
    rd_en           => rdIBuff,
    dOUT            => DataFromIBuff,
    full            => statusReg(1),
    empty           => emptyIBuff
);


IOData: IOBUF
PORT MAP( 
    I               => dataToKb,
    IO              => KBData, 
    O               => dataFromKB,
    T               => TData
);

IOClk: IOBUF
PORT MAP( 
    I               => ClkToKb,
    IO              => KBClk,
    O               => ClkFromKb,
    T               => TClk
);

--dataToKB_out <= dataToKB when (TData = '0') else '1';
--clkToKB_out  <= clkToKB when (TClk = '0') else '1';

--dataFromKB_out <= dataFromKB;
--dataToKB_out <= dataToKB;

--statusReg (6) <= emptyOBuff;

end Behavioral;


