unit loading;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  SynHTTPHelper, common, LCLType, ExtCtrls, IniFiles, scriptmgr, servermgr,
  Zipper, RegExpr;

type

  { TfrmLoading }

  TfrmLoading = class(TForm)
    lblLoadingInfo: TLabel;
    lblLoadingStatusCfg: TLabel;
    tmrClose: TTimer;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure tmrCloseTimer(Sender: TObject);
    procedure UnzipOnOpenInputStream(Sender: TObject; var AStream: TStream);
    procedure UnzipOnCloseInputStream(Sender: TObject; var AStream: TStream);
    procedure UnzipOnCreateOutStream(Sender: TObject; var AStream: TStream; AItem: TFullZipFileEntry);
    procedure UnzipOnDoneOutStream(Sender: TObject; var {%H-}AStream: TStream; AItem: TFullZipFileEntry);
    procedure Translate;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmLoading: TfrmLoading;
  DataLoader: TDownloadFileThread;
  DataStream: TMemoryStream;
  ExtractFileList: TStringList;
  g_bCanClose: Boolean = False;

implementation

uses translation_consts, main;

{$R *.lfm}

function GetMemoryStream(strFilename: string): TMemoryStream;
var
  nIndex: Integer;
begin
  nIndex := ExtractFileList.IndexOf(strFilename);
  Result := ExtractFileList.Objects[nIndex] as TMemoryStream;
end;

procedure TfrmLoading.UnzipOnOpenInputStream(Sender: TObject; var AStream: TStream);
begin
  AStream := DataStream;
end;

procedure TfrmLoading.UnzipOnCloseInputStream(Sender: TObject; var AStream: TStream);
begin
  AStream := nil;
end;

procedure TfrmLoading.UnzipOnCreateOutStream(Sender: TObject; var AStream: TStream; AItem: TFullZipFileEntry);
var
  nIndex: Integer;
begin
  nIndex := ExtractFileList.IndexOf(AItem.DiskFileName);
  if nIndex > -1 then
  begin
    AStream :=  TMemoryStream.Create;
    ExtractFileList.Objects[nIndex] := AStream;
  end;
end;

procedure TfrmLoading.UnzipOnDoneOutStream(Sender: TObject; var AStream: TStream; AItem: TFullZipFileEntry);
var
  nIndex: Integer;
begin
  nIndex := ExtractFileList.IndexOf(AItem.DiskFileName);
  if nIndex > -1 then (ExtractFileList.Objects[nIndex] as TMemoryStream).Position := 0;
end;

procedure DataLoaderCallback(bSuccess: Boolean; Stream: TMemoryStream; strErrorMsg: string; strData: String);
var UnZipper: TUnZipper;
    SL: TStringList;
    i: Integer;
    CurrStream: TMemoryStream;
begin
  if bSuccess then
  begin
    DataStream := Stream;

    UnZipper := TUnZipper.Create;
    UnZipper.OnOpenInputStream := @frmLoading.UnzipOnOpenInputStream;
    UnZipper.OnCloseInputStream := @frmLoading.UnzipOnCloseInputStream;
    UnZipper.OnCreateStream := @frmLoading.UnzipOnCreateOutStream;
    UnZipper.OnDoneStream := @frmLoading.UnzipOnDoneOutStream;
    UnZipper.UnZipAllFiles;
    UnZipper.Free;

    CurrStream := GetMemoryStream(ONLINE_CONFIG_FILENAME);
    CurrStream.SaveToFile(g_strDataDir + ONLINE_CONFIG_FILENAME);
    frmLoading.lblLoadingStatusCfg.Font.Color := clGreen;
    frmLoading.lblLoadingStatusCfg.Caption := GetTranslatedString(IDS_FRM_LOADING_LBL_DATASUCC);
    g_bOnlineResult := True;
    g_OnlineIni := TMemIniFile.Create(CurrStream);

    SL := TStringList.Create;
    SplitRegExpr(';', strData, SL);
    g_nOnlineIndexData := StrToInt(SL.Strings[SL.Count - 1]) + g_nDefaultOnlineData;
    SL.Free;

    LoadUpdateInfo;
    LoadImageCacheVars;
    ServerMgr_LoadFeatured;

    CurrStream := GetMemoryStream(ONLINE_SCRIPT_FILENAME);
    CurrStream.SaveToFile(g_strDataDir + ONLINE_SCRIPT_FILENAME);
    CurrStream.Position := 0;
    g_ScriptText.LoadFromStream(CurrStream);
    g_bCompileResult := ScriptMgr_Compile;
    if g_bCompileResult then
    begin
      ScriptMgr_UpdateLocalData(g_nOnlineIndexData);
    end;

    LoadD3D7FixOptions;
    LoadConfig_D3D7FixAOOnly;
  end
  else
  begin
    frmLoading.lblLoadingStatusCfg.Font.Color := clRed;
    frmLoading.lblLoadingStatusCfg.Caption := strErrorMsg;

    g_bNewOfflineMode := True;
    g_bOnlineResult := True;
    g_OnlineIni := TMemIniFile.Create(g_strDataDir + ONLINE_CONFIG_FILENAME);
    LoadUpdateInfo;
    LoadImageCacheVars;
    ServerMgr_LoadFeatured;

    g_ScriptText.LoadFromFile(g_strDataDir + ONLINE_SCRIPT_FILENAME);
    g_bCompileResult := ScriptMgr_Compile;
    if g_bCompileResult then
    begin
      ScriptMgr_UpdateLocalData(g_nOnlineIndexData);
    end;

    LoadD3D7FixOptions;
    LoadConfig_D3D7FixAOOnly;
  end;

  frmMain.FillVersionPanel;
  for i := 0 to ExtractFileList.Count - 1 do
  begin
    if ExtractFileList.Objects[i] <> nil then
      ExtractFileList.Objects[i].Free;
  end;
  ExtractFileList.Free;

  g_bCanClose := True;
  frmLoading.tmrClose.Enabled := True;
end;

procedure DataLoaderProgressCallback({%H-}nMsg: integer; {%H-}nData: integer);
begin

end;

{ TfrmLoading }

procedure TfrmLoading.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if not g_bCanClose then
    CloseAction := caNone;
end;

procedure TfrmLoading.FormCreate(Sender: TObject);
var i: Integer;
begin
  if not g_bOfflineMode then
  begin
    ExtractFileList := TStringList.Create;
    ExtractFileList.Add(ONLINE_CONFIG_FILENAME);
    ExtractFileList.Add(ONLINE_SCRIPT_FILENAME);

    DataLoader := TDownloadFileThread.Create;
    for i := g_nDefaultOnlineData to MAX_ONLINE_MIRRORS - 1 do
    begin
      if g_astrOnlineData[i] <> '' then
        DataLoader.URLs.Add(g_astrOnlineData[i]);
    end;
    SetLength(DataLoader.m_anValidityCheck, 2);
    DataLoader.m_anValidityCheck[0] := Ord('P');
    DataLoader.m_anValidityCheck[1] := Ord('K');
    DataLoader.Callback := @DataLoaderCallback;
    DataLoader.ProgressCallback := @DataLoaderProgressCallback;
    DataLoader.Start;
  end
  else
  begin
    g_OnlineIni := TMemIniFile.Create(g_strDataDir + ONLINE_CONFIG_FILENAME);
    g_ScriptText.LoadFromFile(g_strDataDir + ONLINE_SCRIPT_FILENAME);
    ServerMgr_LoadFeatured;
    g_bCompileResult := ScriptMgr_Compile;
    g_bCanClose := True;
    lblLoadingStatusCfg.Font.Color := clGreen;
    lblLoadingStatusCfg.Caption := GetTranslatedString(IDS_FRM_LOADING_LBL_DATASUCC);
    frmLoading.tmrClose.Enabled := True;
    g_bOnlineResult := True;
    LoadUpdateInfo;
  end;
end;

procedure TfrmLoading.tmrCloseTimer(Sender: TObject);
begin
  if not frmLoading.Visible then
    tmrClose.Enabled := False
  else
    Close;
end;

procedure TfrmLoading.Translate;
begin
  Caption := GetTranslatedString(IDS_FRM_LOADING);
  lblLoadingInfo.Caption := GetTranslatedString(IDS_FRM_LOADING_LBL_LOADING);
  lblLoadingStatusCfg.Caption := GetTranslatedString(IDS_FRM_LOADING_LBL_DATAWAIT);
end;


end.

