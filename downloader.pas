unit downloader;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ExtCtrls, zipper, common, LCLType, SynHTTPHelper, Contnrs, patchmgr;

const
  CSTATUS_PERCENT = 'd %';
  CPARAM_DOWNLOAD_LINK = 0;
  CPARAM_EXTRACT_DIR = 2;
  CPARAM_SLEEP_VALUE = 0;
  CPARAM_FILE_PATH = 1;
  CPARAM_DIR_TO_CREATE = 0;
  CPARAM_PATCH_MOD = 0;
  C_MAX_PARAMS = 3;
  C_PATCH_INI_FILENAME = 'patch.ini';

type

  { TDownloaderJob }

  TDownloaderJob = class(TObject)
    m_strName: string;
    m_astrParams: TStringArray;
    m_nParamCount: Integer;
    procedure AddParam(strParam: string);
    constructor Create(strName: string);
    destructor Destroy; override;
  end;

  { TfrmDownloader }

  TfrmDownloader = class(TForm)
    btnCancel: TButton;
    lvJobs: TListView;
    tmrRunner: TTimer;
    procedure btnCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var {%H-}CloseAction: TCloseAction);
    procedure tmrRunnerTimer(Sender: TObject);
    procedure Translate;

    procedure HandleDownloadJob;
    procedure HandleExtractJob;
    procedure HandlePatchJob;
    procedure HandlePatchValidationJob;
    procedure HandleFinalizingJob;
    procedure HandleSleepJob;
  private
    { private declarations }
  public
    { public declarations }
    procedure AddJob(strJob: string; {%H-}astrParams: array of string);
    procedure ResetJobs(strTitle: string);
    procedure StartJobs;
  end;

var
  frmDownloader: TfrmDownloader;
  g_nJobIndex: Integer = 0;
  g_nDownloadMode: Integer;
  g_HTTPDownloader: TDownloadFileThread = nil;
  g_pDownloaderParams: TFPObjectList;
  g_slUnzippedFiles: TStringList = nil;
  g_pPatchModThread: TPatchModThread = nil;
  CJOB_DOWNLOAD: string;
  CJOB_EXTRACT: string;
  CJOB_PATCH: string;
  CJOB_PATCH_VALIDATION: string;
  CJOB_FINALIZING: string;
  CJOB_SLEEP: string;
  CSTATUS_PENDING: string;
  CSTATUS_IN_PROGRESS: string;
  CSTATUS_READY: string;
  CSTATUS_FAILED: string;

implementation

uses translation_consts, servermgr;

{$R *.lfm}

function GetJobName(nIndex: Integer): string;
begin
  Result := TDownloaderJob(g_pDownloaderParams.Items[nIndex]).m_strName;
end;

function GetJobParams(nIndex: Integer): TStringArray;
begin
  Result := TDownloaderJob(g_pDownloaderParams.Items[nIndex]).m_astrParams;
end;

procedure HTTPDownloaderCallback(bSuccess: Boolean; Stream: TMemoryStream; strErrorMsg: string; {%H-}strData: String);
begin
  if bSuccess then
  begin
    Stream.SaveToFile(GetJobParams(g_nJobIndex)[CPARAM_FILE_PATH]);
    frmDownloader.lvJobs.Items[g_nJobIndex].SubItems[0] := CSTATUS_READY;
    frmDownloader.lvJobs.Items[g_nJobIndex].ImageIndex := 3;
    g_nDownloadMode := MYMSG_END;
  end
  else
  begin
    frmDownloader.lvJobs.Items[g_nJobIndex].SubItems[0] := strErrorMsg;
    frmDownloader.lvJobs.Items[g_nJobIndex].ImageIndex := 1;
    g_nDownloadMode := MYMSG_ERROR;
  end;
  g_HTTPDownloader := nil;
end;

procedure HTTPDownloaderCallbackProgress(nMsg: integer; nData: integer);
begin
  if nMsg = MYMSG_FILE then
  begin
    frmDownloader.lvJobs.Items[g_nJobIndex].SubItems[0] := IntToStr(nData) + ' %';
  end;
end;

function UnzipArchive(strFilename: string; strOutPath: string): string;
var UnZipper: TUnZipper = nil;
    i: Integer;
begin
  Result := '';
  try
    UnZipper := TUnZipper.Create;
    UnZipper.FileName := strFilename;
    UnZipper.OutputPath := strOutPath;
    UnZipper.UnZipAllFiles;

    for i := 0 to UnZipper.Entries.Count - 1 do
    begin
      if UnZipper.Entries[i].DiskFileName <> C_PATCH_INI_FILENAME then
        g_slUnzippedFiles.AddStrings(UnZipper.Entries[i].DiskFileName);
    end;

    DeleteFile(strFilename);
    UnZipper.Free;
  except
    on E: Exception do
    begin
      if UnZipper <> nil then UnZipper.Free;
      Result := E.Message;
    end;
  end;
end;

{ TDownloaderJob }

procedure TDownloaderJob.AddParam(strParam: string);
begin
  m_astrParams[m_nParamCount] := strParam;
  Inc(m_nParamCount, 1)
end;

constructor TDownloaderJob.Create(strName: string);
begin
  m_strName := strName;
  m_nParamCount := 0;
  SetLength(m_astrParams, C_MAX_PARAMS);
end;

destructor TDownloaderJob.Destroy;
begin
  SetLength(m_astrParams, 0);
  inherited Destroy;
end;

{ TfrmDownloader }

procedure TfrmDownloader.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
  Close;
end;

procedure TfrmDownloader.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  tmrRunner.Enabled := False;

  if g_HTTPDownloader <> nil then
  begin
    g_HTTPDownloader.Abort;
    g_HTTPDownloader.Terminate;
  end;
  g_HTTPDownloader := nil;

  if g_pPatchModThread <> nil then
  begin
    g_pPatchModThread.WaitFor;
    g_pPatchModThread := nil;
  end;

  if g_pDownloaderParams <> nil then
    FreeAndNil(g_pDownloaderParams);

  if g_slUnzippedFiles <> nil then
    FreeAndNil(g_slUnzippedFiles);
end;

procedure TfrmDownloader.tmrRunnerTimer(Sender: TObject);
var strJob: string;
begin
  if g_nJobIndex = lvJobs.Items.Count then
  begin
    tmrRunner.Enabled := False;
    ModalResult := mrOK;
  end
  else
  begin
    if g_pDownloaderParams = nil then Exit;
    strJob := GetJobName(g_nJobIndex);
    if strJob = CJOB_DOWNLOAD then
      HandleDownloadJob
    else if strJob = CJOB_EXTRACT then
      HandleExtractJob
    else if strJob = CJOB_FINALIZING then
      HandleFinalizingJob
    else if strJob = CJOB_PATCH then
      HandlePatchJob
    else if strJob = CJOB_PATCH_VALIDATION then
      HandlePatchValidationJob
    else if strJob = CJOB_SLEEP then
      HandleSleepJob;
  end;
end;

procedure TfrmDownloader.Translate;
begin
  Caption := GetTranslatedString(IDS_FRM_DOWNLOADER);
  lvJobs.Column[0].Caption := GetTranslatedString(IDS_FRM_DOWNLOADER_COL_JOB);
  lvJobs.Column[1].Caption := GetTranslatedString(IDS_FRM_DOWNLOADER_COL_STATUS);
  btnCancel.Caption := GetTranslatedString(IDS_FRM_DOWNLOADER_BTN_CANCEL);

  CJOB_DOWNLOAD := GetTranslatedString(IDS_FRM_DOWNLOADER_CONST_DOWNLOAD);
  CJOB_EXTRACT := GetTranslatedString(IDS_FRM_DOWNLOADER_CONST_UNPACK);
  CJOB_SLEEP := GetTranslatedString(IDS_FRM_DOWNLOADER_CONST_WAIT);
  CJOB_PATCH := GetTranslatedString(IDS_FRM_DOWNLOADER_CONST_PATCH);
  CJOB_PATCH_VALIDATION := GetTranslatedString(IDS_FRM_DOWNLOADER_CONST_PATCHVAL);
  CJOB_FINALIZING := GetTranslatedString(IDS_FRM_DOWNLOADER_CONST_FINAL);

  CSTATUS_PENDING := GetTranslatedString(IDS_FRM_DOWNLOADER_CONST_NOTSTARTED);
  CSTATUS_IN_PROGRESS := GetTranslatedString(IDS_FRM_DOWNLOADER_CONST_INPROGRESS);
  CSTATUS_READY := GetTranslatedString(IDS_FRM_DOWNLOADER_CONST_DONE);
  CSTATUS_FAILED := GetTranslatedString(IDS_FRM_DOWNLOADER_CONST_FAILED);
end;

procedure TfrmDownloader.HandleDownloadJob;
begin
  case g_nDownloadMode of
    MYMSG_NONE:
      begin
        g_nDownloadMode := MYMSG_START;
        g_HTTPDownloader := TDownloadFileThread.Create;
        g_HTTPDownloader.URLs.Add(GetJobParams(g_nJobIndex)[CPARAM_DOWNLOAD_LINK]);
        SetLength(g_HTTPDownloader.m_anValidityCheck, 0);
        g_HTTPDownloader.Callback := @HTTPDownloaderCallback;
        g_HTTPDownloader.ProgressCallback := @HTTPDownloaderCallbackProgress;
        g_HTTPDownloader.Start;
        lvJobs.Items[g_nJobIndex].SubItems[0] := '0 %';
      end;
    MYMSG_ERROR:
      begin
        tmrRunner.Enabled := False;
        Application.MessageBox(PChar(GetTranslatedString(IDS_FRM_DOWNLOADER_MSG_ERROR) + lvJobs.Items[g_nJobIndex].SubItems[0]),
          PChar(Application.Title), MB_OK + MB_ICONERROR);
      end;
    MYMSG_END:
      begin
        Inc(g_nJobIndex, 1);
      end;
  end;
end;

procedure TfrmDownloader.HandleExtractJob;
var strError: string;
begin
  CreateDir(GetJobParams(g_nJobIndex)[CPARAM_DIR_TO_CREATE]);
  strError := UnzipArchive(GetJobParams(g_nJobIndex)[CPARAM_FILE_PATH], GetJobParams(g_nJobIndex)[CPARAM_EXTRACT_DIR]);
  if strError = '' then
  begin
    lvJobs.Items[g_nJobIndex].SubItems[0] := CSTATUS_READY;
    lvJobs.Items[g_nJobIndex].ImageIndex := 3;
  end
  else
  begin
    tmrRunner.Enabled := False;
    lvJobs.Items[g_nJobIndex].SubItems[0] := strError;
    lvJobs.Items[g_nJobIndex].ImageIndex := 1;
    Application.MessageBox(PChar(GetTranslatedString(IDS_FRM_DOWNLOADER_MSG_ERR_EXTRACT) + strError),
      PChar(Application.Title), MB_OK + MB_ICONERROR);
  end;
  Inc(g_nJobIndex, 1);
end;

procedure PatchModCallback(bSuccess: Boolean; {%H-}strInfo: String; strError: String);
var strPatchIni: string;
    astrInfo: TStringArray;
    i: Integer;
begin
  strPatchIni := g_strFixesDir + GetJobParams(g_nJobIndex)[CPARAM_PATCH_MOD] + '\' + C_PATCH_INI_FILENAME;
  if bSuccess then
  begin
    frmDownloader.tmrRunner.Enabled := True;
    frmDownloader.lvJobs.Items[g_nJobIndex].SubItems[0] := CSTATUS_READY;
    frmDownloader.lvJobs.Items[g_nJobIndex].ImageIndex := 3;
    if g_Logger.CheckLevel(etDebug) then
    begin
      astrInfo := strInfo.Split(#10#13, TStringSplitOptions.ExcludeEmpty);
      for i := 0 to Length(astrInfo) - 1 do
      begin
        g_Logger.Debug(astrInfo[i]);
      end;
      SetLength(astrInfo, 0);
    end;
  end
  else
  begin
    frmDownloader.lvJobs.Items[g_nJobIndex].SubItems[0] := CSTATUS_FAILED;
    frmDownloader.lvJobs.Items[g_nJobIndex].ImageIndex := 1;
    Application.MessageBox(PChar(GetTranslatedString(IDS_FRM_DOWNLOADER_MSG_ERR_PATCH) + strError),
      PChar(Application.Title), MB_OK + MB_ICONERROR);
  end;
  g_pPatchModThread := nil;
  DeleteFile(strPatchIni);
  Inc(g_nJobIndex, 1);
end;

procedure TfrmDownloader.HandlePatchJob;
var strPatchIni: string;
begin
  lvJobs.Items[g_nJobIndex].SubItems[0] := CSTATUS_IN_PROGRESS;
  strPatchIni := g_strFixesDir + GetJobParams(g_nJobIndex)[CPARAM_PATCH_MOD] + '\' + C_PATCH_INI_FILENAME;
  tmrRunner.Enabled := False;

  g_pPatchModThread := TPatchModThread.Create(ServerMgr_FindMod(GetJobParams(g_nJobIndex)[CPARAM_PATCH_MOD]),
    strPatchIni, g_slUnzippedFiles);
  g_pPatchModThread.Callback := @PatchModCallback;
  g_pPatchModThread.FreeOnTerminate := True;
  g_pPatchModThread.Start;
end;

procedure TfrmDownloader.HandlePatchValidationJob;
var strError: string = '';
begin
  if not PatchMgr_ValidateMod(ServerMgr_FindMod(GetJobParams(g_nJobIndex)[CPARAM_PATCH_MOD]), strError) then
  begin
    tmrRunner.Enabled := False;
    lvJobs.Items[g_nJobIndex].SubItems[0] := CSTATUS_FAILED;
    lvJobs.Items[g_nJobIndex].ImageIndex := 1;
    Application.MessageBox(PChar(GetTranslatedString(IDS_FRM_DOWNLOADER_MSG_ERR_VALIDATION) + strError),
      PChar(Application.Title), MB_OK + MB_ICONERROR);
  end
  else
  begin
    lvJobs.Items[g_nJobIndex].SubItems[0] := CSTATUS_READY;
    lvJobs.Items[g_nJobIndex].ImageIndex := 3;
  end;
  Inc(g_nJobIndex, 1);
end;

procedure TfrmDownloader.HandleFinalizingJob;
begin
  lvJobs.Items[g_nJobIndex].SubItems[0] := CSTATUS_READY;
  lvJobs.Items[g_nJobIndex].ImageIndex := 3;
  tmrRunner.Enabled := False;
  Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_DOWNLOADER_MSG_RESTART), PChar(Application.Title), MB_OK + MB_ICONASTERISK);
  g_bUpdateReady := True;
  ModalResult := mrOK;
end;

procedure TfrmDownloader.HandleSleepJob;
begin
  Sleep(GetJobParams(g_nJobIndex)[CPARAM_SLEEP_VALUE].ToInteger);
  lvJobs.Items[g_nJobIndex].SubItems[0] := CSTATUS_READY;
  lvJobs.Items[g_nJobIndex].ImageIndex := 3;
  Inc(g_nJobIndex, 1);
end;

procedure TfrmDownloader.AddJob(strJob: string; astrParams: array of string);
var ListItem: TListItem;
    pJob: TDownloaderJob;
begin
  pJob := TDownloaderJob.Create(strJob);
  if strJob = CJOB_DOWNLOAD then
  begin
    pJob.AddParam(astrParams[CPARAM_DOWNLOAD_LINK]);
    pJob.AddParam(astrParams[CPARAM_FILE_PATH]);
  end
  else if strJob = CJOB_EXTRACT then
  begin
    pJob.AddParam(astrParams[CPARAM_DIR_TO_CREATE]);
    pJob.AddParam(astrParams[CPARAM_FILE_PATH]);
    pJob.AddParam(astrParams[CPARAM_EXTRACT_DIR]);
  end
  else if (strJob = CJOB_PATCH) or (strJob = CJOB_PATCH_VALIDATION) then
  begin
    pJob.AddParam(astrParams[CPARAM_PATCH_MOD]);
  end
  else if strJob = CJOB_SLEEP then
  begin
    pJob.AddParam(astrParams[CPARAM_SLEEP_VALUE]);
  end;

  g_pDownloaderParams.Add(pJob);
  ListItem := lvJobs.Items.Add;
  ListItem.ImageIndex := 2;
  ListItem.Caption := pJob.m_strName;
  ListItem.SubItems.Add(CSTATUS_PENDING);
end;

procedure TfrmDownloader.ResetJobs(strTitle: string);
begin
  frmDownloader.Caption := strTitle;
  lvJobs.Clear;
  g_nDownloadMode := MYMSG_NONE;
  g_nJobIndex := 0;

  if g_pDownloaderParams <> nil then
    FreeAndNil(g_pDownloaderParams);
  g_pDownloaderParams := TFPObjectList.Create;

  if g_slUnzippedFiles <> nil then
    FreeAndNil(g_slUnzippedFiles);
  g_slUnzippedFiles := TStringList.Create;
end;

procedure TfrmDownloader.StartJobs;
begin
  tmrRunner.Enabled := True;
end;

end.

