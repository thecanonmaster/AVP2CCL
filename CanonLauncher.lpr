program CanonLauncher;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces,
  Forms, main, common, servermgr, serverinfo, about, loading,
  setup, news, scriptmgr, pascalscript, downloader, serverao, modoptions,
  modinfo, SysUtils, debuginfo, MMSystem,
  image_preview, d3d7fixao, main_updater;

{$R *.res}

begin
  Application.Scaled := True;
  Application.Title := 'AVP2 Canon Launcher';

  if Application.HasOption('u', '') then
  begin
    RequireDerivedFormResource := True;
    Application.Initialize;
    Application.CreateForm(TfrmMainUpdater, frmMainUpdater);
    Application.Run;
    Exit;
  end;

  timeBeginPeriod(1);
  InitCommon(Application);

  frmDebug := nil;

  ServerMgr_Init;
  ServerMgr_LoadFavorites;
  ScriptMgr_Init;
  RequireDerivedFormResource := True;
  Application.Initialize;

  Application.CreateForm(TfrmMain, frmMain);
  frmMain.Translate;

  frmMain.Constraints.MinWidth := frmMain.Width;
  frmMain.Constraints.MinHeight := frmMain.Height;

  Application.CreateForm(TfrmServerInfo, frmServerInfo);
  frmServerInfo.Translate;
  Application.CreateForm(TfrmAbout, frmAbout);
  frmAbout.Translate;
  Application.CreateForm(TfrmLoading, frmLoading);
  frmLoading.Translate;
  Application.CreateForm(TfrmSetup, frmSetup);
  frmSetup.Translate;
  Application.CreateForm(TfrmNews, frmNews);
  frmNews.Translate;
  Application.CreateForm(TfrmDownloader, frmDownloader);
  frmDownloader.Translate;
  Application.CreateForm(TfrmAO, frmAO);
  frmAO.Translate;
  Application.CreateForm(TfrmModOptions, frmModOptions);
  frmModOptions.Translate;
  Application.CreateForm(TfrmModInfo, frmModInfo);
  frmModInfo.Translate;
  Application.CreateForm(TfrmDebug, frmDebug);
  frmDebug.Translate;
  Application.CreateForm(TfrmImagePreview, frmImagePreview);
  frmImagePreview.Translate;
  Application.CreateForm(TfrmD3D7FixAO, frmD3D7FixAO);
  frmD3D7FixAO.Translate;
  Application.Run;

  ScriptMgr_Destroy;
  ServerMgr_Destroy;

  DestroyCommon;
  timeEndPeriod(1);
end.

