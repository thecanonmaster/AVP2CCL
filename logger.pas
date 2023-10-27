unit logger;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, eventlog;

type

  { TEventLogEx }

  TEventLogEx = class(TEventLog)
  private
    FLevel: Integer;
  public
    property Level: Integer read FLevel write FLevel;
    function CheckLevel(LevelToCheck: TEventType): Boolean;
    procedure Warning (const Msg : String);
    procedure Warning (const Fmt : String; Args : Array of const);
    procedure Error (const Msg : String);
    procedure Error (const Fmt : String; Args : Array of const);
    procedure Debug (const Msg : String);
    procedure Debug (const Fmt : String; Args : Array of const);
    procedure Info (const Msg : String);
    procedure Info (const Fmt : String; Args : Array of const);
  end;

implementation

var
  g_EventTypeToIntMap: array[0..4] of Integer = (4, 2, 1, 0, 3);  // (etCustom,etInfo,etWarning,etError,etDebug);

{ TEventLogEx }

function TEventLogEx.CheckLevel(LevelToCheck: TEventType): Boolean;
begin
  Result := (g_EventTypeToIntMap[Ord(LevelToCheck)] <= FLevel)
end;

procedure TEventLogEx.Warning(const Msg: String);
begin
  if not CheckLevel(etWarning) then Exit;
  inherited Warning(Msg);
end;

procedure TEventLogEx.Warning(const Fmt: String; Args: array of const);
begin
  if not CheckLevel(etWarning) then Exit;
  inherited Warning(Fmt, Args);
end;

procedure TEventLogEx.Error(const Msg: String);
begin
  if not CheckLevel(etError) then Exit;
  inherited Error(Msg);
end;

procedure TEventLogEx.Error(const Fmt: String; Args: array of const);
begin
  if not CheckLevel(etError) then Exit;
  inherited Error(Fmt, Args);
end;

procedure TEventLogEx.Debug(const Msg: String);
begin
  if not CheckLevel(etDebug) then Exit;
  inherited Debug(Msg);
end;

procedure TEventLogEx.Debug(const Fmt: String; Args: array of const);
begin
  if not CheckLevel(etDebug) then Exit;
  inherited Debug(Fmt, Args);
end;

procedure TEventLogEx.Info(const Msg: String);
begin
  if not CheckLevel(etInfo) then Exit;
  inherited Info(Msg);
end;

procedure TEventLogEx.Info(const Fmt: String; Args: array of const);
begin
  if not CheckLevel(etInfo) then Exit;
  inherited Info(Fmt, Args);
end;

end.

