entity FULLADDER_TB is
end entity;

architecture test of FULLADDER_TB is
    component FULLADDER is
        port (A,B,Ci: in bit;
            S,Co : out bit);
    end component;

    signal A, B, Ci, S, Co: bit;

begin
    UUT: FULLADDER port map (A, B, Ci, S, Co);

    process
    begin
        -- Test all 8 combinations
        A <= '0'; B <= '0'; Ci <= '0'; wait for 10 ns;
        assert (S = '0' and Co = '0') report "Test 000 failed" severity error;

        A <= '0'; B <= '0'; Ci <= '1'; wait for 10 ns;
        assert (S = '1' and Co = '0') report "Test 001 failed" severity error;

        A <= '0'; B <= '1'; Ci <= '0'; wait for 10 ns;
        assert (S = '1' and Co = '0') report "Test 010 failed" severity error;

        A <= '0'; B <= '1'; Ci <= '1'; wait for 10 ns;
        assert (S = '0' and Co = '1') report "Test 011 failed" severity error;

        A <= '1'; B <= '0'; Ci <= '0'; wait for 10 ns;
        assert (S = '1' and Co = '0') report "Test 100 failed" severity error;

        A <= '1'; B <= '0'; Ci <= '1'; wait for 10 ns;
        assert (S = '0' and Co = '1') report "Test 101 failed" severity error;

        A <= '1'; B <= '1'; Ci <= '0'; wait for 10 ns;
        assert (S = '0' and Co = '1') report "Test 110 failed" severity error;

        A <= '1'; B <= '1'; Ci <= '1'; wait for 10 ns;
        assert (S = '1' and Co = '1') report "Test 111 failed" severity error;

        wait;
    end process;
end architecture;
