unit main_updater;

{$define LANG_TOOL}
//{$define CRYPTED_LANG}
{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, eventlog, LCLType, {utf8process,} JwaTlHelp32, IniFiles,
  BlowFish, LazFileUtils, logger;

const
  UPDATER_VERSION = '1.0.1.1-emb';
  CRYPTED_LANG_READBUF = 1024;

type

  { TfrmMainUpdater }

  TfrmMainUpdater = class(TForm)
    lblInfo: TLabel;
    tmrCooldown: TTimer;
    procedure FormClose(Sender: TObject; var {%H-}CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure tmrCooldownTimer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmMainUpdater: TfrmMainUpdater;
  g_strParameter: string;
  g_UpdLogger: TEventLogEx;
  g_strAppDir: string;
  g_strUserConfig: string;
  g_strUpdateDir: string;
  g_bAllIsGood: Boolean = False;
  g_strGameDir: string;
  g_strGameDirPH: string;
  g_strLang: string;
  g_slTranslatedStrings: TStringList;

procedure SaveResourceToStream(strName: string; MS: TMemoryStream);

implementation

uses translation_consts;

{$R *.lfm}

{ TfrmMainUpdater }

function GetTranslatedString(ID: TTranslateID): string;
begin
  Result := g_slTranslatedStrings.Strings[Ord(ID)];
end;

procedure GetProcessList(List: TStringList);
var
  pa: TProcessEntry32;
  RetVal: THandle;
begin
  RetVal := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  pa.dwSize := sizeof(pa);
  if Process32First(RetVal, pa) then
    List.Add(pa.szExeFile);

  while Process32Next(RetVal, pa) do
  begin
    List.Add(pa.szExeFile);
  end;
end;

procedure IniGuardInit;
var Ini: TMemIniFile;
begin
  g_strUserConfig := 'data\userconfig.ini';
  Ini := TMemIniFile.Create(g_strUserConfig);
  g_strGameDir := Ini.ReadString('Main', 'GameDir', '');
  g_strGameDirPH := Ini.ReadString('Main', 'GameDirPH', '');
  g_strLang := Ini.ReadString('Main', 'Lang', 'English');
  g_UpdLogger.Debug('IniGuard GameDir = ' + g_strGameDir);
  g_UpdLogger.Debug('IniGuard GameDir = ' + g_strGameDirPH);
  g_UpdLogger.Debug('Lang = ' + g_strLang);
  Ini.Free;
end;

procedure IniGuardSave;
var Ini: TMemIniFile;
begin
  Ini := TMemIniFile.Create(g_strUserConfig);
  Ini.WriteString('Main', 'GameDir', g_strGameDir);
  Ini.WriteString('Main', 'GameDirPH', g_strGameDirPH);
  Ini.WriteString('Main', 'Lang', g_strLang);
  Ini.UpdateFile;
  Ini.Free;
end;

procedure TfrmMainUpdater.FormCreate(Sender: TObject);
var UpdateParams: TStringList;
    ProcList: TStringList;
    nRetry, nIndex: Integer;
{$ifdef CRYPTED_LANG}
    nReadCount: Integer;
    DeFishStream: TBlowFishDeCryptStream;
    anBuffer: array[0..CRYPTED_LANG_READBUF] of Byte;
{$endif}
    DecryptedLangStream: TMemoryStream;
    CryptedLangStream: TMemoryStream;
{$ifdef LANG_TOOL}
    EnFishStream: TBlowFishEncryptStream;
{$endif}
begin
  g_strAppDir := ExtractFileDir(Application.ExeName) + '\';
  g_UpdLogger := TEventLogEx.Create(nil);
  g_UpdLogger.LogType := ltFile;
  g_UpdLogger.FileName := g_strAppDir + 'Updater.log';
  g_UpdLogger.Info('Updater started...');
  g_UpdLogger.Info('Version: ' + UPDATER_VERSION);

  g_strParameter := Application.GetOptionValue('e', '');

{$ifdef LANG_TOOL}
  if g_strParameter <> '' then
  begin
    CryptedLangStream := TMemoryStream.Create;
    DecryptedLangStream := TMemoryStream.Create;
    EnFishStream := TBlowFishEncryptStream.Create('Updater.log', CryptedLangStream);

    DecryptedLangStream.LoadFromFile(g_strParameter);
    EnFishStream.CopyFrom(DecryptedLangStream, DecryptedLangStream.Size);
    CryptedLangStream.SaveToFile(ExtractFileNameWithoutExt(g_strParameter) + '.dat');

    EnFishStream.Free;
    DecryptedLangStream.Free;
    CryptedLangStream.Free;

    g_UpdLogger.Free;

    Application.Terminate;
    Exit;
  end;
{$endif}

  IniGuardInit;
  g_slTranslatedStrings := TStringList.Create;
  DecryptedLangStream := TMemoryStream.Create;
{$ifdef CRYPTED_LANG}
  CryptedLangStream := TMemoryStream.Create;
  DeFishStream := TBlowFishDeCryptStream.Create('Updater.log', CryptedLangStream);

  SaveResourceToStream(g_strLang, CryptedLangStream);
  repeat
    nReadCount := DeFishStream.Read(anBuffer{%H-}, CRYPTED_LANG_READBUF);
    DecryptedLangStream.WriteBuffer(anBuffer, nReadCount);
  until nReadCount < CRYPTED_LANG_READBUF;
  DecryptedLangStream.Seek(0, soFromBeginning);
  g_slTranslatedStrings.LoadFromStream(DecryptedLangStream);

  DeFishStream.Free;
  DecryptedLangStream.Free;
  CryptedLangStream.Free;
{$else}
  SaveResourceToStream(g_strLang, DecryptedLangStream);
  g_slTranslatedStrings.LoadFromStream(DecryptedLangStream);
  DecryptedLangStream.Free;
{$endif}
  lblInfo.Caption := GetTranslatedString(IDS_UPDATER_APPLYUPDATE); //'Applying update, please wait...';
  g_strParameter := Application.GetOptionValue('i', '');
  if g_strParameter = '' then
  begin
    g_UpdLogger.Free;
    Application.Terminate;
    Exit;
  end;
  g_UpdLogger.Debug('Commandline = %s %s', [Application.Params[1], Application.Params[2]]);
  ProcList := TStringList.Create;
  Sleep(1000);
  nRetry := 0;
  GetProcessList(ProcList);
  nIndex := ProcList.IndexOf('CanonLauncher.exe');
  while nIndex > -1 do
  begin
    g_UpdLogger.Debug('Retry = %d, Index = %d', [nRetry, nIndex]);
    Sleep(1000);
    ProcList.Clear;
    GetProcessList(ProcList);
    Inc(nRetry, 1);
    if nRetry > 10 then
    begin
      g_UpdLogger.Error('Launcher process is still running!');
      ShowMessage(GetTranslatedString(IDS_UPDATER_LAUNCHERSTILLRUN)); //'Launcher process is still running!');
      g_slTranslatedStrings.Free;
      ProcList.Free;
      g_UpdLogger.Free;
      Exit;
    end
    else
    begin
      nIndex := ProcList.IndexOf('CanonLauncher.exe');
    end;
  end;

  ProcList.Free;
  UpdateParams := TStringList.Create;
  g_strUpdateDir := g_strAppDir + 'update\';
  UpdateParams.LoadFromFile(g_strUpdateDir + 'update.txt');
  DeleteFile(g_strUpdateDir + 'update.txt');
  if UpdateParams.Strings[0] <> g_strParameter then
  begin
    g_UpdLogger.Error('Parameters are not equal! %s <> %s', [g_strParameter, UpdateParams.Strings[0]]);
    lblInfo.Font.Color := clRed;
    lblInfo.Caption := GetTranslatedString(IDS_UPDATER_SMTHWENTWRONG); //'Something went wrong, update failed!';
    UpdateParams.Free;
    tmrCooldown.Enabled := True;
    g_slTranslatedStrings.Free;
    g_UpdLogger.Free;
    Exit;
  end;
  UpdateParams.Free;
  g_UpdLogger.Debug('Unique ID = ' + g_strParameter);

  try
    CopyDirTree(g_strUpdateDir, g_strAppDir, [cffOverwriteFile]);
  except
    on E: Exception do
    begin
      g_UpdLogger.Error('Error during copying new files! - ' + E.Message);
      lblInfo.Font.Color := clRed;
      lblInfo.Caption := GetTranslatedString(IDS_UPDATER_ERRORCOPY); //'Error during copying new files, update failed!';
      tmrCooldown.Enabled := True;
      g_UpdLogger.Free;
      Exit;
    end;
  end;

  IniGuardSave;

  g_UpdLogger.Info('Copying new files successful');
  lblInfo.Font.Color := clGreen;
  lblInfo.Caption := GetTranslatedString(IDS_UPDATER_READY); //'You can now restart the application!';
  g_bAllIsGood := True;
  tmrCooldown.Enabled := True;
  g_slTranslatedStrings.Free;
end;

procedure TfrmMainUpdater.tmrCooldownTimer(Sender: TObject);
begin
  if g_bAllIsGood then
  begin
    DeleteFile(g_strUpdateDir + 'update.txt');
    tmrCooldown.Enabled := False;
    Sleep(2000);
  end;
  Close;
end;

procedure TfrmMainUpdater.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  g_UpdLogger.Info('Updater stopped...');
  g_UpdLogger.Free;
end;

procedure SaveResourceToStream(strName: string; MS: TMemoryStream);
var
  RS: TResourceStream;
begin
  RS := TResourceStream.Create(HInstance, strName, RT_RCDATA);
  MS.LoadFromStream(RS);
  RS.Free;
end;

end.

