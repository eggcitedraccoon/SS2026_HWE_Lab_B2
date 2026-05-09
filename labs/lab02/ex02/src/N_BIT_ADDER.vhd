entity N_BIT_ADDER is
    generic(
        N : integer := 4
    );
    port(
        A  : in  bit_vector(N-1 downto 0);
        B  : in  bit_vector(N-1 downto 0);
        Ci : in  bit;
        S  : out bit_vector(N-1 downto 0);
        Co : out bit
    );
end N_BIT_ADDER;

architecture struct of N_BIT_ADDER is

    signal C : bit_vector(N downto 0);

    component ADDER
        port(
            A  : in  bit;
            B  : in  bit;
            Ci : in  bit;
            S  : out bit;
            Co : out bit
        );
    end component;

begin

    C(0) <= Ci;
    Co <= C(N);

    gen_adders: for i in 0 to N-1 generate
        FA: ADDER
            port map(
                A  => A(i),
                B  => B(i),
                Ci => C(i),
                S  => S(i),
                Co => C(i+1)
            );
    end generate;

end struct;
