unit uPass;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons;

type

  { TfmPassword }

  TfmPassword = class(TForm)
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
    edPassword: TEdit;
    lbPassTitle: TLabel;
    lbPassword: TLabel;
    btnShowPassword: TSpeedButton;
    procedure btnShowPasswordMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnShowPasswordMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  fmPassword: TfmPassword;

implementation

{$R *.lfm}


{ TfmPassword }

procedure TfmPassword.btnShowPasswordMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  edPassword.PasswordChar:= #0;
end;

procedure TfmPassword.btnShowPasswordMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  edPassword.PasswordChar:= '*';
end;

end.

