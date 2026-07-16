library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity Double_Dabble_TB is

end Double_Dabble_TB;

architecture Behavioral of Double_Dabble_TB is

component DoubleDabbleTop is
    Port (  
        A : in std_logic_vector(7 downto 0);
        clk : in std_logic;
        start : in std_logic;
        rst : in std_logic;
        BCDDispData : out std_logic_vector(9 downto 0)
    );
end component;


Signal A : std_logic_vector(7 downto 0);
Signal clk : std_logic;
Signal start : std_logic;
Signal rst : std_logic;
Signal BCDDispData : std_logic_vector(9 downto 0);
constant clk_period : time := 10 ns;

begin

uut: DoubleDabbleTop
port map(A,clk,start,rst,BCDDispData);

clk_process : process
begin
clk <= '0';
wait for clk_period / 2;
clk <= '1';
wait for clk_period / 2;
end process;

stim_process: process
begin
    -- Initial reset sequence
    rst <= '1';
    A <= x"88"; --136 Decimal
    start <= '0';
    wait for 100ns;
    rst <= '0';
    wait for 100ns;
    start <= '1';
    wait for 20ns;
    start <= '0';
    
    wait;
end process;


end Behavioral;
