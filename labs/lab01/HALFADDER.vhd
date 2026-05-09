entity HALFADDER is
    port(
        A  : in  bit;
        B  : in  bit;
        S  : out bit;
        Co : out bit
    );
end HALFADDER;

architecture struct of HALFADDER is

    component XORGATTER
        port(
            X : in  bit;
            Y : in  bit;
            Z : out bit
        );
    end component;

    component ANDGATTER
        port(
            X : in  bit;
            Y : in  bit;
            Z : out bit
        );
    end component;

begin

    U1: XORGATTER
        port map(
            X => A,
            Y => B,
            Z => S
        );

    U2: ANDGATTER
        port map(
            X => A,
            Y => B,
            Z => Co
        );

end struct;
