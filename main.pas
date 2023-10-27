unit main;

{$mode objfpc}{$H+}

interface

uses
  windows, Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ComCtrls, Menus, StdCtrls, ExtCtrls, common, servermgr, SynUDPServer,
  mmsystem, contnrs, LCLType, UTF8Process, scriptmgr, SynHTTPHelper,
  patchmgr, RegExpr;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnOptionsMM: TButton;
    btnReset: TButton;
    btnRefreshAll: TButton;
    btnMasterServer: TButton;
    btnJoin: TButton;
    btnRefresh: TButton;
    btnOptions: TButton;
    btnFeatured: TButton;
    btnFavorites: TButton;
    btnHide: TButton;
    btnLaunchMod: TButton;
    btnResetMM: TButton;
    cgrpFastOptions: TCheckGroup;
    cgrpFastOptionsMM: TCheckGroup;
    edtJoinPassword: TEdit;
    gbSelected: TGroupBox;
    gbMapshot: TGroupBox;
    ilAll: TImageList;
    imgMapshot: TImage;
    lblJoinPassword: TLabel;
    lblInfo: TLabel;
    lblPing: TLabel;
    lblServer: TLabel;
    lvPlayers: TListView;
    lvMods: TListView;
    lvServers: TListView;
    mmiRemoveModPatches: TMenuItem;
    mmiDebugMsg: TMenuItem;
    mmiD3D7FixAO: TMenuItem;
    mmiD3D7Fix: TMenuItem;
    mmiSeparator5: TMenuItem;
    mmiInfoMod: TMenuItem;
    mmiDeleteMod: TMenuItem;
    mmiEditMod: TMenuItem;
    mmiAddMod: TMenuItem;
    mmiLaunchMod: TMenuItem;
    mmiPPMInfo: TMenuItem;
    mmiTitle: TMenuItem;
    mmiSeparator2: TMenuItem;
    mmiPPMFavorite: TMenuItem;
    mmiNews: TMenuItem;
    mmiPPMDelete: TMenuItem;
    mmiPPMAdd: TMenuItem;
    mmiPPMEdit: TMenuItem;
    mmiTrayExit: TMenuItem;
    mmiTrayShow: TMenuItem;
    mmiMarkFavorite: TMenuItem;
    mmiDelete: TMenuItem;
    mmiEdit: TMenuItem;
    mmiAdd: TMenuItem;
    mmiSeparator1: TMenuItem;
    mmiRefreshOnClick: TMenuItem;
    mmiRefreshAll: TMenuItem;
    mmiHide: TMenuItem;
    mmiSeparator: TMenuItem;
    mmiServerList: TMenuItem;
    mmiShow: TMenuItem;
    mmiSetup: TMenuItem;
    mmiAbout: TMenuItem;
    mmiHelp: TMenuItem;
    mmiExit: TMenuItem;
    mmiLauncher: TMenuItem;
    mmMenu: TMainMenu;
    pcMain: TPageControl;
    ppmMods: TPopupMenu;
    ppmServers: TPopupMenu;
    ppmTray: TPopupMenu;
    sbSimple: TStatusBar;
    splMain: TSplitter;
    tsModMgr: TTabSheet;
    tsServerInfo: TTabSheet;
    tiMain: TTrayIcon;
    tmrNews: TTimer;
    tmrUpdate: TTimer;
    tmrRefresh: TTimer;
    procedure btnAddModClick(Sender: TObject);
    procedure btnDeleteModClick(Sender: TObject);
    procedure btnEditModClick(Sender: TObject);
    procedure btnFavoritesClick(Sender: TObject);
    procedure btnFeaturedClick(Sender: TObject);
    procedure btnHideClick(Sender: TObject);
    procedure btnInfoModClick(Sender: TObject);
    procedure btnJoinClick(Sender: TObject);
    procedure btnLaunchModClick(Sender: TObject);
    procedure btnMasterServerClick(Sender: TObject);
    procedure btnOptionsClick(Sender: TObject);
    procedure btnOptionsMMClick(Sender: TObject);
    procedure btnRefreshAllClick(Sender: TObject);
    procedure imgMapshotClick(Sender: TObject);
    procedure lvModsClick(Sender: TObject);
    procedure lvModsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure lvServersClick(Sender: TObject);
    procedure lvServersSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure mmiD3D7FixAOClick(Sender: TObject);
    procedure mmiD3D7FixClick(Sender: TObject);
    procedure mmiDebugMsgClick(Sender: TObject);
    procedure mmiRemoveModPatchesClick(Sender: TObject);
    function RefreshDeadServers: Boolean;
    procedure btnRefreshClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure btnResetMMClick(Sender: TObject);
    procedure cgrpFastOptionsItemClick(Sender: TObject; Index: integer);
    procedure cgrpFastOptionsMMItemClick(Sender: TObject; Index: integer);
    procedure FormClose(Sender: TObject; var {%H-}CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lblServerClick(Sender: TObject);
    procedure lvServersColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvServersCompare(Sender: TObject; Item1, Item2: TListItem;
      {%H-}Data: Integer; var Compare: Integer);
    procedure mmiAddClick(Sender: TObject);
    procedure mmiDeleteClick(Sender: TObject);
    procedure mmiEditClick(Sender: TObject);
    procedure mmiHideClick(Sender: TObject);
    procedure mmiAboutClick(Sender: TObject);
    procedure mmiExitClick(Sender: TObject);
    procedure mmiMarkFavoriteClick(Sender: TObject);
    procedure mmiNewsClick(Sender: TObject);
    procedure mmiPPMInfoClick(Sender: TObject);
    procedure mmiRefreshAllClick(Sender: TObject);
    procedure mmiRefreshOnClickClick(Sender: TObject);
    procedure mmiShowClick(Sender: TObject);
    procedure mmiTrayExitClick(Sender: TObject);
    procedure mmiTrayShowClick(Sender: TObject);
    procedure tiMainClick(Sender: TObject);
    procedure tmrNewsTimer(Sender: TObject);
    procedure tmrRefreshTimer(Sender: TObject);
    procedure RefreshCooldownBegin(bHideList: Boolean);
    procedure RefreshCooldownEnd;
    procedure FillPlayerList(nPlayers: Integer; Server: TServer);
    procedure FillPlayerList0031(nPlayers: Integer; Server: TServer);
    procedure FillFastOptionsOld;
    procedure FillFastOptions;
    procedure FillFastOptionsMM(ListItem: TListItem; Selected: Boolean);
    procedure RestoreLastServerList;
    procedure ApplyColumnSetup;
    procedure tmrUpdateTimer(Sender: TObject);
    procedure ClearServerFastInfo;
    procedure Translate;
    procedure FillVersionPanel;
  private
    procedure CustomExceptionHandler(Sender: TObject; E: Exception);
    { private declarations }
  public
    { public declarations }
  end;

var
  frmMain: TfrmMain;
  UDPServer: TUDPServer;
  g_bStartup: Boolean = False;
  g_nSortedColumn: Integer;
  g_nDeadAttempts: Integer;
  g_bDescending: Boolean;
  g_CS: TRTLCriticalSection;
  g_nColumnWidth_Servers: array of Integer;
  g_ImagePreviewDownloader: TDownloadFileThread = nil;
  g_nLastServerSelect: Cardinal;

implementation

uses serverinfo, about, loading, setup, news, serverao, modoptions, downloader,
  modinfo, translation_consts, debuginfo, image_preview, d3d7fixao;

{$R *.lfm}

procedure ImagePreviewDownloadCallback(bSuccess: Boolean; Stream: TMemoryStream; {%H-}strErrorMsg: string; strData: String);
var SL: TStringList;
    BasicInfo: TBasicInfo;
begin
  SL := TStringList.Create;
  SplitRegExpr(';', strData, SL);

  if bSuccess then
  begin

    g_ImagePreviewCache.Seek(0, soEnd);
    g_ImagePreviewIndex.Items[SL.Strings[0]] := {%H-}Pointer(g_ImagePreviewCache.Position);
    g_ImagePreviewCache.CopyFrom(Stream, Stream.Size);
    Stream.Position := 0;

    if (g_SelectedServer <> nil) then
    begin
      ServerMgr_GetBasicInfo(g_SelectedServer, BasicInfo{%H-});
      if BasicInfo.strMap = SL.Strings[0] then
      begin
        frmMain.imgMapshot.Tag := 1;
        frmMain.imgMapshot.Picture.LoadFromStream(Stream);
      end;
    end;
  end
  else
  begin
    if (g_SelectedServer <> nil) then
    begin
      ServerMgr_GetBasicInfo(g_SelectedServer, BasicInfo{%H-});
      if BasicInfo.strMap = SL.Strings[0] then
      begin
        frmMain.imgMapshot.Tag := 0;
        frmMain.imgMapshot.Picture := g_DefaultImage;
      end;
    end;
  end;

  SL.Free;
end;

procedure ImagePreviewDownloadProgress({%H-}nMsg: Integer; {%H-}nData: Integer);
begin

end;

procedure StartImagePreviewDownload(strMap: string);
begin
  g_ImagePreviewDownloader := TDownloadFileThread.Create;
  g_ImagePreviewDownloader.FreeOnTerminate := False;
  g_ImagePreviewDownloader.Data := strMap;
  g_ImagePreviewDownloader.URLs.Add(g_strImagesRootLink + g_ImagePreviewDownloader.Data + '.jpg');
  SetLength(g_ImagePreviewDownloader.m_anValidityCheck, 2);
  g_ImagePreviewDownloader.m_anValidityCheck[0] := $FF;
  g_ImagePreviewDownloader.m_anValidityCheck[1] := $D8;
  g_ImagePreviewDownloader.Callback := @ImagePreviewDownloadCallback;
  g_ImagePreviewDownloader.ProgressCallback := @ImagePreviewDownloadProgress;
  g_ImagePreviewDownloader.Start;
end;

procedure StopImagePreviewDownload(bQuit: Boolean);
begin
  if g_ImagePreviewDownloader <> nil then
  begin
    if not g_ImagePreviewDownloader.Finished then
    begin
      g_ImagePreviewDownloader.FreeOnTerminate := True;
      if not bQuit then
      begin
        g_ImagePreviewDownloader.Abort;
        g_ImagePreviewDownloader.Terminate;
      end
      else
      begin
        g_ImagePreviewDownloader.WaitFor;
      end;
    end
    else
    begin
      g_ImagePreviewDownloader.Free;
    end;
    g_ImagePreviewDownloader := nil;
  end;
end;

function ListItemExists(ListView: TListView; strAddress: string): TListItem;
var i: Integer;
begin
  Result := nil;
  for i := 0 to ListView.Items.Count-1 do
  begin
    if ListView.Items[i].SubItems[Integer(srvcAddress) - 1] = strAddress then
    begin
      Exit(ListView.Items[i]);
    end;
  end;
end;

procedure UDPOnReceive(strBuffer: string; strIP: string; nPort: Word; dwTime: DWORD);
var Server: TServer;
    ListItem: TListItem;
    BasicInfo: TBasicInfo;
    ServList: TFPObjectList;
    strPing: string;
    nPos: Integer;
begin
  Server := ServerMgr_FindServer(strIP, nPort);
  if Server <> nil then
  begin

    if g_bLogUDP then
      g_Logger.Debug('UDPOnReceive - %s:%d [%d bytes][%d ms]', [strIP, nPort, Length(strBuffer), dwTime]);

    Server.RawInfo := strBuffer;
    Server.LastAlive := True;
    Server.ParsedInfo.Clear;

    Server.ParsedInfo.DelimitedText := strBuffer;
    Server.ParsedInfo.Delete(0);


    ServerMgr_GetBasicInfo(Server, BasicInfo{%H-});

    ListItem := ListItemExists(frmMain.lvServers, Server.Address);
    with frmMain.lvServers do
    begin
      if g_nRefreshMode <> RM_SPECIFIC then BeginUpdate;
      if ListItem = nil then
        ListItem := Items.Add
      else
        ListItem.SubItems.Clear;

      ListItem.Caption := BasicInfo.strServerName;

      if Server.Favorite then
        ListItem.ImageIndex := 6
      else
        ListItem.ImageIndex := 0;


      strPing := IntToStr(dwTime - Server.LastTime);
      if strPing = '0' then
        strPing := '10';
      ListItem.SubItems.Add(strPing);

      ListItem.SubItems.Add(Format('%s/%s', [BasicInfo.strNumPlayers, BasicInfo.strMaxPlayers]));
      g_ScriptServer := Server;

      if g_bCompileResult then
      begin
        Server.ModVer := ScriptMgr_RunModDetection;
        if (Server.Favorite) and (Server.CustomModVer <> '') then
          ListItem.SubItems.Add('*' + Server.CustomModVer)
        else
          ListItem.SubItems.Add(Server.ModVer);
      end
      else
      begin
        Server.ModVer := 'AVP2';
        ListItem.SubItems.Add(Server.ModVer);
      end;

      ListItem.SubItems.Add(BasicInfo.strGameType);
      ListItem.SubItems.Add(BasicInfo.strMap);
      ListItem.SubItems.Add(Server.Address);

      if Server.Favorite then
        ListItem.SubItems.Add(Server.CustomComment)
      else
        ListItem.SubItems.Add(Server.Comment);

      ListItem.Data := Server;

      if g_nRefreshMode = RM_ALL then
      begin
        ServList := ServerMgr_GetCurrentList(True);
        if ServList.Count = Items.Count then
          frmMain.tmrRefreshTimer(nil);
      end;
      if g_nRefreshMode <> RM_SPECIFIC then
        EndUpdate;

    end;

    if (g_nRefreshMode = RM_SPECIFIC) and (Server = g_SelectedServer) then
    begin
      with frmMain do
      begin
        tmrRefreshTimer(nil);
        lblServer.Caption := BasicInfo.strServerName;
        if (Server.Favorite) and (Server.CustomModVer <> '') then
        begin
           lblInfo.Caption :=
            Format(GetTranslatedString(IDS_FRM_MAIN_LBL_MGTPMSTAR),
            [Server.CustomModVer, BasicInfo.strGameType, ListItem.SubItems[Integer(srvcPlayers) - 1], BasicInfo.strMap]);
        end
        else
        begin
          lblInfo.Caption :=
            Format(GetTranslatedString(IDS_FRM_MAIN_LBL_MGTPM), //'Mod: %s'#13#10'Game Type: %s'#13#10'Players: %s'#13#10'Map: %s'
            [Server.ModVer, BasicInfo.strGameType, ListItem.SubItems[Integer(srvcPlayers) - 1], BasicInfo.strMap]);
        end;

        lblPing.Font.Color := ServerMgr_GetPingColor(dwTime - Server.LastTime);
        lblPing.Caption := GetTranslatedString(IDS_FRM_MAIN_LBL_PING) + strPing;

        nPos := GetPositionInImageCache(BasicInfo.strMap);
        if nPos > -1 then
        begin
          g_ImagePreviewCache.Position := nPos;
          imgMapshot.Picture.LoadFromStream(g_ImagePreviewCache);
          imgMapshot.Tag := 1;
        end
        else
        begin
          imgMapshot.Tag := 0;
          StopImagePreviewDownload(False);
          StartImagePreviewDownload(BasicInfo.strMap);
        end;

        frmMain.FillPlayerList0031(SafeStrToInt(BasicInfo.strNumPlayers), Server);
        frmMain.FillFastOptions;

      end;
    end;
  end;
end;

procedure UDPOnError(strValue: string);
begin
   g_Logger.Info('UDPOnError - %s', [strValue]);
end;

{ TfrmMain }

procedure TfrmMain.CustomExceptionHandler(Sender: TObject; E: Exception);
begin
  ShowExceptionCallStack(Application, E);
  Halt;
end;

procedure TfrmMain.mmiExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.mmiMarkFavoriteClick(Sender: TObject);
var Server: TServer;
    strNiceName: string;
begin
  if lvServers.Selected <> nil then
  begin
    Server := TServer(lvServers.Selected.Data); //ServerMgr_FindServer(lvServers.Selected.SubItems[4]);
    g_SelectedServer := Server;
    if lvServers.Selected.Caption <> GetTranslatedString(IDS_FRM_MAIN_CONST_NOTRESPONDING) then  // 'server is not responding'
      strNiceName := lvServers.Selected.Caption
    else
      strNiceName := Server.Address;

    if not Server.Favorite then
    begin

      frmAO.gbxAO.Caption := lvServers.Selected.Caption;
      g_CurrentMod := ServerMgr_FindMod(g_SelectedServer.ModVer);
      g_bAOAddMode := False;
      g_AOServer := Server;
      frmAO.FillAO;
      frmAO.Caption := GetTranslatedString(IDS_FRM_ADVANCEDOPTIONS_FAV);
      if frmAO.ShowModal = mrCancel then Exit;

      lvServers.Selected.ImageIndex := 6;
      lvServers.Selected.SubItems.Strings[Integer(srvcUserComment) - 1] := Server.CustomComment;

      if lvServers.Selected.SubItems.Strings[Integer(srvcMod) - 1] <> '-' then
      begin
        if Server.CustomModVer <> '' then
          lvServers.Selected.SubItems.Strings[Integer(srvcMod) - 1] := '*' + Server.CustomModVer
        else
          lvServers.Selected.SubItems.Strings[Integer(srvcMod) - 1] := Server.ModVer;
      end;

      g_AOServer := ServerMgr_AddFavoriteServer(Server, True);
    end
    else
    begin
      if g_nMode = SM_FAVORITES then
      begin
        Application.MessageBox(PChar(Format(GetTranslatedString(IDS_FRM_MAIN_MSG_ALREADYMARKED), [strNiceName])),
        //'Server "' + strNiceName + '" is already marked as favorite!'
          PChar(Application.Title), MB_ICONASTERISK + MB_OK);
      end
      else
      begin
        if Application.MessageBox(PChar(Format(GetTranslatedString(IDS_FRM_MAIN_MSG_REMOVEFROMFAV), [strNiceName])),
        //'Do you want to remove server "' + strNiceName + '" from favorites?'
           PChar(Application.Title), MB_YESNO + MB_ICONQUESTION) = IDYES then
        begin
          Server.Favorite := False;
          Server.CustomComment := '';
          lvServers.Selected.ImageIndex := 0;
          lvServers.Selected.SubItems.Strings[Integer(srvcUserComment) - 1] := Server.Comment;
          lvServers.Selected.SubItems.Strings[Integer(srvcMod) - 1] := Server.ModVer;
          ServerMgr_DeleteFavoriteServer(Server.Address, True);
        end;
      end;
    end;

    FillFastOptions;
    if lvMods.Selected = nil then
      FillFastOptionsMM(nil, False)
    else
      FillFastOptionsMM(lvMods.Selected, True)
  end
  else
  begin
    Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_MAIN_MSG_PLSSELECTSERVER), PChar(Application.Title), MB_OK + MB_ICONASTERISK);
    //'Please select server!'
  end;
end;

procedure TfrmMain.mmiNewsClick(Sender: TObject);
begin
  frmNews.ShowModal;
end;

procedure TfrmMain.mmiPPMInfoClick(Sender: TObject);
var
  Server: TServer;
begin
  if lvServers.Selected <> nil then
  begin
    Server := TServer(lvServers.Selected.Data);
    frmDebug.Caption := mmiPPMInfo.Caption;
    frmDebug.Clear;
    frmDebug.Add('IP: ' + Server.IP);
    frmDebug.Add('Port: ' + IntToStr(Server.Port));
    frmDebug.Add('DNS: ' + Server.DNSName);
    frmDebug.Add('Status: ' + Server.RawInfo);
    frmDebug.ShowModal;
  end
  else
  begin
    Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_MAIN_MSG_PLSSELECTSERVER), PChar(Application.Title), MB_OK + MB_ICONASTERISK);
    //'Please select server!'
  end;
end;

procedure TfrmMain.mmiRefreshAllClick(Sender: TObject);
var i: Integer;
    Server: TServer;
    strPort: string;
    List: TFPObjectList;
begin
  g_strRefreshAllError := GetTranslatedString(IDS_FRM_MAIN_CONST_ERRNOINFO);
  if (not g_bOnlineResult) and (g_nMode = SM_FEATURED) then
  begin
    Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_MAIN_MSG_NOFEATUREDSERVS),
      //'Featured server list is not available!'
      PChar(Application.Title), MB_OK + MB_ICONINFORMATION);
    Exit;
  end;
  RefreshCooldownBegin(True);
  g_nRefreshMode := RM_ALL;
  lvServers.Clear;
  lvPlayers.Clear;
  ServerMgr_ResetLastAlive(nil);
  List := ServerMgr_GetCurrentList;
  if (g_nMode = SM_FAVORITES) and (List.Count = 0) then
  begin
    Application.MessageBox(PChar(Format(GetTranslatedString(IDS_FRM_MAIN_MSG_SERVLISTEMPTY), [ServerMgr_GetCurrentListDesc])),
      // '"' + ServerMgr_GetCurrentListDesc + '" server list is empty!'
      PChar(Application.Title), MB_OK + MB_ICONINFORMATION);
    Exit;
  end;
  ServerMgr_WereRefreshed;
  if List <> nil then
  begin
    for i := 0 to List.Count-1 do
    begin
      Server := TServer(List.Items[i]);

      if g_bLogUDP then
         g_Logger.Info('TfrmMain.mmiRefreshAllClick - sending request to %s', [Server.Address]);

      strPort := IntToStr(Server.Port);
      UDPServer.SendString(Server.IP, strPort, UDP_STATUS);
      Server.LastTime := timeGetTime;
    end;
  end
  else
  begin
    Application.MessageBox(PChar(Format(GetTranslatedString(IDS_FRM_MAIN_MSG_CANTLOADLIST), [ServerMgr_GetCurrentListDesc, g_strRefreshAllError])),
      // 'Can''t load "' + ServerMgr_GetCurrentListDesc + '" list (' + g_strRefreshAllError + ')'
      PChar(Application.Title), MB_OK + MB_ICONERROR);
  end;
end;

procedure TfrmMain.mmiRefreshOnClickClick(Sender: TObject);
begin
  if mmiRefreshOnClick.Checked then
    mmiRefreshOnClick.Checked := False
  else
    mmiRefreshOnClick.Checked := True;
end;

procedure TfrmMain.mmiShowClick(Sender: TObject);
begin
  frmSetup.lblGameDir.Font.Style := [];
  frmSetup.lblGameDir.Font.Color := clDefault;
  frmSetup.ShowModal;
end;

procedure TfrmMain.mmiTrayExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.mmiTrayShowClick(Sender: TObject);
begin
  if Visible then
    Hide
  else
    Show;
end;

procedure TfrmMain.tiMainClick(Sender: TObject);
begin
  Show;
end;

procedure TfrmMain.tmrNewsTimer(Sender: TObject);
var strTitle, strText, strCompileError: string;
    ListItem: TListItem;
    CurMod: TModInfo;
    i: Integer;
    bSmthWrong: Boolean;
begin
  bSmthWrong := False;
  strTitle := '';
  strText := '';
  tmrNews.Enabled := False;

  btnFeatured.Enabled := True;
  btnMasterServer.Enabled := True;
  btnFavorites.Enabled := True;
  btnRefreshAll.Enabled := True;

  if g_bOnlineResult then
  begin
    if GetNews(0, strTitle, strText, g_strLink) then
    begin
      ServerMgr_LoadAdvanced;
      ServerMgr_LoadCustomMods;

      cgrpFastOptions.Enabled := False;
      cgrpFastOptionsMM.Enabled := False;
      btnOptions.Enabled := False;
      btnReset.Enabled := False;
      btnOptionsMM.Enabled := False;
      btnResetMM.Enabled := False;
      for i := 0 to g_Mods.Count-1 do
      begin
        with lvMods do
        begin
          CurMod := TModInfo(g_Mods.Items[i]);
          ListItem := lvMods.Items.Add;

          if CurMod.FullyCustom then
            ListItem.ImageIndex := 5
          else
            ListItem.ImageIndex := 0;

          ListItem.Caption := CurMod.Name;
          ListItem.Data := CurMod;
          ListItem.SubItems.Add(CurMod.Description);

        end;
      end;
      frmNews.btnOne.Font.Style := [fsBold];
      frmNews.lblTitle.Caption := strTitle;
      frmNews.lblText.Caption := strText;
      if g_strLink = '' then frmNews.lblHyperlink.Visible := False;
      frmNews.HandleNoNews;
      if not g_bHideNews then frmNews.ShowModal;
    end;
  end;
  if not g_bOnlineResult then
  begin
    Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_MAIN_MSG_NOINTERNETCONN), PChar(Application.Title), MB_OK + MB_ICONERROR);
    //'Can''t fetch data from server, check your internet connection! Application will be closed.'
    bSmthWrong := True;
  end;
  if (not bSmthWrong) and (not g_bCompileResult) then
  begin
    strCompileError := GetTranslatedStringPChar(IDS_FRM_MAIN_MSG_CANTCOMPILE); //'Error while compiling online scripts! Application will be closed.';
    for i := 0 to g_PSCompiler.MsgCount -1 do
    begin
      strCompileError := strCompileError + #13#10 + g_PSCompiler.Msg[i].MessageToString;
    end;
    Application.MessageBox(PChar(strCompileError), PChar(Application.Title), MB_OK + MB_ICONERROR);
    bSmthWrong := False;
  end;

  if bSmthWrong then
  begin
    Close;
    Exit;
  end;

  if g_bNewOfflineMode then
  begin
    Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_MAIN_MSG_NEWOFFLINEMODE), PChar(Application.Title), MB_OK + MB_ICONWARNING);
  end;

  if g_bAutoRefresh then
    btnRefreshAllClick(nil);

  if g_bUnlimitedResize then
  begin
    Constraints.MinWidth := 0;
    Constraints.MinHeight := 0;
    Top := Top + ((Height - UNLIMITED_RESIZE_HEIGHT) shr 1);
    Height := UNLIMITED_RESIZE_HEIGHT;
    frmMain.Position := poScreenCenter;
  end;
end;

procedure TfrmMain.tmrRefreshTimer(Sender: TObject);
var Server: TServer;
    ListItem: TListItem;
    i: Integer;
begin
  i := 0;
  if (g_nRefreshMode = RM_ALL) then
  begin
    Server := ServerMgr_GetNextDeadServer(i);
    if (Server <> nil) and (g_nDeadAttempts < DEAD_ATTEMPTS_MAX) then
    begin
      tmrRefresh.Enabled := False;
      RefreshDeadServers;
      Inc(g_nDeadAttempts, 1);
      Exit;
    end;
  end;

  RefreshCooldownEnd;
  if g_nRefreshMode = RM_ALL then
  begin
    i := 0;
    Server := ServerMgr_GetNextDeadServer(i);
    while Server <> nil do
    begin
      with frmMain.lvServers do
      begin
        BeginUpdate;
        ListItem := Items.Add;
        ListItem.Caption := GetTranslatedString(IDS_FRM_MAIN_CONST_NOTRESPONDING); //'server is not responding';

        if Server.Favorite then
          ListItem.ImageIndex := 6
        else
          ListItem.ImageIndex := 0;

        ListItem.SubItems.Add('-');
        ListItem.SubItems.Add('-');
        ListItem.SubItems.Add('-');
        ListItem.SubItems.Add('-');
        ListItem.SubItems.Add('-');
        ListItem.SubItems.Add(Server.Address);

        ListItem.Data := Server;

        if Server.Favorite then
          ListItem.SubItems.Add(Server.CustomComment)
        else
          ListItem.SubItems.Add(Server.Comment);
        EndUpdate;
      end;
      Inc(i, 1);
      Server := ServerMgr_GetNextDeadServer(i);
    end;
  end
  else if (g_nRefreshMode = RM_SPECIFIC) and (Sender <> nil) then
  begin
    ListItem := ListItemExists(lvServers, g_SelectedServer.Address);
    if ListItem <> nil then
    begin
      ListItem.Caption := GetTranslatedString(IDS_FRM_MAIN_CONST_NOTRESPONDING);//'server is not responding';
      ListItem.SubItems.Clear;

      if g_SelectedServer.Favorite then
        ListItem.ImageIndex := 6
      else
        ListItem.ImageIndex := 0;

      ListItem.SubItems.Add('-');
      ListItem.SubItems.Add('-');
      ListItem.SubItems.Add('-');
      ListItem.SubItems.Add('-');
      ListItem.SubItems.Add('-');
      ListItem.SubItems.Add(g_SelectedServer.Address);

      if g_SelectedServer.Favorite then
        ListItem.SubItems.Add(g_SelectedServer.CustomComment)
      else
        ListItem.SubItems.Add(g_SelectedServer.Comment);
    end;
  end;

  if (g_bAutoSort) and (g_nRefreshMode = RM_ALL) and (lvServers.Columns.Count > 0) then
  begin
    g_bDescending := True;
    g_nSortedColumn := 2;
    lvServers.AlphaSort;
  end;
end;

procedure TfrmMain.RefreshCooldownBegin(bHideList: Boolean);
begin
  g_SelectedServer := nil;

  btnFeatured.Enabled := False;
  btnMasterServer.Enabled := False;
  btnFavorites.Enabled := False;

  btnRefresh.Enabled := False;
  btnRefreshAll.Enabled := False;
  mmiRefreshAll.Enabled := False;

  btnJoin.Enabled := False;
  mmiRefreshAll.Enabled := False;
  if bHideList then
  begin
    g_nDeadAttempts := 0;
    lvServers.Enabled := False;
    lvServers.Color := clBtnFace;
  end;
  tmrRefresh.Enabled := True;
  lblServer.Caption := GetTranslatedString(IDS_FRM_MAIN_LBL_SELECTEDSERVER);
  lblInfo.Caption := GetTranslatedString(IDS_FRM_MAIN_LBL_MGTPMNA);
  lblPing.Font.Color := clDefault;
  lblPing.Caption := GetTranslatedString(IDS_FRM_MAIN_LBL_PINGNA);
  imgMapshot.Picture := g_DefaultImage;
  imgMapshot.Tag := 0;

  cgrpFastOptions.Items.Clear;
  cgrpFastOptions.Enabled := False;
  cgrpFastOptions.Caption := GetTranslatedString(IDS_FRM_MAIN_CGRP_FASTOPTIONS);
  btnOptions.Enabled := False;
  btnReset.Enabled := False;

  edtJoinPassword.Visible := False;
  edtJoinPassword.Text := '';
  lblJoinPassword.Visible := False;
end;

procedure TfrmMain.RefreshCooldownEnd;
begin
  btnFeatured.Enabled := True;
  btnMasterServer.Enabled := True;
  btnFavorites.Enabled := True;

  btnRefresh.Enabled := True;
  btnRefreshAll.Enabled := True;
  mmiRefreshAll.Enabled := True;

  btnJoin.Enabled := True;
  mmiRefreshAll.Enabled := True;
  lvServers.Enabled := True;
  lvServers.Color := clDefault;
  tmrRefresh.Enabled := False;
end;

procedure TfrmMain.FillPlayerList(nPlayers: Integer; Server: TServer);
var Info: TPlayerInfo;
    i: Integer;
    ListItem: TListItem;
    strRace: string;
begin
  lvPlayers.Clear;
  for i := 0 to nPlayers - 1 do
  begin
    ServerMgr_GetPlayer(i, Server, Info{%H-});
    if Info.strName <> '' then
    begin

      if (Server.Favorite) and (Server.CustomModVer <> '') then
        strRace := ScriptMgr_RunRaceDetection(Server.CustomModVer, Info.nRace)
      else
        strRace := ScriptMgr_RunRaceDetection(Server.ModVer, Info.nRace);

      lvPlayers.Items.BeginUpdate;
      with lvPlayers do
      begin
        ListItem := Items.Add;
        ListItem.ImageIndex := g_nScriptOut;
        ListItem.Caption := Info.strName;
        ListItem.SubItems.Add(Info.strPing);
        ListItem.SubItems.Add(strRace);
        ListItem.SubItems.Add(Info.strScore);
      end;
      lvPlayers.Items.EndUpdate;

    end
    else
    begin
      Exit;
    end;
  end;
end;

procedure TfrmMain.FillPlayerList0031(nPlayers: Integer; Server: TServer);
var i, j, nRaceColumn: Integer;
    slColumnConfig: TStringList;
    slPropsConfig: TStringList;
    slOut: TStringList;
    ListColumn: TListColumn;
    ListItem: TListItem;
    strRace: string;
begin
  lvPlayers.Visible := False;

  lvPlayers.Clear;
  lvPlayers.Columns.Clear;

  slOut := TStringList.Create;

  slColumnConfig := TStringList.Create;
  slColumnConfig.Delimiter := '|';
  slColumnConfig.StrictDelimiter := True;
  slColumnConfig.CaseSensitive := True;
  slColumnConfig.DelimitedText := ScriptMgr_GetPCC_Columns(Server.ModVer, g_strLang);

  slPropsConfig := TStringList.Create;
  slPropsConfig.Delimiter := '|';
  slPropsConfig.StrictDelimiter := True;
  slPropsConfig.CaseSensitive := True;
  slPropsConfig.DelimitedText := ScriptMgr_GetPCC_Props(Server.ModVer);
  nRaceColumn := g_nScriptOut;

  i := 0;
  while i < slColumnConfig.Count do
  begin
    with lvPlayers do
    begin
      ListColumn := Columns.Add;
      ListColumn.Caption := slColumnConfig.Strings[i];
      Inc(i, 1);
      if slColumnConfig.Strings[i] = '1' then
        ListColumn.AutoSize := True
      else
        ListColumn.AutoSize := False;
      Inc(i, 1);
      ListColumn.Width := StrToInt(slColumnConfig.Strings[i]);
    end;
    Inc(i, 1);
  end;

  for i := 0 to nPlayers - 1 do
  begin
    slOut.Clear;
    if ServerMgr_GetPlayer0031(i, Server, slPropsConfig, slOut) then
    begin
      if (Server.Favorite) and (Server.CustomModVer <> '') then
        strRace := ScriptMgr_RunRaceDetection(Server.CustomModVer, StrToInt(slOut.Strings[nRaceColumn]))
      else
        strRace := ScriptMgr_RunRaceDetection(Server.ModVer, StrToInt(slOut.Strings[nRaceColumn]));

      lvPlayers.Items.BeginUpdate;
      with lvPlayers do
      begin
        ListItem := Items.Add;
        ListItem.ImageIndex := g_nScriptOut;
        ListItem.Caption := slOut.Strings[0];

        for j := 1 to slOut.Count - 1 do
        begin
          if j <> nRaceColumn then
            ListItem.SubItems.Add(slOut.Strings[j])
          else
            ListItem.SubItems.Add(strRace);
        end;
      end;
      lvPlayers.Items.EndUpdate;
    end;
  end;
  slOut.Free;
  slColumnConfig.Free;
  slPropsConfig.Free;

  lvPlayers.Visible := True;
end;

procedure TfrmMain.FillFastOptionsOld;
var i, j: Integer;
    CurFO: TFOItem;
    CurMod: TModInfo;
    CurAO: TAOItem;
    bChecked: Boolean;
    CurAOLight: TAOItemLight;
begin
  for i := 0 to g_FastOptions.Count-1 do
  begin
    CurFO := TFOItem(g_FastOptions.Items[i]);

    if (g_SelectedServer.Favorite) and (g_SelectedServer.CustomModVer <> '') then
      CurMod := ServerMgr_FindMod(g_SelectedServer.CustomModVer)
    else
      CurMod := ServerMgr_FindMod(g_SelectedServer.ModVer);

    bChecked := False;
    for j := 0 to CurMod.AdvancedOptions.Count-1 do
    begin
      CurAO := TAOItem(CurMod.AdvancedOptions.Items[j]);
      if (CurAO.Title = CurFO.Title) then
      begin

        if g_SelectedServer.Favorite then
        begin
          CurAOLight := ServerMgr_GetAOLight(g_SelectedServer, CurAO.Title);
          if CurAOLight = nil then
            bChecked := CurAO.IsDefault
          else
            bChecked := CurAOLight.Checked;

        end
        else
        begin
          bChecked := CurAO.IsDefault;
        end;

        Break;
      end;
    end;
    cgrpFastOptions.Checked[i] := bChecked;
  end;
end;

procedure TfrmMain.FillFastOptions;
var CurMod: TModInfo;
    CurAO: TAOItem;
    i, nIndex: Integer;
    bAOCustom, bAOChecked: Boolean;
begin
  cgrpFastOptions.Visible := False;

  bAOCustom := False;
  bAOChecked := False;
  cgrpFastOptions.Items.Clear;
  edtJoinPassword.Text := '';
  lblJoinPassword.Visible := False;
  edtJoinPassword.Visible := False;

  if g_SelectedServer = nil then Exit;

  if not g_SelectedServer.Favorite then
  begin
    cgrpFastOptions.Enabled := True;
    btnOptions.Enabled := True;
    btnReset.Enabled := True;
    CurMod := ServerMgr_FindMod(g_SelectedServer.ModVer);
    cgrpFastOptions.Caption := GetTranslatedString(IDS_FRM_MAIN_CGRP_FASTOPTIONS)  + ' [' + CurMod.Name + ']';

    cgrpFastOptions.Items.AddObject(g_AOPassword.Title, g_AOPassword);
    cgrpFastOptions.Items.AddObject(g_AOWindowed.Title, g_AOWindowed);

    for i := 0 to CurMod.AdvancedOptions.Count - 1 do
    begin
      CurAO := TAOItem(CurMod.AdvancedOptions.Items[i]);
      nIndex := cgrpFastOptions.Items.AddObject('', CurAO);
      ServerMgr_GetAOCustomStatus(CurAO, bAOCustom, bAOChecked);
      cgrpFastOptions.Checked[nIndex] := bAOChecked;
      if bAOCustom then
        cgrpFastOptions.Items.Strings[nIndex] := CurAO.Title + '*'
      else
        cgrpFastOptions.Items.Strings[nIndex] := CurAO.Title;
    end;
  end
  else
  begin
    cgrpFastOptions.Enabled := True;
    btnOptions.Enabled := False;
    btnReset.Enabled := False;
    cgrpFastOptions.Caption := GetTranslatedString(IDS_FRM_MAIN_CGRP_FASTOPTIONSFAV);
    cgrpFastOptions.Items.AddObject(g_AOPassword.Title, g_AOPassword);
    cgrpFastOptions.Items.AddObject(g_AOWindowed.Title, g_AOWindowed);
  end;

  cgrpFastOptions.Visible := True;
end;

procedure TfrmMain.FillFastOptionsMM(ListItem: TListItem; Selected: Boolean);
var CurMod: TModInfo;
    CurAO: TAOItem;
    i, nIndex: Integer;
    bAOCustom, bAOChecked: Boolean;
begin
  cgrpFastOptionsMM.Visible := False;

  bAOCustom := False;
  bAOChecked := False;
  cgrpFastOptionsMM.Items.Clear;

  if Selected then
  begin
    CurMod := TModInfo(ListItem.Data);
    if not CurMod.FullyCustom then
    begin
      cgrpFastOptionsMM.Enabled := True;
      btnOptionsMM.Enabled := True;
      btnResetMM.Enabled := True;

      cgrpFastOptionsMM.Items.AddObject(g_AOWindowed.Title, g_AOWindowed);

      for i := 0 to CurMod.AdvancedOptions.Count - 1 do
      begin
        CurAO := TAOItem(CurMod.AdvancedOptions.Items[i]);
        nIndex := cgrpFastOptionsMM.Items.AddObject('', CurAO);
        ServerMgr_GetAOCustomStatus(CurAO, bAOCustom, bAOChecked);
        cgrpFastOptionsMM.Checked[nIndex] := bAOChecked;
        if bAOCustom then
          cgrpFastOptionsMM.Items.Strings[nIndex] := CurAO.Title + '*'
        else
          cgrpFastOptionsMM.Items.Strings[nIndex] := CurAO.Title;
      end;
    end
    else
    begin
      cgrpFastOptionsMM.Enabled := True;
      btnOptionsMM.Enabled := False;
      btnResetMM.Enabled := False;

      cgrpFastOptionsMM.Items.AddObject(g_AOWindowed.Title, g_AOWindowed);
    end;
  end
  else
  begin
    cgrpFastOptionsMM.Enabled := False;
    btnOptionsMM.Enabled := False;
    btnResetMM.Enabled := False;
  end;

  cgrpFastOptionsMM.Visible := True;
end;

procedure TfrmMain.RestoreLastServerList;
var List: TFPObjectList;
    i: Integer;
    Server: TServer;
    BasicInfo: TBasicInfo;
    ListItem: TListItem;
begin
  if not g_bWereRefreshed[g_nMode] then Exit;
  List := ServerMgr_GetCurrentList;
  for i := 0 to List.Count-1 do
  begin
    with frmMain.lvServers do
    begin
      Server := TServer(List.Items[i]);
      ListItem := Items.Add;
      if Server.LastAlive then
      begin
        ServerMgr_GetBasicInfo(Server, BasicInfo{%H-});

        ListItem.Caption := BasicInfo.strServerName;

        if Server.Favorite then
          ListItem.ImageIndex := 6
        else
          ListItem.ImageIndex := 0;

        ListItem.SubItems.Add('-');

        ListItem.SubItems.Add(Format('%s/%s', [BasicInfo.strNumPlayers, BasicInfo.strMaxPlayers]));
        ListItem.SubItems.Add(Server.ModVer);
        ListItem.SubItems.Add(BasicInfo.strGameType);
        ListItem.SubItems.Add(BasicInfo.strMap);
        ListItem.SubItems.Add(Server.Address);

        if Server.Favorite then
          ListItem.SubItems.Add(Server.CustomComment)
        else
          ListItem.SubItems.Add(Server.Comment);
      end
      else
      begin
        ListItem.Caption := GetTranslatedString(IDS_FRM_MAIN_CONST_NOTRESPONDING);//'server is not responding';

        if Server.Favorite then
          ListItem.ImageIndex := 6
        else
          ListItem.ImageIndex := 0;

        ListItem.SubItems.Add('-');
        ListItem.SubItems.Add('-');
        ListItem.SubItems.Add('-');
        ListItem.SubItems.Add('-');
        ListItem.SubItems.Add('-');
        ListItem.SubItems.Add(Server.Address);

        if Server.Favorite then
          ListItem.SubItems.Add(Server.CustomComment)
        else
          ListItem.SubItems.Add(Server.Comment);
      end;
    end;
  end;
end;

procedure TfrmMain.ApplyColumnSetup;
var i: Integer;
begin
  for i := 0 to Integer(srvcMax) - 1 do
  begin
    if not g_ColumnSetup.Bits[i] then
    begin
      lvServers.Column[i].AutoSize := g_ColumnSetup.Bits[i];
      lvServers.Column[i].Visible := g_ColumnSetup.Bits[i];
    end
    else
    begin
      if g_nColumnWidth_Servers[i] < 0 then
      begin
        lvServers.Column[i].AutoSize := False;
        lvServers.Column[i].Width := -g_nColumnWidth_Servers[i];
      end
      else
      begin
        lvServers.Column[i].AutoSize := True;
      end;
      lvServers.Column[i].Visible := True;
    end;
  end;
  case g_nMode of
    SM_FEATURED: lvServers.Font.Color := g_clrFeaturedFC;
    SM_MASTER: lvServers.Font.Color := g_clrMasterServerFC;
    SM_FAVORITES: lvServers.Font.Color := g_clrFavoritesFC;
  end;

  if g_bTabPosTop then
    pcMain.TabPosition := tpTop
  else
    pcMain.TabPosition := tpBottom;
end;

procedure TfrmMain.tmrUpdateTimer(Sender: TObject);
var UDPMsg: TUDPMessage;
begin
  try
    EnterCriticalsection(g_CS);
    UDPMsg := UDPServer.ReadMessage;
    while UDPMsg <> nil do
    begin
      UDPOnReceive(UDPMsg.Msg, UDPMsg.IP, UDPMsg.Port, UDPMsg.Time);
      UDPMsg.Free;
      UDPMsg := UDPServer.ReadMessage;
    end;
    UDPMsg := UDPServer.SendMessage;
    while UDPMsg <> nil do
    begin
      UDPMsg.ObjectTime^ := timeGetTime;
      UDPServer.SendString(UDPMsg.IP, IntToStr(UDPMsg.Port), UDPMsg.Msg);
      UDPMsg.Free;
      UDPMsg := UDPServer.SendMessage;
    end;
  finally
    LeaveCriticalsection(g_CS);
  end;
end;

procedure TfrmMain.ClearServerFastInfo;
begin
  lblServer.Caption := GetTranslatedString(IDS_FRM_MAIN_LBL_SELECTEDSERVER); //'Selected Server';
  lblInfo.Caption := GetTranslatedString(IDS_FRM_MAIN_LBL_MGTPMNA);
    //'Mod: N/A'#13#10'Game Type: N/A'#13#10'Players: 0/0'#13#10'Map: N/A';
  lblPing.Font.Color := clDefault;
  lblPing.Caption := GetTranslatedString(IDS_FRM_MAIN_LBL_PINGNA); //'Ping: N/A';
  imgMapshot.Picture := g_DefaultImage;
  imgMapshot.Tag := 0;

  cgrpFastOptions.Items.Clear;
  cgrpFastOptions.Enabled := False;
  cgrpFastOptions.Caption := GetTranslatedString(IDS_FRM_MAIN_CGRP_FASTOPTIONS);
  btnOptions.Enabled := False;
  btnReset.Enabled := False;

  g_SelectedServer := nil;
end;

procedure TfrmMain.Translate;
begin
  Caption := GetTranslatedString(IDS_FRM_MAIN);
  mmiLauncher.Caption := GetTranslatedString(IDS_FRM_MAIN_MMI_LAUNCHER);
  mmiNews.Caption := GetTranslatedString(IDS_FRM_MAIN_MMI_SHOWNEWS);
  mmiHide.Caption := GetTranslatedString(IDS_FRM_MAIN_MMI_HIDEWIN);
  mmiExit.Caption := GetTranslatedString(IDS_FRM_MAIN_MMI_EXIT);
  mmiServerList.Caption := GetTranslatedString(IDS_FRM_MAIN_MMI_SERVLIST);
  mmiRefreshAll.Caption := GetTranslatedString(IDS_FRM_MAIN_MMI_REFRESHALL);
  mmiAdd.Caption := GetTranslatedString(IDS_FRM_MAIN_MMI_ADD);
  mmiEdit.Caption := GetTranslatedString(IDS_FRM_MAIN_MMI_ADVANCED);
  mmiDelete.Caption := GetTranslatedString(IDS_FRM_MAIN_MMI_DELETE);
  mmiMarkFavorite.Caption := GetTranslatedString(IDS_FRM_MAIN_MMI_TOGGLE);
  mmiSetup.Caption := GetTranslatedString(IDS_FRM_MAIN_MMI_SETUP);
  mmiD3D7Fix.Caption := GetTranslatedString(IDS_D3D7FIX_INSTALL);
  mmiShow.Caption := GetTranslatedString(IDS_FRM_MAIN_MMI_SHOW);
  mmiHelp.Caption := GetTranslatedString(IDS_FRM_MAIN_MMI_HELP);
  mmiAbout.Caption := GetTranslatedString(IDS_FRM_MAIN_MMI_ABOUT);
  btnFeatured.Caption := GetTranslatedString(IDS_FRM_MAIN_BTN_FEATURED);
  btnMasterServer.Caption := GetTranslatedString(IDS_FRM_MAIN_BTN_MASTERSERVER);
  btnFavorites.Caption := GetTranslatedString(IDS_FRM_MAIN_BTN_FAVORITES);
  btnRefreshAll.Caption := GetTranslatedString(IDS_FRM_MAIN_BTN_REFRESHALL);

  // srvcServerName = 0, srvcPing, srvcPlayers, srvcMod, srvcGameType, srvcMap, srvcAddress, srvcUserComment,
  lvServers.Column[Integer(srvcServerName)].Caption := GetTranslatedString(IDS_FRM_MAIN_COL_SERVERNAME);
  lvServers.Column[Integer(srvcPing)].Caption := GetTranslatedString(IDS_FRM_MAIN_COL_PING);
  lvServers.Column[Integer(srvcPlayers)].Caption := GetTranslatedString(IDS_FRM_MAIN_COL_PLAYERS);
  lvServers.Column[Integer(srvcMod)].Caption := GetTranslatedString(IDS_FRM_MAIN_COL_MOD);
  lvServers.Column[Integer(srvcGameType)].Caption := GetTranslatedString(IDS_FRM_MAIN_COL_TYPE);
  lvServers.Column[Integer(srvcAddress)].Caption := GetTranslatedString(IDS_FRM_MAIN_COL_ADDRESS);
  lvServers.Column[Integer(srvcUserComment)].Caption := GetTranslatedString(IDS_FRM_MAIN_COL_USERCOMM);
  lvServers.Column[Integer(srvcMap)].Caption := GetTranslatedString(IDS_FRM_MAIN_COL_MAP);

  mmiPPMAdd.Caption := GetTranslatedString(IDS_FRM_MAIN_PMI_SERVADD);
  mmiPPMEdit.Caption := GetTranslatedString(IDS_FRM_MAIN_PMI_SERVADVOPTIONS);
  mmiPPMDelete.Caption := GetTranslatedString(IDS_FRM_MAIN_PMI_SERVDELETE);
  mmiPPMFavorite.Caption := GetTranslatedString(IDS_FRM_MAIN_PMI_SERVTOGGLEFAV);
  mmiPPMInfo.Caption := GetTranslatedString(IDS_FRM_MAIN_PMI_SERVQUICKINFO);
  gbMapshot.Caption := GetTranslatedString(IDS_FRM_MAIN_GBX_MAPSCREEN);
  lblServer.Caption := GetTranslatedString(IDS_FRM_MAIN_LBL_SELECTEDSERVER);
  lblInfo.Caption := GetTranslatedString(IDS_FRM_MAIN_LBL_MGTPMNA);
  lblPing.Caption := GetTranslatedString(IDS_FRM_MAIN_LBL_PINGNA);
  btnRefresh.Caption := GetTranslatedString(IDS_FRM_MAIN_BTN_REFRESH);
  btnJoin.Caption := GetTranslatedString(IDS_FRM_MAIN_BTN_JOINGAME);
  btnHide.Caption := GetTranslatedString(IDS_FRM_MAIN_BTN_HIDEWIN);
  tsServerInfo.Caption := GetTranslatedString(IDS_FRM_MAIN_TAB_SERVINFO);

  //lvPlayers.Column[0].Caption := GetTranslatedString(IDS_FRM_MAIN_COL_PLAYER);
  //lvPlayers.Column[1].Caption := GetTranslatedString(IDS_FRM_MAIN_COL_PLAYERPING);
  //lvPlayers.Column[2].Caption := GetTranslatedString(IDS_FRM_MAIN_COL_RACE);
  //lvPlayers.Column[3].Caption := GetTranslatedString(IDS_FRM_MAIN_COL_SCORE);

  cgrpFastOptions.Caption := GetTranslatedString(IDS_FRM_MAIN_CGRP_FASTOPTIONS);
  lblJoinPassword.Caption := GetTranslatedString(IDS_FRM_MAIN_LBL_JOINPASS);
  btnOptions.Caption := GetTranslatedString(IDS_FRM_MAIN_BTN_SAVEOPTIONS);
  btnReset.Caption := GetTranslatedString(IDS_FRM_MAIN_BTN_RESETOPTIONS);
  tsModMgr.Caption := GetTranslatedString(IDS_FRM_MAIN_TAB_MODMANAGER);
  mmiLaunchMod.Caption := GetTranslatedString(IDS_FRM_MAIN_PMI_LAUNCH);
  mmiAddMod.Caption := GetTranslatedString(IDS_FRM_MAIN_PMI_ADD);
  mmiEditMod.Caption := GetTranslatedString(IDS_FRM_MAIN_PMI_EDIT);
  mmiDeleteMod.Caption := GetTranslatedString(IDS_FRM_MAIN_PMI_DELETE);
  mmiInfoMod.Caption := GetTranslatedString(IDS_FRM_MAIN_PMI_SHOWINFO);
  mmiRemoveModPatches.Caption := GetTranslatedString(IDS_FRM_MAIN_PMI_REMOVEPATCHES);
  lvMods.Column[0].Caption := GetTranslatedString(IDS_FRM_MAIN_COL_MANAGERMOD);
  lvMods.Column[1].Caption := GetTranslatedString(IDS_FRM_MAIN_COL_DESCRIPTION);
  btnLaunchMod.Caption := GetTranslatedString(IDS_FRM_MAIN_BTN_LAUNCH);
  cgrpFastOptionsMM.Caption := GetTranslatedString(IDS_FRM_MAIN_CGRP_FASTOPTIONSMM);
  btnOptionsMM.Caption := GetTranslatedString(IDS_FRM_MAIN_BTN_SAVEOPTIONSMM);
  btnResetMM.Caption := GetTranslatedString(IDS_FRM_MAIN_BTN_RESETOPTIONSMM);
  mmiTitle.Caption := GetTranslatedString(IDS_FRM_MAIN_TRAY_THETITLE);
  mmiTrayShow.Caption := GetTranslatedString(IDS_FRM_MAIN_TRAY_SHOW);
  mmiTrayExit.Caption := GetTranslatedString(IDS_FRM_MAIN_TRAY_EXIT);
  tiMain.Hint := GetTranslatedString(IDS_FRM_MAIN_TRAY_THETITLE);
  mmiD3D7FixAO.Caption := GetTranslatedString(IDS_D3D7FIX_AO);
end;

procedure TfrmMain.FillVersionPanel;
begin
  sbSimple.Panels[0].Text := g_strLauncherVersion;
  sbSimple.Panels[1].Text := g_strLauncherRC;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var i: Integer;
begin
  Application.OnException := @CustomExceptionHandler;

  imgMapshot.Picture := g_DefaultImage;
  imgMapshot.Tag := 0;

  SetLength(g_nColumnWidth_Servers, lvServers.Columns.Count);
  for i := 0 to lvServers.Columns.Count-1 do
  begin
    g_nColumnWidth_Servers[i] := lvServers.Columns.Items[i].Width;
    if not lvServers.Columns.Items[i].AutoSize then
      g_nColumnWidth_Servers[i] := -g_nColumnWidth_Servers[i];
  end;

  ApplyColumnSetup;
  InitializeCriticalSection(g_CS);
  tmrUpdate.Enabled := True;
  tiMain.Visible := True;

  frmMain.Menu := mmMenu;
end;

procedure TfrmMain.FormShow(Sender: TObject);
var strNew: string;
begin
  if not g_bStartup then
  begin
    frmLoading.ShowModal;

    g_nVersionCurrent := StrToInt(sbSimple.Panels[0].Text[7]) +
                         (StrToInt(sbSimple.Panels[0].Text[5]) * 10) +
                         (StrToInt(sbSimple.Panels[0].Text[3]) * 100) +
                         (StrToInt(sbSimple.Panels[0].Text[1]) * 1000);
    if g_strLastVersion <> '' then
    begin
      g_nVersionLast := StrToInt(g_strLastVersion[7]) +
                        (StrToInt(g_strLastVersion[5]) * 10) +
                        (StrToInt(g_strLastVersion[3]) * 100) +
                        (StrToInt(g_strLastVersion[1]) * 1000);
    end;
    if (g_strGameDir = '') or (not IsAVP2Dir(g_strGameDir)) then
    begin
      Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_MAIN_MSG_PLSSETAVP2DIR), PChar(Application.Title), MB_OK + MB_ICONASTERISK);
      frmSetup.lblGameDir.Font.Style := [fsBold];
      frmSetup.lblGameDir.Font.Color := clRed;
      if (frmSetup.ShowModal = mrCancel) and (frmSetup.edtGameDir.Text = '') then
      begin
        Close;
      end;
    end
    else
    begin
      g_Logger.Info('UpdateStuff - New version checking: %d ~ %d', [g_nVersionLast, g_nVersionCurrent]);
      if g_nVersionLast > g_nVersionCurrent then
      begin
        if Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_MAIN_MSG_NEWVERSIONFOUND),
           PChar(Application.Title), MB_YESNO + MB_ICONQUESTION) = IDYES then
        begin
          frmDownloader.ResetJobs(GetTranslatedString(IDS_FRM_DOWNLOADER_UPD));
          frmDownloader.AddJob(CJOB_DOWNLOAD, [g_strLastLink, g_strUpdateDir + 'update.zip']);
          frmDownloader.AddJob(CJOB_EXTRACT, [g_strUpdateDir, g_strUpdateDir + 'update.zip', g_strUpdateDir]);
          frmDownloader.AddJob(CJOB_FINALIZING, []);
          frmDownloader.StartJobs;
          if frmDownloader.ShowModal = mrOK then
          begin
            Close;
          end;
        end;
      end
      else
      begin

        strNew := g_strAppDir + 'Updater.exe';
        if FileExists(strNew) then
        begin
          DeleteFile(strNew);
          DeleteDirectory(g_strUpdateDir, False);
          CleanupOldDirsAndFiles;
        end;
      end;
    end;
    g_bStartup := True;
    tmrNews.Enabled := True;
    if CreateDir(g_strUpdateDir) then
      g_Logger.Info('UpdateStuff - Update directory created')
    else
      g_Logger.Info('UpdateStuff - Unable to create update directory');
  end;
end;

procedure TfrmMain.lblServerClick(Sender: TObject);
var ListItem: TListItem;
    i: Integer;
begin
  if (g_SelectedServer <> nil) and (g_SelectedServer.ParsedInfo.Count > 0) then
  begin
    with frmServerInfo.lvServerInfo do
    begin
      Clear;
      for i := 0 to g_SelectedServer.ParsedInfo.Count-1 do
      begin
        if i mod 2 = 0 then
        begin
          ListItem := Items.Add;
          ListItem.Caption := g_SelectedServer.ParsedInfo.Strings[i];
        end
        else
        begin
          ListItem.SubItems.Add(g_SelectedServer.ParsedInfo.Strings[i]);
        end;
      end;
    end;
    frmServerInfo.ShowModal;
  end;
end;

procedure TfrmMain.lvModsClick(Sender: TObject);
begin
  if lvMods.Selected <> nil then
    FillFastOptionsMM(lvMods.Selected, True)
end;

procedure TfrmMain.lvModsSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  FillFastOptionsMM(Item, Selected);
end;

procedure TfrmMain.lvServersClick(Sender: TObject);
var nCurrTime: Cardinal;
begin
  nCurrTime := timeGetTime;
  if (lvServers.Selected <> nil) and (nCurrTime - g_nLastServerSelect > g_nServerClickDelay) then
  begin
    lvServersSelectItem(nil, lvServers.Selected, True);
  end;
end;

procedure TfrmMain.lvServersSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var Server: TServer;
begin
  if mmiRefreshOnClick.Checked then
  begin
    if Selected then
    begin
      g_nLastServerSelect := timeGetTime;

      RefreshCooldownBegin(False);
      g_nRefreshMode := RM_SPECIFIC;
      Server := TServer(Item.Data);
      g_SelectedServer := Server;
      ServerMgr_ResetLastAlive(Server);

      if g_bLogUDP then
        g_Logger.Info('TfrmMain.lvServersSelectItem - sending request to %s', [Server.Address]);

      UDPServer.PrepareToSendString(Server.IP, Server.Port, UDP_STATUS, @Server.LastTime);
    end
    else
    begin
      ClearServerFastInfo;
    end;
  end;
end;

procedure TfrmMain.lvServersColumnClick(Sender: TObject; Column: TListColumn);
begin
  if Column.Index <> g_nSortedColumn then
  begin
    g_nSortedColumn := Column.Index;
    g_bDescending := False;
  end
  else
  begin
    g_bDescending := not g_bDescending;
  end;
  lvServers.AlphaSort;
end;

procedure TfrmMain.lvServersCompare(Sender: TObject; Item1, Item2: TListItem;
  Data: Integer; var Compare: Integer);
var x, y, nPos: Integer;
begin
  x := 0;
  y := 0;
  if g_nSortedColumn = 0 then
  begin
    Compare := CompareText(Item1.Caption, Item2.Caption);
  end
  else

  if g_nSortedColumn <> 0 then
  begin
    if g_nSortedColumn = 1 then
    begin
      if Item1.SubItems[g_nSortedColumn-1] = Item2.SubItems[g_nSortedColumn-1] then Compare := 0
      else if Item1.SubItems[g_nSortedColumn-1] = '-' then Compare := 1
      else if Item2.SubItems[g_nSortedColumn-1] = '-' then Compare := -1
      else
      begin
        x := SafeStrToInt(Item1.SubItems[g_nSortedColumn-1]);
        y := SafeStrToInt(Item2.SubItems[g_nSortedColumn-1]);
        if x > y then Compare := 1
        else if x < y then Compare := -1
        else Compare := 0;
      end;
    end
    else if g_nSortedColumn = 2 then
    begin
      if Item1.SubItems[g_nSortedColumn-1] = Item2.SubItems[g_nSortedColumn-1] then Compare := 0
      else if Item1.SubItems[g_nSortedColumn-1] = '-' then Compare := -1
      else if Item2.SubItems[g_nSortedColumn-1] = '-' then Compare := 1
      else
      begin
        nPos := Pos('/', Item1.SubItems[g_nSortedColumn-1]);
        if nPos > -1 then
          x := SafeStrToInt(Copy(Item1.SubItems[g_nSortedColumn-1], 1, nPos - 1));

        nPos := Pos('/', Item2.SubItems[g_nSortedColumn-1]);
        if nPos > -1 then
          y := SafeStrToInt(Copy(Item2.SubItems[g_nSortedColumn-1], 1, nPos - 1));

        if x > y then Compare := 1
        else if x < y then Compare := -1
        else Compare := 0;
      end;
    end
    else
    begin
      Compare := CompareText(Item1.SubItems[g_nSortedColumn-1], Item2.SubItems[g_nSortedColumn-1]);
    end;
  end;

  if g_bDescending then Compare := -Compare;
end;

procedure TfrmMain.mmiAddClick(Sender: TObject);
var NewServer: TServer;
begin
  if g_nMode = SM_FAVORITES then
  begin
    g_bAOAddMode := True;
    NewServer := TServer.Create;
    g_AOServer := NewServer;
    frmAO.gbxAO.Caption := '';
    frmAO.FillAO;
    frmAO.Caption := GetTranslatedString(IDS_FRM_ADVANCEDOPTIONS_ADD);
    if frmAO.ShowModal = mrOK then
    begin
      g_AOServer := ServerMgr_AddFavoriteServer(NewServer, True);
      g_nRefreshMode := RM_ALL;
      btnRefreshAllClick(nil);
    end;
    NewServer.Free;
  end
  else
  begin
    Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_MAIN_MSG_ADDONLYTOFAV), PChar(Application.Title), MB_OK + MB_ICONASTERISK);
  end;
end;

procedure TfrmMain.mmiDeleteClick(Sender: TObject);
var strNiceName: string;
    Server: TServer;
begin
  if g_nMode = SM_FAVORITES then
  begin
    if lvServers.Selected <> nil then
    begin
      Server := TServer(lvServers.Selected.Data);
      if lvServers.Selected.Caption <> GetTranslatedString(IDS_FRM_MAIN_CONST_NOTRESPONDING) then
        strNiceName := lvServers.Selected.Caption
      else
        strNiceName := Server.Address;

      if Application.MessageBox(PChar(Format(GetTranslatedString(IDS_FRM_MAIN_MSG_REMOVEFROMFAV), [strNiceName])),
      //'Do you want to remove server "' + strNiceName + '" from favorites?'
         PChar(Application.Title), MB_YESNO + MB_ICONQUESTION) = IDYES then
      begin
        lvServers.Selected.Delete;
        ServerMgr_DeleteFavoriteServer(Server.Address, True);
        ServerMgr_SaveFavorites;
      end;
    end
    else
    begin
      Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_MAIN_MSG_PLSSELECTSERVER), PChar(Application.Title), MB_OK + MB_ICONASTERISK);
    end;
  end
  else
  begin
    Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_MAIN_MSG_REMOVEONLYFROMFAV), PChar(Application.Title), MB_OK + MB_ICONASTERISK);
    //You can delete server only from Favorites!
  end;
end;

procedure TfrmMain.mmiEditClick(Sender: TObject);
var ListItem: TListItem;
begin
  ListItem := lvServers.Selected;
  if ListItem <> nil then
  begin
    g_SelectedServer := TServer(ListItem.Data);
    if g_SelectedServer.Favorite then
    begin
      g_bAOAddMode := False;
      frmAO.gbxAO.Caption := ListItem.Caption;
      g_AOServer := g_SelectedServer;
      frmAO.FillAO;
      frmAO.Caption := GetTranslatedString(IDS_FRM_ADVANCEDOPTIONS_EDIT);
      if frmAO.ShowModal = mrOK then
      begin
        g_AOServer := ServerMgr_AddFavoriteServer(g_SelectedServer, True);
        ListItem.SubItems.Strings[Integer(srvcUserComment) - 1] := g_SelectedServer.CustomComment;

        if ListItem.SubItems.Strings[Integer(srvcMod) - 1] <> '-' then
        begin
          if g_SelectedServer.CustomModVer <> '' then
            ListItem.SubItems.Strings[Integer(srvcMod) - 1] := '*' + g_SelectedServer.CustomModVer
          else
            ListItem.SubItems.Strings[Integer(srvcMod) - 1] := g_SelectedServer.ModVer;
        end;

      end;
    end
    else
    begin
      Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_MAIN_MSG_EDITAOONLYFORFAV), PChar(Application.Title), MB_OK + MB_ICONASTERISK);
      //You can edit advanced options only for favorite servers!
    end;
  end
  else
  begin
    Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_MAIN_MSG_PLSSELECTSERVER), PChar(Application.Title), MB_OK + MB_ICONASTERISK);
  end;
end;

procedure TfrmMain.mmiHideClick(Sender: TObject);
begin
  //tiMain.ShowBalloonHint;
  Hide;
end;

procedure TfrmMain.btnFeaturedClick(Sender: TObject);
begin
  if g_nMode = SM_FEATURED then Exit;
  g_nMode := SM_FEATURED;
  lvServers.Clear;
  lvPlayers.Clear;
  ClearServerFastInfo;
  btnFeatured.Font.Style := [fsBold];
  btnMasterServer.Font.Style := [];
  btnFavorites.Font.Style := [];
  mmiPPMAdd.Enabled := False;
  mmiPPMEdit.Enabled := True;
  mmiPPMDelete.Enabled := False;
  mmiPPMFavorite.Enabled := True;
  mmiAdd.Enabled := False;
  mmiEdit.Enabled := True;
  mmiDelete.Enabled := False;
  mmiMarkFavorite.Enabled := True;
  lvServers.Font.Color := g_clrFeaturedFC;
  g_SelectedServer := nil;

  if g_bAutoRefresh then
    btnRefreshAllClick(nil);
end;

procedure TfrmMain.btnHideClick(Sender: TObject);
begin
  //tiMain.ShowBalloonHint;
  Hide;
end;

procedure TfrmMain.btnInfoModClick(Sender: TObject);
var ListItem: TListItem;
begin
  ListItem := lvMods.Selected;
  if ListItem <> nil then
  begin
    g_ThisMod := TModInfo(ListItem.Data);
    if not g_ThisMod.FullyCustom then
    begin
      frmModInfo.Caption := GetTranslatedString(IDS_FRM_MODINFO_MINUS) + g_ThisMod.Name;
      frmModInfo.mmoInfo.Text := g_ThisMod.FullDescription;
      frmModInfo.edtLink.Text := g_ThisMod.Link;
      frmModInfo.ShowModal;
    end
    else
    begin
      Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_MAIN_MSG_INFOONLYFORCUMODS), PChar(Application.Title), MB_OK + MB_ICONASTERISK);
      //'Information is not available for custom mods!'
    end;
  end
  else
  begin
    Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_MAIN_MSG_PLSSELECTMOD), PChar(Application.Title), MB_OK + MB_ICONASTERISK);
    //Please select mod!
  end;
end;

procedure TfrmMain.btnJoinClick(Sender: TObject);
var Server: TServer;
    MyMod: TModInfo;
    ListItem: TListItem;
    strFinalCmd: string;
    strTemp: string = '';
    strModAOString, strD3D7FixString: string;
    ProcessGame: TProcessUTF8;
    slD3D7FixExtraParams: TStringList;
begin
  ListItem := lvServers.Selected;
  if ListItem <> nil then
  begin
    Server := TServer(ListItem.Data);
    g_SelectedServer := Server;
    g_Logger.Info('TfrmMain.btnJoinClick - joining server %s', [Server.Address]);

    if Server.CustomModVer <> '' then
      MyMod := ServerMgr_FindMod(Server.CustomModVer)
    else
      MyMod := ServerMgr_FindMod(Server.ModVer);

    ProcessGame := TProcessUTF8.Create(nil);
    if MyMod.PrimalHunt then
    begin
      ProcessGame.CurrentDirectory := g_strGameDirPH;
      ProcessGame.Executable := g_strGameExePH;
    end
    else
    begin
      ProcessGame.CurrentDirectory := g_strGameDir;
      ProcessGame.Executable := g_strGameExe;
    end;

    if g_bApplyPatches and (MyMod.PatchLink <> '') and not PatchMgr_ValidateMod(MyMod, strTemp) then
    begin
      strTemp := g_strFixesDir + MyMod.Name;
      PatchMgr_CreateExtractDir(strTemp);
      frmDownloader.ResetJobs(GetTranslatedString(IDS_FRM_DOWNLOADER_PATCH) + MyMod.Name);
      frmDownloader.AddJob(CJOB_DOWNLOAD, [MyMod.PatchLink, g_strFixesDir + 'update.zip']);
      frmDownloader.AddJob(CJOB_EXTRACT, [strTemp, g_strFixesDir + 'update.zip', strTemp]);
      frmDownloader.AddJob(CJOB_PATCH, [MyMod.Name]);
      frmDownloader.AddJob(CJOB_PATCH_VALIDATION, [MyMod.Name]);
      frmDownloader.StartJobs;
      frmDownloader.ShowModal;
    end;

    if Server.Cmd <> '' then
    begin
      strFinalCmd := Server.Cmd;

      if MyMod.PrimalHunt then
      begin
        strFinalCmd := PlaceAVP2DirIntoPHCmd(strFinalCmd);
      end;

    end
    else
    begin
      if MyMod.CustomCmd <> '' then
      begin
        strFinalCmd := MyMod.CustomCmd;
      end
      else
      begin
        strFinalCmd := MyMod.DefaultCmd;
      end;

      if MyMod.PrimalHunt then
      begin
        strFinalCmd := PlaceAVP2DirIntoPHCmd(strFinalCmd);
      end;
    end;

    slD3D7FixExtraParams := TStringList.Create;
    strModAOString := ServerMgr_GetAOString(Server, MyMod, cgrpFastOptions, edtJoinPassword.Text, slD3D7FixExtraParams);
    strD3D7FixString := frmD3D7FixAO.GetGlobalProfileString(slD3D7FixExtraParams);

    strFinalCmd := strFinalCmd + strModAOString + strD3D7FixString;
    slD3D7FixExtraParams.Free;

    if strD3D7FixString <> '' then
    begin
      strTemp := GetD3D7FixVersion(MyMod.PrimalHunt);
      if (strTemp <> '') and (g_strD3D7FixVersionExpected <> strTemp) then
      begin
        Application.MessageBox(PChar(Format(GetTranslatedString(IDS_FRM_MAIN_MSG_UNSUPPORTED_D3D7FIX), [strTemp, g_strD3D7FixVersionExpected])),
          PChar(Application.Title), MB_OK + MB_ICONASTERISK);
      end;
    end;

    if ParseAVP2CommandLine(strFinalCmd, ProcessGame.Parameters) then
    begin
      g_Logger.Debug('btnJoinClick - starting game: %s %s', [ProcessGame.Executable, strFinalCmd]);
      ProcessGame.Execute;
    end
    else
    begin
      g_Logger.Debug('btnJoinClick - error while parsing commandline: %s %s', [ProcessGame.Executable, strFinalCmd]);
      Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_MAIN_MSG_ERRORCMDLINE), PChar(Application.Title), MB_OK + MB_ICONERROR);
      //'Error while parsing commandline!'
    end;
    ProcessGame.Free;
  end
  else
  begin
    Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_MAIN_MSG_PLSSELECTSERVER), PChar(Application.Title), MB_OK + MB_ICONASTERISK);
  end;
end;

procedure TfrmMain.btnLaunchModClick(Sender: TObject);
var MyMod: TModInfo;
    ListItem: TListItem;
    strFinalCmd: string;
    strTemp: string = '';
    strModAOString, strD3D7FixString: string;
    ProcessGame: TProcessUTF8;
    slD3D7FixExtraParams: TStringList;
begin
  ListItem := lvMods.Selected;
  if ListItem <> nil then
  begin
    MyMod := TModInfo(ListItem.Data);
    g_Logger.Info('TfrmMain.btnLaunchModClick - launching mod %s', [MyMod.Name]);

    ProcessGame := TProcessUTF8.Create(nil);
    if MyMod.PrimalHunt then
    begin
      ProcessGame.CurrentDirectory := g_strGameDirPH;
      ProcessGame.Executable := g_strGameExePH;
    end
    else
    begin
      ProcessGame.CurrentDirectory := g_strGameDir;
      ProcessGame.Executable := g_strGameExe;
    end;

    if g_bApplyPatches and (MyMod.PatchLink <> '') and not PatchMgr_ValidateMod(MyMod, strTemp) then
    begin
      strTemp := g_strFixesDir + MyMod.Name;
      PatchMgr_CreateExtractDir(strTemp);
      frmDownloader.ResetJobs(GetTranslatedString(IDS_FRM_DOWNLOADER_PATCH) + MyMod.Name);
      frmDownloader.AddJob(CJOB_DOWNLOAD, [MyMod.PatchLink, g_strFixesDir + 'update.zip']);
      frmDownloader.AddJob(CJOB_EXTRACT, [strTemp, g_strFixesDir + 'update.zip', strTemp]);
      frmDownloader.AddJob(CJOB_PATCH, [MyMod.Name]);
      frmDownloader.AddJob(CJOB_PATCH_VALIDATION, [MyMod.Name]);
      frmDownloader.StartJobs;
      frmDownloader.ShowModal;
    end;

    if MyMod.CustomCmd <> '' then
    begin
      strFinalCmd := MyMod.CustomCmd;
    end
    else
    begin
      strFinalCmd := MyMod.DefaultCmd;
    end;

    if MyMod.PrimalHunt then
    begin
      strFinalCmd := PlaceAVP2DirIntoPHCmd(strFinalCmd);
    end;

    slD3D7FixExtraParams := TStringList.Create;
    strModAOString := ServerMgr_GetAOStringForMod(cgrpFastOptionsMM, MyMod, slD3D7FixExtraParams);
    strD3D7FixString := frmD3D7FixAO.GetGlobalProfileString(slD3D7FixExtraParams);

    strFinalCmd := strFinalCmd + strModAOString + strD3D7FixString;
    slD3D7FixExtraParams.Free;

    if strD3D7FixString <> '' then
    begin
      strTemp := GetD3D7FixVersion(MyMod.PrimalHunt);
      if (strTemp <> '') and (g_strD3D7FixVersionExpected <> strTemp) then
      begin
        Application.MessageBox(PChar(Format(GetTranslatedString(IDS_FRM_MAIN_MSG_UNSUPPORTED_D3D7FIX), [strTemp, g_strD3D7FixVersionExpected])),
          PChar(Application.Title), MB_OK + MB_ICONASTERISK);
      end;
    end;

    if ParseAVP2CommandLine(strFinalCmd, ProcessGame.Parameters) then
    begin
      g_Logger.Debug('btnLaunchModClick - starting game: %s %s', [ProcessGame.Executable, strFinalCmd]);
      ProcessGame.Execute;
    end
    else
    begin
      g_Logger.Debug('btnLaunchModClick - error while parsing commandline: %s %s', [ProcessGame.Executable, strFinalCmd]);
      Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_MAIN_MSG_ERRORCMDLINE), PChar(Application.Title), MB_OK + MB_ICONERROR);
    end;
    ProcessGame.Free;
  end
  else
  begin
    Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_MAIN_MSG_PLSSELECTMOD), PChar(Application.Title), MB_OK + MB_ICONASTERISK);
  end;
end;

procedure TfrmMain.btnFavoritesClick(Sender: TObject);
begin
  if g_nMode = SM_FAVORITES then Exit;
  g_nMode := SM_FAVORITES;
  lvServers.Clear;
  lvPlayers.Clear;
  ClearServerFastInfo;
  btnFeatured.Font.Style := [];
  btnMasterServer.Font.Style := [];
  btnFavorites.Font.Style := [fsBold];
  mmiPPMAdd.Enabled := True;
  mmiPPMEdit.Enabled := True;
  mmiPPMDelete.Enabled := True;
  mmiPPMFavorite.Enabled := False;
  mmiAdd.Enabled := True;
  mmiEdit.Enabled := True;
  mmiDelete.Enabled := True;
  mmiMarkFavorite.Enabled := False;
  lvServers.Font.Color := g_clrFavoritesFC;
  g_SelectedServer := nil;

  if g_bAutoRefresh then
    btnRefreshAllClick(nil);
end;

procedure TfrmMain.btnDeleteModClick(Sender: TObject);
var CurMod: TModInfo;
    ListItem: TListItem;
    i: Integer;
begin
  ListItem := lvMods.Selected;
  if ListItem <> nil then
  begin
    CurMod := TModInfo(ListItem.Data);
    if (CurMod.FullyCustom) then
    begin
      if Application.MessageBox(PChar(Format(GetTranslatedString(IDS_FRM_MAIN_MSG_WANTOREMOVEMOD), [CurMod.Name])),
         PChar(Application.Title), MB_YESNO + MB_ICONQUESTION) = IDYES then
      // 'Do you want to remove custom mod "' + CurMod.Name + '"'
      begin
        i := g_Mods.IndexOf(CurMod);
        g_Mods.Delete(i);
        ServerMgr_SaveCustomMods;
        lvMods.Clear;
        for i := 0 to g_Mods.Count-1 do
        begin
          with lvMods do
          begin
            CurMod := TModInfo(g_Mods.Items[i]);
            ListItem := lvMods.Items.Add;

            if CurMod.FullyCustom then
              ListItem.ImageIndex := 5
            else
              ListItem.ImageIndex := 0;

            ListItem.Caption := CurMod.Name;
            ListItem.Data := CurMod;
            ListItem.SubItems.Add(CurMod.Description);
          end;
        end;
      end;
    end
    else
    begin
      Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_MAIN_MSG_DELETEONLYCUMOD), PChar(Application.Title), MB_OK + MB_ICONASTERISK);
      //You can delete only custom mod!
    end;
  end
  else
  begin
    Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_MAIN_MSG_PLSSELECTMOD), PChar(Application.Title), MB_OK + MB_ICONASTERISK);
  end;
end;

procedure TfrmMain.btnEditModClick(Sender: TObject);
var ListItem: TListItem;
begin
  ListItem := lvMods.Selected;
  if ListItem <> nil then
  begin
    g_ThisMod := TModInfo(ListItem.Data);
    g_MMAddMode := False;
    frmModOptions.Caption := GetTranslatedString(IDS_FRM_MODOPTIONS_EDIT) + g_ThisMod.Name;
    frmModOptions.FillMod;
    if frmModOptions.ShowModal = mrOK then
    begin
      ServerMgr_SaveCustomMods;
      if g_ThisMod.FullyCustom then
      begin
        ListItem.Caption := g_ThisMod.Name;
        ListItem.SubItems[0] := g_ThisMod.Description;
      end;
    end;
  end
  else
  begin
    Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_MAIN_MSG_PLSSELECTMOD), PChar(Application.Title), MB_OK + MB_ICONASTERISK);
  end;
end;

procedure TfrmMain.btnAddModClick(Sender: TObject);
var i: Integer;
    CurMod: TModInfo;
    ListItem: TListItem;
begin
  g_ThisMod := TModInfo.Create;
  g_ThisMod.Name := GetTranslatedString(IDS_FRM_MODOPTIONS_EDT_CUSTOMMOD);
  g_ThisMod.Description := GetTranslatedString(IDS_FRM_MODOPTIONS_EDT_CUSTOMDESC);
  g_ThisMod.FullyCustom := True;
  g_ThisMod.CustomCmd := GetTranslatedString(IDS_FRM_MODOPTIONS_MMO_CUSTOMCMD);
  g_MMAddMode := True;
  frmModOptions.Caption := GetTranslatedString(IDS_FRM_MODOPTIONS_ADD);
  frmModOptions.FillMod;
  if frmModOptions.ShowModal = mrOK then
  begin
    g_Mods.Add(g_ThisMod);
    ServerMgr_SaveCustomMods;
    lvMods.Clear;
    for i := 0 to g_Mods.Count-1 do
    begin
      with lvMods do
      begin
        CurMod := TModInfo(g_Mods.Items[i]);
        ListItem := lvMods.Items.Add;

        if CurMod.FullyCustom then
          ListItem.ImageIndex := 5
        else
          ListItem.ImageIndex := 0;

        ListItem.Caption := CurMod.Name;
        ListItem.Data := CurMod;
        ListItem.SubItems.Add(CurMod.Description);
      end;
    end;
  end
  else
  begin
    g_ThisMod.Free;
  end;
end;

procedure TfrmMain.btnMasterServerClick(Sender: TObject);
begin
  if g_nMode = SM_MASTER then Exit;
  g_nMode := SM_MASTER;
  lvServers.Clear;
  lvPlayers.Clear;
  ClearServerFastInfo;
  btnFeatured.Font.Style := [];
  btnMasterServer.Font.Style := [fsBold];
  btnFavorites.Font.Style := [];
  mmiPPMAdd.Enabled := False;
  mmiPPMEdit.Enabled := True;
  mmiPPMDelete.Enabled := False;
  mmiPPMFavorite.Enabled := True;
  mmiAdd.Enabled := False;
  mmiEdit.Enabled := True;
  mmiDelete.Enabled := False;
  mmiMarkFavorite.Enabled := True;
  lvServers.Font.Color := g_clrMasterServerFC;
  g_SelectedServer := nil;

  if g_bAutoRefresh then
    btnRefreshAllClick(nil);
end;

procedure TfrmMain.btnOptionsClick(Sender: TObject);
var i: Integer;
    CheckAO: TAOItem;
begin
  for i := 0 to cgrpFastOptions.Items.Count-1 do
  begin
    CheckAO := TAOItem(cgrpFastOptions.Items.Objects[i]);
    CheckAO.IsChecked := cgrpFastOptions.Checked[i];

    if CheckAO.IsChecked <> CheckAO.IsDefault then
      CheckAO.IsCustom := True
    else
      CheckAO.IsCustom := False;

  end;
  ServerMgr_SaveCustomMods(True);

  FillFastOptions;
  if lvMods.Selected = nil then
    FillFastOptionsMM(nil, False)
  else
    FillFastOptionsMM(lvMods.Selected, True);

  Application.MessageBox(GetTranslatedStringPChar(IDS_FO_SAVED), PChar(Application.Title), MB_OK + MB_ICONINFORMATION);
end;

procedure TfrmMain.btnOptionsMMClick(Sender: TObject);
var i: Integer;
    CheckAO: TAOItem;
begin
  for i := 0 to cgrpFastOptionsMM.Items.Count-1 do
  begin
    CheckAO := TAOItem(cgrpFastOptionsMM.Items.Objects[i]);
    CheckAO.IsChecked := cgrpFastOptionsMM.Checked[i];

    if CheckAO.IsChecked <> CheckAO.IsDefault then
      CheckAO.IsCustom := True
    else
      CheckAO.IsCustom := False;

  end;
  ServerMgr_SaveCustomMods(True);

  if lvMods.Selected = nil then
    FillFastOptionsMM(nil, False)
  else
    FillFastOptionsMM(lvMods.Selected, True);
  FillFastOptions;

  Application.MessageBox(GetTranslatedStringPChar(IDS_FO_SAVED), PChar(Application.Title), MB_OK + MB_ICONINFORMATION);
end;

procedure TfrmMain.btnRefreshAllClick(Sender: TObject);
var i: Integer;
    Server: TServer;
    List: TFPObjectList;
begin
  g_strRefreshAllError := GetTranslatedString(IDS_FRM_MAIN_CONST_ERRNOINFO);
  if (not g_bOnlineResult) and (g_nMode = SM_FEATURED) then
  begin
    Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_MAIN_MSG_NOFEATUREDSERVS), PChar(Application.Title), MB_OK + MB_ICONINFORMATION);
    //Featured server list is not available!
    Exit;
  end;
  RefreshCooldownBegin(True);
  g_nRefreshMode := RM_ALL;
  lvServers.Clear;
  lvPlayers.Clear;
  ServerMgr_ResetLastAlive(nil);
  List := ServerMgr_GetCurrentList;
  if (g_nMode = SM_FAVORITES) and (List.Count = 0) then
  begin
    Application.MessageBox(PChar(Format(GetTranslatedString(IDS_FRM_MAIN_MSG_SERVLISTEMPTY), [ServerMgr_GetCurrentListDesc])), PChar(Application.Title), MB_OK + MB_ICONINFORMATION);
    //'"' + ServerMgr_GetCurrentListDesc + '" server list is empty!'
    Exit;
  end;
  ServerMgr_WereRefreshed;
  if List <> nil then
  begin
    for i := 0 to List.Count-1 do
    begin
      Server := TServer(List.Items[i]);
      UDPServer.PrepareToSendString(Server.IP, Server.Port, UDP_STATUS, @Server.LastTime);
    end;
  end
  else
  begin
    Application.MessageBox(PChar(Format(GetTranslatedString(IDS_FRM_MAIN_MSG_CANTLOADLIST), [ServerMgr_GetCurrentListDesc, g_strRefreshAllError])), PChar(Application.Title), MB_OK + MB_ICONERROR);
    // 'Can''t load "' + ServerMgr_GetCurrentListDesc + '" list (' + g_strRefreshAllError + ')'
  end;
end;

procedure TfrmMain.imgMapshotClick(Sender: TObject);
begin
  if imgMapshot.Tag <> 0 then
  begin
    frmImagePreview.imgMapshot.Picture := imgMapshot.Picture;
    frmImagePreview.ShowModal;
  end;
end;

procedure TfrmMain.mmiD3D7FixAOClick(Sender: TObject);
begin
  frmD3D7FixAO.Clear;
  frmD3D7FixAO.FillOptions;
  frmD3D7FixAO.ShowModal;
end;

procedure TfrmMain.mmiD3D7FixClick(Sender: TObject);
begin
  mmiD3D7Fix.Caption := GetTranslatedString(IDS_D3D7FIX_INSTALL);
  frmAbout.OpenLink('https://github.com/thecanonmaster/d3d7fix_avp2/releases');
end;

procedure TfrmMain.mmiDebugMsgClick(Sender: TObject);
begin
  frmDebug.Caption := '';
  frmDebug.Clear;
  frmDebug.Show;
end;

procedure TfrmMain.mmiRemoveModPatchesClick(Sender: TObject);
var ListItem: TListItem;
    CurMod: TModInfo;
begin
  ListItem := lvMods.Selected;
  if ListItem <> nil then
  begin
    CurMod := TModInfo(ListItem.Data);
    if not CurMod.FullyCustom then
    begin
      DeleteFile(g_strFixesDir + CurMod.Name + '.txt');
      DeleteDirectory(g_strFixesDir + CurMod.Name, False);
      Application.MessageBox(PChar(GetTranslatedString(IDS_FRM_MAIN_MSG_PATCHES_REMOVED) + CurMod.Name), PChar(Application.Title), MB_OK + MB_ICONINFORMATION);
    end
    else
    begin
      Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_MAIN_MSG_NOTFORCUSTOMMODS), PChar(Application.Title), MB_OK + MB_ICONASTERISK);
    end;
  end
  else
  begin
    Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_MAIN_MSG_PLSSELECTMOD), PChar(Application.Title), MB_OK + MB_ICONASTERISK);
  end;
end;

function TfrmMain.RefreshDeadServers: Boolean;
var i: Integer;
    Server: TServer;
begin
  Result := False;
  RefreshCooldownBegin(False);
  g_nRefreshMode := RM_ALL;
  ServerMgr_WereRefreshed;

  i := 0;
  Server := ServerMgr_GetNextDeadServer(i);
  if Server = nil then Exit(True);
  while Server <> nil do
  begin
    UDPServer.PrepareToSendString(Server.IP, Server.Port, UDP_STATUS, @Server.LastTime);

    Inc(i, 1);
    Server := ServerMgr_GetNextDeadServer(i);
  end;
end;

procedure TfrmMain.btnRefreshClick(Sender: TObject);
var Server: TServer;
    ListItem: TListItem;
begin
  ListItem := lvServers.Selected;
  if ListItem <> nil then
  begin
    RefreshCooldownBegin(False);
    g_nRefreshMode := RM_SPECIFIC;
    Server := TServer(ListItem.Data);
    g_SelectedServer := Server;
    ServerMgr_ResetLastAlive(Server);
    g_Logger.Info('TfrmMain.btnRefreshClick - sending request to %s', [Server.Address]);
    UDPServer.PrepareToSendString(Server.IP, Server.Port, UDP_STATUS, @Server.LastTime);
  end
  else
  begin
    Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_MAIN_MSG_PLSSELECTSERVER), PChar(Application.Title), MB_OK + MB_ICONASTERISK);
  end;
end;

procedure TfrmMain.btnResetClick(Sender: TObject);
var i: Integer;
    CheckAO: TAOItem;
begin
  for i := 0 to cgrpFastOptions.Items.Count-1 do
  begin
    CheckAO := TAOItem(cgrpFastOptions.Items.Objects[i]);
    CheckAO.IsCustom := False;
    CheckAO.IsChecked := False;
  end;
  ServerMgr_SaveCustomMods(True);

  FillFastOptions;
  if lvMods.Selected = nil then
    FillFastOptionsMM(nil, False)
  else
    FillFastOptionsMM(lvMods.Selected, True);

  Application.MessageBox(GetTranslatedStringPChar(IDS_FO_RESET), PChar(Application.Title), MB_OK + MB_ICONINFORMATION);
end;

procedure TfrmMain.btnResetMMClick(Sender: TObject);
var i: Integer;
    CheckAO: TAOItem;
begin
  for i := 0 to cgrpFastOptionsMM.Items.Count-1 do
  begin
    CheckAO := TAOItem(cgrpFastOptionsMM.Items.Objects[i]);
    CheckAO.IsCustom := False;
    CheckAO.IsChecked := False;
  end;
  ServerMgr_SaveCustomMods(True);

  if lvMods.Selected = nil then
    FillFastOptionsMM(nil, False)
  else
    FillFastOptionsMM(lvMods.Selected, True);
  FillFastOptions;

  Application.MessageBox(GetTranslatedStringPChar(IDS_FO_RESET), PChar(Application.Title), MB_OK + MB_ICONINFORMATION);
end;

procedure TfrmMain.cgrpFastOptionsItemClick(Sender: TObject; Index: integer);
var i: Integer;
    CurAO, CheckAO: TAOItem;
begin
  if Index = 0 then
  begin
    if cgrpFastOptions.Checked[Index] then
    begin
      lblJoinPassword.Visible := True;
      edtJoinPassword.Visible := True;
    end
    else
    begin
      lblJoinPassword.Visible := False;
      edtJoinPassword.Visible := False;
      edtJoinPassword.Text := '';
    end;
  end
  else
  begin
    CurAO := TAOItem(cgrpFastOptions.Items.Objects[Index]);

    if (CurAO.IsMandatory) and not cgrpFastOptions.Checked[Index] then
    begin
      Application.MessageBox(PChar(Format(GetTranslatedString(IDS_FRM_MAIN_MSG_OPTIONMANDATORY), [CurAO.Title])), PChar(Application.Title), MB_OK + MB_ICONWARNING);
      //'Option "' + CurAO.Title + '" is required for playing on this server!'
    end
    else
    begin
      if (CurAO.Group > -1) and (cgrpFastOptions.Checked[Index]) then
      begin
        for i := 0 to cgrpFastOptions.Items.Count-1 do
        begin
          CheckAO := TAOItem(cgrpFastOptions.Items.Objects[i]);
          if (CheckAO.Group = CurAO.Group) and (CheckAO <> CurAO) then
          begin
            cgrpFastOptions.Checked[i] := False;
          end;
        end;
      end;
    end;
  end;
end;

procedure TfrmMain.cgrpFastOptionsMMItemClick(Sender: TObject; Index: integer);
var i: Integer;
    CurAO, CheckAO: TAOItem;
begin
  CurAO := TAOItem(cgrpFastOptionsMM.Items.Objects[Index]);
  if (CurAO.Group > -1) and (cgrpFastOptionsMM.Checked[Index]) then
  begin
    for i := 0 to cgrpFastOptionsMM.Items.Count-1 do
    begin
      CheckAO := TAOItem(cgrpFastOptionsMM.Items.Objects[i]);
      if (CheckAO.Group = CurAO.Group) and (CheckAO <> CurAO) then
      begin
        cgrpFastOptionsMM.Checked[i] := False;
      end;
    end;
  end;
end;

procedure TfrmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var Process: TProcessUTF8;
    UpdateParams: TStringList;
    strID: string;
    strUpdater: string;
begin
  tmrUpdate.Enabled := False;

  StopImagePreviewDownload(True);

  UDPServer.Terminate;
  UDPServer.Active := False;
  UDPServer.CloseSocket;
  UDPServer.WaitFor;
  UDPServer.Free;
  if g_bUpdateReady then
  begin
    strUpdater := g_strAppDir + 'Updater.exe';
    FileUtil.CopyFile(Application.ExeName, strUpdater, [cffOverwriteFile]);

    Process := TProcessUTF8.Create(nil);
    Process.Executable := strUpdater;
    Randomize;
    strID := IntToStr(Random(65535));
    if strID = '0' then strID := '1';
    g_Logger.Debug('Restart ID = %s', [strID]);
    Process.Parameters.Add('-u');
    Process.Parameters.Add('-i');
    Process.Parameters.Add(strID);
    UpdateParams := TStringList.Create;
    UpdateParams.Add(strID);
    UpdateParams.SaveToFile(g_strUpdateDir + 'update.txt');
    UpdateParams.Free;
    Sleep(500);
    Process.Execute;
    Sleep(500);
    Process.Free;
  end;
  DeleteCriticalSection(g_CS);
end;

procedure TfrmMain.mmiAboutClick(Sender: TObject);
begin
  frmAbout.tmrRainbow.Enabled := True;
  frmAbout.ShowModal;
end;

end.

