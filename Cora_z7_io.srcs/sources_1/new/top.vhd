----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Moafk Aljabi 
-- 
-- Create Date: 12/04/2025 01:19:46 PM
-- Design Name: 
-- Module Name: top - Behavioral
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

entity top is
    Port (
        clk     : in  STD_LOGIC;                     
        led0_r  : out STD_LOGIC;
        led0_g  : out STD_LOGIC;
        led0_b  : out STD_LOGIC;

        led1_r  : out STD_LOGIC;
        led1_g  : out STD_LOGIC;
        led1_b  : out STD_LOGIC;

        btn     : in  STD_LOGIC_VECTOR(1 downto 0)  
    );
end top;

architecture Structural of top is

    signal brightness  : STD_LOGIC;
    signal db_btn      : STD_LOGIC_VECTOR(1 downto 0);
    signal cd_count    : unsigned(25 downto 0) := (others => '0');
    signal led_shift   : STD_LOGIC_VECTOR(3 downto 0) := "0001";

    constant CD_COUNT_MAX : integer := 125000000/2;

begin

    ----------------------------------------------------------------------
    -- PWM Instance
    ----------------------------------------------------------------------
    pwm_inst : entity work.pwm
        generic map(
            COUNTER_WIDTH => 8,
            MAX_COUNT     => 255
        )
        port map(
            clk     => clk,
            duty    => x"7F",      -- 127 decimal
            pwm_out => brightness
        );

    ----------------------------------------------------------------------
    -- LED cycling at 2 Hz
    ----------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if cd_count = CD_COUNT_MAX-1 then
                cd_count <= (others => '0');
                -- rotate bits: 0001 -> 0010 -> 0100 -> 1000 -> ...
                led_shift <= led_shift(2 downto 0) & led_shift(3);
            else
                cd_count <= cd_count + 1;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------
    -- RGB LED outputs 
    ----------------------------------------------------------------------
    led0_r <= led_shift(2) and (brightness and not db_btn(0));
    led0_g <= led_shift(1) and (brightness and not db_btn(0));
    led0_b <= led_shift(0) and (brightness and not db_btn(0));

    led1_r <= led_shift(2) and (brightness and not db_btn(1));
    led1_g <= led_shift(1) and (brightness and not db_btn(1));
    led1_b <= led_shift(0) and (brightness and not db_btn(1));

    ----------------------------------------------------------------------
    -- Debouncer
    ----------------------------------------------------------------------
    debouncer_inst : entity work.debouncer
        generic map(
            WIDTH          => 2,
            CLOCKS         => 1024,
            CLOCKS_CLOG2   => 10
        )
        port map(
            clk   => clk,
            din   => btn,
            dout  => db_btn
        );

end Structural;
