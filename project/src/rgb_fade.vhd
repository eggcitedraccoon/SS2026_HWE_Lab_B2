--------------------------------------------------------------------------------
-- rgb_fade_top.vhd
--
-- Top-level design for the Nexys A7. Drives one onboard RGB LED (LED16)
-- through a continuous sequence of colors, taken from the COLOR_LIST
-- array below:
--
--    - fade IN  from black to COLOR_LIST(color_index)   (~1 s)
--    - fade OUT from that color back to black            (~1 s)
--    - advance color_index to the next entry in the array,
--      wrapping back to index 0 after the last entry
--
-- Each entry in COLOR_LIST can be ANY 8-bit (R,G,B) triplet -- not just
-- pure primaries -- e.g. (127, 60, 255) fades in/out correctly, with all
-- three channels scaled proportionally to the shared brightness ramp.
--
-- No enable/pause input here: the design is purely synchronous to
-- CLK100MHZ with no async resets and no PLL/MMCM, so if CLK100MHZ stops
-- toggling, every signal (including mid-fade state) simply holds where
-- it is. Gate/mux the clock upstream to pause and resume.
--
-- Port names (CLK100MHZ, LED16_R, LED16_G, LED16_B) match your existing
-- constraints file exactly, so this entity can be set as the top module
-- with no renaming needed.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rgb_fade_top is
    port (
        CLK100MHZ : in  std_logic;
        LED16_R   : out std_logic;
        LED16_G   : out std_logic;
        LED16_B   : out std_logic
    );
end entity rgb_fade_top;

architecture rtl of rgb_fade_top is

    constant CLK_FREQ_HZ : integer := 100_000_000;  -- Nexys A7 onboard clock
    constant RAMP_TIME_S : integer := 1;             -- seconds to ramp 0->255 (and 255->0)

    -- Clock cycles between each 1-step brightness change. 255 steps spread
    -- over STEP_CYCLES cycles each gives a ramp time of ~RAMP_TIME_S seconds.
    constant STEP_CYCLES : integer := (CLK_FREQ_HZ * RAMP_TIME_S) / 255;

    signal step_div_counter : integer range 0 to STEP_CYCLES - 1 := 0;
    signal step_tick        : std_logic := '0';

    ----------------------------------------------------------------------
    -- Color palette: add, remove, or reorder entries here. Any 8-bit
    -- (R,G,B) triplet is valid -- the fade math below scales each
    -- channel proportionally, so mixed/intermediate values work just
    -- as well as pure primaries. The sequencer automatically adapts to
    -- however many colors are in this list.
    ----------------------------------------------------------------------
    type color_t is record
        r : std_logic_vector(7 downto 0);
        g : std_logic_vector(7 downto 0);
        b : std_logic_vector(7 downto 0);
    end record;

    type color_array_t is array (natural range <>) of color_t;

    constant COLOR_LIST : color_array_t(0 to 8) := (
        (r => x"FF", g => x"00", b => x"00"),  -- Red
        (r => x"00", g => x"FF", b => x"00"),  -- Green
        (r => x"00", g => x"00", b => x"FF"),  -- Blue
        (r => x"FF", g => x"FF", b => x"00"),  -- Yellow
        (r => x"FF", g => x"00", b => x"FF"),  -- Magenta
        (r => x"00", g => x"FF", b => x"FF"),   -- Cyan
        (r => x"FF", g => x"7F", b => x"FF"),
        (r => x"7F", g => x"FF", b => x"FF"),
        (r => x"FF", g => x"FF", b => x"7F")
    );
    constant NUM_COLORS : integer := COLOR_LIST'length;

    signal color_index : integer range 0 to NUM_COLORS - 1 := 0;
    signal fading_out   : std_logic := '0';            -- '0' = fading in, '1' = fading out
    signal brightness   : unsigned(7 downto 0) := (others => '0');

    signal r_value, g_value, b_value : std_logic_vector(7 downto 0);

    ----------------------------------------------------------------------
    -- Scales one 8-bit color channel by an 8-bit brightness level
    -- (0-255). Taking the upper byte of the 16-bit product is the same
    -- as dividing by 256 (instead of 255) -- a tiny, visually
    -- imperceptible approximation that avoids needing a real divider.
    -- Works correctly for ANY channel value, not just 0 or 255.
    ----------------------------------------------------------------------
    function scale_channel(channel : std_logic_vector(7 downto 0);
                            level   : unsigned(7 downto 0))
                            return std_logic_vector is
        variable product : unsigned(15 downto 0);
    begin
        product := unsigned(channel) * level;
        return std_logic_vector(product(15 downto 8));
    end function scale_channel;

begin

    ----------------------------------------------------------------------
    -- Step-rate generator: emits one 'step_tick' pulse every STEP_CYCLES
    -- clock cycles. Each tick advances the fade by one brightness level.
    ----------------------------------------------------------------------
    step_div_proc : process(CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            if step_div_counter = STEP_CYCLES - 1 then
                step_div_counter <= 0;
                step_tick        <= '1';
            else
                step_div_counter <= step_div_counter + 1;
                step_tick        <= '0';
            end if;
        end if;
    end process step_div_proc;

    ----------------------------------------------------------------------
    -- Fade sequencer: for the current color_index, ramp brightness
    -- 0 -> 255 ("fading in"), then 255 -> 0 ("fading out"), then move on
    -- to the next color in COLOR_LIST, wrapping back to index 0 after
    -- the last entry. Purely synchronous to CLK100MHZ -- if the clock
    -- pauses, this pauses too, mid-cycle, with no extra logic required.
    ----------------------------------------------------------------------
    fade_proc : process(CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            if step_tick = '1' then
                if fading_out = '0' then
                    -- fading in toward the current color
                    if brightness = 255 then
                        fading_out <= '1';
                    else
                        brightness <= brightness + 1;
                    end if;
                else
                    -- fading out back to black
                    if brightness = 0 then
                        fading_out <= '0';
                        if color_index = NUM_COLORS - 1 then
                            color_index <= 0;
                        else
                            color_index <= color_index + 1;
                        end if;
                    else
                        brightness <= brightness - 1;
                    end if;
                end if;
            end if;
        end if;
    end process fade_proc;

    ----------------------------------------------------------------------
    -- Scale the active color's R/G/B channels by the current brightness
    -- level so all three channels rise and fall together, in proportion
    -- to the color's actual mix (not just on/off).
    ----------------------------------------------------------------------
    r_value <= scale_channel(COLOR_LIST(color_index).r, brightness);
    g_value <= scale_channel(COLOR_LIST(color_index).g, brightness);
    b_value <= scale_channel(COLOR_LIST(color_index).b, brightness);

    ----------------------------------------------------------------------
    -- One pwm_generator instance per color channel, all sharing the same
    -- system clock and a ~1 kHz PWM rate. No reset needed here, so it's
    -- tied to '0' on every instance.
    ----------------------------------------------------------------------
    red_pwm : entity work.pwm_generator
        generic map (
            CLK_FREQ_HZ => CLK_FREQ_HZ,
            PWM_FREQ_HZ => 1000
        )
        port map (
            clk     => CLK100MHZ,
            rst     => '0',
            value   => r_value,
            pwm_out => LED16_R
        );

    green_pwm : entity work.pwm_generator
        generic map (
            CLK_FREQ_HZ => CLK_FREQ_HZ,
            PWM_FREQ_HZ => 1000
        )
        port map (
            clk     => CLK100MHZ,
            rst     => '0',
            value   => g_value,
            pwm_out => LED16_G
        );

    blue_pwm : entity work.pwm_generator
        generic map (
            CLK_FREQ_HZ => CLK_FREQ_HZ,
            PWM_FREQ_HZ => 1000
        )
        port map (
            clk     => CLK100MHZ,
            rst     => '0',
            value   => b_value,
            pwm_out => LED16_B
        );

end architecture rtl;