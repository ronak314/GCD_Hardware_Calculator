----------------------------------------------------------------------------------
-- DFF
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DFF is
    Port (  D : in std_logic;
            clk, rst, en : in std_logic;
            Q : out std_logic);
end DFF;

architecture Behavioral of DFF is

begin

process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            Q <= '0';
        elsif en = '1' then
            Q <= D;
        end if;
    end if;
end process;

end Behavioral;

----------------------------------------------------------------------------------
-- Fixed comparator >4
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity comp is
    Port (  A : in std_logic_vector(3 downto 0);
            Flag : out std_logic);
end comp;

architecture Behavioral of comp is

begin
process(A)
begin
    case A is
        when "0000" => Flag <= '0';
        when "0001" => Flag <= '0';
        when "0010" => Flag <= '0';
        when "0011" => Flag <= '0';
        when "0100" => Flag <= '0';        

        when others => Flag <= '1';
    end case;
end process;

end Behavioral;


----------------------------------------------------------------------------------
-- 1-bit 2 to 1 Mux 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_2_to_1 is
    Port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           F : out STD_LOGIC;
           sel : in STD_LOGIC);
end mux_2_to_1;

architecture Behavioral of mux_2_to_1 is

begin

process(sel,A,B)
begin
    case sel is
        when '0' => F <= A;
        when '1' => F <= B;
        when others => F <= '0';
    end case;
end process;

end Behavioral;

----------------------------------------------------------------------------------
-- DFF with selectable input
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DFF_w_sel is
    Port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           F : out STD_LOGIC;
           sel, clk, rst, en : in STD_LOGIC);
end DFF_w_sel;

architecture Behavioral of DFF_w_sel is

    component DFF is
    Port (  D : in std_logic;
            clk, rst, en : in std_logic;
            Q : out std_logic);
    end component;

    component mux_2_to_1 is
    Port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           F : out STD_LOGIC;
           sel : in STD_LOGIC);
    end component;

    signal mux_out : std_logic;    

begin

    Mux : mux_2_to_1 
    port map(A,B,mux_out,sel);

    FLIPFLOP : DFF
    port map(mux_out,clk,rst,en,F);

end Behavioral;

----------------------------------------------------------------------------------
-- Fixed adder
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Add3 is
    Port ( A : in STD_LOGIC_VECTOR (3 downto 0);
           F : out STD_LOGIC_VECTOR (3 downto 0));
end Add3;

architecture Behavioral of Add3 is

    signal A_temp : unsigned(3 downto 0);

begin
    A_temp <= unsigned(A); -- we do a little bit of behavioral code around here, even if it is bit like cheating
    F <= std_logic_vector(A_temp + 3); -- just keeping the code short and easy to understand

end Behavioral;

----------------------------------------------------------------------------------
-- counter for controlling the number of shifts
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter is
    Port ( count, rst : in STD_LOGIC;
           F : out STD_LOGIC_VECTOR (3 downto 0));
end counter;

architecture Behavioral of counter is

    signal F_temp : unsigned(3 downto 0);

begin
process(count, rst)
begin
    if rst = '1' then
        F_temp <= "0000";
    elsif rising_edge(count) then
        F_temp <= F_temp + 1;
    end if;
    F <= std_logic_vector(F_temp);
end process;

end Behavioral;