entity ADDER is
    port(
        A  : in  bit;
        B  : in  bit;
        Ci : in  bit;
        S  : out bit;
        Co : out bit
    );
end ADDER;

architecture struct of ADDER is

    signal C1 : bit;
    signal S1 : bit;
    signal C2 : bit;

    component HALFADDER
        port(
            A  : in  bit;
            B  : in  bit;
            S  : out bit;
            Co : out bit
        );
    end component;

    component ORGATTER
        port(
            X : in  bit;
            Y : in  bit;
            Z : out bit
        );
    end component;

begin

    U1: HALFADDER
        port map(
            A  => A,
            B  => B,
            S  => S1,
            Co => C1
        );

    U2: HALFADDER
        port map(
            A  => Ci,
            B  => S1,
            S  => S,
            Co => C2
        );

    U3: ORGATTER
        port map(
            X => C1,
            Y => C2,
            Z => Co
        );

end struct;
