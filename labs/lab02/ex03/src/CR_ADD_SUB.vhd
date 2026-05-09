entity CR_ADD_SUB is
    port(
        A    : in  bit_vector(3 downto 0);
        B    : in  bit_vector(3 downto 0);
        Ci   : in  bit;
        Cont : in  bit;
        S    : out bit_vector(3 downto 0);
        Co   : out bit
    );
end CR_ADD_SUB;

architecture struct of CR_ADD_SUB is

    signal B_mod : bit_vector(3 downto 0);

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

    B_mod <= B xor (Cont & Cont & Cont & Cont);

    U1: CR_ADDER
        port map(
            A  => A,
            B  => B_mod,
            Ci => Cont,
            S  => S,
            Co => Co
        );

end struct;
