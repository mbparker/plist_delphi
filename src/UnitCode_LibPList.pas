unit UnitCode_LibPList;

interface

uses
  System.Rtti, System.Generics.Collections, System.Classes, System.SysUtils,
  System.Generics.Defaults, UnitCode_LibPListApi;


type
  TPropertyListNodeType = (plntBoolean, plntUnsignedInteger, plntReal,
    plntString, plntArray, plntDictionary, plntDate, plntData, plntKey,
    plntUniqueIdentifier, plntNone);

  TStringEqualityComparerCaseInsensitive = class(TEqualityComparer<string>)
  public
    function Equals(const ALeft, ARight: string): Boolean; override;
    function GetHashCode(const AValue: string): Integer; override;
  end;

  TPropertyListNode = class;
  TPropertyListPersist = class;

  TPropertyListArray = class(TEnumerable<TPropertyListNode>)
  strict private
    fArray: TObjectList<TPropertyListNode>;
    fParentNode: TPropertyListNode;
    fPersist: TPropertyListPersist;
    function GetCount: integer;
    function GetItem(AIndex: integer): TPropertyListNode;
  protected
    function DoGetEnumerator: TEnumerator<TPropertyListNode>; override;
  public
    constructor Create(AParentNode: TPropertyListNode; const APersist: TPropertyListPersist);
    destructor Destroy; override;
    function Add(ANode: TPropertyListNode): TPropertyListNode;
    function AddArray: TPropertyListNode;
    function AddBoolean(AValue: boolean): TPropertyListNode;
    function AddData: TPropertyListNode;
    function AddDate(const AValue: TDateTime): TPropertyListNode;
    function AddDictionary: TPropertyListNode;
    function AddReal(const AValue: double): TPropertyListNode;
    function AddString(const AValue: string): TPropertyListNode;
    function AddUniqueIdentifier(const AValue: UInt64): TPropertyListNode;
    function AddUnsignedInteger(const AValue: UInt64): TPropertyListNode;
    procedure Clear;
    procedure RemoveAt(AIndex: integer); overload;
    procedure Remove(AValue: TPropertyListNode); overload;
    function ImportNative(ANativeNode: plist_t): TPropertyListNode;
    property Count: Integer read GetCount;
    property Items[AIndex: integer]: TPropertyListNode read GetItem; default;
  end;

  TEnumerablePropertyListNodeDictionary = TEnumerable<TPair<string, TPropertyListNode>>;
  TPropertyListNodeEnumerator = TEnumerator<TPair<string, TPropertyListNode>>;

  TPropertyListDictionary = class(TEnumerablePropertyListNodeDictionary)
  strict private
    fDictionary: TDictionary<string, TPropertyListNode>;
    fParentNode: TPropertyListNode;
    fPersist: TPropertyListPersist;
    fValues: TObjectList<TPropertyListNode>;
    function GetCount: integer;
    function GetItem(const AKey: string): TPropertyListNode;
    function GetKeys: TDictionary<string, TPropertyListNode>.TKeyCollection;
    function GetValues: TDictionary<string, TPropertyListNode>.TValueCollection;
  protected
    function DoGetEnumerator: TPropertyListNodeEnumerator; override;
  public
    constructor Create(AParentNode: TPropertyListNode; const APersist: TPropertyListPersist);
    destructor Destroy; override;
    function Add(const AKey: string; AValue: TPropertyListNode): TPropertyListNode;
    function AddArray(const AKey: string): TPropertyListNode;
    function AddBoolean(const AKey: string; AValue: boolean): TPropertyListNode;
    function AddData(const AKey: string): TPropertyListNode;
    function AddDate(const AKey: string; const AValue: TDateTime): TPropertyListNode;
    function AddDictionary(const AKey: string): TPropertyListNode;
    function AddReal(const AKey: string; const AValue: double): TPropertyListNode;
    function AddString(const AKey: string; const AValue: string): TPropertyListNode;
    function AddUniqueIdentifier(const AKey: string; const AValue: UInt64): TPropertyListNode;
    function AddUnsignedInteger(const AKey: string; const AValue: UInt64): TPropertyListNode;
    procedure Clear;
    function ImportNative(const AKey: string; ANativeNode: plist_t): TPropertyListNode;
    function KeyExists(const AKey: string): boolean;
    procedure Remove(const AKey: string);
    function TryGetValue(const AKey: string; out AValue: TPropertyListNode): Boolean;
    property Count: Integer read GetCount;
    property Items[const AKey: string]: TPropertyListNode read GetItem; default;
    property Keys: TDictionary<string, TPropertyListNode>.TKeyCollection read GetKeys;
    property Values: TDictionary<string, TPropertyListNode>.TValueCollection read GetValues;
  end;

  TPropertyListData = class(TObject)
  strict private
    fData: Pointer;
    fSize: UInt64;
    procedure FreeData;
  public
    constructor Create;
    destructor Destroy; override;
    procedure GetData(AStream: TStream); overload;
    function GetData: TBytes; overload;
    procedure SetData(AData: Pointer; const ASize: UInt64); overload;
    procedure SetData(AStream: TStream); overload;
    procedure SetData(const AData: TBytes); overload;
    property Data: Pointer read fData;
    property Size: UInt64 read fSize;
  end;

  TPropertyListNode = class(TObject)
  strict private
    fNodeType: TPropertyListNodeType;
    fParentNode: TPropertyListNode;
    fPersist: TPropertyListPersist;
    fValue: TValue;
    procedure RaiseIfWrongNodeType(AExpectedNodeType: TPropertyListNodeType);
  private
    function GetAsArray: TPropertyListArray;
    function GetAsBoolean: boolean;
    function GetAsData: TPropertyListData;
    function GetAsDateTime: TDateTime;
    function GetAsDictionary: TPropertyListDictionary;
    function GetAsKey: string;
    function GetAsReal: double;
    function GetAsString: string;
    function GetAsUniqueIdentifier: UInt64;
    function GetAsUnsignedInteger: UInt64;
    function GetIsScalar: boolean;
    function GetNodeType: TPropertyListNodeType;
    function GetParentNode: TPropertyListNode;
    procedure SetAsBoolean(AValue: boolean);
    procedure SetAsDateTime(const AValue: TDateTime);
    procedure SetAsKey(const AValue: string);
    procedure SetAsReal(const AValue: double);
    procedure SetAsString(const AValue: string);
    procedure SetAsUniqueIdentifier(const AValue: UInt64);
    procedure SetAsUnsignedInteger(const AValue: UInt64);
    procedure SetParentNode(AValue: TPropertyListNode);
  public
    constructor Create(AType: TPropertyListNodeType; const APersist: TPropertyListPersist);
    destructor Destroy; override;
    function Copy: TPropertyListNode;
    function ToString: string; override;
    property AsArray: TPropertyListArray read GetAsArray;
    property AsBoolean: boolean read GetAsBoolean write SetAsBoolean;
    property AsData: TPropertyListData read GetAsData;
    property AsDateTime: TDateTime read GetAsDateTime write SetAsDateTime;
    property AsDictionary: TPropertyListDictionary read GetAsDictionary;
    property AsKey: string read GetAsKey write SetAsKey;
    property AsReal: double read GetAsReal write SetAsReal;
    property AsString: string read GetAsString write SetAsString;
    property AsUniqueIdentifier: UInt64 read GetAsUniqueIdentifier write SetAsUniqueIdentifier;
    property AsUnsignedInteger: UInt64 read GetAsUnsignedInteger write SetAsUnsignedInteger;
    property IsScalar: boolean read GetIsScalar;
    property NodeType: TPropertyListNodeType read GetNodeType;
    property ParentNode: TPropertyListNode read GetParentNode write SetParentNode;
  end;

  TConvertUtf8ToUnicodeDelegate = reference to function (const AValue: PAnsiChar): string;
  TConvertUnicodeToUtf8Delegate = reference to function (const AValue: string): PAnsiChar;

  TPropertyListPersist = class(TObject)
  strict private
    fApiService: TLibPListApi;
    fEpoch: TDateTime;
    fUtf8ToUnicodeDelegate: TConvertUtf8ToUnicodeDelegate;
    fUnicodeToUtf8Delegate: TConvertUnicodeToUtf8Delegate;
    function ConvertUtf8ToUnicode(const AValue: PAnsiChar): string;
    function ConvertUnicodeToUtf8(const AValue: string): PAnsiChar;
    function CreateNodeValueArray(AValue: TPropertyListArray): plist_t;
    function CreateNodeValueBoolean(AValue: boolean): plist_t;
    function CreateNodeValueData(AValue: TPropertyListData): plist_t;
    function CreateNodeValueDate(const AValue: TDateTime): plist_t;
    function CreateNodeValueDictionary(AValue: TPropertyListDictionary): plist_t;
    function CreateNodeValueReal(const AValue: double): plist_t;
    function CreateNodeValueString(const AValue: string): plist_t;
    function CreateNodeValueUniqueIdentifier(const AValue: UInt64): plist_t;
    function CreateNodeValueUnsignedInteger(const AValue: UInt64): plist_t;
    function DefaultUtf8ToUnicode(const AValue: PAnsiChar): string;
    function DefaultUnicodeToUtf8(const AValue: string): PAnsiChar;
    function GetEpoch: TDateTime;
    procedure SetEpoch(const AValue: TDateTime);
    function GetNodeType(ATypeId: cardinal): TPropertyListNodeType; overload;
    function GetNodeType(ANativeNode: plist_t): TPropertyListNodeType; overload;
    function GetNodeValueBoolean(ANativeNode: plist_t): boolean;
    function GetNodeValueDateTime(ANativeNode: plist_t): TDateTime;
    function GetNodeValueKey(ANativeNode: plist_t): string;
    function GetNodeValueReal(ANativeNode: plist_t): double;
    function GetNodeValueString(ANativeNode: plist_t): string;
    function GetNodeValueUInt64(ANativeNode: plist_t): UInt64;
    function GetNodeValueUniqueId(ANativeNode: plist_t): UInt64;
    procedure LoadArrayNode(ANode: TPropertyListNode; ANativeNode: plist_t);
    procedure LoadDataNode(ANode: TPropertyListNode; ANativeNode: plist_t);
    procedure LoadDictionaryNode(ANode: TPropertyListNode; ANativeNode: plist_t);
    function LoadFromStreamBinary(AStream: TStream): TPropertyListNode;
    function LoadFromStreamXml(AStream: TStream): TPropertyListNode;
    class function UnicodeToUtf8(const S: string): PAnsiChar;
  public
    constructor Create(AApiService: TLibPListApi); overload;
    constructor Create(AApiService: TLibPListApi;
      AUtf8ToUnicodeDelegate: TConvertUtf8ToUnicodeDelegate;
      AUnicodeToUtf8Delegate: TConvertUnicodeToUtf8Delegate); overload;
    destructor Destroy; override;
    function DataIsBinary(AStream: TStream): boolean;
    function FileIsBinary(const AFilename: string): boolean;
    procedure FreeNativePropertyList(AValue: plist_t);
    function LoadFromFile(const AFilename: string): TPropertyListNode;
    function LoadFromNative(APList: plist_t): TPropertyListNode;
    function LoadFromStream(AStream: TStream): TPropertyListNode;
    function LoadFromBuffer(const AData: TBytes): TPropertyListNode;
    procedure SaveToFileBinary(const AFilename: string; ANode: TPropertyListNode);
    procedure SaveToFileXml(const AFilename: string; ANode: TPropertyListNode);
    function SaveToNative(ANode: TPropertyListNode): plist_t;
    procedure SaveToStreamBinary(AStream: TStream; ARootNode: TPropertyListNode);
    procedure SaveToStreamXml(AStream: TStream; ARootNode: TPropertyListNode);
    property Epoch: TDateTime read GetEpoch write SetEpoch;
  end;

  TPropertyListRootNodeType = (plrntArray, plrntDictionary);

  TPropertyList = class(TObject)
  strict private
    fPersist: TPropertyListPersist;
    fApi: TLibPListApi;
    fRootNode: TPropertyListNode;
  private
    function GetAsArray: TPropertyListArray;
    function GetAsBoolean: boolean;
    function GetAsData: TPropertyListData;
    function GetAsDateTime: TDateTime;
    function GetAsDictionary: TPropertyListDictionary;
    function GetAsKey: string;
    function GetAsReal: double;
    function GetAsString: string;
    function GetAsUniqueIdentifier: UInt64;
    function GetAsUnsignedInteger: UInt64;
    function GetIsScalar: boolean;
    function GetNodeType: TPropertyListNodeType;
    function GetParentNode: TPropertyListNode;
    procedure SetAsBoolean(AValue: boolean);
    procedure SetAsDateTime(const AValue: TDateTime);
    procedure SetAsKey(const AValue: string);
    procedure SetAsReal(const AValue: double);
    procedure SetAsString(const AValue: string);
    procedure SetAsUniqueIdentifier(const AValue: UInt64);
    procedure SetAsUnsignedInteger(const AValue: UInt64);
    procedure SetParentNode(AValue: TPropertyListNode);
  public
    constructor Create; overload;
    constructor Create(ARootNodeType: TPropertyListRootNodeType); overload;
    constructor Create(ARootNodeType: TPropertyListRootNodeType; const APersist: TPropertyListPersist); overload;
    destructor Destroy; override;
    function Copy: TPropertyListNode;
    class procedure ExportScalarValues(const AFilename: string; ADictionary: TDictionary<string, string>); overload;
    class procedure ExportScalarValues(const AFilename: string; AList: TList<string>); overload;
    class procedure ExportScalarValues(APList: plist_t; ADictionary: TDictionary<string, string>); overload;
    class procedure ExportScalarValues(APList: plist_t; AList: TList<string>); overload;
    procedure ExportScalarValues(ADictionary: TDictionary<string, string>); overload;
    procedure ExportScalarValues(AList: TList<string>); overload;
    class procedure ExportScalarValues(AStream: TStream; ADictionary: TDictionary<string, string>); overload;
    class procedure ExportScalarValues(AStream: TStream; AList: TList<string>); overload;
    procedure FreeNativePropertyList(AValue: plist_t);
    class function FromFile(const AFilename: string): TPropertyList;
    class function FromNative(APList: plist_t): TPropertyList;
    class function FromStream(AStream: TStream): TPropertyList;
    procedure LoadFromFile(const AFilename: string);
    procedure LoadFromNative(APList: plist_t);
    procedure LoadFromStream(AStream: TStream);
    procedure LoadFromBuffer(const AData: TBytes);
    procedure SaveToFileBinary(const AFilename: string);
    procedure SaveToFileXml(const AFilename: string);
    function SaveToNative: plist_t;
    procedure SaveToStreamBinary(AStream: TStream);
    procedure SaveToStreamXml(AStream: TStream);
    function ToString: string; override;
    property AsArray: TPropertyListArray read GetAsArray;
    property AsBoolean: boolean read GetAsBoolean write SetAsBoolean;
    property AsData: TPropertyListData read GetAsData;
    property AsDateTime: TDateTime read GetAsDateTime write SetAsDateTime;
    property AsDictionary: TPropertyListDictionary read GetAsDictionary;
    property AsKey: string read GetAsKey write SetAsKey;
    property AsReal: double read GetAsReal write SetAsReal;
    property AsString: string read GetAsString write SetAsString;
    property AsUniqueIdentifier: UInt64 read GetAsUniqueIdentifier write SetAsUniqueIdentifier;
    property AsUnsignedInteger: UInt64 read GetAsUnsignedInteger write SetAsUnsignedInteger;
    property IsScalar: boolean read GetIsScalar;
    property NodeType: TPropertyListNodeType read GetNodeType;
    property ParentNode: TPropertyListNode read GetParentNode write SetParentNode;
  end;

implementation

uses
  System.DateUtils, System.TypInfo, System.Hash, WinApi.Windows;


{ TStringEqualityComparerCaseInsensitive }

function TStringEqualityComparerCaseInsensitive.Equals(const ALeft, ARight: string): Boolean;
begin
  Result := SameText(ALeft, ARight);
end;

function TStringEqualityComparerCaseInsensitive.GetHashCode(
  const AValue: string): Integer;
begin
  Result := THashBobJenkins.GetHashValue(Lowercase(AValue));
end;

{ TPropertyListArray }

constructor TPropertyListArray.Create(AParentNode: TPropertyListNode; const APersist: TPropertyListPersist);
begin
  inherited Create;
  fParentNode := AParentNode;
  fPersist := APersist;
  fArray := TObjectList<TPropertyListNode>.Create(True);
end;

destructor TPropertyListArray.Destroy;
begin
  FreeAndNil(fArray);
  fPersist := nil;
  inherited;
end;

function TPropertyListArray.Add(ANode: TPropertyListNode): TPropertyListNode;
begin
  Result := ANode;
  Result.ParentNode := fParentNode;
  fArray.Add(Result);
end;

function TPropertyListArray.AddArray: TPropertyListNode;
begin
  Result := Add(TPropertyListNode.Create(plntArray, fPersist));
end;

function TPropertyListArray.AddBoolean(AValue: boolean): TPropertyListNode;
begin
  Result := TPropertyListNode.Create(plntBoolean, fPersist);
  Result.AsBoolean := AValue;
  Add(Result);
end;

function TPropertyListArray.AddData: TPropertyListNode;
begin
  Result := Add(TPropertyListNode.Create(plntData, fPersist));
end;

function TPropertyListArray.AddDate(const AValue: TDateTime): TPropertyListNode;
begin
  Result := TPropertyListNode.Create(plntDate, fPersist);
  Result.AsDateTime := AValue;
  Add(Result);
end;

function TPropertyListArray.AddDictionary: TPropertyListNode;
begin
  Result := Add(TPropertyListNode.Create(plntDictionary, fPersist));
end;

function TPropertyListArray.AddReal(const AValue: double): TPropertyListNode;
begin
  Result := TPropertyListNode.Create(plntReal, fPersist);
  Result.AsReal := AValue;
  Add(Result);
end;

function TPropertyListArray.AddString(const AValue: string): TPropertyListNode;
begin
  Result := TPropertyListNode.Create(plntString, fPersist);
  Result.AsString := AValue;
  Add(Result);
end;

function TPropertyListArray.AddUniqueIdentifier(const AValue: UInt64): TPropertyListNode;
begin
  Result := TPropertyListNode.Create(plntUniqueIdentifier, fPersist);
  Result.AsUniqueIdentifier := AValue;
  Add(Result);
end;

function TPropertyListArray.AddUnsignedInteger(const AValue: UInt64): TPropertyListNode;
begin
  Result := TPropertyListNode.Create(plntUnsignedInteger, fPersist);
  Result.AsUnsignedInteger := AValue;
  Add(Result);
end;

procedure TPropertyListArray.Clear;
begin
  fArray.Clear;
end;

procedure TPropertyListArray.RemoveAt(AIndex: integer);
begin
  fArray.Delete(AIndex);
end;

procedure TPropertyListArray.Remove(AValue: TPropertyListNode);
begin
  fArray.Remove(AValue);
end;

function TPropertyListArray.DoGetEnumerator: TEnumerator<TPropertyListNode>;
begin
  Result := fArray.GetEnumerator;
end;

function TPropertyListArray.GetCount: integer;
begin
  Result := fArray.Count;
end;

function TPropertyListArray.GetItem(AIndex: integer): TPropertyListNode;
begin
  Result := fArray[AIndex];
end;

function TPropertyListArray.ImportNative(ANativeNode: plist_t): TPropertyListNode;
begin
  Result := Add(fPersist.LoadFromNative(ANativeNode));
end;

{ TPropertyListDictionary }

constructor TPropertyListDictionary.Create(AParentNode: TPropertyListNode; const APersist: TPropertyListPersist);
var
  lComparer: IEqualityComparer<string>;
begin
  inherited Create;
  fParentNode := AParentNode;
  fPersist := APersist;
  lComparer := TStringEqualityComparerCaseInsensitive.Create;
  fDictionary := TDictionary<string, TPropertyListNode>.Create(lComparer);
  fValues := TObjectList<TPropertyListNode>.Create(True);
end;

destructor TPropertyListDictionary.Destroy;
begin
  fParentNode := nil;
  fPersist := nil;
  FreeAndNil(fDictionary);
  FreeAndNil(fValues);
  inherited;
end;

function TPropertyListDictionary.Add(const AKey: string;
  AValue: TPropertyListNode): TPropertyListNode;
begin
  Result := AValue;
  Result.ParentNode := fParentNode;
  fValues.Add(Result);
  fDictionary.Add(AKey, Result);
end;

function TPropertyListDictionary.AddArray(const AKey: string): TPropertyListNode;
begin
  Result := Add(AKey, TPropertyListNode.Create(plntArray, fPersist));
end;

function TPropertyListDictionary.AddBoolean(const AKey: string; AValue: boolean): TPropertyListNode;
begin
  Result := TPropertyListNode.Create(plntBoolean, fPersist);
  Result.AsBoolean := AValue;
  Add(AKey, Result);
end;

function TPropertyListDictionary.AddData(const AKey: string): TPropertyListNode;
begin
  Result := Add(AKey, TPropertyListNode.Create(plntData, fPersist));
end;

function TPropertyListDictionary.AddDate(const AKey: string; const AValue: TDateTime): TPropertyListNode;
begin
  Result := TPropertyListNode.Create(plntDate, fPersist);
  Result.AsDateTime := AValue;
  Add(AKey, Result);
end;

function TPropertyListDictionary.AddDictionary(const AKey: string): TPropertyListNode;
begin
  Result := Add(AKey, TPropertyListNode.Create(plntDictionary, fPersist));
end;

function TPropertyListDictionary.AddReal(const AKey: string; const AValue: double): TPropertyListNode;
begin
  Result := TPropertyListNode.Create(plntReal, fPersist);
  Result.AsReal := AValue;
  Add(AKey, Result);
end;

function TPropertyListDictionary.AddString(const AKey: string; const AValue: string): TPropertyListNode;
begin
  Result := TPropertyListNode.Create(plntString, fPersist);
  Result.AsString := AValue;
  Add(AKey, Result);
end;

function TPropertyListDictionary.AddUniqueIdentifier(const AKey: string; const AValue: UInt64): TPropertyListNode;
begin
  Result := TPropertyListNode.Create(plntUniqueIdentifier, fPersist);
  Result.AsUniqueIdentifier := AValue;
  Add(AKey, Result);
end;

function TPropertyListDictionary.AddUnsignedInteger(const AKey: string; const AValue: UInt64): TPropertyListNode;
begin
  Result := TPropertyListNode.Create(plntUnsignedInteger, fPersist);
  Result.AsUnsignedInteger := AValue;
  Add(AKey, Result);
end;

procedure TPropertyListDictionary.Clear;
begin
  fDictionary.Clear;
  fValues.Clear;
end;

function TPropertyListDictionary.DoGetEnumerator: TEnumerator<TPair<string, TPropertyListNode>>;
begin
  Result := fDictionary.GetEnumerator;
end;

function TPropertyListDictionary.GetCount: integer;
begin
  Result := fDictionary.Count;
end;

function TPropertyListDictionary.GetItem(const AKey: string): TPropertyListNode;
begin
  Result := fDictionary[AKey];
end;

function TPropertyListDictionary.GetKeys: TDictionary<string, TPropertyListNode>.TKeyCollection;
begin
  Result := fDictionary.Keys;
end;

function TPropertyListDictionary.GetValues: TDictionary<string, TPropertyListNode>.TValueCollection;
begin
  Result := fDictionary.Values;
end;

function TPropertyListDictionary.ImportNative(const AKey: string; ANativeNode: plist_t): TPropertyListNode;
begin
  Result := Add(AKey, fPersist.LoadFromNative(ANativeNode));
end;

function TPropertyListDictionary.KeyExists(const AKey: string): boolean;
begin
  Result := fDictionary.ContainsKey(AKey);
end;

procedure TPropertyListDictionary.Remove(const AKey: string);
var
  lValue: TPropertyListNode;
begin
  lValue := fDictionary[AKey];
  fDictionary.Remove(AKey);
  fValues.Remove(lValue);
end;

function TPropertyListDictionary.TryGetValue(const AKey: string;
  out AValue: TPropertyListNode): Boolean;
begin
  Result := fDictionary.TryGetValue(AKey, AValue);
end;

{ TPropertyListData }

constructor TPropertyListData.Create;
begin
  inherited;
  fData := nil;
  fSize := 0;
end;

destructor TPropertyListData.Destroy;
begin
  FreeData;
  inherited;
end;

procedure TPropertyListData.FreeData;
begin
  if fData <> nil then
  begin
    FreeMem(fData);
    fData := nil;
    fSize := 0;
  end;
end;

procedure TPropertyListData.GetData(AStream: TStream);
begin
  AStream.Write(Data^, Size);
  AStream.Position := 0;
end;

function TPropertyListData.GetData: TBytes;
begin
  if fSize > 0 then
  begin
    SetLength(Result, fSize);
    System.Move(fData^, Result[0], fSize);
  end;
end;

procedure TPropertyListData.SetData(AData: Pointer; const ASize: UInt64);
begin
  FreeData;
  fSize := ASize;
  if fSize > 0 then
  begin
    GetMem(fData, fSize);
    CopyMemory(fData, AData, fSize);
  end;
end;

procedure TPropertyListData.SetData(AStream: TStream);
begin
  FreeData;
  if AStream <> nil then
  begin
    AStream.Position := 0;
    fSize := AStream.Size;
    GetMem(fData, fSize);
    AStream.Read(fData^, fSize);
  end;
end;

procedure TPropertyListData.SetData(const AData: TBytes);
begin
  FreeData;
  fSize := Length(AData);
  if fSize > 0 then
  begin
    GetMem(fData, fSize);
    System.Move(AData[0], fData^, fSize);
  end;
end;

{ TPropertyListNode }

constructor TPropertyListNode.Create(AType: TPropertyListNodeType; const APersist: TPropertyListPersist);
begin
  inherited Create;
  fNodeType := AType;
  fParentNode := nil;
  fPersist := APersist;
  case fNodeType of
    plntBoolean: AsBoolean := False;
    plntUnsignedInteger: AsUnsignedInteger := 0;
    plntReal: AsReal := 0.0;
    plntString: AsString := EmptyStr;
    plntArray: fValue := TPropertyListArray.Create(Self, fPersist);
    plntDictionary: fValue := TPropertyListDictionary.Create(Self, fPersist);
    plntDate: AsDateTime := EncodeDate(1900, 1, 1);
    plntData: fValue := TPropertyListData.Create;
    plntUniqueIdentifier: AsUniqueIdentifier := 0;
  end;
end;

destructor TPropertyListNode.Destroy;
var
  lObj: TObject;
begin
  fPersist := nil;
  case fNodeType of
    plntArray,
    plntDictionary,
    plntData:
    begin
      lObj := fValue.AsObject;
      if lObj <> nil then
        lObj.Free;
    end;
  end;
  inherited;
end;

function TPropertyListNode.Copy: TPropertyListNode;
var
  I: Integer;
  lItem: TPropertyListNode;
  lKey: string;
begin
  Result := TPropertyListNode.Create(NodeType, fPersist);
  case NodeType of
    plntBoolean: Result.AsBoolean := AsBoolean;
    plntUnsignedInteger: Result.AsUnsignedInteger := AsUnsignedInteger;
    plntReal: Result.AsReal := AsReal;
    plntString: Result.AsString := AsString;
    plntDate: Result.AsDateTime := AsDateTime;
    plntData: Result.AsData.SetData(AsData.Data, AsData.Size);
    plntKey: Result.AsKey := AsKey;
    plntUniqueIdentifier: Result.AsUniqueIdentifier := AsUniqueIdentifier;
    plntArray:
    begin
      for I := 0 to AsArray.Count - 1 do
      begin
        lItem := AsArray[I].Copy;
        Result.AsArray.Add(lItem);
      end;
    end;
    plntDictionary:
    begin
      for lKey in AsDictionary.Keys do
      begin
        lItem := AsDictionary[lKey].Copy;
        Result.AsDictionary.Add(lKey, lItem);
      end;
    end;
  end;
end;

function TPropertyListNode.GetAsArray: TPropertyListArray;
begin
  RaiseIfWrongNodeType(plntArray);
  Result := TPropertyListArray(fValue.AsObject);
end;

function TPropertyListNode.GetAsBoolean: boolean;
begin
  RaiseIfWrongNodeType(plntBoolean);
  Result := fValue.AsBoolean;
end;

function TPropertyListNode.GetAsData: TPropertyListData;
begin
  RaiseIfWrongNodeType(plntData);
  Result := TPropertyListData(fValue.AsObject);
end;

function TPropertyListNode.GetAsDateTime: TDateTime;
begin
  RaiseIfWrongNodeType(plntDate);
  Result := fValue.AsType<TDateTime>;
end;

function TPropertyListNode.GetAsDictionary: TPropertyListDictionary;
begin
  RaiseIfWrongNodeType(plntDictionary);
  Result := TPropertyListDictionary(fValue.AsObject);
end;

function TPropertyListNode.GetAsKey: string;
begin
  RaiseIfWrongNodeType(plntKey);
  Result := fValue.AsString;
end;

function TPropertyListNode.GetAsReal: double;
begin
  if not ((NodeType = plntReal) or (NodeType = plntUnsignedInteger)) then
  begin
    RaiseIfWrongNodeType(plntReal);
  end;
  Result := fValue.AsType<double>;
end;

function TPropertyListNode.GetAsString: string;
begin
  RaiseIfWrongNodeType(plntString);
  Result := fValue.AsString;
  if (Pointer(Result) = nil) then
  begin
    Result := EmptyStr;
  end;
end;

function TPropertyListNode.GetAsUniqueIdentifier: UInt64;
begin
  RaiseIfWrongNodeType(plntUniqueIdentifier);
  Result := fValue.AsUInt64;
end;

function TPropertyListNode.GetAsUnsignedInteger: UInt64;
begin
  if not ((NodeType = plntReal) or (NodeType = plntUnsignedInteger)) then
  begin
    RaiseIfWrongNodeType(plntUnsignedInteger);
  end;
  Result := fValue.AsUInt64;
end;

function TPropertyListNode.GetIsScalar: boolean;
begin
  Result := NodeType in [plntBoolean, plntUnsignedInteger, plntReal, plntString, plntDate, plntUniqueIdentifier];
end;

function TPropertyListNode.GetNodeType: TPropertyListNodeType;
begin
  Result := fNodeType;
end;

function TPropertyListNode.GetParentNode: TPropertyListNode;
begin
  Result := fParentNode;
end;

procedure TPropertyListNode.RaiseIfWrongNodeType(
  AExpectedNodeType: TPropertyListNodeType);
begin
  if NodeType <> AExpectedNodeType then
    raise Exception.Create(Format('Invalid typecast: %s as %s',
      [
        GetEnumName(TypeInfo(TPropertyListNodeType), Ord(NodeType)),
        GetEnumName(TypeInfo(TPropertyListNodeType), Ord(AExpectedNodeType))
      ]));
end;

procedure TPropertyListNode.SetAsBoolean(AValue: boolean);
begin
  RaiseIfWrongNodeType(plntBoolean);
  fValue := TValue.From<boolean>(AValue);
end;

procedure TPropertyListNode.SetAsDateTime(const AValue: TDateTime);
begin
  RaiseIfWrongNodeType(plntDate);
  fValue := TValue.From<TDateTime>(AValue);
end;

procedure TPropertyListNode.SetAsKey(const AValue: string);
begin
  RaiseIfWrongNodeType(plntKey);
  fValue := TValue.From<string>(AValue);
end;

procedure TPropertyListNode.SetAsReal(const AValue: double);
begin
  RaiseIfWrongNodeType(plntReal);
  fValue := TValue.From<double>(AValue);
end;

procedure TPropertyListNode.SetAsString(const AValue: string);
begin
  RaiseIfWrongNodeType(plntString);
  fValue := TValue.From<string>(AValue);
end;

procedure TPropertyListNode.SetAsUniqueIdentifier(const AValue: UInt64);
begin
  RaiseIfWrongNodeType(plntUniqueIdentifier);
  fValue := TValue.From<UInt64>(AValue);
end;

procedure TPropertyListNode.SetAsUnsignedInteger(const AValue: UInt64);
begin
  RaiseIfWrongNodeType(plntUnsignedInteger);
  fValue := TValue.From<UInt64>(AValue);
end;

procedure TPropertyListNode.SetParentNode(AValue: TPropertyListNode);
begin
  fParentNode := AValue;
end;

function TPropertyListNode.ToString: string;
begin
  case NodeType of
    plntBoolean: Result := AsBoolean.ToString;
    plntUnsignedInteger: Result := AsUnsignedInteger.ToString;
    plntReal: Result := AsReal.ToString;
    plntString: Result := AsString;
    plntDate: Result := DateTimeToStr(AsDateTime);
    plntUniqueIdentifier: Result := AsUniqueIdentifier.ToString;
    else
      Result := inherited ToString();
  end;
end;

{ TPropertyListPersist }

constructor TPropertyListPersist.Create(
  AApiService: TLibPListApi);
begin
  Create(AApiService, nil, nil);
end;

function TPropertyListPersist.ConvertUtf8ToUnicode(
  const AValue: PAnsiChar): string;
begin
  if Assigned(fUtf8ToUnicodeDelegate) then
    Result := fUtf8ToUnicodeDelegate(AValue)
  else
    Result := DefaultUtf8ToUnicode(AValue);
end;

function TPropertyListPersist.ConvertUnicodeToUtf8(
  const AValue: string): PAnsiChar;
begin
  if Assigned(fUnicodeToUtf8Delegate) then
    Result := fUnicodeToUtf8Delegate(AValue)
  else
    Result := DefaultUnicodeToUtf8(AValue);
end;

constructor TPropertyListPersist.Create(
  AApiService: TLibPListApi;
  AUtf8ToUnicodeDelegate: TConvertUtf8ToUnicodeDelegate;
  AUnicodeToUtf8Delegate: TConvertUnicodeToUtf8Delegate);
begin
  inherited Create;
  fApiService := AApiService;
  fUtf8ToUnicodeDelegate := AUtf8ToUnicodeDelegate;
  fUnicodeToUtf8Delegate := AUnicodeToUtf8Delegate;
  fEpoch := EncodeDate(2001, 1, 1);
end;

destructor TPropertyListPersist.Destroy;
begin
  fApiService := nil;
  inherited;
end;

function TPropertyListPersist.CreateNodeValueArray(AValue: TPropertyListArray): plist_t;
var
  I: integer;
  lItem: plist_t;
begin
  Result := fApiService.plist_new_array;
  for I := 0 to AValue.Count - 1 do
  begin
    lItem := SaveToNative(AValue[I]);
    fApiService.plist_array_append_item(Result, lItem);
  end;
end;

function TPropertyListPersist.CreateNodeValueBoolean(AValue: boolean): plist_t;
var
  lValue: byte;
begin
  if AValue then
    lValue := 1
  else
    lValue := 0;
  Result := fApiService.plist_new_bool(lValue);
end;

function TPropertyListPersist.CreateNodeValueData(AValue: TPropertyListData): plist_t;
begin
  Result := fApiService.plist_new_data(AValue.Data, AValue.Size);
end;

function TPropertyListPersist.CreateNodeValueDate(const AValue: TDateTime): plist_t;
var
  lConvertedDateTime: Int64;
begin
  lConvertedDateTime := MilliSecondsBetween(AValue, fEpoch) div 1000;
  Result := fApiService.plist_new_date(lConvertedDateTime, 0);
end;

function TPropertyListPersist.CreateNodeValueDictionary(AValue: TPropertyListDictionary): plist_t;
var
  lItem: plist_t;
  lKey: string;
begin
  Result := fApiService.plist_new_dict;
  for lKey in AValue.Keys do
  begin
    lItem := SaveToNative(AValue[lKey]);
    fApiService.plist_dict_set_item(Result, PAnsiChar(AnsiString(lKey)), lItem); {do not use delegate here}
  end;
end;

function TPropertyListPersist.CreateNodeValueReal(const AValue: double): plist_t;
begin
  Result := fApiService.plist_new_real(AValue);
end;

function TPropertyListPersist.CreateNodeValueString(const AValue: string): plist_t;
var
  lTemp: PAnsiChar;
begin
  lTemp := ConvertUnicodeToUtf8(AValue);
  if (lTemp = nil) then
  begin
    ltemp := AllocMem(1);
  end;
  Result := fApiService.plist_new_string(lTemp);
  FreeMem(lTemp);
end;

function TPropertyListPersist.CreateNodeValueUniqueIdentifier(const AValue: UInt64): plist_t;
begin
  Result := fApiService.plist_new_uid(AValue);
end;

function TPropertyListPersist.CreateNodeValueUnsignedInteger(const AValue: UInt64): plist_t;
begin
  Result := fApiService.plist_new_uint(AValue);
end;

function TPropertyListPersist.DataIsBinary(AStream: TStream): boolean;
const
  BinaryHeader: AnsiString = 'bplist00';
var
  lFileHeader: AnsiString;
begin
  SetLength(lFileHeader, Length(BinaryHeader));
  AStream.Position := 0;
  AStream.Read(Pointer(lFileHeader)^, Length(lFileHeader));
  Result := SameText(UnicodeString(BinaryHeader), UnicodeString(lFileHeader));
end;

function TPropertyListPersist.DefaultUtf8ToUnicode(
  const AValue: PAnsiChar): string;
begin
  Result := System.Utf8ToUnicodeString(AValue);
end;

class function TPropertyListPersist.UnicodeToUtf8(const S: string): PAnsiChar;
var
  lLength: Integer;
  lTemp: PAnsiChar;
begin
  Result := nil;
  if S = '' then Exit;
  lLength := Length(S);
  lTemp := AllocMem(lLength + 1);
  System.UnicodeToUtf8(lTemp, lLength + 1, PWideChar(S), lLength);
  Result := lTemp;
end;

function TPropertyListPersist.DefaultUnicodeToUtf8(
  const AValue: string): PAnsiChar;
begin
  Result := Self.UnicodeToUtf8(AValue);
end;

function TPropertyListPersist.FileIsBinary(const AFilename: string): boolean;
var
  lStream: TStream;
begin
  lStream := TFileStream.Create(AFilename, fmOpenRead or fmShareDenyNone);
  try
    Result := DataIsBinary(lStream);
  finally
    lStream.Free;
  end;
end;

procedure TPropertyListPersist.FreeNativePropertyList(AValue: plist_t);
begin
  if AValue <> nil then
    fApiService.plist_free(AValue);
end;

function TPropertyListPersist.GetEpoch: TDateTime;
begin
  Result := fEpoch;
end;

function TPropertyListPersist.GetNodeType(
  ATypeId: cardinal): TPropertyListNodeType;
begin
  case ATypeId of
    PLIST_TYPE_BOOLEAN: Result := plntBoolean;
    PLIST_TYPE_UNSIGNED_INTEGER: Result := plntUnsignedInteger;
    PLIST_TYPE_REAL: Result := plntReal;
    PLIST_TYPE_STRING: Result := plntString;
    PLIST_TYPE_ARRAY: Result := plntArray;
    PLIST_TYPE_DICTIONARY: Result := plntDictionary;
    PLIST_TYPE_DATE: Result := plntDate;
    PLIST_TYPE_DATA: Result := plntData;
    PLIST_TYPE_KEY: Result := plntKey;
    PLIST_TYPE_UNIQUE_IDENTIFIER: Result := plntUniqueIdentifier;
    else
      Result := plntNone;
  end;
end;

function TPropertyListPersist.GetNodeType(ANativeNode: plist_t): TPropertyListNodeType;
var
  lNodeTypeId: cardinal;
begin
  lNodeTypeId := fApiService.plist_get_node_type(ANativeNode);
  Result := GetNodeType(lNodeTypeId);
end;

function TPropertyListPersist.GetNodeValueBoolean(ANativeNode: plist_t): boolean;
var
  lValue: byte;
begin
  fApiService.plist_get_bool_val(ANativeNode, lValue);
  Result := lValue = 1;
end;

function TPropertyListPersist.GetNodeValueDateTime(
  ANativeNode: plist_t): TDateTime;
var
  lValueSec: integer;
  lValueUSec: integer;
begin
  fApiService.plist_get_date_val(ANativeNode, lValueSec, lValueUSec);
  Result := IncSecond(fEpoch, lValueSec);
end;

function TPropertyListPersist.GetNodeValueKey(ANativeNode: plist_t): string;
var
  lValue: PAnsiChar;
begin
  Result := EmptyStr;
  lValue := nil;
  fApiService.plist_get_key_val(ANativeNode, lValue);
  if lValue <> nil then
  begin
    Result := ConvertUtf8ToUnicode(lValue);
  end;
end;

function TPropertyListPersist.GetNodeValueReal(ANativeNode: plist_t): double;
begin
  fApiService.plist_get_real_val(ANativeNode, Result);
end;

function TPropertyListPersist.GetNodeValueString(ANativeNode: plist_t): string;
var
  lValue: PAnsiChar;
begin
  Result := EmptyStr;
  lValue := nil;
  fApiService.plist_get_string_val(ANativeNode, lValue);
  if lValue <> nil then
  begin
    Result := ConvertUtf8ToUnicode(lValue);
  end;
end;

function TPropertyListPersist.GetNodeValueUInt64(ANativeNode: plist_t): UInt64;
begin
  fApiService.plist_get_uint_val(ANativeNode, Result);
end;

function TPropertyListPersist.GetNodeValueUniqueId(ANativeNode: plist_t): UInt64;
begin
  fApiService.plist_get_uid_val(ANativeNode, Result);
end;

procedure TPropertyListPersist.LoadArrayNode(ANode: TPropertyListNode;
  ANativeNode: plist_t);
var
  I: Integer;
  lItemCount: Integer;
  lItem: plist_t;
  lNodeItem: TPropertyListNode;
begin
  lItemCount := fApiService.plist_array_get_size(ANativeNode);
  for I := 0 to lItemCount - 1 do
  begin
    lItem := fApiService.plist_array_get_item(ANativeNode, I);
    lNodeItem := LoadFromNative(lItem);
    ANode.AsArray.Add(lNodeItem);
  end;
end;

procedure TPropertyListPersist.LoadDataNode(ANode: TPropertyListNode;
  ANativeNode: plist_t);
var
  lData: Pointer;
  lSize: UInt64;
begin
  lData := nil;
  lSize := 0;
  fApiService.plist_get_data_val(ANativeNode, lData, lSize);
  ANode.AsData.SetData(lData, lSize);
end;

procedure TPropertyListPersist.LoadDictionaryNode(ANode: TPropertyListNode;
  ANativeNode: plist_t);
var
  lNativeIter: plist_t;
  lKeyPtr: PAnsiChar;
  lValue: plist_t;
  lKey: string;
  lNodeItem: TPropertyListNode;
begin
  fApiService.plist_dict_new_iter(ANativeNode, lNativeIter);
  fApiService.plist_dict_next_item(ANativeNode, lNativeIter, lKeyPtr, lValue);
  while lKeyPtr <> nil do
  begin
    lKey := UnicodeString(AnsiString(lKeyPtr)); {do not use delegate here}
    if lValue <> nil then
    begin
      lNodeItem := LoadFromNative(lValue);
      ANode.AsDictionary.Add(lKey, lNodeItem);
    end;
    fApiService.plist_dict_next_item(ANativeNode, lNativeIter, lKeyPtr, lValue);
  end;
end;

function TPropertyListPersist.LoadFromFile(const AFilename: string): TPropertyListNode;
var
  lStream: TStream;
begin
  lStream := TFileStream.Create(AFilename, fmOpenRead or fmShareDenyNone);
  try
    Result := LoadFromStream(lStream);
  finally
    lStream.Free;
  end;
end;

function TPropertyListPersist.LoadFromNative(APList: plist_t): TPropertyListNode;
var
  lNodeType: TPropertyListNodeType;
begin
  lNodeType := GetNodeType(APlist);
  Result := TPropertyListNode.Create(lNodeType, Self);
  case lNodeType of
    plntBoolean: Result.AsBoolean := GetNodeValueBoolean(APList);
    plntUniqueIdentifier: Result.AsUniqueIdentifier := GetNodeValueUniqueId(APList);
    plntUnsignedInteger: Result.AsUnsignedInteger := GetNodeValueUInt64(APList);
    plntReal: Result.AsReal := GetNodeValueReal(APList);
    plntString: Result.AsString := GetNodeValueString(APList);
    plntKey: Result.AsKey := GetNodeValueKey(APList);
    plntDate: Result.AsDateTime := GetNodeValueDateTime(APList);
    plntData: LoadDataNode(Result, APList);
    plntArray: LoadArrayNode(Result, APList);
    plntDictionary: LoadDictionaryNode(Result, APList);
    else
      raise Exception.Create('Unsupported node type');
  end;
end;

function TPropertyListPersist.LoadFromStream(
  AStream: TStream): TPropertyListNode;
begin
  if DataIsBinary(AStream) then
    Result := LoadFromStreamBinary(AStream)
  else
    Result := LoadFromStreamXml(AStream);
end;

function TPropertyListPersist.LoadFromBuffer(const AData: TBytes): TPropertyListNode;
var
  lTempStream: TStream;
begin
  lTempStream := TMemoryStream.Create;
  try
    lTempStream.Write(AData, 0, Length(AData));
    lTempStream.Position := 0;
    Result := LoadFromStream(lTempStream);
  finally
    lTempStream.Free;
  end;
end;

function TPropertyListPersist.LoadFromStreamBinary(
  AStream: TStream): TPropertyListNode;
var
  lData: Pointer;
  lSize: Cardinal;
  lNativePList: plist_t;
begin
  lSize := AStream.Size;
  GetMem(lData, lSize);
  try
    AStream.Position := 0;
    AStream.Read(lData^, lSize);
    lNativePList := nil;
    fApiService.plist_from_bin(lData, lSize, lNativePList);
    try
      Result := LoadFromNative(lNativePList);
    finally
      fApiService.plist_free(lNativePList);
    end;
  finally
    FreeMem(lData);
  end;
end;

function TPropertyListPersist.LoadFromStreamXml(
  AStream: TStream): TPropertyListNode;
var
  lData: PAnsiChar;
  lSize: Cardinal;
  lNativePList: plist_t;
begin
  lSize := AStream.Size;
  GetMem(lData, lSize);
  try
    AStream.Position := 0;
    AStream.Read(lData^, lSize);
    lNativePList := nil;
    fApiService.plist_from_xml(lData, lSize, lNativePList);
    try
      Result := LoadFromNative(lNativePList);
    finally
      fApiService.plist_free(lNativePList);
    end;
  finally
    FreeMem(lData);
  end;
end;

procedure TPropertyListPersist.SaveToFileBinary(const AFilename: string;
  ANode: TPropertyListNode);
var
  lStream: TStream;
begin
  lStream := TFileStream.Create(AFilename, fmCreate or fmOpenReadWrite or fmShareDenyNone);
  try
    SaveToStreamBinary(lStream, ANode);
  finally
    lStream.Free;
  end;
end;

procedure TPropertyListPersist.SaveToFileXml(const AFilename: string;
  ANode: TPropertyListNode);
var
  lStream: TStream;
begin
  lStream := TFileStream.Create(AFilename, fmCreate or fmOpenReadWrite or fmShareDenyNone);
  try
    SaveToStreamXml(lStream, ANode);
  finally
    lStream.Free;
  end;
end;

function TPropertyListPersist.SaveToNative(
  ANode: TPropertyListNode): plist_t;
begin
  case ANode.NodeType of
    plntBoolean: Result := CreateNodeValueBoolean(ANode.AsBoolean);
    plntUnsignedInteger: Result := CreateNodeValueUnsignedInteger(ANode.AsUnsignedInteger);
    plntReal: Result := CreateNodeValueReal(ANode.AsReal);
    plntString: Result := CreateNodeValueString(ANode.AsString);
    plntDate: Result := CreateNodeValueDate(ANode.AsDateTime);
    plntUniqueIdentifier: Result := CreateNodeValueUniqueIdentifier(ANode.AsUniqueIdentifier);
    plntData: Result := CreateNodeValueData(ANode.AsData);
    plntArray: Result := CreateNodeValueArray(ANode.AsArray);
    plntDictionary: Result := CreateNodeValueDictionary(ANode.AsDictionary);
    else
      raise Exception.Create('Unsupported node type');
  end;
end;

procedure TPropertyListPersist.SaveToStreamBinary(AStream: TStream;
  ARootNode: TPropertyListNode);
var
  lData: Pointer;
  lSize: Cardinal;
  lNativePList: plist_t;
begin
  lNativePList := SaveToNative(ARootNode);
  try
    lData := nil;
    fApiService.plist_to_bin(lNativePList, lData, lSize);
    if lData <> nil then
    begin
      AStream.Write(lData^, lSize);
    end;
  finally
    fApiService.plist_free(lNativePList);
  end;
end;

procedure TPropertyListPersist.SaveToStreamXml(AStream: TStream;
  ARootNode: TPropertyListNode);
var
  lData: PAnsiChar;
  lSize: Cardinal;
  lNativePList: plist_t;
begin
  lNativePList := SaveToNative(ARootNode);
  try
    lData := nil;
    fApiService.plist_to_xml(lNativePList, lData, lSize);
    if lData <> nil then
    begin
      AStream.Write(lData^, lSize);
    end;
  finally
    fApiService.plist_free(lNativePList);
  end;
end;

procedure TPropertyListPersist.SetEpoch(const AValue: TDateTime);
begin
  fEpoch := AValue;
end;

{ TPropertyList }

constructor TPropertyList.Create;
begin
  Create(plrntDictionary);
end;

constructor TPropertyList.Create(ARootNodeType: TPropertyListRootNodeType);
var
  lPersist: TPropertyListPersist;
begin
  fApi := TLibPListApi.Create('libplist-2.0.dll');
  lPersist := TPropertyListPersist.Create(fApi);
  Create(ARootNodeType, lPersist);
end;

constructor TPropertyList.Create(ARootNodeType: TPropertyListRootNodeType; const APersist: TPropertyListPersist);
begin
  inherited Create;
  fPersist := APersist;
  case ARootNodeType of
    plrntArray: fRootNode := TPropertyListNode.Create(plntArray, fPersist);
    plrntDictionary: fRootNode := TPropertyListNode.Create(plntDictionary, fPersist);
  end;
end;

destructor TPropertyList.Destroy;
begin
  fPersist := nil;
  FreeAndNil(fRootNode);
  inherited;
end;

function TPropertyList.Copy: TPropertyListNode;
begin
  Result := fRootNode.Copy;
end;

class procedure TPropertyList.ExportScalarValues(const AFilename: string;
  ADictionary: TDictionary<string, string>);
begin
  with Self.FromFile(AFilename) do
  try
    ExportScalarValues(ADictionary);
  finally
    Free;
  end;
end;

class procedure TPropertyList.ExportScalarValues(const AFilename: string;
  AList: TList<string>);
begin
  with Self.FromFile(AFilename) do
  try
    ExportScalarValues(AList);
  finally
    Free;
  end;
end;

class procedure TPropertyList.ExportScalarValues(APList: plist_t;
  ADictionary: TDictionary<string, string>);
begin
  with Self.FromNative(APList) do
  try
    ExportScalarValues(ADictionary);
  finally
    Free;
  end;
end;

class procedure TPropertyList.ExportScalarValues(APList: plist_t;
  AList: TList<string>);
begin
  with Self.FromNative(APList) do
  try
    ExportScalarValues(AList);
  finally
    Free;
  end;
end;

procedure TPropertyList.ExportScalarValues(
  ADictionary: TDictionary<string, string>);
var
  lKey: string;
  lDict: TPropertyListDictionary;
begin
  if (NodeType = plntDictionary) then
  begin
    lDict := AsDictionary;
    for lKey in lDict.Keys do
    begin
      if lDict[lKey].IsScalar then
      begin
        ADictionary.Add(lKey, lDict[lKey].ToString);
      end;
    end;
  end;
end;

procedure TPropertyList.ExportScalarValues(AList: TList<string>);
var
  I: Integer;
  lList: TPropertyListArray;
begin
  if (NodeType = plntArray) then
  begin
    lList := AsArray;
    for I := 0 to lList.Count - 1 do
    begin
      if lList[I].IsScalar then
      begin
        AList.Add(lList[I].ToString);
      end;
    end;
  end;
end;

class procedure TPropertyList.ExportScalarValues(AStream: TStream;
  ADictionary: TDictionary<string, string>);
begin
  with Self.FromStream(AStream) do
  try
    ExportScalarValues(ADictionary);
  finally
    Free;
  end;
end;

class procedure TPropertyList.ExportScalarValues(AStream: TStream;
  AList: TList<string>);
begin
  with Self.FromStream(AStream) do
  try
    ExportScalarValues(AList);
  finally
    Free;
  end;
end;

procedure TPropertyList.FreeNativePropertyList(AValue: plist_t);
begin
  fPersist.FreeNativePropertyList(AValue);
end;

class function TPropertyList.FromFile(const AFilename: string): TPropertyList;
begin
  Result := Self.Create;
  Result.LoadFromFile(AFilename);
end;

class function TPropertyList.FromNative(APList: plist_t): TPropertyList;
begin
  Result := Self.Create;
  Result.LoadFromNative(APList);
end;

class function TPropertyList.FromStream(AStream: TStream): TPropertyList;
begin
  Result := Self.Create;
  Result.LoadFromStream(AStream);
end;

function TPropertyList.GetAsArray: TPropertyListArray;
begin
  Result := fRootNode.AsArray;
end;

function TPropertyList.GetAsBoolean: boolean;
begin
  Result := fRootNode.AsBoolean;
end;

function TPropertyList.GetAsData: TPropertyListData;
begin
  Result := fRootNode.AsData;
end;

function TPropertyList.GetAsDateTime: TDateTime;
begin
  Result := fRootNode.AsDateTime;
end;

function TPropertyList.GetAsDictionary: TPropertyListDictionary;
begin
  Result := fRootNode.AsDictionary;
end;

function TPropertyList.GetAsKey: string;
begin
  Result := fRootNode.AsKey;
end;

function TPropertyList.GetAsReal: double;
begin
  Result := fRootNode.AsReal;
end;

function TPropertyList.GetAsString: string;
begin
  Result := fRootNode.AsString;
end;

function TPropertyList.GetAsUniqueIdentifier: UInt64;
begin
  Result := fRootNode.AsUniqueIdentifier;
end;

function TPropertyList.GetAsUnsignedInteger: UInt64;
begin
  Result := fRootNode.AsUnsignedInteger;
end;

function TPropertyList.GetIsScalar: boolean;
begin
  Result := fRootNode.IsScalar;
end;

function TPropertyList.GetNodeType: TPropertyListNodeType;
begin
  Result := fRootNode.NodeType;
end;

function TPropertyList.GetParentNode: TPropertyListNode;
begin
  Result := fRootNode.ParentNode;
end;

procedure TPropertyList.LoadFromFile(const AFilename: string);
begin
  FreeAndNil(fRootNode);
  fRootNode := fPersist.LoadFromFile(AFilename);
end;

procedure TPropertyList.LoadFromNative(APList: plist_t);
begin
  FreeAndNil(fRootNode);
  fRootNode := fPersist.LoadFromNative(APList);
end;

procedure TPropertyList.LoadFromStream(AStream: TStream);
begin
  FreeAndNil(fRootNode);
  fRootNode := fPersist.LoadFromStream(AStream);
end;

procedure TPropertyList.LoadFromBuffer(const AData: TBytes);
begin
  FreeAndNil(fRootNode);
  fRootNode := fPersist.LoadFromBuffer(AData);
end;

procedure TPropertyList.SaveToFileBinary(const AFilename: string);
begin
  fPersist.SaveToFileBinary(AFilename, fRootNode);
end;

procedure TPropertyList.SaveToFileXml(const AFilename: string);
begin
  fPersist.SaveToFileXml(AFilename, fRootNode);
end;

function TPropertyList.SaveToNative: plist_t;
begin
  Result := fPersist.SaveToNative(fRootNode);
end;

procedure TPropertyList.SaveToStreamBinary(AStream: TStream);
begin
  fPersist.SaveToStreamBinary(AStream, fRootNode);
end;

procedure TPropertyList.SaveToStreamXml(AStream: TStream);
begin
  fPersist.SaveToStreamXml(AStream, fRootNode);
end;

procedure TPropertyList.SetAsBoolean(AValue: boolean);
begin
  fRootNode.AsBoolean := AValue;
end;

procedure TPropertyList.SetAsDateTime(const AValue: TDateTime);
begin
  fRootNode.AsDateTime := AValue;
end;

procedure TPropertyList.SetAsKey(const AValue: string);
begin
  fRootNode.AsKey := AValue;
end;

procedure TPropertyList.SetAsReal(const AValue: double);
begin
  fRootNode.AsReal := AValue;
end;

procedure TPropertyList.SetAsString(const AValue: string);
begin
  fRootNode.AsString := AValue;
end;

procedure TPropertyList.SetAsUniqueIdentifier(const AValue: UInt64);
begin
  fRootNode.AsUniqueIdentifier := AValue;
end;

procedure TPropertyList.SetAsUnsignedInteger(const AValue: UInt64);
begin
  fRootNode.AsUnsignedInteger := AValue;
end;

procedure TPropertyList.SetParentNode(AValue: TPropertyListNode);
begin
  fRootNode.ParentNode := AValue;
end;

function TPropertyList.ToString: string;
begin
  Result := fRootNode.ToString;
end;

end.
