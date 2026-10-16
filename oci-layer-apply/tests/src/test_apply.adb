--  Acceptance tests for OCI.Layer.Apply.
--
--  Copyright (c) 2026 RyansOpenSourceRice
--  SPDX-License-Identifier: Apache-2.0

with Ada.Text_IO; use Ada.Text_IO;
with OCI.Layer.Apply; use OCI.Layer.Apply;

procedure Test_Apply is
   Failures : Natural := 0;

   procedure Check (Got : Boolean; Expect : Boolean; Name : String) is
   begin
      if Got = Expect then
         Put_Line ("PASS: " & Name);
      else
         Put_Line ("FAIL: " & Name);
         Failures := Failures + 1;
      end if;
   end Check;

   O : Order_Array;
   C : Chain := Empty_Chain;
   HexA : constant String (1 .. 64) := [others => 'a'];
   HexB : constant String (1 .. 64) := [others => 'b'];
begin
   Apply_Order (3, O);
   Check (O (1) = 1 and O (2) = 2 and O (3) = 3, True, "order 1..3");
   Apply_Order (0, O);
   Check (O (1) = 0, True, "order empty");

   Check (Is_Whiteout (".wh.foo"), True, "whiteout bare");
   Check (Is_Whiteout ("a/b/.wh.foo"), True, "whiteout nested");
   Check (Is_Whiteout ("a/.wh..wh..opq"), True, "opaque is whiteout-shaped");
   Check (Is_Whiteout ("normal"), False, "plain file");
   Check (Is_Whiteout ("a.wh.foo"), False, "prefix mid-name");
   Check (Is_Whiteout (""), False, "empty path");
   Check (Is_Whiteout ("dir/"), False, "trailing slash");

   Check (Opaque_Dir (".wh..wh..opq"), True, "opaque bare");
   Check (Opaque_Dir ("a/.wh..wh..opq"), True, "opaque nested");
   Check (Opaque_Dir (".wh.foo"), False, "whiteout not opaque");
   Check (Opaque_Dir ("x.wh..wh..opq"), False, "opaque mid-name");

   C := Chain_Append (C, "sha256:" & HexA);
   C := Chain_Append (C, "sha256:" & HexB);
   Check (To_String (C) = "sha256:" & HexA & " sha256:" & HexB,
          True, "chain append two");

   if Failures = 0 then
      Put_Line ("ALL TESTS PASSED");
   else
      Put_Line ("FAILURES:" & Failures'Image);
      raise Program_Error with "test failures";
   end if;
end Test_Apply;
