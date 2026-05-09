entity ORGATTER is
    port (X,Y: in bit;
        Z    : out bit);
end entity;
architecture Data of ANDGATTER is
begin
    Z<= X or Y;
end architecture;
