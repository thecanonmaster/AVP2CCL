unit d3d7fixao;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Menus, ComCtrls, common;

type

  { TfrmD3D7FixAO }

  TfrmD3D7FixAO = class(TForm)
    btnCancel: TButton;
    btnSave: TButton;
    btnSetValue: TButton;
    btnDefaultValue: TButton;
    edtValue: TEdit;
    edtResult: TEdit;
    lvD3D7FixAO: TListView;
    procedure Clear;
    procedure FillOptions;
    procedure btnCancelClick(Sender: TObject);
    procedure btnDefaultValueClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnSetValueClick(Sender: TObject);
    procedure lvD3D7FixAOCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; {%H-}State: TCustomDrawState; var {%H-}DefaultDraw: Boolean);
    procedure lvD3D7FixAOItemChecked(Sender: TObject; {%H-}Item: TListItem);
    procedure lvD3D7FixAOSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure Translate;
    procedure CompileProfile;
    function GetGlobalProfileString(slD3D7FixExtraParams: TStringList): string;
  private
    function CompileProfile_GetOption(nIndex: Integer): TD3D7FixOption;
    function CompileProfile_Filter(nIndex: Integer): Boolean;
    function CompileProfile_GetValue(nIndex: Integer): string;
    function GlobalProfile_Filter(nIndex: Integer): Boolean;
    function GlobalProfile_GetOption(nIndex: Integer): TD3D7FixOption;
    function GlobalProfile_GetValue(nIndex: Integer): string;
  end;

var
  frmD3D7FixAO: TfrmD3D7FixAO;

implementation

uses translation_consts;

{$R *.lfm}

{ TfrmD3D7FixAO }

procedure TfrmD3D7FixAO.Translate;
begin
  Caption := Format(GetTranslatedString(IDS_D3D7FIX_AO_PLUS_WARN), [g_strD3D7FixVersionExpected]);
  btnSave.Caption := GetTranslatedString(IDS_D3D7FIX_AO_SAVE);
  btnCancel.Caption := GetTranslatedString(IDS_D3D7FIX_AO_CANCEL);
  lvD3D7FixAO.Column[0].Caption := GetTranslatedString(IDS_D3D7FIX_AO_PARAM);
  lvD3D7FixAO.Column[1].Caption := GetTranslatedString(IDS_D3D7FIX_AO_DESC);
  lvD3D7FixAO.Column[2].Caption := GetTranslatedString(IDS_D3D7FIX_AO_TYPE);
  lvD3D7FixAO.Column[3].Caption := GetTranslatedString(IDS_D3D7FIX_AO_VALUE);
  btnSetValue.Caption := GetTranslatedString(IDS_D3D7FIX_AO_SETVALUE);
  btnDefaultValue.Caption := GetTranslatedString(IDS_D3D7FIX_AO_DEFAULTVALUE);
end;

procedure TfrmD3D7FixAO.CompileProfile;
var strValue: string;
    i: Integer;
    slMandatoryParams: TStringList;
    pOption: TD3D7FixOption;
begin
  slMandatoryParams := TStringList.Create;
  for i := 0 to g_slD3D7FixOptions.Count - 1 do
  begin
    pOption := TD3D7FixOption(g_slD3D7FixOptions.Objects[i]);
    if pOption.Mandatory then
      slMandatoryParams.AddObject(pOption.Name, pOption);
  end;

  strValue := CompileD3D7FixProfile(lvD3D7FixAO.Items.Count,
    @CompileProfile_GetOption, @CompileProfile_Filter, @CompileProfile_GetValue, slMandatoryParams);

  if strValue <> '' then
    edtResult.Text := D3D7FIX_PROFILE_EX_CMD + ' ' + strValue
  else
    edtResult.Clear;

  slMandatoryParams.Free;
end;

function TfrmD3D7FixAO.GetGlobalProfileString(slD3D7FixExtraParams: TStringList): string;
var i, nIndex: Integer;
    astrTemp: TStringArray;
    strValue: string;
begin
  for i := 0 to slD3D7FixExtraParams.Count - 1 do
  begin
    astrTemp := slD3D7FixExtraParams.Strings[i].Split(['|']);
    nIndex := g_slD3D7FixOptions.IndexOf(astrTemp[0]);
    if nIndex > -1 then
    begin
      slD3D7FixExtraParams.Strings[i] := astrTemp[1];
      slD3D7FixExtraParams.Objects[i] := TD3D7FixOption(g_slD3D7FixOptions.Objects[nIndex]);
    end
    else
    begin
      slD3D7FixExtraParams.Strings[i] := '';
    end;
  end;
  SetLength(astrTemp, 0);

  strValue := CompileD3D7FixProfile(g_slD3D7FixOptions.Count,
    @GlobalProfile_GetOption, @GlobalProfile_Filter, @GlobalProfile_GetValue, slD3D7FixExtraParams);

  if strValue <> '' then
    Result := ' ' + D3D7FIX_PROFILE_EX_CMD + ' ' + strValue
  else
    Result := '';
end;

function TfrmD3D7FixAO.CompileProfile_GetOption(nIndex: Integer): TD3D7FixOption;
begin
  Result := TD3D7FixOption(lvD3D7FixAO.Items[nIndex].Data);
end;

function TfrmD3D7FixAO.CompileProfile_Filter(nIndex: Integer): Boolean;
begin
  Result := lvD3D7FixAO.Items[nIndex].Checked;
end;

function TfrmD3D7FixAO.CompileProfile_GetValue(nIndex: Integer): string;
begin
  Result := lvD3D7FixAO.Items[nIndex].SubItems.Strings[2];
end;

function TfrmD3D7FixAO.GlobalProfile_GetOption(nIndex: Integer): TD3D7FixOption;
begin
  Result := TD3D7FixOption(g_slD3D7FixOptions.Objects[nIndex]);
end;

function TfrmD3D7FixAO.GlobalProfile_Filter(nIndex: Integer): Boolean;
var pOption: TD3D7FixOption;
begin
  pOption := TD3D7FixOption(g_slD3D7FixOptions.Objects[nIndex]);
  Result := pOption.Checked;
end;

function TfrmD3D7FixAO.GlobalProfile_GetValue(nIndex: Integer): string;
var pOption: TD3D7FixOption;
begin
  pOption := TD3D7FixOption(g_slD3D7FixOptions.Objects[nIndex]);
  Result := pOption.Value;
end;

procedure TfrmD3D7FixAO.btnSaveClick(Sender: TObject);
var i: Integer;
    pOption: TD3D7FixOption;
begin
  for i := 0 to lvD3D7FixAO.Items.Count - 1 do
  begin
    pOption := TD3D7FixOption(lvD3D7FixAO.Items[i].Data);
    pOption.Checked := lvD3D7FixAO.Items[i].Checked;
    pOption.Value := lvD3D7FixAO.Items[i].SubItems.Strings[2];
  end;
  SaveConfig_D3D7FixAOOnly;
  Close;
end;

procedure TfrmD3D7FixAO.btnSetValueClick(Sender: TObject);
begin
  if lvD3D7FixAO.Selected <> nil then
  begin
    lvD3D7FixAO.Selected.SubItems[2] := edtValue.Text;
    lvD3D7FixAO.Selected.Checked := True;
    lvD3D7FixAOItemChecked(Sender, lvD3D7FixAO.Selected);
  end;
end;

procedure TfrmD3D7FixAO.lvD3D7FixAOCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if Item.SubItems.Strings[2] <> TD3D7FixOption(Item.Data).DefaultValue then
    Sender.Canvas.Font.Color := clBlue
  else
    Sender.Canvas.Font.Color := clBlack;
end;

procedure TfrmD3D7FixAO.lvD3D7FixAOItemChecked(Sender: TObject; Item: TListItem);
begin
  CompileProfile;
end;

procedure TfrmD3D7FixAO.lvD3D7FixAOSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if not Selected then
  begin
    edtValue.Clear;
    edtValue.Enabled := False;
    btnSetValue.Enabled := False;
    btnDefaultValue.Enabled := False;
  end
  else
  begin
    edtValue.Text := Item.SubItems.Strings[2];
    edtValue.Enabled := True;
    btnSetValue.Enabled := True;
    btnDefaultValue.Enabled := True;
  end;
end;

procedure TfrmD3D7FixAO.Clear;
begin
  edtResult.Clear;
  edtValue.Clear;
  edtValue.Enabled := False;
  btnSetValue.Enabled := False;
  btnDefaultValue.Enabled := False;
  lvD3D7FixAO.Clear;
end;

procedure TfrmD3D7FixAO.FillOptions;
var i: Integer;
    pOption: TD3D7FixOption;
    ListItem: TListItem;
begin
  Caption := Format(GetTranslatedString(IDS_D3D7FIX_AO_PLUS_WARN), [g_strD3D7FixVersionExpected]);
  lvD3D7FixAO.BeginUpdate;
  for i := 0 to g_slD3D7FixOptions.Count - 1 do
  begin
    pOption := TD3D7FixOption(g_slD3D7FixOptions.Objects[i]);
    if not pOption.Hidden then
    begin
      ListItem := lvD3D7FixAO.Items.Add;
      ListItem.Data := pOption;
      ListItem.Caption := pOption.Name;
      ListItem.Checked := pOption.Checked;
      ListItem.SubItems.Add(pOption.Description);
      ListItem.SubItems.Add(pOption.OptionTypeStr);
      ListItem.SubItems.Add(pOption.Value);
    end;
  end;
  lvD3D7FixAO.EndUpdate;
  CompileProfile;
end;

procedure TfrmD3D7FixAO.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmD3D7FixAO.btnDefaultValueClick(Sender: TObject);
begin
  if lvD3D7FixAO.Selected <> nil then
  begin
    lvD3D7FixAO.Selected.SubItems.Strings[2] := TD3D7FixOption(lvD3D7FixAO.Selected.Data).DefaultValue;
    lvD3D7FixAO.Selected.Checked := False;
    edtValue.Text := lvD3D7FixAO.Selected.SubItems.Strings[2];
    lvD3D7FixAOItemChecked(Sender, lvD3D7FixAO.Selected);
  end;
end;

end.

