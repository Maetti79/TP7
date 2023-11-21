UNIT DM_TOOLS; { Copyright 1996 by Dennis Mittmann }

INTERFACE
USES CRT,DOS;
TYPE FadeType=array[0..10] of byte;
     pcxheader_rec=record
     manufacturer: byte;
     version: byte;
     encoding: byte;
     bits_per_pixel: byte;
     xmin, ymin: word;
     xmax, ymax: word;
     hres: word;
     vres: word;
     palette: array [0..47] of byte;
     reserved: byte;
     colour_planes: byte;
     bytes_per_line: word;
     palette_type: word;
     filler: array [0..57] of byte;
     end;
CONST Table:FadeType=(10,black,red,lightred,yellow,white,yellow,lightred,
                     red{,black},darkgray,lightgray);
var header: pcxheader_rec;
    width, depth: word;
    bytes: word;
    palette: array [0..767] of byte;
    f: file;
    c: byte;
{--------------------------------}
procedure fadewriteln(s:string;dela:word;fade:fadetype);
procedure showpcx(sss:string);
procedure WaitKey;
procedure DefineColor (Col, R, G, B : byte);
procedure ChangeColor (Color1, Color2 : byte);
procedure InitGFX;
procedure InitSVGA_640_480_256;
procedure InitSVGA_640_400_256;
procedure InitTXT;
procedure PutPixel (X, Y : word; Col : byte);
function GetPixel (X, Y : word) : byte;
procedure FillScreen (Color : byte);
procedure Rectangle (X1, Y1, X2, Y2 : word; Color : byte);
procedure Bar (X1, Y1, X2, Y2 : word; Color : byte);
procedure ClearScreen;
procedure Retrace;
procedure ScreenOff;
procedure ScreenOn;
procedure FadeIn;
procedure DarkenScreen;
procedure LightenScreen;
procedure BloodyScreen;
procedure CursorOn;
procedure CursorOff;
procedure BarTxt (X1, Y1, X2, Y2, Color : byte);


IMPLEMENTATION
{--------------------------------}

procedure fadewriteln(s:string;dela:word;fade:fadetype);
var c:byte;
begin
     for c:=1 to fade[0]-1 do begin
         Textcolor(fade[c]);
         write(s);
         gotoxy(1,wherey);
         delay(dela div fade[0]);
     end;
     Textcolor(fade[fade[0]]);
     writeln(s);
     delay(dela div fade[0]);
end;

procedure Read_PCX_Line(vidoffset: word);
var c, run: byte;
    n: integer;
    w: word;
begin
  n:=0;
  while (n < bytes) do
  begin
    blockread (f, c, 1);

    { if it's a run of bytes field }
    if ((c and 192)=192) then
    begin

      { and off the high bits }
      run:=c and 63;

      { get the run byte }
      blockread (f, c, 1);
      n:=n+run;
      for w:=0 to run-1 do
      begin
        if c=0 then mem [$a000:vidoffset]:=5 else mem [$a000:vidoffset]:=0;
        inc (vidoffset);
      end;
    end else
    begin
      n:=n+1;
      mem [$a000:vidoffset]:=c;
      inc (vidoffset);
    end;
  end;
end;

procedure Unpack_PCX_File;
var i: word;
begin
  for i:=0 to 767 do
    palette [i]:=palette [i] shr 2;
  asm
    mov ax,13h
    int 10h
    mov ax,1012h
    xor bx,bx
    mov cx,256
    mov dx,offset palette
    int 10h
  end;
  for i:=0 to depth-1 do
    Read_PCX_Line (i*320);
end;

procedure showpcx(sss:string);
begin
    assign (f, sss);
    reset (f,1);
    blockread (f, header, sizeof (header));
    if (header.manufacturer=10) and (header.version=5) and
       (header.bits_per_pixel=8) and (header.colour_planes=1) then
    begin
      seek (f, filesize (f)-769);
      blockread (f, c, 1);
      if (c=12) then
      begin
        blockread (f, palette, 768);
        seek (f, 128);
        width:=header.xmax-header.xmin+1;
        depth:=header.ymax-header.ymin+1;
        bytes:=header.bytes_per_line;
        Unpack_PCX_File;
      end else writeln ('Error reading palette.');
    end else writeln ('Not a 256 colour PCX file.');
    close (f);
end;

procedure WaitKey; assembler;
 asm
  mov ah, 7
  int 21h
 end;

procedure Retrace; assembler;
 asm
  mov dx, 3dah
 @Ret1:
  in al, dx
  test al, 08h
  jnz @Ret1
 @Ret2:
  in al, dx
  test al, 08h
  jnz @Ret2
 end;

procedure DefineColor (Col, R, G, B : byte); assembler;
 asm
  mov dx, 3c8h
  mov al, byte ptr Col
  out dx, al
  mov dx, 3c9h
  mov al, byte ptr R
  out dx, al
  mov al, byte ptr G
  out dx, al
  mov al, byte ptr B
  out dx, al
 end;

procedure InitGFX; assembler;
 asm
  mov ax, 0013h
  int 10h
 end;

procedure InitSVGA_640_480_256; assembler;
 asm
  mov ah, 4fh
  mov al, 02h
  mov bx, 101h
  { btr bx, 15 erst ab 386 }
  int 10h
 end;

procedure InitSVGA_640_400_256; assembler;
 asm
  mov ah, 4fh
  mov al, 02h
  mov bx, 100h
  { btr bx, 15 erst ab 386 }
  int 10h
 end;

procedure InitTXT; assembler;
 asm
  mov ax, 0003h
  int 10h
 end;

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

function GetPixel (X, Y : word) : byte;
 begin
  GetPixel  := mem[$0a000:320*Y+X];
 end;

procedure FillScreen (Color : byte); assembler;
 asm
  mov ax, 0a000h
  mov es, ax
  xor di, di
  mov al, byte ptr Color
  mov cx, 64000
  rep stosb
 end;

procedure Rectangle (X1, Y1, X2, Y2 : word; Color : byte);
 var X, Y : word;
 begin
  for X := X2 downto X1 do
   begin
    PutPixel (X, Y1, Color);
    PutPixel (X, Y2, Color);
   end;
  for Y := Y2 downto Y1 do
   begin
    PutPixel (X1, Y, Color);
    PutPixel (X2, Y, Color);
   end;
 end;

procedure Bar (X1, Y1, X2, Y2 : word; Color : byte);
 var X, Y : word;
 begin
  for Y := Y2 downto Y1 do
   for X := X2 downto X1 do
    mem[$0a000:320*Y+X] := Color;
 end;

procedure ChangeColor (Color1, Color2 : byte);
 var R1, R2, G1, G2, B1, B2 : byte;
 begin
  asm
   mov dx, 3c7h
   mov al, byte ptr Color1
   out dx, al
   mov dx, 3c9h
   in al, dx
   mov byte ptr R1, al
   in al, dx
   mov byte ptr G1, al
   in al, dx
   mov byte ptr B1, al
   mov dx, 3c7h
   mov al, byte ptr Color2
   out dx, al
   mov dx, 3c9h
   in al, dx
   mov byte ptr R2, al
   in al, dx
   mov byte ptr G2, al
   in al, dx
   mov byte ptr B2, al
   mov dx, 3c8h
   mov al, byte ptr Color1
   out dx, al
   mov dx, 3c9h
   mov al, byte ptr R2
   out dx, al
   mov al, byte ptr G2
   out dx, al
   mov al, byte ptr B2
   out dx, al
   mov dx, 3c8h
   mov al, byte ptr Color2
   out dx, al
   mov dx, 3c9h
   mov al, R1
   out dx, al
   mov al, G1
   out dx, al
   mov al, B1
   out dx, al
   call Retrace
  end;
 end;

procedure ClearScreen; assembler;
 asm
  mov ax, 0a000h
  mov es, ax
  xor di, di
  xor ax, ax
  mov cx, 64000
  rep stosw
 end;

procedure ScreenOff; assembler;
 asm
  mov dx, 3c4h
  mov al, 1
  out dx, al
  mov dx, 3c5h
  in al, dx
  or al, 32
  out dx, al
 end;

procedure ScreenOn; assembler;
 asm
  mov dx, 3c4h
  mov al, 1
  out dx, al
  mov dx, 3c5h
  in al, dx
  mov ah, 32
  not ah
  and al, ah
  out dx, al
 end;

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
     Retrace;
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
     Retrace;
    end;
 end;

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

procedure BloodyScreen;
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
      if G > 0 then dec (G);
      if B > 0 then dec (B);
     DefineColor (C, R, G, B);
     Retrace;
    end;
 end;

procedure CursorOn; assembler;
 asm
  mov ah, 1
  mov cx, 0708h
  int 10h
 end;

procedure CursorOff; assembler;
 asm
  mov ah, 1
  mov cx, 3232h
  int 10h
 end;

procedure BarTxt (X1, Y1, X2, Y2, Color : byte);
 var X, Y, OldX, OldY : byte;
 begin
  OldX := whereX;
  OldY := whereY;
  textbackground (0);
  textcolor (Color);
  for Y := Y2 downto Y1 do
   for X := X2 downto X1 do
    begin
     gotoxy (X, Y);
     write (' ');
    end;
  gotoxy (X1, Y1);
  write ('É');
  gotoxy (X2, Y1);
  write ('»');
  gotoxy (X1, Y2);
  write ('È');
  gotoxy (X2, Y2);
  write ('¼');
  for X := X1+1 to X2-1 do
   begin
    gotoxy (X, Y1);
    write ('Í');
    gotoxy (X, Y2);
    write ('Í');
   end;
  for Y := Y1+1 to Y2-1 do
   begin
    gotoxy (X1, Y);
    write ('º');
    gotoxy (X2, Y);
    write ('º');
   end;
  gotoxy (OldX, OldY);
 end;

END.
