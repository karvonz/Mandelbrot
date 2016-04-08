--
-- VHDL Architecture TMCaloTrigger_lib.AlgorithmTop.AlgorithmTop
--
-- Created:
--          by - awr01.UNKNOWN (SINBADPC)
--          at - 09:43:47 25/02/2010
--
-- using Mentor Graphics HDL Designer(TM) 2006.1 (Build 72)
--
LIBRARY ieee;
LIBRARY TMCaloTrigger_lib;

USE ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use TMCaloTrigger_lib.components.all;
use TMCaloTrigger_lib.constants.all;
use TMCaloTrigger_lib.types.all;
--use TMCaloTrigger_lib.usefuls.all;
use TMCaloTrigger_lib.linkinterface.all;

LIBRARY STD;
USE STD.TEXTIO.ALL;


-- ------------------------------------------------------------------------------------------------------------------------------------------------------------
ENTITY AlgorithmTop IS
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------
	PORT(
--TEMPORARY FOR TESTBENCH AND TO MAKE SYNTHESIS INCLUDE EVERYTHING	
-- notpragma nottranslate_off
		OutLinearTowers				: out aLinearTowers;
		OutZeroedTowers	 			: out aLinearTowers;
		OutEHSum					: out aEHSums;
		OutPipe2x1SumA				: out a2x1Sums;
		OutPipe2x1SumB				: out a2x1Sums;
		OutPipe2x1ETSumA			: out a2x1ETSums;
		OutPipe2x1ETSumB			: out a2x1ETSums;
		OutPipe1x2ETSumA			: out a2x1ETSums;
		OutPipe1x2ETSumB			: out a2x1ETSums;
		OutPipe2x2SumA				: out a2x2Sums;
		OutPipe2x2SumB				: out a2x2Sums;
		OutPipe2x2ETSumA			: out a2x2ETSums;
		OutPipe2x2ETSumB			: out a2x2ETSums;
		OutPipeEPIMA				: out aEPIMs;
		OutPipeEPIMB				: out aEPIMs;
		OutPipeFilterMaskA			: out aFilterMask;
		OutPipeFilterMaskB			: out aFilterMask;
		OutPipeClusterPositionA		: out aClusterPosition;
		OutPipeClusterPositionB		: out aClusterPosition;
		OutPipeFilteredClusterA		: out aFilteredCluster;
		OutPipeFilteredClusterB		: out aFilteredCluster;

		-- notpragma nottranslate_on

		OutClusterSorting			: out aSortedCluster( (2*cNumberOfLinks)-1 downto 0 );
		-- -- OutSortedCluster			: out aSortedCluster( (2**cBitonicWidth)-1 downto 0 );
		OutPipeSortedCluster		: out aSortedCluster( cClustersPerPhi-1 DOWNTO 0 );
		-- OutPipeClusterFlag 			: out aClusterFlag;

		-- OutPipeJF1D 				: out aJet1D;
		

		
		epimlut_address:			IN	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		epimlut_data:				IN	STD_LOGIC_VECTOR( 15 DOWNTO 0 );
		epimlut_cl0ck:				IN	std_logic;
		epimlut_enable:				IN	std_logic;

		ecallut_address:			IN	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		ecallut_data:				IN	STD_LOGIC_VECTOR( 15 DOWNTO 0 );
		ecallut_cl0ck:				IN	std_logic;
		ecallut_enable:				IN	std_logic;

		hcallut_address:			IN	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		hcallut_data:				IN	STD_LOGIC_VECTOR( 15 DOWNTO 0 );
		hcallut_cl0ck:				IN	std_logic;
		hcallut_enable:				IN	std_logic;

		-- jfradiuslut_address:		IN	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		-- jfradiuslut_data:			IN	STD_LOGIC_VECTOR( 15 DOWNTO 0 );
		-- jfradiuslut_cl0ck:			IN	std_logic;
		-- jfradiuslut_enable:			IN	std_logic;
		
		
		clk_160		: in STD_LOGIC;
		sync_reset_b	: in STD_LOGIC := '0';
		
		--links_in	: in aLinearTowers
		links_in	: in all_links((cNumberOfLinks-1) DOWNTO 0)
	);
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------
END ENTITY AlgorithmTop;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------




-- ------------------------------------------------------------------------------------------------------------------------------------------------------------
ARCHITECTURE AlgorithmTop OF AlgorithmTop IS
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------
	
-- Set as constants (in this case "4"), would be configurable registers in real system	
	CONSTANT cEcalThreshold		:	STD_LOGIC_VECTOR( cLinearizedWidth-1 DOWNTO 0 ) := std_logic_vector( to_unsigned( 4 , cLinearizedWidth ) );
	CONSTANT cHcalThreshold		:	STD_LOGIC_VECTOR( cLinearizedWidth-1 DOWNTO 0 ) := std_logic_vector( to_unsigned( 4 , cLinearizedWidth ) );

-- For EPIM, would be configurable registers in real system	
	-- ET = "11"
	-- EandH.HCAL = "10"
	-- EandH.ECAL = "01"
	-- epimlut_output (cannot be used for cLUTSelect) = "00";
	CONSTANT cLUTSelect				:	STD_LOGIC_VECTOR( 1 DOWNTO 0 ) := "11";
	CONSTANT cTargetGreaterSelect	:	STD_LOGIC_VECTOR( 1 DOWNTO 0 ) := "01";
	CONSTANT cTargetLesserSelect	:	STD_LOGIC_VECTOR( 1 DOWNTO 0 ) := "00";
	
-- Set as constants (in this case "8"), would be configurable registers in real system	
	CONSTANT cClusterThreshold	:	STD_LOGIC_VECTOR( cLinearizedWidth+2 DOWNTO 0 ) := std_logic_vector( to_unsigned( 8 , cLinearizedWidth+3 ) );

-- Set as constants (in this case "6"), would be configurable registers in real system	
	-- CONSTANT cJetRadius	:	STD_LOGIC_VECTOR( 3 DOWNTO 0 ) := std_logic_vector( to_unsigned( 6 , 4 ) );
	
-- Counter for keeping track of frame number
--	SIGNAL frameCounter : STD_LOGIC_VECTOR( 5 DOWNTO 0 ) := (others => '0');
	-- SIGNAL frameCounter : INTEGER := 0;

	
-- Create a pipe to hold the sync_reset. NB clocked at 160MHz 	
	SIGNAL syncResetPipe : tSyncResetPipe := (OTHERS=>'1')	;
-- Create a pipe to hold the Zeroed Links. NB clocked at 160MHz 	
	SIGNAL LinearTowersPipe : tLinearTowersPipe := (OTHERS=>(OTHERS=>(OTHERS=>(OTHERS=>'0'))));
-- Create a pipe to hold the Zeroed Links. NB clocked at 160MHz 	
	SIGNAL ZeroedTowersPipe : tZeroedTowersPipe := (OTHERS=>(OTHERS=>(OTHERS=>(OTHERS=>'0'))));
-- Create a pipe to hold the E+H Sums. NB clocked at 160MHz 	
	SIGNAL EHSumPipe : tEHSumPipe := (OTHERS=>(OTHERS=>(OTHERS=>(OTHERS=>'0'))));
-- Create pipes to hold the 2x1 Region Sums. NB clocked at 160MHz
	SIGNAL Pipe2x1SumA : t2x1SumPipe := (OTHERS=>(OTHERS=>(OTHERS=>(OTHERS=>'0'))));
	SIGNAL Pipe2x1SumB : t2x1SumPipe := (OTHERS=>(OTHERS=>(OTHERS=>(OTHERS=>'0'))));
	SIGNAL input2x1 : aLinearTowers := (OTHERS=>(OTHERS=>(OTHERS=>'0')));
-- Create pipes to hold the 2x1 ET Sums. NB clocked at 160MHz
	SIGNAL Pipe2x1ETSumA : t2x1ETSumPipe := (OTHERS=>(OTHERS=>(OTHERS=>'0')));
	SIGNAL Pipe2x1ETSumB : t2x1ETSumPipe := (OTHERS=>(OTHERS=>(OTHERS=>'0')));
	SIGNAL Pipe1x2ETSumA : t2x1ETSumPipe := (OTHERS=>(OTHERS=>(OTHERS=>'0')));
	SIGNAL Pipe1x2ETSumB : t2x1ETSumPipe := (OTHERS=>(OTHERS=>(OTHERS=>'0')));
-- Create pipes to hold the 2x2 Region Sums. NB clocked at 160MHz
	SIGNAL Pipe2x2SumA : t2x2SumPipe := (OTHERS=>(OTHERS=>(OTHERS=>(OTHERS=>'0'))));
	SIGNAL Pipe2x2SumB : t2x2SumPipe := (OTHERS=>(OTHERS=>(OTHERS=>(OTHERS=>'0'))));
	SIGNAL input2x2A : a2x1Sums := (OTHERS=>(OTHERS=>(OTHERS=>'0')));
	SIGNAL input2x2B : a2x1Sums := (OTHERS=>(OTHERS=>(OTHERS=>'0')));
	SIGNAL input2x2C : a2x1Sums := (OTHERS=>(OTHERS=>(OTHERS=>'0')));
	SIGNAL input2x2D : a2x1Sums := (OTHERS=>(OTHERS=>(OTHERS=>'0')));
-- Create pipes to hold the 2x2 ET Sums. NB clocked at 160MHz
	SIGNAL Pipe2x2ETSumA : t2x2ETSumPipe := (OTHERS=>(OTHERS=>(OTHERS=>'0')));
	SIGNAL Pipe2x2ETSumB : t2x2ETSumPipe := (OTHERS=>(OTHERS=>(OTHERS=>'0')));
-- Create pipes to hold the Cluster Positions. NB clocked at 160MHz
	SIGNAL PipeClusterPositionA : tClusterPositionPipe := (OTHERS=>(OTHERS=>(OTHERS=>(OTHERS=>'0'))));
	SIGNAL PipeClusterPositionB : tClusterPositionPipe := (OTHERS=>(OTHERS=>(OTHERS=>(OTHERS=>'0'))));
-- Create pipes to hold the Cluster EPIM bits. NB clocked at 160MHz
	SIGNAL PipeEPIMA : tEPIMPipe := (OTHERS=>(OTHERS=>'0'));
	SIGNAL PipeEPIMB : tEPIMPipe := (OTHERS=>(OTHERS=>'0'));
-- Create pipes to hold the Filter Masks. NB clocked at 160MHz
	SIGNAL PipeFilterMaskA : tFilterMaskPipe := (OTHERS=>(OTHERS=>(OTHERS=>'0')));
	SIGNAL PipeFilterMaskB : tFilterMaskPipe := (OTHERS=>(OTHERS=>(OTHERS=>'0')));
	SIGNAL inputFilterRegionA : aFilterRegion:= (OTHERS=>(OTHERS=>(OTHERS=>'0')));
	SIGNAL inputFilterRegionB : aFilterRegion:= (OTHERS=>(OTHERS=>(OTHERS=>'0')));
-- Create pipes to hold the Filtered Clusters. NB clocked at 160MHz
	SIGNAL PipeFilteredClusterA : tFilteredClusterPipe := (OTHERS=>(OTHERS=>( '0' , (OTHERS=>'0') , "0" )));
	SIGNAL PipeFilteredClusterB : tFilteredClusterPipe := (OTHERS=>(OTHERS=>( '0' , (OTHERS=>'0') , "0" )));
-- Create pipes to hold the Sorted Filtered Clusters. NB clocked at 160MHz
	SIGNAL PipeSortedCluster : tSortedClusterPipe(depthSortedClusterPipe-1 downto 0) := (others=>(others=>(('0' , (others=>'0') , (others=>'0')) , ( (others=>'0') , (others=>'0') ) , (others=>'0') , (others=>'0') )));
	-- SIGNAL PipeClusterFlag : tClusterFlagPipe := (OTHERS=>(OTHERS=>(OTHERS=>'0')));

	-- SIGNAL PipeJF1D : tJet1DPipe; -- := (OTHERS=>(OTHERS=>(OTHERS=>(OTHERS=>'0'))));
	
	
-- -----------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------
-- Intermediate signals 	
-- -----------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------
	
	SIGNAL inputnorth1x1B:	aEHSums		:= (OTHERS=>(OTHERS=>(OTHERS=>'0')));	
	SIGNAL inputsouth1x1B:	aEHSums		:= (OTHERS=>(OTHERS=>(OTHERS=>'0')));	

-- for sorter 1	
	-- SIGNAL inputClusterSorting:	aSortedCluster( (2**cBitonicWidth)-1 downto 0 ) := (others=>(('0' , (others=>'0') , (others=>'0')) , ( (others=>'0') , (others=>'0') ) , (others=>'0') , (others=>'0') ));
	-- SIGNAL sortedClusters:		aSortedCluster( (2**cBitonicWidth)-1 downto 0 ) := (others=>(('0' , (others=>'0') , (others=>'0')) , ( (others=>'0') , (others=>'0') ) , (others=>'0') , (others=>'0') ));
-- for sorters 2 & 3
	SIGNAL inputClusterSorting:	aSortedCluster( (2*cNumberOfLinks)-1 downto 0 ) := (others=>(('0' , (others=>'0') , (others=>'0')) , ( (others=>'0') , (others=>'0') ) , (others=>'0') , (others=>'0') ));
	SIGNAL semiSortedClusters:		aSortedCluster( (2*cClustersPerPhi)-1 downto 0 ) := (others=>(('0' , (others=>'0') , (others=>'0')) , ( (others=>'0') , (others=>'0') ) , (others=>'0') , (others=>'0') ));

-- for JF	
	-- SIGNAL inputClusterSorting:	aSortedCluster( (2*cNumberOfLinks)-1 downto 0 ) := (others=>(('0' , (others=>'0') , (others=>'0')) , ( (others=>'0') , (others=>'0') ) , (others=>'0') , (others=>'0') ));

	
	-- ------------------------------------------------------------------------------------------------------------------------------------------------------------
BEGIN
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------

	-- Clock the pipes
	syncResetPipe(0) <= NOT sync_reset_b; --when	rising_edge(clk_160);
	gSyncResetPipe : FOR i IN (depthSyncResetPipe-1) DOWNTO 1 GENERATE
		syncResetPipe(i) <= syncResetPipe(i-1)	when	rising_edge(clk_160);
	END GENERATE gSyncResetPipe;

	gLinearTowersPipe : FOR i IN (depthLinearTowersPipe-1) DOWNTO 1 GENERATE
		LinearTowersPipe(i) <= LinearTowersPipe(i-1)	when	rising_edge(clk_160);
	END GENERATE gLinearTowersPipe;
	
	gZeroedTowersPipe : FOR i IN (depthZeroedTowersPipe-1) DOWNTO 1 GENERATE
		ZeroedTowersPipe(i) <= ZeroedTowersPipe(i-1)	when	rising_edge(clk_160);
	END GENERATE gZeroedTowersPipe;

	gEHSumPipe : FOR i IN (depthEHSumPipe-1) DOWNTO 1 GENERATE
		EHSumPipe(i) <= EHSumPipe(i-1)	when	rising_edge(clk_160);
	END GENERATE gEHSumPipe;

	g2x1SumPipe : FOR i IN (depth2x1SumPipe-1) DOWNTO 1 GENERATE
		Pipe2x1SumA(i) <= Pipe2x1SumA(i-1)	when	rising_edge(clk_160);
		Pipe2x1SumB(i) <= Pipe2x1SumB(i-1)	when	rising_edge(clk_160);
	END GENERATE g2x1SumPipe;

	g2x1ETSumPipe : FOR i IN (depth2x1ETSumPipe-1) DOWNTO 1 GENERATE
		Pipe2x1ETSumA(i) <= Pipe2x1ETSumA(i-1)	when	rising_edge(clk_160);
		Pipe2x1ETSumB(i) <= Pipe2x1ETSumB(i-1)	when	rising_edge(clk_160);

		Pipe1x2ETSumA(i) <= Pipe1x2ETSumA(i-1)	when	rising_edge(clk_160);
		Pipe1x2ETSumB(i) <= Pipe1x2ETSumB(i-1)	when	rising_edge(clk_160);
	END GENERATE g2x1ETSumPipe;
	
	g2x2SumPipe : FOR i IN (depth2x2SumPipe-1) DOWNTO 1 GENERATE
		Pipe2x2SumA(i) <= Pipe2x2SumA(i-1)	when	rising_edge(clk_160);
		Pipe2x2SumB(i) <= Pipe2x2SumB(i-1)	when	rising_edge(clk_160);
	END GENERATE g2x2SumPipe;
	
	g2x2ETSumPipe : FOR i IN (depth2x2ETSumPipe-1) DOWNTO 1 GENERATE
		Pipe2x2ETSumA(i) <= Pipe2x2ETSumA(i-1)	when	rising_edge(clk_160);
		Pipe2x2ETSumB(i) <= Pipe2x2ETSumB(i-1)	when	rising_edge(clk_160);
	END GENERATE g2x2ETSumPipe;
	
	gClusterPositionPipe : FOR i IN (depthClusterPositionPipe-1) DOWNTO 1 GENERATE
		PipeClusterPositionA(i) <= PipeClusterPositionA(i-1)	when	rising_edge(clk_160);
		PipeClusterPositionB(i) <= PipeClusterPositionB(i-1)	when	rising_edge(clk_160);
	END GENERATE gClusterPositionPipe;

	gEPIMPipe : FOR i IN (depthEPIMPipe-1) DOWNTO 1 GENERATE
		PipeEPIMA(i) <= PipeEPIMA(i-1)	when	rising_edge(clk_160);
		PipeEPIMB(i) <= PipeEPIMB(i-1)	when	rising_edge(clk_160);
	END GENERATE gEPIMPipe;

	gFilterMaskPipe : FOR i IN (depthFilterMaskPipe-1) DOWNTO 1 GENERATE
		PipeFilterMaskA(i) <= PipeFilterMaskA(i-1)	when	rising_edge(clk_160);
		PipeFilterMaskB(i) <= PipeFilterMaskB(i-1)	when	rising_edge(clk_160);
	END GENERATE gFilterMaskPipe;

	gFilteredClusterPipe : FOR i IN (depthFilteredClusterPipe-1) DOWNTO 1 GENERATE
		PipeFilteredClusterA(i) <= PipeFilteredClusterA(i-1)	when	rising_edge(clk_160);
		PipeFilteredClusterB(i) <= PipeFilteredClusterB(i-1)	when	rising_edge(clk_160);
	END GENERATE gFilteredClusterPipe;
	
	gSortedClusterPipe : FOR i IN (depthSortedClusterPipe-1) DOWNTO 1 GENERATE
		PipeSortedCluster(i) <= PipeSortedCluster(i-1)	when	rising_edge(clk_160);
	END GENERATE gSortedClusterPipe;
	
	-- gClusterFlagPipe : FOR i IN (depthClusterFlagPipe-1) DOWNTO 1 GENERATE
		-- PipeClusterFlag(i) <= PipeClusterFlag(i-1)	when	rising_edge(clk_160);
	-- END GENERATE gClusterFlagPipe;

	-- gJF1DPipe : FOR i IN (cJetSize-2) DOWNTO 1 GENERATE
		-- PipeJF1D(i) <= PipeJF1D(i-1)	when	rising_edge(clk_160);
	-- END GENERATE gJF1DPipe;
	

	
--TEMPORARY FOR TESTBENCH AND TO MAKE SYNTHESIS INCLUDE EVERYTHING	
-- notpragma nottranslate_off

	OutLinearTowers <= LinearTowersPipe(0);
	OutZeroedTowers <= ZeroedTowersPipe(0);
	OutEHSum <= EHSumPipe(0);
	OutPipe2x1SumA <= Pipe2x1SumA(0);
	OutPipe2x1SumB <= Pipe2x1SumB(0);
	OutPipe2x1ETSumA <= Pipe2x1ETSumA(0);
	OutPipe2x1ETSumB <= Pipe2x1ETSumB(0);
	OutPipe1x2ETSumA <= Pipe1x2ETSumA(0);
	OutPipe1x2ETSumB <= Pipe1x2ETSumB(0);
	OutPipe2x2SumA <= Pipe2x2SumA(0);
	OutPipe2x2SumB <= Pipe2x2SumB(0);
	OutPipe2x2ETSumA <= Pipe2x2ETSumA(0);
	OutPipe2x2ETSumB <= Pipe2x2ETSumB(0);
	OutPipeEPIMA <= PipeEPIMA(0);
	OutPipeEPIMB <= PipeEPIMB(0);
	OutPipeFilterMaskA <= PipeFilterMaskA(0);
	OutPipeFilterMaskB <= PipeFilterMaskB(0);
	OutPipeClusterPositionA	<= PipeClusterPositionA(0);
	OutPipeClusterPositionB	<= PipeClusterPositionB(0);
	OutClusterSorting( (2*cNumberOfLinks)-1 downto 0 ) <= inputClusterSorting( (2*cNumberOfLinks)-1 downto 0 );
	-- OutSortedCluster <= sortedClusters;
	OutPipeFilteredClusterA <= PipeFilteredClusterA(0);
	OutPipeFilteredClusterB <= PipeFilteredClusterB(0);
-- notpragma nottranslate_on
	-- OutPipeJF1D <= PipeJF1D(0);

	OutPipeSortedCluster <= PipeSortedCluster(0);
	-- OutPipeClusterFlag <= PipeClusterFlag(0);

	

	
	

	-- Counter to keep track of the frame number
	-- PROCESS ( clk_160 ) 
	-- BEGIN
		-- IF ( rising_edge(clk_160) ) THEN
			-- IF ( sync_reset_b='0' ) THEN
				-- --frameCounter <= (others => '0');
				-- frameCounter <= 0;
			-- ELSE
				--frameCounter <= std_logic_vector( to_unsigned( to_integer( unsigned(frameCounter) ) + 1 , 6 )); 
				-- frameCounter <= frameCounter+1;				
			-- END IF;
		-- END IF;
	-- END PROCESS;

	
	gLinearize : FOR i IN (cNumberOfLinks-1) DOWNTO 0 GENERATE
		linearizer : entity TMCaloTrigger_lib.TowerLinearizer(V5)
		port map (
			async_reset			=>	syncResetPipe(offsetLinearTowersPipe),
			clk					=>	clk_160,
			ecallut_address		=>	ecallut_address,
			ecallut_data		=>	ecallut_data,
			ecallut_clk			=>	ecallut_cl0ck,
			ecallut_enable		=>	ecallut_enable,
			hcallut_address		=>	hcallut_address,
			hcallut_data		=>	hcallut_data,
			hcallut_clk			=>	hcallut_cl0ck,
			hcallut_enable		=>	hcallut_enable,
			link_in				=>	links_in(i),
			linearized_towers	=>	LinearTowersPipe(0)(i)
 		);
	END GENERATE gLinearize;

	
	-- Run the comparitors and clock into the 0'th element of the Zeroed Link pipe
	-- First clocks into the pipe	when	syncResetPipe is at 0
	gComparitor : FOR i IN (cNumberOfLinks-1) DOWNTO 0 GENERATE
		ComparitorECALA: Comparitor
		port map (
			clk		=>	clk_160,
			async_reset	=>	syncResetPipe(offsetZeroedTowersPipe),
			threshold	=>	cEcalThreshold,
			data_in		=>	LinearTowersPipe(0)(i).ECALA,
--			data_in		=>	links_in(i).ECALA,
			data_out	=>	ZeroedTowersPipe(0)(i).ECALA
		);
		ComparitorECALB: Comparitor
		port map (
			clk		=>	clk_160,
			async_reset	=>	syncResetPipe(offsetZeroedTowersPipe),
			threshold	=>	cEcalThreshold,
			data_in		=>	LinearTowersPipe(0)(i).ECALB,
--			data_in		=>	links_in(i).ECALB,
			data_out	=>	ZeroedTowersPipe(0)(i).ECALB
		);
		ComparitorHCALA: Comparitor
		port map (
			clk		=>	clk_160,
			async_reset	=>	syncResetPipe(offsetZeroedTowersPipe),
			threshold	=>	cHcalThreshold,
			data_in		=>	LinearTowersPipe(0)(i).HCALA,
--			data_in		=>	links_in(i).HCALA,
			data_out	=>	ZeroedTowersPipe(0)(i).HCALA
		);
		ComparitorHCALB: Comparitor
		port map (
			clk		=>	clk_160,
			async_reset	=>	syncResetPipe(offsetZeroedTowersPipe),
			threshold	=>	cHcalThreshold,
			data_in		=>	LinearTowersPipe(0)(i).HCALB,
--			data_in		=>	links_in(i).HCALB,
			data_out	=>	ZeroedTowersPipe(0)(i).HCALB
		);
	END GENERATE gComparitor;


	-- Add the pair of ECAL + HCAL towers and clock into the 0'th element of the E+H Sum pipe
	-- Clocks into the pipe	when	syncResetPipe is at 1
	gEHSum : FOR i IN (cNumberOfLinks-1) DOWNTO 0 GENERATE
		ETAdderA: ETAdder
		generic map( inputwidth	=>	cLinearizedWidth )
		port map (
			clk		=>	clk_160,
			async_reset	=>	syncResetPipe(offsetZeroedTowersPipe+1),
			ET1in		=>	ZeroedTowersPipe(0)(i).ECALA,
			ET2in		=>	ZeroedTowersPipe(0)(i).HCALA,
			data_out	=>	EHSumPipe(0)(i).TOWERA
		);
		ETAdderB: ETAdder
		generic map( inputwidth	=>	cLinearizedWidth )
		port map (
			clk		=>	clk_160,
			async_reset	=>	syncResetPipe(offsetZeroedTowersPipe+1),
			ET1in		=>	ZeroedTowersPipe(0)(i).ECALB,
			ET2in		=>	ZeroedTowersPipe(0)(i).HCALB,
			data_out	=>	EHSumPipe(0)(i).TOWERB
		);
	END GENERATE gEHSum;

	-- Add the pairs of ECAL + ECAL and HCAL + HCAL towers within each pair on a link and clock into the 0'th element of the 1x2 Sum pipe
	-- First clocks into the pipe	when	syncResetPipe is at 3
	g1x2ETSum : FOR i IN (cNumberOfLinks-1) DOWNTO 0 GENERATE
		ETAdderA: ETAdder
		generic map( inputwidth	=>	(cLinearizedWidth+1) )
		port map (
			clk			=>	clk_160,
			async_reset	=>	syncResetPipe(offsetZeroedTowersPipe+3),
			ET1in		=>	EHSumPipe(1)(i).TOWERA,
			ET2in		=>	EHSumPipe(0)(i).TOWERA,
			data_out	=>	Pipe1x2ETSumA(0)(i)
		);
		ETAdderB: ETAdder
		generic map( inputwidth	=>	(cLinearizedWidth+1) )
		port map (
			clk			=>	clk_160,
			async_reset	=>	syncResetPipe(offsetZeroedTowersPipe+3),
			ET1in		=>	EHSumPipe(1)(i).TOWERB,
			ET2in		=>	EHSumPipe(0)(i).TOWERB,
			data_out	=>	Pipe1x2ETSumB(0)(i)
		);
	END GENERATE g1x2ETSum;	
	
	
	-- Add the pairs of ECAL + ECAL and HCAL + HCAL towers within each pair on a link and clock into the 0'th element of the 2x1 Sum pipe A
	-- Clocking from ZeroedTowersPipe(1) to line up 2x1 Sum pipe A and 2x1 Sum pipe B
	-- First clocks into the pipe	when	syncResetPipe is at 3
	g2x1Sum : FOR i IN (cNumberOfLinks-1) DOWNTO 0 GENERATE
		ETAdderECALA: ETAdder
		generic map( inputwidth	=>	cLinearizedWidth )
		port map (
			clk		=>	clk_160,
			async_reset	=>	syncResetPipe(offset2x1SumPipe),
			ET1in		=>	ZeroedTowersPipe(0)(i).ECALA,
			ET2in		=>	ZeroedTowersPipe(0)(i).ECALB,
			data_out	=>	Pipe2x1SumA(0)(i).ECAL
		);
		ETAdderHCALA: ETAdder
		generic map( inputwidth	=>	cLinearizedWidth )
		port map (
			clk		=>	clk_160,
			async_reset	=>	syncResetPipe(offset2x1SumPipe),
			ET1in		=>	ZeroedTowersPipe(0)(i).HCALA,
			ET2in		=>	ZeroedTowersPipe(0)(i).HCALB,
			data_out	=>	Pipe2x1SumA(0)(i).HCAL
		);
		g2x1SumIf : IF (i/=cNumberOfLinks-1) GENERATE
			ETAdderECALB: ETAdder
			generic map( inputwidth	=>	cLinearizedWidth )
			port map (
				clk		=>	clk_160,
				async_reset	=>	syncResetPipe(offset2x1SumPipe),
				ET1in		=>	ZeroedTowersPipe(0)(i+1).ECALA,
				ET2in		=>	ZeroedTowersPipe(0)(i).ECALB,
				data_out	=>	Pipe2x1SumB(0)(i).ECAL
			);
			ETAdderHCALB: ETAdder
			generic map( inputwidth	=>	cLinearizedWidth )
			port map (
				clk		=>	clk_160,
				async_reset	=>	syncResetPipe(offset2x1SumPipe),
				ET1in		=>	ZeroedTowersPipe(0)(i+1).HCALA,
				ET2in		=>	ZeroedTowersPipe(0)(i).HCALB,
				data_out	=>	Pipe2x1SumB(0)(i).HCAL
			);
		END GENERATE g2x1SumIf;
	END GENERATE g2x1Sum;


	-- Add the ECAL + HCAL towers within each pair on a link and clock into the 0'th element of the 2x1 Sum pipe A
	-- First clocks into the pipe	when	syncResetPipe is at 3
	g2x1ETSum : FOR i IN (cNumberOfLinks-1) DOWNTO 0 GENERATE
		ETAdderA: ETAdder
		generic map( inputwidth	=>	(cLinearizedWidth+1) )
		port map (
			clk			=>	clk_160,
			async_reset	=>	syncResetPipe(offset2x1SumPipe+1),
			ET1in		=>	Pipe2x1SumA(0)(i).ECAL,
			ET2in		=>	Pipe2x1SumA(0)(i).HCAL,
			data_out	=>	Pipe2x1ETSumA(0)(i)
		);
		ETAdderB: ETAdder
		generic map( inputwidth	=>	(cLinearizedWidth+1) )
		port map (
			clk			=>	clk_160,
			async_reset	=>	syncResetPipe(offset2x1SumPipe+1),
			ET1in		=>	Pipe2x1SumB(0)(i).ECAL,
			ET2in		=>	Pipe2x1SumB(0)(i).HCAL,
			data_out	=>	Pipe2x1ETSumB(0)(i)
		);
	END GENERATE g2x1ETSum;


	
	

	-- Add the pairs of ECAL + ECAL and HCAL + HCAL towers between pair on link and between links and clock into the 0'th element of the 2x1 Sum pipe B
	-- First clocks into the pipe	when	syncResetPipe is at 4
	g2x2Sum : FOR i IN (cNumberOfLinks-1) DOWNTO 0 GENERATE
		ETAdderECALA: ETAdder
		generic map( inputwidth	=>	(cLinearizedWidth+1) )
		port map (
			clk		=>	clk_160,
			async_reset	=>	syncResetPipe(offset2x2SumPipe),
			ET1in		=>	Pipe2x1SumA(1)(i).ECAL,
			ET2in		=>	Pipe2x1SumA(0)(i).ECAL,
			data_out	=>	Pipe2x2SumA(0)(i).ECAL
		);
		ETAdderECALB: ETAdder
		generic map( inputwidth	=>	(cLinearizedWidth+1) )
		port map (
			clk		=>	clk_160,
			async_reset	=>	syncResetPipe(offset2x2SumPipe),
			ET1in		=>	Pipe2x1SumB(1)(i).ECAL,
			ET2in		=>	Pipe2x1SumB(0)(i).ECAL,
			data_out	=>	Pipe2x2SumB(0)(i).ECAL
		);
		ETAdderHCALA: ETAdder
		generic map( inputwidth	=>	(cLinearizedWidth+1) )
		port map (
			clk		=>	clk_160,
			async_reset	=>	syncResetPipe(offset2x2SumPipe),
			ET1in		=>	Pipe2x1SumA(1)(i).HCAL,
			ET2in		=>	Pipe2x1SumA(0)(i).HCAL,
			data_out	=>	Pipe2x2SumA(0)(i).HCAL
		);
		ETAdderHCALB: ETAdder
		generic map( inputwidth	=>	(cLinearizedWidth+1) )
		port map (
			clk		=>	clk_160,
			async_reset	=>	syncResetPipe(offset2x2SumPipe),
			ET1in		=>	Pipe2x1SumB(1)(i).HCAL,
			ET2in		=>	Pipe2x1SumB(0)(i).HCAL,
			data_out	=>	Pipe2x2SumB(0)(i).HCAL
		);
	END GENERATE g2x2Sum;



	-- Add the ECAL + HCAL towers within each pair on a link and clock into the 0'th element of the 2x2 Sum pipes
	-- First clocks into the pipe	when	syncResetPipe is at 5
	g2x2ETSum : FOR i IN (cNumberOfLinks-1) DOWNTO 0 GENERATE
		ETAdderA: ETAdder
		generic map( inputwidth	=>	(cLinearizedWidth+2) )
		port map (
			clk			=>	clk_160,
			async_reset	=>	syncResetPipe(offset2x2SumPipe+1),
			ET1in		=>	Pipe2x2SumA(0)(i).ECAL,
			ET2in		=>	Pipe2x2SumA(0)(i).HCAL,
			data_out	=>	Pipe2x2ETSumA(0)(i)
		);
		ETAdderB: ETAdder
		generic map( inputwidth	=>	(cLinearizedWidth+2) )
		port map (
			clk			=>	clk_160,
			async_reset	=>	syncResetPipe(offset2x2SumPipe+1),
			ET1in		=>	Pipe2x2SumB(0)(i).ECAL,
			ET2in		=>	Pipe2x2SumB(0)(i).HCAL,
			data_out	=>	Pipe2x2ETSumB(0)(i)
		);
	END GENERATE g2x2ETSum;


	
	
	-- Weight the clusters 
	gClusterPosition : FOR i IN (cNumberOfLinks-1) DOWNTO 0 GENERATE
		ClusterWeightAv: ClusterWeight
		port map(
			async_reset 		=> syncResetPipe(offset2x2SumPipe+2),
			clk					=> clk_160,
			north_or_west		=> Pipe2x1ETSumA(2)(i), --3
			south_or_east		=> Pipe2x1ETSumA(1)(i), --2
			region2x2			=> Pipe2x2ETSumA(0)(i), --1
			weight				=> PipeClusterPositionA(0)(i).V
		);
		ClusterWeightAh: ClusterWeight
		port map(
			async_reset 		=> syncResetPipe(offset2x2SumPipe+2),
			clk					=> clk_160,
			north_or_west		=> Pipe1x2ETSumA(1)(i), --2
			south_or_east		=> Pipe1x2ETSumB(1)(i), --2
			region2x2			=> Pipe2x2ETSumA(0)(i), --1
			weight				=> PipeClusterPositionA(0)(i).H
		);
		ClusterWeightBv: ClusterWeight
		port map(
			async_reset 		=> syncResetPipe(offset2x2SumPipe+2),
			clk					=> clk_160,
			north_or_west		=> Pipe2x1ETSumB(2)(i), --3
			south_or_east		=> Pipe2x1ETSumB(1)(i), --2
			region2x2			=> Pipe2x2ETSumB(0)(i), --1
			weight				=> PipeClusterPositionB(0)(i).V
		);
		gClusterPositionIf : IF (i/=cNumberOfLinks-1) GENERATE
		ClusterWeightBh: ClusterWeight
			port map(
				async_reset 		=> syncResetPipe(offset2x2SumPipe+2),
				clk					=> clk_160,
				north_or_west		=> Pipe1x2ETSumB(1)(i), --2
				south_or_east		=> Pipe1x2ETSumA(1)(i+1), --2
				region2x2			=> Pipe2x2ETSumB(0)(i), --1
				weight				=> PipeClusterPositionB(0)(i).H
			);
		END GENERATE gClusterPositionIf;
	END GENERATE gClusterPosition;
	
	
	-- -- Run the EPIM algorithm and clock into the 0'th element of the EPIM pipe
	-- -- Note that EandH must be clocked in ... cycles prior to ET, since ET is itself derived from EandH
	-- -- First clocks into the pipe	when	syncResetPipe is at 6
	gEPIM : FOR i IN (cNumberOfLinks-1) DOWNTO 0 GENERATE
		EPIMA: entity TMCaloTrigger_lib.EPIM(V5)
		port map(
			async_reset 		=> syncResetPipe(offset2x2SumPipe+2),
			clk					=> clk_160,
			TargetGreaterSelect	=> cTargetGreaterSelect,
			TargetLesserSelect	=> cTargetLesserSelect,
			LUTSelect			=> cLUTSelect,
			EandH				=> Pipe2x2SumA(1)(i),
			ET					=> Pipe2x2ETSumA(0)(i),
			pass				=> PipeEPIMA(0)(i),
			epimlut_address			=> epimlut_address,
			epimlut_data			=> epimlut_data,
			epimlut_clk				=> epimlut_cl0ck,
			epimlut_enable			=> epimlut_enable
		);
		EPIMB: entity TMCaloTrigger_lib.EPIM(V5)
		port map(
			async_reset 		=> syncResetPipe(offset2x2SumPipe+2),
			clk					=> clk_160,
			TargetGreaterSelect	=> cTargetGreaterSelect,
			TargetLesserSelect	=> cTargetLesserSelect,
			LUTSelect			=> cLUTSelect,
			EandH				=> Pipe2x2SumB(1)(i),
			ET					=> Pipe2x2ETSumB(0)(i),
			pass				=> PipeEPIMB(0)(i),
			epimlut_address			=> epimlut_address,
			epimlut_data			=> epimlut_data,
			epimlut_clk				=> epimlut_cl0ck,
			epimlut_enable			=> epimlut_enable
		);
	END GENERATE gEPIM;

	
	-- Compare the cluster with that to the NW, W , SW and S
	-- First clocks into the pipe	when	syncResetPipe is at ...
	gFilterMask : FOR i IN (cNumberOfLinks-1) DOWNTO 0 GENERATE
	
		gFilterMaskIfA : IF (i/=0) GENERATE
			inputFilterRegionA(i).NW		<= Pipe2x2ETSumB(2)(i-1);
			inputFilterRegionA(i).W			<= Pipe2x2ETSumB(1)(i-1);
			inputFilterRegionA(i).SW 		<= Pipe2x2ETSumB(0)(i-1);
		END GENERATE gFilterMaskIfA;

		inputFilterRegionA(i).N			<= Pipe2x2ETSumA(2)(i);
		inputFilterRegionA(i).CENTRE	<= Pipe2x2ETSumA(1)(i);
		inputFilterRegionA(i).S 		<= Pipe2x2ETSumA(0)(i);						
		
		inputFilterRegionA(i).NE 		<= Pipe2x2ETSumB(2)(i);
		inputFilterRegionA(i).E			<= Pipe2x2ETSumB(1)(i);
		inputFilterRegionA(i).SE 		<= Pipe2x2ETSumB(0)(i);

		
		inputFilterRegionB(i).NW		<= Pipe2x2ETSumA(2)(i);
		inputFilterRegionB(i).W			<= Pipe2x2ETSumA(1)(i);
		inputFilterRegionB(i).SW 		<= Pipe2x2ETSumA(0)(i);

		inputFilterRegionB(i).N			<= Pipe2x2ETSumB(2)(i);
		inputFilterRegionB(i).CENTRE	<= Pipe2x2ETSumB(1)(i);
		inputFilterRegionB(i).S 		<= Pipe2x2ETSumB(0)(i);

		gFilterMaskIfB : IF (i/=cNumberOfLinks-1) GENERATE
			inputFilterRegionB(i).NE 		<= Pipe2x2ETSumA(2)(i+1);
			inputFilterRegionB(i).E			<= Pipe2x2ETSumA(1)(i+1);
			inputFilterRegionB(i).SE 		<= Pipe2x2ETSumA(0)(i+1);
		END GENERATE gFilterMaskIfB;

		COFA : ClusterOverlapFilter
		port map(
			async_reset	=> syncResetPipe(offsetFilterMaskPipe),
			clk	=> clk_160,
			filterRegion => inputFilterRegionA(i),
			filterMask => PipeFilterMaskA(0)(i)
		);
		COFB : ClusterOverlapFilter
		port map(
			async_reset	=> syncResetPipe(offsetFilterMaskPipe),
			clk	=> clk_160,
			filterRegion => inputFilterRegionB(i),
			filterMask => PipeFilterMaskB(0)(i)
		);

		
		END GENERATE gFilterMask;


		

	-- Compare the cluster with that to the NW, W , SW and S
	-- First clocks into the pipe	when	syncResetPipe is at ...
	gTowerPruning : FOR i IN (cNumberOfLinks-1) DOWNTO 0 GENERATE

		inputnorth1x1B(i).TOWERA <= EHSumPipe(4)(i).TOWERB;
		inputsouth1x1B(i).TOWERA <= EHSumPipe(3)(i).TOWERB;
		
		gTowerPruningIf : IF (i/=cNumberOfLinks-1) GENERATE
			inputnorth1x1B(i).TOWERB <= EHSumPipe(4)(i+1).TOWERA;
			inputsouth1x1B(i).TOWERB <= EHSumPipe(3)(i+1).TOWERA;
		END GENERATE gTowerPruningIf;
		
		
		cTowerPruningA: TowerPruning
		port map(
			async_reset	=> syncResetPipe(offsetFilteredClusterPipe),
			clk	=> clk_160,
			threshold => cClusterThreshold,
			filterMask => PipeFilterMaskA(0)(i),
			north1x1 => EHSumPipe(4)(i),
			south1x1 => EHSumPipe(3)(i),
			north2x1 => Pipe2x1ETSumA(3)(i),
			south2x1 => Pipe2x1ETSumA(2)(i),
			filteredCluster => PipeFilteredClusterA(0)(i)
		);
		cTowerPruningB: TowerPruning
		port map(
			async_reset	=> syncResetPipe(offsetFilteredClusterPipe),
			clk	=> clk_160,
			threshold => cClusterThreshold,
			filterMask => PipeFilterMaskB(0)(i),
			north1x1 => inputnorth1x1B(i),
			south1x1 => inputsouth1x1B(i),
			north2x1 => Pipe2x1ETSumB(3)(i),
			south2x1 => Pipe2x1ETSumB(2)(i),
			filteredCluster => PipeFilteredClusterB(0)(i)
		);
	end generate gTowerPruning;	
	
	
	gTowerSorting : FOR i IN (cNumberOfLinks-1) DOWNTO 0 GENERATE
		inputClusterSorting((2*i)+0).INFO			<= PipeFilteredClusterA(0)(i); 						
		inputClusterSorting((2*i)+0).FINEPOSITION	<= PipeClusterPositionA(4)(i);
                inputClusterSorting((2*i)+0).COARSEPOSITION	<= std_logic_vector( to_unsigned( (2*i)+0 , 6 ));
                --inputClusterSorting((2*i)+0).COARSEPOSITION	<= (others => '1');
		inputClusterSorting((2*i)+0).EPIMS(0)		<= PipeEPIMA(2)(i);  --could just be STD_LOGIC but state like this for sake of test bench

		inputClusterSorting((2*i)+1).INFO			<= PipeFilteredClusterB(0)(i);
		inputClusterSorting((2*i)+1).FINEPOSITION	<= PipeClusterPositionB(4)(i);
                inputClusterSorting((2*i)+1).COARSEPOSITION	<= std_logic_vector( to_unsigned( (2*i)+1 , 6 ));
                --inputClusterSorting((2*i)+1).COARSEPOSITION	<= (others => '1');
		inputClusterSorting((2*i)+1).EPIMS(0)		<= PipeEPIMB(2)(i);  --could just be STD_LOGIC but state like this for sake of test bench
	end generate gTowerSorting;		

	
	-- gJF1D : FOR i IN ( (2*cNumberOfLinks)-cJetSize) DOWNTO 0 GENERATE
		-- cJF1D: clustercnt
		-- port map(
			-- async_reset		=> syncResetPipe(offset1DJFPipe),
			-- clk				=> clk_160,
			-- clustersIn(cJetSize-2 downto 0)		=> inputClusterSorting(i+cJetSize-2 downto i),
			-- jet1Dout		=> PipeJF1D(0)(i)
		-- );
	-- end generate gJF1D;	
	
	
	
	-- Sort: sorter
	-- generic map( level	=>	cBitonicWidth )
	-- port map (
		-- clk		=>	clk_160,
		-- data_in => inputClusterSorting,
		-- data_out => sortedClusters
	-- );

	-- PipeSortedCluster(0) <= sortedClusters( cClustersPerPhi-1 downto 0) when syncResetPipe(offsetSortedClusterPipe) = '0';
	
	-- SortLower: sorter2
	-- SortLower: sorter3
	-- generic map (
		-- inputs => cNumberOfLinks,
		-- outputs => cClustersPerPhi
	-- )
	-- port map (
		-- async_reset		=> syncResetPipe(offsetSortedClusterPipe),
		-- clk				=>	clk_160,
		-- data_in 		=> inputClusterSorting( cNumberOfLinks-1 DOWNTO 0 ),
		-- data_out 		=> semiSortedClusters( cClustersPerPhi-1 downto 0)
	-- );

	-- -- SortUpper: sorter2
	-- SortUpper: sorter3
	-- generic map (
		-- inputs => cNumberOfLinks,
		-- outputs => cClustersPerPhi
	-- )
	-- port map (
		-- async_reset		=> syncResetPipe(offsetSortedClusterPipe),
		-- clk				=>	clk_160,
		-- data_in 		=> inputClusterSorting( (2*cNumberOfLinks)-1 DOWNTO cNumberOfLinks ),
		-- data_out 		=> semiSortedClusters( (2*cClustersPerPhi)-1 downto cClustersPerPhi)
	-- );	


	-- -- SortFinal: sorter2
	-- SortFinal: sorter3
	-- generic map (
		-- inputs => 2*cClustersPerPhi,
		-- outputs => cClustersPerPhi
	-- )
	-- port map (
		-- async_reset		=> syncResetPipe(offsetSortedClusterPipe+1),
		-- clk				=>	clk_160,
		-- data_in 		=> semiSortedClusters,
		-- data_out 		=> PipeSortedCluster(0)
	-- );	

	
	
	-- clusterInPhi: cluster1d
	-- PORT MAP(
		-- async_reset		=> syncResetPipe(offsetClusterFlagPipe),
		-- clk				=>	clk_160,		
		-- distance		=> cJetRadius,	
		-- SortedClusters	=> PipeSortedCluster(0),
		-- ClusterFlags	=> PipeClusterFlag(0)
	-- );
	

	
	
	


-- ------------------------------------------------------------------------------------------------------------------------------------------------------------
END ARCHITECTURE AlgorithmTop;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------

