entity ANDGATTER is
    port(
        X : in  bit;
        Y : in  bit;
        Z : out bit
    );
end ANDGATTER;

architecture Data of ANDGATTER is
begin
    Z <= X and Y;
end Data;
