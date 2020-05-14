unit UMapIcon;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, ExtCtrls, types, masks, USAPTaskBar, Menus;

type

  { TfmMapIcon }

  TfmMapIcon = class(TForm)
    btnDel: TBitBtn;
    btnCancel: TBitBtn;
    btnOk: TBitBtn;
    cbxIcon: TComboBox;
    edMask: TEdit;
    edTitle: TEdit;
    imgOk: TImage;
    lblIcon: TLabel;
    lblMask: TLabel;
    lblTitle: TLabel;
    btnLoadIconFromFile: TSpeedButton;
    procedure btnLoadIconFromFileClick(Sender: TObject);
    procedure cbStatusBarInfoChange(Sender: TObject);
    procedure cbxIconDrawItem({%H-}Control: TWinControl; Index: Integer; ARect: TRect; {%H-}State: TOwnerDrawState);
    procedure cbxIconSelect(Sender: TObject);
    procedure edMaskChange(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }

    procedure CheckOk;
  end;

var
  fmMapIcon: TfmMapIcon;

implementation

{$R *.lfm}

{ TfmMapIcon }

procedure TfmMapIcon.cbxIconDrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  ii : Integer;
begin
  cbxIcon.Canvas.FillRect(ARect);
  ii := TMenuItem(Self.cbxIcon.Items.Objects[Index]).ImageIndex;
  fSAPTaskBar.IconList.Draw(cbxIcon.Canvas, ARect.Left + 2, ARect.Top, ii, True);
  cbxIcon.Canvas.TextOut(ARect.Left + 20, ARect.Top, Self.cbxIcon.Items[Index]);
end;

procedure TfmMapIcon.btnLoadIconFromFileClick(Sender: TObject);
var
  mi : TMenuItem;
begin
  mi := fSAPTaskBar.LoadIconFromFile;
  if mi = nil then Exit;

  cbxIcon.ItemIndex := cbxIcon.Items.AddObject(mi.Caption, mi);
  cbxIconSelect(Self);
end;

procedure TfmMapIcon.cbStatusBarInfoChange(Sender: TObject);
begin
  CheckOk;
end;

procedure TfmMapIcon.cbxIconSelect(Sender: TObject);
begin
  CheckOk;
end;

procedure TfmMapIcon.edMaskChange(Sender: TObject);
var
  str : String;
begin
  str := edMask.Text;
  str := StringReplace(str, '+', '?', [rfReplaceAll]);
  imgOk.Visible := MatchesMask(edTitle.Text, str);
  CheckOk;
end;

procedure TfmMapIcon.CheckOk;
begin
  btnOk.Enabled:= (imgOk.Visible ) and (cbxIcon.ItemIndex >= 0);
end;

end.

