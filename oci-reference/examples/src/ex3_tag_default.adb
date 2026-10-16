--  ex3_tag_default — tag or "latest".
with Ada.Text_IO; use Ada.Text_IO;
with OCI.Reference; use OCI.Reference;

procedure Ex3_Tag_Default is
   Ref   : Reference (Max_Length => 256);
   Valid : Boolean;
   Tag   : String (1 .. 128);
   Len   : Natural;
begin
   Parse ("docker.io/library/debian", Ref, Valid);
   Tag_Or_Default (Ref, Tag, Len);
   Put_Line ("tag: " & Tag (1 .. Len));
end Ex3_Tag_Default;
