entity CR_ADDER is
    port (A, B : in bit_vector(3 downto 0);
          Ci   : in bit;
          S    : out bit_vector(3 downto 0);
          Co   : out bit);
end entity;

architecture struct of CR_ADDER is

    component FULLADDER is
        port (A, B, Ci : in bit;
              S, Co    : out bit);
    end component;

    signal C : bit_vector(3 downto 1);

begin
    FA0: FULLADDER port map (A(0), B(0), Ci, S(0), C(1));
    FA1: FULLADDER port map (A(1), B(1), C(1), S(1), C(2));
    FA2: FULLADDER port map (A(2), B(2), C(2), S(2), C(3));
    FA3: FULLADDER port map (A(3), B(3), C(3), S(3), Co);

end architecture;
