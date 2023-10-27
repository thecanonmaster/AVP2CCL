unit debuginfo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, LCLType, common;

type

  { TfrmDebug }

  TfrmDebug = class(TForm)
    btnClose: TButton;
    btnCopyToClipboard: TButton;
    mmoDebug: TMemo;
    procedure btnCloseClick(Sender: TObject);
    procedure btnCopyToClipboardClick(Sender: TObject);
    procedure Translate;
    procedure Add(strMsg: string);
    procedure Clear;
  private

  public

  end;

var
  frmDebug: TfrmDebug;

implementation

uses translation_consts;

{$R *.lfm}

{ TfrmDebug }

procedure TfrmDebug.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmDebug.btnCopyToClipboardClick(Sender: TObject);
begin
  mmoDebug.SelectAll;
  mmoDebug.CopyToClipboard;
  Application.MessageBox(GetTranslatedStringPChar(IDS_DEBUG_DONE), PChar(Application.Title), MB_OK + MB_ICONINFORMATION);
end;

procedure TfrmDebug.Translate;
begin
  Caption := GetTranslatedString(IDS_DEBUG_INFORMATION);
  btnClose.Caption := GetTranslatedString(IDS_DEBUG_CLOSE);
  btnCopyToClipboard.Caption := GetTranslatedString(IDS_DEBUG_COPY_TO_CLIPBOARD);  ;
end;

procedure TfrmDebug.Add(strMsg: string);
begin
  mmoDebug.Lines.Add(strMsg);
end;

procedure TfrmDebug.Clear;
begin
  mmoDebug.Lines.Clear;
end;

end.

