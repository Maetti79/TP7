UNIT Mathe;


INTERFACE

VAR
    { Die Sinus- und Kosinus Tabellen }
    Cosinus, Sinus    : ARRAY[0..360] OF REAL;


PROCEDURE SinCosTable;


IMPLEMENTATION

PROCEDURE SinCosTable;
 VAR i : WORD;
 BEGIN
   FOR i := 0 TO 360
     DO BEGIN
          Sinus[i]   := Sin (i * Pi / 180);
          Cosinus[i] := Cos (i * Pi / 180);
        END;
 END;

BEGIN
  SinCosTable;
END.
