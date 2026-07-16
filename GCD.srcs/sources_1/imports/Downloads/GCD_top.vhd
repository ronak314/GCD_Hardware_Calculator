library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity GCD_top is
    port(
        A,B: in std_logic_vector(7 downto 0);
        start, rst, clk: in STD_LOGIC;
        Dis: out std_logic_vector(6 downto 0);
        Disp_en : out STD_LOGIC_VECTOR (3 downto 0)
    );
end;

architecture RTL of GCD_top is

-- Component declarations
component DoubleDabbleTop
    Port (  
        A : in std_logic_vector(7 downto 0);
        clk : in std_logic;
        start : in std_logic;
        rst : in std_logic;
        BCDDispData : out std_logic_vector(9 downto 0)
    );
end component;

component mux2x8 is
    port(A, B: in STD_LOGIC_VECTOR(7 downto 0);
         S: in STD_LOGIC;
         F: out STD_LOGIC_VECTOR(7 downto 0));
end component;

component Seven_Segment_Top
    Port ( Data : in STD_LOGIC_VECTOR (15 downto 0);
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           Disp_en : out STD_LOGIC_VECTOR (3 downto 0);
           Seven_Segment_out : out STD_LOGIC_VECTOR (6 downto 0));
end component;

component Reg8
    Port ( A : in STD_LOGIC_VECTOR(7 downto 0);
           en : in STD_LOGIC;
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           F : out STD_LOGIC_VECTOR(7 downto 0));
end component;

component Inverter
    Port ( A : in STD_LOGIC_VECTOR(7 downto 0);
           Inv : in STD_LOGIC;
           Output : out STD_LOGIC_VECTOR(7 downto 0));
end component;

component Comparator
    Port ( A : in STD_LOGIC_VECTOR(7 downto 0);
           B : in std_logic_vector(7 downto 0);
           AgB : out std_logic;
           AeqB : out std_logic;
           AlB : out std_logic);
end component;

component RCA8
    Port ( A : in STD_LOGIC_VECTOR (7 downto 0);
           B : in STD_LOGIC_VECTOR (7 downto 0);
           Sub : in STD_LOGIC;
           S : out STD_LOGIC_VECTOR (7 downto 0));
end component;

component GCD_ErrorCheck
    port(
        A, B : in std_logic_vector(7 downto 0);
        error : out std_logic
    );
end component;


-- FSM
type state_type is (IDLE, LOAD, COMPARE, SUB_AB, SUB_BA, DONE);
signal CS, NS : state_type;

-- Control signals
signal enA, enB : std_logic;
signal selA, selB : std_logic;
signal invA, invB : std_logic;
signal sub_ctrl : std_logic;
signal DDen : std_logic;

-- Datapath
signal Areg, Breg : std_logic_vector(7 downto 0);
signal A_muxout, B_muxout : std_logic_vector(7 downto 0);
signal A_inv, B_inv : std_logic_vector(7 downto 0);
signal Sum_out : std_logic_vector(7 downto 0);
signal AgB, AlB, AeqB : std_logic;
signal BCD_data : std_logic_vector(9 downto 0);
signal A_padded : std_logic_vector(15 downto 0);

-- Start button sync + latch
signal start_sync1, start_sync2 : std_logic;
signal start_latched : std_logic;

-- error checker
signal error_flag : std_logic;


begin



-------------------------------------------------------
-- Datapath connections
-------------------------------------------------------
MuxA: mux2x8 port map(A, Sum_out, selA, A_muxout);
MuxB: mux2x8 port map(B, Sum_out, selB, B_muxout);

RegA: Reg8 port map(A_muxout, enA, clk, rst, Areg);
RegB: Reg8 port map(B_muxout, enB, clk, rst, Breg);

InvA_inst: Inverter port map(Areg, invA, A_inv);
InvB_inst: Inverter port map(Breg, invB, B_inv);

RCA: RCA8 port map(A_inv, B_inv, sub_ctrl, Sum_out);

Comp: Comparator port map(Areg, Breg, AgB, AeqB, AlB);

DD : DoubleDabbleTop port map(Areg, clk, DDen, rst, BCD_data);

ErrorCheck: GCD_ErrorCheck port map(
    A => Areg,
    B => Breg,
    error => error_flag
);


-- Display padded BCD value
A_padded <= "000000" & BCD_data;

SSD: Seven_Segment_Top port map(
    Data => A_padded,
    clk => clk,
    rst => rst,
    Disp_en => Disp_en,
    Seven_Segment_out => Dis
);

-------------------------------------------------------
-- FSM combinational logic
-------------------------------------------------------
process(CS, start, AgB, AlB, AeqB, error_flag)
begin
    -- defaults
    enA <= '0';
    enB <= '0';
    selA <= '0';
    selB <= '0';
    invA <= '0';
    invB <= '0';
    sub_ctrl <= '0';
    DDen <= '0';
    NS <= CS;
    
    case CS is
        when IDLE =>
            if error_flag = '0' and start = '1' then
                NS <= LOAD; -- only start if inputs are valid
            else
                NS <= IDLE; -- stay idle if invalid or not started
            end if;

        when LOAD =>
            enA <= '1';
            enB <= '1';
            NS <= COMPARE;

        when COMPARE =>
            if AeqB = '1' then
                NS <= DONE;
            elsif AgB = '1' then
                NS <= SUB_AB;
            else
                NS <= SUB_BA;
            end if;

        when SUB_AB =>
            invB <= '1';
            selA <= '1';
            enA  <= '1';
            sub_ctrl <= '1';
            NS   <= COMPARE;

        when SUB_BA =>
            invA <= '1';
            selB <= '1';
            enB  <= '1';
            sub_ctrl <= '1';
            NS   <= COMPARE;

        when DONE =>
            DDen <= '1';
            NS <= IDLE;
    end case;
end process;


-------------------------------------------------------
-- FSM sequential logic
-------------------------------------------------------
sync: process(clk, rst)
begin
    if rst='1' then
        CS <= IDLE;
   --     start_latched <= '0';   -- clear latch on reset
    elsif rising_edge(clk) then
        CS <= NS;
   --     if CS = LOAD then
     --       start_latched <= '0';  -- clear after FSM sees start
      --  end if;
    end if;
end process;

end RTL;
