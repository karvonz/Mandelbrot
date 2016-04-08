--
-- VHDL Package Header TMCaloTrigger_lib.types
--
-- Created:
--          by - awr01.UNKNOWN (SINBADPC)
--          at - 15:31:41 23/02/2010
--
-- using Mentor Graphics HDL Designer(TM) 2006.1 (Build 72)
--
LIBRARY ieee;
LIBRARY TMCaloTrigger_lib;

USE ieee.std_logic_1164.all;
use TMCaloTrigger_lib.constants.all;

PACKAGE types IS

	CONSTANT depthLinearTowersPipe : INTEGER := 1;
	CONSTANT offsetLinearTowersPipe : INTEGER := 0;

	CONSTANT depthZeroedTowersPipe : INTEGER := 1;
	CONSTANT offsetZeroedTowersPipe : INTEGER := offsetLinearTowersPipe+1;

	CONSTANT depthEHSumPipe : INTEGER := 5;
	
	CONSTANT depth2x1SumPipe : INTEGER := 2;
	CONSTANT offset2x1SumPipe : INTEGER := offsetZeroedTowersPipe+1; --1;

	CONSTANT depth2x1ETSumPipe : INTEGER := 5;

	CONSTANT depth2x2SumPipe : INTEGER := 2;
	CONSTANT offset2x2SumPipe : INTEGER := offset2x1SumPipe+2; --3;
	
	CONSTANT depth2x2ETSumPipe : INTEGER := 3;

	CONSTANT depthClusterPositionPipe : INTEGER := 10;
	
	CONSTANT depthEPIMPipe : INTEGER := 3;

	CONSTANT depthFilterMaskPipe : INTEGER := 1;
	CONSTANT offsetFilterMaskPipe : INTEGER := offset2x2SumPipe+4; --8-1;

	CONSTANT depthFilteredClusterPipe : INTEGER := 2;
	CONSTANT offsetFilteredClusterPipe : INTEGER := offsetFilterMaskPipe; --9-2;


	CONSTANT depthSortedClusterPipe : INTEGER := 1;	--2;
	-- CONSTANT depthSortedClusterPipe : INTEGER := (2*cMaxJetRadius)-1;	--2;
	
	-- CONSTANT offsetSortedClusterPipe : INTEGER := offsetFilteredClusterPipe+2;    -- Sorter 3
	CONSTANT offsetSortedClusterPipe : INTEGER := offsetFilteredClusterPipe+2;       -- Sorter 2
	-- CONSTANT offsetSortedClusterPipe : INTEGER := offsetFilteredClusterPipe+23;   -- Sorter 1

	-- CONSTANT depthClusterFlagPipe : INTEGER := 2;
	-- CONSTANT offsetClusterFlagPipe : INTEGER := offsetSortedClusterPipe+2;

	CONSTANT offset1DJFPipe : INTEGER := offsetFilteredClusterPipe+2;

	
	-- -----------------------------------------------------------------------------------------------------------------------

	-- Create a pipe to hold the sync_reset. NB clocked at 160MHz 	
	CONSTANT depthSyncResetPipe : INTEGER := 50;
	TYPE tSyncResetPipe IS ARRAY( depthSyncResetPipe-1 DOWNTO 0 ) OF STD_LOGIC;

	-- -----------------------------------------------------------------------------------------------------------------------
	
	TYPE tLinks IS ARRAY( cNumberOfLinks-1 DOWNTO 0 ) of STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	
	-- -----------------------------------------------------------------------------------------------------------------------

	-- TYPE tRawTowers IS RECORD
		-- TowerA : STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		-- TowerB : STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		-- TowerC : STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		-- TowerD : STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	-- END RECORD;
	-- TYPE aRawTowers IS ARRAY( cNumberOfLinks-1 DOWNTO 0 ) of tRawTowers;

	-- -----------------------------------------------------------------------------------------------------------------------

	-- Create a pipe to hold the Zeroed Links. NB clocked at 160MHz 	
	TYPE tLinearTowers IS RECORD
		ECALA : STD_LOGIC_VECTOR( cLinearizedWidth-1 DOWNTO 0 );
		ECALB : STD_LOGIC_VECTOR( cLinearizedWidth-1 DOWNTO 0 );
		HCALA : STD_LOGIC_VECTOR( cLinearizedWidth-1 DOWNTO 0 );
		HCALB : STD_LOGIC_VECTOR( cLinearizedWidth-1 DOWNTO 0 );
	END RECORD;
	TYPE aLinearTowers IS ARRAY( cNumberOfLinks-1 DOWNTO 0 ) of tLinearTowers;
	TYPE tLinearTowersPipe IS ARRAY( depthLinearTowersPipe-1 DOWNTO 0 ) OF aLinearTowers;
	TYPE tZeroedTowersPipe IS ARRAY( depthZeroedTowersPipe-1 DOWNTO 0 ) OF aLinearTowers;

	-- -----------------------------------------------------------------------------------------------------------------------

	-- Create a pipe to hold the E+H Sums. NB clocked at 160MHz 	
	TYPE tEHSums IS RECORD
		TOWERA : STD_LOGIC_VECTOR( cLinearizedWidth DOWNTO 0 );
		TOWERB : STD_LOGIC_VECTOR( cLinearizedWidth DOWNTO 0 );
	END RECORD;
	TYPE aEHSums IS ARRAY( cNumberOfLinks-1 DOWNTO 0 ) of tEHSums;
	TYPE tEHSumPipe IS ARRAY( depthEHSumPipe-1 DOWNTO 0 ) OF aEHSums;

	-- -----------------------------------------------------------------------------------------------------------------------

	-- Create pipes to hold the 2x1 Region Sums. NB clocked at 160MHz
	TYPE t2x1Sums IS RECORD
		ECAL : STD_LOGIC_VECTOR( cLinearizedWidth DOWNTO 0 );
		HCAL : STD_LOGIC_VECTOR( cLinearizedWidth DOWNTO 0 );
	END RECORD;
	TYPE a2x1Sums IS ARRAY( cNumberOfLinks-1 DOWNTO 0 ) of t2x1Sums;
	TYPE t2x1SumPipe IS ARRAY( depth2x1SumPipe-1 DOWNTO 0 ) OF a2x1Sums;

	-- -----------------------------------------------------------------------------------------------------------------------

	-- Create pipes to hold the Cluster ET Sums. NB clocked at 160MHz
	TYPE a2x1ETSums IS ARRAY( cNumberOfLinks-1 DOWNTO 0 ) of STD_LOGIC_VECTOR( cLinearizedWidth+1 DOWNTO 0 );
	TYPE t2x1ETSumPipe IS ARRAY( depth2x1ETSumPipe-1 DOWNTO 0 ) OF a2x1ETSums;

	-- -----------------------------------------------------------------------------------------------------------------------

	-- Create pipes to hold the 2x2 Region Sums. NB clocked at 160MHz
	TYPE t2x2Sums IS RECORD
		ECAL : STD_LOGIC_VECTOR( cLinearizedWidth+1 DOWNTO 0 );
		HCAL : STD_LOGIC_VECTOR( cLinearizedWidth+1 DOWNTO 0 );
	END RECORD;
	TYPE a2x2Sums IS ARRAY( cNumberOfLinks-1 DOWNTO 0 ) of t2x2Sums;
	TYPE t2x2SumPipe IS ARRAY( depth2x2SumPipe-1 DOWNTO 0 ) OF a2x2Sums;

	-- -----------------------------------------------------------------------------------------------------------------------

	-- Create pipes to hold the Cluster ET Sums. NB clocked at 160MHz
	TYPE a2x2ETSums IS ARRAY( cNumberOfLinks-1 DOWNTO 0 ) of STD_LOGIC_VECTOR( cLinearizedWidth+2 DOWNTO 0 );
	TYPE t2x2ETSumPipe IS ARRAY( depth2x2ETSumPipe-1 DOWNTO 0 ) OF a2x2ETSums;

	-- -----------------------------------------------------------------------------------------------------------------------
	
	-- Create pipes to hold the Cluster weighted position. NB clocked at 160MHz
	TYPE tClusterPosition IS RECORD
		H : STD_LOGIC_VECTOR( 1 DOWNTO 0 );
		V : STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	END RECORD;
	TYPE aClusterPosition IS ARRAY( cNumberOfLinks-1 DOWNTO 0 ) of tClusterPosition;
	TYPE tClusterPositionPipe IS ARRAY( depthClusterPositionPipe-1 DOWNTO 0 ) OF aClusterPosition;

	-- -----------------------------------------------------------------------------------------------------------------------

	-- Create pipes to hold the Cluster EPIM bit. NB clocked at 160MHz
	TYPE aEPIMs IS ARRAY( cNumberOfLinks-1 DOWNTO 0 ) of STD_LOGIC;
	TYPE tEPIMPipe IS ARRAY( depthEPIMPipe-1 DOWNTO 0 ) OF aEPIMs;

	-- -----------------------------------------------------------------------------------------------------------------------
		
	-- intermediary type to make mapping the data to the Cluster overlap filter easier!
	TYPE tFilterRegion IS RECORD
		CENTRE : STD_LOGIC_VECTOR( cLinearizedWidth+2 DOWNTO 0 );
		NW : STD_LOGIC_VECTOR( cLinearizedWidth+2 DOWNTO 0 );
		W : STD_LOGIC_VECTOR( cLinearizedWidth+2 DOWNTO 0 );
		SW : STD_LOGIC_VECTOR( cLinearizedWidth+2 DOWNTO 0 );
		S : STD_LOGIC_VECTOR( cLinearizedWidth+2 DOWNTO 0 );
		SE : STD_LOGIC_VECTOR( cLinearizedWidth+2 DOWNTO 0 );
		E : STD_LOGIC_VECTOR( cLinearizedWidth+2 DOWNTO 0 );
		NE : STD_LOGIC_VECTOR( cLinearizedWidth+2 DOWNTO 0 );
		N : STD_LOGIC_VECTOR( cLinearizedWidth+2 DOWNTO 0 );
	END RECORD;
	TYPE aFilterRegion IS ARRAY( cNumberOfLinks-1 DOWNTO 0 ) of tFilterRegion;

	-- Create pipes to hold the Cluster Overlap mask. NB clocked at 160MHz
	TYPE tFilterMask IS RECORD
		NW : STD_LOGIC;
		NE : STD_LOGIC; -- W : STD_LOGIC;
		SW : STD_LOGIC;
		SE : STD_LOGIC;	-- S : STD_LOGIC;
	END RECORD;
	TYPE aFilterMask IS ARRAY( cNumberOfLinks-1 DOWNTO 0 ) of tFilterMask;
	TYPE tFilterMaskPipe IS ARRAY( depthFilterMaskPipe-1 DOWNTO 0 ) of aFilterMask;

	
	-- Create pipes to hold the 2x2 Overlap Filtered Cluster. NB clocked at 160MHz
	TYPE tFilteredCluster IS RECORD
		MAXIMA : STD_LOGIC;
		CLUSTER : STD_LOGIC_VECTOR( cLinearizedWidth+2 DOWNTO 0 );
		COUNT : STD_LOGIC_VECTOR( 0 DOWNTO 0 );
	END RECORD;
	
	TYPE aFilteredCluster IS ARRAY( cNumberOfLinks-1 DOWNTO 0 ) of tFilteredCluster;
	TYPE tFilteredClusterPipe IS ARRAY( depthFilteredClusterPipe-1 DOWNTO 0 ) of aFilteredCluster;


	TYPE tSortedCluster IS RECORD
		INFO : tFilteredCluster;
		FINEPOSITION : tClusterPosition;
		COARSEPOSITION : STD_LOGIC_VECTOR( 5 DOWNTO 0 ) ;
		EPIMS : STD_LOGIC_VECTOR( 0 DOWNTO 0 ) ;  --could just be STD_LOGIC but state like this for sake of test bench
	END RECORD;
	
	TYPE aSortedCluster IS ARRAY( natural range <> ) of tSortedCluster;
	TYPE tSortedClusterPipe IS ARRAY( natural range <> ) of aSortedCluster( cClustersPerPhi-1 DOWNTO 0 );
	

	-- TYPE tJet1D IS RECORD
		-- Sum : STD_LOGIC_VECTOR( cLinearizedWidth+6 DOWNTO 0 ) ;
		-- Count : STD_LOGIC_VECTOR( 3 DOWNTO 0 ) ;
	-- END RECORD;
	
	-- TYPE aJet1D IS ARRAY( (2*cNumberOfLinks)-cJetSize DOWNTO 0 ) of tJet1D;
	-- TYPE tJet1DPipe IS ARRAY( cJetSize-2 DOWNTO 0 ) of aJet1D;
	

	
	-- TYPE aClusterFlag IS ARRAY( cClustersPerPhi-1 DOWNTO 0 ) of STD_LOGIC_VECTOR( cClustersPerPhi-1 DOWNTO 0 );
	-- TYPE aClusterFlag IS ARRAY( (2*cMaxJetRadius)-2 DOWNTO 0 ) of STD_LOGIC_VECTOR( cClustersPerPhi-1 DOWNTO 0 );
	-- TYPE tClusterFlagPipe IS ARRAY( depthClusterFlagPipe-1 DOWNTO 0 ) of aClusterFlag;
	
	
		

	-- -----------------------------------------------------------------------------------------------------------------------

	
END types;
