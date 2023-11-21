UNIT TxtUni;


INTERFACE

USES DOS, CRT;


CONST Txt = $0003;


FUNCTION  GetChar : BYTE;
FUNCTION  GetCharCol : BYTE;
PROCEDURE InitMode (Mode : WORD);
PROCEDURE BarTxt (X1, Y1, X2, Y2, FrameCol, BkCol: BYTE; Name : STRING);
PROCEDURE ShadedBarTxt (X1, Y1, X2, Y2, FrameCol, BkCol, ShadeCol: BYTE; Name : STRING);
PROCEDURE FrameTxt (X1, Y1, X2, Y2, FrameCol : BYTE; Name : STRING);
PROCEDURE SelectorBar (X1, X2, Y, TxtCol, BkCol : BYTE);
PROCEDURE UpCaseStr (VAR S : STRING);
PROCEDURE CursorOff;
PROCEDURE CursorOn;
Procedure Draw_Ansi(Name:String);


IMPLEMENTATION

{ Liefert den ASCII-Code des Zeichens an der aktuellen Cursor-Position }
FUNCTION GetChar : BYTE;
 VAR Regs : REGISTERS;
 BEGIN
   Regs.ah := $08;
   Regs.bh :=   0;
   Intr ($10, Regs);
   GetChar := Regs.al;
 END;

{ Liefert die Farbe des Zeichens an der aktuellen Cursor-Position }
FUNCTION GetCharCol : BYTE;
 VAR Regs : REGISTERS;
 BEGIN
   Regs.ah := $08;
   Regs.bh :=   0;
   Intr ($10, Regs);
   GetCharCol := Regs.ah;
 END;

{ Initialisiert einen Modus }
PROCEDURE InitMode (Mode : WORD); ASSEMBLER;
 ASM
   mov ax, Mode
   int 10h
 END;

{ Setzt ein Rahmenfenster mit Namen im Textmodus }
PROCEDURE BarTxt (X1, Y1, X2, Y2, FrameCol, BkCol: BYTE; Name : STRING);
 VAR X, Y, OldX, OldY : BYTE;
 BEGIN
   OldX := WhereX;
   OldY := WhereY;
   TextBackGround (BkCol);
   TextColor (FrameCol);
   FOR Y := Y2 DOWNTO Y1
     DO FOR X := X2 DOWNTO X1
          DO BEGIN
               GotoXY (X, Y);
               Write (' ');
             END;
   GotoXY (X1, Y1);
   Write ('É');
   GotoXY (X2, Y1);
   Write ('»');
   GotoXY (X1, Y2);
   Write ('È');
   GotoXY (X2, Y2);
   Write ('¼');
   FOR X := X1+1 TO X2-1
     DO BEGIN
          GotoXY (X, Y1);
          Write ('Í');
          GotoXY (X, Y2);
          Write ('Í');
        END;
   FOR Y := Y1+1 TO Y2-1
     DO BEGIN
          GotoXY (X1, Y);
          Write ('º');
          GotoXY (X2, Y);
          Write ('º');
        END;
   { Namen zentriert schreiben }
   GotoXY (X1+ (((X2-X1) SHR 1) - (Length (Name) SHR 1)), Y1);
   Write (Name);
   { Cursor wieder zurcksetzen }
   GotoXY (OldX, OldY);
 END;

{ Setzt ein Rahmenfenster mit Shatten und Namen im Textmodus }
PROCEDURE ShadedBarTxt (X1, Y1, X2, Y2,
                        FrameCol, BkCol, ShadeCol: BYTE; Name : STRING);
 VAR X, Y, OldX, OldY : BYTE;
 BEGIN
   OldX := WhereX;
   OldY := WhereY;
   TextBackGround (BkCol);
   TextColor (FrameCol);
   FOR Y := Y2 DOWNTO Y1
     DO FOR X := X2 DOWNTO X1
          DO BEGIN
               GotoXY (X, Y);
               Write (' ');
             END;
   GotoXY (X1, Y1);
   Write ('É');
   GotoXY (X2, Y1);
   Write ('»');
   GotoXY (X1, Y2);
   Write ('È');
   GotoXY (X2, Y2);
   Write ('¼');
   FOR X := X1+1 TO X2-1
     DO BEGIN
          GotoXY (X, Y1);
          Write ('Í');
          GotoXY (X, Y2);
          Write ('Í');
        END;
   FOR Y := Y1+1 TO Y2-1
     DO BEGIN
          GotoXY (X1, Y);
          Write ('º');
          GotoXY (X2, Y);
          Write ('º');
        END;
   { Namen zentriert schreiben }
   GotoXY (X1+ (((X2-X1) SHR 1) - (Length (Name) SHR 1)), Y1);
   Write (Name);
   { Schatten zeichnen unten und links zeichnen }
   TextColor (ShadeCol);
   X := X2+1;
   FOR Y := Y1+1 TO Y2
     DO BEGIN
          GotoXY (X, Y);
          Write (#219, #219);
        END;
   GotoXY (X1+2, Y2+1);
   FOR X := X1+2 TO X2+2
     DO Write (#219);
   { Cursor wieder zurcksetzen }
   GotoXY (OldX, OldY);
 END;

{ Setzt ein Rahmenfenster mit Shatten und Namen im Textmodus }
PROCEDURE FrameTxt (X1, Y1, X2, Y2, FrameCol : BYTE; Name : STRING);
 VAR X, Y, OldX, OldY : BYTE;
 BEGIN
   OldX := WhereX;
   OldY := WhereY;
   TextColor (FrameCol);
   GotoXY (X1, Y1);
   Write ('É');
   GotoXY (X2, Y1);
   Write ('»');
   GotoXY (X1, Y2);
   Write ('È');
   GotoXY (X2, Y2);
   Write ('¼');
   FOR X := X1+1 TO X2-1
     DO BEGIN
          GotoXY (X, Y1);
          Write ('Í');
          GotoXY (X, Y2);
          Write ('Í');
        END;
   FOR Y := Y1+1 TO Y2-1
     DO BEGIN
          GotoXY (X1, Y);
          Write ('º');
          GotoXY (X2, Y);
          Write ('º');
        END;
   { Namen zentriert schreiben }
   GotoXY (X1+ (((X2-X1) SHR 1) - (Length (Name) SHR 1)), Y1);
   Write (Name);
   { Cursor wieder zurcksetzen }
   GotoXY (OldX, OldY);
 END;

PROCEDURE SelectorBar (X1, X2, Y, TxtCol, BkCol : BYTE);
 VAR X, Letter : BYTE;
 BEGIN
   TextColor (TxtCol);
   TextBackGround (BkCol);
   GotoXY (X1, Y);
   FOR X := X1 TO X2
     DO BEGIN
          ASM
            { ASCII-Code des Zeichens und auslesen }
            mov ah, 08
            xor bh, bh
            int 10h
            mov Letter, al
          END;
          Write (Chr (Letter));
        END;
 END;

PROCEDURE UpCaseStr (VAR S : STRING);
 VAR i : BYTE;
 BEGIN
   FOR i := 1 TO Length (S)
     DO S[i] := UpCase (S[i]);
 END;

PROCEDURE CursorOff; ASSEMBLER;
 ASM
   mov ah, 1
   mov cx, 3232h
   int 10h
 END;

PROCEDURE CursorOn; ASSEMBLER;
 ASM
   mov ah, 1
   mov cx, 0708h
   int 10h
 END;

{ Diese Routine stammt von der CD zum Buch "PC Underground" von Data Becker }
Procedure Draw_Ansi(Name:String);
{gibt ein Ansi-File auf dem Bildschirm aus (ANSI.SYS erforderlich !)}
Var Ansi:File;                  {Ansi-Datei}
    StdOut:File;                {Standard-Ausgabe Datei (Int 21h)}
    Puffer:Pointer;             {Zwischenpuffer fr Bildschirm}
    Groesse:Word;               {Dateigr”áe}
Begin
  Assign(Ansi,Name);            {Ansi-File ”ffnen}
  Assign(StdOut,'CON');         {Ausgabe-File ”ffnen}
  Reset(Ansi,1);                {Ansi-File mit Blockgr”áe 1 Byte init.}
  Groesse:=FileSize(Ansi);      {Gr”áe (in Byte) bestimmen}
  Reset(Ansi,Groesse);          {Datei mit dieser Gr”áe erneut initialisieren}
  Reset(StdOut,Groesse);        {Ausgabe-Datei initialisieren}
  GetMem(Puffer,Groesse);       {Puffer allokieren}
  BlockRead(Ansi,Puffer^,1);    {File lesen ...}
  BlockWrite(StdOut,Puffer^,1); {... und ausgeben}
  FreeMem(Puffer,Groesse);      {Puffer freigeben}
  Close(Ansi);                  {Dateien schlieáen}
  Close(StdOut);
End;


BEGIN
END.

