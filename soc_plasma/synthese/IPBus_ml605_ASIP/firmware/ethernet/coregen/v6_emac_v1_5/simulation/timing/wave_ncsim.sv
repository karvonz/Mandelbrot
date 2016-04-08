# SimVision Command Script

#
# groups
#
if {[catch {group new -name {System Signals} -overlay 0}] != ""} {
    group using {System Signals}
    group set -overlay 0
    group set -comment {}
    group clear 0 end
}
group insert \
    :reset \
    :gtx_clk \
    :host_clk

if {[catch {group new -name {TX Client Interface} -overlay 0}] != ""} {
    group using {TX Client Interface}
    group set -overlay 0
    group set -comment {}
    group clear 0 end
}
group insert \
    :dut:tx_clk \
    :dut:v6_emac_v1_5_locallink_inst_tx_data_i \
    :dut:v6_emac_v1_5_locallink_inst_tx_data_valid_i \
    :dut:v6_emac_v1_5_locallink_inst_tx_ack_i \
    :tx_ifg_delay

if {[catch {group new -name {RX Client Interface} -overlay 0}] != ""} {
    group using {RX Client Interface}
    group set -overlay 0
    group set -comment {}
    group clear 0 end
}
group insert \
    :dut:rx_clk_i \
    :dut:v6_emac_v1_5_locallink_inst_rx_data_i \
    :dut:EMACCLIENTRXDVLD \
    :dut:v6_emac_v1_5_locallink_inst_rx_good_frame_i \
    :dut:v6_emac_v1_5_locallink_inst_rx_bad_frame_i

if {[catch {group new -name {Flow Control} -overlay 0}] != ""} {
    group using {Flow Control}
    group set -overlay 0
    group set -comment {}
    group clear 0 end
}
group insert \
    :pause_val \
    :pause_req

if {[catch {group new -name {TX GMII/MII Interface} -overlay 0}] != ""} {
    group using {TX GMII/MII Interface}
    group set -overlay 0
    group set -comment {}
    group clear 0 end
}
group insert \
    :gmii_tx_clk \
    :gmii_txd \
    :gmii_tx_en \
    :gmii_tx_er 
if {[catch {group new -name {RX GMII/MII Interface} -overlay 0}] != ""} {
    group using {RX GMII/MII Interface}
    group set -overlay 0
    group set -comment {}
    group clear 0 end
}
group insert \
    :gmii_rx_clk \
    :gmii_rxd \
    :gmii_rx_dv \
    :gmii_rx_er


if {[catch {group new -name {Test semaphores} -overlay 0}] != ""} {
    group using {Test semaphores}
    group set -overlay 0
    group set -comment {}
    group clear 0 end
}
group insert \
    :configuration_busy \
    :monitor_finished_1g \
    :monitor_finished_100m \
    :monitor_finished_10m
#
# Waveform windows
#
if {[window find -match exact -name "Waveform 1"] == {}} {
    window new WaveWindow -name "Waveform 1" -geometry 906x585+25+55
} else {
    window geometry "Waveform 1" 906x585+25+55
}
window target "Waveform 1" on
waveform using {Waveform 1}
waveform sidebar visibility partial
waveform set \
    -primarycursor TimeA \
    -signalnames name \
    -signalwidth 175 \
    -units fs \
    -valuewidth 75
cursor set -using TimeA -time 50,000,000,000fs
cursor set -using TimeA -marching 1
waveform baseline set -time 0

set id [waveform add -signals [list :reset \
 :gtx_clk ]]

set groupId [waveform add -groups {{System Signals}}]

set groupId [waveform add -groups {{TX Client Interface}}]

set groupId [waveform add -groups {{RX Client Interface}}]

set groupId [waveform add -groups {{TX GMII/MII Interface}}]

set groupId [waveform add -groups {{RX GMII/MII Interface}}]


set groupId [waveform add -groups {{Management Interface}}]

set groupId [waveform add -groups {{Test semaphores}}]

waveform xview limits 0fs 10us

simcontrol run -time 2000us

