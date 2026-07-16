----------------------------------------------------------------------------------
-- Double Dabble
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DoubleDabbleTop is
    Port (  
        A : in std_logic_vector(7 downto 0);
        clk : in std_logic;
        start : in std_logic;
        rst : in std_logic;
        BCDDispData : out std_logic_vector(9 downto 0)
    );
end DoubleDabbleTop;

architecture Behavioral of DoubleDabbleTop is

    component comp is
    Port (  A : in std_logic_vector(3 downto 0);
            Flag : out std_logic);
    end component;

    component mux_8_to_4 is
    Port ( A : in STD_LOGIC_VECTOR (3 downto 0);
           B : in STD_LOGIC_VECTOR (3 downto 0);
           F : out STD_LOGIC_VECTOR (3 downto 0);
           sel : in STD_LOGIC);
    end component;

    component DFF_w_sel is
    Port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           F : out STD_LOGIC;
           sel, clk, rst, en: in STD_LOGIC);
    end component;

    component Add3 is
    Port ( A : in STD_LOGIC_VECTOR (3 downto 0);
           F : out STD_LOGIC_VECTOR (3 downto 0));
    end component;

    component counter is
    Port ( count, rst : in STD_LOGIC;
           F : out STD_LOGIC_VECTOR (3 downto 0));
    end component;

-- FSM State Declaration
    type state_type is (S0, S1, S2, S3, S4, S5);
	signal CS, NS: state_type;

    --signal galore
    signal InputShiftEn, OnesShiftEn, TensShiftEn, HundredsShiftEn : std_logic;
    signal DataLoad, OnesLoad, TensLoad : std_logic;
    signal OnesFlag, TensFlag : std_logic;
    signal OnesAddOut, TensAddOut : std_logic_vector(3 downto 0);
    signal Count : std_logic;
    signal CountOut : std_logic_vector(3 downto 0);
    signal CountRST : std_logic;
    signal DFFwire : std_logic_vector(17 downto 0);
    signal start_prev : std_logic := '0';
    signal start_rising : std_logic;

begin

process(clk)
begin
    if rising_edge(clk) then
        start_prev <= start;
    end if;
end process;

start_rising <= start and not start_prev;
----------------------------------------------------------------------------------
-- Input Shift Register Loads in A
----------------------------------------------------------------------------------
    DFF0 : DFF_w_sel
        port map('0', A(0), DFFwire(0), DataLoad, clk, CountRst, InputShiftEn);
    DFF1 : DFF_w_sel
        port map(DFFwire(0), A(1), DFFwire(1), DataLoad, clk, CountRst, InputShiftEn);
    DFF2 : DFF_w_sel
        port map(DFFwire(1), A(2), DFFwire(2), DataLoad, clk, CountRst, InputShiftEn);
    DFF3 : DFF_w_sel
        port map(DFFwire(2), A(3), DFFwire(3), DataLoad, clk, CountRst, InputShiftEn);
    DFF4 : DFF_w_sel
        port map(DFFwire(3), A(4), DFFwire(4), DataLoad, clk, CountRst, InputShiftEn);
    DFF5 : DFF_w_sel
        port map(DFFwire(4), A(5), DFFwire(5), DataLoad, clk, CountRst, InputShiftEn);
    DFF6 : DFF_w_sel
        port map(DFFwire(5), A(6), DFFwire(6), DataLoad, clk, CountRst, InputShiftEn);
    DFF7 : DFF_w_sel
        port map(DFFwire(6), A(7), DFFwire(7), DataLoad, clk, CountRst, InputShiftEn);
----------------------------------------------------------------------------------
-- Ones place registers
----------------------------------------------------------------------------------
    DFF8 : DFF_w_sel
        port map(DFFwire(7), OnesAddOut(0), DFFwire(8), OnesLoad, clk, CountRst, OnesShiftEn);
    DFF9 : DFF_w_sel
        port map(DFFwire(8), OnesAddOut(1), DFFwire(9), OnesLoad, clk, CountRst, OnesShiftEn);
    DFF10 : DFF_w_sel
        port map(DFFwire(9), OnesAddOut(2), DFFwire(10), OnesLoad, clk, CountRst, OnesShiftEn);
    DFF11 : DFF_w_sel
        port map(DFFwire(10), OnesAddOut(3), DFFwire(11), OnesLoad, clk, CountRst, OnesShiftEn);
    comp_ones: comp
        port map(DFFwire(11 downto 8), OnesFlag);
    Add3_ones: Add3
        port map(DFFwire(11 downto 8), OnesAddOut);
----------------------------------------------------------------------------------
-- Tens place registers
----------------------------------------------------------------------------------
    DFF12 : DFF_w_sel
        port map(DFFwire(11), TensAddOut(0), DFFwire(12), TensLoad, clk, CountRst, TensShiftEn);
    DFF13 : DFF_w_sel
        port map(DFFwire(12), TensAddOut(1), DFFwire(13), TensLoad, clk, CountRst, TensShiftEn);
    DFF14 : DFF_w_sel
        port map(DFFwire(13), TensAddOut(2), DFFwire(14), TensLoad, clk, CountRst, TensShiftEn);
    DFF15 : DFF_w_sel
        port map(DFFwire(14), TensAddOut(3), DFFwire(15), TensLoad, clk, CountRst, TensShiftEn);
    comp_tens: comp
        port map(DFFwire(15 downto 12), TensFlag);
    Add3_tens: Add3
        port map(DFFwire(15 downto 12), TensAddOut);
----------------------------------------------------------------------------------
-- Hundreds place registers
----------------------------------------------------------------------------------
    DFF16 : DFF_w_sel
        port map(DFFwire(15), '0', DFFwire(16), '0', clk, CountRst, HundredsShiftEn);
    DFF17 : DFF_w_sel
        port map(DFFwire(16), '0', DFFwire(17), '0', clk, CountRst, HundredsShiftEn);
----------------------------------------------------------------------------------
-- Connect the DFFs to the output
----------------------------------------------------------------------------------
    BCDDispData <= DFFwire(17 downto 8);
----------------------------------------------------------------------------------
-- Shift Counter
----------------------------------------------------------------------------------
    counter_inst : counter
        port map(Count, CountRst, CountOut);
----------------------------------------------------------------------------------
-- FSM Control
----------------------------------------------------------------------------------
    comb: process(CS, OnesFlag, TensFlag, start, CountOut(3))	-- Process Sensitivity List
	begin
		-- Set Defaults to prevent latches
		InputShiftEn <= '0';
        OnesShiftEn <= '0';
        TensShiftEn <= '0';
        HundredsShiftEn <= '0';
        DataLoad <= '0';
		OnesLoad <= '0';
		TensLoad <= '0';
		Count <= '0';
		CountRst <= '0';
		NS <= S0;
		
		-- Read the FSM implementation of the lab manual for help assigning values in each state. 
		case CS is
		
			--State Start
			when S0 =>
    CountRst <= '1';
    if start_rising = '1' then
        NS <= S1;
    else
        NS <= S0;
    end if;
			
			
		   --State Load
			when S1 =>
				-- Assert load Data
				DataLoad <= '1';
                InputShiftEn <= '1';
                -- Move to next state
				NS <= S2;
			
			-- State check if numby in ones or tens is greater than 4 and does addition if so.	
			when S2 =>
				-- Check if Ones or the Tens space is above 4
				if OnesFlag = '1' or TensFlag = '1' then
				    if OnesFlag = '1' then
                        OnesShiftEn <= '1'; --add 3 to ones place
                        OnesLoad <= '1';
                    end if;
                    if TensFlag = '1' then
                        TensShiftEn <= '1'; -- add 3 to tens place
                        TensLoad <= '1';
					end if;
				end if;
				NS <= S3;
			-- State Shift state
			when S3 =>
				InputShiftEn <= '1';
                OnesShiftEn <= '1';
                TensShiftEn <= '1';
                HundredsShiftEn <= '1';
                Count <= '1';
				NS <= S4;
			
			-- State S4
			when S4 =>
			if CountOut(3) = '0' then
                NS <= S2;
            else
                NS <= S5;
            end if;
            
            --State S5
            when S5 =>
				-- Check if input data is Ready/Valid
				if start = '0' then
					NS <= S5;
				else
					NS <= S1;
					CountRst <= '1';
				end if;
			end case;
	end process;

	-- Update Current State based on Next State Logic
	sync: process(clk, rst)
	begin
		if rst = '1' then
			CS <= S0;
		elsif rising_edge(clk) then
			CS <= NS;
		end if;
	end process;


end Behavioral;
