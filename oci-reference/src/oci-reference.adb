--  OCI.Reference body (SPARK Silver).
--
--  Proof strategy: Parse normalizes Input into a 1-based work buffer
--  on entry, so every later index is a Plain Positive in 1 .. N with
--  N <= Max_Input. OUT params are fully initialized up front.
--
--  Copyright (c) 2026 RyansOpenSourceRice
--  SPDX-License-Identifier: Apache-2.0

pragma SPARK_Mode (On);

package body OCI.Reference is

   Max_Input : constant := 8_192;

   function Is_Hex (C : Character) return Boolean is
     (C in '0' .. '9' | 'a' .. 'f' | 'A' .. 'F');

   function Is_Algo_Char (C : Character) return Boolean is
     (C in 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_' | '.' | '-' | '+');

   function Is_Name_Char (C : Character) return Boolean is
     (C in 'a' .. 'z' | '0' .. '9' | '_' | '.' | '-' | '/');

   function Is_Tag_Char (C : Character) return Boolean is
     (C in 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_' | '.' | '-');

   function Length (Ref : Reference) return Natural is
     (Ref.Len);

   function Has_Digest (Ref : Reference) return Boolean is
     (Ref.Digest_Len > 0);

   function Is_Valid_Digest (Digest : String) return Boolean is
      Colon : Natural := 0;
   begin
      if Digest'Length < 8 or Digest'Length > Max_Digest_Length then
         return False;
      end if;
      for I in Digest'Range loop
         pragma Loop_Invariant (Colon = 0);
         if Digest (I) = ':' then
            Colon := I;
            exit;
         end if;
      end loop;
      if Colon <= Digest'First or Colon >= Digest'Last then
         return False;
      end if;
      pragma Assert (Colon > Digest'First and Colon < Digest'Last);
      for I in Digest'First .. Colon - 1 loop
         pragma Loop_Invariant (Colon > Digest'First);
         pragma Loop_Invariant (Colon < Digest'Last);
         if not Is_Algo_Char (Digest (I)) then
            return False;
         end if;
      end loop;
      if Digest'Last - Colon < 32 then
         return False;
      end if;
      for I in Colon + 1 .. Digest'Last loop
         pragma Loop_Invariant (Colon < Digest'Last);
         if not Is_Hex (Digest (I)) then
            return False;
         end if;
      end loop;
      return True;
   end Is_Valid_Digest;

   procedure Parse
     (Input  : in String;
      Result : out Reference;
      Valid  : out Boolean)
   is
      N         : Natural := 0;
      J         : Natural := 0;
      Work      : String (1 .. Max_Input) := [others => ' '];
      At_Pos    : Natural := 0;
      Name_Last : Natural := 0;
      Slash     : Natural := 0;
      Colon     : Natural := 0;
   begin
      Result.Value := [others => ' '];
      Result.Digest := [others => ' '];
      Result.Len := 0;
      Result.Digest_Len := 0;
      Valid := False;

      if Input'Length = 0 or Input'Length > Max_Input then
         return;
      end if;
      pragma Assert (Input'Length >= 1);

      --  Normalize to 1-based Work (1 .. N).
      N := Input'Length;
      for I in Input'Range loop
         pragma Loop_Invariant (J = I - Input'First);
         pragma Loop_Invariant (J < N);
         J := J + 1;
         Work (J) := Input (I);
      end loop;
      pragma Assert (J = N);

      Name_Last := N;

      --  Split @digest.
      for I in 1 .. N loop
         pragma Loop_Invariant (At_Pos = 0);
         if Work (I) = '@' then
            At_Pos := I;
            exit;
         end if;
      end loop;

      if At_Pos /= 0 then
         if At_Pos = N then
            return;
         end if;
         pragma Assert (At_Pos < N);
         if N - At_Pos > Max_Digest_Length then
            return;
         end if;
         if not Is_Valid_Digest (Work (At_Pos + 1 .. N)) then
            return;
         end if;
         Result.Digest (1 .. N - At_Pos) := Work (At_Pos + 1 .. N);
         Result.Digest_Len := N - At_Pos;
         Name_Last := At_Pos - 1;
         if Name_Last < 1 then
            Result.Digest_Len := 0;
            return;
         end if;
      end if;

      --  Last '/' in 1 .. Name_Last, then last ':' after it.
      for I in 1 .. Name_Last loop
         pragma Loop_Invariant (Slash <= I - 1);
         if Work (I) = '/' then
            Slash := I;
         end if;
      end loop;
      for I in 1 .. Name_Last loop
         pragma Loop_Invariant (Colon <= I - 1);
         pragma Loop_Invariant (Colon = 0 or Colon > Slash);
         if Work (I) = ':' and then I > Slash then
            Colon := I;
         end if;
      end loop;

      if Colon /= 0 then
         if Colon = Name_Last then
            Result.Digest_Len := 0;
            return;
         end if;
         pragma Assert (Colon < Name_Last);
         if Name_Last - Colon > 128 then
            Result.Digest_Len := 0;
            return;
         end if;
         for I in Colon + 1 .. Name_Last loop
            pragma Loop_Invariant (Colon < Name_Last);
            if not Is_Tag_Char (Work (I)) then
               Result.Digest_Len := 0;
               return;
            end if;
         end loop;
         Name_Last := Colon - 1;
      end if;

      if Name_Last < 1 then
         Result.Digest_Len := 0;
         return;
      end if;

      --  Name allows [a-z0-9._-/] plus one optional :port in the
      --  registry segment (before the first '/'), digits only.
      declare
         Seen_Slash  : Boolean := False;
         Seen_Colon  : Boolean := False;
         Port_Digits : Natural := 0;
      begin
         for I in 1 .. Name_Last loop
            pragma Loop_Invariant (Port_Digits <= I - 1);
            if Work (I) = '/' then
               if Seen_Colon and then Port_Digits = 0 then
                  Result.Digest_Len := 0;
                  return;
               end if;
               Seen_Slash := True;
            elsif Work (I) = ':' then
               if Seen_Slash or Seen_Colon then
                  Result.Digest_Len := 0;
                  return;
               end if;
               Seen_Colon := True;
            elsif Seen_Colon and not Seen_Slash then
               if Work (I) not in '0' .. '9' then
                  Result.Digest_Len := 0;
                  return;
               end if;
               Port_Digits := Port_Digits + 1;
            elsif not Is_Name_Char (Work (I)) then
               Result.Digest_Len := 0;
               return;
            end if;
         end loop;
         if Seen_Colon and then not Seen_Slash and then Port_Digits = 0 then
            Result.Digest_Len := 0;
            return;
         end if;
      end;

      --  Store the full input text (bounded by Max_Length).
      if N > Result.Max_Length then
         Result.Digest_Len := 0;
         return;
      end if;
      Result.Value (1 .. N) := Work (1 .. N);
      Result.Len := N;
      Valid := True;
   end Parse;

   procedure Tag_Or_Default
     (Ref : in Reference;
      Tag : out String;
      Len : out Natural)
   is
      Slash : Natural := 0;
      Colon : Natural := 0;
      Last  : constant Natural := Ref.Len;
      Stop  : Natural := Last;
      Src   : Positive := 1;
   begin
      Tag := [others => ' '];
      Len := 0;
      if Last = 0 then
         return;
      end if;
      pragma Assert (Last >= 1);
      for I in 1 .. Last loop
         pragma Loop_Invariant (Stop = Last);
         if Ref.Value (I) = '@' then
            Stop := I - 1;
            exit;
         end if;
      end loop;
      if Stop = 0 then
         return;
      end if;
      for I in 1 .. Stop loop
         pragma Loop_Invariant (Slash <= I - 1);
         if Ref.Value (I) = '/' then
            Slash := I;
         end if;
      end loop;
      for I in 1 .. Stop loop
         pragma Loop_Invariant (Colon <= I - 1);
         pragma Loop_Invariant (Colon = 0 or Colon > Slash);
         if Ref.Value (I) = ':' and then I > Slash then
            Colon := I;
         end if;
      end loop;
      if Colon /= 0 and then Colon < Stop then
         Len := Natural'Min (Stop - Colon, Tag'Length);
         Src := Colon + 1;
         pragma Assert (Len >= 1);
         pragma Assert (Len <= Tag'Length);
         pragma Assert (Len <= Stop - Colon);
         pragma Assert (Tag'Last - Tag'First = Tag'Length - 1);
         for K in 1 .. Len loop
            pragma Loop_Invariant (K - 1 <= Tag'Last - Tag'First);
            pragma Loop_Invariant (K - 1 <= Stop - Src);
            Tag (Tag'First + (K - 1)) := Ref.Value (Src + (K - 1));
         end loop;
      elsif Default_Tag'Length <= Tag'Length then
         Src := 1;
         Len := Default_Tag'Length;
         pragma Assert (Tag'Last - Tag'First = Tag'Length - 1);
         for K in 1 .. Len loop
            pragma Loop_Invariant (K - 1 <= Tag'Last - Tag'First);
            Tag (Tag'First + (K - 1)) := Default_Tag (K);
         end loop;
      end if;
   end Tag_Or_Default;

end OCI.Reference;
