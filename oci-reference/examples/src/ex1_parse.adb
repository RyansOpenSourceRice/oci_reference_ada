--  ex1_parse — parse a reference, print validity.
--  Read in under five minutes.
with Ada.Text_IO; use Ada.Text_IO;
with OCI.Reference; use OCI.Reference;

procedure Ex1_Parse is
   Ref   : Reference (Max_Length => 256);
   Valid : Boolean;
begin
   Parse ("docker.io/library/debian:bookworm", Ref, Valid);
   Put_Line ("valid:" & Valid'Image & " len:" & Length (Ref)'Image);
end Ex1_Parse;
