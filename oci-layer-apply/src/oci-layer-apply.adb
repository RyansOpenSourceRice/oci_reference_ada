--  OCI.Layer.Apply body.
--
--  Proof strategy: whiteout queries normalize Path into a 1-based
--  buffer (paths longer than Max_Path_Length are fail-closed to
--  False), so all later indices are Plain Positive in 1 .. N.
--
--  Copyright (c) 2026 RyansOpenSourceRice
--  SPDX-License-Identifier: Apache-2.0

pragma SPARK_Mode (On);

package body OCI.Layer.Apply is

   Whiteout_Prefix : constant String := ".wh.";
   Opaque_Name     : constant String := ".wh..wh..opq";

   --  Copy of Path in 1 .. N; N = 0 when Path is empty or oversize
   --  (oversize paths are fail-closed: never whiteouts).
   procedure To_Buffer (Path : in String;
                        Work : in out String;
                        N    : out Natural)
     with Pre  => Work'First = 1 and Work'Length >= Max_Path_Length,
          Post => N <= Max_Path_Length
                  and N = (if Path'Length in 1 .. Max_Path_Length
                           then Path'Length else 0)
   is
      J : Natural := 0;
   begin
      N := 0;
      if Path'Length = 0 or Path'Length > Max_Path_Length then
         return;
      end if;
      for I in Path'Range loop
         pragma Loop_Invariant (J = I - Path'First);
         pragma Loop_Invariant (J < Path'Length);
         J := J + 1;
         Work (J) := Path (I);
      end loop;
      N := J;
   end To_Buffer;

   --  Start index of the basename (after the last '/'), 1-based Work.
   function Base_Start (Work : String; N : Natural) return Positive
     with Pre => Work'First = 1 and N <= Work'Length
                 and N <= Max_Path_Length
   is
      Start : Positive := 1;
   begin
      for I in 1 .. N loop
         pragma Loop_Invariant (Start <= I);
         if Work (I) = '/' then
            Start := I + 1;
         end if;
      end loop;
      return Start;
   end Base_Start;

   procedure Apply_Order (Count : in Natural;
                          Order : out Order_Array) is
   begin
      Order := [others => 0];
      for I in 1 .. Count loop
         pragma Loop_Invariant (for all J in 1 .. I - 1 => Order (J) = J);
         Order (I) := I;
      end loop;
      pragma Assert (for all J in 1 .. Count => Order (J) = J);
   end Apply_Order;

   function Is_Whiteout (Path : String) return Boolean is
      Work  : String (1 .. Max_Path_Length) := [others => ' '];
      N     : Natural := 0;
      Start : Positive := 1;
   begin
      To_Buffer (Path, Work, N);
      if N = 0 then
         return False;
      end if;
      Start := Base_Start (Work, N);
      if Start > N then
         return False;
      end if;
      pragma Assert (Start >= 1 and Start <= N);
      if N - Start + 1 < Whiteout_Prefix'Length then
         return False;
      end if;
      return Work (Start .. Start + Whiteout_Prefix'Length - 1)
        = Whiteout_Prefix;
   end Is_Whiteout;

   function Opaque_Dir (Path : String) return Boolean is
      Work  : String (1 .. Max_Path_Length) := [others => ' '];
      N     : Natural := 0;
      Start : Positive := 1;
   begin
      To_Buffer (Path, Work, N);
      if N = 0 then
         return False;
      end if;
      Start := Base_Start (Work, N);
      if Start > N then
         return False;
      end if;
      pragma Assert (Start >= 1 and Start <= N);
      if N - Start + 1 /= Opaque_Name'Length then
         return False;
      end if;
      return Work (Start .. N) = Opaque_Name;
   end Opaque_Dir;

   function Chain_Append (Parent : Chain;
                          Diff   : String) return Chain is
      Gap    : constant Natural := (if Parent.Len > 0 then 1 else 0);
      Result : Chain (Parent.Len + Gap + Diff'Length);
   begin
      pragma Assert (Diff'Last - Diff'First = Diff'Length - 1);
      Result.Value (1 .. Parent.Len) := Parent.Value (1 .. Parent.Len);
      if Parent.Len > 0 then
         Result.Value (Parent.Len + 1) := ' ';
         pragma Assert (Parent.Len + 1 + Diff'Length <= Max_Chain_Length);
         for K in 1 .. Diff'Length loop
            pragma Loop_Invariant (K <= Max_Chain_Length - (Parent.Len + 1));
            pragma Loop_Invariant (K - 1 <= Diff'Last - Diff'First);
            Result.Value (Parent.Len + 1 + K) := Diff (Diff'First + (K - 1));
         end loop;
      else
         pragma Assert (Diff'Length <= Max_Chain_Length);
         for K in 1 .. Diff'Length loop
            pragma Loop_Invariant (K - 1 <= Max_Chain_Length - 1);
            pragma Loop_Invariant (K - 1 <= Diff'Last - Diff'First);
            Result.Value (K) := Diff (Diff'First + (K - 1));
         end loop;
      end if;
      return Result;
   end Chain_Append;

end OCI.Layer.Apply;
