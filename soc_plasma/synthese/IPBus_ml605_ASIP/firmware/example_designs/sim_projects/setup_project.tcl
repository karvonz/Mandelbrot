# Creates a new Questa project for ipbus demo
#
# You will want to amend the path to compiled Xilinx libraries to suit
# your system.
#
# Dave Newbold, April 2011
#
# $Id$

project new ./ ipbus_sim_demo
vmap unisim /opt/dave_xilinx_lib/ise13.1/unisim
vmap unimacro /opt/dave_xilinx_lib/ise13.1/unimacro
vmap secureip /opt/dave_xilinx_lib/ise13.1/secureip
vmap xilinxcorelib /opt/dave_xilinx_lib/ise13.1/xilinxcorelib
project addfile firmware/ipbus/hdl/ipbus_package.vhd
project addfile firmware/example_designs/sim_hdl/clock_sim.vhd
project addfile firmware/example_designs/hdl/slaves.vhd
project addfile firmware/example_designs/hdl/ipbus_addr_decode.vhd
project addfile firmware/ethernet/sim/eth_mac_sim.vhd
project addfile firmware/ipbus/hdl/arp.v
project addfile firmware/ipbus/hdl/gbe_rxpacketbuffer.v
project addfile firmware/ipbus/hdl/gbe_txpacketbuffer.v
project addfile firmware/ipbus/hdl/icmp.v
project addfile firmware/ipbus/hdl/ipbus_fabric.vhd
project addfile firmware/ipbus/hdl/ipbus_ctrl.vhd
project addfile firmware/ipbus/hdl/ipbus_ctrl_decl.vhd
project addfile firmware/ipbus/hdl/ip_checksum_8bit.v
project addfile firmware/ipbus/hdl/packet_handler.v
project addfile firmware/ipbus/hdl/sub_packetbuffer.v
project addfile firmware/ipbus/hdl/sub_packetreq.v
project addfile firmware/ipbus/hdl/sub_packetresp.v
project addfile firmware/ipbus/hdl/transactor_rx.vhd
project addfile firmware/ipbus/hdl/transactor_sm.vhd
project addfile firmware/ipbus/hdl/transactor_tx.vhd
project addfile firmware/ipbus/hdl/transactor.vhd
project addfile firmware/ipbus/hdl/slaves/ipbus_reg.vhd
project addfile firmware/ipbus/hdl/slaves/ipbus_ram.vhd
project addfile firmware/ipbus/hdl/slaves/ipbus_ctr.vhd
project addfile firmware/ipbus/coregen/dpbr8.vhd
project addfile firmware/ipbus/coregen/dpbr_8_32.vhd
project addfile firmware/example_designs/sim_hdl/top_sim.vhd
project calculateorder
project close
