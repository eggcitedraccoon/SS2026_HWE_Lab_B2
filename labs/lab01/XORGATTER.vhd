entity XORGATTER is
    port(
        X : in  bit;
        Y : in  bit;
        Z : out bit
    );
end XORGATTER;

architecture Data of XORGATTER is
begin
    Z <= X xor Y;
end Data;
