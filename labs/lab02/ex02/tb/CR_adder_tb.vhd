entity CR_ADDER_TB is
end CR_ADDER_TB;

architecture test of CR_ADDER_TB is

    signal A_tb  : bit_vector(3 downto 0) := "0000";
    signal B_tb  : bit_vector(3 downto 0) := "0000";
    signal Ci_tb : bit := '0';

    signal S_tb  : bit_vector(3 downto 0);
    signal Co_tb : bit;

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

    UUT: CR_ADDER
        port map(
            A  => A_tb,
            B  => B_tb,
            Ci => Ci_tb,
            S  => S_tb,
            Co => Co_tb
        );

    stimulus: process
    begin
        A_tb <= "0000"; B_tb <= "0000"; Ci_tb <= '0';
        wait for 10 ns;
        assert S_tb = "0000" and Co_tb = '0'
            report "FAILED: 0000 + 0000 + 0 should be 0000 carry 0"
            severity error;

        A_tb <= "0001"; B_tb <= "0001"; Ci_tb <= '0';
        wait for 10 ns;
        assert S_tb = "0010" and Co_tb = '0'
            report "FAILED: 0001 + 0001 + 0 should be 0010 carry 0"
            severity error;

        A_tb <= "0011"; B_tb <= "0100"; Ci_tb <= '0';
        wait for 10 ns;
        assert S_tb = "0111" and Co_tb = '0'
            report "FAILED: 0011 + 0100 + 0 should be 0111 carry 0"
            severity error;

        A_tb <= "0111"; B_tb <= "0001"; Ci_tb <= '1';
        wait for 10 ns;
        assert S_tb = "1001" and Co_tb = '0'
            report "FAILED: 0111 + 0001 + 1 should be 1001 carry 0"
            severity error;

        A_tb <= "1111"; B_tb <= "0001"; Ci_tb <= '0';
        wait for 10 ns;
        assert S_tb = "0000" and Co_tb = '1'
            report "FAILED: 1111 + 0001 + 0 should be 0000 carry 1"
            severity error;

        A_tb <= "1111"; B_tb <= "1111"; Ci_tb <= '1';
        wait for 10 ns;
        assert S_tb = "1111" and Co_tb = '1'
            report "FAILED: 1111 + 1111 + 1 should be 1111 carry 1"
            severity error;

        report "4-bit adder testbench completed";
        wait;
    end process;

end test;
