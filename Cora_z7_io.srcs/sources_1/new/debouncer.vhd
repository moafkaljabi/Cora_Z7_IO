----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/04/2025 01:19:46 PM
-- Design Name: 
-- Module Name: debouncer - Behavioral
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

entity debouncer is
    generic (
        WIDTH        : integer := 1;
        CLOCKS       : integer := 256;
        CLOCKS_CLOG2 : integer := 8
    );
    port (
        clk  : in  STD_LOGIC;
        din  : in  STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        dout : out STD_LOGIC_VECTOR(WIDTH-1 downto 0)
    );
end debouncer;

architecture Behavioral of debouncer is

    -- Internal storage for each bit
    type count_array is array (natural range <>) of unsigned(CLOCKS_CLOG2-1 downto 0);
    type flag_array  is array (natural range <>) of STD_LOGIC;
    type data_array  is array (natural range <>) of STD_LOGIC;

    signal count        : count_array(0 to WIDTH-1);
    signal transitioning : flag_array(0 to WIDTH-1);
    signal data         : data_array(0 to WIDTH-1);

begin
    gen_bits : for i in 0 to WIDTH-1 generate

        process(clk)
        begin
            if rising_edge(clk) then

                if transitioning(i) = '1' then
                    -- still waiting for stable input
                    if data(i) /= din(i) then
                        if count(i) >= CLOCKS-1 then
                            -- stable long enough , accept new value
                            data(i) <= din(i);
                            transitioning(i) <= '0';
                        else
                            -- increment timer
                            count(i) <= count(i) + 1;
                        end if;
                    else
                        -- bounced back , cancel transition
                        transitioning(i) <= '0';
                    end if;

                elsif data(i) /= din(i) then
                    -- detected a change , start timer
                    count(i) <= (others => '0');
                    transitioning(i) <= '1';
                end if;

            end if;
        end process;

        dout(i) <= data(i);

    end generate;

end Behavioral;
