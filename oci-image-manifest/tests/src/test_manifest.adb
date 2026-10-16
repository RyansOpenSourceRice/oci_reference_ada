--  Acceptance tests for OCI.Image.Manifest.
--
--  Copyright (c) 2026 RyansOpenSourceRice
--  SPDX-License-Identifier: Apache-2.0

with Ada.Text_IO; use Ada.Text_IO;
with OCI.Image.Manifest; use OCI.Image.Manifest;

procedure Test_Manifest is
   Failures : Natural := 0;

   Hex64 : constant String (1 .. 64) := [others => 'a'];
   HexB  : constant String (1 .. 64) := [others => 'b'];

   Good_Doc : constant String :=
     "{""schemaVersion"":2,"
     & """mediaType"":""" & Manifest_Media_Type & ""","
     & """config"":{""mediaType"":""" & Config_Media_Type & ""","
     & """digest"":""sha256:" & Hex64 & """,""size"":1471},"
     & """layers"":[{""mediaType"":""application/vnd.oci.image.layer.v1.tar+gzip"","
     & """digest"":""sha256:" & HexB & """,""size"":1234}]}";

   procedure Check (Doc   : String;
                    Expect_Valid  : Boolean;
                    Expect_Layers : Natural;
                    Name  : String) is
      V : Validation;
   begin
      Validate (Doc, V);
      if Valid (V) = Expect_Valid
        and then (not Expect_Valid or else V.Layers_Count = Expect_Layers)
      then
         Put_Line ("PASS: " & Name);
      else
         Put_Line ("FAIL: " & Name & " (valid=" & Valid (V)'Image
                   & " layers=" & V.Layers_Count'Image & ")");
         Failures := Failures + 1;
      end if;
   end Check;

begin
   Check (Good_Doc, True, 1, "good manifest, 1 layer");
   Check ("{}", False, 0, "empty object");
   Check ("", False, 0, "empty doc");
   Check (Good_Doc (Good_Doc'First .. Good_Doc'Last), True, 1, "good again");

   declare
      No_Schema : constant String :=
        "{""mediaType"":""" & Manifest_Media_Type & ""","
        & """config"":{""digest"":""sha256:" & Hex64 & """},"
        & """layers"":[{""digest"":""sha256:" & HexB & """}]}";
   begin
      Check (No_Schema, False, 0, "missing schemaVersion");
   end;

   declare
      Bad_MT : constant String :=
        "{""schemaVersion"":2,""mediaType"":""application/vnd.docker.distribution.manifest.v2+json"","
        & """config"":{""digest"":""sha256:" & Hex64 & """},"
        & """layers"":[{""digest"":""sha256:" & HexB & """}]}";
   begin
      Check (Bad_MT, False, 0, "wrong mediaType");
   end;

   declare
      No_Layers : constant String :=
        "{""schemaVersion"":2,""mediaType"":""" & Manifest_Media_Type & ""","
        & """config"":{""digest"":""sha256:" & Hex64 & """},"
        & """layers"":[]}";
   begin
      Check (No_Layers, False, 0, "no layers");
   end;

   declare
      Bad_Digest : constant String :=
        "{""schemaVersion"":2,""mediaType"":""" & Manifest_Media_Type & ""","
        & """config"":{""digest"":""sha256:zzz""},"
        & """layers"":[{""digest"":""sha256:" & HexB & """}]}";
   begin
      Check (Bad_Digest, False, 0, "bad config digest");
   end;

   if Failures = 0 then
      Put_Line ("ALL TESTS PASSED");
   else
      Put_Line ("FAILURES:" & Failures'Image);
      raise Program_Error with "test failures";
   end if;
end Test_Manifest;
