entity bcd_to_7segment_conv is
    port(
        bcd : in  bit_vector(3 downto 0);
        seg : out bit_vector(6 downto 0)
    );
end bcd_to_7segment_conv;


architecture behavioral of bcd_to_7segment_conv is
begin

    process(bcd)
    begin
        case bcd is


            when "0000" => seg <= "1111110"; -- 0
            when "0001" => seg <= "0110000"; -- 1
            when "0010" => seg <= "1101101"; -- 2
            when "0011" => seg <= "1111001"; -- 3
            when "0100" => seg <= "0110011"; -- 4
            when "0101" => seg <= "1011011"; -- 5
            when "0110" => seg <= "1011111"; -- 6
            when "0111" => seg <= "1110000"; -- 7
            when "1000" => seg <= "1111111"; -- 8
            when "1001" => seg <= "1111011"; -- 9

            -- invalid BCD values: blank display
            when others => seg <= "0000000";

        end case;
    end process;

end behavioral;