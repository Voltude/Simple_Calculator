----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.05.2022 09:52:44
-- Design Name: 
-- Module Name: fsm - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fsm is
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
end fsm;

architecture Behavioral of fsm is

    type state_t is (NUM1, NUM2, OPERATOR, CALC);
    signal state : state_t := NUM1;
    
    
    type operation_t is (ADD, SUB, MUL, DIV, EXP, ERR);
    signal operation : operation_t := ADD;
    
    signal number1 : unsigned (INPUT_SIZE-2 downto 0);
    signal number2 : unsigned (INPUT_SIZE-2 downto 0);
    signal answer : std_logic_vector(INPUT_SIZE*2-3 downto 0);
   
    
    alias state_leds : std_logic_vector(3 downto 0) is leds(leds'high downto leds'high-3);
    alias switch_leds : std_logic_vector(INPUT_SIZE-1 downto 0) is leds(INPUT_SIZE-1 downto 0);
    
    signal calc_error : std_logic;
    

begin

    with state select state_leds <=
        "1000" when NUM1,
        "0100" when NUM2,
        "0010" when OPERATOR,
        "0001" when CALC,
        "1000" when others;
        
    with state select switch_leds <=
        switches when NUM1,
        switches when NUM2,
        switches when OPERATOR,
        (others => '0') when others;
        
        
    with switches(2 downto 0) select operation <=
        ADD when "000",
        SUB when "001",
        MUL when "010",
        DIV when "011",
        EXP when "100",
        ERR when others;
       

    process (clock, reset) 
        variable next_state : boolean := false;
        variable prev_button : std_logic := '0';
        variable div_count : integer := 0;
        variable power_count : integer := 0;

        variable negative : boolean := false;
        variable dividing : boolean := false;
        
        variable temp_num1 :  unsigned (INPUT_SIZE-2 downto 0);
        variable temp_num2 :  unsigned (INPUT_SIZE-2 downto 0);
        variable temp_num3 :  unsigned (INPUT_SIZE-2 downto 0);
        variable temp_num4 :  unsigned (INPUT_SIZE-2 downto 0);
        
        variable num1_neg : boolean := false;
        variable num2_neg : boolean := false;
        
        variable operand_error : std_logic := '0';
        variable div_error : std_logic := '0';
        variable exp_error : std_logic := '0';
        
        variable temp_number : unsigned((INPUT_SIZE - 1) * 4 - 1 downto 0) := to_unsigned(1, (INPUT_SIZE - 1) * 4);
    begin
        if reset = '1' then
            display_number <= (others => '0');
            error <= '0';
            number1 <= (others => '0');
            number2 <= (others => '0');
            answer <= (others => '0');
            div_error := '0';
            
        elsif rising_edge (clock) then
            next_state := prev_button = '0' and button = '1';
            prev_button := button;
            
            case (state) is 
                when NUM1 =>
                    if switches (11) = '1' then
                        is_neg <= '1';
                        num1_neg := true;
                    else 
                        is_neg <= '0';
                        num1_neg := false;
                    end if;
                    display_number <= "0000000000000" & switches(INPUT_SIZE -2 downto 0);                
                    if next_state then
                        number1 <= unsigned(switches(INPUT_SIZE -2 downto 0));
                        temp_num1 := unsigned(switches(INPUT_SIZE -2 downto 0));
                        state <= NUM2;
                    end if;
                when NUM2 =>
                    if switches (11) = '1' then
                        is_neg <= '1';
                        num2_neg := true;
                    else 
                        is_neg <= '0';
                        num2_neg := false;            
                    end if;
                    display_number <= "0000000000000" & switches(INPUT_SIZE -2 downto 0);
                    if next_state then
                        number2 <= unsigned(switches(INPUT_SIZE -2 downto 0));
                        temp_num2 := unsigned(switches(INPUT_SIZE -2 downto 0));
                        state <= OPERATOR;
                    end if;
                when OPERATOR => 
                    is_neg <= '0';
                    display_number <= "000000000000000000000" & switches(2 downto 0);
                    case operation is 
                        when ADD =>
                            operand_error := '0';
                            exp_error := '0';
                            if num1_neg = false and num2_neg = false then
                                answer <= "00000000000" & std_logic_vector(number1 + number2);
                            elsif num1_neg = true and num2_neg = false then
                                if number1 > number2 then
                                    answer <= "00000000000" & std_logic_vector(number1 - number2);
                                    negative := true;
                                elsif number1 = number2 then
                                    answer <= "00000000000" & std_logic_vector(number1 - number2);
                                    negative := false;
                                else
                                    answer <= "00000000000" & std_logic_vector(number2 - number1);
                                    negative := false;
                                end if;
                            elsif num1_neg = false and num2_neg = true then
                                if number1 > number2 then
                                    answer <= "00000000000" & std_logic_vector(number1 - number2);
                                    negative := false;
                                elsif number1 = number2 then
                                    answer <= "00000000000" & std_logic_vector(number1 - number2);
                                    negative := false;
                                else
                                    answer <= "00000000000" & std_logic_vector(number2 - number1);
                                    negative := true;
                                end if;
                            else
                                answer <= "00000000000" & std_logic_vector(number1 + number2);
                                negative := true;
                            end if;
                        when SUB =>
                            operand_error := '0';
                            exp_error := '0';
                            if num1_neg = false and num2_neg = false then
                                if number1 >= number2 then
                                    answer <= "00000000000" & std_logic_vector(number1 - number2);
                                    negative := false;
                                else
                                    answer <= "00000000000" & std_logic_vector(number2 - number1);
                                    negative := true;
                                end if;
                            elsif num1_neg = true and num2_neg = false then
                                answer <= "00000000000" & std_logic_vector(number1 + number2);
                                negative := true;
                            elsif num1_neg = false and num2_neg = true then
                                answer <= "00000000000" & std_logic_vector(number1 + number2);
                                negative := false;
                            else
                                if number1 > number2 then
                                    answer <= "00000000000" & std_logic_vector(number1 - number2);
                                    negative := true;
                                elsif number1 = number2 then
                                    answer <= "00000000000" & std_logic_vector(number1 - number2);
                                    negative := false;
                                else
                                    answer <= "00000000000" & std_logic_vector(number2 - number1);
                                    negative := false;
                                end if;
                            end if;
                        when MUL =>
                            operand_error := '0';
                            exp_error := '0';
                            if (num1_neg = false and num2_neg = false) or (num1_neg = true and num2_neg = true) then
                                answer <= std_logic_vector (number1 * number2);
                                negative := false;
                            else 
                                answer <= std_logic_vector(number1 * number2);
                                negative := true;
                            end if;
                        when DIV =>
                            operand_error := '0';
                            exp_error := '0';
                            if number2 = 0 then
                                div_error := '1';
                                negative := false;
                            elsif temp_num1 < temp_num2 and dividing = false then
                                answer <= (others => '0');
                            else
                                dividing := true;
                                if temp_num1 >= temp_num2 then
                                    temp_num1 := temp_num1 - temp_num2;
                                    div_count := div_count + 1;
                                else
                                    if (num1_neg = false and num2_neg = false) or (num1_neg = true and num2_neg = true) then
                                        negative := false;
                                    else
                                        negative := true;
                                    end if;
                                    answer <= std_logic_vector(to_unsigned(div_count, answer'length));
                                end if;
                            end if;
                        when EXP =>
                            operand_error := '0';
                            if num2_neg = false then
                                if power_count < number2 and exp_error = '0' then
                                    temp_number := temp_number((number1'length) * 2 -1  downto 0) * unsigned("00000000000" & std_logic_vector(number1));
                                    power_count := power_count + 1;
                                    if temp_number > 9999999 then
                                        exp_error := '1';
                                    end if;
                                end if;
                                if power_count = number2 then
                                    answer <= std_logic_vector(temp_number(answer'length-1 downto 0));
                                    if number2(0) = '1' and num1_neg then
                                        negative := true;
                                    else
                                        negative := false;
                                    end if;
                                end if;
                            else
                                power_count := 0;
                                operand_error := '1';
                            end if;
                        when ERR =>
                            operand_error := '1';
                    end case;
                    if next_state then
                        state <= CALC;
                        calc_error <= operand_error or div_error or exp_error;
                    end if;
                when CALC => 
                    display_number <= "00" & answer;
                    if negative then    
                        is_neg <= '1';
                    else 
                        is_neg <= '0';
                    end if;
                    
                    error <= calc_error;
                    
                    if next_state then
                        state <= NUM1;
                        negative := false;
                        error <= '0';
                        calc_error <= '0';
                        div_count := 0;
                        div_error := '0';
                        exp_error := '0';
                        operand_error := '0';
                        is_neg <= '0';
                        num1_neg := false;
                        num2_neg := false;
                        operand_error := '0';
                        power_count := 0;
                        dividing := false;
                        temp_num1 := (others => '0');
                        temp_num2 := (others => '0');
                        temp_number := to_unsigned(1, temp_number'length);
                    end if;
            end case;
        end if;
    end process;
end Behavioral;

