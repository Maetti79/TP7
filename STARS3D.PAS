uses Alphabet;

const
      MaxQuart  = 250;  { Anzahl der Sterne in einem Bildschirmausschnitt }
      MinX      =   0;
      MinY      =   0;
      MaxX      = 100;
      MaxY      = 100;
      MaxZ      =  63;
      MX        = 160;
      MY        = 100;
      Camera    =  60;  { 0 ist am weitesten entfernt }
      BKC       =   0;
      L         =  90;
      G         =  91;
      { Das Sprite "DOS" }
      Sprite    : array[1..55] of byte = ( 64,64, 0, 0, 0,64, 0, 0, 0,64,64,
                                           64, 0,64, 0,64, 0,64, 0,64, 0, 0,
                                           64, 0,64, 0,64, 0,64, 0, 0,64, 0,
                                           64, 0,64, 0,64, 0,64, 0, 0, 0,64,
                                           64,64, 0, 0, 0,64, 0, 0,64,64, 0 );

var
    SX, SY, X : array[0..3,0..MaxQuart] of word;
    Y, Z, OC  : array[0..3,0..MaxQuart] of byte;
    Zahl, C   : word;
    Dir, Val : byte;

{ Wartet den Vertikalen Strahlrcklauf ab }
procedure Retrace; assembler;
 asm
  mov dx, 3dah
 @R1:
  in al, dx
  test al, 08h
  jnz @R1
 @R2:
  in al,dx
  test al, 08h
  jnz @R2
 end;

{ Zeichnet einen Pixel }
procedure PutPixel (X, Y : word; Col : byte); assembler;
 asm
  mov ax, 0a000h
  mov es, ax
  mov ax, 320
  mul Y
  add ax, X
  mov di, ax
  mov al, Col
  mov es:[di], al
 end;

{ Definiert die Einheiten einer Farbe }
procedure DefineColor (Col, R, G, B : byte); assembler;
 asm
  mov dx, 3c8h
  mov al, Col
  out dx, al
  mov dx, 3c9h
  mov al, R
  out dx, al
  mov al, G
  out dx, al
  mov al, B
  out dx, al
 end;

{ Vertauscht die Einheiten zweier Farben }
procedure ChangeColor (Col1, Col2 : byte);
 var R1, G1, B1, R2, G2, B2 : byte;
 begin
  port[$3c7] := Col1;
  R1 := port[$3c9];
  G1 := port[$3c9];
  B1 := port[$3c9];
  port[$3c7] := Col2;
  R2 := port[$3c9];
  G2 := port[$3c9];
  B2 := port[$3c9];
  DefineColor (Col1, R2, G2, B2);
  DefineColor (Col2, R1, G1, B1);
  Retrace;
 end;

{ Blendet den Bildschirm aus }
procedure DarkenScreen;
 var V, C, R, G, B : byte;
 begin
  for V := 63 downto 0 do
   for C := 255 downto 0 do
    begin
     port[$3c7] := C;
     R := port[$3c9];
     G := port[$3c9];
     B := port[$3c9];
      if R > 0 then dec (R);
      if G > 0 then dec (G);
      if B > 0 then dec (B);
     DefineColor (C, R, G, B);
     Retrace;
    end;
 end;

{ Blendet den Bildschirm auf maximale Helligkeit }
procedure LightenScreen;
 var C, V, R, G, B : byte;
 begin
  for V := 63 downto 0 do
   for C := 255 downto 0 do
    begin
     port[$3c7] := C;
     R := port[$3c9];
     G := port[$3c9];
     B := port[$3c9];
      if R < 63 then inc (R);
      if G < 63 then inc (G);
      if B < 63 then inc (B);
     DefineColor (C, R, G, B);
     Retrace;
    end;
 end;

{ Zeichnet das Sprite "DOS" }
procedure PutSprite (PX, PY : word);
 var X, Y, I : word;
 begin
  I := 1;
  for Y := PY to PY+4 do
   for X := PX to PX+10 do
    begin
      if Sprite[I] <> 0 then PutPixel (X, Y, Sprite[I]);
     inc (I);
    end;
 end;

{ Setzt aus dem Srpite "DOS" ein groáes Bild "DOS" zusammen }
procedure PutImageOfSprites (PX, PY : word; Range : byte);
 var X, Y, V, CX, CY : word;
 begin
  V := 1;
  Y := PY;
  CY := 1;
  repeat
   X := PX;
   CX := 1;
   repeat
     if Sprite[V] <> 0 then PutSprite (X, Y);
    inc (V);
    inc (X, Range);
    inc (CX);
   until CX = 12;
   inc (Y, Range-(Range div 3));
   inc (CY);
  until CY = 6;
 end;

procedure PutCredits (PCX, Y : word);
 var X : word;
 begin
  X := PCX;
  PutLetter (X, Y, 'C');
  inc (X, 7);
  PutLetter (X, Y, 'O');
  inc (X, 7);
  PutLetter (X, Y, 'D');
  inc (X, 7);
  PutLetter (X, Y, 'E');
  inc (X, 14);
  PutLetter (X, Y, 'B');
  inc (X, 7);
  PutLetter (X, Y, 'Y');
  inc (X, 14);
  PutLetter (X, Y, 'S');
  inc (X, 7);
  PutLetter (X, Y, 'A');
  inc (X, 7);
  PutLetter (X, Y, 'S');
  inc (X, 7);
  PutLetter (X, Y, 'C');
  inc (X, 7);
  PutLetter (X, Y, 'H');
  inc (X, 7);
  PutLetter (X, Y, 'A');
  inc (X, 14);
  PutLetter (X, Y, 'S');
  inc (X, 7);
  PutLetter (X, Y, 'I');
  inc (X, 7);
  PutLetter (X, Y, 'G');
  inc (X, 7);
  PutLetter (X, Y, 'G');
  inc (X, 7);
  PutLetter (X, Y, 'E');
  inc (X, 7);
  PutLetter (X, Y, 'S');
 end;

BEGIN
 asm
  { VGA 320*200 256 }
  mov ax, 0013h
  int 10h
 end;
 { Spritefarbe definieren und Bild zeichnen }
 Val := 0;
 DefineColor (64, Val, Val, 0);
 PutImageOfSprites (80, 70, 15);
 DefineColor (255, 0, 50, 20);
 PutCredits (90, 190);
 { Farben fr Sterne umprogrammieren }
 randomize;
 C := 1;
 for Zahl := 63 downto 1 do
  begin
   DefineColor (C, Zahl, Zahl, Zahl);
   inc (C);
  end;
 { 2D-Koordinaten der Sterne vorberechnen }
 for Zahl := MaxQuart downto 0 do
  begin
   for C := 3 downto 0 do
    begin
     X[C][Zahl] := random(MaxX);
     Y[C][Zahl] := random(MaxY);
     repeat Z[C][Zahl] := random(MaxZ) until Z[C][Zahl] <> 0;
    end;
  end;
 repeat  { wiederhole ... }
  for Zahl := MaxQuart downto 0 do
   begin
    { 2D- in 3D-Koordinaten umrechnen nach X2D=X3D*A/Z; Y2D=Y3D*A/Z }
    { links oben }
    SX[0][Zahl] := MX-(X[0][Zahl]*Camera div Z[0][Zahl]);
    SY[0][Zahl] := MY-(Y[0][Zahl]*Camera div Z[0][Zahl]);
    { rechts oben }
    SX[1][Zahl] := MX+(X[1][Zahl] * Camera div Z[1][Zahl]);
    SY[1][Zahl] := MY-(Y[1][Zahl] * Camera div Z[1][Zahl]);
    { links unten }
    SX[2][Zahl] := MX-(X[2][Zahl] * Camera div Z[2][Zahl]);
    SY[2][Zahl] := MY+(Y[2][Zahl] * Camera div Z[2][Zahl]);
    { rechts unten }
    SX[3][Zahl] := MX+(X[3][Zahl] * Camera div Z[3][Zahl]);
    SY[3][Zahl] := MY+(Y[3][Zahl] * Camera div Z[3][Zahl]);
    for C := 3 downto 0 do
     begin
      OC[C][Zahl] := mem[$0a000:320*SY[C][Zahl]+SX[C][Zahl]];
       if (SX[C][Zahl] > MinX) and (SX[C][Zahl] < 319) and
        (SY[C][Zahl] > MinY) and (SY[C][Zahl] < 199) then
         if OC[C][Zahl] = 0 then PutPixel (SX[C][Zahl], SY[C][Zahl], Z[C][Zahl]);
     end;
   end;
  Retrace;  { Strahlrcklauf abwarten }
  for Zahl := MaxQuart downto 0 do
   begin
    for C := 3 downto 0 do
     begin
       if OC[C][Zahl] = 0 then PutPixel (SX[C][Zahl], SY[C][Zahl], BKC);
       if Z[C][Zahl] > 1 then dec (Z[C][Zahl]) else
        begin
         X[C][Zahl] := random(MaxX);
         Y[C][Zahl] := random(MaxY);
         Z[C][Zahl] := MaxZ;
        end;
     end;
   end;
   { Spritefarbe neu berechnen }
   if Dir = 0 then if Val < 63 then inc (Val) else Dir := 1;
   if Dir = 1 then if Val > 0 then dec (Val) else Dir := 0;
  DefineColor (64, Val, Val, 0);  {Spritefarbe neu definieren }
  Retrace;  { Strahlrcklauf abwarten }
 until port[$60] and 127 = $01;  { ... bis die ESC-Taste gedrckt wurde }
 LightenScreen;  { Bildschirmfarben auf h”chste Helligkeitsstufe }
 DarkenScreen;  { Bildschirm ausblenden }
 asm
  { TXT 80*25 16 }
  mov ax, 0003h
  int 10h
 end;
END.

