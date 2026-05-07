entity CR_ADDER_TB is
end entity;

architecture test of CR_ADDER_TB is
    component CR_ADDER is
        port (A, B : in bit_vector(3 downto 0);
              Ci   : in bit;
              S    : out bit_vector(3 downto 0);
              Co   : out bit);
    end component;

    signal A, B, S : bit_vector(3 downto 0);
    signal Ci, Co  : bit;

begin
    UUT: CR_ADDER port map (A, B, Ci, S, Co);

    process
    begin
        -- Test Case 1: 0 + 0 + 0 = 0, Co=0
        A <= "0000"; B <= "0000"; Ci <= '0'; wait for 10 ns;
        assert (S = "0000" and Co = '0') report "Test 1 failed" severity error;

        -- Test Case 2: 1 + 1 + 0 = 2, Co=0
        A <= "0001"; B <= "0001"; Ci <= '0'; wait for 10 ns;
        assert (S = "0010" and Co = '0') report "Test 2 failed" severity error;

        -- Test Case 3: 15 + 1 + 0 = 16 (S=0, Co=1)
        A <= "1111"; B <= "0001"; Ci <= '0'; wait for 10 ns;
        assert (S = "0000" and Co = '1') report "Test 3 failed" severity error;

        -- Test Case 4: 10 + 5 + 0 = 15, Co=0
        A <= "1010"; B <= "0101"; Ci <= '0'; wait for 10 ns;
        assert (S = "1111" and Co = '0') report "Test 4 failed" severity error;

        -- Test Case 5: 10 + 5 + 1 = 16 (S=0, Co=1)
        A <= "1010"; B <= "0101"; Ci <= '1'; wait for 10 ns;
        assert (S = "0000" and Co = '1') report "Test 5 failed" severity error;

        -- Test Case 6: 15 + 15 + 1 = 31 (S=15, Co=1)
        A <= "1111"; B <= "1111"; Ci <= '1'; wait for 10 ns;
        assert (S = "1111" and Co = '1') report "Test 6 failed" severity error;

        wait;
    end process;
end architecture;
