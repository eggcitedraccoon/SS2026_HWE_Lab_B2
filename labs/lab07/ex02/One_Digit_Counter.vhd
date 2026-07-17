--------------------------------------------------------------------------------
-- One_Digit_Counter.vhd
--
-- Decimal (0-9) counter for the Nexys A7-100T board, displayed on one digit
-- of the on-board 7-segment display.
--   START_STOP : '1' -> counting enabled, '0' -> counting paused
--   CLEAR      : '1' -> synchronously resets the count to 0
--
-- The visible counting rate is derived from the 100 MHz on-board oscillator
-- with the CLK_DIVIDER module from Exercise 01, so the digit change is slow
-- enough for a human to see.
--
-- Uses only the STANDARD VHDL library (type BIT, BIT_VECTOR, INTEGER) --
-- no IEEE / std_logic is used, so no library/use clauses are needed.
--------------------------------------------------------------------------------

entity One_Digit_Counter is
    generic (
        DIVIDE_BY : positive := 100_000_000    -- CLK_DIVIDER factor N (must be even);
                                                -- 100_000_000 turns the 100 MHz board
                                                -- clock into a 1 Hz counting tick
    );
    port (
        CLK100MHZ  : in  bit;                      -- 100 MHz on-board oscillator
        START_STOP : in  bit;                      -- '1' = count, '0' = pause
        CLEAR      : in  bit;                      -- '1' = reset count to 0
        SEG        : out bit_vector(6 downto 0);   -- 7-segment cathodes CA..CG, active low
        AN         : out bit_vector(7 downto 0)    -- digit anode selects, active low
    );
end entity One_Digit_Counter;

architecture rtl of One_Digit_Counter is

    signal tick  : bit;
    signal digit : integer range 0 to 9 := 0;

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

    DIV: entity work.CLK_DIVIDER
        generic map (N => DIVIDE_BY)
        port map (CLK => CLK100MHZ, CLK_N => tick);

    count_proc: process (tick)
    begin
        if tick'event and tick = '1' then
            if CLEAR = '1' then
                digit <= 0;
            elsif START_STOP = '1' then
                if digit = 9 then
                    digit <= 0;
                else
                    digit <= digit + 1;
                end if;
            end if;
        end if;
    end process count_proc;

    SEG <= SEG_LUT(digit);

    -- only anode 0 enabled (active low); the other seven digits stay off
    AN <= "11111110";

end architecture rtl;
