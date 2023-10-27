unit SynUDPServer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, blcksock, contnrs, mmsystem;

const
  MAX_UDP_MESSAGES = 100;

type

  TOnReceiveCallback = procedure(strBuffer: string; strIP: string; nPort: Word; dwTime: DWORD);
  TOnErrorCallback = procedure(strValue: string);

  TUDPMessage = class(TObject)
    IP: string;
    Port: Word;
    Time: DWORD;
    Msg: string;
    ObjectTime: PDWord;
  end;

  { TUDPThread }

  TUDPThread = class(TThread)
  protected
    m_Socket: TUDPBlockSocket;
    m_fuOnError: TOnErrorCallback;
    m_bActive: Boolean;
    procedure OnStatus(Sender: TObject; Reason: THookSocketReason; const Value: string);
  public
    property Active: Boolean read m_bActive write m_bActive;
    constructor Create; virtual;
    destructor Destroy; override;
  end;

  { TUDPServer }

  TUDPServer = class(TUDPThread)
  protected
    m_Messages: TObjectQueue;
    m_SendMessages: TObjectQueue;
    m_strPort: string;
    m_fuOnReceive: TOnReceiveCallback;
    procedure Execute; override;
  public
    property Port: string read m_strPort write m_strPort;
    property OnReceive: TOnReceiveCallback read m_fuOnReceive write m_fuOnReceive;
    property OnError: TOnErrorCallback read m_fuOnError write m_fuOnError;
    procedure Send(strIP: string; strRemotePort: string; pData: Pointer;
      nSize: integer);
    procedure SendString(strIP: string; strRemotePort: string; strData: string);
    procedure SendGUA(strIP: string; strRemotePort: string; pData: Pointer;
      nSize: integer);
    procedure SendStringGUA(strIP: string; strRemotePort: string;
      strData: string);
    procedure PrepareToSendString(strIP: string; strRemotePort: Word;
      strData: string; ObjectTime: PDWord);
    function ResolveName(strName: string): string;
    procedure CloseSocket;
    function ReadMessage: TUDPMessage;
    function SendMessage: TUDPMessage;
    constructor Create; override;
    destructor Destroy; override;
  end;


implementation

uses common;

{ TUDPThread }

constructor TUDPThread.Create;
begin
  m_bActive := True;
  inherited Create(False);
  FreeOnTerminate := False;
  Priority := tpNormal;
end;

destructor TUDPThread.Destroy;
begin
  m_Socket.Free;
  g_Logger.Debug('TUDPThread.Destroy');
  inherited;
end;

procedure TUDPThread.OnStatus(Sender: TObject; Reason: THookSocketReason;
  const Value: string);
var strReason: String;
begin
  if (Reason = HR_Error) and (m_fuOnError <> nil) then
  begin
    if m_fuOnError <> nil then m_fuOnError(Value);
  end;

  if g_bLogUDP then
  begin
    WriteStr(strReason, Reason);
    g_Logger.Debug('TUDPThread.OnStatus - [ %s ] %s', [strReason, Value]);
  end;
end;

{ TUDPServer }

procedure TUDPServer.CloseSocket;
begin
  g_Logger.Debug('TUDPServer.CloseSocket (force)');
  m_Socket.CloseSocket;
end;

function TUDPServer.ReadMessage: TUDPMessage;
begin
  Result := (m_Messages.Pop as TUDPMessage);
end;

function TUDPServer.SendMessage: TUDPMessage;
begin
  Result := (m_SendMessages.Pop as TUDPMessage);
end;

constructor TUDPServer.Create;
begin
  inherited Create;

  m_Socket := TUDPBlockSocket.Create;
  m_Socket.OnStatus := @OnStatus;
  if Port = '0' then
    m_Socket.Bind(cAnyHost, '')
  else
    m_Socket.Bind(cAnyHost, Port);
  m_Socket.CloseSocket;
  m_Socket.Free;

  m_Socket := TUDPBlockSocket.Create;
  m_Socket.OnStatus := @OnStatus;
  m_Messages := TObjectQueue.Create;
  m_SendMessages := TObjectQueue.Create;
end;

destructor TUDPServer.Destroy;
var Obj: TObject;
begin
  inherited Destroy;
  Obj := m_Messages.Pop;
  while Obj <> nil do
  begin
    Obj.Free;
    Obj := m_Messages.Pop;
  end;
  m_Messages.Free;
  m_SendMessages.Free;
end;

procedure TUDPServer.Execute;
var
  sResult: string;
  UDPMsg: TUDPMessage;
begin

  if Port = '0' then
    m_Socket.Bind(cAnyHost, '')
  else
    m_Socket.Bind(cAnyHost, Port);

  if (m_Socket.LastError = 0) then
  begin
    while not Terminated do
    begin
      sResult := m_Socket.RecvPacket(g_nUDPTimeout);
      if m_Socket.LastError = 0 then
      begin
        if (m_Messages.Count < MAX_UDP_MESSAGES) and (sResult[1] = '\') then //and (Length(sResult) > 16) then
        begin
          UDPMsg := TUDPMessage.Create;
          UDPMsg.IP := m_Socket.GetRemoteSinIP;
          UDPMsg.Port := m_Socket.GetRemoteSinPort;
          UDPMsg.Time := timeGetTime;
          UDPMsg.Msg := sResult;
          m_Messages.Push(UDPMsg);
        end;
      end;
    end;
  end
  else
  begin
    g_Logger.Error('TUDPServer.Execute - %s [%s:%d] (on start)', [m_Socket.LastErrorDesc, m_Socket.GetRemoteSinIP, m_Socket.GetRemoteSinPort]);
  end;
end;

procedure TUDPServer.Send(strIP: string; strRemotePort: string; pData: Pointer; nSize: integer);
begin
  m_Socket.Connect(strIP, strRemotePort);
  m_Socket.SendBuffer(pData, nSize);
end;

procedure TUDPServer.SendString(strIP: string; strRemotePort: string; strData: string);
begin
  m_Socket.Connect(strIP, strRemotePort);
  m_Socket.SendString(strData);
end;

procedure TUDPServer.SendGUA(strIP: string; strRemotePort: string; pData: Pointer; nSize: integer);
begin
  m_Socket.Connect(strIP, strRemotePort);
  m_Socket.SendBuffer(pData, nSize);
  m_Socket.SendBuffer(pData, nSize);
  m_Socket.SendBuffer(pData, nSize);
  m_Socket.SendBuffer(pData, nSize);
  m_Socket.SendBuffer(pData, nSize);
end;

procedure TUDPServer.SendStringGUA(strIP: string; strRemotePort: string; strData: string);
begin
  m_Socket.Connect(strIP, strRemotePort);
  m_Socket.SendString(strData);
  m_Socket.SendString(strData);
  m_Socket.SendString(strData);
  m_Socket.SendString(strData);
  m_Socket.SendString(strData);
end;

procedure TUDPServer.PrepareToSendString(strIP: string; strRemotePort: Word;
  strData: string; ObjectTime: PDWord);
var
  UDPMsg: TUDPMessage;
begin
  UDPMsg := TUDPMessage.Create;
  UDPMsg.IP := strIP;
  UDPMsg.Port := strRemotePort;
  UDPMsg.Msg := strData;
  UDPMSg.ObjectTime := ObjectTime;
  m_SendMessages.Push(UDPMsg);
end;

function TUDPServer.ResolveName(strName: string): string;
begin
  Result := m_Socket.ResolveName(strName);
end;


end.

