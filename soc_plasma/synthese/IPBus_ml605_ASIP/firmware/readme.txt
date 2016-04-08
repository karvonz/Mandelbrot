Firmware area repository structure

The repository is divided into two areas. The ipbus firmware is publicly available:

ipbus/ : The core ipbus controller and ipbus fabric
ethernet/ : Ethernet mac implementations for various Xilinx chips
example_designs/ : Simple examples of entire designs using ipbus

There is also a less-public area for various projects using the ipbus.

projects/ : Project areas for designs using the ipbus

Each directory has various subdirectories:

hdl/ : Synthesisable VHDL or verilog source code
sim/ :  Simulation-specific sources or other simulation related files
coregen/ : core directories for Xilinx coregen tool

---

$Id: readme.txt 295 2011-04-24 08:40:38Z phdmn $


