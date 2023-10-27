unit news;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, common, windows;

type

  { TfrmNews }

  TfrmNews = class(TForm)
    btnOne: TButton;
    btnTwo: TButton;
    btnThree: TButton;
    btnFour: TButton;
    btnFive: TButton;
    lblHyperlink: TLabel;
    lblText: TLabel;
    lblTitle: TLabel;
    shpNews: TShape;
    procedure btnFiveClick(Sender: TObject);
    procedure btnFourClick(Sender: TObject);
    procedure btnOneClick(Sender: TObject);
    procedure btnThreeClick(Sender: TObject);
    procedure btnTwoClick(Sender: TObject);
    procedure lblHyperlinkClick(Sender: TObject);
    procedure HandleNoNews;
    procedure ShowNews(i: Integer);
    procedure Translate;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmNews: TfrmNews;
  g_strLink: string;

implementation

uses translation_consts;

{$R *.lfm}

{ TfrmNews }

procedure TfrmNews.btnOneClick(Sender: TObject);
begin
  ShowNews(0);
  btnOne.Font.Style := [fsBold];
  btnTwo.Font.Style := [];
  btnThree.Font.Style := [];
  btnFour.Font.Style := [];
  btnFive.Font.Style := [];
end;

procedure TfrmNews.btnFourClick(Sender: TObject);
begin
  ShowNews(3);
  btnOne.Font.Style := [];
  btnTwo.Font.Style := [];
  btnThree.Font.Style := [];
  btnFour.Font.Style := [fsBold];
  btnFive.Font.Style := [];
end;

procedure TfrmNews.btnFiveClick(Sender: TObject);
begin
  ShowNews(4);
  btnOne.Font.Style := [];
  btnTwo.Font.Style := [];
  btnThree.Font.Style := [];
  btnFour.Font.Style := [];
  btnFive.Font.Style := [fsBold];
end;

procedure TfrmNews.btnThreeClick(Sender: TObject);
begin
  ShowNews(2);
  btnOne.Font.Style := [];
  btnTwo.Font.Style := [];
  btnThree.Font.Style := [fsBold];
  btnFour.Font.Style := [];
  btnFive.Font.Style := [];
end;

procedure TfrmNews.btnTwoClick(Sender: TObject);
begin
  ShowNews(1);
  btnOne.Font.Style := [];
  btnTwo.Font.Style := [fsBold];
  btnThree.Font.Style := [];
  btnFour.Font.Style := [];
  btnFive.Font.Style := [];
end;

procedure TfrmNews.lblHyperlinkClick(Sender: TObject);
begin
  ShellExecute(0,PChar('open'),PChar(g_strLink),
            PChar(''),
            PChar(''),SW_SHOWNORMAL);
end;

procedure TfrmNews.HandleNoNews;
var strTitle, strText: string;
begin
  GetNews(0, strTitle{%H-}, strText{%H-}, g_strLink);
  if strTitle = '' then btnOne.Enabled := False;
  GetNews(1, strTitle{%H-}, strText{%H-}, g_strLink);
  if strTitle = '' then btnTwo.Enabled := False;
  GetNews(2, strTitle{%H-}, strText{%H-}, g_strLink);
  if strTitle = '' then btnThree.Enabled := False;
  GetNews(3, strTitle{%H-}, strText{%H-}, g_strLink);
  if strTitle = '' then btnFour.Enabled := False;
  GetNews(4, strTitle{%H-}, strText{%H-}, g_strLink);
  if strTitle = '' then btnFive.Enabled := False;
end;

procedure TfrmNews.ShowNews(i: Integer);
var strTitle, strText: string;
begin
  GetNews(i, strTitle{%H-}, strText{%H-}, g_strLink);
  lblTitle.Caption := strTitle;
  lblText.Caption := strText;
  if g_strLink = '' then
    frmNews.lblHyperlink.Visible := False
  else
    frmNews.lblHyperlink.Visible := True;
end;

procedure TfrmNews.Translate;
begin
  Caption := GetTranslatedString(IDS_FRM_NEWS);
  lblHyperlink.Caption := GetTranslatedString(IDS_FRM_NEWS_LBL_VISIT);
end;

end.

