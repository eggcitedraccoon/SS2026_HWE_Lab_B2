entity FULLADDER is
    port (A,B,Ci: in bit;
        S,Co : out bit);
end entity;

architecture struct of FULLADDER is

    component HALFADDER is
        port (A,B: in bit;
            S,Co : out bit);
    end component;

    component ORGATTER is
        port (X,Y: in bit;
            Z    : out bit);
    end component;

    signal S1, C1, C2: bit;

begin
    U1: HALFADDER
        port map(A, B, S1, C1);
    U2: HALFADDER
        port map(S1, Ci, S, C2);
    U3: ORGATTER
        port map(C1, C2, Co);
end architecture;