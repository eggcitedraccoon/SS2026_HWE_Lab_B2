library ieee;
use ieee.std_logic_1164.all;

entity clock_router_top is
    port (
        CLK100MHZ : in  std_logic;

        -- Two switches select which output gets the clock.
        -- Keep as 4 bits if your current XDC uses A[0]..A[3].
        -- A(2) and A(3) are unused here.
        A   : in  std_logic_vector(3 downto 0);

        -- Clock outputs to your three mode modules
        clk_mode0 : out std_logic;
        clk_mode1 : out std_logic;
        clk_mode2 : out std_logic
    );
end clock_router_top;

architecture gatey of clock_router_top is

    signal select_mode0 : std_logic;
    signal select_mode1 : std_logic;
    signal select_mode2 : std_logic;

begin

    --------------------------------------------------------------------
    -- Switch decoder
    --
    -- A(1) A(0)
    --   0    0   -> mode 0 gets clock
    --   0    1   -> mode 1 gets clock
    --   1    0   -> mode 2 gets clock
    --   1    1   -> nobody gets clock
    --------------------------------------------------------------------

    select_mode0 <= (not A(1)) and (not A(0));
    select_mode1 <= (not A(1)) and      A(0);
    select_mode2 <=      A(1)  and (not A(0));


    --------------------------------------------------------------------
    -- Clock routing
    --
    -- Selected output receives clk.
    -- Other outputs stay at 0.
    --------------------------------------------------------------------

    clk_mode0 <= CLK100MHZ and select_mode0;
    clk_mode1 <= CLK100MHZ and select_mode1;
    clk_mode2 <= CLK100MHZ and select_mode2;

end gatey;