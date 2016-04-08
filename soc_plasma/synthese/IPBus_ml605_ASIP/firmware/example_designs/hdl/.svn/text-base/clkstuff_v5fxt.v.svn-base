`timescale 1ns / 1ps

module clkstuff_v5(
    input clki,
    output clko125,
	 output clko200,
	 output clko25,
    output locked,
	 output rsto
    );

	wire clk125_int, rst, clk25_int;

	assign rsto = ~rst;

	BUFG BUFG_clko (
		.O(clko125),
		.I(clk125_int)	);
	
	BUFG BUFG_clkd4 (
		.O(clko25),
		.I(clk25_int)
	);

	DCM_BASE #(
		.CLKFX_DIVIDE(4),		.CLKFX_MULTIPLY(5),
		.CLKDV_DIVIDE(4),
		.CLKIN_PERIOD(10.0),
		.CLK_FEEDBACK("NONE"),
		.DFS_FREQUENCY_MODE("LOW"),		.DLL_FREQUENCY_MODE("LOW"),
		.STARTUP_WAIT("TRUE")	) DCM_0 (
		.CLKFX(clk125_int),
		.CLK2X(clko200),
		.CLKDV(clk25_int),
		.LOCKED(locked),
		.CLKIN(clki),
		.RST(~rst)
	);

	SRL16 sr16_reset (
		.A3(1'b1), .A2(1'b1), .A1(1'b1), .A0(1'b1),
		.CLK(clki),
		.D(1'b1),
		.Q(rst)
	);

endmodule
