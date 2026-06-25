--------------------------------------------------------------------------------
-- rgb_blink.vhd
--
-- Top-level design for the Nexys A7. Drives one onboard RGB LED (LED16)
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
        CLK100MHZ : in  std_logic;
        LED16_R   : out std_logic;
        LED16_G   : out std_logic;
        LED16_B   : out std_logic
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
    step_div_proc : process(CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
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
    blink_proc : process(CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
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
    LED16_R <= '1' when (phase = 0 or phase = 6 or phase = 10 or phase = 12) else '0';
    LED16_G <= '1' when (phase = 2 or phase = 6 or phase = 8  or phase = 12) else '0';
    LED16_B <= '1' when (phase = 4 or phase = 8 or phase = 10 or phase = 12) else '0';

end architecture rtl;