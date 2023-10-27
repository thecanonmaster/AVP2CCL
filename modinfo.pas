unit modinfo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  windows;

type

  { TfrmModInfo }

  TfrmModInfo = class(TForm)
    btnClose: TButton;
    edtLink: TEdit;
    gbxDownload: TGroupBox;
    lblGo: TLabel;
    mmoInfo: TMemo;
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lblGoClick(Sender: TObject);
    procedure Translate;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmModInfo: TfrmModInfo;

implementation

{$R *.lfm}

uses common, translation_consts, modoptions;

{ TfrmModInfo }

procedure TfrmModInfo.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmModInfo.FormCreate(Sender: TObject);
begin

end;

procedure TfrmModInfo.lblGoClick(Sender: TObject);
begin
  if edtLink.Text <> '' then
  begin
    ShellExecute(0,PChar('open'),PChar(edtLink.Text),
            PChar(''),
            PChar(''),SW_SHOWNORMAL);
  end
  else
  begin
    Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_MODINFO_MSG_NOTAVAILABLE), PChar(g_ThisMod.Name), MB_OK + MB_ICONINFORMATION);
  end;
end;

procedure TfrmModInfo.Translate;
begin
  Caption := GetTranslatedString(IDS_FRM_MODINFO);
  gbxDownload.Caption := GetTranslatedString(IDS_FRM_MODINFO_GBX_WHERE);
  lblGo.Caption := GetTranslatedString(IDS_FRM_MODINFO_LBL_VISIT);
  btnClose.Caption := GetTranslatedString(IDS_FRM_MODINFO_BTN_CLOSE);
end;

end.

