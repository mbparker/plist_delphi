unit UnitCode_LibPListApi;

interface

uses
  Winapi.Windows, System.Classes, UnitCode_CustomDynamicLibrary;

const
  PLIST_TYPE_BOOLEAN = 0;
  PLIST_TYPE_UNSIGNED_INTEGER = 1;
  PLIST_TYPE_REAL = 2;
  PLIST_TYPE_STRING = 3;
  PLIST_TYPE_ARRAY = 4;
  PLIST_TYPE_DICTIONARY = 5;
  PLIST_TYPE_DATE = 6;
  PLIST_TYPE_DATA = 7;
  PLIST_TYPE_KEY = 8;
  PLIST_TYPE_UNIQUE_IDENTIFIER = 9;
  PLIST_TYPE_NONE = 10;

type
  uint8_t = Byte;
  int32_t = Int32;
  uint32_t = UInt32;
  uint64_t = UInt64;
  plist_t = Pointer;
  pplist_t = ^plist_t;
  plist_dict_iter_t = Pointer;

  plist_new_dict_t = function (): plist_t; cdecl;
  plist_new_array_t = function (): plist_t; cdecl;
  plist_new_string_t = function (const value: PAnsiChar): plist_t; cdecl;
  plist_new_bool_t = function (value: uint8_t): plist_t; cdecl;
  plist_new_uint_t = function (value: uint64_t): plist_t; cdecl;
  plist_new_real_t = function (const value: double): plist_t; cdecl;
  plist_new_data_t = function (const value: Pointer; length: uint64_t): plist_t; cdecl;
  plist_new_date_t = function (valuesec: int32_t; valueusec: int32_t): plist_t; cdecl;
  plist_new_uid_t = function (value: uint64): plist_t; cdecl;
  plist_copy_t = function (node: plist_t): plist_t; cdecl;
  plist_free_t = procedure (item: plist_t); cdecl;

  plist_get_node_type_t = function (node: plist_t): uint32_t; cdecl;
  plist_get_parent_t = function (node: plist_t): plist_t; cdecl;
  plist_get_string_val_t = procedure (node: plist_t; var value: PAnsiChar); cdecl;
  plist_get_key_val_t = procedure (node: plist_t; var value: PAnsiChar); cdecl;
  plist_get_bool_val_t = procedure (node: plist_t; var value: uint8_t); cdecl;
  plist_get_uint_val_t = procedure (node: plist_t; var value: uint64_t); cdecl;
  plist_get_uid_val_t = procedure (node: plist_t; var value: uint64_t); cdecl;
  plist_get_real_val_t = procedure (node: plist_t; var value: double); cdecl;
  plist_get_data_val_t = procedure (node: plist_t; var data: pointer; var length: uint64_t); cdecl;
  plist_get_date_val_t = procedure (node: plist_t; var valuesec: int32_t; var valueusec: int32_t); cdecl;

  plist_set_key_val_t = procedure (node: plist_t; const value: PAnsiChar); cdecl;
  plist_set_string_val_t = procedure (node: plist_t; const value: PAnsiChar); cdecl;
  plist_set_bool_val_t = procedure (node: plist_t; value: uint8_t); cdecl;
  plist_set_uint_val_t = procedure (node: plist_t; value: uint64_t); cdecl;
  plist_set_real_val_t = procedure (node: plist_t; const value: double); cdecl;
  plist_set_data_val_t = procedure (node: plist_t; const data: Pointer; length: uint64_t); cdecl;
  plist_set_date_val_t = procedure (node: plist_t; valuesec: int32_t; valueusec: int32_t); cdecl;
  plist_set_uid_val_t = procedure (node: plist_t; value: uint64_t); cdecl;

  plist_array_get_size_t = function (node: plist_t): uint32_t; cdecl;
  plist_array_get_item_t = function (node: plist_t; index: uint32_t): plist_t; cdecl;
  plist_array_get_item_index_t = function (node: plist_t): uint32_t; cdecl;
  plist_array_set_item_t = procedure (node: plist_t; item: plist_t; index: uint32_t); cdecl;
  plist_array_append_item_t = procedure (node: plist_t; item: plist_t); cdecl;
  plist_array_insert_item_t = procedure (node: plist_t; item: plist_t; index: uint32_t); cdecl;
  plist_array_remove_item_t = procedure (node: plist_t; index: uint32_t); cdecl;

  plist_dict_get_size_t = function (node: plist_t): uint32_t; cdecl;
  plist_dict_get_item_t = function (node: plist_t; const key: PAnsiChar): plist_t; cdecl;
  plist_dict_new_iter_t = procedure (node: plist_t; var iter: plist_dict_iter_t); cdecl;
  plist_dict_next_item_t = procedure (node: plist_t; iter: plist_dict_iter_t; var key: PAnsiChar; var value: plist_t); cdecl;
  plist_dict_get_item_key_t = procedure (node: plist_t; var key: PAnsiChar); cdecl;
  plist_dict_set_item_t = procedure (node: plist_t; const key: PAnsiChar; item: plist_t); cdecl;
  plist_dict_insert_item_t = procedure (node: plist_t; const key: PAnsiChar; item: plist_t); cdecl;
  plist_dict_remove_item_t = procedure (node: plist_t; const key: PAnsiChar); cdecl;
  plist_dict_merge_t = procedure (target: pplist_t; source: plist_t); cdecl;

  plist_to_xml_t = procedure (node: plist_t; var plist_xml: PAnsiChar; var length: uint32_t); cdecl;
  plist_from_xml_t = procedure (const plist_xml: PAnsiChar; length: uint32_t; var plist: plist_t); cdecl;

  plist_to_bin_t = procedure (plist: plist_t; var plist_bin: Pointer; var length: uint32_t); cdecl;
  plist_from_bin_t = procedure (const plist_bin: Pointer; length: uint32_t; var plist: plist_t); cdecl;

  TLibPListApi = class(TCustomDynamicLibrary)
  strict private
    fplist_new_dict_t: plist_new_dict_t;
    fplist_new_array_t: plist_new_array_t;
    fplist_new_string_t: plist_new_string_t;
    fplist_new_bool_t: plist_new_bool_t;
    fplist_new_uint_t: plist_new_uint_t;
    fplist_new_real_t: plist_new_real_t;
    fplist_new_data_t: plist_new_data_t;
    fplist_new_date_t: plist_new_date_t;
    fplist_new_uid_t: plist_new_uid_t;
    fplist_copy_t: plist_copy_t;
    fplist_free_t: plist_free_t;

    fplist_get_node_type_t: plist_get_node_type_t;
    fplist_get_parent_t: plist_get_parent_t;
    fplist_get_string_val_t: plist_get_string_val_t;
    fplist_get_key_val_t: plist_get_key_val_t;
    fplist_get_bool_val_t: plist_get_bool_val_t;
    fplist_get_uint_val_t: plist_get_uint_val_t;
    fplist_get_uid_val_t: plist_get_uid_val_t;
    fplist_get_real_val_t: plist_get_real_val_t;
    fplist_get_data_val_t: plist_get_data_val_t;
    fplist_get_date_val_t: plist_get_date_val_t;

    fplist_set_key_val_t: plist_set_key_val_t;
    fplist_set_string_val_t: plist_set_string_val_t;
    fplist_set_bool_val_t: plist_set_bool_val_t;
    fplist_set_uint_val_t: plist_set_uint_val_t;
    fplist_set_real_val_t: plist_set_real_val_t;
    fplist_set_data_val_t: plist_set_data_val_t;
    fplist_set_date_val_t: plist_set_date_val_t;
    fplist_set_uid_val_t: plist_set_uid_val_t;

    fplist_array_get_size_t: plist_array_get_size_t;
    fplist_array_get_item_t: plist_array_get_item_t;
    fplist_array_get_item_index_t: plist_array_get_item_index_t;
    fplist_array_set_item_t: plist_array_set_item_t;
    fplist_array_append_item_t: plist_array_append_item_t;
    fplist_array_insert_item_t: plist_array_insert_item_t;
    fplist_array_remove_item_t: plist_array_remove_item_t;

    fplist_dict_get_size_t: plist_dict_get_size_t;
    fplist_dict_get_item_t: plist_dict_get_item_t;
    fplist_dict_new_iter_t: plist_dict_new_iter_t;
    fplist_dict_next_item_t: plist_dict_next_item_t;
    fplist_dict_get_item_key_t: plist_dict_get_item_key_t;
    fplist_dict_set_item_t: plist_dict_set_item_t;
    fplist_dict_insert_item_t: plist_dict_insert_item_t;
    fplist_dict_remove_item_t: plist_dict_remove_item_t;
    fplist_dict_merge_t: plist_dict_merge_t;

    fplist_to_xml_t: plist_to_xml_t;
    fplist_from_xml_t: plist_from_xml_t;
    fplist_to_bin_t: plist_to_bin_t;
    fplist_from_bin_t: plist_from_bin_t;
  strict protected
    procedure MapRoutines; override;
  public
    function plist_new_dict(): plist_t;
    function plist_new_array(): plist_t;
    function plist_new_string(const value: PAnsiChar): plist_t;
    function plist_new_bool(value: uint8_t): plist_t;
    function plist_new_uint(value: uint64_t): plist_t;
    function plist_new_real(const value: double): plist_t;
    function plist_new_data(const value: Pointer; length: uint64_t): plist_t;
    function plist_new_date(valuesec: int32_t; valueusec: int32_t): plist_t;
    function plist_new_uid(value: uint64): plist_t;
    function plist_copy(node: plist_t): plist_t;
    procedure plist_free(item: plist_t);

    function plist_get_node_type(node: plist_t): uint32_t;
    function plist_get_parent(node: plist_t): plist_t;
    procedure plist_get_string_val(node: plist_t; var value: PAnsiChar);
    procedure plist_get_key_val(node: plist_t; var value: PAnsiChar);
    procedure plist_get_bool_val(node: plist_t; var value: uint8_t);
    procedure plist_get_uint_val(node: plist_t; var value: uint64_t);
    procedure plist_get_uid_val(node: plist_t; var value: uint64_t);
    procedure plist_get_real_val(node: plist_t; var value: double);
    procedure plist_get_data_val(node: plist_t; var data: pointer; var length: uint64_t);
    procedure plist_get_date_val(node: plist_t; var valuesec, valueusec: int32_t);

    procedure plist_set_key_val(node: plist_t; const value: PAnsiChar);
    procedure plist_set_string_val(node: plist_t; const value: PAnsiChar);
    procedure plist_set_bool_val(node: plist_t; value: uint8_t);
    procedure plist_set_uint_val(node: plist_t; value: uint64_t);
    procedure plist_set_real_val(node: plist_t; const value: double);
    procedure plist_set_data_val(node: plist_t; const data: Pointer; length: uint64_t);
    procedure plist_set_date_val(node: plist_t; valuesec: int32_t; valueusec: int32_t);
    procedure plist_set_uid_val(node: plist_t; value: uint64_t);

    function plist_array_get_size(node: plist_t): uint32_t;
    function plist_array_get_item(node: plist_t; index: uint32_t): plist_t;
    function plist_array_get_item_index(node: plist_t): uint32_t;
    procedure plist_array_set_item(node: plist_t; item: plist_t; index: uint32_t);
    procedure plist_array_append_item(node: plist_t; item: plist_t);
    procedure plist_array_insert_item(node: plist_t; item: plist_t; index: uint32_t);
    procedure plist_array_remove_item(node: plist_t; index: uint32_t);

    function plist_dict_get_size(node: plist_t): uint32_t;
    function plist_dict_get_item(node: plist_t; const key: PAnsiChar): plist_t;
    procedure plist_dict_new_iter(node: plist_t; var iter: plist_dict_iter_t);
    procedure plist_dict_next_item(node: plist_t; iter: plist_dict_iter_t; var key: PAnsiChar; var value: plist_t);
    procedure plist_dict_get_item_key(node: plist_t; var key: PAnsiChar);
    procedure plist_dict_set_item(node: plist_t; const key: PAnsiChar; item: plist_t);
    procedure plist_dict_insert_item(node: plist_t; const key: PAnsiChar; item: plist_t);
    procedure plist_dict_remove_item(node: plist_t; const key: PAnsiChar);
    procedure plist_dict_merge(target: pplist_t; source: plist_t);

    procedure plist_to_xml(node: plist_t; var plist_xml: PAnsiChar; var length: uint32_t);
    procedure plist_from_xml(const plist_xml: PAnsiChar; length: uint32_t; var plist: plist_t);
    procedure plist_to_bin(plist: plist_t; var plist_bin: Pointer; var length: uint32_t);
    procedure plist_from_bin(const plist_bin: Pointer; length: uint32_t; var plist: plist_t);
  end;

implementation

{ TLibPListApi }

procedure TLibPListApi.MapRoutines;
begin
  MapRoutine('plist_new_dict', @@fplist_new_dict_t);
  MapRoutine('plist_new_array', @@fplist_new_array_t);
  MapRoutine('plist_new_string', @@fplist_new_string_t);
  MapRoutine('plist_new_bool', @@fplist_new_bool_t);
  MapRoutine('plist_new_uint', @@fplist_new_uint_t);
  MapRoutine('plist_new_real', @@fplist_new_real_t);
  MapRoutine('plist_new_data', @@fplist_new_data_t);
  MapRoutine('plist_new_date', @@fplist_new_date_t);
  MapRoutine('plist_new_uid', @@fplist_new_uid_t);
  MapRoutine('plist_copy', @@fplist_copy_t);
  MapRoutine('plist_free', @@fplist_free_t);

  MapRoutine('plist_get_node_type', @@fplist_get_node_type_t);
  MapRoutine('plist_get_parent', @@fplist_get_parent_t);
  MapRoutine('plist_get_string_val', @@fplist_get_string_val_t);
  MapRoutine('plist_get_key_val', @@fplist_get_key_val_t);
  MapRoutine('plist_get_bool_val', @@fplist_get_bool_val_t);
  MapRoutine('plist_get_uint_val', @@fplist_get_uint_val_t);
  MapRoutine('plist_get_uid_val', @@fplist_get_uid_val_t);
  MapRoutine('plist_get_real_val', @@fplist_get_real_val_t);
  MapRoutine('plist_get_data_val', @@fplist_get_data_val_t);
  MapRoutine('plist_get_date_val', @@fplist_get_date_val_t);

  MapRoutine('plist_set_key_val', @@fplist_set_key_val_t);
  MapRoutine('plist_set_string_val', @@fplist_set_string_val_t);
  MapRoutine('plist_set_bool_val', @@fplist_set_bool_val_t);
  MapRoutine('plist_set_uint_val', @@fplist_set_uint_val_t);
  MapRoutine('plist_set_real_val', @@fplist_set_real_val_t);
  MapRoutine('plist_set_data_val', @@fplist_set_data_val_t);
  MapRoutine('plist_set_date_val', @@fplist_set_date_val_t);
  MapRoutine('plist_set_uid_val', @@fplist_set_uid_val_t);

  MapRoutine('plist_array_get_size', @@fplist_array_get_size_t);
  MapRoutine('plist_array_get_item', @@fplist_array_get_item_t);
  MapRoutine('plist_array_get_item_index', @@fplist_array_get_item_index_t);
  MapRoutine('plist_array_set_item', @@fplist_array_set_item_t);
  MapRoutine('plist_array_append_item', @@fplist_array_append_item_t);
  MapRoutine('plist_array_insert_item', @@fplist_array_insert_item_t);
  MapRoutine('plist_array_remove_item', @@fplist_array_remove_item_t);

  MapRoutine('plist_dict_get_size', @@fplist_dict_get_size_t);
  MapRoutine('plist_dict_get_item', @@fplist_dict_get_item_t);
  MapRoutine('plist_dict_new_iter', @@fplist_dict_new_iter_t);
  MapRoutine('plist_dict_next_item', @@fplist_dict_next_item_t);
  MapRoutine('plist_dict_get_item_key', @@fplist_dict_get_item_key_t);
  MapRoutine('plist_dict_set_item', @@fplist_dict_set_item_t);
  MapRoutine('plist_dict_insert_item', @@fplist_dict_insert_item_t);
  MapRoutine('plist_dict_remove_item', @@fplist_dict_remove_item_t);
  MapRoutine('plist_dict_merge', @@fplist_dict_merge_t);

  MapRoutine('plist_to_xml', @@fplist_to_xml_t);
  MapRoutine('plist_from_xml', @@fplist_from_xml_t);
  MapRoutine('plist_to_bin', @@fplist_to_bin_t);
  MapRoutine('plist_from_bin', @@fplist_from_bin_t);
end;

procedure TLibPListApi.plist_array_append_item(node, item: plist_t);
begin
  LibraryNeeded;
  fplist_array_append_item_t(node, item);
end;

function TLibPListApi.plist_array_get_item(node: plist_t;
  index: uint32_t): plist_t;
begin
  LibraryNeeded;
  Result := fplist_array_get_item_t(node, index);
end;

function TLibPListApi.plist_array_get_item_index(node: plist_t): uint32_t;
begin
  LibraryNeeded;
  Result := fplist_array_get_item_index_t(node);
end;

function TLibPListApi.plist_array_get_size(node: plist_t): uint32_t;
begin
  LibraryNeeded;
  Result := fplist_array_get_size_t(node);
end;

procedure TLibPListApi.plist_array_insert_item(node, item: plist_t;
  index: uint32_t);
begin
  LibraryNeeded;
  fplist_array_insert_item_t(node, item, index);
end;

procedure TLibPListApi.plist_array_remove_item(node: plist_t; index: uint32_t);
begin
  LibraryNeeded;
  fplist_array_remove_item_t(node, index);
end;

procedure TLibPListApi.plist_array_set_item(node, item: plist_t;
  index: uint32_t);
begin
  LibraryNeeded;
  fplist_array_set_item_t(node, item, index);
end;

function TLibPListApi.plist_copy(node: plist_t): plist_t;
begin
  LibraryNeeded;
  Result := fplist_copy_t(node);
end;

function TLibPListApi.plist_dict_get_item(node: plist_t;
  const key: PAnsiChar): plist_t;
begin
  LibraryNeeded;
  Result := fplist_dict_get_item_t(node, key);
end;

procedure TLibPListApi.plist_dict_get_item_key(node: plist_t;
  var key: PAnsiChar);
begin
  LibraryNeeded;
  fplist_dict_get_item_key_t(node, key);
end;

function TLibPListApi.plist_dict_get_size(node: plist_t): uint32_t;
begin
  LibraryNeeded;
  Result := fplist_dict_get_size_t(node);
end;

procedure TLibPListApi.plist_dict_insert_item(node: plist_t;
  const key: PAnsiChar; item: plist_t);
begin
  LibraryNeeded;
  fplist_dict_insert_item_t(node, key, item);
end;

procedure TLibPListApi.plist_dict_merge(target: pplist_t; source: plist_t);
begin
  LibraryNeeded;
  fplist_dict_merge_t(target, source);
end;

procedure TLibPListApi.plist_dict_new_iter(node: plist_t;
  var iter: plist_dict_iter_t);
begin
  LibraryNeeded;
  fplist_dict_new_iter_t(node, iter);
end;

procedure TLibPListApi.plist_dict_next_item(node: plist_t;
  iter: plist_dict_iter_t; var key: PAnsiChar; var value: plist_t);
begin
  LibraryNeeded;
  fplist_dict_next_item_t(node, iter, key, value);
end;

procedure TLibPListApi.plist_dict_remove_item(node: plist_t;
  const key: PAnsiChar);
begin
  LibraryNeeded;
  fplist_dict_remove_item_t(node, key);
end;

procedure TLibPListApi.plist_dict_set_item(node: plist_t; const key: PAnsiChar;
  item: plist_t);
begin
  LibraryNeeded;
  fplist_dict_set_item_t(node, key, item);
end;

procedure TLibPListApi.plist_free(item: plist_t);
begin
  LibraryNeeded;
  fplist_free_t(item);
end;

procedure TLibPListApi.plist_from_bin(const plist_bin: Pointer; length: uint32_t;
  var plist: plist_t);
begin
  LibraryNeeded;
  fplist_from_bin_t(plist_bin, length, plist);
end;

procedure TLibPListApi.plist_from_xml(const plist_xml: PAnsiChar;
  length: uint32_t; var plist: plist_t);
begin
  LibraryNeeded;
  fplist_from_xml_t(plist_xml, length, plist);
end;

procedure TLibPListApi.plist_get_bool_val(node: plist_t; var value: uint8_t);
begin
  LibraryNeeded;
  fplist_get_bool_val_t(node, value);
end;

procedure TLibPListApi.plist_get_data_val(node: plist_t; var data: pointer; var length: uint64_t);
begin
  LibraryNeeded;
  fplist_get_data_val_t(node, data, length);
end;

procedure TLibPListApi.plist_get_date_val(node: plist_t; var valuesec, valueusec: int32_t);
begin
  LibraryNeeded;
  fplist_get_date_val_t(node, valuesec, valueusec);
end;

procedure TLibPListApi.plist_get_key_val(node: plist_t; var value: PAnsiChar);
begin
  LibraryNeeded;
  fplist_get_key_val_t(node, value);
end;

function TLibPListApi.plist_get_node_type(node: plist_t): uint32_t;
begin
  LibraryNeeded;
  Result := fplist_get_node_type_t(node);
end;

function TLibPListApi.plist_get_parent(node: plist_t): plist_t;
begin
  LibraryNeeded;
  Result := fplist_get_parent_t(node);
end;

procedure TLibPListApi.plist_get_real_val(node: plist_t; var value: double);
begin
  LibraryNeeded;
  fplist_get_real_val_t(node, value);
end;

procedure TLibPListApi.plist_get_string_val(node: plist_t;
  var value: PAnsiChar);
begin
  LibraryNeeded;
  fplist_get_string_val_t(node, value);
end;

procedure TLibPListApi.plist_get_uid_val(node: plist_t; var value: uint64_t);
begin
  LibraryNeeded;
  fplist_get_uid_val_t(node, value);
end;

procedure TLibPListApi.plist_get_uint_val(node: plist_t; var value: uint64_t);
begin
  LibraryNeeded;
  fplist_get_uint_val_t(node, value);
end;

function TLibPListApi.plist_new_array: plist_t;
begin
  LibraryNeeded;
  Result := fplist_new_array_t();
end;

function TLibPListApi.plist_new_bool(value: uint8_t): plist_t;
begin
  LibraryNeeded;
  Result := fplist_new_bool_t(value);
end;

function TLibPListApi.plist_new_data(const value: Pointer;
  length: uint64_t): plist_t;
begin
  LibraryNeeded;
  Result := fplist_new_data_t(value, length);
end;

function TLibPListApi.plist_new_date(valuesec, valueusec: int32_t): plist_t;
begin
  LibraryNeeded;
  Result := fplist_new_date_t(valuesec, valueusec);
end;

function TLibPListApi.plist_new_dict: plist_t;
begin
  LibraryNeeded;
  Result := fplist_new_dict_t();
end;

function TLibPListApi.plist_new_real(const value: double): plist_t;
begin
  LibraryNeeded;
  Result := fplist_new_real_t(value);
end;

function TLibPListApi.plist_new_string(const value: PAnsiChar): plist_t;
begin
  LibraryNeeded;
  Result := fplist_new_string_t(value);
end;

function TLibPListApi.plist_new_uid(value: uint64): plist_t;
begin
  LibraryNeeded;
  Result := fplist_new_uid_t(value);
end;

function TLibPListApi.plist_new_uint(value: uint64_t): plist_t;
begin
  LibraryNeeded;
  Result := fplist_new_uint_t(value);
end;

procedure TLibPListApi.plist_set_bool_val(node: plist_t; value: uint8_t);
begin
  LibraryNeeded;
  fplist_set_bool_val_t(node, value);
end;

procedure TLibPListApi.plist_set_data_val(node: plist_t; const data: Pointer;
  length: uint64_t);
begin
  LibraryNeeded;
  fplist_set_data_val_t(node, data, length);
end;

procedure TLibPListApi.plist_set_date_val(node: plist_t; valuesec,
  valueusec: int32_t);
begin
  LibraryNeeded;
  fplist_set_date_val_t(node, valuesec, valueusec);
end;

procedure TLibPListApi.plist_set_key_val(node: plist_t; const value: PAnsiChar);
begin
  LibraryNeeded;
  fplist_set_key_val_t(node, value);
end;

procedure TLibPListApi.plist_set_real_val(node: plist_t; const value: double);
begin
  LibraryNeeded;
  fplist_set_real_val_t(node, value);
end;

procedure TLibPListApi.plist_set_string_val(node: plist_t;
  const value: PAnsiChar);
begin
  LibraryNeeded;
  fplist_set_string_val_t(node, value);
end;

procedure TLibPListApi.plist_set_uid_val(node: plist_t; value: uint64_t);
begin
  LibraryNeeded;
  fplist_set_uid_val_t(node, value);
end;

procedure TLibPListApi.plist_set_uint_val(node: plist_t; value: uint64_t);
begin
  LibraryNeeded;
  fplist_set_uint_val_t(node, value);
end;

procedure TLibPListApi.plist_to_bin(plist: plist_t; var plist_bin: Pointer;
  var length: uint32_t);
begin
  LibraryNeeded;
  fplist_to_bin_t(plist, plist_bin, length);
end;

procedure TLibPListApi.plist_to_xml(node: plist_t; var plist_xml: PAnsiChar;
  var length: uint32_t);
begin
  LibraryNeeded;
  fplist_to_xml_t(node, plist_xml, length);
end;

end.
