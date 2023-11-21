UNIT Joy;
{ Copyright 1996 by Dennis Mittmann }

INTERFACE
  FUNCTION JoyStickX:WORD;
  FUNCTION JoyStickY:WORD;
  FUNCTION JoyButton1:BOOLEAN;
  FUNCTION JoyButton2:BOOLEAN;
  FUNCTION JoyButton3:BOOLEAN;
  FUNCTION JoyButton4:BOOLEAN;

IMPLEMENTATION

FUNCTION JoyStickX:WORD;
  BEGIN
  INLINE($1E/
         $50/
         $52/
         $56/
         $BA/$01/$02/
         $B4/$01/
         $BE/$00/$00/
         $8E/$DE/
         $FA/
         $EE/
         $46/
         $EC/
         $84/$C4/
         $75/$FA/
         $FB/
         $89/$36/$64/$12/
         $5E/
         $5A/
         $58/
         $1F);
  JoyStickX:=MemW[0:$1264];
END;

FUNCTION JoyStickY:WORD;
  BEGIN
  INLINE($1E/
         $50/
         $52/
         $56/
         $BA/$01/$02/
         $B4/$01/
         $BE/$00/$00/
         $8E/$DE/
         $FA/
         $EE/
         $46/
         $EC/
         $84/$C4/
         $75/$FA/
         $FB/
         $89/$36/$64/$12/
         $5E/
         $5A/
         $58/
         $1F);
  JoyStickY:=MemW[0:$1264];
END;

FUNCTION JoyButton1:BOOLEAN;
  BEGIN
    JoyButton1:=(Port[$201] AND 16)=0;
  END;

FUNCTION JoyButton2:BOOLEAN;
  BEGIN
    JoyButton2:=(Port[$201] AND 32)=0;
  END;

FUNCTION JoyButton3:BOOLEAN;
  BEGIN
    JoyButton3:=(Port[$201] AND 64)=0;
  END;

FUNCTION JoyButton4:BOOLEAN;
  BEGIN
    JoyButton4:=(Port[$201] AND 128)=0;
  END;

END.
