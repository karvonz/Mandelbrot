
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY UNISIM;
USE UNISIM.VCOMPONENTS.ALL;

ENTITY minit_gtx_tile IS
generic
(
    -- Simulation attributes
    TILE_SIM_MODE                : string    := "FAST"; -- Set TO Fast Functional Simulation Model
    TILE_SIM_GTX_RESET_SPEEDUP    : integer   := 0; -- Set TO 1 TO speed up sim reset
    TILE_SIM_PLL_PERDIV2         : bit_vector:= x"0d0"); -- Set TO the VCO Unit Interval time 
PORT 
(
    ------------------------ Loopback AND Powerdown Ports ----------------------
    LOOPBACK0_IN                            : IN   std_logic_vector(2 DOWNTO 0);
    LOOPBACK1_IN                            : IN   std_logic_vector(2 DOWNTO 0);
    RXPOWERDOWN0_IN                         : IN   std_logic;
    RXPOWERDOWN1_IN                         : IN   std_logic;
    TXPOWERDOWN0_IN                         : IN   std_logic;
    TXPOWERDOWN1_IN                         : IN   std_logic;
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    RXCHARISCOMMA0_OUT                      : OUT  std_logic_vector(3 DOWNTO 0);
    RXCHARISCOMMA1_OUT                      : OUT  std_logic_vector(3 DOWNTO 0);
    RXCHARISK0_OUT                          : OUT  std_logic_vector(3 DOWNTO 0);
    RXCHARISK1_OUT                          : OUT  std_logic_vector(3 DOWNTO 0);
    RXDISPERR0_OUT                          : OUT  std_logic_vector(3 DOWNTO 0);
    RXDISPERR1_OUT                          : OUT  std_logic_vector(3 DOWNTO 0);
    RXNOTINTABLE0_OUT                       : OUT  std_logic_vector(3 DOWNTO 0);
    RXNOTINTABLE1_OUT                       : OUT  std_logic_vector(3 DOWNTO 0);
    ------------------- Receive Ports - Clock Correction Ports -----------------
    RXCLKCORCNT0_OUT                        : OUT  std_logic_vector(2 DOWNTO 0);
    RXCLKCORCNT1_OUT                        : OUT  std_logic_vector(2 DOWNTO 0);
    --------------- Receive Ports - Comma Detection AND Alignment --------------
    RXBYTEISALIGNED0_OUT                    : OUT  std_logic;
    RXBYTEISALIGNED1_OUT                    : OUT  std_logic;
    RXENMCOMMAALIGN0_IN                     : IN   std_logic;
    RXENMCOMMAALIGN1_IN                     : IN   std_logic;
    RXENPCOMMAALIGN0_IN                     : IN   std_logic;
    RXENPCOMMAALIGN1_IN                     : IN   std_logic;
    ------------------- Receive Ports - RX Data Path interface -----------------
    RXDATA0_OUT                             : OUT  std_logic_vector(31 DOWNTO 0);
    RXDATA1_OUT                             : OUT  std_logic_vector(31 DOWNTO 0);
    RXRESET0_IN                             : IN   std_logic;
    RXRESET1_IN                             : IN   std_logic;
    RXUSRCLK0_IN                            : IN   std_logic;
    RXUSRCLK1_IN                            : IN   std_logic;
    RXUSRCLK20_IN                           : IN   std_logic;
    RXUSRCLK21_IN                           : IN   std_logic;
    ------- Receive Ports - RX Driver,OOB signalling,Coupling AND Eq.,CDR ------
    RXCDRRESET0_IN                          : IN   std_logic;
    RXCDRRESET1_IN                          : IN   std_logic;
    RXN0_IN                                 : IN   std_logic;
    RXN1_IN                                 : IN   std_logic;
    RXP0_IN                                 : IN   std_logic;
    RXP1_IN                                 : IN   std_logic;
    -------- Receive Ports - RX Elastic BUFFER AND Phase Alignment Ports -------
    RXBUFRESET0_IN                          : IN   std_logic;
    RXBUFRESET1_IN                          : IN   std_logic;
    RXBUFSTATUS0_OUT                        : OUT  std_logic_vector(2 DOWNTO 0);
    RXBUFSTATUS1_OUT                        : OUT  std_logic_vector(2 DOWNTO 0);
    RXSTATUS0_OUT                           : OUT  std_logic_vector(2 DOWNTO 0);
    RXSTATUS1_OUT                           : OUT  std_logic_vector(2 DOWNTO 0);
    --------------- Receive Ports - RX Loss-OF-sync State Machine --------------
    RXLOSSOFSYNC0_OUT                       : OUT  std_logic_vector(1 DOWNTO 0);
    RXLOSSOFSYNC1_OUT                       : OUT  std_logic_vector(1 DOWNTO 0);
    -------------- Receive Ports - RX Pipe Control FOR PCI Express -------------
    RXVALID0_OUT                            : OUT  std_logic;
    RXVALID1_OUT                            : OUT  std_logic;
    ----------------- Receive Ports - RX Polarity Control Ports ----------------
    RXPOLARITY0_IN                          : IN   std_logic;
    RXPOLARITY1_IN                          : IN   std_logic;
    ------------- SHARED Ports - Dynamic Reconfiguration PORT (DRP) ------------
    DADDR_IN                                : IN   std_logic_vector(6 DOWNTO 0);
    DCLK_IN                                 : IN   std_logic;
    DEN_IN                                  : IN   std_logic;
    DI_IN                                   : IN   std_logic_vector(15 DOWNTO 0);
    DO_OUT                                  : OUT  std_logic_vector(15 DOWNTO 0);
    DRDY_OUT                                : OUT  std_logic;
    DWE_IN                                  : IN   std_logic;
    --------------------- SHARED Ports - Tile AND PLL Ports --------------------
    CLKIN_IN                                : IN   std_logic;
    GTXRESET_IN                             : IN   std_logic;
    PLLLKDET_OUT                            : OUT  std_logic;
    PLLPOWERDOWN_IN                         : IN   std_logic;
    REFCLKOUT_OUT                           : OUT  std_logic;
    REFCLKPWRDNB_IN                         : IN   std_logic;
    RESETDONE0_OUT                          : OUT  std_logic;
    RESETDONE1_OUT                          : OUT  std_logic;
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    TXCHARISK0_IN                           : IN   std_logic_vector(3 DOWNTO 0);
    TXCHARISK1_IN                           : IN   std_logic_vector(3 DOWNTO 0);
    ------------------ Transmit Ports - TX Data Path interface -----------------
    TXDATA0_IN                              : IN   std_logic_vector(31 DOWNTO 0);
    TXDATA1_IN                              : IN   std_logic_vector(31 DOWNTO 0);
    TXOUTCLK0_OUT                           : OUT  std_logic;
    TXOUTCLK1_OUT                           : OUT  std_logic;
    TXRESET0_IN                             : IN   std_logic;
    TXRESET1_IN                             : IN   std_logic;
    TXUSRCLK0_IN                            : IN   std_logic;
    TXUSRCLK1_IN                            : IN   std_logic;
    TXUSRCLK20_IN                           : IN   std_logic;
    TXUSRCLK21_IN                           : IN   std_logic;
    --------------- Transmit Ports - TX Driver AND OOB signalling --------------
    TXN0_OUT                                : OUT  std_logic;
    TXN1_OUT                                : OUT  std_logic;
    TXP0_OUT                                : OUT  std_logic;
    TXP1_OUT                                : OUT  std_logic;
    --------------------- Transmit Ports - TX PRBS Generator -------------------
    TXENPRBSTST0_IN                         : IN   std_logic_vector(1 DOWNTO 0);
    TXENPRBSTST1_IN                         : IN   std_logic_vector(1 DOWNTO 0);
    -------------------- Transmit Ports - TX Polarity Control ------------------
    TXPOLARITY0_IN                          : IN   std_logic;
    TXPOLARITY1_IN                          : IN   std_logic


);

    ATTRIBUTE X_CORE_INFO : string;
    ATTRIBUTE X_CORE_INFO OF minit_gtx_tile : ENTITY is "gtxwizard_v1_6, Coregen v11.2";

END minit_gtx_tile;

ARCHITECTURE RTL OF minit_gtx_tile IS

    -- Ground AND tied_to_vcc_i signals
    SIGNAL  tied_to_ground_i                :   std_logic;
    SIGNAL  tied_to_ground_vec_i            :   std_logic_vector(63 DOWNTO 0);
    SIGNAL  tied_to_vcc_i                   :   std_logic;

    -- Datapath signals
    SIGNAL rxdata0_i                        :   std_logic_vector(31 DOWNTO 0);      
    SIGNAL txdata0_i                        :   std_logic_vector(31 DOWNTO 0);
    SIGNAL rxdata1_i                        :   std_logic_vector(31 DOWNTO 0);      
    SIGNAL txdata1_i                        :   std_logic_vector(31 DOWNTO 0);

    SIGNAL RXPOWERDOWN0  :   std_logic_vector(1 DOWNTO 0);
    SIGNAL RXPOWERDOWN1  :   std_logic_vector(1 DOWNTO 0);
    SIGNAL TXPOWERDOWN0  :   std_logic_vector(1 DOWNTO 0);
    SIGNAL TXPOWERDOWN1  :   std_logic_vector(1 DOWNTO 0);

begin

    -- Static SIGNAL Assignments

    tied_to_ground_i                    <= '0';
    tied_to_ground_vec_i(63 DOWNTO 0)   <= (OTHERS => '0');
    tied_to_vcc_i                       <= '1';

    -- GTX Datapath byte mapping
    RXDATA0_OUT    <=   rxdata0_i;
    RXDATA1_OUT    <=   rxdata1_i;
    txdata0_i    <=   TXDATA0_IN;
    txdata1_i    <=   TXDATA1_IN;

    -- Two pins control power up/down.  Must be connected TO gether except FOR PCI-E
    RXPOWERDOWN0 <= (OTHERS => RXPOWERDOWN0_IN);
    RXPOWERDOWN1 <= (OTHERS => RXPOWERDOWN1_IN);
    TXPOWERDOWN0 <= (OTHERS => TXPOWERDOWN0_IN);
    TXPOWERDOWN1 <= (OTHERS => TXPOWERDOWN1_IN);

    gtx_dual_i:GTX_DUAL
    GENERIC MAP
    (

        SIM_RECEIVER_DETECT_PASS_0  =>       TRUE,
        SIM_RECEIVER_DETECT_PASS_1  =>       TRUE,
        SIM_MODE                    =>       TILE_SIM_MODE,
        SIM_GTXRESET_SPEEDUP        =>       TILE_SIM_GTX_RESET_SPEEDUP,
        SIM_PLL_PERDIV2             =>       TILE_SIM_PLL_PERDIV2,

        -------------------------- Tile AND PLL Attributes ---------------------

        CLK25_DIVIDER               =>       6,  -- Depends ON CLKIN frequency 
        CLKINDC_B                   =>       TRUE,
        CLKRCV_TRST                 =>       TRUE,
        OOB_CLK_DIVIDER             =>       8,
        OVERSAMPLE_MODE             =>       FALSE,
        PLL_COM_CFG                 =>       x"21680a",
        PLL_CP_CFG                  =>       x"00",
        PLL_DIVSEL_FB               =>       4,   -- Make sure PLL frequncy within 1.5 TO 3.25 GHz
        PLL_DIVSEL_REF              =>       1,   -- Make sure PLL frequncy within 1.5 TO 3.25 GHz
        PLL_FB_DCCEN                =>       FALSE,
        PLL_LKDET_CFG               =>       "101",
        PLL_TDCC_CFG                =>       "000",
        PMA_COM_CFG                 =>       x"000000000000000000",

        ------------------- TX Buffering AND Phase Alignment -------------------   

        TX_BUFFER_USE_0             =>       TRUE,
        TX_XCLK_SEL_0               =>       "TXOUT",
        TXRX_INVERT_0               =>       "011",        

        TX_BUFFER_USE_1             =>       TRUE,
        TX_XCLK_SEL_1               =>       "TXOUT",
        TXRX_INVERT_1               =>       "011",        

        --------------------- TX Gearbox Settings -----------------------------

        GEARBOX_ENDEC_0             =>       "000", 
        TXGEARBOX_USE_0            =>        FALSE,

        GEARBOX_ENDEC_1            =>        "000", 
        TXGEARBOX_USE_1            =>        FALSE,

        --------------------- TX Serial Line Rate settings ---------------------   

        PLL_TXDIVSEL_OUT_0          =>       1,  -- Used TO adjust line rate, WHILE keeping PLL frequncy within bounds.
        PLL_TXDIVSEL_OUT_1          =>       1,  -- Used TO adjust line rate, WHILE keeping PLL frequncy within bounds.
        --------------------- TX Driver AND OOB signalling --------------------  

        CM_TRIM_0                   =>       "10",
        PMA_TX_CFG_0                =>       x"80082",
        TX_DETECT_RX_CFG_0          =>       x"1832",
        TX_IDLE_DELAY_0             =>       "010",

        CM_TRIM_1                   =>       "10",
        PMA_TX_CFG_1                =>       x"80082",
        TX_DETECT_RX_CFG_1          =>       x"1832",
        TX_IDLE_DELAY_1             =>       "010",

        ------------------ TX Pipe Control FOR PCI Express/SATA ---------------

        COM_BURST_VAL_0             =>       "1111",
        COM_BURST_VAL_1             =>       "1111",

        ------------ RX Driver,OOB signalling,Coupling AND Eq,CDR -------------  

        AC_CAP_DIS_0                =>       TRUE,
        OOBDETECT_THRESHOLD_0       =>       "111",
        PMA_CDR_SCAN_0              =>       x"6404037",  -- Depends ON PLL_RXDIVSEL_OUT
        PMA_RX_CFG_0                =>       x"0f44088",  -- Allows clk TO drift by 100PPM
        RCV_TERM_GND_0              =>       FALSE,
        RCV_TERM_VTTRX_0            =>       FALSE,
        TERMINATION_IMP_0           =>       50,

        AC_CAP_DIS_1                =>       TRUE,
        OOBDETECT_THRESHOLD_1       =>       "111",
        PMA_CDR_SCAN_1              =>       x"6404035",   -- Changed, GregIles 21/4/2010, Was x"6404037"
        PMA_RX_CFG_1                =>       x"0f44089",   -- Changed, GregIles 21/4/2010, Was x"0f44088"
        RCV_TERM_GND_1              =>       FALSE,
        RCV_TERM_VTTRX_1            =>       FALSE,
        TERMINATION_IMP_1           =>       50,

        TERMINATION_CTRL            =>       "10100",
        TERMINATION_OVRD            =>       FALSE,

        ---------------- RX Decision Feedback Equalizer(DFE)  ----------------  

        DFE_CFG_0                   =>       "1001111011",
        DFE_CFG_1                   =>       "1001111011",
        DFE_CAL_TIME                =>       "00110",

        --------------------- RX Serial Line Rate Attributes ------------------   

        PLL_RXDIVSEL_OUT_0          =>       1,  -- Used TO adjust line rate, WHILE keeping PLL frequncy within bounds.
        PLL_SATA_0                  =>       FALSE,
        PLL_RXDIVSEL_OUT_1          =>       1,   -- Used TO adjust line rate, WHILE keeping PLL frequncy within bounds.
        PLL_SATA_1                  =>       FALSE,

        ----------------------- PRBS Detection Attributes ---------------------  

        PRBS_ERR_THRESHOLD_0        =>       x"00000001",
        PRBS_ERR_THRESHOLD_1        =>       x"00000001",

        ---------------- Comma Detection AND Alignment Attributes -------------  

        ALIGN_COMMA_WORD_0          =>       2,
        COMMA_10B_ENABLE_0          =>       "1111111111",
        COMMA_DOUBLE_0              =>       FALSE,
        DEC_MCOMMA_DETECT_0         =>       TRUE,
        DEC_PCOMMA_DETECT_0         =>       TRUE,
        DEC_VALID_COMMA_ONLY_0      =>       TRUE,          -- Changed, GregIles 9/4/2010, Was FALSE
        MCOMMA_10B_VALUE_0          =>       "1010000011",  -- Changed, GregIles 9/4/2010, Was "0110000011",
        MCOMMA_DETECT_0             =>       TRUE,
        PCOMMA_10B_VALUE_0          =>       "0101111100",  -- Changed, GregIles 9/4/2010, Was "1001111100",
        PCOMMA_DETECT_0             =>       TRUE,
        RX_SLIDE_MODE_0             =>       "PCS",

        ALIGN_COMMA_WORD_1          =>       2,
        COMMA_10B_ENABLE_1          =>       "1111111111",
        COMMA_DOUBLE_1              =>       FALSE,
        DEC_MCOMMA_DETECT_1         =>       TRUE,
        DEC_PCOMMA_DETECT_1         =>       TRUE,
        DEC_VALID_COMMA_ONLY_1      =>       TRUE,          -- Changed, GregIles 9/4/2010, Was FALSE
        MCOMMA_10B_VALUE_1          =>       "1010000011",  -- Changed, GregIles 9/4/2010, Was "0110000011",
        MCOMMA_DETECT_1             =>       TRUE,
        PCOMMA_10B_VALUE_1          =>       "0101111100",  -- Changed, GregIles 9/4/2010, Was "1001111100",
        PCOMMA_DETECT_1             =>       TRUE,
        RX_SLIDE_MODE_1             =>       "PCS",

        ------------------ RX Loss-OF-sync State Machine Attributes -----------  

        RX_LOSS_OF_SYNC_FSM_0       =>       TRUE,       -- Changed, GregIles 9/4/2010, Was FALSE
        RX_LOS_INVALID_INCR_0       =>       8,
        RX_LOS_THRESHOLD_0          =>       128,

        RX_LOSS_OF_SYNC_FSM_1       =>       TRUE,       -- Changed, GregIles 9/4/2010, Was FALSE
        RX_LOS_INVALID_INCR_1       =>       8,
        RX_LOS_THRESHOLD_1          =>       128,

        --------------------- RX Gearbox Settings -----------------------------

        RXGEARBOX_USE_0             =>       FALSE,

        RXGEARBOX_USE_1             =>       FALSE,

        -------------- RX Elastic BUFFER AND Phase alignment Attributes -------   

        PMA_RXSYNC_CFG_0            =>       x"00",
        RX_BUFFER_USE_0             =>       TRUE,
        RX_XCLK_SEL_0               =>       "RXREC",

        PMA_RXSYNC_CFG_1            =>       x"00",
        RX_BUFFER_USE_1             =>       TRUE,
        RX_XCLK_SEL_1               =>       "RXREC",                   

        ------------------------ Clock Correction Attributes ------------------   

        CLK_CORRECT_USE_0           =>       FALSE,     -- Changed, GregIles 21/4/2010, Was TRUE
        CLK_COR_ADJ_LEN_0           =>       2,
        CLK_COR_DET_LEN_0           =>       2,
        CLK_COR_INSERT_IDLE_FLAG_0  =>       FALSE,
        CLK_COR_KEEP_IDLE_0         =>       FALSE,
        CLK_COR_MAX_LAT_0           =>       20,
        CLK_COR_MIN_LAT_0           =>       16,
        CLK_COR_PRECEDENCE_0        =>       TRUE,
        CLK_COR_REPEAT_WAIT_0       =>       0,
        CLK_COR_SEQ_1_1_0           =>       "0100000000",   -- Changed, GregIles 21/4/2010, Was "0111110111",
        CLK_COR_SEQ_1_2_0           =>       "0000000000",
        CLK_COR_SEQ_1_3_0           =>       "0000000000",
        CLK_COR_SEQ_1_4_0           =>       "0000000000",
        CLK_COR_SEQ_1_ENABLE_0      =>       "1111",        -- Changed, GregIles 21/4/2010, Was "0011",
        CLK_COR_SEQ_2_1_0           =>       "0100000000",  -- Changed, GregIles 21/4/2010, Was "0000000000",
        CLK_COR_SEQ_2_2_0           =>       "0000000000",
        CLK_COR_SEQ_2_3_0           =>       "0000000000",
        CLK_COR_SEQ_2_4_0           =>       "0000000000",
        CLK_COR_SEQ_2_ENABLE_0      =>       "1111",         -- Changed, GregIles 21/4/2010, Was "0000",
        CLK_COR_SEQ_2_USE_0         =>       FALSE,
        RX_DECODE_SEQ_MATCH_0       =>       TRUE,

        CLK_CORRECT_USE_1           =>       FALSE,
        CLK_COR_ADJ_LEN_1           =>       2,
        CLK_COR_DET_LEN_1           =>       2,
        CLK_COR_INSERT_IDLE_FLAG_1  =>       FALSE,
        CLK_COR_KEEP_IDLE_1         =>       FALSE,
        CLK_COR_MAX_LAT_1           =>       20,
        CLK_COR_MIN_LAT_1           =>       16,
        CLK_COR_PRECEDENCE_1        =>       TRUE,
        CLK_COR_REPEAT_WAIT_1       =>       0,
        CLK_COR_SEQ_1_1_1           =>       "0100000000",
        CLK_COR_SEQ_1_2_1           =>       "0000000000",
        CLK_COR_SEQ_1_3_1           =>       "0000000000",
        CLK_COR_SEQ_1_4_1           =>       "0000000000",
        CLK_COR_SEQ_1_ENABLE_1      =>       "1111",
        CLK_COR_SEQ_2_1_1           =>       "0100000000",
        CLK_COR_SEQ_2_2_1           =>       "0000000000",
        CLK_COR_SEQ_2_3_1           =>       "0000000000",
        CLK_COR_SEQ_2_4_1           =>       "0000000000",
        CLK_COR_SEQ_2_ENABLE_1      =>       "1111",
        CLK_COR_SEQ_2_USE_1         =>       FALSE,
        RX_DECODE_SEQ_MATCH_1       =>       TRUE,

        ------------------------ Channel Bonding Attributes -------------------   

        CB2_INH_CC_PERIOD_0         =>       8,
        CHAN_BOND_1_MAX_SKEW_0      =>       1,
        CHAN_BOND_2_MAX_SKEW_0      =>       1,
        CHAN_BOND_KEEP_ALIGN_0      =>       FALSE,
        CHAN_BOND_LEVEL_0           =>       0,
        CHAN_BOND_MODE_0            =>       "OFF",
        CHAN_BOND_SEQ_1_1_0         =>       "0000000000",
        CHAN_BOND_SEQ_1_2_0         =>       "0000000000",
        CHAN_BOND_SEQ_1_3_0         =>       "0000000000",
        CHAN_BOND_SEQ_1_4_0         =>       "0000000000",
        CHAN_BOND_SEQ_1_ENABLE_0    =>       "0000",
        CHAN_BOND_SEQ_2_1_0         =>       "0000000000",
        CHAN_BOND_SEQ_2_2_0         =>       "0000000000",
        CHAN_BOND_SEQ_2_3_0         =>       "0000000000",
        CHAN_BOND_SEQ_2_4_0         =>       "0000000000",
        CHAN_BOND_SEQ_2_ENABLE_0    =>       "0000",
        CHAN_BOND_SEQ_2_USE_0       =>       FALSE,  
        CHAN_BOND_SEQ_LEN_0         =>       1,
        PCI_EXPRESS_MODE_0          =>       FALSE,   
     
        CB2_INH_CC_PERIOD_1         =>       8,
        CHAN_BOND_1_MAX_SKEW_1      =>       1,
        CHAN_BOND_2_MAX_SKEW_1      =>       1,
        CHAN_BOND_KEEP_ALIGN_1      =>       FALSE,
        CHAN_BOND_LEVEL_1           =>       0,
        CHAN_BOND_MODE_1            =>       "OFF",
        CHAN_BOND_SEQ_1_1_1         =>       "0000000000",
        CHAN_BOND_SEQ_1_2_1         =>       "0000000000",
        CHAN_BOND_SEQ_1_3_1         =>       "0000000000",
        CHAN_BOND_SEQ_1_4_1         =>       "0000000000",
        CHAN_BOND_SEQ_1_ENABLE_1    =>       "0000",
        CHAN_BOND_SEQ_2_1_1         =>       "0000000000",
        CHAN_BOND_SEQ_2_2_1         =>       "0000000000",
        CHAN_BOND_SEQ_2_3_1         =>       "0000000000",
        CHAN_BOND_SEQ_2_4_1         =>       "0000000000",
        CHAN_BOND_SEQ_2_ENABLE_1    =>       "0000",
        CHAN_BOND_SEQ_2_USE_1       =>       FALSE,  
        CHAN_BOND_SEQ_LEN_1         =>       1,
        PCI_EXPRESS_MODE_1          =>       FALSE,

        -------- RX Attributes TO Control Reset AFTER Electrical Idle  ------

        RX_EN_IDLE_HOLD_DFE_0       =>       TRUE,
        RX_EN_IDLE_RESET_BUF_0      =>       TRUE,
        RX_IDLE_HI_CNT_0            =>       "1000",
        RX_IDLE_LO_CNT_0            =>       "0000",

        RX_EN_IDLE_HOLD_DFE_1       =>       TRUE,
        RX_EN_IDLE_RESET_BUF_1      =>       TRUE,
        RX_IDLE_HI_CNT_1            =>       "1000",
        RX_IDLE_LO_CNT_1            =>       "0000",


        CDR_PH_ADJ_TIME             =>       "01010",
        RX_EN_IDLE_RESET_FR         =>       TRUE,
        RX_EN_IDLE_HOLD_CDR         =>       FALSE,
        RX_EN_IDLE_RESET_PH         =>       TRUE,

        ------------------ RX Attributes FOR PCI Express/SATA ---------------

        RX_STATUS_FMT_0             =>       "PCIE",
        SATA_BURST_VAL_0            =>       "100",
        SATA_IDLE_VAL_0             =>       "100",
        SATA_MAX_BURST_0            =>       9,
        SATA_MAX_INIT_0             =>       26,
        SATA_MAX_WAKE_0             =>       9,
        SATA_MIN_BURST_0            =>       5,
        SATA_MIN_INIT_0             =>       14,
        SATA_MIN_WAKE_0             =>       5,
        TRANS_TIME_FROM_P2_0        =>       x"003c",
        TRANS_TIME_NON_P2_0         =>       x"0019",
        TRANS_TIME_TO_P2_0          =>       x"0064",

        RX_STATUS_FMT_1             =>       "PCIE",
        SATA_BURST_VAL_1            =>       "100",
        SATA_IDLE_VAL_1             =>       "100",
        SATA_MAX_BURST_1            =>       9,
        SATA_MAX_INIT_1             =>       26,
        SATA_MAX_WAKE_1             =>       9,
        SATA_MIN_BURST_1            =>       5,
        SATA_MIN_INIT_1             =>       14,
        SATA_MIN_WAKE_1             =>       5,
        TRANS_TIME_FROM_P2_1        =>       x"003c",
        TRANS_TIME_NON_P2_1         =>       x"0019",
        TRANS_TIME_TO_P2_1          =>       x"0064"
    ) 
    PORT MAP 
    (
        ------------------------ Loopback AND Powerdown Ports ----------------------

        LOOPBACK0                       =>      LOOPBACK0_IN,
        LOOPBACK1                       =>      LOOPBACK1_IN,
        RXPOWERDOWN0                    =>      RXPOWERDOWN0,
        RXPOWERDOWN1                    =>      RXPOWERDOWN1,
        TXPOWERDOWN0                    =>      TXPOWERDOWN0,
        TXPOWERDOWN1                    =>      TXPOWERDOWN1,

        -------------- Receive Ports - 64b66b AND 64b67b Gearbox Ports -------------

        RXDATAVALID0                    =>      open,
        RXDATAVALID1                    =>      open,
        RXGEARBOXSLIP0                  =>      tied_to_ground_i,
        RXGEARBOXSLIP1                  =>      tied_to_ground_i,
        RXHEADER0                       =>      open,
        RXHEADER1                       =>      open,
        RXHEADERVALID0                  =>      open,
        RXHEADERVALID1                  =>      open,
        RXSTARTOFSEQ0                   =>      open,
        RXSTARTOFSEQ1                   =>      open,

        ----------------------- Receive Ports - 8b10b Decoder ----------------------

        RXCHARISCOMMA0                  =>      RXCHARISCOMMA0_OUT,
        RXCHARISCOMMA1                  =>      RXCHARISCOMMA1_OUT,
        RXCHARISK0                      =>      RXCHARISK0_OUT,
        RXCHARISK1                      =>      RXCHARISK1_OUT,
        RXDEC8B10BUSE0                  =>      tied_to_vcc_i,
        RXDEC8B10BUSE1                  =>      tied_to_vcc_i,
        RXDISPERR0                      =>      RXDISPERR0_OUT,
        RXDISPERR1                      =>      RXDISPERR1_OUT,
        RXNOTINTABLE0                   =>      RXNOTINTABLE0_OUT,
        RXNOTINTABLE1                   =>      RXNOTINTABLE1_OUT,
        RXRUNDISP0                      =>      open,
        RXRUNDISP1                      =>      open,

        ------------------- Receive Ports - Channel Bonding Ports ------------------

        RXCHANBONDSEQ0                  =>      open,
        RXCHANBONDSEQ1                  =>      open,
        RXCHBONDI0                      =>      tied_to_ground_vec_i(3 DOWNTO 0),
        RXCHBONDI1                      =>      tied_to_ground_vec_i(3 DOWNTO 0),
        RXCHBONDO0                      =>      open,
        RXCHBONDO1                      =>      open,
        RXENCHANSYNC0                   =>      tied_to_ground_i,
        RXENCHANSYNC1                   =>      tied_to_ground_i,

        ------------------- Receive Ports - Clock Correction Ports -----------------

        RXCLKCORCNT0                    =>      RXCLKCORCNT0_OUT,
        RXCLKCORCNT1                    =>      RXCLKCORCNT1_OUT,

        --------------- Receive Ports - Comma Detection AND Alignment --------------

        RXBYTEISALIGNED0                =>      RXBYTEISALIGNED0_OUT,
        RXBYTEISALIGNED1                =>      RXBYTEISALIGNED1_OUT,
        RXBYTEREALIGN0                  =>      open,
        RXBYTEREALIGN1                  =>      open,
        RXCOMMADET0                     =>      open,
        RXCOMMADET1                     =>      open,
        RXCOMMADETUSE0                  =>      tied_to_vcc_i,
        RXCOMMADETUSE1                  =>      tied_to_vcc_i,
        RXENMCOMMAALIGN0                =>      RXENMCOMMAALIGN0_IN,
        RXENMCOMMAALIGN1                =>      RXENMCOMMAALIGN1_IN,
        RXENPCOMMAALIGN0                =>      RXENPCOMMAALIGN0_IN,
        RXENPCOMMAALIGN1                =>      RXENPCOMMAALIGN1_IN,
        RXSLIDE0                        =>      tied_to_ground_i,
        RXSLIDE1                        =>      tied_to_ground_i,

        ----------------------- Receive Ports - PRBS Detection ---------------------

        PRBSCNTRESET0                   =>      tied_to_ground_i,
        PRBSCNTRESET1                   =>      tied_to_ground_i,
        RXENPRBSTST0                    =>      tied_to_ground_vec_i(1 DOWNTO 0),
        RXENPRBSTST1                    =>      tied_to_ground_vec_i(1 DOWNTO 0),
        RXPRBSERR0                      =>      open,
        RXPRBSERR1                      =>      open,

        ------------------- Receive Ports - RX Data Path interface -----------------

        RXDATA0                         =>      rxdata0_i,
        RXDATA1                         =>      rxdata1_i,
        RXDATAWIDTH0                    =>      "10",
        RXDATAWIDTH1                    =>      "10",
        RXRECCLK0                       =>      open,
        RXRECCLK1                       =>      open,
        RXRESET0                        =>      RXRESET0_IN,
        RXRESET1                        =>      RXRESET1_IN,
        RXUSRCLK0                       =>      RXUSRCLK0_IN,
        RXUSRCLK1                       =>      RXUSRCLK1_IN,
        RXUSRCLK20                      =>      RXUSRCLK20_IN,
        RXUSRCLK21                      =>      RXUSRCLK21_IN,

        ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------

        DFECLKDLYADJ0                   =>      tied_to_ground_vec_i(5 DOWNTO 0),
        DFECLKDLYADJ1                   =>      tied_to_ground_vec_i(5 DOWNTO 0),
        DFECLKDLYADJMONITOR0            =>      open,
        DFECLKDLYADJMONITOR1            =>      open,
        DFEEYEDACMONITOR0               =>      open,
        DFEEYEDACMONITOR1               =>      open,
        DFESENSCAL0                     =>      open,
        DFESENSCAL1                     =>      open,
        DFETAP10                        =>      tied_to_ground_vec_i(4 DOWNTO 0),
        DFETAP11                        =>      tied_to_ground_vec_i(4 DOWNTO 0),
        DFETAP1MONITOR0                 =>      open,
        DFETAP1MONITOR1                 =>      open,
        DFETAP20                        =>      tied_to_ground_vec_i(4 DOWNTO 0),
        DFETAP21                        =>      tied_to_ground_vec_i(4 DOWNTO 0),
        DFETAP2MONITOR0                 =>      open,
        DFETAP2MONITOR1                 =>      open,
        DFETAP30                        =>      tied_to_ground_vec_i(3 DOWNTO 0),
        DFETAP31                        =>      tied_to_ground_vec_i(3 DOWNTO 0),
        DFETAP3MONITOR0                 =>      open,
        DFETAP3MONITOR1                 =>      open,
        DFETAP40                        =>      tied_to_ground_vec_i(3 DOWNTO 0),
        DFETAP41                        =>      tied_to_ground_vec_i(3 DOWNTO 0),
        DFETAP4MONITOR0                 =>      open,
        DFETAP4MONITOR1                 =>      open,

        ------- Receive Ports - RX Driver,OOB signalling,Coupling AND Eq.,CDR ------

        RXCDRRESET0                     =>      RXCDRRESET0_IN,
        RXCDRRESET1                     =>      RXCDRRESET1_IN,
        RXELECIDLE0                     =>      open,
        RXELECIDLE1                     =>      open,
        RXENEQB0                        =>      tied_to_ground_i,
        RXENEQB1                        =>      tied_to_ground_i,
        RXEQMIX0                        =>      "11",
        RXEQMIX1                        =>      "11",
        RXEQPOLE0                       =>      "0000",
        RXEQPOLE1                       =>      "0000",
        RXN0                            =>      RXN0_IN,
        RXN1                            =>      RXN1_IN,
        RXP0                            =>      RXP0_IN,
        RXP1                            =>      RXP1_IN,

        -------- Receive Ports - RX Elastic BUFFER AND Phase Alignment Ports -------

        RXBUFRESET0                     =>      RXBUFRESET0_IN,
        RXBUFRESET1                     =>      RXBUFRESET1_IN,
        RXBUFSTATUS0                    =>      RXBUFSTATUS0_OUT,
        RXBUFSTATUS1                    =>      RXBUFSTATUS1_OUT,
        RXCHANISALIGNED0                =>      open,
        RXCHANISALIGNED1                =>      open,
        RXCHANREALIGN0                  =>      open,
        RXCHANREALIGN1                  =>      open,
        RXENPMAPHASEALIGN0              =>      tied_to_ground_i,
        RXENPMAPHASEALIGN1              =>      tied_to_ground_i,
        RXPMASETPHASE0                  =>      tied_to_ground_i,
        RXPMASETPHASE1                  =>      tied_to_ground_i,
        RXSTATUS0                       =>      RXSTATUS0_OUT,
        RXSTATUS1                       =>      RXSTATUS1_OUT,

        --------------- Receive Ports - RX Loss-OF-sync State Machine --------------

        RXLOSSOFSYNC0                   =>      RXLOSSOFSYNC0_OUT,
        RXLOSSOFSYNC1                   =>      RXLOSSOFSYNC1_OUT,

        ---------------------- Receive Ports - RX Oversampling ---------------------

        RXENSAMPLEALIGN0                =>      tied_to_ground_i,
        RXENSAMPLEALIGN1                =>      tied_to_ground_i,
        RXOVERSAMPLEERR0                =>      open,
        RXOVERSAMPLEERR1                =>      open,

        -------------- Receive Ports - RX Pipe Control FOR PCI Express -------------

        PHYSTATUS0                      =>      open,
        PHYSTATUS1                      =>      open,
        RXVALID0                        =>      RXVALID0_OUT,
        RXVALID1                        =>      RXVALID1_OUT,

        ----------------- Receive Ports - RX Polarity Control Ports ----------------

        RXPOLARITY0                     =>      RXPOLARITY0_IN,
        RXPOLARITY1                     =>      RXPOLARITY1_IN,

        ------------- SHARED Ports - Dynamic Reconfiguration PORT (DRP) ------------

        DADDR                           =>      DADDR_IN,
        DCLK                            =>      DCLK_IN,
        DEN                             =>      DEN_IN,
        DI                              =>      DI_IN,
        DO                              =>      DO_OUT,
        DRDY                            =>      DRDY_OUT,
        DWE                             =>      DWE_IN,

        --------------------- SHARED Ports - Tile AND PLL Ports --------------------

        CLKIN                           =>      CLKIN_IN,
        GTXRESET                        =>      GTXRESET_IN,
        GTXTEST                         =>      "10000000000000",
        INTDATAWIDTH                    =>      tied_to_vcc_i,
        PLLLKDET                        =>      PLLLKDET_OUT,
        PLLLKDETEN                      =>      tied_to_vcc_i,
        PLLPOWERDOWN                    =>      PLLPOWERDOWN_IN,
        REFCLKOUT                       =>      REFCLKOUT_OUT,
        REFCLKPWRDNB                    =>      REFCLKPWRDNB_IN, -- tied_to_vcc_i,
        RESETDONE0                      =>      RESETDONE0_OUT,
        RESETDONE1                      =>      RESETDONE1_OUT,

        -------------- Transmit Ports - 64b66b AND 64b67b Gearbox Ports ------------

        TXGEARBOXREADY0                 =>      open,
        TXGEARBOXREADY1                 =>      open,
        TXHEADER0                       =>      tied_to_ground_vec_i(2 DOWNTO 0),
        TXHEADER1                       =>      tied_to_ground_vec_i(2 DOWNTO 0),
        TXSEQUENCE0                     =>      tied_to_ground_vec_i(6 DOWNTO 0),
        TXSEQUENCE1                     =>      tied_to_ground_vec_i(6 DOWNTO 0),
        TXSTARTSEQ0                     =>      tied_to_ground_i,
        TXSTARTSEQ1                     =>      tied_to_ground_i,

        ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------

        TXBYPASS8B10B0                  =>      tied_to_ground_vec_i(3 DOWNTO 0),
        TXBYPASS8B10B1                  =>      tied_to_ground_vec_i(3 DOWNTO 0),
        TXCHARDISPMODE0                 =>      tied_to_ground_vec_i(3 DOWNTO 0),
        TXCHARDISPMODE1                 =>      tied_to_ground_vec_i(3 DOWNTO 0),
        TXCHARDISPVAL0                  =>      tied_to_ground_vec_i(3 DOWNTO 0),
        TXCHARDISPVAL1                  =>      tied_to_ground_vec_i(3 DOWNTO 0),
        TXCHARISK0                      =>      TXCHARISK0_IN,
        TXCHARISK1                      =>      TXCHARISK1_IN,
        TXENC8B10BUSE0                  =>      tied_to_vcc_i,
        TXENC8B10BUSE1                  =>      tied_to_vcc_i,
        TXKERR0                         =>      open,
        TXKERR1                         =>      open,
        TXRUNDISP0                      =>      open,
        TXRUNDISP1                      =>      open,

        ------------- Transmit Ports - TX Buffering AND Phase Alignment ------------

        TXBUFSTATUS0                    =>      open,
        TXBUFSTATUS1                    =>      open,

        ------------------ Transmit Ports - TX Data Path interface -----------------

        TXDATA0                         =>      txdata0_i,
        TXDATA1                         =>      txdata1_i,
        TXDATAWIDTH0                    =>      "10",
        TXDATAWIDTH1                    =>      "10",
        TXOUTCLK0                       =>      TXOUTCLK0_OUT,
        TXOUTCLK1                       =>      TXOUTCLK1_OUT,
        TXRESET0                        =>      TXRESET0_IN,
        TXRESET1                        =>      TXRESET1_IN,
        TXUSRCLK0                       =>      TXUSRCLK0_IN,
        TXUSRCLK1                       =>      TXUSRCLK1_IN,
        TXUSRCLK20                      =>      TXUSRCLK20_IN,
        TXUSRCLK21                      =>      TXUSRCLK21_IN,

        --------------- Transmit Ports - TX Driver AND OOB signalling --------------

        TXBUFDIFFCTRL0                  =>      "101",
        TXBUFDIFFCTRL1                  =>      "101",
        TXDIFFCTRL0                     =>      "000",
        TXDIFFCTRL1                     =>      "000",
        TXINHIBIT0                      =>      tied_to_ground_i,
        TXINHIBIT1                      =>      tied_to_ground_i,
        TXN0                            =>      TXN0_OUT,
        TXN1                            =>      TXN1_OUT,
        TXP0                            =>      TXP0_OUT,
        TXP1                            =>      TXP1_OUT,
        TXPREEMPHASIS0                  =>      "0000",
        TXPREEMPHASIS1                  =>      "0000",

        -------- Transmit Ports - TX Elastic BUFFER AND Phase Alignment Ports ------

        TXENPMAPHASEALIGN0              =>      tied_to_ground_i,
        TXENPMAPHASEALIGN1              =>      tied_to_ground_i,
        TXPMASETPHASE0                  =>      tied_to_ground_i,
        TXPMASETPHASE1                  =>      tied_to_ground_i,

        --------------------- Transmit Ports - TX PRBS Generator -------------------

        TXENPRBSTST0                    =>      TXENPRBSTST0_IN,
        TXENPRBSTST1                    =>      TXENPRBSTST1_IN,

        -------------------- Transmit Ports - TX Polarity Control ------------------

        TXPOLARITY0                     =>      TXPOLARITY0_IN,
        TXPOLARITY1                     =>      TXPOLARITY1_IN,

        ----------------- Transmit Ports - TX Ports FOR PCI Express ----------------

        TXDETECTRX0                     =>      tied_to_ground_i,
        TXDETECTRX1                     =>      tied_to_ground_i,
        TXELECIDLE0                     =>      TXPOWERDOWN0_IN,   --tied_to_ground_i,
        TXELECIDLE1                     =>      TXPOWERDOWN1_IN,   -- tied_to_ground_i,

        --------------------- Transmit Ports - TX Ports FOR SATA -------------------

        TXCOMSTART0                     =>      tied_to_ground_i,
        TXCOMSTART1                     =>      tied_to_ground_i,
        TXCOMTYPE0                      =>      tied_to_ground_i,
        TXCOMTYPE1                      =>      tied_to_ground_i);


END RTL;


