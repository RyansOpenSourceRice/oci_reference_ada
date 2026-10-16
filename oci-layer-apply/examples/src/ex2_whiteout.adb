--  ex2_whiteout — classify tar entry names.
--
--  Copyright (c) 2026 RyansOpenSourceRice
--  SPDX-License-Identifier: Apache-2.0

with Ada.Text_IO; use Ada.Text_IO;
with OCI.Layer.Apply; use OCI.Layer.Apply;

procedure Ex2_Whiteout is
   procedure Show (P : String) is
   begin
      Put_Line (P & " whiteout=" & Is_Whiteout (P)'Image
                & " opaque=" & Opaque_Dir (P)'Image);
   end Show;
begin
   Show ("etc/passwd");
   Show (".wh.etc");
   Show ("var/.wh..wh..opq");
end Ex2_Whiteout;
