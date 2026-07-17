--------------------------------------------------------------------------------
-- rgb_blink_tb.vhd
--
-- Self-checking testbench for rgb_blink_top.
-- The timing generics are reduced so the blinking sequence simulates quickly.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity rgb_blink_tb is
end entity rgb_blink_tb;

architecture sim of rgb_blink_tb is

    constant CLK_PERIOD      : time    := 10 ns;
    constant CLK_FREQ_HZ_TB  : integer := 10;
    constant STEP_TIME_S_TB  : integer := 1;
    constant STEP_CYCLES_TB  : integer := CLK_FREQ_HZ_TB * STEP_TIME_S_TB;

    signal clk   : std_logic := '0';
    signal red   : std_logic;
    signal green : std_logic;
    signal blue  : std_logic;

begin

    ----------------------------------------------------------------------
    -- Device Under Test
    ----------------------------------------------------------------------
    dut : entity work.rgb_blink_top
        generic map (
            CLK_FREQ_HZ => CLK_FREQ_HZ_TB,
            STEP_TIME_S => STEP_TIME_S_TB
        )
        port map (
            CLK100MHZ => clk,
            LED16_R   => red,
            LED16_G   => green,
            LED16_B   => blue
        );

    ----------------------------------------------------------------------
    -- Clock generation
    ----------------------------------------------------------------------
    clk <= not clk after CLK_PERIOD / 2;

    ----------------------------------------------------------------------
    -- Stimulus / self-checking process
    ----------------------------------------------------------------------
    stim_proc : process
    begin
        wait for CLK_PERIOD;

        assert (red = '1' and green = '0' and blue = '0') report "Expected RED" severity error;
        wait for CLK_PERIOD * STEP_CYCLES_TB;

        assert (red = '0' and green = '0' and blue = '0') report "Expected OFF after RED" severity error;
        wait for CLK_PERIOD * STEP_CYCLES_TB;

        assert (red = '0' and green = '1' and blue = '0') report "Expected GREEN" severity error;
        wait for CLK_PERIOD * STEP_CYCLES_TB;

        assert (red = '0' and green = '0' and blue = '0') report "Expected OFF after GREEN" severity error;
        wait for CLK_PERIOD * STEP_CYCLES_TB;

        assert (red = '0' and green = '0' and blue = '1') report "Expected BLUE" severity error;
        wait for CLK_PERIOD * STEP_CYCLES_TB;

        assert (red = '0' and green = '0' and blue = '0') report "Expected OFF after BLUE" severity error;
        wait for CLK_PERIOD * STEP_CYCLES_TB;

        assert (red = '1' and green = '1' and blue = '0') report "Expected YELLOW" severity error;
        wait for CLK_PERIOD * STEP_CYCLES_TB;

        assert (red = '0' and green = '0' and blue = '0') report "Expected OFF after YELLOW" severity error;
        wait for CLK_PERIOD * STEP_CYCLES_TB;

        assert (red = '0' and green = '1' and blue = '1') report "Expected CYAN" severity error;
        wait for CLK_PERIOD * STEP_CYCLES_TB;

        assert (red = '0' and green = '0' and blue = '0') report "Expected OFF after CYAN" severity error;
        wait for CLK_PERIOD * STEP_CYCLES_TB;

        assert (red = '1' and green = '0' and blue = '1') report "Expected MAGENTA" severity error;
        wait for CLK_PERIOD * STEP_CYCLES_TB;

        assert (red = '0' and green = '0' and blue = '0') report "Expected OFF after MAGENTA" severity error;
        wait for CLK_PERIOD * STEP_CYCLES_TB;

        assert (red = '1' and green = '1' and blue = '1') report "Expected WHITE" severity error;
        wait for CLK_PERIOD * STEP_CYCLES_TB;

        assert (red = '0' and green = '0' and blue = '0') report "Expected OFF after WHITE" severity error;

       
                       report "rgb_blink_tb finished. If no errors were reported above, all checks passed.";

        assert false report "simulation finished" severity note;
        wait;

    end process stim_proc;

end architecture sim;