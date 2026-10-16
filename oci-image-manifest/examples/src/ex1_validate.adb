--  ex1_validate — validate a manifest document.
--
--  Copyright (c) 2026 RyansOpenSourceRice
--  SPDX-License-Identifier: Apache-2.0

with Ada.Text_IO; use Ada.Text_IO;
with OCI.Image.Manifest; use OCI.Image.Manifest;

procedure Ex1_Validate is
   Hex : constant String (1 .. 64) := [others => 'c'];
   Doc : constant String :=
     "{""schemaVersion"":2,"
     & """mediaType"":""" & Manifest_Media_Type & ""","
     & """config"":{""digest"":""sha256:" & Hex & """},"
     & """layers"":[{""digest"":""sha256:" & Hex & """}]}";
   V : Validation;
begin
   Validate (Doc, V);
   Put_Line ("valid =" & Valid (V)'Image
             & " layers =" & V.Layers_Count'Image);
end Ex1_Validate;
