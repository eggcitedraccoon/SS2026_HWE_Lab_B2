entity bcd_adder is
    port(
        A  : in  bit_vector(3 downto 0);
        B  : in  bit_vector(3 downto 0);
        Ci : in  bit;

        S  : out bit_vector(3 downto 0);
        Co : out bit
    );
end bcd_adder;


architecture struct of bcd_adder is

    signal raw_sum      : bit_vector(3 downto 0);
    signal raw_carry    : bit;

    signal correction   : bit;
    signal correction_v : bit_vector(3 downto 0);

    signal dummy_carry  : bit;

    component CR_ADDER
        port(
            A  : in  bit_vector(3 downto 0);
            B  : in  bit_vector(3 downto 0);
            Ci : in  bit;
            S  : out bit_vector(3 downto 0);
            Co : out bit
        );
    end component;

begin


    ADD1: CR_ADDER
        port map(
            A  => A,
            B  => B,
            Ci => Ci,
            S  => raw_sum,
            Co => raw_carry
        );


    correction <= raw_carry or (raw_sum(3) and raw_sum(2)) or (raw_sum(3) and raw_sum(1));


    correction_v(0) <= '0';
    correction_v(1) <= correction;
    correction_v(2) <= correction;
    correction_v(3) <= '0';


    -- Second adder corrects the BCD result
    ADD2: CR_ADDER
        port map(
            A  => raw_sum,
            B  => correction_v,
            Ci => '0',
            S  => S,
            Co => dummy_carry
        );


    -- Decimal carry out
    Co <= correction;

end struct;
