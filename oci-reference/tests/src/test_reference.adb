--  test_reference — acceptance tests for OCI.Reference.
--
--  Copyright (c) 2026 RyansOpenSourceRice
--  SPDX-License-Identifier: Apache-2.0

with Ada.Text_IO; use Ada.Text_IO;
with OCI.Reference; use OCI.Reference;

procedure Test_Reference is
   Failures : Natural := 0;

   procedure Check (Name : String; Cond : Boolean) is
   begin
      if Cond then
         Put_Line ("PASS: " & Name);
      else
         Put_Line ("FAIL: " & Name);
         Failures := Failures + 1;
      end if;
   end Check;

   procedure Check_Parse
     (Input : String; Expect_Valid : Boolean; Name : String)
   is
      Ref   : Reference (Max_Length => 512);
      Valid : Boolean;
   begin
      Parse (Input, Ref, Valid);
      Check (Name & " (valid=" & Valid'Image & ")", Valid = Expect_Valid);
      if Expect_Valid then
         Check (Name & " length", Length (Ref) = Input'Length);
      end if;
   end Check_Parse;

   Ref   : Reference (Max_Length => 512);
   Valid : Boolean;
   Tag   : String (1 .. 128);
   Len   : Natural;
   Hex64 : constant String (1 .. 64) := (others => 'a');
begin
   Check_Parse ("docker.io/library/debian:bookworm", True, "tagged");
   Check_Parse ("docker.io/library/debian", True, "untagged defaults");
   Check_Parse ("localhost:5000/a/b:c1", True, "registry port");
   Check_Parse ("ghcr.io/o/r@sha256:" & Hex64, True, "digest");
   Check_Parse ("r:1@sha256:" & Hex64, True, "tag+digest");

   Check_Parse ("", False, "empty");
   Check_Parse ("UPPER CASE", False, "space+upper");
   Check_Parse ("repo:", False, "empty tag");
   Check_Parse ("@sha256:" & Hex64, False, "digest only");
   Check_Parse ("repo@sha256:zzz", False, "bad digest");
   Check_Parse ("repo@sha256:" & Hex64 & " trailing", False, "trailing junk");
   Check_Parse ("localhost:/a", False, "empty port");
   Check_Parse ("localhost:abc/a", False, "alpha port");
   Check_Parse ("a/b:1/c", False, "colon after slash in name");

   Check ("digest ok", Is_Valid_Digest ("sha256:" & Hex64));
   Check ("digest short", not Is_Valid_Digest ("sha256:abc"));
   Check ("digest no colon", not Is_Valid_Digest ("sha256" & Hex64));

   Parse ("docker.io/library/debian", Ref, Valid);
   Tag_Or_Default (Ref, Tag, Len);
   Check ("default tag", Len = 6 and then Tag (1 .. Len) = "latest");

   Parse ("docker.io/library/debian:bookworm", Ref, Valid);
   Tag_Or_Default (Ref, Tag, Len);
   Check ("explicit tag", Len = 8 and then Tag (1 .. Len) = "bookworm");

   Parse ("ghcr.io/o/r@sha256:" & Hex64, Ref, Valid);
   Check ("has digest", Valid and then Has_Digest (Ref));
   Tag_Or_Default (Ref, Tag, Len);
   Check ("digest implies latest", Len = 6 and then Tag (1 .. Len) = "latest");

   if Failures > 0 then
      Put_Line ("FAILURES:" & Failures'Image);
      raise Program_Error with "test failures";
   end if;
   Put_Line ("ALL TESTS PASSED");
end Test_Reference;
