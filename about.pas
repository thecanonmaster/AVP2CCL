unit about;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, windows;

type

  { TfrmAbout }

  TfrmAbout = class(TForm)
    btnOk: TButton;
    img1: TImage;
    lblGAL: TLabel;
    lblGAME: TLabel;
    lblFACE: TLabel;
    lblRED: TLabel;
    lblRED2: TLabel;
    lblVK: TLabel;
    lblUNT: TLabel;
    lblUND: TLabel;
    lblUN: TLabel;
    pnl1: TPanel;
    pnl2: TPanel;
    pnl3: TPanel;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    lblMS: TLabel;
    tmrRainbow: TTimer;
    procedure btnOkClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var {%H-}CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure img1DblClick(Sender: TObject);
    procedure lblGALClick(Sender: TObject);
    procedure lblGAMEClick(Sender: TObject);
    procedure lblMSClick(Sender: TObject);
    procedure lblFACEClick(Sender: TObject);
    procedure lblRED2Click(Sender: TObject);
    procedure lblREDClick(Sender: TObject);
    procedure lblUNClick(Sender: TObject);
    procedure lblUNDClick(Sender: TObject);
    procedure lblUNTClick(Sender: TObject);
    procedure lblVKClick(Sender: TObject);
    procedure pnl3Click(Sender: TObject);
    procedure tmrRainbowTimer(Sender: TObject);
    procedure Translate;
    procedure OpenLink(strLink: string);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmAbout: TfrmAbout;

implementation

uses translation_consts, common, debuginfo;

{$R *.lfm}

{ TfrmAbout }
procedure TfrmAbout.btnOkClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmAbout.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  tmrRainbow.Enabled := False;
end;

procedure TfrmAbout.FormCreate(Sender: TObject);
begin

end;

procedure TfrmAbout.img1DblClick(Sender: TObject);
begin
  frmDebug.Clear;
  frmDebug.Caption := GetTranslatedString(IDS_DEBUG_INFORMATION);
  frmDebug.Add('Offline mode: ' + BoolToStr(g_bNewOfflineMode, True));
  frmDebug.Add('Last version available: ' + g_strLastVersion);
  frmDebug.Add('D3D7Fix version (expected): ' + g_strD3D7FixVersionExpected);
  frmDebug.Add('Link index: ' + IntToStr(g_nOnlineIndexData));
  frmDebug.Add('Image preview count: ' + IntToStr(g_ImagePreviewIndex.Count));
  frmDebug.Add('Image preview cache: ' + IntToStr(g_ImagePreviewCache.Size));
  frmDebug.ShowModal;
end;

procedure TfrmAbout.lblGALClick(Sender: TObject);
begin
  OpenLink('http://avpgalaxy.net');
end;

procedure TfrmAbout.lblGAMEClick(Sender: TObject);
begin
  OpenLink('http://twitter.com/avp2game');
end;

procedure TfrmAbout.lblMSClick(Sender: TObject);
begin
  OpenLink('http://avp2msp.com');
end;

procedure TfrmAbout.lblFACEClick(Sender: TObject);
begin
  OpenLink('https://www.facebook.com/aliensvspredator2');
end;

procedure TfrmAbout.lblRED2Click(Sender: TObject);
begin
  OpenLink('https://reddit.com/r/aliensvspredator2');
end;

procedure TfrmAbout.lblREDClick(Sender: TObject);
begin
  OpenLink('https://reddit.com/r/avp2game');
end;

procedure TfrmAbout.lblUNClick(Sender: TObject);
begin
  OpenLink('https://avpunknown.com');
end;

procedure TfrmAbout.lblUNDClick(Sender: TObject);
begin
  OpenLink('https://discord.com/invite/esPD62d');
end;

procedure TfrmAbout.lblUNTClick(Sender: TObject);
begin
  OpenLink('https://twitter.com/avpunknown');
end;

procedure TfrmAbout.lblVKClick(Sender: TObject);
begin
  OpenLink('https://vk.com/avp2pbt');
end;

procedure TfrmAbout.pnl3Click(Sender: TObject);
begin

end;

procedure TfrmAbout.tmrRainbowTimer(Sender: TObject);
begin
  lbl1.Font.Color := lbl1.Font.Color + $060708;
end;

procedure TfrmAbout.Translate;
begin
  Caption := GetTranslatedString(IDS_FRM_ABOUT);
  btnOk.Caption := GetTranslatedString(IDS_FRM_ABOUT_BTN_OK);
end;

procedure TfrmAbout.OpenLink(strLink: string);
begin
  ShellExecute(0,PChar('open'),PChar(strLink),
            PChar(''),
            PChar(''),SW_SHOWNORMAL);
end;



end.

