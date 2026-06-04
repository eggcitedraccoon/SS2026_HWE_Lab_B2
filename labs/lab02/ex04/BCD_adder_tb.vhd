
entity bcd_adder_tb is
end bcd_adder_tb;


architecture test of bcd_adder_tb is

    signal A_tb  : bit_vector(3 downto 0) := "0000";
    signal B_tb  : bit_vector(3 downto 0) := "0000";
    signal Ci_tb : bit := '0';

    signal S_tb  : bit_vector(3 downto 0);
    signal Co_tb : bit;

    component bcd_adder
        port(
            A  : in  bit_vector(3 downto 0);
            B  : in  bit_vector(3 downto 0);
            Ci : in  bit;
            S  : out bit_vector(3 downto 0);
            Co : out bit
        );
    end component;

begin

    UUT: bcd_adder
        port map(
            A  => A_tb,
            B  => B_tb,
            Ci => Ci_tb,
            S  => S_tb,
            Co => Co_tb
        );


    stimulus: process
    begin

        -- 0 + 0 + 0 = 0
        A_tb  <= "0000";
        B_tb  <= "0000";
        Ci_tb <= '0';
        wait for 10 ns;

        assert S_tb = "0000" and Co_tb = '0'
            report "FAILED: 0 + 0 + 0"
            severity error;


        -- 4 + 3 = 7
        A_tb  <= "0100";
        B_tb  <= "0011";
        Ci_tb <= '0';
        wait for 10 ns;

        assert S_tb = "0111" and Co_tb = '0'
            report "FAILED: 4 + 3 + 0"
            severity error;


        -- 5 + 4 = 9
        A_tb  <= "0101";
        B_tb  <= "0100";
        Ci_tb <= '0';
        wait for 10 ns;

        assert S_tb = "1001" and Co_tb = '0'
            report "FAILED: 5 + 4 + 0"
            severity error;


        -- 5 + 5 = 10
        -- BCD result: carry 1, digit 0
        A_tb  <= "0101";
        B_tb  <= "0101";
        Ci_tb <= '0';
        wait for 10 ns;

        assert S_tb = "0000" and Co_tb = '1'
            report "FAILED: 5 + 5 + 0"
            severity error;


        -- 8 + 7 = 15
        -- BCD result: carry 1, digit 5
        A_tb  <= "1000";
        B_tb  <= "0111";
        Ci_tb <= '0';
        wait for 10 ns;

        assert S_tb = "0101" and Co_tb = '1'
            report "FAILED: 8 + 7 + 0"
            severity error;


        -- 9 + 9 = 18
        -- BCD result: carry 1, digit 8
        A_tb  <= "1001";
        B_tb  <= "1001";
        Ci_tb <= '0';
        wait for 10 ns;

        assert S_tb = "1000" and Co_tb = '1'
            report "FAILED: 9 + 9 + 0"
            severity error;


        -- 9 + 9 + 1 = 19
        -- BCD result: carry 1, digit 9
        A_tb  <= "1001";
        B_tb  <= "1001";
        Ci_tb <= '1';
        wait for 10 ns;

        assert S_tb = "1001" and Co_tb = '1'
            report "FAILED: 9 + 9 + 1"
            severity error;


        report "BCD adder testbench completed";
        wait;

    end process;

end test;