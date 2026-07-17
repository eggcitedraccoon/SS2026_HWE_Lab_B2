--------------------------------------------------------------------------------
-- pwm_generator_tb.vhd
--
-- Self-checking testbench for pwm_8bit. For each value in TEST_VALUES, it
-- applies the brightness, lets it settle for one clock, then counts how many
-- of the next 256 clock edges saw pwm_out high and compares that against the
-- expected value/256 ratio.
--
-- pwm_8bit has no reset -- its internal 8-bit counter free-runs from
-- power-up. That's not a problem here: the counter is a mod-256 counter, so
-- any window of exactly 256 consecutive clock edges visits every counter
-- value 0..255 exactly once regardless of the phase the window starts at.
-- The measured duty cycle is therefore exact, not just close, for every
-- brightness value.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_generator_tb is
end entity pwm_generator_tb;

architecture sim of pwm_generator_tb is

    constant CLK_PERIOD    : time    := 10 ns;  -- simulated clock period (value is arbitrary)
    constant PERIOD_CYCLES : integer := 256;    -- pwm_8bit's counter wraps every 256 clk cycles

    signal clk        : std_logic := '0';
    signal brightness : std_logic_vector(7 downto 0) := (others => '0');
    signal pwm_out    : std_logic;

    type value_array is array (natural range <>) of integer;
    constant TEST_VALUES : value_array := (0, 1, 64, 128, 192, 255);

begin

    ----------------------------------------------------------------------
    -- Device Under Test
    ----------------------------------------------------------------------
    dut : entity work.pwm_8bit
        port map (
            clk        => clk,
            brightness => brightness,
            pwm_out    => pwm_out
        );

    ----------------------------------------------------------------------
    -- Clock generation
    ----------------------------------------------------------------------
    clk <= not clk after CLK_PERIOD / 2;

    ----------------------------------------------------------------------
    -- Stimulus / self-checking process
    ----------------------------------------------------------------------
    stim_proc : process
        variable high_count    : integer;
        variable actual_duty   : real;
        variable expected_duty : real;
    begin

        for i in TEST_VALUES'range loop

            -- Apply the brightness value to test and let it settle through
            -- the comparator before sampling starts.
            brightness <= std_logic_vector(to_unsigned(TEST_VALUES(i), 8));
            wait until rising_edge(clk);

            -- Measure the duty cycle over exactly one full 256-cycle counter wrap
            high_count := 0;
            for cyc in 0 to PERIOD_CYCLES - 1 loop
                wait until rising_edge(clk);
                if pwm_out = '1' then
                    high_count := high_count + 1;
                end if;
            end loop;

            actual_duty   := (real(high_count) / real(PERIOD_CYCLES)) * 100.0;
            expected_duty := (real(TEST_VALUES(i)) / 256.0) * 100.0;

            report "value=" & integer'image(TEST_VALUES(i)) &
                   "  expected duty=" & real'image(expected_duty) & "%" &
                   "  measured duty=" & real'image(actual_duty) & "%";

            assert abs(actual_duty - expected_duty) < 1.0
                report "DUTY CYCLE MISMATCH for value=" & integer'image(TEST_VALUES(i))
                severity error;

        end loop;

        report "pwm_generator_tb finished. If no errors were reported above, all checks passed.";
        wait;  -- halt simulation here

    end process stim_proc;

end architecture sim;
