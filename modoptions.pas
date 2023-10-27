unit modoptions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, servermgr, LCLType;

type

  { TfrmModOptions }

  TfrmModOptions = class(TForm)
    btnCancel: TButton;
    btnOk: TButton;
    cbxCustomCmd: TCheckBox;
    cbxPrimalHunt: TCheckBox;
    edtDesc: TEdit;
    edtName: TEdit;
    lblDesc: TLabel;
    lblName: TLabel;
    mmoCmd: TMemo;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure cbxCustomCmdChange(Sender: TObject);
    procedure FillMod;
    procedure Translate;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmModOptions: TfrmModOptions;
  g_ThisMod: TModInfo;
  g_MMAddMode: Boolean;

implementation

uses common, translation_consts;

{$R *.lfm}

{ TfrmModOptions }

procedure TfrmModOptions.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmModOptions.btnOkClick(Sender: TObject);
var CurMod: TModInfo;
begin
  if g_ThisMod.FullyCustom then
  begin
    g_ThisMod.Name := edtName.Text;
    g_ThisMod.Description := edtDesc.Text;
    CurMod := ServerMgr_FindMod(g_ThisMod.Name);
  end;
  if cbxCustomCmd.Checked then
  begin
    g_ThisMod.CustomCmd := mmoCmd.Text;
    g_ThisMod.PrimalHunt := cbxPrimalHunt.Checked;
  end
  else
  begin
    g_ThisMod.CustomCmd := '';
  end;
  if g_MMAddMode then
  begin
    CurMod := ServerMgr_FindMod(g_ThisMod.Name);
    if CurMod = nil then
    begin
      ModalResult := mrOK;
    end
    else
    begin
      Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_MODOPTIONS_MSG_EXISTS), PChar(Application.Title), MB_OK + MB_ICONASTERISK);
    end;
  end
  else
  begin
    ModalResult := mrOK;
  end;
end;

procedure TfrmModOptions.cbxCustomCmdChange(Sender: TObject);
begin
  if cbxCustomCmd.Checked then
  begin
    mmoCmd.Enabled := True;
    mmoCmd.Color := clDefault;
    cbxPrimalHunt.Enabled := True;
  end
  else
  begin
    mmoCmd.Enabled := False;
    mmoCmd.Color := clBtnFace;
    cbxPrimalHunt.Enabled := False;
  end;
end;

procedure TfrmModOptions.FillMod;
begin
  edtName.Text := g_ThisMod.Name;
  edtDesc.Text := g_ThisMod.Description;
  if g_ThisMod.FullyCustom then
  begin
    edtName.Enabled := True;
    edtDesc.Enabled := True;
    edtName.Color := clDefault;
    edtDesc.Color := clDefault;
    cbxCustomCmd.Enabled := False;
  end
  else
  begin
    edtName.Enabled := False;
    edtDesc.Enabled := False;
    edtName.Color := clBtnFace;
    edtDesc.Color := clBtnFace;
    cbxCustomCmd.Enabled := True;
  end;
  if g_ThisMod.CustomCmd <> '' then
  begin
    cbxCustomCmd.Checked := True;
    mmoCmd.Enabled := True;
    mmoCmd.Color := clDefault;
    mmoCmd.Text := g_ThisMod.CustomCmd;
    cbxPrimalHunt.Enabled := True;
    cbxPrimalHunt.Checked := g_ThisMod.PrimalHunt;
  end
  else
  begin
    cbxCustomCmd.Checked := False;
    mmoCmd.Enabled := False;
    mmoCmd.Color := clBtnFace;
    mmoCmd.Text := g_ThisMod.DefaultCmd;
    cbxPrimalHunt.Enabled := False;
    cbxPrimalHunt.Checked := g_ThisMod.PrimalHunt;
  end;
end;

procedure TfrmModOptions.Translate;
begin
  Caption := GetTranslatedString(IDS_FRM_MODOPTIONS);
  lblName.Caption := GetTranslatedString(IDS_FRM_MODOPTIONS_LBL_NAME);
  lblDesc.Caption := GetTranslatedString(IDS_FRM_MODOPTIONS_LBL_DESC);
  cbxCustomCmd.Caption := GetTranslatedString(IDS_FRM_MODOPTIONS_CBX_CUSTOMCMD);
  cbxPrimalHunt.Caption := GetTranslatedString(IDS_FRM_MODOPTIONS_CBX_PHBASED);
  btnOk.Caption := GetTranslatedString(IDS_FRM_MODOPTIONS_BTN_OK);
  btnCancel.Caption := GetTranslatedString(IDS_FRM_MODOPTIONS_BTN_CANCEL);
end;

end.

