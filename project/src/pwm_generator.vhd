--------------------------------------------------------------------------------
-- pwm_generator.vhd
--
-- Simple 8-bit PWM generator, intended for driving one channel of an RGB LED
-- (instantiate this module 3 times -- once each for R, G, and B -- to control
-- a full RGB LED).
--
-- HOW IT WORKS
--   1. A clock divider counts system clock cycles and produces a one-cycle
--      "tick" pulse at a reduced rate.
--   2. An 8-bit counter ("pwm_counter") increments by 1 on every tick. It
--      free-runs 0 -> 255 -> 0 -> 255 ... forever. This is the PWM "ramp".
--   3. The output is driven HIGH whenever pwm_counter < value, and LOW
--      otherwise. Since pwm_counter sweeps evenly through 0..255, the
--      fraction of time the output spends HIGH is value/256.
--
--      value = 0   -> output always LOW   (0% duty   -> LED off)
--      value = 128 -> output HIGH ~50% of the time    (~50% brightness)
--      value = 255 -> output HIGH 255/256 of the time (~99.6% duty, nearly
--                      full brightness -- note it is not a literal 100%,
--                      this is normal/expected for this common PWM scheme)
--
-- TIMING
--   The PWM period is divided into 256 steps. To get a PWM frequency around
--   PWM_FREQ_HZ, the system clock is divided down by TICK_DIVIDER so that
--   256 ticks occur in roughly 1/PWM_FREQ_HZ seconds:
--
--       TICK_DIVIDER = CLK_FREQ_HZ / (PWM_FREQ_HZ * 256)
--
--   This is integer division, so the actual PWM frequency will be close to,
--   but not exactly, PWM_FREQ_HZ (e.g. with the defaults below: 100 MHz and
--   a 1000 Hz target, TICK_DIVIDER works out to 390, giving an actual PWM
--   frequency of about 1001.6 Hz -- plenty close for driving an LED, where
--   anything from roughly 100 Hz to a few kHz looks flicker-free to the eye).
--
-- POLARITY
--   pwm_out is active-HIGH: '1' means "LED on". If your LED is wired common
--   anode (active-low), invert pwm_out (or invert it for that channel only)
--   before driving the physical pin.
--
-- RESET
--   rst is a synchronous, active-high reset. It is not strictly required
--   for correct behavior (Xilinx FPGA registers initialize to 0 from the
--   bitstream), but it's included as good practice and to allow forcing the
--   counters back to a known state on demand. If you don't need it, simply
--   tie rst to '0' in your top-level design.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_generator is
    generic (
        CLK_FREQ_HZ : integer := 100_000_000;  -- input clock frequency, Hz (Nexys A7 onboard clock)
        PWM_FREQ_HZ : integer := 1_000         -- target PWM frequency, Hz
    );
    port (
        clk     : in  std_logic;                      -- system clock
        rst     : in  std_logic;                       -- synchronous reset, active-high (tie to '0' if unused)
        value   : in  std_logic_vector(7 downto 0);     -- desired brightness, 0-255
        pwm_out : out std_logic                         -- PWM output, active-high ('1' = LED on)
    );
end entity pwm_generator;

architecture rtl of pwm_generator is

    -- Number of system clock cycles per "tick". 256 ticks make up one full
    -- PWM period, so this sets the overall PWM frequency.
    constant TICK_DIVIDER : integer := CLK_FREQ_HZ / (PWM_FREQ_HZ * 256);

    signal div_counter : integer range 0 to TICK_DIVIDER - 1 := 0;
    signal tick         : std_logic := '0';
    signal pwm_counter  : unsigned(7 downto 0) := (others => '0');

begin

    ----------------------------------------------------------------------
    -- Clock divider: emits a single-cycle 'tick' pulse every TICK_DIVIDER
    -- clock cycles. This is what slows the PWM ramp down from the raw
    -- system clock rate to something appropriate for an LED.
    ----------------------------------------------------------------------
    clk_divider_proc : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                div_counter <= 0;
                tick        <= '0';
            elsif div_counter = TICK_DIVIDER - 1 then
                div_counter <= 0;
                tick        <= '1';
            else
                div_counter <= div_counter + 1;
                tick        <= '0';
            end if;
        end if;
    end process clk_divider_proc;

    ----------------------------------------------------------------------
    -- 8-bit free-running ramp counter. Advances by 1 every time 'tick' is
    -- high, wrapping naturally from 255 back to 0 (unsigned overflow).
    ----------------------------------------------------------------------
    pwm_counter_proc : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                pwm_counter <= (others => '0');
            elsif tick = '1' then
                pwm_counter <= pwm_counter + 1;
            end if;
        end if;
    end process pwm_counter_proc;

    ----------------------------------------------------------------------
    -- Output comparator: HIGH while the ramp is below 'value'.
    -- This is what actually creates the variable duty cycle.
    ----------------------------------------------------------------------
    pwm_out <= '1' when (pwm_counter < unsigned(value)) else '0';

end architecture rtl;