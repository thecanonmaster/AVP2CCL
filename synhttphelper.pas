unit SynHTTPHelper;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, httpsend, synautil, blcksock, synsock, typinfo, mmsystem,
  synacode, Graphics, ssl_openssl, common;

const
  MYMSG_END = 0;
  MYMSG_START = 1;
  MYMSG_FILE = 2;
  MYMSG_ENDFILE = 3;
  MYMSG_NONE = 4;
  MYMSG_ERROR = 5;

type
  TMyCallback = procedure(bSuccess: boolean; Stream: TMemoryStream; strErrorMsg: string; strData: String);
  TMyCallbackProgress = procedure(nMsg: integer; nData: Integer);

type

  { TDownloadFileThread }

  TDownloadFileThread = class(TThread)
  private
    { private declarations }
    m_slURLs: TStringList;
    m_bResult: Boolean;
    m_strErrorMessage: string;
    m_HTTPSend: THTTPSend;
    m_nTotalSize: Int64;
    m_nCurSize: Int64;
    m_strData: string;
  protected
    { protected declarations }
    m_fuCallback: TMyCallback;
    m_fuCallbackProgress: TMyCallbackProgress;
    function DoValidityCheck: Boolean;
    procedure Execute; override;
    procedure SyncCallback;
    function DownloadHTTP(nIndex: Integer): Boolean;
    procedure SockPutCallBack(Sender: TObject; Reason: THookSocketReason;
      const Value: string);
  public
    { public declarations }
    m_anValidityCheck: TDynByteArray;
    property URLs: TStringList read m_slURLs write m_slURLs;
    property Data: string read m_strData write m_strData;
    property Callback: TMyCallback read m_fuCallback write m_fuCallback;
    property ProgressCallback: TMyCallbackProgress read m_fuCallbackProgress write m_fuCallbackProgress;
    procedure Abort;
    constructor Create;
    destructor Destroy; override;
  end;

  { TDownloadPageThread }

  TDownloadPageThread = class(TThread)
  private
    { private declarations }
    m_slURLs: TStringList;
    m_bResult: Boolean;
    m_strPostMessage: string;
    m_strErrorMessage: string;
    m_strValidityCheck: string;
    m_HTTPSend: THTTPSend;
    m_strData: String;
    function Download(nIndex: Integer): Boolean;
  protected
    { protected declarations }
    m_fuCallback: TMyCallback;
    procedure Execute; override;
    procedure SyncCallback;
    function DownloadHTTP(nIndex: Integer): Boolean;
  public
    { public declarations }
    property URLs: TStringList read m_slURLs write m_slURLs;
    property ValidityCheck: string read m_strValidityCheck write m_strValidityCheck;
    property PostMessage: string read m_strPostMessage write m_strPostMessage;
    property Data: string read m_strData write m_strData;
    property Callback: TMyCallback read m_fuCallback write m_fuCallback;
    constructor Create;
    destructor Destroy; override;
  end;

  { TMSSocket }

  TMSSocket = class(TObject)
  private
    m_Socket: TTCPBlockSocket;
    m_dwTime: DWORD;
    procedure MSOnStatus(Sender: TObject; Reason: THookSocketReason; const Value: String);
  public
    property Time: DWORD read m_dwTime write m_dwTime;
    property Socket: TTCPBlockSocket read m_Socket write m_Socket;
    constructor Create;
    destructor Destroy; override;
  end;

var
  g_bMSConnected: Boolean = False;
  g_MSSocket: TMSSocket = nil;

function DownloadMSList(strAddress: string; strPostMsg: string; Stream: TStream): Boolean;
procedure DestroyMSSocket;

implementation

function GetLength(const URL: string): int64;
var
  HTTP: THTTPSend;
  i: Integer;
  strSize: string;
  chTemp: Char;
begin
  HTTP := THTTPSend.Create;
  HTTP.UserAgent := g_strHttpMyUserAgent;
  try
    if HTTP.HTTPMethod('HEAD', URL) then
    begin
      for i := 0 to HTTP.Headers.Count - 1 do
      begin
        if Pos('content-length', LowerCase(HTTP.Headers[i])) > 0 then
        begin
          strSize := '';
          for chTemp in HTTP.Headers[i] do
          begin
            if chTemp in ['0'..'9'] then
              strSize := strSize + chTemp;
          end;
          Result := StrToInt64(strSize) + Length(HTTP.Headers.Text);
          break;
        end;
      end;
    end
    else
    begin
      Result := -1;
    end;
  finally
    HTTP.Free;
  end;
end;

function MyHttpGetBinary(const URL: string; const Response: TStream): Boolean;
var
  HTTP: THTTPSend;
begin
  HTTP := THTTPSend.Create;
  HTTP.UserAgent := g_strHttpMyUserAgent;
  try
    Result := HTTP.HTTPMethod('GET', URL);
    if Result then
    begin
      Response.Seek(0, soFromBeginning);
      Response.CopyFrom(HTTP.Document, 0);
    end;
  finally
    HTTP.Free;
  end;
end;

function MyHttpGetText(const URL: string; const Response: TStrings): Boolean;
var
  HTTP: THTTPSend;
begin
  HTTP := THTTPSend.Create;
  HTTP.UserAgent := g_strHttpMyUserAgent;
  try
    Result := HTTP.HTTPMethod('GET', URL);
    if Result then
      Response.LoadFromStream(HTTP.Document);
  finally
    HTTP.Free;
  end;
end;

function DownloadMSList(strAddress: string; strPostMsg: string; Stream: TStream): Boolean;
var nPos: Integer;
    strResult: string;
    bTimeout: Boolean;
begin
  if g_bMSProxy then
  begin
    g_Logger.Debug('DownloadMSList - using proxy');
    Result := MyHttpGetBinary(g_strMSProxyAddress, Stream);
    Exit;
  end;
  bTimeout := False;
  if (g_MSSocket <> nil) and (timeGetTime - g_MSSocket.Time > g_nMSTimeout) then
  begin
    g_Logger.Debug('DownloadMSList - connection timeout');
    g_MSSocket.Socket.SendString(strPostMsg);
    g_MSSocket.Socket.RecvPacket(g_nTCPTimeout);
    g_MSSocket.Free;
    g_MSSocket := nil;
    g_bMSConnected := False;
    bTimeout := True;
  end;
  if g_MSSocket = nil then
  begin
    g_MSSocket := TMSSocket.Create;

    if g_strLocalTCPPort = '0' then
      g_MSSocket.Socket.Bind('', '')
    else
      g_MSSocket.Socket.Bind('', g_strLocalTCPPort);

    g_MSSocket.Socket.OnStatus := @g_MSSocket.MSOnStatus;
    g_MSSocket.Time := timeGetTime;
  end;
  nPos := Pos(':', strAddress);
  g_MSSocket.Socket.Connect(Copy(strAddress, 1, nPos-1), Copy(strAddress, nPos+1, Length(strAddress)));
  if not g_bMSConnected then
  begin
    g_MSSocket.Socket.RecvPacket(g_nTCPTimeout);
    g_bMSConnected := True;
  end;
  g_MSSocket.Socket.SendString(strPostMsg);
  strResult := g_MSSocket.Socket.RecvPacket(g_nTCPTimeout);

  if strResult <> '' then
  begin
    Stream.WriteBuffer(strResult[1], Length(strResult));
    Result := True;
  end
  else
  begin
    Result := False;
    if bTimeout then
      g_strRefreshAllError := 'ERROR: Connection timeout'
    else
      g_strRefreshAllError := 'ERROR: Blank response';
  end;
end;

procedure DestroyMSSocket;
begin
  if g_MSSocket <> nil then
  begin
    g_MSSocket.Socket.CloseSocket;
    g_MSSocket.Free;
  end;
end;

{ TMSSocket }

procedure TMSSocket.MSOnStatus(Sender: TObject; Reason: THookSocketReason;
  const Value: String);
var strEnum: string;
begin
  strEnum := GetEnumName(TypeInfo(THookSocketReason), Integer(Reason));
  g_Logger.Debug('TMSSocket.MSOnStatus - %s: %s', [strEnum, Value]);
end;

constructor TMSSocket.Create;
begin
  m_Socket := TTCPBlockSocket.Create;;
end;

destructor TMSSocket.Destroy;
begin
  inherited Destroy;
  m_Socket.CloseSocket;
  m_Socket.Free;
end;

constructor TDownloadFileThread.Create;
begin
  inherited Create(True);
  m_strData := '';
  m_slURLs := TStringList.Create;
  m_bResult := False;
  FreeOnTerminate := True;
  m_HTTPSend := THTTPSend.Create;
  m_nCurSize := 0;
  g_Logger.Info('TDownloadFileThread.Create');
end;

destructor TDownloadFileThread.Destroy;
begin
  inherited Destroy;
  SetLength(m_anValidityCheck, 0);
  m_slURLs.Free;
  if m_HTTPSend <> nil then
  begin
    m_HTTPSend.Free;
    m_HTTPSend := nil;
  end;
  g_Logger.Info('TDownloadFileThread.Destroy: ' + m_strData);
end;

function TDownloadFileThread.DoValidityCheck: Boolean;
var nLength, i: Integer;
begin
  nLength := Length(m_anValidityCheck);
  if nLength = 0 then Exit(True);
  if nLength > m_HTTPSend.Document.Size then Exit(False);

  for i := 0 to nLength - 1 do
  begin
    if m_anValidityCheck[i] <> m_HTTPSend.Document.ReadByte then
    begin
      m_HTTPSend.Document.Position := 0;
      Exit(False);
    end;
  end;
  m_HTTPSend.Document.Position := 0;
  Result := True;
end;

procedure TDownloadFileThread.Execute;
var i: Integer;
begin
  for i := 0 to m_slURLs.Count - 1 do
  begin
    m_bResult := DownloadHTTP(i);
    if m_bResult then
    begin
      if DoValidityCheck then
      begin
        m_strData := m_strData + ';' + IntToStr(i);
        Synchronize(@SyncCallback);
        Exit;
      end;
    end;
    m_HTTPSend.Free;
    m_HTTPSend := THTTPSend.Create;
  end;
  m_bResult := False;
  Synchronize(@SyncCallback);
end;

procedure TDownloadFileThread.SyncCallback;
begin
  m_fuCallback(m_bResult, m_HTTPSend.Document, m_strErrorMessage, m_strData);
end;

function TDownloadFileThread.DownloadHTTP(nIndex: Integer): Boolean;
const
  MaxRetries = 5;
var
  bGetResult: boolean;
  nRetryAttempt: Integer;
begin
  m_slURLs[nIndex] := EncodeURL(m_slURLs[nIndex]);
  m_nTotalSize := GetLength(m_slURLs[nIndex]);
  if m_nTotalSize = -1 then
  begin
    g_Logger.Error('TDownloadFileThread.DownloadHTTP - File size is not available');
    m_strErrorMessage := 'File size is not available';
    Exit(False);
  end;
  Result := False;
  nRetryAttempt := 1;
  m_HTTPSend.Timeout := 2500;
  m_HTTPSend.UserAgent := g_strHttpMyUserAgent;
  try
    try
      m_HTTPSend.Sock.OnStatus := @SockPutCallBack;
      bGetResult := m_HTTPSend.HTTPMethod('GET', m_slURLs[nIndex]);
      while (bGetResult = False) and (nRetryAttempt < MaxRetries) do
      begin
        g_Logger.Debug('TDownloadFileThread.DownloadHTTP - RetryAttempt = %d', [nRetryAttempt]);
        sleep(500);
        bGetResult := m_HTTPSend.HTTPMethod('GET', m_slURLs[nIndex]);
        Inc(nRetryAttempt, 1);
      end;
      case m_HTTPSend.Resultcode of
        100..299:
        begin
          m_strErrorMessage := 'Success';
          g_Logger.Debug('TDownloadFileThread.DownloadHTTP - Success');
          Result := True;
        end;
        300..399:
        begin
          Result := False;
          m_strErrorMessage := 'Redirection is not supported';
          g_Logger.Error('TDownloadFileThread.DownloadHTTP - Redirection is not supported');
        end;

        400..499:
        begin
          m_strErrorMessage := 'File not found on server';
          Result := False;
          g_Logger.Error('TDownloadFileThread.DownloadHTTP - File not found on server');
        end;

        500..599:
        begin
          m_strErrorMessage := 'Internal server error';
          Result := False;
          g_Logger.Error('TDownloadFileThread.DownloadHTTP - Internal server error');
        end;

        else
        begin
          m_strErrorMessage := 'Unknown error';
          Result := False;
          g_Logger.Error('TDownloadFileThread.DownloadHTTP - Unknown error');
        end;
      end;
    except
      m_strErrorMessage := 'Server is not responding';
      g_Logger.Error('TDownloadPageThread.DownloadHTTP - Server is not responding');
      Result := False;
    end;
  finally

  end;
end;

procedure TDownloadFileThread.SockPutCallBack(Sender: TObject;
  Reason: THookSocketReason; const Value: string);
begin
  case Reason of
    HR_ReadCount:
    begin
      Inc(m_nCurSize, StrToIntDef(Value, 0));
      m_fuCallbackProgress(MYMSG_FILE, Round(100 * (m_nCurSize / m_nTotalSize)));
    end;
    HR_Connect:
    begin
      m_nCurSize := 0;
    end;
  end;
end;

procedure TDownloadFileThread.Abort;
begin
  if m_HTTPSend <> nil then
    m_HTTPSend.Abort;
end;

constructor TDownloadPageThread.Create;
begin
  inherited Create(True);
  m_strData := '';
  m_slURLs := TStringList.Create;
  m_bResult := False;
  FreeOnTerminate := True;
  m_HTTPSend := THTTPSend.Create;
  m_strPostMessage := '';
  g_Logger.Debug('TDownloadPageThread.Create');
end;

destructor TDownloadPageThread.Destroy;
begin
  inherited Destroy;
  m_slURLs.Free;
  m_HTTPSend.Free;
  g_Logger.Debug('TDownloadPageThread.Destroy');
end;

function TDownloadPageThread.DownloadHTTP(nIndex: Integer): Boolean;
const
  MaxRetries = 5;
var
  bGetResult: boolean;
  nRetryAttempt: integer;
begin
  m_slURLs[nIndex] := EncodeURL(m_slURLs[nIndex]);
  Result := False;
  nRetryAttempt := 1;
  m_HTTPSend.Timeout := 2500;
  m_HTTPSend.UserAgent := g_strHttpMyUserAgent;
  m_HTTPSend.KeepAlive := False;
  try
    try
      bGetResult := Download(nIndex);
      while (bGetResult = False) and (nRetryAttempt < MaxRetries) do
      begin
        g_Logger.Debug('TDownloadPageThread.DownloadHTTP - RetryAttempt = %d', [nRetryAttempt]);
        sleep(500);
        bGetResult := Download(nIndex);
        Inc(nRetryAttempt, 1);
      end;
      case m_HTTPSend.Resultcode of
        100..299:
        begin
          m_strErrorMessage := 'Success';
          g_Logger.Debug('TDownloadPageThread.DownloadHTTP - Success');
          Result := True;
        end;
        300..399:
        begin
          Result := False;
          m_strErrorMessage := 'Redirection is not supported';
          g_Logger.Error('TDownloadPageThread.DownloadHTTP - Redirection is not supported');
        end;

        400..499:
        begin
          m_strErrorMessage := 'File not found on server';
          Result := False;
          g_Logger.Error('TDownloadPageThread.DownloadHTTP - File not found on server');
        end;

        500..599:
        begin
          m_strErrorMessage := 'Internal server error';
          Result := False;
          g_Logger.Error('TDownloadPageThread.DownloadHTTP - Internal server error');
        end;

        else
        begin
          m_strErrorMessage := 'Unknown error';
          Result := False;
          g_Logger.Error('TDownloadPageThread.DownloadHTTP - Unknown error');
        end;
      end;
    except
      m_strErrorMessage := 'Server is not responding';
      g_Logger.Error('TDownloadPageThread.DownloadHTTP - Server is not responding');
      Result := False;
    end;
  finally

  end;
end;


procedure TDownloadPageThread.SyncCallback;
begin
  m_fuCallback(m_bResult, m_HTTPSend.Document, m_strErrorMessage, m_strData);
end;

function TDownloadPageThread.Download(nIndex: Integer): Boolean;
begin
  if m_strPostMessage = '' then
  begin
    Result := m_HTTPSend.HTTPMethod('GET', m_slURLs[nIndex]);
  end
  else
  begin
    WriteStrToStream(m_HTTPSend.Document, m_strPostMessage);
    m_HTTPSend.HTTPMethod('POST', m_slURLs[nIndex]);
  end;
end;

procedure TDownloadPageThread.Execute;
var i: Integer;
    slData: TStringList;
begin
  slData := TStringList.Create;
  for i := 0 to m_slURLs.Count - 1 do
  begin
    m_bResult := DownloadHTTP(i);
    if m_bResult then
    begin
      slData.LoadFromStream(m_HTTPSend.Document);
      m_HTTPSend.Document.Position := 0;
      if slData.IndexOf(m_strValidityCheck) > -1 then
      begin
        slData.Free;
        m_strData := m_strData + ';' + IntToStr(i);
        Synchronize(@SyncCallback);
        Exit;
      end;
    end;
    m_HTTPSend.Free;
    m_HTTPSend := THTTPSend.Create;
  end;
  slData.Free;
  m_bResult := False;
  Synchronize(@SyncCallback);
end;

end.

