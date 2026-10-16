--  ex1_order — print the apply order for N layers.
--
--  Copyright (c) 2026 RyansOpenSourceRice
--  SPDX-License-Identifier: Apache-2.0

with Ada.Text_IO; use Ada.Text_IO;
with OCI.Layer.Apply; use OCI.Layer.Apply;

procedure Ex1_Order is
   O : Order_Array;
begin
   Apply_Order (3, O);
   for I in 1 .. 3 loop
      Put_Line ("apply layer" & O (I)'Image);
   end loop;
end Ex1_Order;
