library ieee;
use ieee.std_logic_1164.all;

entity rgb_modes_top is
    port (
        CLK100MHZ  : in std_logic;
        A   : in std_logic_vector(3 downto 0);

        LED16_R : out std_logic;
        LED16_G : out std_logic;
        LED16_B : out std_logic
    );
end rgb_modes_top;

architecture rtl of rgb_modes_top is

    signal clk_mode0 : std_logic;
    signal clk_mode1 : std_logic;
    signal clk_mode2 : std_logic;

    signal mode0_r, mode0_g, mode0_b : std_logic;
    signal mode1_r, mode1_g, mode1_b : std_logic;
    signal mode2_r, mode2_g, mode2_b : std_logic;

begin

    router_inst : entity work.clock_router_top
        port map (
            CLK100MHZ => CLK100MHZ,
            A         => A,
            clk_mode0 => clk_mode0,
            clk_mode1 => clk_mode1,
            clk_mode2 => clk_mode2
        );


    mode0_inst : entity work.rgb_blink_top
        port map (
            clk_mode0,
            mode0_r,
            mode0_g,
            mode0_b
        );


    mode1_inst : entity work.colour_change
        port map (
            clk_mode1,
            mode1_r,
            mode1_g,
            mode1_b
        );


    mode2_inst : entity work.rgb_fade_top
        port map (
            clk_mode2,
            mode2_r,
            mode2_g,
            mode2_b
        );


    LED16_R <= mode0_r when A(1 downto 0) = "00" else
               mode1_r when A(1 downto 0) = "01" else
               mode2_r when A(1 downto 0) = "10" else
               '0';

    LED16_G <= mode0_g when A(1 downto 0) = "00" else
               mode1_g when A(1 downto 0) = "01" else
               mode2_g when A(1 downto 0) = "10" else
               '0';

    LED16_B <= mode0_b when A(1 downto 0) = "00" else
               mode1_b when A(1 downto 0) = "01" else
               mode2_b when A(1 downto 0) = "10" else
               '0';

end rtl;
