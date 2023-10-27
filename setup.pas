unit setup;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LazFileUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  LCLType, ExtCtrls, ColorBox, common, LazUTF8;

type

  { TfrmSetup }

  TfrmSetup = class(TForm)
    btnBrowse: TButton;
    btnBrowsePH: TButton;
    btnOk: TButton;
    btnCancel: TButton;
    cbxHideNews: TCheckBox;
    cbxUnlimitedResize: TCheckBox;
    cgrbColumn: TCheckGroup;
    cbxTopTabs: TCheckBox;
    cbxAutoRefresh: TCheckBox;
    cbxPlayersSort: TCheckBox;
    clrbxFeaturedFC: TColorBox;
    clrbxMasterFC: TColorBox;
    clrbxFavoritesFC: TColorBox;
    cobxLang: TComboBox;
    edtGameDir: TEdit;
    edtGameDirPH: TEdit;
    edtLocalPort: TEdit;
    edtLocalPortTCP: TEdit;
    gbxSetup: TGroupBox;
    gbxColors: TGroupBox;
    lblLang: TLabel;
    lblFeaturedFontColor: TLabel;
    lblMSFontColor: TLabel;
    lblFavoritesFontColor: TLabel;
    lblGameDirPH: TLabel;
    lblLocalPortTCP: TLabel;
    lblGameDir: TLabel;
    lblLocalPort: TLabel;
    sddGameDir: TSelectDirectoryDialog;
    procedure btnBrowseClick(Sender: TObject);
    procedure btnBrowsePHClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure cobxLangSelect(Sender: TObject);
    procedure FormClose(Sender: TObject; var {%H-}CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure gbxWebChatOptionsClick(Sender: TObject);
    procedure Translate;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmSetup: TfrmSetup;

implementation

uses main, translation_consts, serverinfo, about, loading, news, downloader,
  serverao, modoptions, modinfo, debuginfo, image_preview, d3d7fixao;

{$R *.lfm}

{ TfrmSetup }

procedure TfrmSetup.btnCancelClick(Sender: TObject);
var nIndex: Integer;
begin
  edtGameDir.Text := ExtractFileDir(g_strGameDir);
  edtGameDirPH.Text := ExtractFileDir(g_strGameDirPH);
  edtLocalPort.Text := g_strLocalUDPPort;
  edtLocalPortTCP.Text := g_strLocalTCPPort;

  nIndex := cobxLang.Items.IndexOf(g_strLang);
  if nIndex = -1 then nIndex := 0;
  cobxLang.ItemIndex := nIndex;
  g_strLang := cobxLang.Text;
  LoadTranslation;
  Translate;

  Close;
end;

procedure TfrmSetup.btnOkClick(Sender: TObject);
var i: Integer;
    bRetranslate: Boolean;
begin
  try
    i := StrToInt(edtLocalPort.Text);
  except
    on E: Exception do
    begin
      Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_SETUP_MSG_UDPPORTINVALID), PChar(Application.Title), MB_OK + MB_ICONERROR);
      Exit;
    end;
  end;

  try
    i := StrToInt(edtLocalPortTCP.Text);
  except
    on E: Exception do
    begin
      Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_SETUP_MSG_TCPPORTINVALID), PChar(Application.Title), MB_OK + MB_ICONERROR);
      Exit;
    end;
  end;

  if edtGameDir.Text = '' then
  begin
    Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_SETUP_MSG_SETAVP2DIR), PChar(Application.Title), MB_OK + MB_ICONERROR);
    Exit;
  end;

  if cbxUnlimitedResize.Checked <> g_bUnlimitedResize then
  begin
    Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_SETUP_MSG_RESTARTNEEDED), PChar(Application.Title), MB_OK + MB_ICONINFORMATION);
  end;

  g_strGameDir := edtGameDir.Text;
  g_strGameDirPH := edtGameDirPH.Text;
  if g_strGameDir <> '' then g_strGameDir := g_strGameDir + '\';
  if g_strGameDirPH <> '' then g_strGameDirPH := g_strGameDirPH + '\';

  g_strGameExe := g_strGameDir + LITHTECH_EXE;
  g_strGameExePH := g_strGameDirPH + LITHTECH_EXE;
  g_strFixesDir := g_strGameDir + AVP2FIXES_DIR;

  g_strLocalUDPPort := edtLocalPort.Text;
  g_strLocalTCPPort := edtLocalPortTCP.Text;

  bRetranslate := False;
  if g_strLang <> cobxLang.Text then
    bRetranslate := True;
  g_strLang := cobxLang.Text;

  g_clrFeaturedFC := clrbxFeaturedFC.Selected;
  g_clrMasterServerFC := clrbxMasterFC.Selected;
  g_clrFavoritesFC := clrbxFavoritesFC.Selected;

  g_bTabPosTop := cbxTopTabs.Checked;
  g_bAutoRefresh := cbxAutoRefresh.Checked;
  g_bAutoSort := cbxPlayersSort.Checked;
  g_bHideNews := cbxHideNews.Checked;
  g_bUnlimitedResize := cbxUnlimitedResize.Checked;

  for i := 0 to frmMain.lvServers.Columns.Count - 1 do
  begin
    g_ColumnSetup.Bits[i] := cgrbColumn.Checked[i];
  end;
  SaveConfig;
  frmMain.ApplyColumnSetup;

  if bRetranslate then
  begin
    Translate;
    frmMain.Translate;
    frmServerInfo.Translate;
    frmAbout.Translate;
    frmLoading.Translate;
    frmNews.Translate;
    frmDownloader.Translate;
    frmAO.Translate;
    frmModOptions.Translate;
    frmModInfo.Translate;
    frmDebug.Translate;
    frmImagePreview.Translate;
    frmD3D7FixAO.Translate;
  end;

  Close;
end;

procedure TfrmSetup.cobxLangSelect(Sender: TObject);
var i: Integer;
    strBackup: string;
begin
  strBackup := g_strLang;
  g_strLang := cobxLang.Text;
  LoadTranslation;
  Translate;

  cgrbColumn.Visible := False;
  cgrbColumn.Items.Clear;
  for i := 0 to frmMain.lvServers.Columns.Count - 1 do
  begin
    cgrbColumn.Items.Add(GetTranslatedString(Ord(IDS_FRM_MAIN_COL_SERVERNAME) + i));
    cgrbColumn.Checked[i] := g_ColumnSetup.Bits[i];
  end;
  cgrbColumn.Visible := True;

  g_strLang := strBackup;
end;

procedure TfrmSetup.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var i, nIndex: Integer;
begin
  edtGameDir.Text := ExtractFileDir(g_strGameDir);
  edtGameDirPH.Text := ExtractFileDir(g_strGameDirPH);
  edtLocalPort.Text := g_strLocalUDPPort;
  edtLocalPortTCP.Text := g_strLocalTCPPort;

  nIndex := cobxLang.Items.IndexOf(g_strLang);
  if nIndex = -1 then nIndex := 0;
  cobxLang.ItemIndex := nIndex;
  g_strLang := cobxLang.Text;
  LoadTranslation;
  Translate;

  clrbxFeaturedFC.Selected := g_clrFeaturedFC;
  clrbxMasterFC.Selected := g_clrMasterServerFC;
  clrbxFavoritesFC.Selected := g_clrFavoritesFC;

  cbxTopTabs.Checked := g_bTabPosTop;
  cbxAutoRefresh.Checked := g_bAutoRefresh;
  cbxPlayersSort.Checked := g_bAutoSort;
  cbxHideNews.Checked := g_bHideNews;
  cbxUnlimitedResize.Checked := g_bUnlimitedResize;

  cgrbColumn.Visible := False;
  cgrbColumn.Items.Clear;
  for i := 0 to frmMain.lvServers.Columns.Count - 1 do
  begin
    cgrbColumn.Items.Add(GetTranslatedString(Ord(IDS_FRM_MAIN_COL_SERVERNAME) + i));
    cgrbColumn.Checked[i] := g_ColumnSetup.Bits[i];
  end;
  cgrbColumn.Visible := True;

  Close;
end;

procedure TfrmSetup.FormCreate(Sender: TObject);
var i, nIndex: Integer;
begin
  edtGameDir.Text := ExtractFileDir(g_strGameDir);
  edtGameDirPH.Text := ExtractFileDir(g_strGameDirPH);

  edtLocalPort.Text := g_strLocalUDPPort;
  edtLocalPortTCP.Text := g_strLocalTCPPort;

  SaveResourceToStringList('LANGS', cobxLang.Items);

  nIndex := cobxLang.Items.IndexOf(g_strLang);
  if nIndex = -1 then nIndex := 0;
  cobxLang.ItemIndex := nIndex;

  clrbxFeaturedFC.Items.AddObject('Default', TObject(clDefault));
  clrbxMasterFC.Items.AddObject('Default', TObject(clDefault));
  clrbxFavoritesFC.Items.AddObject('Default', TObject(clDefault));

  clrbxFeaturedFC.Selected := g_clrFeaturedFC;
  clrbxMasterFC.Selected := g_clrMasterServerFC;
  clrbxFavoritesFC.Selected := g_clrFavoritesFC;

  cbxTopTabs.Checked := g_bTabPosTop;
  cbxAutoRefresh.Checked := g_bAutoRefresh;
  cbxPlayersSort.Checked := g_bAutoSort;
  cbxHideNews.Checked := g_bHideNews;
  cbxUnlimitedResize.Checked := g_bUnlimitedResize;

  cgrbColumn.Visible := False;
  for i := 0 to frmMain.lvServers.Columns.Count - 1 do
  begin
    cgrbColumn.Items.Add(GetTranslatedString(Ord(IDS_FRM_MAIN_COL_SERVERNAME) + i));
    cgrbColumn.Checked[i] := g_ColumnSetup.Bits[i];
  end;
  cgrbColumn.Visible := True;
end;

procedure TfrmSetup.gbxWebChatOptionsClick(Sender: TObject);
begin

end;

procedure TfrmSetup.Translate;
begin
  Caption := GetTranslatedString(IDS_FRM_SETUP);
  gbxSetup.Caption := GetTranslatedString(IDS_FRM_SETUP_GBX_MAINPREFS);
  lblGameDir.Caption := GetTranslatedString(IDS_FRM_SETUP_LBL_AVP2DIR);
  lblGameDirPH.Caption := GetTranslatedString(IDS_FRM_SETUP_LBL_PHDIR);
  lblLocalPort.Caption := GetTranslatedString(IDS_FRM_SETUP_LBL_PORT);
  lblLang.Caption := GetTranslatedString(IDS_FRM_SETUP_LBL_LANG);
  gbxColors.Caption := GetTranslatedString(IDS_FRM_SETUP_GBX_INTERFACEPREFS);
  lblFeaturedFontColor.Caption := GetTranslatedString(IDS_FRM_SETUP_LBL_FONTCOLOR1);
  lblMSFontColor.Caption := GetTranslatedString(IDS_FRM_SETUP_LBL_FONTCOLOR2);
  lblFavoritesFontColor.Caption := GetTranslatedString(IDS_FRM_SETUP_LBL_FONTCOLOR3);
  cbxTopTabs.Caption := GetTranslatedString(IDS_FRM_SETUP_CBX_TABPOSITIONTOP);
  cbxAutoRefresh.Caption := GetTranslatedString(IDS_FRM_SETUP_CBX_AUTOREFRESH);
  cbxPlayersSort.Caption := GetTranslatedString(IDS_FRM_SETUP_CBX_AUTOSORT);
  cbxHideNews.Caption := GetTranslatedString(IDS_FRM_SETUP_CBX_HIDENEWS);
  cgrbColumn.Caption := GetTranslatedString(IDS_FRM_SETUP_CGRP_COLUMNPREFS);
  btnOk.Caption := GetTranslatedString(IDS_FRM_SETUP_BTN_SAVE);
  btnCancel.Caption := GetTranslatedString(IDS_FRM_SETUP_BTN_CANCEL);

  // 0030
  cbxUnlimitedResize.Caption := GetTranslatedString(IDS_FRM_SETUP_CBX_UNLIMITEDRESIZE);
end;

procedure TfrmSetup.btnBrowseClick(Sender: TObject);
var bExecuted, bValidDir: Boolean;
begin
  bExecuted := False;
  bValidDir := False;
  repeat
    bExecuted := sddGameDir.Execute;
    bValidDir := IsAVP2Dir(sddGameDir.FileName);
    if (bExecuted) and (not bValidDir) then
    begin
      if Application.MessageBox(PChar('"' + sddGameDir.FileName + GetTranslatedString(IDS_FRM_SETUP_MSG_NOTAVP2DIR)),
        PChar(Application.Title), MB_OKCANCEL + MB_ICONWARNING) = IDCANCEL then bExecuted := False;
    end;
  until (not bExecuted) or (bValidDir);
  if bValidDir then
  begin
    edtGameDir.Text := sddGameDir.FileName;
    if Length(sddGameDir.FileName) <> UTF8Length(sddGameDir.FileName) then
      Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_SETUP_BAD_PATH), PChar(Application.Title), MB_OK + MB_ICONWARNING);
  end;
end;

procedure TfrmSetup.btnBrowsePHClick(Sender: TObject);
var bExecuted, bValidDir: Boolean;
begin
  bExecuted := False;
  bValidDir := False;
  repeat
    bExecuted := sddGameDir.Execute;
    bValidDir := IsAVP2Dir(sddGameDir.FileName);
    if (bExecuted) and (not bValidDir) then
    begin
      if Application.MessageBox(PChar('"' + sddGameDir.FileName + GetTranslatedString(IDS_FRM_SETUP_MSG_NOTPHDIR)),
        PChar(Application.Title), MB_OKCANCEL + MB_ICONWARNING) = IDCANCEL then bExecuted := False;
    end;
  until (not bExecuted) or (bValidDir);
  if bValidDir then
  begin
    edtGameDirPH.Text := sddGameDir.FileName;
    if Length(sddGameDir.FileName) <> UTF8Length(sddGameDir.FileName) then
      Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_SETUP_BAD_PATH), PChar(Application.Title), MB_OK + MB_ICONWARNING);
  end;
end;

end.

