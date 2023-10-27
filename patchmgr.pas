unit patchmgr;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, common, servermgr, FileUtil, Contnrs, rez, IniFiles;

const
  PATCHMGR_NOREZ = 'NOREZ';

type

  TPatchMgrCallback = procedure(bSuccess: Boolean; strInfo: String; strError: String);

  { TDiff }

  TDiff = class(TObject)
    m_nOffset: Int64;
    m_DiffStream: TMemoryStream;
  public
    property Offset: Int64 read m_nOffset write m_nOffset;
    property DiffStream: TMemoryStream read m_DiffStream write m_DiffStream;
    constructor Create;
    destructor Destroy; override;
  end;

  { TPatchInfo }

  TPatchInfo = class(TObject)
  private
    m_strRez: string;
    m_strFilename: string;
    m_nResize: Int64;
    m_DiffList: TFPObjectList;
  public
    property DiffList: TFPObjectList read m_DiffList write m_DiffList;
    property Rez: string read m_strRez write m_strRez;
    property Filename: string read m_strFilename write m_strFilename;
    property Resize: Int64 read m_nResize write m_nResize;
    constructor Create;
    destructor Destroy; override;
  end;

  { TExtFile }

  TExtFile = class(TObject)
  private
    m_strName: string;
    m_strDest: string;
  public
    property Name: string read m_strName write m_strName;
    property Dest: string read m_strDest write m_strDest;
  end;

  { TPatchList }

  TPatchList = class(TObject)
  private
    m_nVersion: Integer;
    m_nMode: Integer;
    m_pPatches: TFPObjectList;
    m_pExtFiles: TFPObjectList;
  public
    property Version: Integer read m_nVersion write m_nVersion;
    property Mode: Integer read m_nMode write m_nMode;
    property Patches: TFPObjectList read m_pPatches write m_pPatches;
    property ExtFiles: TFPObjectList read m_pExtFiles write m_pExtFiles;
    function FindExtFile(strName: string): Integer;
    constructor Create;
    destructor Destroy; override;
  end;

  { TPatchModThread }

  TPatchModThread = class(TThread)
  private
    m_pRezMgr: TRezMgr;
    m_slRezMgrInfo: TStringList;
    m_slRezMgrError: TStringList;
    m_pCurMod: TModInfo;
    m_pPatchList: TPatchList;
    m_slPatchResult: TStringList;
    m_strLastRezName: string;
    m_bResult: Boolean;
    procedure RezCallbackInfo({%H-}strMsg: string);
    procedure RezCallbackError(strMsg: string);
  protected
    m_fuCallback: TPatchMgrCallback;
    procedure Execute; override;
    procedure SyncCallback;
    procedure CreateRezMgr(strRezFilename: string; strWorkingDir: string);
    procedure LoadRezMgr(bCreateGlobalMap: Boolean);
    procedure DestroyRezMgr;
    function ExtractFileToBuffer(strItemName: string; var dwSize: Cardinal; var pBuffer: PByte): Boolean;
    function ExtractRezItem(strRezName: string; strRezItem: string;
      strExtractDir: string; pPatchStream: TMemoryStream): Boolean;
    function PatchFile(CurMod: TModInfo; PatchInfo: TPatchInfo): Boolean;
    function PatchMod: Boolean;
  public
    property Callback: TPatchMgrCallback read m_fuCallback write m_fuCallback;
    constructor Create(CurMod: TModInfo; strPatchIni: string; slExtraFiles: TStringList);
    destructor Destroy; override;
  end;

procedure PatchMgr_LoadPatchIni(strFilename: string; PatchList: TPatchList);
function PatchMgr_ValidateMod(CurMod: TModInfo; var strError: string): Boolean;
procedure PatchMgr_CreateExtractDir(strFinalDir: string);

implementation

{ TPatchList }

function TPatchList.FindExtFile(strName: string): Integer;
var i: Integer;
    pEF: TExtFile;
begin
  for i := 0 to m_pExtFiles.Count - 1 do
  begin
    pEF := TExtFile(m_pExtFiles.Items[i]);
    if pEF.Name = strName then
      Exit(i);
  end;
  Result := -1;
end;

constructor TPatchList.Create;
begin
  m_pPatches := TFPObjectList.Create;
  m_pExtFiles := TFPObjectList.Create;
end;

destructor TPatchList.Destroy;
begin
  m_pPatches.Free;
  m_pExtFiles.Free;
  inherited Destroy;
end;

{ TDiff }

constructor TDiff.Create;
begin
  m_DiffStream := TMemoryStream.Create;
end;

destructor TDiff.Destroy;
begin
  inherited Destroy;
  m_DiffStream.Free;
end;

{ TPatchInfo }

constructor TPatchInfo.Create;
begin
  m_DiffList := TFPObjectList.Create;
end;

destructor TPatchInfo.Destroy;
begin
  inherited Destroy;
  m_DiffList.Free;
end;


{ TPatchModThread }

procedure TPatchModThread.RezCallbackInfo(strMsg: string);
begin
  m_slRezMgrInfo.Add(strMsg);
end;

procedure TPatchModThread.RezCallbackError(strMsg: string);
begin
  m_slRezMgrError.Add(strMsg);
end;

procedure TPatchModThread.Execute;
begin
  try
    m_bResult := PatchMod;
  except on E: Exception do
    RezCallbackError(ExceptionCallStackToString(E));
  end;
  DestroyRezMgr;
  Synchronize(@SyncCallback);
end;

procedure TPatchModThread.SyncCallback;
begin
  m_fuCallback(m_bResult, m_slRezMgrInfo.Text, m_slRezMgrError.Text);
end;

procedure TPatchModThread.CreateRezMgr(strRezFilename: string; strWorkingDir: string);
var FS: TFileStream;
begin
  try
    FS := TFileStream.Create(PChar(strRezFilename), fmOpenRead);
  except on E: Exception do
    RezCallbackError(E.Message);
  end;
  m_pRezMgr := TRezMgr.Create(FS, @RezCallbackInfo, @RezCallbackError, PChar(strWorkingDir), '\');
end;

procedure TPatchModThread.LoadRezMgr(bCreateGlobalMap: Boolean);
begin
  if m_pRezMgr <> nil then
    m_pRezMgr.Load(bCreateGlobalMap);
end;

function TPatchModThread.ExtractFileToBuffer(strItemName: string; var dwSize: Cardinal; var pBuffer: PByte): Boolean;
var pRezItem: TRezItem;
begin
  Result := False;
  if m_pRezMgr = nil then
    Exit;

  pRezItem := TRezItem(m_pRezMgr.GlobalMap.Items[strItemName]);
  if pRezItem <> nil then
  begin
    dwSize := pRezItem.m_dwSize;
    m_pRezMgr.Stream.Seek(pRezItem.m_dwFilePos, soBeginning);
    pBuffer := GetMem(dwSize);
    m_pRezMgr.Stream.ReadBuffer(pBuffer^, dwSize);
    Result := True;
  end
  else
  begin
    RezCallbackError(Format(C_ERR_ITEM_NOT_FOUND, [strItemName]));
  end;
end;

procedure TPatchModThread.DestroyRezMgr;
begin
  if m_pRezMgr <> nil then
  begin
    m_pRezMgr.Stream.Free;
    FreeAndNil(m_pRezMgr);
  end;
end;

function TPatchModThread.ExtractRezItem(strRezName: string; strRezItem: string;
  strExtractDir: string; pPatchStream: TMemoryStream): Boolean;
var dwItemSize: Cardinal = 0;
    pItemBuffer: PByte = nil;
begin
  Result := True;

  if not FileExists(strRezName) then
  begin
    RezCallbackError(Format('ExtractRezItem - file not found [%s]', [strRezName]));
    Exit(False);
  end;

  m_slRezMgrError.Clear;

  if (m_strLastRezName = '') or (strRezName <> m_strLastRezName) then
  begin
    DestroyRezMgr;
    CreateRezMgr(strRezName, strExtractDir);

    if m_slRezMgrError.Count > 0 then
    begin
      RezCallbackError(Format('ExtractRezItem - errors on creating REZ manager [%s]: %s',
        [strRezName, m_slRezMgrError.Strings[m_slRezMgrError.Count - 1]]));
      DestroyRezMgr;
      Exit(False);
    end;

    LoadRezMgr(True);
    m_strLastRezName := strRezName;

    if m_slRezMgrError.Count > 0 then
    begin
      RezCallbackError(Format('ExtractRezItem - errors on loading file [%s]: %s',
        [strRezName, m_slRezMgrError.Strings[m_slRezMgrError.Count - 1]]));
      DestroyRezMgr;
      Exit(False);
    end;
  end;

  if ExtractFileToBuffer(strRezItem, dwItemSize, pItemBuffer) then
  begin
    pPatchStream.WriteBuffer(pItemBuffer^, dwItemSize);
    Freemem(pItemBuffer);
  end
  else
  begin
    if m_slRezMgrError.Count > 0 then
    begin
      RezCallbackError(Format('ExtractRezItem - errors on extracting item [%s] from [%s]: %s',
        [strRezItem, strRezName, m_slRezMgrError.Strings[m_slRezMgrError.Count - 1]]));
    end;
    DestroyRezMgr;
    Exit(False);
  end;
end;

function TPatchModThread.PatchFile(CurMod: TModInfo; PatchInfo: TPatchInfo): Boolean;
var PatchStream: TMemoryStream;
    i: Integer;
    Diff: TDiff;
    strRezFilename: string;
    strExtractDirFinal: string;
    strWorkingDir: string;
    strExtractFilename: string;
    strOldBytes: string;
    strNewBytes: string;
begin
  Result := True;

  if PatchInfo.Rez <> PATCHMGR_NOREZ then
  begin
    strRezFilename := g_strGameDir + PatchInfo.Rez;
    strWorkingDir := g_strFixesDir + CurMod.Name;
    strExtractFilename := strWorkingDir + '\' + PatchInfo.Filename;
    strExtractDirFinal := ExtractFileDir(strExtractFilename);

    PatchMgr_CreateExtractDir(strExtractDirFinal);

    PatchStream := TMemoryStream.Create;
    if not ExtractRezItem(strRezFilename, PatchInfo.Filename, strWorkingDir, PatchStream) then
      Exit(False);
  end
  else
  begin
    strExtractFilename := g_strGameDir + PatchInfo.Filename;

    PatchStream := TMemoryStream.Create;
    PatchStream.LoadFromFile(strExtractFilename);
  end;

  if PatchInfo.Resize <> -1 then
  begin
    PatchStream.SetSize(PatchInfo.Resize);
    RezCallbackInfo(Format('PatchFile - File resized [%s, %d bytes, %d bytes]',
      [strExtractFilename, PatchStream.Size, PatchInfo.Resize]));
  end;

  for i := 0 to PatchInfo.DiffList.Count-1 do
  begin
    Diff := TDiff(PatchInfo.DiffList.Items[i]);

    strOldBytes := MemToHex(PatchStream.Memory + Diff.Offset, Diff.DiffStream.Size);
    strNewBytes := MemToHex(Diff.DiffStream.Memory, Diff.DiffStream.Size);

    PatchStream.Seek(Diff.Offset, soFromBeginning);
    Diff.DiffStream.Seek(0, soFromBeginning);
    PatchStream.CopyFrom(Diff.DiffStream, Diff.DiffStream.Size);
    RezCallbackInfo(Format('PatchFile - File patched [%s <- %s] [%s / %.8X / %d bytes / %d bytes]',
      [strOldBytes, strNewBytes, strExtractFilename, Diff.Offset, Diff.DiffStream.Size, PatchStream.Size]));
  end;

  try
    PatchStream.SaveToFile(strExtractFilename);
  except
    on E: EFCreateError do
    begin
      RezCallbackError(E.Message);
      RezCallbackInfo(Format('PatchFile - EFCreateError occured when saving file [%s]',
        [strExtractFilename]));
    end;
  end;
  PatchStream.Free;
end;

function TPatchModThread.PatchMod: Boolean;
var i: Integer;
    PatchInfo: TPatchInfo;
begin
  Result := True;
  if m_pPatchList.Patches.Count > 0 then
  begin
    for i := 0 to m_pPatchList.Patches.Count - 1 do
    begin
      PatchInfo := TPatchInfo(m_pPatchList.Patches.Items[i]);
      if not PatchFile(m_pCurMod, PatchInfo) then Break;
      if PatchInfo.Rez <> PATCHMGR_NOREZ then
        m_slPatchResult.Add(PatchInfo.Filename);
    end;
    if m_slRezMgrError.Count > 0 then
    begin
      Result := False;
      m_slPatchResult.Strings[0] := '0';
    end;
    m_slPatchResult.SaveToFile(g_strFixesDir + m_pCurMod.Name + '.txt');
    DestroyRezMgr;
  end;
end;

constructor TPatchModThread.Create(CurMod: TModInfo; strPatchIni: string; slExtraFiles: TStringList);
var i, nIndex: Integer;
    strExtFilename, strExtDestination: string;
    pEF: TExtFile;
begin
  inherited Create(True);
  m_pCurMod := CurMod;
  m_pPatchList := TPatchList.Create;
  PatchMgr_LoadPatchIni(strPatchIni, m_pPatchList);
  m_slRezMgrInfo := TStringList.Create;
  m_slRezMgrError := TStringList.Create;
  m_slPatchResult := TStringList.Create;
  m_slPatchResult.Add(m_pPatchList.Version.ToString);

  //m_slPatchResult.AddStrings(slExtraFiles);
  for i := 0 to slExtraFiles.Count - 1 do
  begin
    nIndex := m_pPatchList.FindExtFile(slExtraFiles.Strings[i]);
    if nIndex > -1 then
    begin
      pEF := TExtFile(m_pPatchList.ExtFiles.Items[nIndex]);
      strExtFilename :=  g_strFixesDir + CurMod.Name + '\' + pEF.Name;
      strExtDestination := g_strGameDir + pEF.Dest;
      g_Logger.Debug('TPatchModThread.Create - ExtFile %s -> %s', [strExtFilename, strExtDestination]);
      ForceDirectories(ExtractFileDir(strExtDestination));
      CopyFile(strExtFilename, strExtDestination);
      DeleteFile(strExtFilename);
    end
    else
    begin
      m_slPatchResult.Add(slExtraFiles.Strings[i]);
    end;
  end;

  m_bResult := False;
end;

destructor TPatchModThread.Destroy;
begin
  m_pPatchList.Free;
  m_slRezMgrInfo.Free;
  m_slRezMgrError.Free;
  m_slPatchResult.Free;
  inherited Destroy;
end;

function PatchMgr_ValidateMod(CurMod: TModInfo; var strError: string): Boolean;
var slPatchResult: TStringList;
    strWorkingDir: string;
    i: Integer;
begin
  Result := True;
  strWorkingDir := g_strFixesDir + CurMod.Name;
  slPatchResult := TStringList.Create;
  try
    slPatchResult.LoadFromFile(g_strFixesDir + CurMod.Name + '.txt');
    if slPatchResult.Strings[0] = CurMod.PatchVersion.ToString then
    begin
      for i := 1 to slPatchResult.Count - 1 do
      begin
        if not slPatchResult.Strings[i].EndsWith('\') then
        begin
          if not FileExists(strWorkingDir + '\' + slPatchResult.Strings[i]) then
          begin
            Result := False;
            strError := Format('File "%s" does not exist', [slPatchResult.Strings[i]]);
            Break;
          end;
        end
        else
        begin
          if not DirectoryExists(strWorkingDir + '\' + slPatchResult.Strings[i]) then
          begin
            Result := False;
            strError := Format('Directory "%s" does not exist', [slPatchResult.Strings[i]]);
            Break;
          end;
        end;
      end;
    end
    else
    begin
      Result := False;
      strError := Format('Patch version %s <> %d', [slPatchResult.Strings[0], CurMod.PatchVersion]);
    end;
  except on E: Exception do
  begin
    Result := False;
    strError := E.Message;
  end;
  end;
  slPatchResult.Free;
end;

function PatchMgr_PatchIniReadOffset(Ini: TIniFile; nMode: Integer; nFileNum: Integer; nPatchNum: Integer): String;
begin
  if nMode = PATCH_MODE_INT then
    Result := Ini.ReadString(OINI_PATCH_PATCH, OINI_PATCH_OFFSET + IntToStr(nFileNum) + '_' + IntToStr(nPatchNum), '-1')
  else
    Result := '$' + Ini.ReadString(OINI_PATCH_PATCH, OINI_PATCH_OFFSET + IntToStr(nFileNum) + '_' + IntToStr(nPatchNum), '-1');
end;

procedure PatchMgr_LoadPatchIni(strFilename: string; PatchList: TPatchList);
var j, k: Integer;
    strName, strOffset: string;
    NewPI: TPatchInfo;
    Ini: TMemIniFile;
    NewDI: TDiff;
    NewEF: TExtFile;
begin
  j := 0;
  Ini := TMemIniFile.Create(strFilename);
  PatchList.Version := Ini.ReadInteger(OINI_PATCH_PATCH, OINI_PATCH_ACTUAL_VERSION, 1);
  PatchList.Mode := Ini.ReadInteger(OINI_PATCH_PATCH, OINI_PATCH_MODE, 0);
  strName := Ini.ReadString(OINI_PATCH_PATCH, OINI_PATCH_REZ + IntToStr(j), '');
  while strName <> '' do
  begin
    NewPI := TPatchInfo.Create;
    NewPI.Rez := strName;
    NewPI.Filename := Ini.ReadString(OINI_PATCH_PATCH, OINI_PATCH_FILENAME + IntToStr(j), '');
    NewPI.Resize := Ini.ReadInt64(OINI_PATCH_PATCH, OINI_PATCH_RESIZE + IntToStr(j), -1);

    k := 0;
    strOffset := PatchMgr_PatchIniReadOffset(Ini, PatchList.Mode, j, k);

    while (strOffset <> '-1') and (strOffset <> '$-1') do
    begin
      NewDI := TDiff.Create;
      NewDI.Offset := StrToInt64(strOffset);
      Ini.ReadBinaryStream(OINI_PATCH_PATCH, OINI_PATCH_DATA + IntToStr(j) + '_' + IntToStr(k), NewDI.DiffStream);

      NewPI.DiffList.Add(NewDI);
      g_Logger.Debug('PatchMgr_LoadPatchIni - Diff[%d, %d] %d - %d', [j, k, NewDI.Offset, NewDI.DiffStream.Size]);
      Inc(k, 1);
      strOffset := PatchMgr_PatchIniReadOffset(Ini, PatchList.Mode, j, k);
    end;

    PatchList.Patches.Add(NewPI);
    g_Logger.Debug('PatchMgr_LoadPatchIni - PatchInfo[%d] %s - %s - %d', [j, NewPI.Rez, NewPI.Filename, NewPI.Resize]);
    Inc(j, 1);
    strName := Ini.ReadString(OINI_PATCH_PATCH, OINI_PATCH_REZ + IntToStr(j), '');
  end;

  j := 0;
  strName := Ini.ReadString(OINI_PATCH_PATCH, OINI_PATCH_EXT_FILENAME + IntToStr(j), '');
  while strName <> '' do
  begin
    NewEF := TExtFile.Create;
    NewEF.Name := strName;
    NewEF.Dest := Ini.ReadString(OINI_PATCH_PATCH, OINI_PATCH_EXT_DESTINATION + IntToStr(j), ''); ;

    PatchList.ExtFiles.Add(NewEF);
    Inc(j, 1);
    strName := Ini.ReadString(OINI_PATCH_PATCH, OINI_PATCH_EXT_FILENAME + IntToStr(j), '');
  end;

  Ini.Free;
end;

procedure PatchMgr_CreateExtractDir(strFinalDir: string);
begin
  ForceDirectories(strFinalDir);
end;

end.

