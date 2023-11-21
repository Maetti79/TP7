UNIT VGA;

INTERFACE

USES Crt;

{ ------------------------------- }
{ Konstanten, Typen und VARiablen }
{ ------------------------------- }
CONST
      { Die untersttzten Grafikmodi }
      _320_200_256        =    $13;
      { Die Grafikseiten }
      VisualPage   : Word = $0a000;
      VirtualPage  : Word =  $7000;
      RamPage      : Word =  $8000;
      MaxX         : Word =    319;
      MaxY         : Word =    199;

TYPE
     tPal = RECORD
             R, G, B : ARRAY[0..255] OF Byte;
            END;

VAR
    Pal : tPal;  { Die Farbpalette }
    { Die Sinus- und Kosinus Tabellen }
    Cosinus,
    Sinus    : ARRAY[0..360] OF real;


PROCEDURE LoadRaw (FileName : STRING; Page : Word);
PROCEDURE SinCosTable;
PROCEDURE InitMode (Mode : Word);
PROCEDURE WaitVBL;
PROCEDURE ScreenOn;
PROCEDURE ScreenOff;
PROCEDURE CursorOn;
PROCEDURE CursorOff;
PROCEDURE PutPixel (X, Y : Word; Col : Byte; Page : Word);
FUNCTION  GetPixel (X, Y, Page : Word) : Byte;
PROCEDURE FillScreen (Col : Byte; Page : Word);
PROCEDURE Rectangle (X1, Y1, X2, Y2 : Word; Col : Byte; Page : Word);
PROCEDURE Bar (X1, Y1, X2, Y2 : Word; Col : Byte; Page : Word);
PROCEDURE PointedCircle (X, Y : Word; Radius, Col : Byte; Page : Word);
PROCEDURE ClearScreen (Page : Word);
PROCEDURE CopySeg (Q, Z : Word);
PROCEDURE Zoom (X1, Y1, X2, Y2, QPage, PX, PY, ZPage : Word; Factor : Byte);
PROCEDURE CopyBuffer (GX1, GY1, GX2, GY2, GPage, PX, PY, PPage : Word);
PROCEDURE CopySprite (GX1, GY1, GX2, GY2, GPage, PX, PY, PPage : Word);
PROCEDURE DefineColor (C, R, G, B : Byte);
PROCEDURE FadeIn;
PROCEDURE DarkenScreen;
PROCEDURE GetPal;
PROCEDURE SetPal;

IMPLEMENTATION

PROCEDURE LoadRaw (FileName : STRING; Page : Word);
 VAR RF : FILE;
 BEGIN
   Assign (RF, FileName);
   {$I-}
   Reset (RF);
   {$I+}
    IF IOResult<>0
      THEN BEGIN
             InitMode (3);
             WriteLn ('Could not open ', FileName, ' !  Program haltet.', #10);
             Halt (1);
           END;
   BlockRead (RF, Ptr (Page, 0)^, FileSize (RF));
 END;

PROCEDURE SinCosTable;
 VAR i : Word;
 BEGIN
   FOR i := 0 TO 360
     DO BEGIN
          Sinus[i] := Sin (i);
          Cosinus[i] := Cos (i);
        END;
 END;

PROCEDURE InitMode (Mode : Word); ASSEMBLER;
 ASM
   mov ax, Mode
   int 10h
 END;

PROCEDURE WaitVBL; ASSEMBLER;
 ASM
   mov dx, 3dah
  @Ret1:
   in al, dx
   test al, 08h
   jnz @Ret1
  @Ret2:
   in al, dx
   test al, 08h
   jz @Ret2
 END;

PROCEDURE ScreenOn; ASSEMBLER;
 ASM
   mov dx, 3c4h
   mov al, 1
   out dx, al
   mov dx, 3c5h
   in al, dx
   mov ah, 32
   not ah
   and al, ah
   out dx, al
 END;

PROCEDURE ScreenOff; ASSEMBLER;
 ASM
   mov dx, 3c4h
   mov al, 1
   out dx, al
   mov dx, 3c5h
   in al, dx
   or al, 32
   out dx, al
 END;

PROCEDURE CursorOn; ASSEMBLER;
 ASM
   mov ah, 1
   mov cx, 0708h
   int 10h
 END;

PROCEDURE CursorOff; ASSEMBLER;
 ASM
   mov ah, 1
   mov cx, 3232h
   int 10h
 END;

PROCEDURE PutPixel (X, Y : Word; Col : Byte; Page : Word); ASSEMBLER;
 ASM
   mov es, Page
   mov ax, 320
   mul Y
   add ax, X
   mov di, ax
   mov al, Col
   mov es:[di], al
 END;

FUNCTION  GetPixel (X, Y, Page : Word) : Byte; ASSEMBLER;
 ASM
   mov es, Page
   mov ax, 320
   mul Y
   add ax, X
   mov di, ax
   mov ax, es:[di]
 END;

PROCEDURE FillScreen (Col : Byte; Page : Word); ASSEMBLER;
 ASM
  mov es, Page
  xor di, di
  mov al, Col
  mov cx, 64000
  rep stosb
 END;

PROCEDURE Rectangle (X1, Y1, X2, Y2 : Word; Col : Byte; Page : Word);
 VAR Dummy, Y : Word;
 BEGIN
   IF X1>X2 THEN BEGIN
                   Dummy := X1;
                   X1 := X2;
                   X2 := Dummy;
                 END;
   IF Y1>Y2 THEN BEGIN
                   Dummy := Y1;
                   Y1 := Y2;
                   Y2 := Dummy;
                 END;
  { Horizontale Linie zeichnen }
  ASM
    { Zielsegment (VGA) laden }
    mov es, Page
    { Oberes Offset laden }
    mov ax, 320
    mul Y1
    add ax, X1
    mov di, ax
    { Differenz berechnen }
    mov cx, X2
    sub cx, X1
    mov dx, cx
    { Farbe laden }
    mov al, Col
    { Schreibern }
    rep stosb
    { Unteres Offset laden }
    mov ax, 320
    mul Y2
    add ax, X1
    mov di, ax
    { Differenz }
    mov cx, X2
    sub cx, X1
    { Farbe laden }
    mov al, Col
    rep stosb
  END;
  { Vertikale Linie zeichnen }
  FOR Y := Y2 DOWNTO Y1 DO
   BEGIN
    mem[Page:320*Y+X1] := Col;
    mem[Page:320*Y+X2] := Col;
   END;
 END;

PROCEDURE Bar (X1, Y1, X2, Y2 : Word; Col : Byte; Page : Word); ASSEMBLER;
 ASM
   mov es, Page
   mov ax, 320
   mul Y1
   add ax, X1
   mov di, ax
   mov cx, X2
   sub cx, X1
   mov bx, cx
   mov dx, Y2
   sub dx, Y1
   mov al, Col
  @D:
   rep sTOsb
   sub di, bx
   mov cx, bx
   add di, 320
   dec dx
   jnz @D
 END;

PROCEDURE PointedCircle (X, Y : Word; Radius, Col : Byte; Page : Word);
 VAR KX, KY : Word; W : Byte;
 BEGIN
   FOR W := 0 TO 45
     DO BEGIN
          KX := Round (160+(Cosinus[W]*Radius));
          KY := Round (100+(Sinus[W]*Radius));
          PutPixel (KX, KY, Col, Page);
        END;
 END;

PROCEDURE ClearScreen (Page : Word); ASSEMBLER;
 ASM
   mov es, Page
   xor di, di
   xor ax, ax
   mov cx, 32000
   rep stosw
 END;

PROCEDURE CopySeg (Q, Z : Word); ASSEMBLER;
 ASM
   push ds
   mov ds, Q
   xor si, si
   mov es, Z
   xor di, di
   mov cx, 32000
   rep movsw
   pop ds
 END;

PROCEDURE Zoom (X1, Y1, X2, Y2, QPage, PX, PY, ZPage : Word; Factor : Byte);
 VAR GetX, PutX, GetY, PutY, Factor1, Factor2 : word;
 BEGIN
   PutY := PY;
   FOR GetY := Y1 TO Y2  { Leseschleife fr Y }
     DO BEGIN
          FOR Factor1 := 1 TO Factor
            DO BEGIN
                 PutX := PX;
                 FOR GetX := X1 TO X2 DO  { Leseschleife fr X }
                   FOR Factor2 := 1 TO Factor
                     DO ASM
                         { Pixel auslesen (wird in bl gespeichert }
                         mov es, Qpage
                         mov ax, 320
                         mul GetY
                         add ax, GetX
                         mov di, ax
                         mov bl, es:[di]
                         { Pixel schreiben }
                         mov es, ZPage
                         mov ax, 320
                         mul PutY
                         add ax, PutX
                         mov di, ax
                         mov es:[di], bl
                         { PutX erh”hen }
                         inc PutX
                       END;
                 Inc (PutY);
               END;
        END;
 END;


PROCEDURE CopyBuffer (GX1, GY1, GX2, GY2, GPage, PX, PY, PPage : Word);
 VAR X, Y : Word; C : Byte;
 BEGIN
   FOR Y := GY1 TO GY2 DO
     IF Y<MaxY+1 THEN
       FOR X := GX1 TO GX2 DO
         Mem[PPage:320*(PY+(Y-GY1))+(PX+(X-GX1))] := Mem[GPage:320*Y+X];
 END;

PROCEDURE CopySprite (GX1, GY1, GX2, GY2, GPage, PX, PY, PPage : Word);
 VAR X, Y : Word; C : Byte;
 BEGIN
   FOR Y := GY1 TO GY2 DO
     IF Y<MaxY+1 THEN
       FOR X := GX1 TO GX2 DO
         BEGIN
           C := Mem[GPage:320*Y+X];
            IF C<>0
              THEN Mem[PPage:320*(PY+(Y-GY1))+(PX+(X-GX1))] := C;
         END;
 END;

PROCEDURE DefineColor (C, R, G, B : Byte); ASSEMBLER;
 ASM
   mov dx, 3c8h
   mov al, C
   out dx, al
   mov dx, 3c9h
   mov al, R
   out dx, al
   mov al, G
   out dx, al
   mov al, B
   out dx, al
 END;

procedure FadeIn;
 var
     V, C, R1, G1, B1 : byte;
     R2, G2, B2 : array[0..255] of byte;
 begin
  for C := 255 downto 0 do
   begin
    port[$3c7] := C;
    R2[C] := port[$3c9];
    G2[C] := port[$3c9];
    B2[C] := port[$3c9];
    DefineColor (C, 0, 0, 0);
   end;
  ScreenOn;
  for V := 63 downto 0 do
   for C := 255 downto 0 do
    begin
     port[$3c7] := C;
     R1 := port[$3c9];
     G1 := port[$3c9];
     B1 := port[$3c9];
      if R1 > R2[C] then dec (R1);
      if R1 < R2[C] then inc (R1);
      if G1 > G2[C] then dec (G1);
      if G1 < G2[C] then inc (G1);
      if B1 > B2[C] then dec (B1);
      if B1 < B2[C] then inc (B1);
     DefineColor (C, R1, G1, B1);
     Delay (5);
    end;
 end;

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
     Delay (5);
    end;
 end;

PROCEDURE GetPal;
 VAR i : Byte;
 BEGIN
   FOR i := 255 DOWNTO 0
     DO BEGIN
          Port[$3c7] := i;
          Pal.R[i] := Port[$3c9];
          Pal.G[i] := Port[$3c9];
          Pal.B[i] := Port[$3c9];
        END;
 END;

PROCEDURE SetPal;
 VAR i : Byte;
 BEGIN
   FOR i := 255 DOWNTO 0
     DO DefineColor (i, Pal.R[i], Pal.G[i], Pal.B[i]);
 END;

{ Unit-Prozedur }
BEGIN
END.


