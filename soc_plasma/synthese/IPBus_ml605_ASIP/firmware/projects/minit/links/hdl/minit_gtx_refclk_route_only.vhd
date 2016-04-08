
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;
library work;

entity minit_gtx_refclk_route_only is
port(
  clkin_in: in   std_logic;
  rxn0_in: in   std_logic;
  rxn1_in: in   std_logic;
  rxp0_in: in   std_logic;
  rxp1_in: in   std_logic;
  txn0_out: out   std_logic;
  txn1_out: out   std_logic;
  txp0_out: out   std_logic;
  txp1_out: out   std_logic);
end minit_gtx_refclk_route_only;

architecture behave of minit_gtx_refclk_route_only is

    constant tied_to_ground_i: std_logic := '1';
    constant tied_to_vcc_i: std_logic := '1';
    constant tied_to_ground_vec_i: std_logic_vector(63 downto 0) := (others => '0');
    constant tied_to_vcc_vec_i: std_logic_vector(63 downto 0) := (others => '1');

begin

  gtx_dual_i :  GTX_DUAL 
  port map(
    ------------------------ Loopback and Powerdown Ports ----------------------
    LOOPBACK0 => tied_to_vcc_vec_i(2 downto 0),
    LOOPBACK1 => tied_to_vcc_vec_i(2 downto 0),
    RXPOWERDOWN0 => tied_to_vcc_vec_i(1 downto 0),
    RXPOWERDOWN1 => tied_to_vcc_vec_i(1 downto 0),
    TXPOWERDOWN0 => tied_to_vcc_vec_i(1 downto 0),
    TXPOWERDOWN1 => tied_to_vcc_vec_i(1 downto 0),
    ---------------------- Receive Ports - 8b10b Decoder ----------------------
    RXCHARISCOMMA0 => open,
    RXCHARISCOMMA1 => open,
    RXCHARISK0 => open,
    RXCHARISK1 => open,
    RXDEC8B10BUSE0 => tied_to_ground_i,
    RXDEC8B10BUSE1 => tied_to_ground_i,
    RXDISPERR0 => open,
    RXDISPERR1 => open,
    RXNOTINTABLE0 => open,
    RXNOTINTABLE1 => open,
    RXRUNDISP0 => open,
    RXRUNDISP1 => open,
    ------------------- Receive Ports - Channel Bonding Ports ------------------
    RXCHANBONDSEQ0 => open,
    RXCHANBONDSEQ1 => open,
    RXCHBONDI0 => tied_to_ground_vec_i(3 downto 0),
    RXCHBONDI1 => tied_to_ground_vec_i(3 downto 0),
    RXCHBONDO0 => open,
    RXCHBONDO1 => open,
    RXENCHANSYNC0 => tied_to_ground_i,
    RXENCHANSYNC1 => tied_to_ground_i,
    ------------------- Receive Ports - Clock Correction Ports -----------------
    RXCLKCORCNT0 => open,
    RXCLKCORCNT1 => open,
    --------------- Receive Ports - Comma Detection and Alignment --------------
    RXBYTEISALIGNED0 => open,
    RXBYTEISALIGNED1 => open,
    RXBYTEREALIGN0 => open,
    RXBYTEREALIGN1 => open,
    RXCOMMADET0 => open,
    RXCOMMADET1 => open,
    RXCOMMADETUSE0 => tied_to_ground_i,
    RXCOMMADETUSE1 => tied_to_ground_i,
    RXENMCOMMAALIGN0 => tied_to_ground_i,
    RXENMCOMMAALIGN1 => tied_to_ground_i,
    RXENPCOMMAALIGN0 => tied_to_ground_i,
    RXENPCOMMAALIGN1 => tied_to_ground_i,
    RXSLIDE0 => tied_to_ground_i,
    RXSLIDE1 => tied_to_ground_i,
    ----------------------- Receive Ports - PRBS Detection ---------------------
    PRBSCNTRESET0 => tied_to_ground_i,
    PRBSCNTRESET1 => tied_to_ground_i,
    RXENPRBSTST0 => tied_to_ground_vec_i(1 downto 0),
    RXENPRBSTST1 => tied_to_ground_vec_i(1 downto 0),
    RXPRBSERR0 => open,
    RXPRBSERR1 => open,
    ------------------- Receive Ports - RX Data Path interface -----------------
    RXDATA0 => open,
    RXDATA1 => open,
    RXDATAWIDTH0 => tied_to_vcc_vec_i(1 downto 0),
    RXDATAWIDTH1 => tied_to_vcc_vec_i(1 downto 0),
    RXRECCLK0 => open,
    RXRECCLK1 => open,
    RXRESET0 => tied_to_ground_i,
    RXRESET1 => tied_to_ground_i,
    RXUSRCLK0 => tied_to_ground_i,
    RXUSRCLK1 => tied_to_ground_i,
    RXUSRCLK20 => tied_to_ground_i,
    RXUSRCLK21 => tied_to_ground_i,
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq,CDR ------
    RXCDRRESET0 => tied_to_ground_i,
    RXCDRRESET1 => tied_to_ground_i,
    RXELECIDLE0 => open,
    RXELECIDLE1 => open,
    RXENEQB0 => tied_to_vcc_i,
    RXENEQB1 => tied_to_vcc_i,
    RXEQMIX0 => tied_to_ground_vec_i(1 downto 0),
    RXEQMIX1 => tied_to_ground_vec_i(1 downto 0),
    RXEQPOLE0 => tied_to_ground_vec_i(3 downto 0),
    RXEQPOLE1 => tied_to_ground_vec_i(3 downto 0),
    RXN0 => rxn0_in,
    RXN1 => rxn1_in,
    RXP0 => rxp0_in,
    RXP1 => rxp1_in,
    -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    RXBUFRESET0 => tied_to_ground_i,
    RXBUFRESET1 => tied_to_ground_i,
    RXBUFSTATUS0 => open,
    RXBUFSTATUS1 => open,
    RXCHANISALIGNED0 => open,
    RXCHANISALIGNED1 => open,
    RXCHANREALIGN0 => open,
    RXCHANREALIGN1 => open,
    RXPMASETPHASE0 => tied_to_ground_i,
    RXPMASETPHASE1 => tied_to_ground_i,
    RXSTATUS0 => open,
    RXSTATUS1 => open,
    --------------- Receive Ports - RX Loss-of-sync State Machine --------------
    RXLOSSOFSYNC0 => open,
    RXLOSSOFSYNC1 => open,
    ---------------------- Receive Ports - RX Oversampling ---------------------
    RXENSAMPLEALIGN0 => tied_to_ground_i,
    RXENSAMPLEALIGN1 => tied_to_ground_i,
    RXOVERSAMPLEERR0 => open,
    RXOVERSAMPLEERR1 => open,
    -------------- Receive Ports - RX Pipe Control for PCI Express -------------
    PHYSTATUS0 => open,
    PHYSTATUS1 => open,
    RXVALID0 => open,
    RXVALID1 => open,
    ----------------- Receive Ports - RX Polarity Control Ports ----------------
    RXPOLARITY0 => tied_to_ground_i,
    RXPOLARITY1 => tied_to_ground_i,
    ------------- Shared Ports - Dynamic Reconfiguration Port => DRP) ------------
    DADDR => tied_to_ground_vec_i(6 downto 0),
    DCLK => tied_to_ground_i,
    DEN => tied_to_ground_i,
    DI => tied_to_ground_vec_i(15 downto 0),
    DO => open,
    DRDY => open,
    DWE => tied_to_ground_i,
    --------------------- Shared Ports - Tile and PLL Ports --------------------
    CLKIN => clkin_in,
    GTXRESET => tied_to_ground_i,
    GTXTEST => tied_to_ground_vec_i(13 downto 0),
    INTDATAWIDTH => tied_to_vcc_i,
    PLLLKDET => open,
    PLLLKDETEN => tied_to_vcc_i,
    PLLPOWERDOWN => tied_to_ground_i,
    REFCLKOUT => open,
    REFCLKPWRDNB => tied_to_vcc_i,
    RESETDONE0 => open,
    RESETDONE1 => open,
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    TXBYPASS8B10B0 => tied_to_ground_vec_i(3 downto 0),
    TXBYPASS8B10B1 => tied_to_ground_vec_i(3 downto 0),
    TXCHARDISPMODE0 => tied_to_ground_vec_i(3 downto 0),
    TXCHARDISPMODE1 => tied_to_ground_vec_i(3 downto 0),
    TXCHARDISPVAL0 => tied_to_ground_vec_i(3 downto 0),
    TXCHARDISPVAL1 => tied_to_ground_vec_i(3 downto 0),
    TXCHARISK0 => tied_to_ground_vec_i(3 downto 0),
    TXCHARISK1 => tied_to_ground_vec_i(3 downto 0),
    TXENC8B10BUSE0 => tied_to_ground_i,
    TXENC8B10BUSE1 => tied_to_ground_i,
    TXKERR0 => open,
    TXKERR1 => open,
    TXRUNDISP0 => open,
    TXRUNDISP1 => open,
    ------------- Transmit Ports - TX Buffering and Phase Alignment ------------
    TXBUFSTATUS0 => open,
    TXBUFSTATUS1 => open,
    ------------------ Transmit Ports - TX Data Path interface -----------------
    TXDATA0 => tied_to_ground_vec_i(31 downto 0),
    TXDATA1 => tied_to_ground_vec_i(31 downto 0),
    TXDATAWIDTH0 => tied_to_vcc_vec_i(1 downto 0),
    TXDATAWIDTH1 => tied_to_vcc_vec_i(1 downto 0),
    TXOUTCLK0 => open,
    TXOUTCLK1 => open,
    TXRESET0 => tied_to_ground_i,
    TXRESET1 => tied_to_ground_i,
    TXUSRCLK0 => tied_to_ground_i,
    TXUSRCLK1 => tied_to_ground_i,
    TXUSRCLK20 => tied_to_ground_i,
    TXUSRCLK21 => tied_to_ground_i,
    --------------- Transmit Ports - TX Driver and OOB signalling --------------
    TXBUFDIFFCTRL0 => tied_to_vcc_vec_i(2 downto 0),
    TXBUFDIFFCTRL1 => tied_to_vcc_vec_i(2 downto 0),
    TXDIFFCTRL0 => tied_to_vcc_vec_i(2 downto 0),
    TXDIFFCTRL1 => tied_to_vcc_vec_i(2 downto 0),
    TXINHIBIT0 => tied_to_ground_i,
    TXINHIBIT1 => tied_to_ground_i,
    TXN0 => txn0_out,
    TXN1 => txn1_out,
    TXP0 => txp0_out,
    TXP1 => txp1_out,
    TXPREEMPHASIS0 => tied_to_vcc_vec_i(3 downto 0),
    TXPREEMPHASIS1 => tied_to_vcc_vec_i(3 downto 0),
    --------------------- Transmit Ports - TX PRBS Generator -------------------
    TXENPRBSTST0 => tied_to_ground_vec_i(1 downto 0),
    TXENPRBSTST1 => tied_to_ground_vec_i(1 downto 0),
    -------------------- Transmit Ports - TX Polarity Control ------------------
    TXPOLARITY0 => tied_to_ground_i,
    TXPOLARITY1 => tied_to_ground_i,
    ----------------- Transmit Ports - TX Ports for PCI Express ----------------
    TXDETECTRX0 => tied_to_ground_i,
    TXDETECTRX1 => tied_to_ground_i,
    TXELECIDLE0 => tied_to_ground_i,
    TXELECIDLE1 => tied_to_ground_i,
    --------------------- Transmit Ports - TX Ports for SATA -------------------
    TXCOMSTART0 => tied_to_ground_i,
    TXCOMSTART1 => tied_to_ground_i,
    TXCOMTYPE0 => tied_to_ground_i,
    TXCOMTYPE1 => tied_to_ground_i);

end behave;

