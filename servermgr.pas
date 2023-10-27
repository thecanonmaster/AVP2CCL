unit servermgr;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, common, contnrs, IniFiles, Graphics, SynHTTPHelper, ExtCtrls, LCLType;

const
  SM_FEATURED = 0;
  SM_MASTER = 1;
  SM_FAVORITES = 2;

  RM_ALL = 0;
  RM_SPECIFIC = 1;

  SINI_IP = 'IP';
  SINI_DNS = 'DNS';
  SINI_PORT = 'Port';
  SINI_CUSTOMMOD = 'CustomMod';
  SINI_CMD = 'Cmd';
  SINI_COMMENT = 'Comment';
  SINI_CUSTOMCOMMENT = 'CustomComment';
  SINI_AO_NAME = 'AOName';
  SINI_AO_CHECKED = 'AOChecked';

  UDP_STATUS = '\status\';

  GSA_WITH_PW = ' +gsa 1 +gsa_ip %s +gsa_port %d +gsa_pw %s';
  GSA_NO_PW = ' +gsa 1 +gsa_ip %s +gsa_port %d';

type

  TAOItem = class(TObject)
    Title: string;
    Option: string;
    Description: string;
    IsDefault: Boolean;
    IsMandatory: Boolean;
    IsCustom: Boolean;
    IsChecked: Boolean;
    IsD3D7FixExtra: Boolean;
    Group: Integer;
  end;

  TAOItemLight = class(TObject)
    Name: string;
    Checked: Boolean;
  end;

  TFOItem = class(TObject)
    Title: string;
    Option: string;
  end;

  { TModInfo }

  TModInfo = class
  private
    m_AdvancedOptions: TFPObjectList;
    m_strName: string;
    m_strDescription: string;
    m_strFullDesc: string;
    m_strLink: string;
    m_strDefaultCmd: string;
    m_strCustomCmd: string;
    m_bPrimalHunt: Boolean;
    m_bInstalled: Boolean;
    m_bFullyCustom: Boolean;
    m_strPatchLink: string;
    m_nPatchVersion: Integer;
  public
    property AdvancedOptions: TFPObjectList read m_AdvancedOptions write m_AdvancedOptions;
    property Name: string read m_strName write m_strName;
    property Description: string read m_strDescription write m_strDescription;
    property FullDescription: string read m_strFullDesc write m_strFullDesc;
    property Link: string read m_strLink write m_strLink;
    property DefaultCmd: string read m_strDefaultCmd write m_strDefaultCmd;
    property CustomCmd: string read m_strCustomCmd write m_strCustomCmd;
    property PrimalHunt: Boolean read m_bPrimalHunt write m_bPrimalHunt;
    property Installed: Boolean read m_bInstalled write m_bInstalled;
    property FullyCustom: Boolean read m_bFullyCustom write m_bFullyCustom;
    property PatchLink: string read m_strPatchLink write m_strPatchLink;
    property PatchVersion: Integer read m_nPatchVersion write m_nPatchVersion;
    constructor Create; virtual;
    destructor Destroy; override;
  end;

  TBasicInfo = record
    strServerName: string;
    strNumPlayers: string;
    strMaxPlayers: string;
    strGameType: string;
    strMap: string;
  end;

  TPlayerInfo = record
    strName: string;
    strPing: string;
    nRace: Integer;
    strScore: string;
  end;

  { TServer }

  TServer = class(TObject)
    DNSName: string;
    IP: string;
    Port: Word;
    Address: string;
    Comment: string;
    CustomComment: string;
    ModVer: string;
    CustomModVer: string;
    Cmd: string;
    Favorite: Boolean;
    LastTime: DWORD;
    LastAlive: Boolean;
    RawInfo: string;
    ParsedInfo: TStringList;
    AOLightList: TFPObjectList;
    constructor Create; virtual;
    destructor Destroy; override;
  end;

var
  g_ServersFavorites: TFPObjectList;
  g_ServersFeatured: TFPObjectList;
  g_FastOptions: TFPObjectList;
  g_AOPassword: TAOItem = nil;
  g_AOWindowed: TAOItem = nil;
  g_ServersMaster: TFPObjectList;
  g_nMode: Integer = SM_MASTER;
  g_nRefreshMode: Integer;
  g_SelectedServer: TServer;
  g_ScriptServer: TServer;
  g_bWereRefreshed: array[0..SM_FAVORITES] of Boolean;
  g_Mods: TFPObjectList;
  g_IniFavorites: TMemIniFile = nil;

function ServerMgr_FindServer(strAddress: string): TServer;
function ServerMgr_FindServer(strIP: string; nPort: Word): TServer;
function ServerMgr_FindMasterListServer(strIP: string; nPort: Word): TServer;
function ServerMgr_FindFeaturedServer(strIP: string; nPort: Word): TServer;
function ServerMgr_FindFavoriteServer(strIP: string; nPort: Word): TServer;
function ServerMgr_FindFavoriteServer(strAddress: string): TServer;
function ServerMgr_AddFavoriteServer(Server: TServer; bSave: Boolean = False): TServer;
procedure ServerMgr_DeleteFavoriteServer(strAddress: string; bSave: Boolean = False);
function ServerMgr_GetNextDeadServer(var nPos: Integer): TServer;
procedure ServerMgr_GetBasicInfo(Server: TServer; var Data: TBasicInfo);
procedure ServerMgr_ResetLastAlive(Server: TServer);
procedure ServerMgr_GetPlayer(nIndex: Integer; Server: TServer; var Info: TPlayerInfo);
function ServerMgr_GetPlayer0031(nIndex: Integer; Server: TServer; slProps: TStringList; var slOut: TStringList): Boolean;
function ServerMgr_GetCurrentList(bDontLoadMS: Boolean = False): TFPObjectList;
procedure ServerMgr_SaveFavorites;
procedure ServerMgr_LoadFavorites;
function ServerMgr_LoadFeatured: Boolean;
function ServerMgr_CheckFeatured: Boolean;
function ServerMgr_LoadMS: Boolean;
procedure ServerMgr_Init;
procedure ServerMgr_Destroy;
function ServerMgr_ParseMSResponse(List: TStringList): Boolean;
procedure ServerMgr_WereRefreshed;
function ServerMgr_GetPingColor(nPing: Integer): TColor;
function ServerMgr_GetCurrentListDesc: string;
procedure ServerMgr_LoadAdvanced;
function ServerMgr_GetServerProp(Server: TServer; strProp: string; var nPos: Integer): string;
function ServerMgr_FindMod(strName: string): TModInfo;
function ServerMgr_FindAO(CurMod: TModInfo; strAOTitle: string): TAOItem;
function ServerMgr_GetAOString(Server: TServer; CurMod: TModInfo; GroupControl: TCheckGroup; strPassword: string; slD3D7FixExtraParams: TStringList): string;
function ServerMgr_GetAOStringForMod(GroupControl: TCheckGroup; CurMod: TModInfo; slD3D7FixExtraParams: TStringList): string;
function ServerMgr_GetAOLight(Server: TServer; strAOName: string): TAOItemLight;
procedure ServerMgr_LoadCustomMods;
procedure ServerMgr_SaveCustomMods(bSaveAO: Boolean = False);
procedure ServerMgr_GetAOCustomStatus(CurAO: TAOItem; var bCustom: Boolean; var bChecked: Boolean);

implementation

uses main, translation_consts;

function ServerMgr_GetPingColor(nPing: Integer): TColor;
begin
  case nPing of
    0..120: Result := clGreen;
    121..190: Result := clNavy;
    191..250: Result := RGBToColor(196, 125, 0);
    251..350: Result := RGBToColor(196, 69, 0);
  else
    Result := clRed;
  end;
end;

function ServerMgr_LoadFeatured: Boolean;
var Ini: TIniFile;
    List: TStringList;
    i: Integer;
    NewServer: TServer;
    FavServer: TServer;
    strTempDNS: String;
begin
  if g_OnlineIni = nil then Exit(False);
  Result := True;
  Ini := g_OnlineIni;
  List := TStringList.Create;
  Ini.ReadSections(List);
  g_ServersFeatured.Clear;
  for i := 0 to List.Count-1 do
  begin
    if Pos('Server', List.Strings[i]) <> 1 then Continue;
    NewServer := TServer.Create;
    strTempDNS := Ini.ReadString(List.Strings[i], SINI_DNS, '');

    if strTempDNS = '' then
      NewServer.DNSName := Ini.ReadString(List.Strings[i], SINI_IP, '127.0.0.1')
    else
      NewServer.DNSName := strTempDNS;

    NewServer.IP := UDPServer.ResolveName(NewServer.DNSName);
    NewServer.Port := Ini.ReadInteger(List.Strings[i], SINI_PORT, 27888);
    NewServer.Address := NewServer.IP + ':' + IntToStr(NewServer.Port);
    NewServer.Cmd := Ini.ReadString(List.Strings[i], SINI_CMD, '');
    NewServer.Comment := Ini.ReadString(List.Strings[i], SINI_COMMENT, '');

    FavServer := ServerMgr_FindFavoriteServer(NewServer.IP, NewServer.Port);

    if FavServer <> nil then
    begin
      NewServer.Favorite := True;
      NewServer.Cmd := FavServer.Cmd;

      if FavServer.CustomModVer <> '' then
        NewServer.ModVer := FavServer.CustomModVer;

      NewServer.CustomComment := FavServer.CustomComment;
    end
    else
    begin
      NewServer.Favorite := False;
    end;

    g_Logger.Info('ServerMgr_LoadFeatured - [%d] %s / %s [%s] [%s]', [i, NewServer.Comment, NewServer.Address, NewServer.ModVer, NewServer.Cmd]);
    g_ServersFeatured.Add(NewServer);
  end;
  List.Free;
end;

function ServerMgr_FindMod(strName: string): TModInfo;
var i: Integer;
    CurMod: TModInfo;
begin
  Result := nil;
  if (strName = '') or (strName = '-') then Exit(ServerMgr_FindMod('AVP2'));
  for i := 0 to g_Mods.Count-1 do
  begin
    CurMod := TModInfo(g_Mods.Items[i]);
    if CurMod.Name = strName then Exit(CurMod);
  end;
end;

function ServerMgr_FindAO(CurMod: TModInfo; strAOTitle: string): TAOItem;
var i: Integer;
    CurAO: TAOItem;
begin
  Result := nil;
  for i := 0 to CurMod.AdvancedOptions.Count-1 do
  begin
    CurAO := TAOItem(CurMod.AdvancedOptions.Items[i]);
    if strAOTitle = CurAO.Title then Exit(CurAO);
  end;
end;

function ServerMgr_GetAOString(Server: TServer; CurMod: TModInfo;
  GroupControl: TCheckGroup; strPassword: string;
  slD3D7FixExtraParams: TStringList): string;
var i: Integer;
    ModAO: TAOItem;
    SrvAO: TAOItemLight;
begin
  Result := '';

  if (Server.Favorite) and (Server.Cmd = '') and (not CurMod.FullyCustom) then
  begin
    for i := 0 to CurMod.AdvancedOptions.Count-1 do
    begin
      ModAO := TAOItem(CurMod.AdvancedOptions.Items[i]);
      SrvAO := ServerMgr_GetAOLight(Server, ModAO.Title);

      if (SrvAO <> nil) and (SrvAO.Checked) then
      begin
        if ModAO.IsD3D7FixExtra then
        begin
          slD3D7FixExtraParams.Add(ModAO.Option);
          Continue;
        end;
        Result := Result + ' ' + ModAO.Option;
      end;
    end;
  end;

  for i := 1 to GroupControl.Items.Count-1 do
  begin
    ModAO := TAOItem(GroupControl.Items.Objects[i]);

    if GroupControl.Checked[i] then
    begin
      if ModAO.IsD3D7FixExtra then
      begin
        slD3D7FixExtraParams.Add(ModAO.Option);
        Continue;
      end;
      Result := Result + ' ' + ModAO.Option;
    end;
  end;

  if (GroupControl.Items.Count > 0) and (GroupControl.Checked[0]) then
  begin
    Result := Result + Format(GSA_WITH_PW, [Server.IP, Server.Port, strPassword]);
  end
  else
  begin
    Result := Result + Format(GSA_NO_PW, [Server.IP, Server.Port]);
  end;
end;

function ServerMgr_GetAOStringForMod(GroupControl: TCheckGroup;
  CurMod: TModInfo; slD3D7FixExtraParams: TStringList): string;
var i: Integer;
    ModAO: TAOItem;
begin
  Result := '';

  if CurMod.FullyCustom then Exit;

  for i := 0 to GroupControl.Items.Count-1 do
  begin
    ModAO := TAOItem(GroupControl.Items.Objects[i]);

    if GroupControl.Checked[i] then
    begin
      if ModAO.IsD3D7FixExtra then
      begin
        slD3D7FixExtraParams.Add(ModAO.Option);
        Continue;
      end;
      Result := Result + ' ' + ModAO.Option;
    end;
  end;
end;

function ServerMgr_GetAOLight(Server: TServer; strAOName: string): TAOItemLight;
var AOLight: TAOItemLight;
    FavServer: TServer;
    i: Integer;
begin
  Result := nil;
  FavServer := ServerMgr_FindFavoriteServer(Server.IP, Server.Port);
  for i := 0 to FavServer.AOLightList.Count-1 do
  begin
    AOLight := TAOItemLight(FavServer.AOLightList.Items[i]);
    if AOLight.Name = strAOName then
    begin
      Result := AOLight;
      Exit;
    end;
  end;
end;

procedure ServerMgr_LoadCustomMods;
var Ini: TIniFile;
    List: TStringList;
    i, j: Integer;
    NewMod: TModInfo;
    strModName, strAO: string;
    NewAO: TAOItem;
begin
  Ini := g_IniFavorites;
  List := TStringList.Create;
  Ini.ReadSections(List);
  for i := 0 to List.Count-1 do
  begin
    if Pos(OINI_MOD, List.Strings[i]) <> 1 then Continue;
    strModName := Copy(List.Strings[i], 1 + Length(OINI_MOD), Length(List.Strings[i]) - Length(OINI_MOD));
    NewMod := ServerMgr_FindMod(strModName);
    if NewMod = nil then
    begin
      NewMod := TModInfo.Create;
      NewMod.FullyCustom := True;
      NewMod.Name := strModName;
      NewMod.Description := Ini.ReadString(List.Strings[i], OINI_MOD_DESC, '');
      NewMod.CustomCmd := Ini.ReadString(List.Strings[i], OINI_CUSTOM_CMD, '');
      g_Mods.Add(NewMod);
    end
    else
    begin
      NewMod.CustomCmd := Ini.ReadString(List.Strings[i], OINI_CUSTOM_CMD, '');
      NewMod.PrimalHunt := Ini.ReadBool(List.Strings[i], OINI_PRIMAL_HUNT, NewMod.PrimalHunt);

      j := 0;
      strAO := Ini.ReadString(List.Strings[i], OINI_AO_TITLE + IntToStr(j), '');
      while strAO <> '' do
      begin
        NewAO := ServerMgr_FindAO(NewMod, strAO);
        if NewAO <> nil then
        begin
          NewAO.IsCustom := True;
          NewAO.IsChecked := Ini.ReadBool(List.Strings[i], OINI_AO_CHECKED + IntToStr(j), False);
        end;
        Inc(j, 1);
        strAO := Ini.ReadString(List.Strings[i], OINI_AO_TITLE + IntToStr(j), '');
      end;

    end;
  end;
  List.Free;
end;

procedure ServerMgr_SaveCustomMods(bSaveAO: Boolean);
var Ini: TIniFile;
    List: TStringList;
    i, j, k: Integer;
    CurMod: TModInfo;
    CurAO: TAOItem;
    strModSection: string;
begin
  Ini := g_IniFavorites;
  List := TStringList.Create;
  Ini.ReadSections(List);
  for i := 0 to List.Count-1 do
  begin
    if Pos(OINI_MOD, List.Strings[i]) <> 1 then Continue;
    Ini.EraseSection(List.Strings[i]);
  end;
  for i := 0 to g_Mods.Count-1 do
  begin
    CurMod := TModInfo(g_Mods.Items[i]);
    strModSection := OINI_MOD + CurMod.Name;
    if CurMod.CustomCmd <> '' then
    begin
      if CurMod.FullyCustom then
      begin
        Ini.WriteString(strModSection, OINI_MOD_DESC, CurMod.Description);
      end;
      Ini.WriteString(strModSection, OINI_CUSTOM_CMD, CurMod.CustomCmd);
      Ini.WriteBool(strModSection, OINI_PRIMAL_HUNT, CurMod.PrimalHunt);
    end;
    if bSaveAO then
    begin
      k := 0;
      for j := 0 to CurMod.AdvancedOptions.Count-1 do
      begin
        CurAO := TAOItem(CurMod.AdvancedOptions.Items[j]);
        if CurAO.IsCustom then
        begin
          Ini.WriteString(strModSection, OINI_AO_TITLE + IntToStr(k), CurAO.Title);
          Ini.WriteBool(strModSection, OINI_AO_CHECKED + IntToStr(k), CurAO.IsChecked);
          Inc(k, 1);
        end;
      end;
    end;
  end;
  List.Free;
end;

procedure ServerMgr_GetAOCustomStatus(CurAO: TAOItem; var bCustom: Boolean;
  var bChecked: Boolean);
begin
  bCustom := CurAO.IsCustom;
  bChecked := CurAO.IsDefault;
  if bCustom then
  begin
    bChecked := CurAO.IsChecked;
    if CurAO.IsDefault = bChecked then bCustom := False;
  end;
end;

procedure ServerMgr_LoadAdvanced;
var Ini: TIniFile;
    List: TStringList;
    i, j: Integer;
    NewMod: TModInfo;
    NewAO: TAOItem;
    NewFO: TFOItem;
    strAO, strFO: string;
begin
  Ini := g_OnlineIni;
  List := TStringList.Create;
  Ini.ReadSections(List);
  for i := 0 to List.Count-1 do
  begin
    if Pos(OINI_MOD, List.Strings[i]) <> 1 then Continue;
    NewMod := TModInfo.Create;
    NewMod.Name := Copy(List.Strings[i], 1 + Length(OINI_MOD), Length(List.Strings[i]) - Length(OINI_MOD));
    NewMod.Description := Ini.ReadString(List.Strings[i], OINI_MOD_DESC, '');
    NewMod.FullDescription := Ini.ReadString(List.Strings[i], OINI_MOD_FULLDESC, '');
    NewMod.Link := Ini.ReadString(List.Strings[i], OINI_MOD_LINK, '');

    NewMod.PatchLink := Ini.ReadString(List.Strings[i], OINI_PATCH_LINK, '');
    NewMod.PatchVersion := Ini.ReadInteger(List.Strings[i], OINI_PATCH_VERSION, 0);

    NewMod.DefaultCmd := Ini.ReadString(List.Strings[i], OINI_DEFAULT_CMD, '');
    NewMod.CustomCmd := Ini.ReadString(List.Strings[i], OINI_CUSTOM_CMD, '');
    NewMod.PrimalHunt := Ini.ReadBool(List.Strings[i], OINI_PRIMAL_HUNT, False);
    g_Logger.Info('ServerMgr_LoadAdvanced - [%d] %s', [i, NewMod.Name]);

    j := 0;
    strAO := Ini.ReadString(List.Strings[i], OINI_AO_TITLE + IntToStr(j), '');
    while strAO <> '' do
    begin
      NewAO := TAOItem.Create;
      NewAO.Title := strAO;
      NewAO.Option := Ini.ReadString(List.Strings[i], OINI_AO_OPTION + IntToStr(j), '');
      NewAO.Description := Ini.ReadString(List.Strings[i], OINI_AO_DESC + IntToStr(j), '');
      NewAO.IsDefault := Ini.ReadBool(List.Strings[i], OINI_AO_DEFAULT + IntToStr(j), False);
      NewAO.IsMandatory := Ini.ReadBool(List.Strings[i], OINI_AO_MANDATORY + IntToStr(j), False);
      NewAO.Group := Ini.ReadInteger(List.Strings[i], OINI_AO_GROUP + IntToStr(j), -1);
      NewAO.IsCustom := False;
      NewAO.IsChecked := False;

      if NewAO.Option.StartsWith(OINI_AO_D3D7FIX_EXTRA) then
      begin
        NewAO.Option := NewAO.Option.Substring(OINI_AO_D3D7FIX_EXTRA.Length);
        NewAO.IsD3D7FixExtra := True;
      end;

      NewMod.AdvancedOptions.Add(NewAO);
      g_Logger.Debug('ServerMgr_LoadAdvanced - AO[%d] %s - %s - %d - %d', [j, NewAO.Title, NewAO.Option, Integer(NewAO.IsDefault), Integer(NewAO.IsMandatory)]);
      Inc(j, 1);
      strAO := Ini.ReadString(List.Strings[i], OINI_AO_TITLE + IntToStr(j), '');
    end;

    g_Mods.Add(NewMod);
  end;

  g_AOPassword := TAOItem.Create;
  g_AOPassword.Title := 'Use Password';
  g_AOPassword.Option := '+gsa_pw %s';
  g_AOPassword.Description := '';
  g_AOPassword.Group := -1;
  g_AOPassword.IsDefault := False;
  g_AOPassword.IsMandatory := False;
  g_AOPassword.IsChecked := False;

  g_AOWindowed := TAOItem.Create;
  g_AOWindowed.Title := 'Windowed Mode';
  g_AOWindowed.Option := '+windowed 1';
  g_AOWindowed.Description := '';
  g_AOWindowed.Group := -1;
  g_AOWindowed.IsDefault := False;
  g_AOWindowed.IsMandatory := False;
  g_AOWindowed.IsChecked := False;

  j := 0;
  strFO := Ini.ReadString(OINI_FASTOPTIONS, OINI_FO_TITLE + IntToStr(j), '');
  while strFO <> '' do
  begin
    NewFO := TFOItem.Create;
    NewFO.Title := strFO;
    NewFO.Option := Ini.ReadString(OINI_FASTOPTIONS, OINI_FO_OPTION + IntToStr(j), '');
    g_FastOptions.Add(NewFO);
    Inc(j, 1);
    strFO := Ini.ReadString(OINI_FASTOPTIONS, OINI_FO_TITLE + IntToStr(j), '');
  end;

  List.Free;
end;

function ServerMgr_CheckFeatured: Boolean;
var CurServer, FavServer: TServer;
    i: Integer;
begin
  Result := True;
  for i := 0 to g_ServersFeatured.Count-1 do
  begin
    CurServer := TServer(g_ServersFeatured.Items[i]);
    FavServer := ServerMgr_FindFavoriteServer(CurServer.IP, CurServer.Port);
    if FavServer <> nil then
    begin
      CurServer.Favorite := True;
      CurServer.ModVer := '';
      CurServer.Cmd := FavServer.Cmd;

      if FavServer.CustomModVer <> '' then
        CurServer.CustomModVer := FavServer.CustomModVer;

      CurServer.CustomComment := FavServer.CustomComment;
    end
    else
    begin
      CurServer.Favorite := False;
      CurServer.ModVer := '';
      CurServer.Cmd := '';
      CurServer.CustomComment := '';
    end;
  end;
end;

procedure ServerMgr_EnrichMasterList(slList: TStringList);
var i, nIndex: Integer;
    Server: TServer;
begin
  for i := 0 to g_ServersFeatured.Count - 1 do
  begin
    Server := TServer(g_ServersFeatured.Items[i]);
    nIndex := slList.IndexOf(Server.Address);
    if nIndex = -1 then
      slList.Add(Server.Address);
  end;
end;

function ServerMgr_LoadMS: Boolean;
var i, nPos: Integer;
    NewServer: TServer;
    FavServer: TServer;
    SrvList: TStringList;
begin
  SrvList := TStringList.Create;
  g_ServersMaster.Clear;
  Result := ServerMgr_ParseMSResponse(SrvList);

  ServerMgr_EnrichMasterList(SrvList);

  for i := 0 to SrvList.Count-1 do
  begin

    nPos := Pos(':', SrvList.Strings[i]);
    if nPos > -1 then
    begin
      NewServer := TServer.Create;
      NewServer.IP := Copy(SrvList.Strings[i], 1, nPos-1);
      NewServer.DNSName := NewServer.IP;
      NewServer.Port := StrToInt(Copy(SrvList.Strings[i], nPos+1, Length(SrvList.Strings[i])));
      NewServer.Address := SrvList.Strings[i];
      NewServer.ModVer := '';
      NewServer.CustomModVer := '';
      NewServer.Cmd := '';
      NewServer.Comment := '';
      NewServer.CustomComment := '';

      FavServer := ServerMgr_FindFeaturedServer(NewServer.IP, NewServer.Port);

      if FavServer <> nil then
      begin
        NewServer.Comment := FavServer.Comment;
      end;

      FavServer := ServerMgr_FindFavoriteServer(NewServer.IP, NewServer.Port);

      if FavServer <> nil then
      begin
        NewServer.Favorite := True;

        if FavServer.CustomModVer <> '' then
          NewServer.CustomModVer := FavServer.CustomModVer;

        NewServer.Cmd := FavServer.Cmd;
        NewServer.CustomComment := FavServer.CustomComment;
      end
      else
      begin
        NewServer.Favorite := False;
      end;

      g_Logger.Info('ServerMgr_LoadMS -[%d] %s / %s [%s] [%s]', [i, NewServer.Comment, NewServer.Address, NewServer.ModVer, NewServer.Cmd]);
      g_ServersMaster.Add(NewServer);
    end;
  end;

  SrvList.Free;
end;

procedure ServerMgr_Init;
begin
  g_ServersFavorites := TFPObjectList.Create;
  g_ServersFeatured := TFPObjectList.Create;
  g_ServersMaster := TFPObjectList.Create;
  g_FastOptions := TFPObjectList.Create;
  g_Mods := TFPObjectList.Create;
end;

procedure ServerMgr_Destroy;
begin
  g_ServersFavorites.Free;
  g_ServersFeatured.Free;
  g_ServersMaster.Free;
  g_FastOptions.Free;
  g_Mods.Free;
  if g_IniFavorites <> nil then g_IniFavorites.Free;
  if g_AOPassword <> nil then g_AOPassword.Free;
  if g_AOWindowed <> nil then g_AOWindowed.Free;
  DestroyMSSocket;
end;

function ServerMgr_ParseMSResponse(List: TStringList): Boolean;
var Stream: TMemoryStream;
    nStartPos: Int64;
    nSize: Int64;
    strBuf: string = '';
begin
  Stream := TMemoryStream.Create;
  try
    if DownloadMSList(g_strMSAddress, g_strMSPost, Stream) then
    begin
      Stream.Position := 0;
      while Stream.ReadByte <> 1 do ;
      while Stream.ReadByte <> 1 do ;
      nStartPos := Stream.Position;
      while Stream.ReadByte <> 2 do ;
      nSize := Stream.Position - nStartPos - 1;
      SetLength(strBuf, nSize);
      Stream.Position := nStartPos;
      nSize := Stream.Read(strBuf[1], nSize);
      List.Text := strBuf;
      Result := True;
    end
    else
    begin
      Result := False;
    end;
  except on E: Exception do
  begin
    Result := False;
    g_Logger.Debug('ServerMgr_ParseMSResponse - connection reset');
    g_strRefreshAllError := 'Connection to Master Server was reset, please try again!';
  end;
  end;
  Stream.Free;
end;

procedure ServerMgr_WereRefreshed;
begin
  g_bWereRefreshed[g_nMode] := True;
end;

procedure ServerMgr_GetPlayer(nIndex: Integer; Server: TServer;
  var Info: TPlayerInfo);
var i, j: Integer;
begin
  // 'player_%d\%d-Player%d\race_%d\%d\score_%d\%d\ping_%d\%d\'
  Info.strName := '';
  i := Server.ParsedInfo.IndexOf('player_' + IntToStr(nIndex));
  if i > -1 then
  begin
    j := i + 1;
    if j > Server.ParsedInfo.Count - 1 then Exit;
    Info.strName := Server.ParsedInfo.Strings[j];
    i := Server.ParsedInfo.IndexOf('race_' + IntToStr(nIndex));
    if i > -1 then
    begin
      j := i + 1;
      if j > Server.ParsedInfo.Count - 1 then Exit;
      Info.nRace := SafeStrToInt(Server.ParsedInfo.Strings[j]) + 1;
      if (Info.nRace > 4) or (Info.nRace < 0) then Info.nRace := 0;
    end;
    i := Server.ParsedInfo.IndexOf('score_' + IntToStr(nIndex));
    if i > -1 then
    begin
      j := i + 1;
      if j > Server.ParsedInfo.Count - 1 then Exit;
      Info.strScore := Server.ParsedInfo.Strings[j];
    end;
    i := Server.ParsedInfo.IndexOf('ping_' + IntToStr(nIndex));
    if i > -1 then
    begin
      j := i + 1;
      if j > Server.ParsedInfo.Count - 1 then Exit;
      Info.strPing := Server.ParsedInfo.Strings[j];
    end;
  end;
end;

function ServerMgr_GetPlayer0031(nIndex: Integer; Server: TServer;
  slProps: TStringList; var slOut: TStringList): Boolean;
var i, j, k: Integer;
begin
  for i := 0 to slProps.Count - 1 do
  begin
    j := Server.ParsedInfo.IndexOf(Format(slProps.Strings[i], [nIndex]));
    if j > -1 then
    begin
      k := j + 1;
      if k > Server.ParsedInfo.Count - 1 then Exit(False);
      slOut.Add(Server.ParsedInfo.Strings[k]);
    end
    else
    begin
      Exit(False);
    end;
  end;
  Result := True;
end;

function ServerMgr_GetCurrentListDesc: string;
begin
  if g_nMode = SM_FAVORITES then
  begin
    Result := GetTranslatedString(IDS_FRM_MAIN_CONST_FAVORITES); //'Favorites';
  end
  else if g_nMode = SM_MASTER then
  begin
    Result := GetTranslatedString(IDS_FRM_MAIN_CONST_MASTER); //'Master Server';
  end
  else if g_nMode = SM_FEATURED then
  begin
    Result := GetTranslatedString(IDS_FRM_MAIN_CONST_FEATURED); //'Featured';
  end;
end;

function ServerMgr_GetCurrentList(bDontLoadMS: Boolean): TFPObjectList;
begin
  if g_nMode = SM_FAVORITES then
  begin
    Result := g_ServersFavorites;
  end
  else if g_nMode = SM_MASTER then
  begin
    if (not bDontLoadMS) and (not ServerMgr_LoadMS) then
      Result := nil
    else
      Result := g_ServersMaster;
  end
  else if g_nMode = SM_FEATURED then
  begin
    ServerMgr_CheckFeatured;
    Result := g_ServersFeatured;
  end;
end;

procedure ServerMgr_SaveFavorites;
var i, j: Integer;
    Ini: TMemIniFile;
    Server: TServer;
    strSection: string;
    List: TStringList;
    AOItem: TAOItemLight;
begin
  Ini := g_IniFavorites;
  List := TStringList.Create;
  Ini.ReadSections(List);
  for i := 0 to List.Count-1 do
  begin
    if Pos('Server', List.Strings[i]) <> 1 then Continue;
    Ini.EraseSection(List.Strings[i]);
  end;
  List.Free;
  for i := 0 to g_ServersFavorites.Count - 1 do
  begin
    Server := TServer(g_ServersFavorites.Items[i]);
    strSection := 'Server' + IntToStr(i);
    Ini.WriteString(strSection, SINI_IP, Server.DNSName);
    Ini.WriteInteger(strSection, SINI_PORT, Server.Port);
    Ini.WriteString(strSection, SINI_CUSTOMMOD, Server.CustomModVer);
    Ini.WriteString(strSection, SINI_CMD, Server.Cmd);
    Ini.WriteString(strSection, SINI_CUSTOMCOMMENT, Server.CustomComment);
    for j := 0 to Server.AOLightList.Count-1 do
    begin
      AOItem := TAOItemLight(Server.AOLightList.Items[j]);
      Ini.WriteString(strSection, SINI_AO_NAME + IntToStr(j), AOItem.Name);
      Ini.WriteBool(strSection, SINI_AO_CHECKED + IntToStr(j), AOItem.Checked);
    end;
  end;
  Ini.UpdateFile;
end;

procedure ServerMgr_LoadFavorites;
var Ini: TMemIniFile;
    List: TStringList;
    i, j: Integer;
    NewServer: TServer;
    NewAOLight: TAOItemLight;
    strTemp: string;
begin
  g_bWereRefreshed[SM_FEATURED] := False;
  g_bWereRefreshed[SM_MASTER] := False;
  g_bWereRefreshed[SM_FAVORITES] := False;
  g_IniFavorites := TMemIniFile.Create(g_strDataDir + 'favorites.ini');
  Ini := g_IniFavorites;
  List := TStringList.Create;
  Ini.ReadSections(List);
  for i := 0 to List.Count-1 do
  begin
    if Pos('Server', List.Strings[i]) <> 1 then Continue;
    NewServer := TServer.Create;
    NewServer.DNSName := Ini.ReadString(List.Strings[i], SINI_IP, '127.0.0.1');
    NewServer.IP := UDPServer.ResolveName(NewServer.DNSName);
    NewServer.Port := Ini.ReadInteger(List.Strings[i], SINI_PORT, 27888);
    NewServer.Address := NewServer.IP + ':' + IntToStr(NewServer.Port);
    NewServer.CustomModVer := Ini.ReadString(List.Strings[i], SINI_CUSTOMMOD, '');
    NewServer.Cmd := Ini.ReadString(List.Strings[i], SINI_CMD, '');
    NewServer.CustomComment := Ini.ReadString(List.Strings[i], SINI_CUSTOMCOMMENT, '');
    NewServer.Favorite := True;

    j := 0;
    strTemp := Ini.ReadString(List.Strings[i], SINI_AO_NAME + IntToStr(j), '');
    while strTemp <> '' do
    begin
      NewAOLight := TAOItemLight.Create;
      NewAOLight.Name := strTemp;
      NewAOLight.Checked := Ini.ReadBool(List.Strings[i], SINI_AO_CHECKED + IntToStr(j), False);;
      NewServer.AOLightList.Add(NewAOLight);
      Inc(j, 1);
      strTemp := Ini.ReadString(List.Strings[i], SINI_AO_NAME + IntToStr(j), '');
    end;

    g_Logger.Info('ServerMgr_LoadFavorites -[%d] %s / %s [%s] [%s]', [i, NewServer.CustomComment, NewServer.Address, NewServer.ModVer, NewServer.Cmd]);
    g_ServersFavorites.Add(NewServer);
  end;
  List.Free;
end;

function ServerMgr_FindServer(strAddress: string): TServer;
var i: Integer;
    Server: TServer;
    List: TFPObjectList;
begin
  Result := nil;
  if g_nMode = SM_FAVORITES then List := g_ServersFavorites
  else if g_nMode = SM_MASTER then List := g_ServersMaster
  else if g_nMode = SM_FEATURED then List := g_ServersFeatured;
  for i := 0 to List.Count - 1 do
  begin
    Server := TServer(List.Items[i]);
    if Server.Address = strAddress then
    begin
      Exit(Server);
    end;
  end;
end;

function ServerMgr_FindServer(strIP: string; nPort: Word): TServer;
var i: Integer;
    Server: TServer;
    List: TFPObjectList;
begin
  Result := nil;
  if g_nMode = SM_FAVORITES then List := g_ServersFavorites
  else if g_nMode = SM_MASTER then List := g_ServersMaster
  else if g_nMode = SM_FEATURED then List := g_ServersFeatured;
  for i := 0 to List.Count - 1 do
  begin
    Server := TServer(List.Items[i]);
    if (Server.IP = strIP) and (Server.Port = nPort) then
    begin
      Exit(Server);
    end;
  end;
end;

function ServerMgr_GetServerProp(Server: TServer; strProp: string; var nPos: Integer): string;
begin
  nPos := Server.ParsedInfo.IndexOf(strProp);
  if nPos > -1 then Result := Server.ParsedInfo.Strings[nPos+1];
end;

procedure ServerMgr_GetBasicInfo(Server: TServer; var Data: TBasicInfo);
var i: Integer;
begin
  i := Server.ParsedInfo.IndexOf('hostname');
  if i > -1 then Data.strServerName := Server.ParsedInfo.Strings[i+1];
  i := Server.ParsedInfo.IndexOf('numplayers');
  if i > -1 then Data.strNumPlayers := Server.ParsedInfo.Strings[i+1];
  i := Server.ParsedInfo.IndexOf('maxplayers');
  if i > -1 then Data.strMaxPlayers := Server.ParsedInfo.Strings[i+1];
  i := Server.ParsedInfo.IndexOf('gametype');
  if i > -1 then Data.strGameType := Server.ParsedInfo.Strings[i+1];
  i := Server.ParsedInfo.IndexOf('mapname');
  if i > -1 then Data.strMap := Server.ParsedInfo.Strings[i+1];
end;

procedure ServerMgr_ResetLastAlive(Server: TServer);
var i: Integer;
    CurrentServer: TServer;
    List: TFPObjectList;
begin
  if g_nMode = SM_FAVORITES then List := g_ServersFavorites
  else if g_nMode = SM_MASTER then List := g_ServersMaster
  else if g_nMode = SM_FEATURED then List := g_ServersFeatured;
  for i := 0 to List.Count - 1 do
  begin
    CurrentServer := TServer(List.Items[i]);
    if (Server = nil) or (Server = CurrentServer) then
       CurrentServer.LastAlive := False;
  end;
end;

function ServerMgr_FindMasterListServer(strIP: string; nPort: Word): TServer;
var i: Integer;
    Server: TServer;
begin
  Result := nil;
  for i := 0 to g_ServersMaster.Count - 1 do
  begin
    Server := TServer(g_ServersMaster.Items[i]);
    if (Server.IP = strIP) and (Server.Port = nPort) then
    begin
      Exit(Server);
    end;
  end;
end;

function ServerMgr_FindFeaturedServer(strIP: string; nPort: Word): TServer;
var i: Integer;
    Server: TServer;
begin
  Result := nil;
  for i := 0 to g_ServersFeatured.Count - 1 do
  begin
    Server := TServer(g_ServersFeatured.Items[i]);
    if (Server.IP = strIP) and (Server.Port = nPort) then
    begin
      Exit(Server);
    end;
  end;
end;

function ServerMgr_FindFavoriteServer(strIP: string; nPort: Word): TServer;
var i: Integer;
    Server: TServer;
begin
  Result := nil;
  for i := 0 to g_ServersFavorites.Count - 1 do
  begin
    Server := TServer(g_ServersFavorites.Items[i]);
    if (Server.IP = strIP) and (Server.Port = nPort) then
    begin
      Exit(Server);
    end;
  end;
end;

function ServerMgr_FindFavoriteServer(strAddress: string): TServer;
var i: Integer;
    Server: TServer;
begin
  Result := nil;
  for i := 0 to g_ServersFavorites.Count - 1 do
  begin
    Server := TServer(g_ServersFavorites.Items[i]);
    if (Server.Address = strAddress) then
    begin
      Exit(Server);
    end;
  end;
end;

function ServerMgr_AddFavoriteServer(Server: TServer; bSave: Boolean): TServer;
var NewServer: TServer;
    AOLightItem, AOLightCopy: TAOItemLight;
    i: Integer;
begin
  NewServer := ServerMgr_FindFavoriteServer(Server.IP, Server.Port);

  if NewServer = nil then
  begin
    NewServer := TServer.Create;
    g_ServersFavorites.Add(NewServer);
  end;

  NewServer.DNSName := Server.DNSName;
  NewServer.IP := Server.IP;
  NewServer.Port := Server.Port;
  NewServer.Address := Server.Address;
  NewServer.ModVer := Server.ModVer;
  NewServer.CustomModVer := Server.CustomModVer;
  NewServer.Cmd := Server.Cmd;
  NewServer.CustomComment := Server.CustomComment;
  NewServer.Favorite := True;

  if NewServer <> Server then
  begin
    NewServer.AOLightList.Clear;
    for i := 0 to Server.AOLightList.Count-1 do
    begin
      AOLightCopy := TAOItemLight(Server.AOLightList.Items[i]);
      AOLightItem := TAOItemLight.Create;
      AOLightItem.Name := AOLightCopy.Name;
      AOLightItem.Checked := AOLightCopy.Checked;
      NewServer.AOLightList.Add(AOLightItem);
    end;
  end;

  Result := NewServer;
  g_Logger.Info('ServerMgr_AddFavoriteServer - %s / %s [%s] [%s]', [NewServer.CustomComment, NewServer.Address, NewServer.ModVer, NewServer.Cmd]);
  if bSave then ServerMgr_SaveFavorites;
end;

procedure ServerMgr_DeleteFavoriteServer(strAddress: string; bSave: Boolean);
var i: Integer;
    Server: TServer;
begin
  for i := 0 to g_ServersFavorites.Count - 1 do
  begin
    Server := TServer(g_ServersFavorites.Items[i]);
    if (Server.Address = strAddress) then
    begin
      g_ServersFavorites.Delete(i);
      if bSave then ServerMgr_SaveFavorites;
      Exit;
    end;
  end;
end;

function ServerMgr_GetNextDeadServer(var nPos: Integer): TServer;
var i: Integer;
    Server: TServer;
    List: TFPObjectList;
begin
  Result := nil;
  if g_nMode = SM_FAVORITES then List := g_ServersFavorites
  else if g_nMode = SM_MASTER then List := g_ServersMaster
  else if g_nMode = SM_FEATURED then List := g_ServersFeatured;
  for i := nPos to List.Count - 1 do
  begin
    Server := TServer(List.Items[i]);
    if not Server.LastAlive then
    begin
      nPos := i;
      Exit(Server);
    end;
  end;
end;

{ TModInfo }

constructor TModInfo.Create;
begin
  m_AdvancedOptions := TFPObjectList.Create;
end;

destructor TModInfo.Destroy;
begin
  inherited Destroy;
  m_AdvancedOptions.Free;
end;

{ TServer }

constructor TServer.Create;
begin
  ParsedInfo := TStringList.Create;
  ParsedInfo.StrictDelimiter := True;
  ParsedInfo.Delimiter := '\';
  ParsedInfo.CaseSensitive := True;
  AOLightList := TFPObjectList.Create;
end;

destructor TServer.Destroy;
begin
  ParsedInfo.Free;
  AOLightList.Free;
  inherited Destroy;
end;

end.

