-- MUX 2x8

library ieee;
use ieee.std_logic_1164.all;
entity mux2x8 is
    port(A, B: in STD_LOGIC_VECTOR(7 downto 0);
                S: in STD_LOGIC;
                F: out STD_LOGIC_VECTOR(7 downto 0));
end mux2x8;
architecture behavior of mux2x8 is
    begin
        process (A, B, S)
        begin
        if S = '0' then
            F <= A;
        else
            F <= B;
        end if;
    end process;
end behavior;

-- SEVEN SEGMENT:
----------------------------------------------------------------------------------
-- 4-bit 4 to 1 Mux selecting specific inputs from the switches
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_16_to_4 is
    Port ( A : in STD_LOGIC_VECTOR (3 downto 0);
           B : in STD_LOGIC_VECTOR (3 downto 0);
           C : in STD_LOGIC_VECTOR (3 downto 0);
           D : in STD_LOGIC_VECTOR (3 downto 0);
           F : out STD_LOGIC_VECTOR (3 downto 0);
           sel : in STD_LOGIC_VECTOR (1 downto 0));
end mux_16_to_4;

architecture Behavioral of mux_16_to_4 is

begin

process(sel,A,B,C,D)
begin
    case sel is
        when "00" => F <= A;
        when "01" => F <= B;
        when "10" => F <= C;
        when "11" => F <= D;

        when others => F <= "0000";
    end case;
end process;

end Behavioral;

----------------------------------------------------------------------------------
-- Clock Divider 100Mhz / 2^19 to slow the clock down for the display
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Clk_Div is
    Port ( clk, rst : in STD_LOGIC;
           clk_div : out STD_LOGIC);
end Clk_Div;

architecture Behavioral of Clk_Div is

signal count : unsigned(31 downto 0);

begin

process(clk, rst)
begin
   if rst = '1' then
        count <= x"00000000";
   elsif rising_edge(clk) then
        count <= count +1;   
   end if;
    
end process;
clk_div <= count(18);
end Behavioral;

----------------------------------------------------------------------------------
-- 2-bit counter used to select which of the seven segment displays to display too
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Two_bit_counter is
    Port ( count_en : in STD_LOGIC;
           rst : in STD_LOGIC;
           F : out STD_LOGIC_VECTOR (1 downto 0));
end Two_bit_counter;

architecture Behavioral of Two_bit_counter is

signal F_temp : unsigned(1 downto 0);

begin

process(count_en, rst)
begin
    if rst = '1' then
        F_temp <= "00";
    elsif rising_edge(count_en) then
        F_temp <= F_temp + 1;
    end if;

end process;

F <= std_logic_vector(F_temp);

end Behavioral;

----------------------------------------------------------------------------------
-- This decoder takes the output from the counter and enables the PNP transistor driving the LEDs
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity One_cold_line_decoder is
    Port ( A : in STD_LOGIC_VECTOR (1 downto 0);
           F : out STD_LOGIC_VECTOR (3 downto 0));
end One_cold_line_decoder;

architecture Behavioral of One_cold_line_decoder is

begin
process(A)
begin
    case A is
        when "11" => F <= "1110";
        when "10" => F <= "1101";
        when "01" => F <= "1011";
        when "00" => F <= "0111";

        when others => F <= "1111";
    end case;
end process;


end Behavioral;

-- i dont know what this is 
----------------------------------------------------------------------------------
-- Top-Level Driver for seven segment display -missing a decoder
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Seven_Segment_Top is
    Port ( Data : in STD_LOGIC_VECTOR (15 downto 0);
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           Disp_en : out STD_LOGIC_VECTOR (3 downto 0);
           Seven_Segment_out : out STD_LOGIC_VECTOR (6 downto 0));
end Seven_Segment_Top;

architecture Behavioral of Seven_Segment_Top is

    component mux_16_to_4 is
        Port ( A : in STD_LOGIC_VECTOR (3 downto 0);
            B : in STD_LOGIC_VECTOR (3 downto 0);
            C : in STD_LOGIC_VECTOR (3 downto 0);
            D : in STD_LOGIC_VECTOR (3 downto 0);
            F : out STD_LOGIC_VECTOR (3 downto 0);
            sel : in STD_LOGIC_VECTOR (1 downto 0));
    end component;

    component Clk_Div is
        Port ( clk, rst : in STD_LOGIC;
            clk_div : out STD_LOGIC);
    end component;

    component Two_bit_counter is
        Port ( count_en : in STD_LOGIC;
            rst : in STD_LOGIC;
            F : out STD_LOGIC_VECTOR (1 downto 0));
    end component;

    component One_cold_line_decoder is
        Port ( A : in STD_LOGIC_VECTOR (1 downto 0);
            F : out STD_LOGIC_VECTOR (3 downto 0));
    end component;


component BCD_to_SevenSeg is
        Port ( A : in STD_LOGIC_VECTOR (3 downto 0);
               F : out STD_LOGIC_VECTOR (6 downto 0));
    end component;

    signal slow_clk : std_logic;
    signal count : std_logic_vector(1 downto 0);
    signal Mux_out : std_logic_vector(3 downto 0); --Output of the mux is connected to the input of the Seven segment decoder

begin

    Div: Clk_Div port map(clk, rst, slow_clk);

    counter: Two_bit_counter port map(slow_clk, rst, count);

    DisplaySelect: One_cold_line_decoder port map(count,Disp_en);

    MUX: mux_16_to_4 port map(Data(15 downto 12),Data(11 downto 8),Data(7 downto 4),Data(3 downto 0), Mux_out, count);

    decoder: BCD_to_SevenSeg port map(A => Mux_out, F => Seven_Segment_out);

end Behavioral;
 --REG8
 ----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/23/2025 05:29:26 PM
-- Design Name: 
-- Module Name: reigsterthing - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Reg8 is
    Port ( A : in STD_LOGIC_VECTOR (7 downto 0);
           en : in STD_LOGIC;
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           F : out STD_LOGIC_VECTOR (7 downto 0));
end entity Reg8;

architecture Behavioral of Reg8 is

begin

process(rst, clk)
 
begin
    if rst = '1' then
        F <= "00000000";
    elsif rising_edge(clk) and en = '1' then
            F <= A;
        end if;
  end process;

end Behavioral;
--
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/09/2025 06:07:54 PM
-- Design Name: 
-- Module Name: FA - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/09/2025 06:11:29 PM
-- Design Name: 
-- Module Name: RCA8 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RCA8 is
    Port ( A : in STD_LOGIC_VECTOR (7 downto 0);
           B : in STD_LOGIC_VECTOR (7 downto 0);
           Sub : in STD_LOGIC;
           S : out STD_LOGIC_VECTOR (7 downto 0));
end RCA8;

architecture Behavioral of RCA8 is

   component FA is
        Port ( A : in STD_LOGIC;
               B : in STD_LOGIC;
               Cin : in STD_LOGIC;
               S : out STD_LOGIC;
               Cout : out STD_LOGIC);
end component;

Signal carry1, carry2, carry3, carry4, carry5, carry6, carry7 : std_logic;
Signal notB : std_logic_vector(7 downto 0);
begin

--notB(0) <= B(0) xor Sub;
--(1) <= B(1) xor Sub;
--(2) <= B(2) xor Sub;
--notB(3) <= B(3) xor Sub;
--notB(4) <= B(4) xor Sub;
--(notB5) <= B(5) xor Sub;
--notB(6) <= B(6) xor Sub;
--notB(7) <= B(7) xor Sub;


FA0 : FA
port map (A(0), B(0), Sub, S(0), carry1);

FA1 : FA
port map (A(1), B(1), carry1, S(1), carry2);

FA2 : FA
port map (A(2), B(2), carry2, S(2), carry3);

FA3 : FA
port map (A(3), B(3), carry3, S(3), carry4);

FA4 : FA
port map (A(4), B(4), carry4, S(4), carry5);

FA5 : FA
port map (A(5), B(5), carry5, S(5), carry6);

FA6 : FA
port map (A(6), B(6), carry6, S(6), carry7);

FA7 : FA
port map (A(7), B(7), carry7, S(7), open);

end Behavioral;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FA is
    Port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           Cin : in STD_LOGIC;
           S : out STD_LOGIC;
           Cout : out STD_LOGIC);
end FA;

architecture Behavioral of FA is

begin

S <= A xor B xor Cin;
Cout <= (A and B) or (Cin and B) or (A and Cin);

end Behavioral;
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity Comparator is
    Port ( A : in STD_LOGIC_VECTOR(7 downto 0);
           B : in STD_LOGIC_VECTOR(7 downto 0);
           AgB : out STD_LOGIC;
           AeqB : out STD_LOGIC;
           AlB : out STD_LOGIC);
end Comparator;

architecture Behavioral of Comparator is

begin

AlB <= '1' when unsigned(A) < unsigned(B) else '0';
AgB <= '1' when unsigned(A) > unsigned(B) else '0';
AeqB <= '1' when unsigned(A) = unsigned(B) else '0';

end Behavioral;
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Inverter is
    Port (
        A : in STD_LOGIC_VECTOR(7 downto 0);
        Inv : in STD_LOGIC;
        Output : out STD_LOGIC_VECTOR(7 downto 0)
    );
end Inverter;

architecture RTL of Inverter is
begin
    Output <= (not A) when Inv = '1' else A;
end RTL;

-- error checker
-- Error check component for GCD_top
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity GCD_ErrorCheck is
    port(
        A, B : in std_logic_vector(7 downto 0);
        error : out std_logic
    );
end entity;

architecture RTL of GCD_ErrorCheck is
begin
    process(A, B)
    begin
        if A = "00000000" or B = "00000000" then
            error <= '1';  --  inputs zero, invalid
        else
            error <= '0';
        end if;
    end process;
end architecture;
