unit scriptmgr;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uPSCompiler, uPSRuntime, uPSUtils, common, servermgr;

const
  PAS_MOD_DETECTION_PROC = 'DetectMod';
  PAS_RACE_DETECTION_PROC = 'GetRace';
  PAS_PCC_COLUMNS_PROC = 'GetPCC_Columns';
  PAS_PCC_PROPS_PROC = 'GetPCC_Props';
  PAS_UPDATE_LD_PROC = 'UpdateLocalData';

procedure ScriptMgr_Init;
procedure ScriptMgr_Destroy;
function ScriptMgr_Compile: Boolean;
function ScriptMgr_RunModDetection: string;
function ScriptMgr_RunRaceDetection(strMod: string; nRace: Integer): string;
function ScriptMgr_GetPCC_Columns(strMod: string; strLang: string): string;
function ScriptMgr_GetPCC_Props(strMod: string): string;
procedure ScriptMgr_UpdateLocalData(nServerIndex: Integer);

var
  g_ScriptText: TStringList;
  g_PSCompiler: TPSPascalCompiler;
  g_PSRunner: TPSExec;
  g_bCompileResult: Boolean = False;
  g_nScriptOut: Integer;

implementation

procedure UTILS_Sleep(nDelay: Integer);
begin
  Sleep(nDelay);
end;

procedure UTILS_LogError(strMsg: string);
begin
  g_Logger.Error(strMsg);
end;

function SERVER_GetProp(strProp: string; var nPos: Integer): string;
begin
  Result := ServerMgr_GetServerProp(g_ScriptServer, strProp, nPos);
end;

procedure SetPointerToData(const VarName: tbtstring; Data: Pointer; aType: TIFTypeRec);
var
  v: PIFVariant;
  t: TPSVariantIFC;
begin
  v := g_PSRunner.GetVar2(VarName);
  t.Dta := @PPSVariantData(v)^.Data;
  t.aType := v^.FType;
  t.VarParam := false;
  VNSetPointerTo(t, Data, aType);
end;

function ScriptOnUses(Sender: TPSPascalCompiler; const Name: string): Boolean;
begin
  if Name = 'SYSTEM' then
  begin
    Sender.AddDelphiFunction('procedure UTILS_Sleep(nDelay: Integer);');
    Sender.AddDelphiFunction('procedure UTILS_LogError(strMsg: string);');
    Sender.AddDelphiFunction('function SERVER_GetProp(strProp: string; var nPos: Integer): string;');

    Sender.AddUsedPtrVariableN('g_nScriptOut', 'Integer');

    Sender.AddUsedPtrVariableN('g_bLogUDP', 'Boolean');
    Sender.AddUsedPtrVariableN('g_strMSAddress', 'String');
    Sender.AddUsedPtrVariableN('g_strMSPost', 'String');
    Sender.AddUsedPtrVariableN('g_bApplyPatches', 'Boolean');
    Sender.AddUsedPtrVariableN('g_bMSProxy', 'Boolean');
    Sender.AddUsedPtrVariableN('g_strMSProxyAddress', 'String');
    Sender.AddUsedPtrVariableN('g_nServerClickDelay', 'Cardinal');
    Sender.AddUsedPtrVariableN('g_strHttpMyUserAgent', 'String');

    Result := True;
  end
  else
    Result := False;
end;

function ScriptMgr_Compile: Boolean;
var i: Integer;
    strOutData: string = '';
begin
  Result := g_PSCompiler.Compile(g_ScriptText.Text);
  g_bCompileResult := Result;
  if not Result then
  begin
    for i := 0 to g_PSCompiler.MsgCount -1 do
      g_Logger.Error('ScriptMgr_Compile - %s', [g_PSCompiler.Msg[i].MessageToString]);
  end
  else
  begin
    g_PSCompiler.GetOutput(strOutData);
    Result := g_PSRunner.LoadData(strOutData);
    SetPointerToData('g_nScriptOut', @g_nScriptOut, g_PSRunner.FindType2(btS32));
    SetPointerToData('g_bLogUDP', @g_bLogUDP, g_PSRunner.FindType2(btU8));
    SetPointerToData('g_strMSAddress', @g_strMSAddress, g_PSRunner.FindType2(btString));
    SetPointerToData('g_strMSPost', @g_strMSPost, g_PSRunner.FindType2(btString));
    SetPointerToData('g_bApplyPatches', @g_bApplyPatches, g_PSRunner.FindType2(btU8));
    SetPointerToData('g_bMSProxy', @g_bMSProxy, g_PSRunner.FindType2(btU8));
    SetPointerToData('g_strMSProxyAddress', @g_strMSProxyAddress, g_PSRunner.FindType2(btString));
    SetPointerToData('g_nServerClickDelay', @g_nServerClickDelay, g_PSRunner.FindType2(btU32));
    SetPointerToData('g_strHttpMyUserAgent', @g_strHttpMyUserAgent, g_PSRunner.FindType2(btString));

    g_Logger.Debug('ScriptMgr_Compile - Success');
  end;
end;

function ScriptMgr_RunModDetection: string;
begin
  Result := '';
  try
    Result := g_PSRunner{%H-}.RunProcPN([], PAS_MOD_DETECTION_PROC);
  except
    on E: Exception do g_Logger.Error('ScriptMgr_RunModDetection - Error while executing script: %s', [E.Message]);
  end;
end;

function ScriptMgr_RunRaceDetection(strMod: string; nRace: Integer): string;
begin
  Result := '';
  try
    Result := g_PSRunner{%H-}.RunProcPN([{%H-}strMod, {%H-}nRace], PAS_RACE_DETECTION_PROC);
  except
    on E: Exception do g_Logger.Error('ScriptMgr_RunRaceDetection - Error while executing script: %s', [E.Message]);
  end;
end;

function ScriptMgr_GetPCC_Columns(strMod: string; strLang: string): string;
begin
  Result := '';
  try
    Result := g_PSRunner{%H-}.RunProcPN([{%H-}strMod, {%H-}strLang], PAS_PCC_COLUMNS_PROC);
  except
    on E: Exception do g_Logger.Error('ScriptMgr_RunGetPCC_Columns - Error while executing script: %s', [E.Message]);
  end;
end;

function ScriptMgr_GetPCC_Props(strMod: string): string;
begin
  Result := '';
  try
    Result := g_PSRunner{%H-}.RunProcPN([{%H-}strMod], PAS_PCC_PROPS_PROC);
  except
    on E: Exception do g_Logger.Error('ScriptMgr_RunGetPCC_Props - Error while executing script: %s', [E.Message]);
  end;
end;

procedure ScriptMgr_UpdateLocalData(nServerIndex: Integer);
begin
  try
    g_PSRunner{%H-}.RunProcPN([{%H-}nServerIndex], PAS_UPDATE_LD_PROC);
  except
    on E: Exception do g_Logger.Error('ScriptMgr_UpdateLocalData - Error while executing script: %s', [E.Message]);
  end;
end;

procedure ScriptMgr_Init;
begin
  g_PSCompiler := TPSPascalCompiler.Create;
  g_PSCompiler.OnUses := @ScriptOnUses;
  g_PSRunner := TPSExec.Create;
  g_ScriptText := TStringList.Create;
  g_PSRunner.RegisterDelphiFunction(@UTILS_Sleep, 'UTILS_SLEEP', cdRegister);
  g_PSRunner.RegisterDelphiFunction(@UTILS_LogError, 'UTILS_LOGERROR', cdRegister);
  g_PSRunner.RegisterDelphiFunction(@SERVER_GetProp, 'SERVER_GETPROP', cdRegister);
end;

procedure ScriptMgr_Destroy;
begin
  g_PSCompiler.Free;
  g_PSRunner.Free;
  g_ScriptText.Free;
end;

end.

