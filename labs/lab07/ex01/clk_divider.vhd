--------------------------------------------------------------------------------
-- clk_divider.vhd
--
-- Generates CLK_N, a clock derived from CLK whose frequency is lower than
-- the frequency of CLK by the factor N (N must be an even integer >= 2).
--
-- Uses only the STANDARD VHDL library (type BIT, INTEGER, POSITIVE) --
-- no IEEE / std_logic is used, so no library/use clauses are needed.
--------------------------------------------------------------------------------

entity CLK_DIVIDER is
    generic (
        N : positive := 4      -- division factor, must be even and >= 2
    );
    port (
        CLK   : in  bit;
        CLK_N : out bit
    );
end entity CLK_DIVIDER;

architecture rtl of CLK_DIVIDER is
    signal counter : integer range 0 to N/2 - 1 := 0;
    signal clk_int : bit := '0';
begin

    assert (N >= 2) and (N mod 2 = 0)
        report "CLK_DIVIDER: generic N must be an even integer >= 2"
        severity failure;

    divide: process (CLK)
    begin
        if CLK'event and CLK = '1' then
            if counter = N/2 - 1 then
                counter <= 0;
                clk_int <= not clk_int;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process divide;

    CLK_N <= clk_int;

end architecture rtl;
