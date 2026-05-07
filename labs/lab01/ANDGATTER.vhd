entity ADDGATTER is
port (X,Y: in bit;
Z:out bit);
end entity;
architecture Data of ADDGATTER is
begin
Z<= X and Y;
end architecture;