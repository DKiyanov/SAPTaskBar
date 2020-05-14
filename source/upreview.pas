unit UPreView;

{$mode delphi}

interface

uses
  Windows, Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, USAPTaskBar;

type

  { TfmPreView }

  TfmPreView = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    Btn : TTaskBtn;
    SizeChanged : Boolean;
  end;

var
  fmPreView: TfmPreView;

implementation

{$R *.lfm}

{ TfmPreView }

procedure TfmPreView.FormCreate(Sender: TObject);
begin
//Remove title Bar
  SetWindowLong(Self.Handle, GWL_EXSTYLE, getWindowLong(Self.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW);
  SetWindowLong(Self.Handle, GWL_STYLE, (getWindowLong(Self.Handle, GWL_STYLE) {%H-}or WS_POPUP) AND (NOT WS_DLGFRAME));

  Self.DoubleBuffered:= True;
end;

procedure TfmPreView.FormShow(Sender: TObject);
begin
  SizeChanged := False;
end;

procedure TfmPreView.FormResize(Sender: TObject);
begin
  fSAPTaskBar.PreviewWidth:= Self.Width;
  fSAPTaskBar.PreviewHeight:= Self.Height;
  SizeChanged := True;
end;

procedure TfmPreView.FormHide(Sender: TObject);
begin
  Self.Btn := nil;

  if not SizeChanged then Exit;
  SizeChanged := False;
  fSAPTaskBar.RefreshScreenShots;
end;

procedure TfmPreView.FormPaint(Sender: TObject);
begin
  if Self.Btn = nil then Exit;

  WaitForSingleObject(BMutex, INFINITE);
  try
    if SizeChanged then begin
      Self.Btn.PreviewBmp.DrawTo(Self.Canvas.Handle, Rect(0,0, Self.Width, Self.Height), Self.Btn.PreviewBmp.BoundsRect);
      Exit;
    end;

    Self.Btn.PreviewBmp.DrawTo(Self.Canvas.Handle, 0, 0);
  finally
    ReleaseMutex(BMutex);
  end;
end;

end.

