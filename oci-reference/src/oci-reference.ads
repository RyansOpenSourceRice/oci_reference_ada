--  OCI.Reference — distribution-spec reference parser (SPARK Silver).
--
--  Copyright (c) 2026 RyansOpenSourceRice
--  SPDX-License-Identifier: Apache-2.0
--
--  Grammar: [registry[:port]/]path[:tag][@digest]
--  where digest = algorithm ":" hex-encoded digest.

pragma SPARK_Mode (On);

package OCI.Reference is

   Default_Tag : constant String := "latest";

   Max_Digest_Length : constant Positive := 256;

   type Reference (Max_Length : Positive) is private;

   function Length (Ref : Reference) return Natural
   with
      Post => Length'Result <= Ref.Max_Length;

   function Has_Digest (Ref : Reference) return Boolean;

   function Is_Valid_Digest (Digest : String) return Boolean
   with
      Post =>
        (if Is_Valid_Digest'Result then Digest'Length >= 8
         and then Digest'Length <= Max_Digest_Length);

   procedure Parse
     (Input  : in String;
      Result : out Reference;
      Valid  : out Boolean)
   with
      Pre  => Input'Length <= 8_192 and then Result.Max_Length > 0,
      Post =>
        (if Valid then Length (Result) > 0
         and then Length (Result) <= Result.Max_Length);

   procedure Tag_Or_Default
     (Ref : in Reference;
      Tag : out String;
      Len : out Natural)
   with
      Pre  => Tag'Length > 0,
      Post => Len <= Tag'Length;

private

   type Reference (Max_Length : Positive) is record
      Value      : String (1 .. Max_Length) := [others => ' '];
      Len        : Natural := 0;
      Digest     : String (1 .. Max_Digest_Length) := [others => ' '];
      Digest_Len : Natural := 0;
   end record
   with Dynamic_Predicate => Len <= Max_Length and Digest_Len <= Max_Digest_Length;

end OCI.Reference;
