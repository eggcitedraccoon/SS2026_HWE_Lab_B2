entity ADDER_TB is
end ADDER_TB;

architecture test of ADDER_TB is

    signal A_tb  : bit := '0';
    signal B_tb  : bit := '0';
    signal Ci_tb : bit := '0';

    signal S_tb  : bit;
    signal Co_tb : bit;

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

    UUT: ADDER
        port map(
            A  => A_tb,
            B  => B_tb,
            Ci => Ci_tb,
            S  => S_tb,
            Co => Co_tb
        );

    stimulus: process
    begin
        A_tb <= '0'; B_tb <= '0'; Ci_tb <= '0';
        wait for 10 ns;
        assert S_tb = '0' and Co_tb = '0'
            report "FAILED: 0 + 0 + 0 should be S=0 Co=0"
            severity error;

        A_tb <= '0'; B_tb <= '0'; Ci_tb <= '1';
        wait for 10 ns;
        assert S_tb = '1' and Co_tb = '0'
            report "FAILED: 0 + 0 + 1 should be S=1 Co=0"
            severity error;

        A_tb <= '0'; B_tb <= '1'; Ci_tb <= '0';
        wait for 10 ns;
        assert S_tb = '1' and Co_tb = '0'
            report "FAILED: 0 + 1 + 0 should be S=1 Co=0"
            severity error;

        A_tb <= '0'; B_tb <= '1'; Ci_tb <= '1';
        wait for 10 ns;
        assert S_tb = '0' and Co_tb = '1'
            report "FAILED: 0 + 1 + 1 should be S=0 Co=1"
            severity error;

        A_tb <= '1'; B_tb <= '0'; Ci_tb <= '0';
        wait for 10 ns;
        assert S_tb = '1' and Co_tb = '0'
            report "FAILED: 1 + 0 + 0 should be S=1 Co=0"
            severity error;

        A_tb <= '1'; B_tb <= '0'; Ci_tb <= '1';
        wait for 10 ns;
        assert S_tb = '0' and Co_tb = '1'
            report "FAILED: 1 + 0 + 1 should be S=0 Co=1"
            severity error;

        A_tb <= '1'; B_tb <= '1'; Ci_tb <= '0';
        wait for 10 ns;
        assert S_tb = '0' and Co_tb = '1'
            report "FAILED: 1 + 1 + 0 should be S=0 Co=1"
            severity error;

        A_tb <= '1'; B_tb <= '1'; Ci_tb <= '1';
        wait for 10 ns;
        assert S_tb = '1' and Co_tb = '1'
            report "FAILED: 1 + 1 + 1 should be S=1 Co=1"
            severity error;

        report "Full adder testbench completed";
        wait;
    end process;

end test;
