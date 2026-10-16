--  OCI.Reference spec (SPARK Silver).
--
--  Parses OCI distribution-spec references:
--  [registry[:port]/]path[:tag][@digest].
--
--  Copyright (c) 2026 RyansOpenSourceRice
--  SPDX-License-Identifier: Apache-2.0

pragma SPARK_Mode (On);

package OCI.Reference is

   Max_Digest_Length : constant := 256;

   Default_Tag : constant String := "latest";

   type Reference (Max_Length : Positive) is record
      Value      : String (1 .. Max_Length) := [others => ' '];
      Len        : Natural := 0;
      Digest     : String (1 .. Max_Digest_Length) := [others => ' '];
      Digest_Len : Natural := 0;
   end record;

   function Length (Ref : Reference) return Natural is (Ref.Len);

   function Has_Digest (Ref : Reference) return Boolean is
     (Ref.Digest_Len > 0);

   --  Digest grammar: algorithm ":" hex, algorithm chars
   --  [a-zA-Z0-9_.+-], hex run of at least 32 nibbles.
   function Is_Valid_Digest (Digest : String) return Boolean
     with Post => (if Is_Valid_Digest'Result
                   then Digest'Length in 8 .. Max_Digest_Length);

   --  Parse a reference. Input longer than 8_192 chars is invalid
   --  (fail-closed DoS bound). Slices with arbitrary 'First accepted.
   procedure Parse
     (Input  : in String;
      Result : out Reference;
      Valid  : out Boolean)
     with Pre  => Input'Length <= 8_192 and Result.Max_Length > 0,
          Post => (if Valid then Length (Result) > 0
                   and Length (Result) <= Result.Max_Length);

   --  Explicit tag, or "latest" when absent. Tag is blank-filled
   --  first; Len = 0 means empty ref or buffer too small.
   procedure Tag_Or_Default
     (Ref : in Reference;
      Tag : out String;
      Len : out Natural)
     with Pre => Tag'Length > 0;

end OCI.Reference;
