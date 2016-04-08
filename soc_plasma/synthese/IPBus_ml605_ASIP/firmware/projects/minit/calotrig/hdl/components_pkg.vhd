--
-- VHDL Package Header TMCaloTrigger_lib.components
--
-- Created:
--          by - awr01.UNKNOWN (SINBADPC)
--          at - 10:51:28 25/02/2010
--
-- using Mentor Graphics HDL Designer(TM) 2006.1 (Build 72)
--

LIBRARY ieee;
LIBRARY TMCaloTrigger_lib;

USE ieee.std_logic_1164.all;
use TMCaloTrigger_lib.constants.all;
use TMCaloTrigger_lib.types.all;
use TMCaloTrigger_lib.linkinterface.all;


PACKAGE components IS


	COMPONENT TowerLinearizer is
	port(
		async_reset:		IN	STD_LOGIC;
		clk:				IN	STD_LOGIC;
		ecallut_address:	IN	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		ecallut_data:		IN	STD_LOGIC_VECTOR( 15 DOWNTO 0 );
		ecallut_clk:		IN	std_logic;
		ecallut_enable:		IN	std_logic;
		hcallut_address:	IN	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		hcallut_data:		IN	STD_LOGIC_VECTOR( 15 DOWNTO 0 );
		hcallut_clk:		IN	std_logic;
		hcallut_enable:		IN	std_logic;
		link_in:			IN	link_type;
		linearized_towers:	OUT tLinearTowers
	);
	end COMPONENT TowerLinearizer;

	COMPONENT Comparitor IS
		PORT(
			async_reset:	IN	STD_LOGIC;
			clk:			IN	STD_LOGIC;
			threshold:		IN	STD_LOGIC_VECTOR( cLinearizedWidth-1 DOWNTO 0 );
			data_in:		IN	STD_LOGIC_VECTOR( cLinearizedWidth-1 DOWNTO 0 );
			data_out:		OUT	STD_LOGIC_VECTOR( cLinearizedWidth-1 DOWNTO 0 )
		);
	END COMPONENT Comparitor;


	COMPONENT ETAdder IS
		GENERIC(
			inputwidth:		INTEGER
		);
		PORT(
			async_reset:	IN	STD_LOGIC;
			clk:			IN	STD_LOGIC;
			ET1in:			IN	STD_LOGIC_VECTOR( inputwidth-1 DOWNTO 0 );
			ET2in:			IN	STD_LOGIC_VECTOR( inputwidth-1 DOWNTO 0 );
			data_out:		OUT	STD_LOGIC_VECTOR( inputwidth DOWNTO 0 )
		);
	END COMPONENT ETAdder;


	COMPONENT ClusterWeight is
	port(
		async_reset:		IN	STD_LOGIC;
		clk:				IN	STD_LOGIC;
		north_or_west:		IN	STD_LOGIC_VECTOR( cLinearizedWidth+1 DOWNTO 0 );
		south_or_east:		IN	STD_LOGIC_VECTOR( cLinearizedWidth+1 DOWNTO 0 );
		region2x2:			IN	STD_LOGIC_VECTOR( cLinearizedWidth+2 DOWNTO 0 );
		weight:				OUT	STD_LOGIC_VECTOR( 1 DOWNTO 0 )
	);
	end COMPONENT ClusterWeight;

	
-- THIS IS CURRENTLY A PLACEHOLDER AND NEEDS COMPLETION
	COMPONENT EPIM is
		port(
			async_reset:			IN	STD_LOGIC;
			clk:					IN	STD_LOGIC;
			TargetGreaterSelect:	IN	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			TargetLesserSelect:		IN	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			LUTSelect:				IN	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			EandH:					IN	t2x2Sums;
			ET:						IN	STD_LOGIC_VECTOR( cLinearizedWidth+2 DOWNTO 0 );
			pass:					OUT	STD_LOGIC;
			epimlut_address:		IN	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			epimlut_data:			IN	STD_LOGIC_VECTOR( 15 DOWNTO 0 );
			epimlut_clk:			IN	std_logic;
			epimlut_enable:			IN	std_logic
		);
	end COMPONENT EPIM;	
-- THIS IS CURRENTLY A PLACEHOLDER AND NEEDS COMPLETION



	COMPONENT ClusterOverlapFilter is
		port(
			async_reset:		IN	STD_LOGIC;
			clk:				IN	STD_LOGIC;
			filterRegion:		IN	tFilterRegion;
			filterMask:			OUT	tFilterMask
		);
	end COMPONENT ClusterOverlapFilter;

	
	
	COMPONENT TowerPruning is
		port(
			async_reset:		IN	STD_LOGIC;
			clk:				IN	STD_LOGIC;
			threshold:			IN	STD_LOGIC_VECTOR( cLinearizedWidth+2 DOWNTO 0 );
			filterMask:			IN	tFilterMask;
			north1x1:			IN	tEHSums;
			south1x1:			IN	tEHSums;
			north2x1:			IN	STD_LOGIC_VECTOR( cLinearizedWidth+1 DOWNTO 0 );
			south2x1:			IN	STD_LOGIC_VECTOR( cLinearizedWidth+1 DOWNTO 0 );
			filteredCluster:	OUT	tFilteredCluster
		);
	end COMPONENT TowerPruning;	

	
	-- COMPONENT sorter IS
	-- GENERIC(
		-- level:			INTEGER
	-- );
	-- PORT(
		-- clk:			IN 	STD_LOGIC;
		-- data_in:		IN	aSortedCluster;
		-- data_out:		OUT	aSortedCluster
	-- );
	-- END COMPONENT sorter;

	
	COMPONENT sorter2 IS
	GENERIC(
		inputs:			integer;
		outputs:		integer
	);
	PORT(
		async_reset:	IN	STD_LOGIC;
		clk:			IN	STD_LOGIC;
		-- data_in:		IN	aSortedCluster( (2*cNumberOfLinks)-1 downto 0 );
		-- data_out:		OUT	aSortedCluster( cClustersPerPhi-1 DOWNTO 0 )
		data_in:		IN	aSortedCluster( inputs-1 downto 0 );
		data_out:		OUT	aSortedCluster( outputs-1 DOWNTO 0 )
	);
	END COMPONENT sorter2;
	
	
	
	COMPONENT sorter3 IS
	GENERIC(
		inputs:			integer;
		outputs:		integer
	);
	PORT(
		async_reset:	IN	STD_LOGIC;
		clk:			IN	STD_LOGIC;
		data_in:		IN	aSortedCluster( inputs-1 downto 0 );
		data_out:		OUT	aSortedCluster( outputs-1 DOWNTO 0 )
	);
	END COMPONENT sorter3;
	
	-- COMPONENT cluster1d is
		-- PORT(
			-- async_reset		:	IN	STD_LOGIC;
			-- clk				:	IN	STD_LOGIC;
			-- distance		:	IN	STD_LOGIC_VECTOR( 3 DOWNTO 0 ) ;
			-- SortedClusters	:	IN	aSortedCluster( cClustersPerPhi-1 DOWNTO 0 );
			-- ClusterFlags	:	OUT	aClusterFlag
		-- );
	-- end COMPONENT cluster1d;	
	
	-- COMPONENT clustercnt is
		-- PORT(
			-- async_reset:	IN	STD_LOGIC;
			-- clk:			IN	STD_LOGIC;
			-- clustersIn:		IN	aSortedCluster(cJetSize-2 downto 0);
			-- jet1Dout:		OUT tJet1D
		-- );
	-- end COMPONENT clustercnt;	
	
END components;
