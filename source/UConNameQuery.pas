unit UConNameQuery;

{$MODE Delphi}

interface

uses
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, USAPTaskBar;

type
  TfmConNameQuery = class(TForm)
    cbConName: TComboBox;
    lblConName: TLabel;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    cbSave: TCheckBox;
    lbConnectTo: TLabel;
    lbSys_Desc: TLabel;
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmConNameQuery: TfmConNameQuery;

implementation

{$R *.lfm}

procedure TfmConNameQuery.btnOKClick(Sender: TObject);
begin
  if cbConName.Text = '' then begin
    MessageDlg(rsMsg010, mtError, [mbOk], 0);
    Exit;
  end;

  ModalResult := mrOk;
end;

end.
