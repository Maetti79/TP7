UNIT Mouse;
{ Copyright 1996 by Dennis Mittmann }

INTERFACE
USES DOS;
CONST
  LeftButton           = 1;
  RightButton          = 2;
  MiddleButton         = 4;
  HardWareTextCursor   = 1;
  SoftWareTextCursor   = 0;
  event_CursorMoved           = 1;
  event_LeftButtonPressed     = 2;
  event_LeftButtonReleased    = 4;
  event_RightButtonPressed    = 8;
  event_RightButtonReleased   = 16;
  event_MiddleButtonPressed   = 32;
  event_MiddleButtonReleased  = 64;

TYPE regs = registers;

PROCEDURE ResetMouse (VAR state:regs);
PROCEDURE SetCursorDisplay (on:BOOLEAN);
PROCEDURE ReadMouse (VAR x,y:INTEGER;
          VAR LeftButton,RightButton,MiddleButton:BOOLEAN);
PROCEDURE SetCursorLocation (x,y:INTEGER);
PROCEDURE ReadMouseButtonPress (which:INTEGER;
          VAR Button:BOOLEAN;
          VAR Count,y,x:INTEGER);
PROCEDURE ReadMouseButtonRelease (Which:INTEGER;
          VAR Button:BOOLEAN;
          VAR Count,x,y:INTEGER);
PROCEDURE DefineGraphicsCursor (hotspotx,hotspoty:INTEGER; Shape:WORD);
PROCEDURE DefineTextCursor (select:INTEGER; ScreenMask,CursorMask:WORD);
PROCEDURE DefineMouseSensetivity (ratio_x,ratio_y:INTEGER);

IMPLEMENTATION
CONST  MouseInterrupt =$33;
VAR    Reg:Regs;

PROCEDURE ResetMouse (VAR state:regs);
BEGIN
  state.ax:=0;
  INTR(MouseInterrupt,state);
END;

PROCEDURE SetCursorDisplay (on:BOOLEAN);
BEGIN
  IF on
    THEN reg.ax:=1
    ELSE reg.ax:=2;
  INTR(MouseInterrupt,reg);
END;

PROCEDURE ReadMouse (VAR x,y:INTEGER;
          VAR LeftButton,RightButton,MiddleButton:BOOLEAN);
BEGIN
  reg.ax:=3;
  INTR(MouseInterrupt,reg);
  With reg DO BEGIN
    LeftButton:=(bx AND 1)=1;
    RightButton:=(bx AND 2)=2;
    MiddleButton:=(bx AND 4)=4;
    X:= cx;
    Y:= dx;
  END;
END;

PROCEDURE SetCursorLocation (x,y:INTEGER);
BEGIN
  reg.ax:=4;
  reg.cx:=x;
  reg.dx:=y;
  INTR(MouseInterrupt,reg);
END;

PROCEDURE ReadMouseButtonPress (which:INTEGER;
          VAR Button:BOOLEAN;
          VAR Count,y,x:INTEGER);
BEGIN
  reg.ax:=5;
  IF ((which=LeftButton) OR (which=RightButton) OR (which=MiddleButton))
    THEN BEGIN
     reg.bx:=which;
     INTR(MouseInterrupt,reg);
     Button := (reg.ax AND which)=which;
     Count  := reg.bx;
     x:= reg.cx;
     y:= reg.dx;
    END ELSE BEGIN
     which := -1;
     Button:= FALSE;
     Count := -1;
     X     := -1;
     Y     := -1;
   END;
END;

PROCEDURE ReadMouseButtonRelease (which:INTEGER;
          VAR Button:BOOLEAN;
          VAR count,x,y:INTEGER);
BEGIN
  reg.ax:=5;
  IF ((which=LeftButton) OR (which=RightButton) OR (which=MiddleButton))
    THEN BEGIN
     reg.bx:=which;
     INTR(MouseInterrupt,reg);
     Button := (reg.ax AND which)=which;
     Count  := reg.bx;
     x:= reg.cx;
     y:= reg.dx;
    END ELSE BEGIN
     which := -1;
     Button:= FALSE;
     Count := -1;
     X     := -1;
     Y     := -1;
   END;
END;

PROCEDURE DefineGraphicsCursor (hotspotx,hotspoty:INTEGER; Shape:WORD);
BEGIN
  reg.ax:=9;
  reg.bx:=hotspotx;
  reg.cx:=hotspoty;
  reg.dx:=Shape;
  INTR(MouseInterrupt,reg);
END;

PROCEDURE DefineTextCursor (select:INTEGER; ScreenMask,CursorMask:WORD);
BEGIN
  reg.ax:=10;
  reg.bx:=select;
  reg.cx:=screenmask;
  reg.dx:=cursormask;
  INTR(MouseInterrupt,reg);
END;

PROCEDURE DefineMouseSensetivity (ratio_x,ratio_y:INTEGER);
BEGIN
  reg.ax:=15;
  IF ratio_x<1 THEN ratio_x:=1;
  IF ratio_y<1 THEN ratio_y:=1;
  reg.cx:=ratio_x;
  reg.dx:=ratio_y;
  INTR(MouseInterrupt,reg);
END;

END.



