entity CR_ADD_SUB_TB is
end CR_ADD_SUB_TB;

architecture test of CR_ADD_SUB_TB is

    signal A_tb    : bit_vector(3 downto 0) := "0000";
    signal B_tb    : bit_vector(3 downto 0) := "0000";
    signal Ci_tb   : bit := '0';
    signal Cont_tb : bit := '0';

    signal S_tb  : bit_vector(3 downto 0);
    signal Co_tb : bit;

    component CR_ADD_SUB
        port(
            A    : in  bit_vector(3 downto 0);
            B    : in  bit_vector(3 downto 0);
            Ci   : in  bit;
            Cont : in  bit;
            S    : out bit_vector(3 downto 0);
            Co   : out bit
        );
    end component;

begin

    UUT: CR_ADD_SUB
        port map(
            A    => A_tb,
            B    => B_tb,
            Ci   => Ci_tb,
            Cont => Cont_tb,
            S    => S_tb,
            Co   => Co_tb
        );

    stimulus: process
    begin
        A_tb <= "0011"; B_tb <= "0100"; Ci_tb <= '0'; Cont_tb <= '0';
        wait for 10 ns;
        assert S_tb = "0111" and Co_tb = '0'
            report "FAILED ADD: 0011 + 0100 should be 0111 carry 0"
            severity error;

        A_tb <= "1111"; B_tb <= "0001"; Ci_tb <= '0'; Cont_tb <= '0';
        wait for 10 ns;
        assert S_tb = "0000" and Co_tb = '1'
            report "FAILED ADD: 1111 + 0001 should be 0000 carry 1"
            severity error;

        A_tb <= "0111"; B_tb <= "0001"; Ci_tb <= '0'; Cont_tb <= '1';
        wait for 10 ns;
        assert S_tb = "0110" and Co_tb = '1'
            report "FAILED SUB: 0111 - 0001 should be 0110 no-borrow 1"
            severity error;

        A_tb <= "0101"; B_tb <= "0101"; Ci_tb <= '0'; Cont_tb <= '1';
        wait for 10 ns;
        assert S_tb = "0000" and Co_tb = '1'
            report "FAILED SUB: 0101 - 0101 should be 0000 no-borrow 1"
            severity error;

        A_tb <= "0011"; B_tb <= "0100"; Ci_tb <= '0'; Cont_tb <= '1';
        wait for 10 ns;
        assert S_tb = "1111" and Co_tb = '0'
            report "FAILED SUB: 0011 - 0100 should be 1111 borrow 0"
            severity error;

        A_tb <= "0000"; B_tb <= "0001"; Ci_tb <= '0'; Cont_tb <= '1';
        wait for 10 ns;
        assert S_tb = "1111" and Co_tb = '0'
            report "FAILED SUB: 0000 - 0001 should be 1111 borrow 0"
            severity error;

        A_tb <= "1111"; B_tb <= "1111"; Ci_tb <= '0'; Cont_tb <= '1';
        wait for 10 ns;
        assert S_tb = "0000" and Co_tb = '1'
            report "FAILED SUB: 1111 - 1111 should be 0000 no-borrow 1"
            severity error;

        report "4-bit add/sub testbench completed";
        wait;
    end process;

end test;
