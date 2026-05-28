entity BCDto7seg is
    port(
        A  : in  bit_vector(3 downto 0);
        B  : in  bit_vector(3 downto 0);
        Ci : in  bit;

        seg_sum   : out bit_vector(6 downto 0);
        seg_carry : out bit_vector(6 downto 0)
    );
end BCDto7seg;


architecture struct of BCDto7seg is

    signal S_internal  : bit_vector(3 downto 0);
    signal Co_internal : bit;

    signal carry_bcd   : bit_vector(3 downto 0);

    component bcd_adder
        port(
            A  : in  bit_vector(3 downto 0);
            B  : in  bit_vector(3 downto 0);
            Ci : in  bit;

            S  : out bit_vector(3 downto 0);
            Co : out bit
        );
    end component;

    component bcd_to_7segment_conv
        port(
            bcd : in  bit_vector(3 downto 0);
            seg : out bit_vector(6 downto 0)
        );
    end component;

begin

    -- BCD adder
    ADDER: bcd_adder
        port map(
            A  => A,
            B  => B,
            Ci => Ci,
            S  => S_internal,
            Co => Co_internal
        );


    -- Convert carry bit to BCD digit:
    -- Co = 0 -> "0000"
    -- Co = 1 -> "0001"

    carry_bcd <= "0001" when Co_internal = '1' else "0000";


    -- Display the sum digit
    SUM_DISPLAY: bcd_to_7segment_conv
        port map(
            bcd => S_internal,
            seg => seg_sum
        );


    -- Display the carry digit
    CARRY_DISPLAY: bcd_to_7segment_conv
        port map(
            bcd => carry_bcd,
            seg => seg_carry
        );

end struct;