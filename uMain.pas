unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Memo.Types, FMX.ScrollBox,
  FMX.Memo;

const
  ConstNBOfThread = 3;

type

  TLogChangeEvent = procedure(Sender: TObject) of object;

  TMyThread = class(TThread)
  public
    procedure Execute; override;
  end;

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Timer1: TTimer;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FLogChangeEvent: TLogChangeEvent;
  public

    property LogChangeEvent: TLogChangeEvent read FLogChangeEvent
      write FLogChangeEvent;
    procedure MethodeChangeEvent(Sender: TObject);
    { Public declarations }
  end;

var
  Form1: TForm1;
  ThreadList: tlist;
  MyThread, MyThread2, MyThread3, MyThread4, MyThread5: TMyThread;

implementation

uses System.Rtti;
{$R *.fmx}

procedure TMyThread.Execute;
var
  lRttiContext: TRttiContext;
begin
  while true do
  begin
    TRttiContext.KeepContext;
    TRttiContext.DropContext;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  I: integer;
begin
  if not assigned(ThreadList) then
    ThreadList := tlist.Create;
  for I := 0 to ConstNBOfThread do
  begin
    if ThreadList.Count > I then
      TMyThread(ThreadList[I]).Resume
    else
      ThreadList.add(TMyThread.Create(false));

  end;
  Timer1.Enabled := true;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  I: integer;
begin
  if not assigned(ThreadList) then
    ThreadList := tlist.Create;
  for I := 0 to ThreadList.Count - 1 do
  begin
    if assigned(ThreadList[I]) then
      TMyThread(ThreadList[I]).suspend
  end;
  Timer1.Enabled := false;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FLogChangeEvent := MethodeChangeEvent;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  context: TRttiContext;
  method: TValue;
  methodType: TRttiInvokableType;
begin
  Memo1.lines.add('Find methode');
  method := context.GetType(Form1.ClassType).GetProperty('LogChangeEvent')
    .GetValue(Form1);
  methodType := context.GetType(method.TypeInfo) as TRttiInvokableType;
  methodType.Invoke(method, [Form1 { Sender } ]);
  Memo1.lines.add('After call methode');
end;

procedure TForm1.MethodeChangeEvent(Sender: TObject);
begin
  if Memo1.lines.Count > 10 then
    Memo1.lines.clear;
  Memo1.lines.add('On rtti call methode');
end;

end.
