library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_8bit is
    port (
        clk        : in  std_logic;
        brightness : in  std_logic_vector(7 downto 0);
        pwm_out    : out std_logic
    );
end pwm_8bit;

architecture rtl of pwm_8bit is
    signal counter : unsigned(7 downto 0) := (others => '0');
begin

    process(clk)
    begin
        if rising_edge(clk) then
            counter <= counter + 1;
        end if;
    end process;

    process(counter, brightness)
    begin
        if unsigned(brightness) = 255 then
            pwm_out <= '1';
        elsif counter < unsigned(brightness) then
            pwm_out <= '1';
        else
            pwm_out <= '0';
        end if;
    end process;

end rtl;