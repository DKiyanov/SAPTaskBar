unit UOptions;

{$MODE Delphi}

interface

uses
  SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ComCtrls,
  Grids, StdCtrls, Buttons, ExtCtrls, Spin, Menus, Registry, Windows,
  USAPTaskBar, GR32, uPass;

type

  { TfmOptions }

  TfmOptions = class(TForm)
    btnDropDown: TBitBtn;
    btnSapLogon: TSpeedButton;
    btnPasswords: TButton;
    cbBigPreview: TCheckBox;
    cbCotrolLanguage: TCheckBox;
    cbHideIfNoSap: TCheckBox;
    cbHideSapGuiTaskBtn: TCheckBox;
    cbHideSapLogonTaskBtn: TCheckBox;
    cbHideTaskBtn: TCheckBox;
    cbHideTransparentBorders: TCheckBox;
    cbShowBtnMarker: TCheckBox;
    cbDrawSapSys: TCheckBox;
    cbShowStepHistory: TCheckBox;
    cbStartWithWin: TCheckBox;
    cbMaximizeNewWin: TCheckBox;
    cbIgnoreAero: TCheckBox;
    cbScrollLimitInCentre: TCheckBox;
    cbShowScrollButton: TCheckBox;
    cbShowTBinWTBwhenSTBHide: TCheckBox;
    cobPrintWindowMode: TComboBox;
    cobHideTaskButtonMode: TComboBox;
    cobSHThreadPriority: TComboBox;
    edLanguage: TEdit;
    edLogin: TEdit;
    edSapLogon: TEdit;
    imgSapTaskButton: TImage;
    imgSapGuiCastomizing: TImage;
    lblScreenCaptureInterval: TLabel;
    lblShowTBinWTBwhenSTBHide: TLabel;
    lblSHThreadPriority: TLabel;
    lbPlug_AlphaBlend: TLabel;
    lbIcon: TLabel;
    lbLanguage: TLabel;
    lbLogin: TLabel;
    lblHideTaskButtonMode: TLabel;
    lblPrintWindowMode: TLabel;
    lbSapLogon: TLabel;
    meLicense: TMemo;
    meAbout: TMemo;
    meAboutSite: TMemo;
    meLicensors: TMemo;
    miClearPassword: TMenuItem;
    miInputPassword: TMenuItem;
    miRemoveIcon: TMenuItem;
    miAddFromFile: TMenuItem;
    PageControl: TPageControl;
    ppmPass: TPopupMenu;
    ppmIcons: TPopupMenu;
    ScrollBox: TScrollBox;
    seStatusBarWordNum: TSpinEdit;
    seStepHistoryLength: TSpinEdit;
    btnAboutIcon: TSpeedButton;
    seScreenCaptureInterval: TSpinEdit;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    btnInputMasterPass: TToolButton;
    trbPlug_AlphaBlend: TTrackBar;
    tsOptions1: TTabSheet;
    tsLicense: TTabSheet;
    tsExtOptions: TTabSheet;
    tsAbout: TTabSheet;
    tsSapGUICustomizing: TTabSheet;
    tsSapSys: TTabSheet;
    sgSapSys: TStringGrid;
    ToolBar_SapSys: TToolBar;
    tsOptions: TTabSheet;
    plStatus: TPanel;
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
    btnMoveUp: TToolButton;
    btnMoveDown: TToolButton;
    ColorDialog: TColorDialog;
    ImageList: TImageList;
    btnDelete: TToolButton;
    rgAlign: TRadioGroup;
    rgPanelMode: TRadioGroup;
    gbPanelOptions: TGroupBox;
    OpenDialog: TOpenDialog;
    cbDrawSapTitle: TCheckBox;
    gbTaskButton: TGroupBox;
    procedure btnAboutIconClick(Sender: TObject);
    procedure btnDropDownClick(Sender: TObject);
    procedure btnInputMasterPassClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnPasswordsClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure meLicensorsDblClick(Sender: TObject);
    procedure miAddFromFileClick(Sender: TObject);
    procedure miClearPasswordClick(Sender: TObject);
    procedure miInputPasswordClick(Sender: TObject);
    procedure miRemoveIconClick(Sender: TObject);
    procedure sgSapSysMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure sgSapSysSelectCell(Sender: TObject; ACol, {%H-}ARow: Integer; var {%H-}CanSelect: Boolean);
    procedure sgSapSysDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; {%H-}State: TGridDrawState);
    procedure sgSapSysDblClick(Sender: TObject);
    procedure btnMoveUpClick(Sender: TObject);
    procedure btnMoveDownClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnSapLogonClick(Sender: TObject);
    procedure rgPanelModeClick(Sender: TObject);
    procedure tsAboutShow(Sender: TObject);
    procedure miIconSelectClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    StartWithWin : Boolean;
    btnDropDown_Row : Integer;
    btnDropDown_Col : Integer;

    procedure InitIconsPopup;
  end;

var
  fmOptions: TfmOptions;

const
  fdSysnm    = 0;
  fdColor    = 1;
  fdIcon     = 2;
  fdConnm    = 3; // Saplogon connection name
  fdDesc     = 4;
  fdLogin    = 5;
  fdLang     = 6;
  fdPass     = 7;
  fdCount    = 8;

  fdwSysnm    = 100;
  fdwColor    = 63;
  fdwIcon     = 20;
  fdwConnm    = 145;
  fdwDesc     = 173;
  fdwLogin    = 116;
  fdwLang     = 32;
  fdwPass     = 20;
  fdwCount    = 32;

  oppmLikeTaskBar    = 0;
  oppmAutoHide       = 1;
  oppmAlignToTaskBar = 2;

  opsaLeft   = 0;
  opsaRight  = 1;
  opsaTop    = 2;
  opsaBottom = 3;
  
implementation

{$R *.lfm}

procedure TfmOptions.FormCreate(Sender: TObject);
begin
  sgSapSys.Cells[fdSysnm, 0] := rsfdSysnm;
  sgSapSys.Cells[fdLogin, 0] := rsfdLogin;
  sgSapSys.Cells[fdLang,  0] := rsfdLang;
  sgSapSys.Cells[fdColor, 0] := rsfdColor;
  sgSapSys.Cells[fdDesc,  0] := rsfdDesc;
  sgSapSys.Cells[fdConnm, 0] := rsfdConnm;
  sgSapSys.Cells[fdCount, 0] := rsfdCount;
  sgSapSys.Cells[fdPass,  0] := rsfdPass;
  sgSapSys.Cells[fdIcon,  0] := rsfdIcon;

  sgSapSys.ColWidths[fdSysnm] := fdwSysnm;
  sgSapSys.ColWidths[fdLogin] := fdwLogin;
  sgSapSys.ColWidths[fdLang]  := fdwLang;
  sgSapSys.ColWidths[fdColor] := fdwColor;
  sgSapSys.ColWidths[fdDesc]  := fdwDesc;
  sgSapSys.ColWidths[fdConnm] := fdwConnm;
  sgSapSys.ColWidths[fdCount] := fdwCount;
  sgSapSys.ColWidths[fdPass]  := fdwPass;
  sgSapSys.ColWidths[fdIcon]  := fdwIcon;
end;

procedure TfmOptions.meLicensorsDblClick(Sender: TObject);
begin
  ShellExecute(0, 'open', 'AboutComponentsLicens.txt', nil, '', SW_SHOW);
end;

procedure TfmOptions.FormActivate(Sender: TObject);
var
  reg : TRegistry;
begin
  reg := TRegistry.Create(KEY_READ);
  reg.RootKey:= HKEY_CURRENT_USER;
  if reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', false) then begin
    StartWithWin := SameText(reg.ReadString(Application.Title), Application.ExeName);
    cbStartWithWin.Checked:= StartWithWin;
    reg.CloseKey;
  end;
  reg.Free;
end;

procedure TfmOptions.btnOkClick(Sender: TObject);
var
  reg : TRegistry;
begin
  if cbStartWithWin.Checked = StartWithWin then Exit;
  reg := TRegistry.Create(KEY_READ or KEY_WRITE);
  reg.RootKey:= HKEY_CURRENT_USER;

  if reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True) then begin

    if cbStartWithWin.Checked
    then reg.WriteString( Application.Title, Application.ExeName)
    else Reg.DeleteValue(Application.Title);

    reg.CloseKey;
  end;

  reg.Free;
end;

procedure TfmOptions.btnPasswordsClick(Sender: TObject);
var
  i : Integer;
  j : Integer;
  sys_name : String;
  sys : PSapSys;
begin
  fSAPTaskBar.LoadPass;
  if not fSAPTaskBar.PassLoaded then Exit;

  for i := 1 to sgSapSys.RowCount - 1 do begin
     sys_name := sgSapSys.Cells[fdSysnm, i];

     for j := 0 to fSAPTaskBar.SysList.Count - 1 do begin
       sys := PSapSys(fSAPTaskBar.SysList[j]);
       if sys.Name = sys_name then begin
         if sys.Password <> '' then begin
           sgSapSys.Cells[fdPass, i] := IntToStr(sys.PassIndex) +#9+ sys.Password;
         end;

         Break;
       end;
     end;
  end;

  fmOptions.btnInputMasterPass.Visible := True;
  fmOptions.btnPasswords.Visible       := False;
  fmOptions.sgSapSys.ColWidths[fdPass] := fdwPass;
end;

procedure TfmOptions.btnAboutIconClick(Sender: TObject);
begin
  OpenMySite;
end;

procedure TfmOptions.btnDropDownClick(Sender: TObject);
var
  ARow : Integer;
  ACol : Integer;
  R  : TRect;
  pt : TPoint;
begin
  InitIconsPopup;
  ARow := btnDropDown_Row;
  ACol := btnDropDown_Col;
  sgSapSys.CellRect(ACol, ARow);
  R  := sgSapSys.CellRect(ACol, ARow);
  pt := Point(R.Left, R.Bottom);
  pt := sgSapSys.ClientToScreen(pt);

  case ACol of
  fdIcon : begin
      ppmIcons.Tag:= ARow;
      ppmIcons.PopUp(pt.x, pt.y);
    end;
  fdPass : begin
      ppmPass.Tag:= ARow;
      ppmPass.PopUp(pt.x, pt.y);
    end;
  end;
end;

procedure TfmOptions.btnInputMasterPassClick(Sender: TObject);
begin
  fmPassword.lbPassTitle.Caption:= 'Input master password';
  fmPassword.edPassword.Text := '';
  if fmPassword.ShowModal <> mrOk then Exit;
  fSAPTaskBar.MasterPass := fmPassword.edPassword.Text;
  fSAPTaskBar.PassListChanged:= True;
end;

procedure TfmOptions.sgSapSysSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  case ACol of
    fdSysnm,
    fdConnm,
    fdColor,
    fdPass,
    fdIcon: sgSapSys.Options := sgSapSys.Options - [goEditing];
  else
    sgSapSys.Options := sgSapSys.Options + [goEditing];
  end;
end;

procedure TfmOptions.sgSapSysDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  cl : TColor;
  s  : String;
  ii  : Integer;
begin
  if (ACol=fdColor) and (ARow > 0) then begin
    s := sgSapSys.Cells[ACol,ARow];
    if s = '' then Exit;

    cl := TColor(StrToInt(s));
    if cl = TColor(0) then Exit;

    sgSapSys.Canvas.Brush.Color:= cl;
    sgSapSys.Canvas.FillRect(Rect);
    sgSapSys.Canvas.TextOut(Rect.Left + 2,Rect.Top + 2,sgSapSys.Cells[ACol,ARow]);
  end;

  if (ACol=fdPass) and (ARow > 0) then begin
    s := sgSapSys.Cells[ACol,ARow];

    sgSapSys.Canvas.Brush.Color:= sgSapSys.Color;
    sgSapSys.Canvas.FillRect(Rect);

    ImageList.Draw(sgSapSys.Canvas, Rect.Left + 2, Rect.Top + 2, 3, s <> '');
  end;

  if (ACol=fdIcon) and (ARow > 0) then begin
    s := sgSapSys.Cells[ACol,ARow];

    sgSapSys.Canvas.Brush.Color:= sgSapSys.Color;
    sgSapSys.Canvas.FillRect(Rect);

    s := sgSapSys.Cells[ACol,ARow];
    ii := fSAPTaskBar.GetIconIndex(s);
    if ii >= 0 then begin
      fSAPTaskBar.IconList.Draw(sgSapSys.Canvas, Rect.Left + 2, Rect.Top + 2, ii, True);
    end;
  end;
end;

procedure TfmOptions.sgSapSysDblClick(Sender: TObject);
var
  ACol : Integer;
  ARow : Integer;
  cl : TColor;
  s : String;
  PassIndex : String;
begin
  ACol := sgSapSys.Col;
  ARow := sgSapSys.Row;

  if (ACol = fdColor) and (ARow > 0) then begin
    cl := TColor(StrToInt(sgSapSys.Cells[ACol,ARow]));
    if cl = TColor(0) then cl := clWhite;

    ColorDialog.Color := cl;
    if ColorDialog.Execute then sgSapSys.Cells[ACol,ARow] := '$' + IntToHex(Integer(ColorDialog.Color), 8);
  end;

  if (ACol = fdPass) and (ARow > 0) then begin
    fmPassword.lbPassTitle.Caption:= sgSapSys.Cells[fdDesc,ARow];
    fmPassword.edPassword.Text := '';
    if fmPassword.ShowModal <> mrOk then Exit;

    if fmPassword.edPassword.Text = '' then begin
      sgSapSys.Cells[fdPass,ARow] := '';
      Exit;
    end;

    s := sgSapSys.Cells[fdPass,ARow];
    if s <> '' then begin
      PassIndex := ExtractWord(s, 1, #9);
    end;

    if PassIndex = '' then begin // Получение нового индекса
      Inc(fSAPTaskBar.MaxPassIndex);
      PassIndex := IntToStr(fSAPTaskBar.MaxPassIndex);
    end;

    sgSapSys.Cells[fdPass,ARow] := PassIndex +#9+ fmPassword.edPassword.Text;
    fSAPTaskBar.PassListChanged:= True;
  end;
end;

procedure TfmOptions.sgSapSysMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  ACol : Integer;
  ARow : Integer;
  R : TRect;
  pt : TPoint;
begin
  btnDropDown.Visible:= False;
  sgSapSys.MouseToCell(X, Y, ACol, ARow);
  R := sgSapSys.CellRect(ACol, ARow);

  if ARow < 1 then Exit;
  if not ((ACol = fdIcon) or (ACol = fdPass)) then Exit;

  pt := Point(R.Right, R.Top);
  pt := sgSapSys.ClientToScreen(pt);
  pt := tsSapSys.ScreenToClient(pt);

  btnDropDown.Left:= pt.x;
  btnDropDown.Top := pt.y;
  btnDropDown.Height:= R.Bottom - R.Top;
  btnDropDown.Visible:=True;
  btnDropDown_Row := ARow;
  btnDropDown_Col := ACol;
end;

procedure TfmOptions.btnMoveUpClick(Sender: TObject);
var
  ARow : Integer;
  s : string;
begin
  ARow := sgSapSys.Row;
  if ARow <= 1 then Exit;

  s := sgSapSys.Rows[ARow - 1].Text;
  sgSapSys.Rows[ARow - 1].Text := sgSapSys.Rows[ARow].Text;
  sgSapSys.Rows[ARow].Text := s;

  sgSapSys.Row := ARow - 1;
end;

procedure TfmOptions.btnMoveDownClick(Sender: TObject);
var
  ARow : Integer;
  s : string;
begin
  ARow := sgSapSys.Row;
  if ARow >= sgSapSys.RowCount - 1 then Exit;

  s := sgSapSys.Rows[ARow + 1].Text;
  sgSapSys.Rows[ARow + 1].Text := sgSapSys.Rows[ARow].Text;
  sgSapSys.Rows[ARow].Text := s;

  sgSapSys.Row := ARow + 1;
end;

procedure DeleteRow(StringGrid: TStringGrid; ARow: integer);
var
  i, j: integer;
begin
  with StringGrid do
  begin
    for i := ARow to RowCount - 2 do
      for j := 0 to ColCount - 1 do
        Cells[j, i] := Cells[j, i + 1];
    RowCount := RowCount - 1;
  end;
end;

procedure TfmOptions.btnDeleteClick(Sender: TObject);
var
  ARow : Integer;
  sct : String;
begin
  ARow := sgSapSys.Row;
  sct := sgSapSys.Cells[fdCount, ARow];
  if sct <> '0' then begin
    MessageDlg(rsMsg012, mtWarning, [mbOk], 0);
    Exit;
  end;

  if (ARow = 1) and (sgSapSys.RowCount = 2)
  then sgSapSys.Rows[ARow].Clear
  else DeleteRow(sgSapSys, ARow);
end;

procedure TfmOptions.btnSapLogonClick(Sender: TObject);
begin
  if OpenDialog.Execute then edSapLogon.Text := OpenDialog.FileName;
end;

procedure TfmOptions.rgPanelModeClick(Sender: TObject);
var
  AlignToTaskBar : Boolean;
begin
  AlignToTaskBar := rgPanelMode.ItemIndex = oppmAlignToTaskBar;
  if AlignToTaskBar then begin
    rgAlign.ItemIndex := - 1;
    cbHideTaskBtn.Checked := False;
  end;

  rgAlign.Enabled := not AlignToTaskBar;
  cbHideTaskBtn.Enabled := not AlignToTaskBar;
end;

procedure TfmOptions.tsAboutShow(Sender: TObject);
begin
  meAboutSite.Lines.Text:= MySite;
end;

procedure TfmOptions.InitIconsPopup;
var
  i : Integer;
  j : Integer;
  mi : TMenuItem;
  Found : Boolean;
  nmi : TMenuItem;
begin
  for i := 0 to fSAPTaskBar.miIcons.Count -1 do begin
    mi := fSAPTaskBar.miIcons.Items[i];
    if mi.ImageIndex < 0 then Continue;

    Found := False;
    for  j := 0 to ppmIcons.Items.Count - 1 do begin
      if ppmIcons.Items.Items[j].ImageIndex = mi.ImageIndex then begin
        Found := True;
        Break;
      end;
    end;

    if Found then Continue;

    nmi := TMenuItem.Create(Self);
    nmi.Caption    := mi.Caption;
    nmi.ImageIndex := mi.ImageIndex;
    nmi.OnClick    := miIconSelectClick;
    ppmIcons.Items.Add(nmi);
  end;
end;

procedure TfmOptions.miIconSelectClick(Sender: TObject);
var
  mi : TMenuItem;
begin
  mi := TMenuItem(Sender);
  sgSapSys.Cells[fdIcon, ppmIcons.Tag] := mi.Caption;
end;

procedure TfmOptions.miAddFromFileClick(Sender: TObject);
var
  mi : TMenuItem;
begin
  mi := fSAPTaskBar.LoadIconFromFile;
  if mi = nil then Exit;

  InitIconsPopUp;
  miIconSelectClick(mi);
end;

procedure TfmOptions.miClearPasswordClick(Sender: TObject);
begin
  sgSapSys.Cells[fdPass,btnDropDown_Row] := '';
end;

procedure TfmOptions.miInputPasswordClick(Sender: TObject);
begin
  sgSapSys.Col := fdPass;
  sgSapSys.Row := btnDropDown_Row;
  sgSapSysDblClick(sgSapSys);
end;

procedure TfmOptions.miRemoveIconClick(Sender: TObject);
begin
  sgSapSys.Cells[fdIcon, ppmIcons.Tag] := '';
end;

end.
