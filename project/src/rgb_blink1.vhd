--------------------------------------------------------------------------------
-- rgb_blink.vhd
--
-- Blink mode. Produces RGB signals for the top-level output mux.
-- through a repeated blink pattern:
--
--    RED -> OFF -> GREEN -> OFF -> BLUE -> OFF
--    YELLOW -> OFF -> CYAN -> OFF -> MAGENTA -> OFF -> WHITE -> OFF
--    -> loops back to RED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity rgb_blink_top is
    generic (
        CLK_FREQ_HZ : integer := 100_000_000;
        STEP_TIME_S : integer := 1
    );
    port (
        clk_mode0 : in  std_logic;
        rgb_r     : out std_logic;
        rgb_g     : out std_logic;
        rgb_b     : out std_logic
    );
end entity rgb_blink_top;

architecture rtl of rgb_blink_top is

    constant STEP_CYCLES : integer := CLK_FREQ_HZ * STEP_TIME_S;

    signal step_counter : integer range 0 to STEP_CYCLES - 1 := 0;
    signal step_tick    : std_logic := '0';

    signal phase : integer range 0 to 13 := 0;

begin

    ----------------------------------------------------------------------
    -- Step-rate generator:
    -- Emits one 'step_tick' pulse every STEP_CYCLES clock cycles.
    ----------------------------------------------------------------------
    step_div_proc : process(clk_mode0)
    begin
        if rising_edge(clk_mode0) then
            if step_counter = STEP_CYCLES - 1 then
                step_counter <= 0;
                step_tick    <= '1';
            else
                step_counter <= step_counter + 1;
                step_tick    <= '0';
            end if;
        end if;
    end process step_div_proc;

    ----------------------------------------------------------------------
    -- Blink sequencer:
    -- Advances through colour and OFF phases.
    ----------------------------------------------------------------------
    blink_proc : process(clk_mode0)
    begin
        if rising_edge(clk_mode0) then
            if step_tick = '1' then
                if phase = 13 then
                    phase <= 0;
                else
                    phase <= phase + 1;
                end if;
            end if;
        end if;
    end process blink_proc;

    ----------------------------------------------------------------------
    -- RGB output decoder:
    -- OFF phases drive all channels low.
    ----------------------------------------------------------------------
    rgb_r <= '1' when (phase = 0 or phase = 6 or phase = 10 or phase = 12) else '0';
    rgb_g <= '1' when (phase = 2 or phase = 6 or phase = 8  or phase = 12) else '0';
    rgb_b <= '1' when (phase = 4 or phase = 8 or phase = 10 or phase = 12) else '0';

end architecture rtl;
