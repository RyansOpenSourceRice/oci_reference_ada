--  OCI.Image.Manifest body.
--
--  Proof strategy: Validate normalizes Doc into a 1-based work buffer
--  (Doc'Length <= Max_Doc_Length keeps it stack-allocatable), so every
--  later index is a Plain Positive in 1 .. N.
--
--  Copyright (c) 2026 RyansOpenSourceRice
--  SPDX-License-Identifier: Apache-2.0

pragma SPARK_Mode (On);

with OCI.Reference;

package body OCI.Image.Manifest is

   function Contains (S : String; N : Natural; Needle : String) return Boolean
     with Pre  => S'First = 1 and N <= S'Length and N <= Max_Doc_Length
                  and Needle'Length >= 1,
          Post => (if Contains'Result then N >= Needle'Length)
   is
      L : constant Natural := Needle'Length;
   begin
      if N < L then
         return False;
      end if;
      pragma Assert (N >= L);
      for I in 1 .. N - L + 1 loop
         pragma Loop_Invariant (I - 1 <= N - L);
         if S (I .. I + L - 1) = Needle then
            return True;
         end if;
      end loop;
      return False;
   end Contains;

   function Is_Hex (C : Character) return Boolean is
     (C in '0' .. '9' | 'a' .. 'f' | 'A' .. 'F');

   function Is_Algo (C : Character) return Boolean is
     (C in 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_' | '.' | '-');

   --  Count valid digest tokens at/after Config_At (1-based Doc).
   procedure Scan_Digests (Doc         : in String;
                           N           : in Natural;
                           Config_At   : in Natural;
                           After_Count : out Natural)
     with Pre => Doc'First = 1 and N <= Doc'Length and N <= Max_Doc_Length
                  and Config_At <= N
   is
   begin
      After_Count := 0;
      if N = 0 then
         return;
      end if;
      for I in 1 .. N loop
         pragma Loop_Invariant (After_Count <= I - 1);
         if Doc (I) = ':' and then I > 1 and then I < N then
            declare
               A_First : Natural := I - 1;
               A_Last  : constant Natural := I - 1;
            begin
               while A_First > 1 and then Is_Algo (Doc (A_First - 1)) loop
                  pragma Loop_Variant (Decreases => A_First);
                  pragma Loop_Invariant (A_First >= 1);
                  pragma Loop_Invariant (A_First <= I - 1);
                  A_First := A_First - 1;
               end loop;
               if A_Last - A_First + 1 <= 64 then
                  declare
                     H_Last : Natural := I;
                  begin
                     while H_Last < N and then Is_Hex (Doc (H_Last + 1)) loop
                        pragma Loop_Variant (Increases => H_Last);
                        H_Last := H_Last + 1;
                     end loop;
                     if H_Last - I <= OCI.Reference.Max_Digest_Length - 66 then
                        declare
                           Token : constant String :=
                             Doc (A_First .. A_Last) & ":"
                             & Doc (I + 1 .. H_Last);
                        begin
                           if OCI.Reference.Is_Valid_Digest (Token)
                             and then I >= Config_At
                           then
                              After_Count := After_Count + 1;
                           end if;
                        end;
                     end if;
                  end;
               end if;
            end;
         end if;
      end loop;
   end Scan_Digests;

   procedure Validate (Doc    : in String;
                       Result : out Validation) is
      N           : Natural := 0;
      J           : Natural := 0;
      Work        : String (1 .. Max_Doc_Length) := [others => ' '];
      Config_At   : Natural := 0;
      After_Count : Natural := 0;
   begin
      Result := (others => <>);
      if Doc'Length = 0 or Doc'Length > Max_Doc_Length then
         return;
      end if;

      N := Doc'Length;
      for I in Doc'Range loop
         pragma Loop_Invariant (J = I - Doc'First);
         pragma Loop_Invariant (J < N);
         J := J + 1;
         Work (J) := Doc (I);
      end loop;
      pragma Assert (J = N);

      if Contains (Work, N, """config""") then
         for I in 1 .. N - 7 loop
            pragma Loop_Invariant (Config_At <= I - 1);
            if Work (I .. I + 7) = """config""" then
               Config_At := I;
               exit;
            end if;
         end loop;
      end if;

      Result.Schema_Version_Ok :=
        Contains (Work, N, """schemaVersion"":2")
        or else Contains (Work, N, """schemaVersion"": 2");
      Result.Media_Type_Ok := Contains (Work, N, Manifest_Media_Type);

      if Config_At > 0 then
         pragma Assert (Config_At <= N);
         Scan_Digests (Work, N, Config_At, After_Count);
      end if;
      Result.Config_Ok := After_Count >= 1;
      if After_Count >= 1 then
         Result.Layers_Count := Natural'Min (After_Count - 1, Max_Layers);
      else
         Result.Layers_Count := 0;
      end if;
   end Validate;

end OCI.Image.Manifest;
