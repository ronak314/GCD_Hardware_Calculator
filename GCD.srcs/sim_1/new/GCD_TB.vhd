library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity GCD_TB is
end GCD_TB;

architecture Behavioral of GCD_TB is

    component GCD_top is
        port(
            A, B     : in  std_logic_vector(7 downto 0);
            start,
            rst,
            clk      : in  std_logic;
            Dis      : out std_logic_vector(6 downto 0);
            Disp_en  : out std_logic_vector(3 downto 0)
        );
    end component;

    signal A, B     : std_logic_vector(7 downto 0);
    signal start    : std_logic;
    signal rst      : std_logic;
    signal clk      : std_logic;
    signal Dis      : std_logic_vector(6 downto 0);
    signal Disp_en  : std_logic_vector(3 downto 0);

    constant clk_period : time := 10 ns;

begin

    uut: GCD_top
        port map(
            A       => A,
            B       => B,
            start   => start,
            rst     => rst,
            clk     => clk,
            Dis     => Dis,
            Disp_en => Disp_en
        );

    ----------------------------------------
    -- CLOCK PROCESS
    ----------------------------------------
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;


    ----------------------------------------
    -- STIMULUS PROCESS (FIXED)
    ----------------------------------------
    stim_process: process
    begin
        ----------------------------------------------------
        -- RESET
        ----------------------------------------------------
        rst <= '1';
        start <= '0';
        A <= (others => '0');
        B <= (others => '0');
        wait for 50 ns;

        rst <= '0';
        wait for 50 ns;   -- ensure system is stable

        ----------------------------------------------------
        -- TEST CASE 1: A = 100, B = 10 → GCD = 10
        ----------------------------------------------------
        A <= std_logic_vector(to_unsigned(100,8));
        B <= std_logic_vector(to_unsigned(10,8));
        wait for 30 ns;

        start <= '1';
        wait for clk_period;
        start <= '0';

        wait for 300 ns;


        ----------------------------------------------------
        -- TEST CASE 2: A = 15, B = 10 → GCD = 5
        ----------------------------------------------------
        A <= std_logic_vector(to_unsigned(15,8));
        B <= std_logic_vector(to_unsigned(10,8));
        wait for 30 ns;

        start <= '1';
        wait for clk_period;
        start <= '0';

        wait for 300 ns;


        ----------------------------------------------------
        -- TEST CASE 3: A = 42, B = 6 → GCD = 6
        ----------------------------------------------------
        A <= std_logic_vector(to_unsigned(42,8));
        B <= std_logic_vector(to_unsigned(6,8));
        wait for 30 ns;

        start <= '1';
        wait for clk_period;
        start <= '0';

        wait for 300 ns;

        wait;
    end process;

end Behavioral;
