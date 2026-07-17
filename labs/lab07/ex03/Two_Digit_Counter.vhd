--------------------------------------------------------------------------------
-- Two_Digit_Counter.vhd
--
-- Two-digit decimal (00-99) counter for the Nexys A7-100T board, displayed
-- on two digits of the on-board 7-segment display via time-multiplexing.
--   START_STOP : '1' -> counting enabled, '0' -> counting paused
--   CLEAR      : '1' -> synchronously resets the count to 00
--
-- Two instances of the CLK_DIVIDER module from Exercise 01 are reused:
--   - COUNT_DIV slows the 100 MHz board clock down to a human-visible
--     counting rate (default 1 Hz).
--   - MUX_DIV slows it down to a display refresh rate (default ~500 Hz per
--     digit); its square-wave output is used directly to select which of
--     the two digits (ones/tens) is currently driven onto SEG/AN, which is
--     exactly the multiplexed anode control described in the board's user
--     guide (only one digit's anode is active at a time, cycled fast enough
--     that persistence of vision makes both digits appear lit).
--
-- Uses only the STANDARD VHDL library (type BIT, BIT_VECTOR, INTEGER) --
-- no IEEE / std_logic is used, so no library/use clauses are needed.
--------------------------------------------------------------------------------

entity Two_Digit_Counter is
    generic (
        COUNT_DIVIDE_BY : positive := 100_000_000; -- CLK_DIVIDER N for the counting tick;
                                                     -- 100_000_000 -> 1 Hz from a 100 MHz clock
        MUX_DIVIDE_BY   : positive := 100_000       -- CLK_DIVIDER N for the display multiplex
                                                     -- rate; 100_000 -> ~500 Hz per digit
    );
    port (
        CLK100MHZ  : in  bit;                      -- 100 MHz on-board oscillator
        START_STOP : in  bit;                      -- '1' = count, '0' = pause
        CLEAR      : in  bit;                      -- '1' = reset count to 00
        SEG        : out bit_vector(6 downto 0);   -- 7-segment cathodes CA..CG, active low
        AN         : out bit_vector(7 downto 0)    -- digit anode selects, active low
    );
end entity Two_Digit_Counter;

architecture rtl of Two_Digit_Counter is

    signal count_tick : bit;  -- ~1 Hz, advances the two-digit count
    signal mux_tick   : bit;  -- ~500 Hz, selects which digit is shown

    signal tens : integer range 0 to 9 := 0;
    signal ones : integer range 0 to 9 := 0;

    -- active-low 7-segment patterns, indexed by decimal digit; bit order is
    -- SEG(6)=CA, SEG(5)=CB, SEG(4)=CC, SEG(3)=CD, SEG(2)=CE, SEG(1)=CF, SEG(0)=CG
    type seg_lut_t is array (0 to 9) of bit_vector(6 downto 0);
    constant SEG_LUT : seg_lut_t := (
        0 => "0000001",
        1 => "1001111",
        2 => "0010010",
        3 => "0000110",
        4 => "1001100",
        5 => "0100100",
        6 => "0100000",
        7 => "0001111",
        8 => "0000000",
        9 => "0000100"
    );

begin

    COUNT_DIV: entity work.CLK_DIVIDER
        generic map (N => COUNT_DIVIDE_BY)
        port map (CLK => CLK100MHZ, CLK_N => count_tick);

    MUX_DIV: entity work.CLK_DIVIDER
        generic map (N => MUX_DIVIDE_BY)
        port map (CLK => CLK100MHZ, CLK_N => mux_tick);

    count_proc: process (count_tick)
    begin
        if count_tick'event and count_tick = '1' then
            if CLEAR = '1' then
                tens <= 0;
                ones <= 0;
            elsif START_STOP = '1' then
                if ones = 9 then
                    ones <= 0;
                    if tens = 9 then
                        tens <= 0;
                    else
                        tens <= tens + 1;
                    end if;
                else
                    ones <= ones + 1;
                end if;
            end if;
        end if;
    end process count_proc;

    -- multiplexed display: mux_tick = '0' shows the ones digit on AN(0),
    -- mux_tick = '1' shows the tens digit on AN(1); all other anodes are off
    SEG <= SEG_LUT(ones) when mux_tick = '0' else SEG_LUT(tens);
    AN  <= "11111110"    when mux_tick = '0' else "11111101";

end architecture rtl;
