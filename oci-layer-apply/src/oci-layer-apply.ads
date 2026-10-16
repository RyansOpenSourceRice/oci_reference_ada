--  OCI.Layer.Apply — layer apply-order and whiteout helpers.
--
--  Layers apply base-first: Apply_Order (Count) yields 1 .. Count.
--  Whiteout detection follows the OCI image spec: a file whose
--  basename starts with ".wh." removes the corresponding path, and
--  ".wh..wh..opq" marks a directory opaque.
--
--  Chain_Append tracks the ordered diff digest list; the hashed
--  ChainID (sha256 over the chain) arrives with the future SHA-256
--  crate — see SPECIFICATION.md §ChainID-note.
--
--  Copyright (c) 2026 RyansOpenSourceRice
--  SPDX-License-Identifier: Apache-2.0

pragma SPARK_Mode (On);

with OCI.Reference;

package OCI.Layer.Apply is

   Max_Layers : constant := 128;

   --  Fail-closed path bound (Linux PATH_MAX): longer paths are never
   --  whiteouts and never opaque.
   Max_Path_Length : constant := 4_096;

   type Order_Array is array (1 .. Max_Layers) of Natural;

   --  Base-first application order for Count layers.
   procedure Apply_Order (Count : in Natural;
                          Order : out Order_Array)
     with Pre  => Count <= Max_Layers,
          Post => (for all I in 1 .. Count => Order (I) = I);

   --  True when Path's basename starts with ".wh.".
   function Is_Whiteout (Path : String) return Boolean;

   --  True when Path's basename is exactly ".wh..wh..opq".
   function Opaque_Dir (Path : String) return Boolean;

   Max_Chain_Length : constant := 8192;

   type Chain (Len : Natural := 0) is record
      Value : String (1 .. Max_Chain_Length) := [others => ' '];
   end record
   with Dynamic_Predicate => Len <= Max_Chain_Length;

   function Empty_Chain return Chain is ((Len => 0, Value => [others => ' ']));

   --  Append a validated diff digest to the chain descriptor.
   function Chain_Append (Parent : Chain;
                          Diff   : String) return Chain
     with Pre => OCI.Reference.Is_Valid_Digest (Diff)
                 and then Parent.Len + Diff'Length + 1 <= Max_Chain_Length;

   function To_String (C : Chain) return String is
     (C.Value (1 .. C.Len));

end OCI.Layer.Apply;
