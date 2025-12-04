----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/04/2025 01:19:46 PM
-- Design Name: 
-- Module Name: pwm - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity pwm is
    generic (
        COUNTER_WIDTH : integer := 8;
        MAX_COUNT     : integer := 255
    );
    port (
        clk     : in  STD_LOGIC;
        duty    : in  STD_LOGIC_VECTOR(COUNTER_WIDTH-1 downto 0);
        pwm_out : out STD_LOGIC
    );
end pwm;

architecture Behavioral of pwm is

    signal count  : unsigned(COUNTER_WIDTH-1 downto 0) := (others => '0');
    signal r_duty : unsigned(COUNTER_WIDTH-1 downto 0) := (others => '0');

begin

    ----------------------------------------------------------------------
    -- Latch duty cycle when the PWM counter wraps
    ----------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if count = 0 then
                r_duty <= unsigned(duty);
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------
    -- Up-counter maxed at MAX_COUNT
    ----------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if count >= MAX_COUNT then
                count <= (others => '0');
            else
                count <= count + 1;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------
    -- PWM output
    ----------------------------------------------------------------------
    pwm_out <= '1' when count >= r_duty else '0';

end Behavioral;
