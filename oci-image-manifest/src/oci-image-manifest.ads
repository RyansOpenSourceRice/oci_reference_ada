--  OCI.Image.Manifest — structural validation of OCI image manifests.
--
--  Works on the raw manifest document (JSON text) without a JSON
--  dependency: checks schemaVersion, mediaType, config descriptor,
--  and layer descriptors by substring structure + digest validation.
--
--  Copyright (c) 2026 RyansOpenSourceRice
--  SPDX-License-Identifier: Apache-2.0

pragma SPARK_Mode (On);

package OCI.Image.Manifest is

   Manifest_Media_Type : constant String :=
     "application/vnd.oci.image.manifest.v1+json";

   Config_Media_Type : constant String :=
     "application/vnd.oci.image.config.v1+json";

   Max_Layers : constant := 128;

   --  Fail-closed document bound (DoS resistance): larger docs are
   --  invalid. Sized so the work buffer stays stack-allocatable.
   Max_Doc_Length : constant := 65_536;

   type Validation is record
      Schema_Version_Ok : Boolean := False;
      Media_Type_Ok     : Boolean := False;
      Config_Ok         : Boolean := False;
      Layers_Count      : Natural := 0;
   end record;

   function Valid (V : Validation) return Boolean is
     (V.Schema_Version_Ok and V.Media_Type_Ok
      and V.Config_Ok and V.Layers_Count > 0);

   --  Validate a manifest document. Passes iff schemaVersion is 2,
   --  mediaType is the manifest media type, the "config" section holds
   --  a valid digest, and at least one layer descriptor digest exists.
   procedure Validate (Doc    : in String;
                       Result : out Validation)
     with Pre => Doc'Length <= Max_Doc_Length;

end OCI.Image.Manifest;
