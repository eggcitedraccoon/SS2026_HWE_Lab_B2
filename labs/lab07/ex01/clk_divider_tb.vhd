--------------------------------------------------------------------------------
-- clk_divider_tb.vhd
--
-- Self-checking testbench for CLK_DIVIDER.
-- Verifies that CLK_N toggles exactly every N/2 rising edges of CLK, i.e.
-- that the period of CLK_N is N times the period of CLK.
--
-- Uses only the STANDARD VHDL library (type BIT, TIME, INTEGER) --
-- no IEEE / std_logic is used.
--------------------------------------------------------------------------------

entity CLK_DIVIDER_TB is
end entity CLK_DIVIDER_TB;

architecture test of CLK_DIVIDER_TB is

    constant N          : positive := 4;
    constant CLK_PERIOD : time     := 10 ns;

    signal clk   : bit := '0';
    signal clk_n : bit;

begin

    ----------------------------------------------------------------------
    -- Device Under Test
    ----------------------------------------------------------------------
    UUT: entity work.CLK_DIVIDER
        generic map (N => N)
        port map (CLK => clk, CLK_N => clk_n);

    ----------------------------------------------------------------------
    -- Clock generation
    ----------------------------------------------------------------------
    clk <= not clk after CLK_PERIOD / 2;

    ----------------------------------------------------------------------
    -- Self-checking process: measure the period between consecutive
    -- rising edges of CLK_N and compare it against N * CLK_PERIOD.
    ----------------------------------------------------------------------
    check_proc: process
        variable t_prev : time;
        variable t_now  : time;
    begin
        wait until clk_n'event and clk_n = '1';
        t_prev := now;

        for i in 1 to 5 loop
            wait until clk_n'event and clk_n = '1';
            t_now := now;
            assert (t_now - t_prev) = N * CLK_PERIOD
                report "CLK_N period incorrect on edge " & integer'image(i) &
                       ": expected " & time'image(N * CLK_PERIOD) &
                       ", got " & time'image(t_now - t_prev)
                severity error;
            t_prev := t_now;
        end loop;

        report "clk_divider_tb finished. If no errors were reported above, all checks passed.";
        assert false report "simulation finished" severity note;
        wait;
    end process check_proc;

end architecture test;
