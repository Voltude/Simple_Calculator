----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.05.2022 18:22:59
-- Design Name: 
-- Module Name: test_fsm - Behavioral
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

entity fsm_tb is
--  Port ( );
end fsm_tb;

architecture Behavioral of fsm_tb is

    component fsm is
    generic (
           INPUT_SIZE : integer := 12
    );
    Port ( reset : in STD_LOGIC;
           clock : in STD_LOGIC;
           button : in STD_LOGIC;
           switches : in STD_LOGIC_VECTOR (INPUT_SIZE-1 downto 0);
           leds : out std_logic_vector (15 downto 0);
           display_number : out STD_LOGIC_VECTOR (INPUT_SIZE*2-1 downto 0);  
           is_neg : out std_logic;
           error : out STD_LOGIC);
    end component fsm;
    
    signal test_reset : std_logic := '0';
    signal test_clock : std_logic;
    signal test_button : std_logic;
    signal test_switches : std_logic_vector(11 downto 0);
    signal test_leds : std_logic_vector(15 downto 0);
    signal test_display_number : std_logic_vector(23 downto 0);
    signal test_is_neg : std_logic;
    signal test_error : std_logic;
    
    constant period : time := 1 us;

begin

    UUT: fsm port map (test_reset, test_clock, test_button, test_switches, test_leds, test_display_number, test_is_neg, test_error);
    
    clk : process
    begin
        test_clock <= '1';
        wait for period/2;
        test_clock <= '0';
        wait for period/2;
    end process;
   
    swtchs_btn : process
    begin
        test_button <= '0';
        wait for period;
        test_switches <= "000000000101";
        wait for period;
        test_button <= '1';
        wait for period;
        test_button <= '0';
        wait for period;
        test_switches <= "000000000011";
        wait for period;
        test_button <= '1';
        wait for period;
        test_button <= '0';
        wait for period;
        test_switches <= "000000000000";
        wait for period;
        test_button <= '1';
        wait for period;
        test_button <= '0';
        wait for period;
        test_switches <= "000000000000";
        wait for period;
        test_button <= '1';
        wait for period;
        test_button <= '0';
        std.env.stop;                  -- Stops the whole simulation here
    end process;
end Behavioral;
