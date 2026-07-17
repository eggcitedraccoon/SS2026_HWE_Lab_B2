--------------------------------------------------------------------------------
-- pwm_generator_tb.vhd
--
-- Self-checking testbench for pwm_generator. For each value in TEST_VALUES,
-- it resets the DUT, lets it run for exactly one full PWM period, counts how
-- many clock cycles the output was high, and compares the measured duty
-- cycle against the expected value/256 ratio.
--
-- NOTE ON GENERICS: the DUT's CLK_FREQ_HZ / PWM_FREQ_HZ generics are
-- overridden here with small values (1024 Hz / 1 Hz) purely to make the
-- divider small (TICK_DIVIDER = 4), so the whole 256-step PWM period is
-- only 1024 simulated clock cycles -- keeping simulation fast. This does
-- NOT change the DUT's logic at all, it only affects how many cycles a
-- period takes. On real hardware you'd instantiate the DUT with the real
-- 100 MHz clock and your desired PWM frequency instead.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_generator_tb is
end entity pwm_generator_tb;

architecture sim of pwm_generator_tb is

    constant CLK_PERIOD      : time    := 10 ns;  -- simulated clock period (value is arbitrary)
    constant CLK_FREQ_HZ_TB  : integer := 1024;   -- see note above
    constant PWM_FREQ_HZ_TB  : integer := 1;      -- gives TICK_DIVIDER = 1024 / (1*256) = 4
    constant TICK_DIVIDER_TB : integer := CLK_FREQ_HZ_TB / (PWM_FREQ_HZ_TB * 256);
    constant PERIOD_CYCLES   : integer := TICK_DIVIDER_TB * 256; -- clk cycles in one full PWM period (1024)

    signal clk     : std_logic := '0';
    signal rst     : std_logic := '1';
    signal value   : std_logic_vector(7 downto 0) := (others => '0');
    signal pwm_out : std_logic;

    type value_array is array (natural range <>) of integer;
    constant TEST_VALUES : value_array := (0, 1, 64, 128, 192, 255);

begin

    ----------------------------------------------------------------------
    -- Device Under Test
    ----------------------------------------------------------------------
    dut : entity work.pwm_generator
        generic map (
            CLK_FREQ_HZ => CLK_FREQ_HZ_TB,
            PWM_FREQ_HZ => PWM_FREQ_HZ_TB
        )
        port map (
            clk     => clk,
            rst     => rst,
            value   => value,
            pwm_out => pwm_out
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

        -- Initial reset
        rst <= '1';
        wait for CLK_PERIOD * 5;
        rst <= '0';
        wait for CLK_PERIOD * 2;

        for i in TEST_VALUES'range loop

            -- Apply the brightness value to test
            value <= std_logic_vector(to_unsigned(TEST_VALUES(i), 8));

            -- Pulse reset so both internal counters restart cleanly at 0.
            -- This gives a known starting point so we can measure exactly
            -- one full period right after.
            rst <= '1';
            wait for CLK_PERIOD;
            rst <= '0';

            -- Measure the duty cycle over exactly one full PWM period
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