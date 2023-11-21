unit Alphabet;

INTERFACE

 const Q = 255;
       Number : array[0..9,1..25] of byte =
(
( Q,Q,Q,Q,Q,
  Q,Q,0,0,Q,
  Q,0,Q,0,Q,
  Q,0,0,Q,Q,
  Q,Q,Q,Q,Q ),

( 0,0,Q,0,0,
  0,0,Q,0,0,
  0,0,Q,0,0,
  0,0,Q,0,0,
  0,0,Q,0,0 ),

( Q,Q,Q,Q,Q,
  0,0,0,0,Q,
  Q,Q,Q,Q,Q,
  Q,0,0,0,0,
  Q,Q,Q,Q,Q ),

( Q,Q,Q,Q,Q,
  0,0,0,0,Q,
  Q,Q,Q,Q,Q,
  0,0,0,0,Q,
  Q,Q,Q,Q,Q ),

( Q,0,Q,0,0,
  Q,0,Q,0,0,
  Q,Q,Q,Q,Q,
  0,0,Q,0,0,
  0,0,Q,0,0 ),

( Q,Q,Q,Q,Q,
  Q,0,0,0,0,
  Q,Q,Q,Q,Q,
  0,0,0,0,Q,
  Q,Q,Q,Q,Q ),

( Q,Q,Q,Q,Q,
  Q,0,0,0,0,
  Q,Q,Q,Q,Q,
  Q,0,0,0,Q,
  Q,Q,Q,Q,Q ),

( Q,Q,Q,Q,Q,
  0,0,0,0,Q,
  0,0,0,0,Q,
  0,0,0,0,Q,
  0,0,0,0,Q ),

( Q,Q,Q,Q,Q,
  Q,0,0,0,Q,
  Q,Q,Q,Q,Q,
  Q,0,0,0,Q,
  Q,Q,Q,Q,Q ),

( Q,Q,Q,Q,Q,
  Q,0,0,0,Q,
  Q,Q,Q,Q,Q,
  0,0,0,0,Q,
  Q,Q,Q,Q,Q ) );

 Letter : array['A'..'Z',1..25] of byte =

(
( Q,Q,Q,Q,Q,
  Q,0,0,0,Q,
  Q,Q,Q,Q,Q,
  Q,0,0,0,Q,
  Q,0,0,0,Q ),

( Q,Q,Q,Q,Q,
  Q,0,0,0,Q,
  Q,Q,Q,Q,0,
  Q,0,0,0,Q,
  Q,Q,Q,Q,Q ),

( Q,Q,Q,Q,Q,
  Q,0,0,0,0,
  Q,0,0,0,0,
  Q,0,0,0,0,
  Q,Q,Q,Q,Q ),

( Q,Q,Q,Q,0,
  Q,0,0,0,Q,
  Q,0,0,0,Q,
  Q,0,0,0,Q,
  Q,Q,Q,Q,0 ),

( Q,Q,Q,Q,Q,
  Q,0,0,0,0,
  Q,Q,Q,Q,Q,
  Q,0,0,0,0,
  Q,Q,Q,Q,Q ),

( Q,Q,Q,Q,Q,
  0,0,Q,0,0,
  0,Q,Q,Q,0,
  0,0,Q,0,0,
  0,0,Q,0,0 ),

( Q,Q,Q,Q,Q,
  Q,0,0,0,0,
  Q,0,Q,Q,Q,
  Q,0,0,0,Q,
  Q,Q,Q,Q,Q ),

( Q,0,0,0,Q,
  Q,0,0,0,Q,
  Q,Q,Q,Q,Q,
  Q,0,0,0,Q,
  Q,0,0,0,Q ),

( 0,0,Q,0,0,
  0,0,Q,0,0,
  0,0,Q,0,0,
  0,0,Q,0,0,
  0,0,Q,0,0 ),

( Q,Q,Q,Q,Q,
  0,0,0,0,Q,
  0,0,0,0,Q,
  Q,0,0,0,Q,
  0,Q,Q,Q,Q ),

( Q,0,0,0,Q,
  Q,0,0,Q,0,
  Q,Q,Q,0,0,
  Q,0,0,Q,0,
  Q,0,0,0,Q ),

( Q,0,0,0,0,
  Q,0,0,0,0,
  Q,0,0,0,0,
  Q,0,0,0,0,
  Q,Q,Q,Q,Q ),

( Q,Q,0,Q,Q,
  Q,0,Q,0,Q,
  Q,0,Q,0,Q,
  Q,0,0,0,Q,
  Q,0,0,0,Q ),

( Q,Q,0,0,Q,
  Q,Q,0,0,Q,
  Q,0,Q,0,Q,
  Q,0,0,Q,Q,
  Q,0,0,Q,Q ),

( Q,Q,Q,Q,Q,
  Q,0,0,0,Q,
  Q,0,0,0,Q,
  Q,0,0,0,Q,
  Q,Q,Q,Q,Q ),

( Q,Q,Q,Q,Q,
  Q,0,0,0,Q,
  Q,Q,Q,Q,Q,
  Q,0,0,0,0,
  Q,0,0,0,0 ),

( Q,Q,Q,Q,Q,
  Q,0,0,0,Q,
  Q,0,Q,0,Q,
  Q,0,0,Q,Q,
  Q,Q,Q,Q,Q ),

( Q,Q,Q,Q,Q,
  Q,0,0,0,Q,
  Q,Q,Q,Q,Q,
  Q,0,0,Q,0,
  Q,0,0,0,Q ),

( 0,Q,Q,Q,Q,
  Q,0,0,0,0,
  Q,Q,Q,Q,Q,
  0,0,0,0,Q,
  Q,Q,Q,Q,0 ),

( Q,Q,Q,Q,Q,
  0,0,Q,0,0,
  0,0,Q,0,0,
  0,0,Q,0,0,
  0,0,Q,0,0 ),

( Q,0,0,0,Q,
  Q,0,0,0,Q,
  Q,0,0,0,Q,
  Q,0,0,0,Q,
  Q,Q,Q,Q,Q ),

( Q,0,0,0,Q,
  Q,0,0,0,Q,
  Q,0,0,0,Q,
  0,Q,0,Q,0,
  0,0,Q,0,0 ),

( Q,0,0,0,Q,
  Q,0,0,0,Q,
  Q,0,Q,0,Q,
  Q,0,Q,0,Q,
  Q,Q,Q,Q,Q ),

( Q,0,0,0,Q,
  0,Q,0,Q,0,
  0,0,Q,0,0,
  0,Q,0,Q,0,
  Q,0,0,0,Q ),

( Q,0,0,0,Q,
  Q,0,0,0,Q,
  Q,Q,Q,Q,Q,
  0,0,0,0,Q,
  Q,Q,Q,Q,Q ),

( Q,Q,Q,Q,Q,
  0,0,0,Q,0,
  0,0,Q,0,0,
  0,Q,0,0,0,
  Q,Q,Q,Q,Q ) );

procedure PutNumber (SX, SY : word; No : byte);
procedure PutLetter (SX, SY : word; No : char);

IMPLEMENTATION

procedure PutNumber (SX, SY : word; No : byte);
 var PX, PY, I : word;
 begin
  I := 1;
  for PY := SY to SY+4 do
   for PX := SX to SX+4 do
    begin
      if Number[No][I] <> 0 then mem[$0a000:320*PY+PX] := Number[No][I];
     inc (I);
    end;
 end;

procedure PutLetter (SX, SY : word; No : char);
 var PX, PY, I : word;
 begin
  I := 1;
  for PY := SY to SY+4 do
   for PX := SX to SX+4 do
    begin
      if Letter[No][I] <> 0 then mem[$0a000:320*PY+PX] := Letter[No][I];
     inc (I);
    end;
 end;

BEGIN
END.
