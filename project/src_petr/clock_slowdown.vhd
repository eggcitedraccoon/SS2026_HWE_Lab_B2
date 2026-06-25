library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_slowdown is
    generic (
        DIVIDE_BY : positive := 1562500
    );
    port (
        clk       : in  std_logic;
        slow_tick : out std_logic
    );
end clock_slowdown;

architecture rtl of clock_slowdown is
    signal counter : integer range 0 to DIVIDE_BY - 1 := 0;
begin

    process(clk)
    begin
        if rising_edge(clk) then

            if counter = DIVIDE_BY - 1 then
                counter <= 0;
                slow_tick <= '1';
            else
                counter <= counter + 1;
                slow_tick <= '0';
            end if;

        end if;
    end process;

end rtl;