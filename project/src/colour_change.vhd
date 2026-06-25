library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity colour_change is
    port (
        clk     : in  std_logic;

        rgb_r : out std_logic;
        rgb_g : out std_logic;
        rgb_b : out std_logic
    );
end colour_change;

architecture rtl of colour_change is

    constant COLOUR_STEP_CLKS : positive := 390625;

    signal slow_tick : std_logic;

    signal hue : integer range 0 to 1535 := 0;

    signal red_value   : std_logic_vector(7 downto 0);
    signal green_value : std_logic_vector(7 downto 0);
    signal blue_value  : std_logic_vector(7 downto 0);

    signal red_pwm   : std_logic;
    signal green_pwm : std_logic;
    signal blue_pwm  : std_logic;

begin

    speed_control : entity work.clock_slowdown
        generic map (
            DIVIDE_BY => COLOUR_STEP_CLKS
        )
        port map (
            clk       => clk,
            slow_tick => slow_tick
        );

    process(clk)
    begin
        if rising_edge(clk) then
            if slow_tick = '1' then
                if hue = 1535 then
                    hue <= 0;
                else
                    hue <= hue + 1;
                end if;
            end if;
        end if;
    end process;

    process(hue)
        variable step : integer range 0 to 255;
    begin
        if hue < 256 then
            -- Red -> Yellow
            step := hue;

            red_value   <= std_logic_vector(to_unsigned(255, 8));
            green_value <= std_logic_vector(to_unsigned(step, 8));
            blue_value  <= std_logic_vector(to_unsigned(0, 8));

        elsif hue < 512 then
            -- Yellow -> Green
            step := hue - 256;

            red_value   <= std_logic_vector(to_unsigned(255 - step, 8));
            green_value <= std_logic_vector(to_unsigned(255, 8));
            blue_value  <= std_logic_vector(to_unsigned(0, 8));

        elsif hue < 768 then
            -- Green -> Cyan
            step := hue - 512;

            red_value   <= std_logic_vector(to_unsigned(0, 8));
            green_value <= std_logic_vector(to_unsigned(255, 8));
            blue_value  <= std_logic_vector(to_unsigned(step, 8));

        elsif hue < 1024 then
            -- Cyan -> Blue
            step := hue - 768;

            red_value   <= std_logic_vector(to_unsigned(0, 8));
            green_value <= std_logic_vector(to_unsigned(255 - step, 8));
            blue_value  <= std_logic_vector(to_unsigned(255, 8));

        elsif hue < 1280 then
            -- Blue -> Magenta
            step := hue - 1024;

            red_value   <= std_logic_vector(to_unsigned(step, 8));
            green_value <= std_logic_vector(to_unsigned(0, 8));
            blue_value  <= std_logic_vector(to_unsigned(255, 8));

        else
            -- Magenta -> Red
            step := hue - 1280;

            red_value   <= std_logic_vector(to_unsigned(255, 8));
            green_value <= std_logic_vector(to_unsigned(0, 8));
            blue_value  <= std_logic_vector(to_unsigned(255 - step, 8));
        end if;
    end process;

    pwm_red : entity work.pwm_8bit
        port map (
            clk        => clk,
            brightness => red_value,
            pwm_out    => red_pwm
        );

    pwm_green : entity work.pwm_8bit
        port map (
            clk        => clk,
            brightness => green_value,
            pwm_out    => green_pwm
        );

    pwm_blue : entity work.pwm_8bit
        port map (
            clk        => clk,
            brightness => blue_value,
            pwm_out    => blue_pwm
        );

    rgb_r <= red_pwm;
    rgb_g <= green_pwm;
    rgb_b <= blue_pwm;

end rtl;
