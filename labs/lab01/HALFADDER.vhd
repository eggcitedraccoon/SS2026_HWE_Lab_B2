entity HALFADDER is
    port (A,B: in bit;
        S,Co : out bit);
end entity;

architecture struct of HALFADDER is

    component XORGATTER is
        port (X,Y: in bit;
            Z    : out bit);
    end component;

    component ADDGATTER is
        port (X,Y: in bit;
            Z    : out bit);
    end component;

begin
    U1: XORGATTER
        port map(A, B, S);
    U2: ADDGATTER
        port map(A, B, Co);
end architecture;