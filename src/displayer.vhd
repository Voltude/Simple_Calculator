----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.05.2022 18:30:54
-- Design Name: 
-- Module Name: displayer - Behavioral
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

entity displayer is
    generic (
        INPUT_SIZE : integer := 12
    );
    Port ( reset : in STD_LOGIC;
           clock : in STD_LOGIC;
           error : in STD_LOGIC;
           number : in std_logic_vector(INPUT_SIZE*2-1 downto 0);
           is_neg : in STD_LOGIC;
           AN : out STD_LOGIC_VECTOR (0 to 7);
           C : out STD_LOGIC_VECTOR (0 to 6));
end displayer;

architecture Behavioral of displayer is

    component BCD_to_7SEG is
		   Port ( bcd_in: in std_logic_vector (3 downto 0);	-- Input BCD vector
    			leds_out: out	std_logic_vector (0 to 6));		-- Output 7-Seg vector 
    end component BCD_to_7SEG;    

    signal input_value0, input_value1, input_value2, input_value3, input_value4, input_value5, input_value6 : std_logic_vector(6 downto 0) := (others => '0');
    
    signal bcd0, bcd1, bcd2, bcd3, bcd4, bcd5, bcd6 : std_logic_vector(3 downto 0) := (others => '0');
    
    signal SEL_AN : std_logic_vector(2 downto 0) := "000";
    signal temp_clock : std_logic;

begin

    clock_divider : entity work.clk_divider
        port map (
            clk_in => clock,
            clk_out => temp_clock);

    making_bcd : entity work.binary_bcd
        generic map (
            N => 24
        )
        port map (
            reset => reset, 
            clk => clock, 
            binary_in => number, 
            bcd0 => bcd0, 
            bcd1 => bcd1, 
            bcd2 => bcd2, 
            bcd3 => bcd3, 
            bcd4 => bcd4, 
            bcd5 => bcd5, 
            bcd6 => bcd6);
            
    INPUT_ANODE1 : BCD_to_7SEG port map (bcd_in => bcd0, leds_out => input_value0);
    INPUT_ANODE2 : BCD_to_7SEG port map (bcd_in => bcd1, leds_out => input_value1);
    INPUT_ANODE3 : BCD_to_7SEG port map (bcd_in => bcd2, leds_out => input_value2);
    INPUT_ANODE4 : BCD_to_7SEG port map (bcd_in => bcd3, leds_out => input_value3);  
    INPUT_ANODE5 : BCD_to_7SEG port map (bcd_in => bcd4, leds_out => input_value4);  
    INPUT_ANODE6 : BCD_to_7SEG port map (bcd_in => bcd5, leds_out => input_value5);  
    INPUT_ANODE7 : BCD_to_7SEG port map (bcd_in => bcd6, leds_out => input_value6);  
    
    sel : process (temp_clock)
        begin
            if rising_edge(temp_clock) then
                if SEL_AN = "000" then
                    AN <= "01111111";
                    if error = '0' then
                        C <= input_value0;
                    else
                        C <= "1111010";        -- spells 'r'
                    end if;
                    SEL_AN <= "001";    
                
                elsif SEL_AN = "001" then 
                    AN <= "10111111";
                    if error = '0' then
                        C <= input_value1;
                    else
                        C <= "1100010";         -- spells 'o'
                    end if;
                    SEL_AN <= "010"; 
                
                elsif SEL_AN = "010" then 
                    AN <= "11011111";
                    if error = '0' then
                        C <= input_value2;
                    else
                        C <= "1111010";          -- spells 'r'
                    end if;
                    SEL_AN <= "011";
                
                elsif SEL_AN = "011" then 
                    AN <= "11101111";
                    if error = '0' then
                        C <= input_value3;
                    else
                        C <= "1111010";            -- spells 'r'
                    end if;
                    SEL_AN <= "100";
                
                elsif SEL_AN = "100" then 
                    AN <= "11110111";
                    if error = '0' then
                        C <= input_value4;
                    else
                        C <= "0110000";          -- spells 'E'
                    end if;
                    SEL_AN <= "101";
                
                elsif SEL_AN = "101" then 
                    AN <= "11111011";
                    if error = '0' then
                        C <= input_value5;
                    else
                        C <= "1111111";
                    end if;
                    SEL_AN <= "110";
                
                elsif SEL_AN = "110" then 
                    AN <= "11111101";
                    if error = '0' then
                        C <= input_value6;
                    else
                        C <= "1111111";
                    end if;
                    SEL_AN <= "111";
                
                elsif SEL_AN = "111" then
                    AN <= "11111110";
                    if is_neg = '1' then
                        C <= "1111110";
                    else 
                        C <= "1111111";
                    end if;
                    SEL_AN <= "000";
                end if;
            end if;
    end process sel;    
end Behavioral;
