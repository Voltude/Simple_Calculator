----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.05.2022 23:34:46
-- Design Name: 
-- Module Name: Testing_2 - Behavioral
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
use ieee.numeric_std.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity Calculator is
    generic (
        INPUT_SIZE : integer := 12
    );
    Port ( CLK100MHZ : in STD_LOGIC;
           SW : in STD_LOGIC_VECTOR (INPUT_SIZE-1 downto 0);
           BTNC : in STD_LOGIC;
           BTNR : in STD_LOGIC;
           LED : out std_logic_vector (15 downto 0);
           C : out STD_LOGIC_VECTOR (0 to 6);
           AN : out STD_LOGIC_VECTOR (0 to 7));
end Calculator;

architecture Structural of Calculator is

    signal number : std_logic_vector (INPUT_SIZE*2-1 downto 0);
    signal button_c : std_logic;
   
    
    signal error : std_logic;
    signal is_neg : std_logic;

    
begin

    debouncer : entity work.debounce
        port map (
            reset => BTNR,
            clock => CLK100MHZ, -- was 100MHZ
            input => BTNC,
            output => button_c);
            
    
    state_machine : entity work.fsm
        port map (
            reset => BTNR,
            clock => CLK100MHZ, -- 100mhz
            button => button_c,
            switches => SW,
            leds => LED,
            display_number => number,
            is_neg => is_neg,
            error => error);
            
    displaying : entity work.displayer
        port map (
            reset => BTNR,
            clock => CLK100MHZ,
            error => error,
            number => number,
            is_neg => is_neg,
            AN => AN,
            C => C);
end Structural;
