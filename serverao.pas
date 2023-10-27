unit serverao;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, servermgr, LCLType, ExtCtrls;

type

  { TfrmAO }

  TfrmAO = class(TForm)
    btnSave: TButton;
    btnCancel: TButton;
    cbxCustomCmd: TCheckBox;
    cbxMod: TComboBox;
    cbxCustomMod: TCheckBox;
    edtComment: TEdit;
    edtIP: TEdit;
    edtPort: TEdit;
    gbxAO: TGroupBox;
    lblPort: TLabel;
    lblAdvancedOptions: TLabel;
    lblUserComment: TLabel;
    lblIP: TLabel;
    lvAOS: TListView;
    mmoCustomCmd: TMemo;
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure cbxCustomCmdChange(Sender: TObject);
    procedure cbxCustomModChange(Sender: TObject);
    procedure cbxModChange(Sender: TObject);
    procedure edtIPChange(Sender: TObject);
    procedure FillAO;
    procedure lvAOSChange(Sender: TObject; Item: TListItem; {%H-}Change: TItemChange);
    procedure Translate;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmAO: TfrmAO;
  g_bAOAddMode: Boolean = False;
  g_AOServer: TServer;
  g_CurrentMod: TModInfo = nil;
  g_CurrentCustomMod: TModInfo = nil;

implementation

uses main, translation_consts, common;

{$R *.lfm}

{ TfrmAO }

procedure TfrmAO.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmAO.btnSaveClick(Sender: TObject);
var i: Integer;
    NewAOLight: TAOItemLight;
    strResolvedIP: string;
    strPort: Word;
begin
  if g_bAOAddMode then
  begin
    strResolvedIP := UDPServer.ResolveName(edtIP.Text);
    strPort := SafeStrToInt(edtPort.Text);
    if ServerMgr_FindFavoriteServer(strResolvedIP, strPort) = nil then
    begin
      g_AOServer.DNSName := edtIP.Text;
      g_AOServer.IP := strResolvedIP;
      g_AOServer.Port := SafeStrToInt(edtPort.Text);
      g_AOServer.Address := g_AOServer.IP + ':' + edtPort.Text;
      g_AOServer.Favorite := True;
      g_AOServer.CustomComment := edtComment.Text;

      if cbxCustomMod.Checked then
        g_AOServer.CustomModVer := ''
      else
        g_AOServer.CustomModVer := cbxMod.Text;

      if cbxCustomCmd.Checked then
        g_AOServer.Cmd := mmoCustomCmd.Text
      else
        g_AOServer.Cmd := '';

      g_AOServer.AOLightList.Clear;
      for i := 0 to lvAOS.Items.Count-1 do
      begin
        NewAOLight := TAOItemLight.Create;
        NewAOLight.Name := lvAOS.Items[i].Caption;
        NewAOLight.Checked := lvAOS.Items[i].Checked;
        g_AOServer.AOLightList.Add(NewAOLight);
      end;

      ModalResult := mrOK;
    end
    else
    begin
      Application.MessageBox(GetTranslatedStringPChar(IDS_FRM_ADVANCEDOPTIONS_MSG_ALREADYFAV), PChar(Application.Title), MB_OK + MB_ICONASTERISK);
    end;
  end
  else
  begin
    g_AOServer.Favorite := True;
    g_AOServer.CustomComment := edtComment.Text;

    if cbxCustomMod.Checked then
      g_AOServer.CustomModVer := ''
    else
      g_AOServer.CustomModVer := cbxMod.Text;

    if cbxCustomCmd.Checked then
      g_AOServer.Cmd := mmoCustomCmd.Text
    else
      g_AOServer.Cmd := '';

    g_AOServer.AOLightList.Clear;
    for i := 0 to lvAOS.Items.Count-1 do
    begin
      NewAOLight := TAOItemLight.Create;
      NewAOLight.Name := lvAOS.Items[i].Caption;
      NewAOLight.Checked := lvAOS.Items[i].Checked;
      g_AOServer.AOLightList.Add(NewAOLight);
    end;

    ModalResult := mrOK;
  end;
end;

procedure TfrmAO.cbxCustomCmdChange(Sender: TObject);
begin
  if cbxCustomCmd.Checked then
  begin
    mmoCustomCmd.Enabled := True;
    mmoCustomCmd.Color := clDefault;
    lvAOS.Enabled := False;
    lvAOS.Color := clBtnFace;
  end
  else
  begin
    mmoCustomCmd.Enabled := False;
    mmoCustomCmd.Color := clBtnFace;
    lvAOS.Enabled := True;
    lvAOS.Color := clDefault;
  end;
end;

procedure TfrmAO.cbxCustomModChange(Sender: TObject);
begin
  if cbxCustomMod.Checked then
  begin
    cbxMod.Enabled := False;
    cbxMod.Color := clBtnFace;
    cbxMod.ItemIndex := cbxMod.Items.IndexOf(g_CurrentMod.Name);
    cbxModChange(nil);
  end
  else
  begin
    cbxMod.Enabled := True;
    cbxMod.Color := clDefault;
  end;
end;

procedure TfrmAO.cbxModChange(Sender: TObject);
var CurMod: TModInfo;
    CurAO: TAOItem;
    i: Integer;
    ListItem: TListItem;
begin
  lvAOS.Clear;
  CurMod := ServerMgr_FindMod(cbxMod.Text);
  for i := 0 to CurMod.AdvancedOptions.Count - 1 do
  begin
    CurAO := TAOItem(CurMod.AdvancedOptions.Items[i]);
    ListItem := lvAOS.Items.Add;
    ListItem.Checked := CurAO.IsDefault;
    ListItem.Caption := CurAO.Title;
    ListItem.Data := CurAO;
    ListItem.SubItems.Add(CurAO.Description);
  end;
  if not cbxCustomCmd.Checked then
  begin
    if CurMod.CustomCmd = '' then
      mmoCustomCmd.Lines.Text := CurMod.DefaultCmd
    else
      mmoCustomCmd.Lines.Text := CurMod.CustomCmd;
  end;
end;

procedure TfrmAO.edtIPChange(Sender: TObject);
begin

end;

procedure TfrmAO.FillAO;
var i: Integer;
    CurMod, MyMod: TModInfo;
    CurAO: TAOItem;
    CurAOLight: TAOItemLight;
    ListItem: TListItem;
begin
  g_CurrentMod := ServerMgr_FindMod(g_AOServer.ModVer);

  if g_AOServer.CustomModVer <> '' then
    g_CurrentCustomMod := ServerMgr_FindMod(g_AOServer.CustomModVer)
  else
    g_CurrentCustomMod := nil;

  if (g_AOServer.Favorite) and (g_CurrentCustomMod <> nil) then
    MyMod := g_CurrentCustomMod
  else
    MyMod := g_CurrentMod;

  edtComment.Text := '';
  cbxMod.Clear;
  cbxCustomCmd.Checked := False;
  mmoCustomCmd.Enabled := False;
  mmoCustomCmd.Color := clBtnFace;
  lvAOS.Enabled := True;
  lvAOS.Color := clDefault;
  if g_bAOAddMode then
  begin
    edtIP.Text := '';
    edtPort.Text := '';
    edtIP.ReadOnly := False;
    edtPort.ReadOnly := False;
    edtIP.Color := clDefault;
    edtPort.Color := clDefault;
  end
  else
  begin
    edtIP.Text := g_AOServer.DNSName;
    edtPort.Text :=  SafeIntToStr(g_AOServer.Port);
    edtIP.ReadOnly := True;
    edtPort.ReadOnly := True;
    edtIP.Color := clBtnFace;
    edtPort.Color := clBtnFace;
  end;
  for i := 0 to g_Mods.Count-1 do
  begin
    CurMod := TModInfo(g_Mods.Items[i]);
    cbxMod.Items.Add(CurMod.Name);
  end;

  if g_AOServer.Favorite then
  begin
    if g_CurrentCustomMod <> nil then
    begin
      cbxCustomMod.Checked := False;
      cbxMod.Enabled := True;
      cbxMod.Color := clDefault;
    end
    else
    begin
      cbxCustomMod.Checked := True;
      cbxMod.Enabled := False;
      cbxMod.Color := clBtnFace;
    end;
    cbxMod.ItemIndex := cbxMod.Items.IndexOf(MyMod.Name);
    edtComment.Text := g_AOServer.CustomComment;
  end
  else
  begin
    cbxCustomMod.Checked := True;
    cbxMod.Enabled := False;
    cbxMod.Color := clBtnFace;
    edtComment.Text := g_AOServer.Comment;
    cbxMod.ItemIndex := cbxMod.Items.IndexOf(MyMod.Name);
  end;

  if g_AOServer.Cmd <> '' then
  begin
    cbxCustomCmd.Checked := True;
    mmoCustomCmd.Enabled := True;
    mmoCustomCmd.Color := clDefault;
    mmoCustomCmd.Lines.Text := g_AOServer.Cmd;
    lvAOS.Enabled := False;
    lvAOS.Color := clBtnFace;
  end
  else
  begin
    if g_CurrentMod.CustomCmd = '' then
      mmoCustomCmd.Lines.Text := MyMod.DefaultCmd
    else
      mmoCustomCmd.Lines.Text := MyMod.CustomCmd;
  end;
  lvAOS.Clear;
  for i := 0 to MyMod.AdvancedOptions.Count - 1 do
  begin
    CurAO := TAOItem(MyMod.AdvancedOptions.Items[i]);
    ListItem := lvAOS.Items.Add;

    if g_AOServer.Favorite then
    begin
      CurAOLight := ServerMgr_GetAOLight(g_AOServer, CurAO.Title);
      if CurAOLight = nil then
        ListItem.Checked := CurAO.IsDefault
      else
        ListItem.Checked := CurAOLight.Checked;
    end
    else
    begin
      ListItem.Checked := CurAO.IsDefault;
    end;

    ListItem.Caption := CurAO.Title;
    ListItem.Data := CurAO;
    ListItem.SubItems.Add(CurAO.Description);
  end;
end;

procedure TfrmAO.lvAOSChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var i: Integer;
    CurAO, CheckAO: TAOItem;
begin
  if Item.Data <> nil then
  begin
    CurAO := TAOItem(Item.Data);
    if (CurAO.Group > -1) and (Item.Checked) then
    begin
      for i := 0 to lvAOS.Items.Count-1 do
      begin
        CheckAO := TAOItem(lvAOS.Items[i].Data);
        if (CheckAO.Group = CurAO.Group) and (CheckAO <> CurAO) then
        begin
          lvAOS.Items[i].Checked := False;
        end;
      end;
    end;
  end;
end;

procedure TfrmAO.Translate;
begin
  Caption := GetTranslatedString(IDS_FRM_ADVANCEDOPTIONS);
  lblIP.Caption := GetTranslatedString(IDS_FRM_ADVANCEDOPTIONS_LBL_ADDRESS);
  lblPort.Caption := GetTranslatedString(IDS_FRM_ADVANCEDOPTIONS_LBL_PORT);
  lblUserComment.Caption := GetTranslatedString(IDS_FRM_ADVANCEDOPTIONS_LBL_USERCOMM);
  cbxCustomMod.Caption := GetTranslatedString(IDS_FRM_ADVANCEDOPTIONS_CBX_MODAUTO);
  lblAdvancedOptions.Caption := GetTranslatedString(IDS_FRM_ADVANCEDOPTIONS_LBL_ADVOPT);
  lvAOS.Column[0].Caption := GetTranslatedString(IDS_FRM_ADVANCEDOPTIONS_COL_OPTION);
  lvAOS.Column[1].Caption := GetTranslatedString(IDS_FRM_ADVANCEDOPTIONS_COL_DESCRIPTION);
  cbxCustomCmd.Caption := GetTranslatedString(IDS_FRM_ADVANCEDOPTIONS_CBX_USECUSTOM);
  btnSave.Caption := GetTranslatedString(IDS_FRM_ADVANCEDOPTIONS_BTN_SAVE);
  btnCancel.Caption := GetTranslatedString(IDS_FRM_ADVANCEDOPTIONS_BTN_CANCEL);
end;


end.

