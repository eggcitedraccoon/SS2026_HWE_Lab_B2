entity CR_ADDER is
    port(
        A  : in  bit_vector(3 downto 0);
        B  : in  bit_vector(3 downto 0);
        Ci : in  bit;
        S  : out bit_vector(3 downto 0);
        Co : out bit
    );
end CR_ADDER;

architecture struct of CR_ADDER is

    component N_BIT_ADDER
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
    end component;

begin

    U1: N_BIT_ADDER
        generic map(
            N => 4
        )
        port map(
            A  => A,
            B  => B,
            Ci => Ci,
            S  => S,
            Co => Co
        );

end struct;
