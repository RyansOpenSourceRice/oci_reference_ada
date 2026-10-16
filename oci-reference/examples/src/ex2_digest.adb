--  ex2_digest — validate a digest string.
with Ada.Text_IO; use Ada.Text_IO;
with OCI.Reference; use OCI.Reference;

procedure Ex2_Digest is
   Hex64 : constant String (1 .. 64) := (others => 'b');
begin
   Put_Line ("ok:" & Is_Valid_Digest ("sha256:" & Hex64)'Image);
   Put_Line ("bad:" & Is_Valid_Digest ("sha256:zzz")'Image);
end Ex2_Digest;
