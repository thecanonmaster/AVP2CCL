unit image_preview;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  common;

type

  { TfrmImagePreview }

  TfrmImagePreview = class(TForm)
    btnClose: TButton;
    imgMapshot: TImage;
    procedure btnCloseClick(Sender: TObject);
    procedure imgMapshotClick(Sender: TObject);
  private

  public
    procedure Translate;
  end;

var
  frmImagePreview: TfrmImagePreview;

implementation

uses translation_consts;

{$R *.lfm}

{ TfrmImagePreview }

procedure TfrmImagePreview.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmImagePreview.imgMapshotClick(Sender: TObject);
begin
  if imgMapshot.AntialiasingMode = amOn then
    imgMapshot.AntialiasingMode := amOff
  else
    imgMapshot.AntialiasingMode := amOn;
end;

procedure TfrmImagePreview.Translate;
begin
  Caption := GetTranslatedString(IDS_FRM_MAIN_GBX_MAPSCREEN);
  btnClose.Caption := GetTranslatedString(IDS_MAPSHOT_CLOSE);
end;

end.

