
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
PACKAGE package_serial IS

   COMPONENT mtrigxmt IS 
      GENERIC (
         size:                          integer := 8; -- maximum number OF bits TO transmit
         clkperbit:                     integer := 6); -- clocks per bit time
      PORT (
         clk, rst, xmt:                 IN std_logic;
         clen:                          IN integer RANGE 0 TO size-1;
         idat:                          IN std_logic_vector(size-1 DOWNTO 0);
         serout, done:                  OUT std_logic);
   END COMPONENT;
   COMPONENT nrztrigxmt IS 
      GENERIC (
         size:                          integer := 8; -- maximum number OF bits TO transmit
         clkperbit:                     integer := 3); -- clocks per bit time
      PORT (
         clk, rst, xmt:                 IN std_logic;
         clen:                          IN integer RANGE 0 TO size-1;
         idat:                          IN std_logic_vector(size-1 DOWNTO 0);
         serout, done:                  OUT std_logic);
   END COMPONENT;
   COMPONENT mtrigrec IS 
      GENERIC (
         size:                          integer := 8; -- maximum number OF bits TO transmit
         clkperbit:                     integer := 6); -- clocks per bit time
      PORT (
         clk, indat, rst:               IN std_logic;
         done, err:                     OUT std_logic;
         bcount:                        OUT integer RANGE 0 TO size-1;
         odat:                          OUT std_logic_vector(size-1 DOWNTO 0));
   END COMPONENT;
   COMPONENT nrztrigrec IS 
      GENERIC (
         size:                          integer := 8;
         clkperbit:                     integer := 3); -- clocks per bit time
      PORT (
         clk, indat, rst:               IN std_logic;
         done, err:                     OUT std_logic;
         bcount:                        OUT integer RANGE 0 TO size-1;
         odat:                          OUT std_logic_vector(size-1 DOWNTO 0));
   END COMPONENT;

END package_serial;


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY mtrigxmt IS 
   GENERIC (
      size:                         integer := 8; -- maximum number OF bits TO transmit
      clkperbit:                    integer := 6); -- clocks per bit time
   PORT (
      clk, rst, xmt:                IN std_logic;
      clen:                         IN integer RANGE 0 TO size-1;
      idat:                         IN std_logic_vector(size-1 DOWNTO 0);
      serout, done:                 OUT std_logic);
END mtrigxmt;
ARCHITECTURE amtrigxmt OF mtrigxmt IS
   TYPE stateType IS (idle,sync0,sync1,bit0,bit1,p0,p1,tgap);
   SIGNAL state:                    stateType;
   SIGNAL bcnt, ccnt:               integer RANGE 0 TO size-1;
   SIGNAL bufi:                     std_logic_vector(size-1 DOWNTO 0);
   SIGNAL par:                      std_logic;
   -- sync waveform timing CONSTANT
   -- 3 bit sync (more robust - reciever will NOT sync ON any manchester data)
   --CONSTANT synctime:               integer := clkperbit+clkperbit/2-1;
   -- 4 bit sync (compatable WITH older versions)
   CONSTANT synctime:               integer := clkperbit-1;
   SIGNAL scnt:                     integer RANGE 0 TO synctime; -- bit timing count
begin
   ASSERT (clkperbit > 5)
      report "clocks bit bit must be at least 6"
      SEVERITY FAILURE;
   ASSERT (clkperbit MOD 2 = 0)
      report "clocks per bit must be an even number"
      SEVERITY FAILURE;
   ASSERT (size > 1)
      report "message size must be at least two bits"
      SEVERITY FAILURE;
   sm: PROCESS(clk, rst) BEGIN
      IF rst = '0' THEN
         scnt <= 0; bcnt <= 0; serout <= '0'; done  <= '0';
         state <= idle; ccnt <= 0; par <= '0'; bufi <= (OTHERS => '0');
      ELSIF (clk'event AND clk = '1') THEN
         CASE state IS
            WHEN idle =>
               serout <= '0';
               IF xmt ='1' THEN -- NEW message
                  par <= '0';
                  state <= sync0; -- start transmission
						ccnt <= clen;
                  bufi <= idat;
               END IF;
            WHEN sync0 => -- first half OF sync
               serout <= '1'; -- data OUT is always '1'
               IF scnt = synctime THEN -- time OUT
                  scnt <= 0; -- reset bit timer
                  state <= sync1;
               ELSE
                  scnt <= scnt + 1; -- increment bit timer
               END IF;
            WHEN sync1 => -- second half OF sync
               serout <= '0'; -- data OUT is always '0'
               IF scnt = synctime THEN -- time OUT
                  scnt <= 0; -- reset bit timer
                  state <= bit0;
               ELSE
                  scnt <= scnt + 1;
               END IF;
            WHEN bit0 => -- first half OF data bit
               serout <= NOT(bufi(bcnt)); -- serial OUT is inverse OF data bit
               IF scnt = clkperbit/2-1 THEN -- time OUT
                  scnt <= 0; -- reset bit timer
                  state <= bit1;
               ELSE
                  scnt <= scnt + 1;
               END IF;
            WHEN bit1 => -- second half OF data bit
               serout <= bufi(bcnt); -- serial OUT is data bit
               IF scnt = clkperbit/2-1 THEN -- time OUT
                  scnt <= 0; -- reset bit timer
                  par <= par XOR idat(bcnt); -- update parity
                  IF bcnt = ccnt THEN -- are ALL bits done?
                     bcnt <= 0; -- reset bit counter
                     state <= p0; -- END parity
                  ELSE
                     bcnt <= bcnt + 1; -- increment bit counter
                     state <= bit0; -- do NEXT bit
                  END IF;
               ELSE
                  scnt <= scnt + 1; -- increment bit timer
               END IF;
            WHEN p0 => -- first half OF parity bit
               serout <= NOT(par); -- serial OUT is inverse OF data bit
               IF scnt = clkperbit/2-1 THEN -- time OUT
                  scnt <= 0; -- reset bit timer
                  state <= p1;
               ELSE
                  scnt <= scnt + 1;
               END IF;
            WHEN p1 => -- second half OF parity bit
               serout <= par; -- serial OUT is data bit
               done <= '0';
               IF scnt = clkperbit/2-1 THEN -- time OUT
                  scnt <= 0; -- reset bit timer
                  state <= tgap; -- END transmission
                  done <= '1';
               ELSE
                  scnt <= scnt + 1; -- increment bit timer
               END IF;
            WHEN tgap => -- enforce transmission gap TO allow reciever TO reset
               done <= '0';
               serout <= '0';
               IF scnt = 1 THEN
                  scnt <= 0;
                  state <= idle;
               ELSE
                  scnt <= scnt + 1;
               END IF;
         END CASE;
      END IF;
   END PROCESS;
END amtrigxmt;
--
-- NRZ serializer
--
-- N-bit serial transmitter WITH two start bits
-- The xmt input starts transmission, the done flag 
-- signals completion.
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY nrztrigxmt IS 
   GENERIC (
      size:                         integer := 8; -- maximum number OF bits TO transmit
      clkperbit:                    integer := 3); -- clocks per bit time
   PORT (
      clk, rst, xmt:                 IN std_logic;
		clen:									 IN integer RANGE 0 TO size-1;
      idat:                          IN std_logic_vector(size-1 DOWNTO 0);
      serout, done:                  OUT std_logic);
END nrztrigxmt;
ARCHITECTURE anrztrigxmt OF nrztrigxmt IS
   TYPE stateType IS (idle,sync,xbit,pbit,donedly);
   SIGNAL state:                     stateType;
   SIGNAL scnt:                      integer RANGE 0 TO clkperbit*2-1;
   SIGNAL bcnt, ccnt:                integer RANGE 0 TO size-1;
   SIGNAL bufi:                      std_logic_vector(size-1 DOWNTO 0);
   SIGNAL par:                       std_logic;
begin
   sm: PROCESS(clk, rst) BEGIN
      IF rst = '0' THEN
         scnt <= 0; bcnt <= 0; serout <= '0'; done  <= '0';
         state <= idle; ccnt <= 0; par <= '0'; bufi <= (OTHERS => '0');
      ELSIF (clk'event AND clk = '1') THEN
         CASE state IS
            WHEN idle => -- WAIT FOR transmit command
               serout <= '0';
               par <= '0'; -- initialize parity
               IF xmt = '1' THEN
                  bufi <= idat;
                  state <= sync;
                  ccnt <= clen;
               END IF;
            WHEN sync => -- start bits
               serout <= '1'; -- data OUT is always '1'
               IF scnt = clkperbit*2-1 THEN -- time OUT
                  scnt <= 0; -- reset bit timer
                  state <= xbit;
               ELSE
                  scnt <= scnt + 1; -- increment bit timer
               END IF;
            WHEN xbit => -- data bit
               serout <= bufi(bcnt);
               IF scnt = clkperbit-1 THEN -- time OUT
                  par <= par XOR bufi(bcnt);
                  scnt <= 0; -- reset bit timer
                  IF bcnt = ccnt THEN -- are ALL bits done?
                     bcnt <= 0; -- reset bit counter
                     state <= pbit;
                  ELSE
                     bcnt <= bcnt + 1; -- increment bit counter
                  END IF;
               ELSE
                  scnt <= scnt + 1;
               END IF;
            WHEN pbit => -- parity bit
               serout <= par;
               IF scnt = clkperbit-1 THEN -- time OUT
                  scnt <= 0; -- reset bit timer
                  state <= donedly;
                  done <= '1'; -- flag transmission complete
               ELSE
                  scnt <= scnt + 1;
               END IF;
            WHEN donedly =>
               done <= '0';
               serout <= '0';
               IF scnt = 1 THEN -- WAIT at least 2 clocks between words          
                  scnt <= 0;
                  state <= idle;
               ELSE
                  scnt <= scnt + 1;
               END IF;
         END CASE;
      END IF;
   END PROCESS;
END anrztrigxmt;


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
ENTITY mtrigrec IS 
   GENERIC (
      size:                         integer := 8;
      clkperbit:                    integer := 6); -- clocks per bit time
   PORT (
      clk, indat, rst:              IN std_logic;
		done, err:			   			OUT std_logic;
      bcount:                       OUT integer RANGE 0 TO size-1;
      odat:                         OUT std_logic_vector(size-1 DOWNTO 0));
END mtrigrec;
ARCHITECTURE amtrigrec OF mtrigrec IS
   -- state machine definition
   TYPE sStateType IS (idle,e1,synced);
   TYPE bStateType IS (idle,d0a,d0b,d1a,d1b);
   TYPE mStateType IS (idle,busy,clear);
   -- edge finder
   SIGNAL indats:                   std_logic;
   SIGNAL indat0, indat1:           std_logic;
   SIGNAL edge, posedge:            std_logic;
   -- bit AND sync timing comparators
   SIGNAL bitime, halfbitime:       std_logic;
   SIGNAL syntime, halfsyntime:     std_logic;
   SIGNAL timeout:                  std_logic;
   -- sync state machine
   SIGNAL synstate:                 sStateType;
   SIGNAL sync:                     std_logic;
   -- bit decode state machine
   SIGNAL bitstate:                 bStateType;
   SIGNAL bout, bready, ierr:       std_logic;
   -- message sequence state machine
   SIGNAL msgstate:                 mStateType;
   SIGNAL bcnt:                     integer RANGE 0 TO size;
   SIGNAL idone, perr, par:         std_logic;
   -- manchester bit timing constants
   CONSTANT halfbit:                integer := clkperbit/2-1; -- these counts are zero based
   CONSTANT fullbit:                integer := clkperbit-1;
   CONSTANT twobit:                 integer := clkperbit*2-1;
   CONSTANT timoutval:              integer := twobit; -- make sure TO set TO largest count required
   -- sync waveform timing constants
   -- 3 bit time sync waveform (more robust - will NOT sync ON any manchester data)
   --CONSTANT halfsync:               integer := clkperbit+clkperbit/2-1; -- 1/2 the sync time (first bit is 0)
   --CONSTANT fullsync:               integer := clkperbit*2-1; -- 1/2 sync time + 1/2 bit time (first bit is one)
   -- 2 bit time syncwaveform (compatable WITH older versions)
   CONSTANT halfsync:               integer := clkperbit-1; -- 1/2 the sync time (first bit is 0)
   CONSTANT fullsync:               integer := clkperbit+clkperbit/2-1; -- 1/2 sync time + 1/2 bit time (first bit is one)
   -- sample count FOR bit timing
   SIGNAL scnt:                     integer RANGE 0 TO timoutval; 
   -- misc
   SIGNAL rst_clked:                std_logic;

begin

   derive_clked_rst: PROCESS (clk) BEGIN
      IF (clk'event AND clk = '1') THEN
         rst_clked <= rst;
      END IF;
   END PROCESS;

   -- check generics
   ASSERT (clkperbit > 5)
      report "clocks per bit must be at least 6"
      SEVERITY FAILURE;
   ASSERT (clkperbit MOD 2 = 0)
      report "clocks per bit must be an even number"
      SEVERITY FAILURE;
   ASSERT (size > 1)
      report "message size must be at least two bits"
      SEVERITY FAILURE;
   -- input data synchronizer
   isync: PROCESS (clk) BEGIN
      IF (clk'event AND clk = '1') THEN
         indats <= indat; -- reclock
         indat0 <= indats; -- need two sample times TO find edge
         indat1 <= indat0;
      END IF;
   END PROCESS;
   -- edge finder
   findedge: PROCESS (clk) BEGIN
      IF (clk'event AND clk = '1') THEN
         edge <= indat0 XOR indat1;
         posedge <= indat0;
      END IF;
   END PROCESS;
   -- sample time counter
   scount: PROCESS (clk) BEGIN
      IF (clk'event AND clk = '1') THEN
         IF edge = '1' THEN
            scnt <= 0;
         ELSIF scnt < timoutval THEN
            scnt <= scnt + 1;
         END IF;
      END IF;
   END PROCESS;
   -- windows are three samples wide, centered ON expected time
   halfbitime <= '1' WHEN (scnt > halfbit-2 AND scnt < halfbit+2) ELSE '0';
   bitime <= '1' WHEN (scnt > fullbit-2 AND scnt < fullbit+2) ELSE '0';
   halfsyntime <= '1' WHEN (scnt > halfsync-2 AND scnt < halfsync+2) ELSE '0';
   syntime <= '1' WHEN (scnt > fullsync-2 AND scnt < fullsync+2) ELSE '0';
   timeout <= '1' WHEN scnt = timoutval ELSE '0';
   --
   -- Three state machines used TO decode bit stream
   -- The sync state machine detects a valid sync waveform AND is reset by message END
   -- The bit state machine decodes manchester bits IF the sync is valid AND is reset by message END
   -- The message state machine reads OUT data bits WHEN valid, checks parity AND ends message WHEN completed
   --
   -- sync decoder detects valid sync input
   -- sync waveform starts WITH rising edge
   ssm: PROCESS (clk) BEGIN
      IF (clk'event AND clk = '1') THEN
         IF rst_clked = '0' THEN
            synstate <= idle;
            sync <= '0';
         ELSE
            CASE synstate IS
               WHEN idle =>
                  IF (edge = '1' AND posedge = '1') THEN
                     synstate <= e1;
                  END IF;
               WHEN e1 =>
                  IF (edge = '1' AND halfsyntime = '1') THEN -- expected edge
                     synstate <= synced;
                  ELSIF (edge = '1' AND halfsyntime = '0') THEN -- bad timing
                     synstate <= idle;
                  END IF;
               WHEN synced =>
                  IF (idone = '1' OR ierr = '1') THEN
                     sync <= '0';
                     synstate <= idle;
                  ELSE
                     sync <= '1';
                  END IF;
            END CASE;
         END IF;
      END IF;
   END PROCESS;
   -- decode manchester bit stream
   bsm: PROCESS (clk) BEGIN
      IF (clk'event AND clk = '1') THEN
         IF (idone = '1' OR rst_clked = '0') THEN
            bitstate <= idle;
            ierr <= '0';
            bout <= '0'; bready <= '0';
         ELSE
            CASE bitstate IS
               WHEN idle =>
                  ierr <= '0';
                  bready <= '0';
                  IF (sync = '1' AND edge = '1' AND halfsyntime = '1') THEN -- first bit is a 0
                     bitstate <= d0a;
                  ELSIF (sync = '1' AND edge = '1' AND syntime = '1') THEN -- first bit is a 1
                     bout <= '1';
                     bready <= '1';
                     bitstate <= d1b;
                  END IF;
               WHEN d0a => -- first half OF bit time, data bit is a zero
                  IF (edge = '1' AND halfbitime = '1') THEN -- second half OF bit time
                     bout <= '0';
                     bready <= '1';
                     bitstate <= d0b;
                  ELSIF (timeout = '1' OR edge = '1') THEN -- missing OR stray edge
                     ierr <= '1';
                     bitstate <= idle;
                  END IF;
               WHEN d0b => -- second half OF bit time, data bit is a zero
                  bready <= '0';
                  IF (edge = '1' AND halfbitime = '1') THEN -- another zero follows
                     bitstate <= d0a;
                  ELSIF (edge = '1' AND bitime = '1') THEN -- a one follows
                     bout <= '1';
                     bready <= '1';
                     bitstate <= d1b;
                  ELSIF (timeout = '1' OR edge = '1') THEN -- missing OR stray edge
                     ierr <= '1';
                     bitstate <= idle;
                  END IF;
               WHEN d1a => -- first half OF bit time, data bit is a one
                  IF (edge = '1' AND halfbitime = '1') THEN -- second half OF bit time
                     bout <= '1';
                     bready <= '1';
                     bitstate <= d1b;
                  ELSIF (timeout = '1' OR edge = '1') THEN -- missing OR stray edge
                     ierr <= '1';
                     bitstate <= idle;
                  END IF;
               WHEN d1b => -- second half OF bit time, data bit is a one
                  bready <= '0';
                  IF (edge = '1' AND halfbitime = '1') THEN -- another one follows
                     bitstate <= d1a;
                  ELSIF (edge = '1' AND bitime = '1') THEN -- a zero follows
                     bout <= '0';
                     bready <= '1';
                     bitstate <= d0b;
                  ELSIF (timeout = '1' OR edge = '1') THEN -- missing OR stray edge
                     ierr <= '1';
                     bitstate <= idle;
                  END IF;
            END CASE;
         END IF;
      END IF;
   END PROCESS;
   -- message sequence
   msm: PROCESS (clk) BEGIN
      IF (clk'event AND clk = '1') THEN
         IF rst_clked = '0' THEN
            msgstate <= idle; 
            par <= '0'; perr <= '0'; idone <= '0';
            odat <= (OTHERS => '0'); 
            bcnt <= 0; bcount <= 0;
         ELSE
           CASE msgstate IS
               WHEN idle =>
                  perr <= '0'; par <= '0';
                  IF (sync = '1' AND bready = '1') THEN -- WAIT FOR first data bit
                     odat(bcnt) <= bout;
                     bcnt <= bcnt + 1;
                     par <= par XOR bout;
                     msgstate <= busy;
                  END IF;
               WHEN busy =>
                  IF ierr = '1' THEN -- abort IF error
                     idone <= '1';
                     msgstate <= clear;
                  ELSIF bcnt < size THEN -- get remaining data bits
                     IF (sync = '1' AND bready = '1') THEN
                        odat(bcnt) <= bout;
                        bcount <= bcnt;
                        bcnt <= bcnt + 1;
                        par <= par XOR bout;
                     END IF;
                  ELSIF (sync = '1' AND bready = '1') THEN
                     idone <= '1';
                     msgstate <= clear;
                     IF bout /= par THEN -- parity bit is last, check IF ok
                        perr <= '1';
                     END IF;
                  END IF;
               WHEN clear => -- reset
                  idone <= '0';
                  IF (indat0 = '0' AND indat1 = '0') THEN
                     bcnt <= 0;
                     msgstate <= idle;
                  END IF;
            END CASE;
         END IF;
      END IF;
   END PROCESS;
   -- assign outputs
   done <= idone;
   err <= ierr OR perr;
END amtrigrec;  
--
-- NRZ serial reciever 
-- 
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY nrztrigrec IS 
   GENERIC (
      size:                         integer := 8;
      clkperbit:                    integer := 3); -- clocks per bit time
   PORT (
      clk, indat, rst:               IN std_logic;
		done, err:			   			 OUT std_logic;
      bcount:                        OUT integer RANGE 0 TO size-1;
      odat:                          OUT std_logic_vector(size-1 DOWNTO 0));
END nrztrigrec;
ARCHITECTURE anrztrigrec OF nrztrigrec IS
   TYPE stateType IS (idle,sync,dbit,pbit);
   SIGNAL state:                     stateType;
   SIGNAL scnt:                      integer RANGE 0 TO clkperbit*2-1;
   SIGNAL ocnt:                      integer RANGE 0 TO clkperbit*2-1;
   SIGNAL bcnt:                      integer RANGE 0 TO size-1;
   SIGNAL indat0, indat1:            std_logic;
   SIGNAL tbuf:                      std_logic_vector(size-1 DOWNTO 0);
   SIGNAL par:                       std_logic;
begin
   ASSERT (clkperbit > 1)
      report "clocks ber bit must be at least 2"
      SEVERITY FAILURE;
   -- input synchronizer
   isyn: PROCESS (clk, rst) BEGIN
      IF rst = '0' THEN
         indat0 <= '0'; indat1 <= '0';
      ELSIF (clk'event AND clk = '1') THEN -- do NOT change clock phase
         indat0 <= indat;
         indat1 <= indat0;
      END IF;
   END PROCESS;
   -- decode state machine
   sm: PROCESS (clk, rst) BEGIN
      IF rst = '0' THEN
         state <= idle;
         scnt <= 0; bcnt <= 0; done <= '0';
         par <= '0'; err <= '0'; ocnt <= 0;
         tbuf <= (OTHERS => '0'); odat <= (OTHERS => '0');
      ELSIF (clk'event AND clk = '1') THEN
         CASE state IS
            WHEN idle =>
               bcnt <= 0; par <= '0'; scnt <= 0;
               done <= '0'; err <= '0'; ocnt <= 0;
               IF indat1 = '1' THEN
                  scnt <= scnt + 1;
                  state <= sync;
               END IF;
            WHEN sync =>
               IF scnt < clkperbit*2-2 THEN -- look FOR start bits
                  scnt <= scnt + 1;
                  IF indat1 = '0' THEN
                    state <= idle; -- bad sync
                  END IF;
               ELSIF scnt = clkperbit*2-1 THEN
                  scnt <= 0;
                  state <= dbit; -- sync is good
               ELSE
                  scnt <= scnt + 1;
                  IF indat1 = '0' THEN
                     scnt <= 1;
                     state <= dbit; -- slipped a bit
                  END IF;
               END IF;
            WHEN dbit =>
               IF indat1 = '1' THEN
                  ocnt <= ocnt + 1;
               END IF;
               IF scnt = clkperbit-1 THEN -- END OF bit time
                  IF ocnt < clkperbit-2 THEN
                     tbuf(bcnt) <= '0';
                  ELSE
                     tbuf(bcnt) <= '1';
                     par <= par XOR '1';
                  END IF;
                  ocnt <= 0;
                  scnt <= 0;
                  IF bcnt = (size-1) THEN -- message END
                     state <= pbit;
                  ELSE
                     bcnt <= bcnt + 1;
                  END IF;
               ELSE
                  scnt <= scnt + 1;
               END IF;
            WHEN pbit =>
               IF indat1 = '1' THEN
                  ocnt <= ocnt + 1;
               END IF;
               IF scnt = clkperbit-1 THEN -- END OF bit time
                  IF ocnt < clkperbit-2 THEN
                     IF par /= '0' THEN
                        odat <= (OTHERS => '0');
                        err <= '1';
                     END IF;
                  ELSE
                     IF par /= '1' THEN
                        odat <= (OTHERS => '0');
                        err <= '1';
                     END IF;
                  END IF;
                  done <= '1';
                  odat <= tbuf;
                  state <= idle;
               ELSE
                  scnt <= scnt + 1;
               END IF;
         END CASE;
      END IF;
   END PROCESS;
	bcount <= bcnt;
END anrztrigrec;
