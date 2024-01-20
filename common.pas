unit common;

//{$define CRYPTED_LANG}
{$mode objfpc}{$H+}

interface

uses
  Forms, Classes, SysUtils, eventlog, logger, IniFiles, Graphics, SynUDPServer, RegExpr,
  translation_consts, sha1, FileUtil, LCLType, StrUtils, Contnrs
{$ifdef CRYPTED_LANG}
  , BlowFish
{$endif}
  ;

const
  CRYPTED_LANG_READBUF = 1024;

  CSTR_YES = '+';
  CSTR_NO = '-';

  CCOL_PLA_PING = 0;
  CCOL_PLA_RACE = 1;
  CCOL_PLA_SCORE = 2;

  INI_MAIN = 'Main';
  INI_LANG = 'Lang';
  INI_AVP2DIR = 'GameDir';
  INI_PHDIR = 'GameDirPH';
  INI_LOGLEVEL = 'LogLevel';
  INI_LOGUDP = 'LogUDP';
  INI_OFFLINE = 'OfflineMode';
  INI_SM = 'ServerManager';
  INI_UDPPORT = 'LocalUPDPort';
  INI_TCPPORT = 'LocalTCPPort';
  INI_UDPTIMEOUT = 'UDPTimeout';
  INI_TCPTIMEOUT = 'TCPTimeout';
  INI_NICK = 'Nickname';
  INI_NEWS_HIDE = 'NewsHide';
  INI_MS = 'MasterServer';
  INI_MS_PROXY = 'UseProxy';
  INI_MS_PROXY_ADDRESS = 'ProxyAddress';
  INI_MS_POST = 'PostMessage';
  INI_MS_ADDRESS = 'Address';
  INI_MS_TIMEOUT = 'Timeout';
  INI_ONLINE = 'Online';
  INI_DEFAULT_DATA = 'DefaultData';
  INI_DATA = 'Data';
  INI_COLUMN = 'ColumnSetup';
  INI_CS_SERVER = 'ServerName';
  INI_CS_PING = 'Ping';
  INI_CS_PLAYERS = 'Players';
  INI_CS_MOD = 'Mod';
  INI_CS_TYPE = 'GameType';
  INI_CS_MAP = 'Map';
  INI_CS_ADDRESS = 'Address';
  INI_CS_COMMENT = 'UserComment';
  INI_CUSTOMIZATION = 'Customization';
  INI_CUST_FEATURED_FC = 'FeaturedFC';
  INI_CUST_MASTERSERVER_FC = 'MasterServerFC';
  INI_CUST_FAVORITES_FC = 'FavoritesFC';
  INI_CUST_TAB_POS_TOP = 'TabPositionTop';
  INI_CUST_AUTO_REFRESH = 'AutoRefresh';
  INI_CUST_AUTO_SORT = 'AutoSort';
  INI_CUST_UNLIMITED_RESIZE = 'UnlimitedResize';

  OINI_UPDATE = 'Update';
  OINI_LASTLINK = 'LastLink';
  OINI_LASTVERSION = 'LastVersion';
  OINI_D3D7FIX_VERSION = 'D3D7FixVersion';

  OINI_IMAGES = 'Images';
  OINI_ROOTLINK = 'RootLink';

  OINI_NEWS = 'News_';
  OINI_TITLE = 'Title';
  OINI_TEXT = 'Text';
  OINI_LINK = 'Link';

  OINI_D3D7FIX_OPTIONS = 'D3D7FixOptions';

  OINI_PATCH_PATCH = 'Patch';
  OINI_PATCH_ACTUAL_VERSION = 'Version';
  OINI_PATCH_MODE = 'Mode';
  OINI_PATCH_REZ = 'PatchRez';
  OINI_PATCH_FILENAME = 'Filename';
  OINI_PATCH_RESIZE = 'Resize';
  OINI_PATCH_OFFSET = 'Offset';
  OINI_PATCH_DATA = 'Data';
  OINI_PATCH_EXT_FILENAME = 'ExtFilename';
  OINI_PATCH_EXT_DESTINATION = 'ExtDestination';

  OINI_MOD = 'Mod_';
  OINI_MOD_DESC = 'Description';
  OINI_MOD_FULLDESC = 'FullDescription';
  OINI_MOD_LINK = 'Link';

  OINI_PATCH_VERSION = 'PatchVersion';
  OINI_PATCH_LINK = 'PatchLink';

  OINI_DEFAULT_CMD = 'DefaultCmd';
  OINI_CUSTOM_CMD = 'CustomCmd';
  OINI_PRIMAL_HUNT = 'PrimalHunt';
  OINI_AO_TITLE = 'AOTitle';
  OINI_AO_DESC = 'AODescription';
  OINI_AO_OPTION = 'AOOption';
  OINI_AO_DEFAULT = 'AODefault';
  OINI_AO_CHECKED = 'AOChecked';
  OINI_AO_MANDATORY = 'AOMandatory';
  OINI_AO_GROUP = 'AOGroup';
  OINI_AO_D3D7FIX_EXTRA = 'D3D7FixExtra|';

  OINI_FASTOPTIONS = 'FastOptions';
  OINI_FO_TITLE = 'FOTitle';
  OINI_FO_OPTION = 'FOOption';

  AVP2CMD_MODE_NONE = 0;
  AVP2CMD_MODE_KEY = 1;
  AVP2CMD_MODE_VALUE = 2;

  AVP2FIXES_DIR = 'CANON_FIXES\';
  D3DFIX_DLL_FILENAME = 'ltmsg.dll';
  D3D7FIX_PROFILE_VER = 'FixVersion';
  D3D7FIX_PROFILE_CMD = '+D3D7FixProfile';
  D3D7FIX_PROFILE_EX_CMD = '+D3D7FixProfileEx';

  ONLINE_CONFIG_FILENAME = 'onlineconfig.ini';
  ONLINE_SCRIPT_FILENAME = 'onlinescript.pas';

  CONFIG_FILENAME = 'config.ini';
  USER_CONFIG_FILENAME = 'userconfig.ini';

  LITHTECH_EXE = 'lithtech.exe';

  UNLIMITED_RESIZE_HEIGHT = 650;
  DEAD_ATTEMPTS_MAX = 1;

  MAX_ONLINE_MIRRORS = 8;

  D3DFIX_DLL_GET_VERSION = 1;

  D3D7O_TYPE_BYTE = 0;
  D3D7O_TYPE_FLOAT = 1;
  D3D7O_TYPE_STRING = 2;
  D3D7O_TYPE_DWORD = 3;
  D3D7O_TYPE_BYTE_STR = 'BYTE';
  D3D7O_TYPE_FLOAT_STR = 'FLOAT';
  D3D7O_TYPE_STRING_STR = 'STRING';
  D3D7O_TYPE_DWORD_STR = 'DWORD';

  PATCH_MODE_INT = 0;
  PATCH_MODE_HEX = 1;

  HEX_DIGITS: array[0..15] of Char = '0123456789ABCDEF';

type
  TServerColumns = (srvcServerName = 0, srvcPing, srvcPlayers, srvcMod, srvcGameType, srvcMap, srvcAddress, srvcUserComment, srvcMax);
  TGetD3D7FixVersion = procedure(szBuffer: PChar; nFullInfo: Integer); cdecl;
  TDynByteArray = array of Byte;

  TD3D7FixOption = class(TObject)
    Checked: Boolean;
    Hidden: Boolean;
    Mandatory: Boolean;
    Name: string;
    ID: Byte;
    OptionType: Byte;
    Description: string;
    OptionTypeStr: string;
    DefaultValue: string;
    Value: string;
  end;

  TD3DFixProfileGetOption = function(nIndex: Integer): TD3D7FixOption of object;
  TD3DFixProfileFilter = function(nIndex: Integer): Boolean of object;
  TD3DFixProfileGetValue = function(nIndex: Integer): string of object;

var
  g_strLauncherVersion: string = '0.0.4.0';
  g_strLauncherRC: string = '';
  g_slTranslateStrings: TStringList;
  g_strLang: string;
  g_Logger: TEventLogEx;
  g_strAppDir: string;
  g_strDataDir: string;
  g_DefaultImage: TPicture;
  g_NUConfigIni: TMemIniFile;
  g_ConfigIni: TMemIniFile;
  g_OnlineIni: TMemIniFile = nil;
  g_bMSProxy: Boolean;
  g_strMSProxyAddress: string;
  g_strMSAddress: string;
  g_strMSPost: string;
  g_nMSTimeout: Integer;
  g_strLocalUDPPort: string;
  g_strLocalTCPPort: string;
  g_nUDPTimeout: Integer;
  g_nTCPTimeout: Integer;
  g_nDefaultOnlineData: Integer = 0;
  g_astrOnlineData: array[0..MAX_ONLINE_MIRRORS - 1] of string;
  g_nOnlineIndexData: Integer = 0;
  g_strGameDir: string;
  g_strGameDirPH: string;
  g_strGameExe: string;
  g_strGameExePH: string;
  g_strUpdateDir: string;
  g_ColumnSetup: TBits;
  g_bOfflineMode: Boolean;
  g_bNewOfflineMode: Boolean = False;
  g_bOnlineResult: Boolean = False;
  g_strLastLink: string;
  g_strLastVersion: string = '0.0.0.1';
  g_strD3D7FixVersionExpected: string = '0.1';
  g_strImagesRootLink: string;
  g_nVersionCurrent: Integer;
  g_nVersionLast: Integer;
  g_bUpdateReady: Boolean = False;
  g_Application: TApplication;
  g_clrFeaturedFC: TColor;
  g_clrMasterServerFC: TColor;
  g_clrFavoritesFC: TColor;
  g_bTabPosTop: Boolean;
  g_bAutoRefresh: Boolean;
  g_bAutoSort: Boolean;
  g_bUnlimitedResize: Boolean;
  g_bHideNews: Boolean;
  g_bLogUDP: Boolean;
  g_bApplyPatches: Boolean = True;
  g_strRefreshAllError: string;
  g_ImagePreviewCache: TFileStream;
  g_ImagePreviewIndex: TFPDataHashTable;
  g_nServerClickDelay: Cardinal = 500;
  g_slD3D7FixOptions: TStringList;
  g_strHttpMyUserAgent: string = 'Mozilla/5.0 (Synapse)';
  g_strFixesDir: string;

function ExceptionCallStackToString(E: Exception): string;
procedure ShowExceptionCallStack(App: TApplication; E: Exception);
function IsAVP2Dir(S: string): Boolean;
function ParseAVP2CommandLine(strCmd: string; slParams: TStrings): Boolean;
procedure InitCommon(Application: TApplication);
procedure LoadTranslation;
procedure LoadConfig_D3D7FixAOOnly;
procedure LoadConfig;
procedure SaveConfig;
procedure SaveConfig_D3D7FixAOOnly;
procedure DestroyCommon;
procedure LoadUpdateInfo;
procedure LoadImageCacheVars;
procedure ParseD3D7FixOption(strValue: string; pOption: TD3D7FixOption);
procedure LoadD3D7FixOptions;
function GetNews(i: Integer; var strTitle: string; var strText: string; var strLink: string): Boolean;
function ConvertTranslatedString(szInput: string): string;
function GetTranslatedString(ID: TTranslateID): string;
function GetTranslatedString(ID: Integer): string;
function GetTranslatedStringPChar(ID: TTranslateID): PChar;
procedure SaveStringToFile(strString: string; strFilename: string);
function DynArray_Sha1Hash(Source: TDynByteArray; nLength: Cardinal): string;
procedure SaveResourceToStream(strName: string; MS: TMemoryStream);
procedure SaveResourceToStringList(strName: string; SL: TStrings);
procedure CleanupOldDirsAndFiles;
procedure CleanupImageCache;
function GetPositionInImageCache(strName: string): Integer;
function PlaceAVP2DirIntoPHCmd(strInput: string): string;
function GetD3D7FixVersion(bPrimalHunt: Boolean): string;
function MemToHex(P: Pointer; dwSize: Integer): string;
function StrToHex(S: string): string;
function CompileD3D7FixProfile(nItemsCount: Integer; GetOptionProc: TD3DFixProfileGetOption;
  FilterProc: TD3DFixProfileFilter; GetValueProc: TD3DFixProfileGetValue; slOverrides: TStringList): string;
function SafeStrToInt(S: string): Integer;
function SafeIntToStr(i: Integer): string;

implementation

uses main, debuginfo;

procedure SaveStringToFile(strString: string; strFilename: string);
var SL: TStringList;
begin
  SL := TStringList.Create;
  SL.Add(strString);
  SL.SaveToFile(strFilename);
  SL.Free;
end;

function ExceptionCallStackToString(E: Exception): string;
var i: Integer;
    Frames: PPointer;
begin
  Result := 'Unhandled exception! ' + LineEnding +
    'Stacktrace:' + LineEnding + LineEnding;
  if E <> nil then begin
    Result := Result + 'Exception class: ' + E.ClassName + LineEnding +
    'Message: ' + E.Message + LineEnding;
  end;
  Result := Result + BackTraceStrFunc(ExceptAddr);
  Frames := ExceptFrames;
  for i := 0 to ExceptFrameCount - 1 do
    Result := Result + LineEnding + BackTraceStrFunc(Frames[I]);
end;

procedure ShowExceptionCallStack(App: TApplication; E: Exception);
var strMsg: string;
begin
  strMsg := ExceptionCallStackToString(E);
  g_Logger.Error(strMsg);

  if frmDebug <> nil then
  begin
    frmDebug.Clear;
    frmDebug.Caption := GetTranslatedString(IDS_DEBUG_INFORMATION);
    frmDebug.mmoDebug.Lines.Text := strMsg;
    frmDebug.ShowModal;
  end
  else
  begin
    App.MessageBox(PChar(strMsg), 'Unhandled exception', MB_ICONERROR);
  end;
end;

function IsAVP2Dir(S: string): Boolean;
begin
  Result := FileExists(S + '\' + LITHTECH_EXE);
end;

function PairAVP2CommandLineParams(slInput: TStringList; slOutput: TStrings): Boolean;
var i: Integer;
    strKey: string;
begin
  strKey := '';
  i := 0;
  while i < slInput.Count do
  begin
    if strKey = '' then
    begin
      if (slInput.Strings[i][1] <> '-') and (slInput.Strings[i][1] <> '+') then Exit(False);
      strKey := slInput.Strings[i];
    end
    else
    begin
      if (slInput.Strings[i][1] = '-') or (slInput.Strings[i][1] = '+') then Exit(False);
      slOutput.Add(strKey + ' ' + slInput.Strings[i]);
      strKey := '';
    end;
    Inc(i, 1);
  end;
end;

function ParseAVP2CommandLine(strCmd: string; slParams: TStrings): Boolean;
var i, nStart, nLen: Integer;
    bStartSet: Boolean;
    strBuf: string;
begin
  nLen := Length(strCmd);
  i := 1;
  nStart := 1;
  bStartSet := False;
  while True do
  begin
    if i > nLen then
    begin
      if bStartSet then
      begin
        strBuf := Copy(strCmd, nStart, i - nStart);
        slParams.Add(strBuf);
      end;
      Break;
    end;
    if (strCmd[i] = ' ') or (strCmd[i] = #9) or
       (strCmd[i] = #10) or (strCmd[i] = #13) then
    begin
      if bStartSet then
      begin
        strBuf := Copy(strCmd, nStart, i - nStart);
        slParams.Add(strBuf);
        bStartSet := False;
      end;
    end
    else
    begin
      if not bStartSet then
      begin
        nStart := i;
        bStartSet := True;
      end;
    end;
    Inc(i, 1);
  end;
  Result := True;
end;

procedure InitCommon(Application: TApplication);
begin
  g_Application := Application;

  g_slTranslateStrings := TStringList.Create;
  g_ColumnSetup := TBits.Create;
  g_Logger := TEventLogEx.Create(nil);
  g_Logger.LogType := ltFile;
  g_Logger.RaiseExceptionOnError := True;
  g_Logger.Level := 3;
  g_strAppDir := ExtractFileDir(Application.ExeName) + '\';
  g_Logger.FileName := g_strAppDir + 'CanonLauncher.log';
  g_strDataDir := g_strAppDir + 'data\';
  g_strUpdateDir := g_strAppDir + 'update\';
  g_DefaultImage := TPicture.Create;
  g_DefaultImage.LoadFromResourceName(HInstance, 'DEFAULT_IMAGE');

  CleanupImageCache;
  g_ImagePreviewCache := TFileStream.Create(g_strDataDir + 'cache', fmCreate + fmOpenReadWrite);
  g_ImagePreviewCache.WriteByte(Ord('C'));
  g_ImagePreviewIndex := TFPDataHashTable.Create;

  g_slD3D7FixOptions := TStringList.Create;
  g_slD3D7FixOptions.OwnsObjects := True;

  g_Logger.Info('Program started...');
  g_Logger.Info('Program directory = %s', [g_strAppDir]);

  LoadConfig;
  LoadTranslation;
end;

procedure LoadTranslation;
var i: Integer;
    DecryptedLangStream: TMemoryStream;
{$ifdef CRYPTED_LANG}
  DeFishStream: TBlowFishDeCryptStream;
  CryptedLangStream, DecryptedLangStream: TMemoryStream;
  nReadCount: Integer;
  anBuffer: array[0..CRYPTED_LANG_READBUF] of Byte;
{$endif}

begin
{$ifdef CRYPTED_LANG}
  CryptedLangStream := TMemoryStream.Create;
  DecryptedLangStream := TMemoryStream.Create;
  DeFishStream := TBlowFishDeCryptStream.Create('Updater.log', CryptedLangStream);

  SaveResourceToStream(g_strLang, CryptedLangStream);
  repeat
    nReadCount := DeFishStream.Read(anBuffer{%H-}, CRYPTED_LANG_READBUF);
    DecryptedLangStream.WriteBuffer(anBuffer, nReadCount);
  until nReadCount < CRYPTED_LANG_READBUF;
  DecryptedLangStream.Seek(0, soFromBeginning);
  g_slTranslateStrings.LoadFromStream(DecryptedLangStream);

  DeFishStream.Free;
  DecryptedLangStream.Free;
  CryptedLangStream.Free;
{$else}
  DecryptedLangStream := TMemoryStream.Create;

  SaveResourceToStream(g_strLang, DecryptedLangStream);
  g_slTranslateStrings.LoadFromStream(DecryptedLangStream);

  DecryptedLangStream.Free;
{$endif}
  for i := 0 to g_slTranslateStrings.Count - 1 do
  begin
    g_slTranslateStrings.Strings[i] := ConvertTranslatedString(g_slTranslateStrings.Strings[i]);
  end;
end;

procedure LoadConfig_D3D7FixAOOnly;
var i, nIndex: Integer;
    slItems: TStringList;
    strValue: string;
    aParams: TStringArray;
    pOption: TD3D7FixOption;
begin
  nIndex := g_slD3D7FixOptions.IndexOf(D3D7FIX_PROFILE_VER);
  if nIndex > -1 then
  begin
    pOption := TD3D7FixOption(g_slD3D7FixOptions.Objects[nIndex]);
    pOption.Mandatory := True;
    pOption.DefaultValue := g_strD3D7FixVersionExpected;
    pOption.Value := g_strD3D7FixVersionExpected;
  end;

  slItems := TStringList.Create;
  g_ConfigIni.ReadSection(OINI_D3D7FIX_OPTIONS, slItems);
  for i := 0 to slItems.Count - 1 do
  begin
    strValue := g_ConfigIni.ReadString(OINI_D3D7FIX_OPTIONS, slItems.Strings[i], '0|0');
    aParams := strValue.Split(['|']);
    nIndex := g_slD3D7FixOptions.IndexOf(slItems.Strings[i]);
    if nIndex > -1 then
    begin
      pOption := TD3D7FixOption(g_slD3D7FixOptions.Objects[nIndex]);
      if aParams[0] = '1' then pOption.Checked := True;
      pOption.Value := aParams[1];
    end;
    SetLength(aParams, 0);
  end;
  slItems.Free;
end;

procedure LoadConfig;
var i: Integer;
begin
  g_NUConfigIni := TMemIniFile.Create(g_strDataDir + CONFIG_FILENAME);
  g_bLogUDP := g_NUConfigIni.ReadBool(INI_MAIN, INI_LOGUDP, False);
  g_Logger.Level := g_NUConfigIni.ReadInteger(INI_MAIN, INI_LOGLEVEL, 0);
  g_bOfflineMode := g_NUConfigIni.ReadBool(INI_MAIN, INI_OFFLINE, False);
  g_nDefaultOnlineData := g_NUConfigIni.ReadInt64(INI_ONLINE, INI_DEFAULT_DATA, 0);

  for i := 0 to MAX_ONLINE_MIRRORS - 1 do
    g_astrOnlineData[i] := g_NUConfigIni.ReadString(INI_ONLINE, INI_DATA + IntToStr(i), '');

  g_strMSAddress := g_NUConfigIni.ReadString(INI_MS, INI_MS_ADDRESS, '');
  g_strMSPost := g_NUConfigIni.ReadString(INI_MS, INI_MS_POST, '001');
  g_bMSProxy := g_NUConfigIni.ReadBool(INI_MS, INI_MS_PROXY, True);
  g_nMSTimeout := g_NUConfigIni.ReadInteger(INI_MS, INI_MS_TIMEOUT, 250000);
  g_NUConfigIni.Free;

  g_ConfigIni := TMemIniFile.Create(g_strDataDir + USER_CONFIG_FILENAME);
  g_strLocalUDPPort := g_ConfigIni.ReadString(INI_SM, INI_UDPPORT, '0');
  g_strLocalTCPPort := g_ConfigIni.ReadString(INI_SM, INI_TCPPORT, '0');
  g_nUDPTimeout := g_ConfigIni.ReadInteger(INI_SM, INI_UDPTIMEOUT, -1);
  g_nTCPTimeout := g_ConfigIni.ReadInteger(INI_SM, INI_TCPTIMEOUT, 5000);

  g_strLang := g_ConfigIni.ReadString(INI_MAIN, INI_LANG, 'English');
  g_strGameDir := g_ConfigIni.ReadString(INI_MAIN, INI_AVP2DIR, '');
  g_strGameDirPH := g_ConfigIni.ReadString(INI_MAIN, INI_PHDIR, '');
  if g_strGameDir <> '' then g_strGameDir := g_strGameDir + '\';
  if g_strGameDirPH <> '' then g_strGameDirPH := g_strGameDirPH + '\';

  g_strGameExe := g_strGameDir + LITHTECH_EXE;
  g_strGameExePH := g_strGameDirPH + LITHTECH_EXE;
  g_strFixesDir := g_strGameDir + AVP2FIXES_DIR;

  g_ColumnSetup.Bits[Integer(srvcServerName)] := g_ConfigIni.ReadBool(INI_COLUMN, INI_CS_SERVER, True);
  g_ColumnSetup.Bits[Integer(srvcPing)] := g_ConfigIni.ReadBool(INI_COLUMN, INI_CS_PING, True);
  g_ColumnSetup.Bits[Integer(srvcPlayers)] := g_ConfigIni.ReadBool(INI_COLUMN, INI_CS_PLAYERS, True);
  g_ColumnSetup.Bits[Integer(srvcMod)] := g_ConfigIni.ReadBool(INI_COLUMN, INI_CS_MOD, True);
  g_ColumnSetup.Bits[Integer(srvcGameType)] := g_ConfigIni.ReadBool(INI_COLUMN, INI_CS_TYPE, True);
  g_ColumnSetup.Bits[Integer(srvcMap)] := g_ConfigIni.ReadBool(INI_COLUMN, INI_CS_MAP, False);
  g_ColumnSetup.Bits[Integer(srvcAddress)] := g_ConfigIni.ReadBool(INI_COLUMN, INI_CS_ADDRESS, False);
  g_ColumnSetup.Bits[Integer(srvcUserComment)] := g_ConfigIni.ReadBool(INI_COLUMN, INI_CS_COMMENT, False);

  g_clrFeaturedFC := g_ConfigIni.ReadInt64(INI_CUSTOMIZATION, INI_CUST_FEATURED_FC, clNavy);
  g_clrMasterServerFC := g_ConfigIni.ReadInt64(INI_CUSTOMIZATION, INI_CUST_MASTERSERVER_FC, clBlack);
  g_clrFavoritesFC := g_ConfigIni.ReadInt64(INI_CUSTOMIZATION, INI_CUST_FAVORITES_FC, clMaroon);

  g_bTabPosTop := g_ConfigIni.ReadBool(INI_CUSTOMIZATION, INI_CUST_TAB_POS_TOP, False);
  g_bAutoRefresh := g_ConfigIni.ReadBool(INI_CUSTOMIZATION, INI_CUST_AUTO_REFRESH, False);
  g_bAutoSort := g_ConfigIni.ReadBool(INI_CUSTOMIZATION, INI_CUST_AUTO_SORT, False);
  g_bUnlimitedResize := g_ConfigIni.ReadBool(INI_CUSTOMIZATION, INI_CUST_UNLIMITED_RESIZE, False);
  g_bHideNews := g_ConfigIni.ReadBool(INI_CUSTOMIZATION, INI_NEWS_HIDE, False);

  for i := 0 to Integer(srvcMax) - 1 do
  begin
    g_Logger.Debug('LoadConfig - ColumnSetup %d = %s', [i, BoolToStr(g_ColumnSetup.Bits[i], True)]);
  end;

  UDPServer := TUDPServer.Create;
  UDPServer.Port := g_strLocalUDPPort;
  UDPServer.OnReceive := nil; // @UDPOnReceive;
  UDPServer.OnError := nil; //@UDPOnError;
end;

procedure SaveConfig;
begin
  g_ConfigIni.WriteString(INI_SM, INI_UDPPORT, g_strLocalUDPPort);
  g_ConfigIni.WriteString(INI_SM, INI_TCPPORT, g_strLocalTCPPort);
  g_ConfigIni.WriteString(INI_MAIN, INI_LANG, g_strLang);
  g_ConfigIni.WriteString(INI_MAIN, INI_AVP2DIR, ExtractFileDir(g_strGameDir));
  g_ConfigIni.WriteString(INI_MAIN, INI_PHDIR, ExtractFileDir(g_strGameDirPH));

  g_ConfigIni.WriteBool(INI_COLUMN, INI_CS_SERVER, g_ColumnSetup.Bits[Integer(srvcServerName)]);
  g_ConfigIni.WriteBool(INI_COLUMN, INI_CS_PING, g_ColumnSetup.Bits[Integer(srvcPing)]);
  g_ConfigIni.WriteBool(INI_COLUMN, INI_CS_PLAYERS, g_ColumnSetup.Bits[Integer(srvcPlayers)]);
  g_ConfigIni.WriteBool(INI_COLUMN, INI_CS_MOD, g_ColumnSetup.Bits[Integer(srvcMod)]);
  g_ConfigIni.WriteBool(INI_COLUMN, INI_CS_TYPE, g_ColumnSetup.Bits[Integer(srvcGameType)]);
  g_ConfigIni.WriteBool(INI_COLUMN, INI_CS_MAP, g_ColumnSetup.Bits[Integer(srvcMap)]);
  g_ConfigIni.WriteBool(INI_COLUMN, INI_CS_ADDRESS, g_ColumnSetup.Bits[Integer(srvcAddress)]);
  g_ConfigIni.WriteBool(INI_COLUMN, INI_CS_COMMENT, g_ColumnSetup.Bits[Integer(srvcUserComment)]);

  g_ConfigIni.WriteInt64(INI_CUSTOMIZATION, INI_CUST_FEATURED_FC, g_clrFeaturedFC);
  g_ConfigIni.WriteInt64(INI_CUSTOMIZATION, INI_CUST_MASTERSERVER_FC, g_clrMasterServerFC);
  g_ConfigIni.WriteInt64(INI_CUSTOMIZATION, INI_CUST_FAVORITES_FC, g_clrFavoritesFC);

  g_ConfigIni.WriteBool(INI_CUSTOMIZATION, INI_CUST_TAB_POS_TOP, g_bTabPosTop);
  g_ConfigIni.WriteBool(INI_CUSTOMIZATION, INI_CUST_AUTO_REFRESH, g_bAutoRefresh);
  g_ConfigIni.WriteBool(INI_CUSTOMIZATION, INI_CUST_AUTO_SORT, g_bAutoSort);
  g_ConfigIni.WriteBool(INI_CUSTOMIZATION, INI_NEWS_HIDE, g_bHideNews);
  g_ConfigIni.WriteBool(INI_CUSTOMIZATION, INI_CUST_UNLIMITED_RESIZE, g_bUnlimitedResize);

  g_ConfigIni.UpdateFile;
end;

procedure SaveConfig_D3D7FixAOOnly;
var i: Integer;
    pOption: TD3D7FixOption;
    strTemp: string;
begin
  g_ConfigIni.EraseSection(OINI_D3D7FIX_OPTIONS);
  for i := 0 to g_slD3D7FixOptions.Count - 1 do
  begin
    pOption := TD3D7FixOption(g_slD3D7FixOptions.Objects[i]);
    if (pOption.Checked) or (pOption.Value <> pOption.DefaultValue) then
    begin
      if pOption.Checked then
        strTemp := '1|'
      else
        strTemp := '0|';
      strTemp := strTemp + pOption.Value;
      g_ConfigIni.WriteString(OINI_D3D7FIX_OPTIONS, pOption.Name, strTemp);
    end;
  end;

  g_ConfigIni.UpdateFile;
end;

procedure DestroyCommon;
begin
  g_Logger.Level := 3;
  g_Logger.Info('Program stopped...');
  g_ColumnSetup.Free;
  g_ConfigIni.Free;
  g_DefaultImage.Free;
  g_ImagePreviewCache.Free;
  g_ImagePreviewIndex.Free;
  CleanupImageCache;
  g_slD3D7FixOptions.Free;
  if g_OnlineIni <> nil then g_OnlineIni.Free;
  g_slTranslateStrings.Free;
  g_Logger.Free;
end;

procedure LoadUpdateInfo;
begin
  g_strLastLink := g_OnlineIni.ReadString(OINI_UPDATE, OINI_LASTLINK, '');
  g_strLastVersion := g_OnlineIni.ReadString(OINI_UPDATE, OINI_LASTVERSION, '');
  g_strD3D7FixVersionExpected := g_OnlineIni.ReadString(OINI_UPDATE, OINI_D3D7FIX_VERSION, '');
end;

procedure LoadImageCacheVars;
begin
  g_strImagesRootLink := g_OnlineIni.ReadString(OINI_IMAGES, OINI_ROOTLINK, '');
end;

procedure ParseD3D7FixOption(strValue: string; pOption: TD3D7FixOption);
var aParams: TStringArray;
begin
  aParams := strValue.Split(['|']);
  pOption.Checked := False;
  pOption.Description := aParams[0];
  if aParams[1] = '0' then pOption.Hidden := True else pOption.Hidden := False;
  pOption.OptionTypeStr := aParams[2];

  if aParams[2] = D3D7O_TYPE_BYTE_STR then pOption.OptionType := D3D7O_TYPE_BYTE
  else if aParams[2] = D3D7O_TYPE_DWORD_STR then pOption.OptionType := D3D7O_TYPE_DWORD
  else if aParams[2] = D3D7O_TYPE_STRING_STR then pOption.OptionType := D3D7O_TYPE_STRING
  else if aParams[2] = D3D7O_TYPE_FLOAT_STR then pOption.OptionType := D3D7O_TYPE_FLOAT;

  pOption.Mandatory := False;
  pOption.DefaultValue := aParams[3];
  pOption.Value := pOption.DefaultValue;
  SetLength(aParams, 0);
end;

procedure LoadD3D7FixOptions;
var slItems: TStringList;
    i: Integer;
    pOption: TD3D7FixOption;
    strValue: string;
begin
  slItems := TStringList.Create;
  g_OnlineIni.ReadSection(OINI_D3D7FIX_OPTIONS, slItems);
  for i := 0 to slItems.Count - 1 do
  begin
    pOption := TD3D7FixOption.Create;
    pOption.ID := i;
    pOption.Name := slItems.Strings[i];
    strValue := g_OnlineIni.ReadString(OINI_D3D7FIX_OPTIONS, pOption.Name, 'No description|0|BYTE|0|');
    ParseD3D7FixOption(strValue, pOption);
    g_slD3D7FixOptions.AddObject(pOption.Name, pOption);
  end;
  slItems.Free;
end;

function GetNews(i: Integer; var strTitle: string; var strText: string;
  var strLink: string): Boolean;
var strSection: string;
    nLen, n: Integer;
begin
  Result := False;
  if g_OnlineIni <> nil then
  begin
    strSection := OINI_NEWS + IntToStr(i);
    strTitle := g_OnlineIni.ReadString(strSection, OINI_TITLE, '');
    strText := g_OnlineIni.ReadString(strSection, OINI_TEXT, '');
    nLen := Length(strText);
    for n := 2 to nLen - 1 do
    begin
      if (strText[n-1] = '^') and (strText[n] = '^') then
      begin
        strText[n-1] := #13;
        strText[n] := #10;
      end;
    end;
    strLink := g_OnlineIni.ReadString(strSection, OINI_LINK, ''); ;
    if strTitle <> '' then Result := True;
  end;
end;

function ConvertTranslatedString(szInput: string): string;
var i, nLen: Integer;
begin
  Result := szInput;
  if szInput[1] <> '^' then Exit(Result);
  Delete(Result, 1, 1);
  nLen := Length(Result);
  for i := 2 to nLen - 1 do
  begin
    if (Result[i-1] = '^') and (Result[i] = '^') then
    begin
      Result[i-1] := #13;
      Result[i] := #10;
    end;
  end;
end;

function GetTranslatedString(ID: TTranslateID): string;
begin
  Result := g_slTranslateStrings.Strings[Ord(ID)];
end;

function GetTranslatedString(ID: Integer): string;
begin
  Result := g_slTranslateStrings.Strings[ID];
end;

function GetTranslatedStringPChar(ID: TTranslateID): PChar;
begin
  Result := PChar(g_slTranslateStrings.Strings[Ord(ID)]);
end;

function DynArray_Sha1Hash(Source: TDynByteArray; nLength: Cardinal): string;
begin
  if nLength > 0 then
    Result := SHA1Print(SHA1Buffer(Source[0], nLength))
  else
    Result := 'NONE';
end;

procedure SaveResourceToStream(strName: string; MS: TMemoryStream);
var
  RS: TResourceStream;
begin
  RS := TResourceStream.Create(HInstance, strName, RT_RCDATA);
  MS.LoadFromStream(RS);
  RS.Free;
end;

procedure SaveResourceToStringList(strName: string; SL: TStrings);
var
  RS: TResourceStream;
begin
  RS := TResourceStream.Create(HInstance, strName, RT_RCDATA);
  SL.LoadFromStream(RS);
  RS.Free;
end;

procedure CleanupOldDirsAndFiles;
begin
  DeleteDirectory(g_strAppDir + 'sounds\', False);
  DeleteDirectory(g_strAppDir + 'images\', False);
  DeleteDirectory(g_strAppDir + 'lang\', False);
  DeleteFile(g_strDataDir + 'ltmsg.dll');
  DeleteFile(g_strDataDir + 'ltmsg.ini');
  DeleteFile(g_strDataDir + 'ltmsg.original');
  DeleteFile(g_strAppDir + 'RezMgrLW.dll');
  DeleteFile(g_strAppDir + 'Updater.exe');
  DeleteFile(g_strAppDir + 'Updater.log');
end;

procedure CleanupImageCache;
begin
  DeleteFile(g_strDataDir + 'cache');
end;

function GetPositionInImageCache(strName: string): Integer;
var
  P: Pointer;
begin
  P := g_ImagePreviewIndex.Items[strName];
  if P <> nil then
    Result := {%H-}Integer(P)
  else
    Result := - 1;
end;

function PlaceAVP2DirIntoPHCmd(strInput: string): string;
begin
  Result := ReplaceStr(strInput, '$GameDir$', ExtractFileDir(g_strGameDir));
end;

function GetD3D7FixVersion(bPrimalHunt: Boolean): string;
var hLib: TLibHandle;
    strLibFilename: string;
    strGameDir: string;
    Proc: TGetD3D7FixVersion;
    szBuffer: array[0..127] of Char;
begin
  Result := '';
  if not bPrimalHunt then
    strGameDir := g_strGameDir
  else
    strGameDir := g_strGameDirPH;

  if strGameDir = '' then Exit;

  strLibFilename := g_strGameDir + D3DFIX_DLL_FILENAME;
  if FileExists(strLibFilename) then
  begin
    hLib := SafeLoadLibrary(strLibFilename);
    Proc := TGetD3D7FixVersion(GetProcedureAddress(hLib, D3DFIX_DLL_GET_VERSION));
    if Proc <> nil then
    begin
      Proc(szBuffer, 0);
      Result := szBuffer;
    end;
    FreeLibrary(hLib);
  end;
end;

function MemToHex(P: Pointer; dwSize: Integer): string;
var i, nTemp, nByte: Integer;
begin
  Result := '';
  SetLength(Result, dwSize << 1);
  for i := 0 to dwSize - 1 do
  begin
    nByte := PByte(P + i)^;
    nTemp := 1 + (i << 1);
    Result[nTemp + 0] := HEX_DIGITS[nByte div 16];
    Result[nTemp + 1] := HEX_DIGITS[nByte mod 16];
  end;
end;

function StrToHex(S: string): string;
var i, nTemp: Integer;
    strTemp: string;
begin
  Result := '';
  SetLength(Result, Length(S) << 1);
  for i := 1 to Length(S) do
  begin
    strTemp := IntToHex(Ord(S[i]), 2);
    nTemp := 1 + ((i - 1) << 1);
    Result[nTemp + 0] := strTemp[1];
    Result[nTemp + 1] := strTemp[2];
  end;
end;

function D3D7FixOptionToString(pOption: TD3D7FixOption; strValue: string): string;
begin
  case pOption.OptionType of
    D3D7O_TYPE_BYTE: Result := IntToHex(pOption.ID, 2) + IntToHex(StrToInt(strValue), 2);
    D3D7O_TYPE_FLOAT, D3D7O_TYPE_STRING: Result := IntToHex(pOption.ID, 2) + IntToHex(Length(strValue), 2) + StrToHex(strValue);
    D3D7O_TYPE_DWORD: Result := IntToHex(pOption.ID, 2) + IntToHex(StrToInt(strValue), 8);
  end;
end;

function CompileD3D7FixProfile(nItemsCount: Integer; GetOptionProc: TD3DFixProfileGetOption;
  FilterProc: TD3DFixProfileFilter; GetValueProc: TD3DFixProfileGetValue; slOverrides: TStringList): string;
var i, nOverrideIndex: Integer;
    pOption: TD3D7FixOption;
    strTemp: string;
    bEmpty: Boolean;
begin
  bEmpty := True;
  Result := '';

  for i := 0 to nItemsCount - 1 do
  begin
    nOverrideIndex := -1;
    pOption := GetOptionProc(i);

    if slOverrides <> nil then
      nOverrideIndex := slOverrides.IndexOfObject(pOption);

    if (nOverrideIndex > -1) or FilterProc(i) then
    begin
      bEmpty := False;
      Break;
    end;
  end;

  if bEmpty then
    Exit;

  for i := 0 to nItemsCount - 1 do
  begin
    nOverrideIndex := -1;
    pOption := GetOptionProc(i);

    if slOverrides <> nil then
      nOverrideIndex := slOverrides.IndexOfObject(pOption);

    if (nOverrideIndex > -1) or FilterProc(i) or pOption.Mandatory then
    begin
      if nOverrideIndex > -1 then
        strTemp := slOverrides.Strings[nOverrideIndex]
      else
        strTemp := GetValueProc(i);

      Result := Result + D3D7FixOptionToString(pOption, strTemp);
    end;

    if (slOverrides <> nil) and (nOverrideIndex > -1) then
      slOverrides.Delete(nOverrideIndex);
  end;

  if slOverrides.Count > 0 then
  begin
    for i := 0 to slOverrides.Count - 1 do
    begin
      pOption := TD3D7FixOption(slOverrides.Objects[i]);
      Result := D3D7FixOptionToString(pOption, pOption.Value) + Result;
    end;
  end;
end;

function SafeStrToInt(S: string): Integer;
begin
  try
    Result := StrToInt(S);
  except
    on E: Exception do Result := 0;
  end;
end;

function SafeIntToStr(i: Integer): string;
begin
  try
    Result := IntToStr(i);
  except
    on E: Exception do Result := '0';
  end;
end;

end.

