unit UPlug;

{$mode delphi}

interface

uses
  Windows, Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, USAPTaskBar;

type

  { TfmPlug }

// Эта форма нужна для того чтобы заглушыть прозрачные borders в win10 основной формы
// Должна распологаться точно под основной формой
  TfmPlug = class(TForm)
    Bevel: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    { private declarations }
    procedure WMShowWindow(var Msg: TWMShowWindow); message WM_SHOWWINDOW; // Lock minimizeing window
  public
    { public declarations }
  end;

var
  fmPlug: TfmPlug;

implementation

{$R *.lfm}

{ TfmPlug }

procedure TfmPlug.FormCreate(Sender: TObject);
begin
  //Remove title Bar
  SetWindowLong(Self.Handle, GWL_EXSTYLE, getWindowLong(Self.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW);
  SetWindowLong(Self.Handle, GWL_STYLE, (getWindowLong(Self.Handle, GWL_STYLE) {%H-}or WS_POPUP) AND (NOT WS_DLGFRAME));
end;

procedure TfmPlug.FormDestroy(Sender: TObject);
begin
  fmPlug := nil;
end;

procedure TfmPlug.FormPaint(Sender: TObject);
begin
  fSAPTaskBar.SetPlug;
end;

procedure TfmPlug.WMShowWindow(var Msg: TWMShowWindow);
begin
  if not Msg.Show
  then Msg.Result := 0
  else inherited;
end;

end.

