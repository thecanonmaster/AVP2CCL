unit serverinfo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, Menus, LCLType, Clipbrd;

type

  { TfrmServerInfo }

  TfrmServerInfo = class(TForm)
    btnClose: TButton;
    lvServerInfo: TListView;
    mmiCopyValue: TMenuItem;
    ppmItem: TPopupMenu;
    procedure btnCloseClick(Sender: TObject);
    procedure mmiCopyValueClick(Sender: TObject);
    procedure ppmItemPopup(Sender: TObject);
    procedure Translate;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmServerInfo: TfrmServerInfo;

implementation

uses translation_consts, common;

{$R *.lfm}

{ TfrmServerInfo }

procedure TfrmServerInfo.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmServerInfo.mmiCopyValueClick(Sender: TObject);
begin
  if lvServerInfo.Selected <> nil then
  begin
    Clipboard.AsText := lvServerInfo.Selected.SubItems[0];
    Application.MessageBox(GetTranslatedStringPChar(IDS_DEBUG_DONE), PChar(Application.Title), MB_OK + MB_ICONINFORMATION);
  end;
end;

procedure TfrmServerInfo.ppmItemPopup(Sender: TObject);
begin
  mmiCopyValue.Enabled := (lvServerInfo.Selected <> nil);
end;

procedure TfrmServerInfo.Translate;
begin
  Caption := GetTranslatedString(IDS_FRM_SERVINFO);
  lvServerInfo.Column[0].Caption := GetTranslatedString(IDS_FRM_SERVINFO_COL_PARAMETER);
  lvServerInfo.Column[1].Caption := GetTranslatedString(IDS_FRM_SERVINFO_COL_VALUE);
  btnClose.Caption := GetTranslatedString(IDS_FRM_SERVINFO_BTN_CLOSE);
end;


end.

