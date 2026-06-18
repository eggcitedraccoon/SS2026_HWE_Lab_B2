--------------------------------------------------------------------------------
-- rgb_fade_top.vhd
--
-- Top-level design for the Nexys A7. Drives one onboard RGB LED (LED16)
-- through a continuous fade pattern:
--
--    Phase 0: RED   fades IN  (0 -> 255)   ~1 s
--    Phase 1: RED   fades OUT (255 -> 0)   ~1 s
--    Phase 2: GREEN fades IN  (0 -> 255)   ~1 s
--    Phase 3: GREEN fades OUT (255 -> 0)   ~1 s
--    Phase 4: BLUE  fades IN  (0 -> 255)   ~1 s
--    Phase 5: BLUE  fades OUT (255 -> 0)   ~1 s
--    -> loops back to phase 0
--
-- Each color gets a 2-second "in + out" cycle, and the full R -> G -> B
-- loop repeats every ~6 seconds, matching the timing you described. Only
-- one color is ever lit at a time; the other two channels are held at 0.
--
-- Port names (CLK100MHZ, LED16_R, LED16_G, LED16_B) match your provided
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

    -- 0:RED up, 1:RED down, 2:GREEN up, 3:GREEN down, 4:BLUE up, 5:BLUE down
    signal phase      : integer range 0 to 5 := 0;
    signal brightness : unsigned(7 downto 0) := (others => '0');

    signal r_value, g_value, b_value : std_logic_vector(7 downto 0);

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
    -- Fade sequencer: 6-phase state machine that ramps 'brightness' up or
    -- down and advances to the next phase once it hits the limit.
    ----------------------------------------------------------------------
    fade_proc : process(CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            if step_tick = '1' then
                case phase is
                    when 0 | 2 | 4 =>  -- "ramp up" phases (RED/GREEN/BLUE)
                        if brightness = 255 then
                            phase <= phase + 1;
                        else
                            brightness <= brightness + 1;
                        end if;

                    when 1 | 3 =>      -- "ramp down" phases, more colors follow
                        if brightness = 0 then
                            phase <= phase + 1;
                        else
                            brightness <= brightness - 1;
                        end if;

                    when 5 =>          -- final "ramp down" phase, loop back to phase 0
                        if brightness = 0 then
                            phase <= 0;
                        else
                            brightness <= brightness - 1;
                        end if;

                    when others =>
                        phase <= 0;
                end case;
            end if;
        end if;
    end process fade_proc;

    ----------------------------------------------------------------------
    -- Route the shared brightness ramp to whichever color is currently
    -- active; the other two channels are held off (value = 0).
    ----------------------------------------------------------------------
    r_value <= std_logic_vector(brightness) when (phase = 0 or phase = 1) else (others => '0');
    g_value <= std_logic_vector(brightness) when (phase = 2 or phase = 3) else (others => '0');
    b_value <= std_logic_vector(brightness) when (phase = 4 or phase = 5) else (others => '0');

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