unit USAPTaskBar;

{$MODE Delphi}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ExtCtrls, ShellAPI, ComCtrls, GR32, Menus,
  FileUtil, IniFiles, Registry, InterfaceBase, StdCtrls, win32int, Win32proc,
  UHookMsg, ComObj, ShlObj, types, masks, blowfish, base64,
  uPass, md5, Clipbrd, LConvEncoding;

type
  PSLItem = ^TSLItem;
  TSLItem = record
    connm: string[100];
    sysid: string[3];
  end;

  PSapSys = ^TSapSys;
  TSapSys = record
    Name  : string[7]; // sysid '/' mandt
    Color : TColor;
    Login : string[12];
    Lang  : string[2];
    desc  : string[100];
    connm : string[100]; // Saplogon connection name
    sysid : string[3];
    mandt : string[3];
    Passindex: Integer;
    Password : string[30]; // password
    Count : Integer;
    mi    : TMenuItem; // Освобождать его будет форма (Owner)
    IconName: string[50];
    IconIndex: Integer;
  end;

  PBtnData = ^TBtnData;
  TBtnData = record
    IconRect  : TRect;
    MarcRect  : TRect;
    HistRect  : TRect;
    ImageList : TImageList;
    IconList  : TImageList;
    ShowMark  : Boolean;
    HistLength: Integer;
    HistShow  : Boolean;
    SysIconRect : TRect;
  end;

  { TTaskBtn }

  TTaskBtn = class(TGraphicControl)
  protected
    FOnMarkChange: TNotifyEvent;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure SetDown(ADown: Boolean);
  private
    procedure CMButtonPressed(var Message: TMessage); message CM_BUTTONPRESSED;
  public
    Glyph   : TBitmap32;
    FDown   : Boolean;
    PreviewBmp  : TBitmap32;
    PreviewWidth: Integer;
    PreviewHeight: Integer;

    hw      : hwnd;
    intMark : Integer; // Пометка объекта для какой либо обработки
    sysid   : string;  // Имя системы SAP
    mandt   : string;  // Mandant
    modno   : Integer; // Номер режима
    title   : string;
    sys     : PSapSys; // Ссылка на обект сап системы

    jdbmn   : Integer; // Окно режима отладки - номер отлаживаемого режима

    hw_stbar: HWND; // StatusBar window
    stbmp   : TBitmap32; // StatusBar bitmap
    sttxt   : String;   // Текст полученый из статуса
    stok    : Boolean; // StatusBar - прочитан успешно
    ftime   : TDateTime; // Время обнаружения окна

    Mark    : Boolean; // Метка на кнопке
    MarkNum : Integer;

    Restore : Integer;
    RestoreRect : TRect; // При востановлении позиции окна после групповых операций
    GrpIndex : Integer;  // С помощью одинкаового индекса объеденяются окна участвующие в одной груповой операции
    GrpRect  : TRect;

    BtnData : PBtnData;

    MarkImageIndex : Integer;
    IconImageIndex : Integer;
    IconMask       : String;

    StepNum : Integer;

    ExPrint : Boolean; // Параметр для получения скриншота

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetVisible(Value: Boolean); override;
    property OnMarkChange: TNotifyEvent read FOnMarkChange write FOnMarkChange;
    property Down : Boolean read FDown write SetDown;
  end;

  { TSAPTaskBar }

  TDirect = (dtHorizontal, dtVertical);

  TSAPTaskBar = class(TForm)
    btnHide: TBitBtn;
    btnScrollBottom: TSpeedButton;
    btnScrollLeft: TSpeedButton;
    btnScrollRight: TSpeedButton;
    ImageList: TImageList;
    IconList: TImageList;
    miTrayIcon_Hide: TMenuItem;
    miTrayIcon_Show: TMenuItem;
    miTrayIcon_Splitter: TMenuItem;
    miTrayIcon_Exit: TMenuItem;
    miGatherGroup: TMenuItem;
    miAutoHide: TMenuItem;
    miRemoveIcon: TMenuItem;
    miRestart: TMenuItem;
    miShowStepHistory: TMenuItem;
    miSapSystemsList: TMenuItem;
    miShowBtnMarker: TMenuItem;
    miThreeWin2: TMenuItem;
    miThreeWin3: TMenuItem;
    miFourWin: TMenuItem;
    miThreeWin4: TMenuItem;
    miThreeWin1: TMenuItem;
    micxNotMarked: TMenuItem;
    miSpliter2: TMenuItem;
    micxYellow: TMenuItem;
    micxAqua: TMenuItem;
    micxBlue: TMenuItem;
    micxRed: TMenuItem;
    micxGreen: TMenuItem;
    miAqua: TMenuItem;
    miYellow: TMenuItem;
    miRed: TMenuItem;
    miAddIconFromFile: TMenuItem;
    miMapIcon: TMenuItem;
    miIcons: TMenuItem;
    miBlue: TMenuItem;
    miGreen: TMenuItem;
    miLockChangeSize: TMenuItem;
    miMaximize: TMenuItem;
    miCloseSapGuiWindow: TMenuItem;
    miFilter: TMenuItem;
    miSelFilter: TMenuItem;
    miSpliter1: TMenuItem;
    miSapLogon: TMenuItem;
    miRestore: TMenuItem;
    miLikeRows: TMenuItem;
    miLikeColumn: TMenuItem;
    IconOpenDialog: TOpenDialog;
    plTasks: TPanel;
    ppmTrayIcon: TPopupMenu;
    ppmMarkIcons: TPopupMenu;
    ppmOption: TPopupMenu;
    ppmButton: TPopupMenu;
    ppmGroupAction: TPopupMenu;
    btnScrollTop: TSpeedButton;
    ToolBar: TToolBar;
    btnOptions: TToolButton;
    plArea: TPanel;
    Timer: TTimer;
    ppmTaskBar: TPopupMenu;
    miHide: TMenuItem;
    miExit: TMenuItem;
    miOptions: TMenuItem;
    plLabel: TPanel;
    miShow: TMenuItem;
    btnSapSys: TToolButton;
    miSort: TMenuItem;
    ppmSapSys: TPopupMenu;
    miSpliter: TMenuItem;
    ApplicationEvents: TApplicationProperties;
    btnGroupAction: TToolButton;
    btnShowHiden: TToolButton;
    TrayIcon: TTrayIcon;

    procedure btnGroupActionClick(Sender: TObject);
    procedure btnHideKeyDown(Sender: TObject; var Key: Word; {%H-}Shift: TShiftState);
    procedure btnOptionsMouseDown(Sender: TObject; {%H-}Button: TMouseButton; Shift: TShiftState; {%H-}X, {%H-}Y: Integer);
    procedure btnScrollBottomClick(Sender: TObject);
    procedure btnScrollLeftClick(Sender: TObject);
    procedure btnScrollRightClick(Sender: TObject);
    procedure btnScrollTopClick(Sender: TObject);
    procedure btnShowHidenClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure BtnMouseDown(Sender: TObject; {%H-}Button: TMouseButton; {%H-}Shift: TShiftState; X, Y: Integer);
    procedure BtnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure BtnMouseUp(Sender: TObject; {%H-}Button: TMouseButton; {%H-}Shift: TShiftState; {%H-}X, {%H-}Y: Integer);
    procedure BtnClick(Sender: TObject);
    procedure BtnMouseLeave(Sender: TObject);
    procedure BtnMarkChange(Sender: TObject);
    procedure BtnPopUp(Sender: TObject; {%H-}MousePos: TPoint; var {%H-}Handled: Boolean);
    procedure BtnShowHint(Sender: TObject; HintInfo: PHintInfo);
    procedure FormHide(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure miAutoHideClick(Sender: TObject);
    procedure miAddIconFromFileClick(Sender: TObject);
    procedure miCloseSapGuiWindowClick(Sender: TObject);
    procedure micxNotMarkedClick(Sender: TObject);
    procedure miGatherGroupClick(Sender: TObject);
    procedure miMarkGroupClick(Sender: TObject);
    procedure miFilterClick(Sender: TObject);
    procedure miMapIconClick(Sender: TObject);
    procedure miMarkIconClick(Sender: TObject);
    procedure miLockChangeSizeClick(Sender: TObject);
    procedure miRemoveIconClick(Sender: TObject);
    procedure miRestartClick(Sender: TObject);
    procedure miSapSystemsListClick(Sender: TObject);
    procedure miSelFilterClick(Sender: TObject);
    procedure miMaximizeClick(Sender: TObject);
    procedure miRestoreClick(Sender: TObject);
    procedure miSapLogonClick(Sender: TObject);
    procedure miShowBtnMarkerClick(Sender: TObject);
    procedure miShowStepHistoryClick(Sender: TObject);
    procedure miWinPosClick(Sender: TObject);
    procedure plTasksResize(Sender: TObject);
    procedure ppmOptionPopup(Sender: TObject);
    procedure ppmTrayIconPopup(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure plAreaResize(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure miOptionsClick(Sender: TObject);
    procedure BtnHideClick(Sender: TObject);
    procedure miShowClick(Sender: TObject);
    procedure miSortClick(Sender: TObject);
    procedure miSapSysClick(Sender: TObject);
    procedure miIconSelectClick(Sender: TObject);
    procedure btnSapSysClick(Sender: TObject);
    procedure ApplicationEventsRestore(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure TrayIconClick(Sender: TObject);
    procedure btnGroupActionMouseDown(Sender: TObject; {%H-}Button: TMouseButton; Shift: TShiftState; {%H-}X, {%H-}Y: Integer);
    procedure TrayIconDblClick(Sender: TObject);
  private
    function CalcSystemColor(bmp: TBitmap32): TColor;
    { Private declarations }
    procedure WM_MyMouseWheel(var M: TMessage); message wm_My_MouseWheel;
    procedure WM_MyMouseMove(var {%H-}M: TMessage); message wm_My_MouseMove;
    procedure WM_MyKey(var M: TMessage); message wm_My_Key;
    procedure WM_MyExitSizeMove(var M: TMessage); message wm_My_ExitSizeMove;

    procedure WMShowWindow(var Msg: TWMShowWindow); message WM_SHOWWINDOW; // Lock minimizeing window
    procedure WMWindowPosChanging(var Message: TWMWindowPosChanging); message WM_WINDOWPOSCHANGING; // Low limit size window
    procedure WM_NCHITest(var Message: TMessage); message WM_NCHITTEST; // Lock can resize window
  public
    { Public declarations }
    MDPoint : TPoint;
    TBList : TList;
    Direct : TDirect;
    ThumbWidth: Integer;
    ThumbHeight : Integer;

    SideBarOn  : Boolean;
    BtnMoving  : Boolean;

    sbmp : TBitmap32;
    dbmp : TBitmap32;
    ImageRect : TRect;

    sbmp_w : Integer; // width current scrren shot
    sbmp_h : Integer; // width current scrren shot

    tiks : Integer;
    hwCur : HWND; // Текущее верхнее окно SAP

    MyTaskBar  : TAppBarData;
    SAlign : TAlign;

    sizing : Integer;

    SelfDir : String;

    SLList  : TStringList; // from SapLogoin.ini info

    SysList : TList;
    SysListChanged : Boolean;

    MasterPass      : String;
    MaxPassIndex    : Integer;
    PassListChanged : Boolean;
    PassLoaded      : Boolean;

    LogonBtn : Boolean; // Есть кнопка к окну входа в SAP, после входа её надо удалить
    InvalidSysName : Boolean; // Есть кнопку для которой не удалось определить систему

    DefLogin : String;
    Language : String;
    SapGuiPath   : String;
    SapLogonPath : String;

    SelectAlign : Integer;
    PanelMode   : Integer;

    StartWithWin : Boolean;
    HideIfNoSap  : Boolean;
    HideTaskBtn  : Boolean;
    HideSapGuiTaskBtn : Boolean;
    ShowTBinWTBwhenSTBHide : Boolean;
    HideSapLogonTaskBtn : Boolean;

    BigPreview : Boolean;
    PreviewWidth: Integer;
    PreviewHeight : Integer;

    StepHistoryLength : Integer;
    ShowStepHistory : Boolean;

    LockChangeSize : Boolean;
    CotrolLanguage : Boolean; // Set the input language EN when the user enters the transaction code in the upper left window of SAP GUI
    MaximizeNewWin : Boolean;
    ScrollLimitInCentre : Boolean;
    ShowScrollButton : Boolean;

    HideTransparentBorders : Boolean;

    Plug_Visible : Boolean;
    Plug_AlphaBlend : Integer;

    RusEx : Integer; // Наличие русского языка - 0 не определено, 1 есть, 2 нет

    NoEditSapLogonPath : Boolean;
    
    ShowBtnMarker : Boolean;
    DrawSapTitle : Boolean;
    DrawSapSys : Boolean;

    HideTiker : Integer;

    AppHandle : HWND;
    SapLogon_hw : HWND;

    WaitSap : Boolean; // Режим ожидания появления окна SAP

    BtnData : TBtnData;

    Taskbar: ITaskbarList;

    PrintWindowMode    : Integer; // 0 - PW + Redraw, 1 - PW, 2 - PW + Option, 3 - Copy from screen
    SHThreadPriority   : Integer; // 0 - Normal, 1 - Lower, 2 - Lowest, 3 - Idle
    ScreenCaptureInterval : Integer;

    HideTaskButtonMode : Integer; // 0 - TaskbarList, 1 - Set window ExStyle
    StatusBarWordNum   : Integer;

    IconMapList : TStringList;

    KeyDown_Win : Boolean;
    KeyDown_Ctrl: Boolean;
    KeyDown_Alt : Boolean;

    cbmp : TBitmap32;

    LastRunWndList : TStringList;

    GetGlyphIndex : Integer;
    GetGlyphTiks : Integer;

    PrevBtn     : TTaskBtn;
    PrevBtnTiks : Integer;

    NotSave : Boolean; // Не сохранять настройки перед выходом

    ProductName : String;
    ProductVersion : String;
    FileVersion : String;

    CheckTiks : Integer;

    SWAR : TRect; // Screen work area rect, for check changeing it

    AeroEnabled : Boolean;
    IgnoreAero : Boolean;

    procedure SetFormAlign(fAlign: TAlign);
    function  GetTaskBarAlign:TAlign;
    procedure RefreshButtons;
    procedure RefreshBtnPos;
    procedure SortButtons;
    procedure SideBarSet(fAlign: TAlign);
    procedure SideBarPosChanged;
    procedure SideBarRemove;

    procedure GetBtnGlyph(btn : TTaskBtn; ex : Boolean);
    procedure GetBtnGlyphEx(btn : TTaskBtn; ex : Boolean);
    procedure PrintWindowMy(hw : HWND; w, h: Integer; ex : Boolean);
    function  GetWindowScreenShot(hw : HWND; ex : Boolean):Boolean;
    procedure SplitSAPWindowText(btn : TTaskBtn);
    procedure BtnMove(btn : TTaskBtn);
    procedure LoadSys;
    procedure LoadPass;
    procedure SaveSys;
    procedure SavePass;
    procedure LoadOptions;
    procedure SaveOptions;
    function  EditOptions(ActPage: TTabSheet): Boolean;
    procedure ApplyOptions;
    procedure ReadSapLogon;
    procedure SetTaskBtnSys(tb: TTaskBtn);
    procedure OpenNewSapSys(sys : PSapSys);
    procedure RefreshSysCount;
    procedure SetSysColor(sys : PSapSys; AColor : TColor);
    procedure AutoHide;
    procedure SetSapWinToPos(Mode : Integer);
    procedure RefreshScreenShots;
    procedure BtnUnDown;
    procedure HideTaskButton(hw : HWND);
    procedure ShowTaskButton(hw : HWND);
    function  GetSapLogonWnd:HWND;
    procedure CheckWindowPos(hw : HWND);
    procedure LoadIcons;
    procedure LoadIconsMap;
    procedure MapIcon(btn : TTaskBtn);
    procedure MapIconEx(tb : TTaskBtn);
    function  LoadIconFromFile: TMenuItem;
    function  GetIconIndex(const IconName: String): Integer;
    procedure ApplyFilers;
    procedure MakeBigScreenShot(btn : TTaskBtn);
    procedure PreviewShow(btn : TTaskBtn);
    procedure PreviewEnd;
    procedure SetPlug;
    procedure ShowSapGUI(btn : TTaskBtn);
    procedure SaveLastRunWndList;
    procedure SetLastRunWndList;
    procedure Terminate;
    procedure ReadSelfVersion;
    function  isABAPDebugWin(const sysid, str : String): Integer;
    procedure SetTransparent(ATransparent : Boolean);
    procedure GuiTuning;
    procedure DeleteButton(btn : TTaskBtn);
  end;

  { TBtnGlyphThread }

  TBtnGlyphThread = class(TThread)
  protected
    procedure Execute; override;
  public
    ScreenCaptureInterval : Integer;
  end;

var
  fSAPTaskBar: TSAPTaskBar;
  PrevWndProc: WNDPROC;

  BtnGroupIndex : Integer = 0;

  CurStepNum : Integer = 0;

  MySite : String;

  CTBList : TList; // Очередь кнопок для получения скриншота
  RTBList : TList; // Список кнопок для которых получен скриншот
  CMutex  : THandle;
  BMutex  : THandle;
  CThread : TBtnGlyphThread;

const
  SapWindowClass = 'SAP_FRONTEND_SESSION';
  SelfWindowName = 'SAPTaskBar';

  LowLimitThumbSize : Integer = 40; // Минимальный размер кнопки
  BThumbSize  : Integer = 2; // Расстояние между кнопками
  BSysSize    : Integer = 10; // Расстояние между системами

  AutoShowWidth : Integer = 4; // Расстояние от бортика на котором срабатывает всплыване

  invalid_sys_name : String = '#######';
  ZeroMandt = '000';

  scIconMap    = 'IconMap.ini';
  scLastRunWnd = 'LastRunWnd.dat';
  scSapSys     = 'SapSys.ini';
  scPassDat    = 'Passwords.dat';
  scOptionsIni = 'Options.ini';
  scIconsDir   = 'icons';
  scLicenseSubStr_en = 'Kiyanov';
  scLicenseSubStr_ru = 'Киянов';

//  DebugPrepare: Boolean = True;
  DebugPrepare: Boolean = False;

procedure SetHook; external 'PHook.dll' name 'SetHook';
procedure SetHookNLng; external 'PHook.dll' name 'SetHookNLng';
procedure UnHook;  external 'PHook.dll' name 'UnHook';

function PrintWindow(HWND:HWND; hdcBlt:HDC; nFlags:DWORD):BOOL; stdcall; external 'user32.dll';

function WaitTerminationPrevRan: Boolean;
function GetWndClassName(WND:HWND): String;
function WindowIsTop(hw : HWND): Boolean;

procedure MyShowWindow(hWnd:HWND; nCmdShow:longint);
procedure MySetWindowPos(hWnd:HWND; Rect : TRect);
procedure MySetForegroundWindow(hWnd:HWND);

function GetWinVer: Integer;
function ISAeroEnabled: Boolean;
function NoEnLngEx:Boolean;

procedure OpenMySite;

function ExtractWord(const S : String; WordNum : Integer; const Separator : String; const DefValue : String = ''): String;

function KeyIsDown(vKey:longint): Boolean;

procedure StrToFile(const FileName, SourceString : string);
function FileToStr(const FileName : string):string;

function Encrypt(const AKey, AValue, ACheckStr: string): string;
function Decrypt(const AKey, AValue, ACheckStr: string): string;

function Utf8ToAnsi(const Utf8Str: string): string;

resourcestring
  rsMsg001 = 'Do you want to exit from SAPTaskBar?';
  rsMsg002 = 'Some settings apply only after restarting the program.' +#13+ 'Restart the program?';
  rsMsg003 = 'No permission to change the configuration file';
  rsMsg007 = 'Icon size mast be 16x16';
  rsMsg008 = 'File with name %s already existing, Replace?';
  rsMsg010 = 'Select value from list';
  rsMsg011 = 'Please input default language';
  rsMsg012 = 'You can not delete, exists open modes';
  rsMsg013 = 'Not found license file';
  rsMsg016 = 'Configuring SAP GUI for grouping task buttons by SAP systems and clients has been executed. For correct program work, please, restart SAP GUI.';

  rsfdSysnm = 'SystemID\Mandant';
  rsfdLogin = 'Login';
  rsfdLang  = 'Language';
  rsfdColor = 'Color';
  rsfdDesc  = 'Description';
  rsfdConnm = 'Connection';
  rsfdCount = 'Count open screens';
  rsfdPass  = 'Password';
  rsfdIcon  = 'Icon';

implementation

uses UOptions, UConNameQuery, UMapIcon, UPreView, UPlug;

{$R *.lfm}

{ TBtnGlyphThread }

procedure TBtnGlyphThread.Execute;
var
  i: Integer;
  ctb : TTaskBtn;
  lCTBList : TList;
begin
  lCTBList := TList.Create;

  if Self.ScreenCaptureInterval < 300 then Self.ScreenCaptureInterval:= 300;

  while True do begin
    try
      // Перегружаем в локальный список, и освобождаем Mutex
      // так сделано, чтоб основной поток не тормозился ожидая пока будут сделаны скриншоты
      WaitForSingleObject(CMutex, INFINITE);
      try
        lCTBList.Assign(CTBList);
        CTBList.Clear;
      finally
        ReleaseMutex(CMutex);
      end;

      if lCTBList.Count > 0 then begin
        // Главное чтоб кнопку в основном потоке не удалили, для этого отдельный мутекс
        WaitForSingleObject(BMutex, INFINITE);
        try
          for i := 0 to lCTBList.Count - 1 do begin
            ctb := TTaskBtn(lCTBList[i]);
            if ctb = nil then Continue;

            // Так конечно не очень хорошо делать, но думаю тут проблем не будет
            fSapTaskBar.GetBtnGlyphEx(ctb, ctb.ExPrint);
          end;
        finally
          ReleaseMutex(BMutex);
        end;

        lCTBList.Clear;
      end;

      if Self.Terminated then Break;
      Sleep(Self.ScreenCaptureInterval);

    except
      on e: exception do begin
      end;
    end;
  end;

  lCTBList.Free;
end;

{ TTaskBtn }

constructor TTaskBtn.Create(AOwner: TComponent);
begin
  inherited;
  Self.controlstyle := Self.controlstyle + [csopaque];

  Glyph := TBitmap32.Create;

  stbmp := TBitmap32.Create;
  stbmp.DrawMode := dmBlend;

  Self.MarkImageIndex:= -1;
  Self.IconImageIndex:= -1;
end;

destructor TTaskBtn.Destroy;
begin
  Glyph.Free;
  stbmp.Free;
  if PreviewBmp <> nil then PreviewBmp.Free;
  inherited;
end;

procedure TTaskBtn.SetVisible(Value: Boolean);
begin
  inherited SetVisible(Value);
  if Self.hw = 0 then Exit;
  if Value
  then MyShowWindow(Self.hw, SW_SHOWNA)
  else MyShowWindow(Self.hw, SW_HIDE);
end;

procedure TTaskBtn.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;

  if (Shift = [ssLeft]) and (Self.BtnData <> nil) and (Self.BtnData.ShowMark) and PtInRect(Self.BtnData.MarcRect, Point(X, Y)) then begin
    Self.Mark:= not Self.Mark;
    Self.MarkNum:= 0;
    if Assigned(FOnMarkChange) then FOnMarkChange(Self);
    Self.Invalidate;
    Exit;
  end;

  if (Shift = [ssLeft]) and not Down then begin
    Down := True;
    Self.Invalidate;
  end;
end;

procedure TTaskBtn.SetDown(ADown: Boolean);
var
  Msg: TMessage;
begin
  FDown := ADown;
  if not FDown then Exit;
  if Parent = nil then Exit;

  Msg.Msg := CM_BUTTONPRESSED;
  Msg.WParam := -1;
  Msg.LParam := Longint(Self);
  Msg.Result := 0;
  Parent.Broadcast(Msg);
end;

procedure TTaskBtn.CMButtonPressed(var Message: TMessage);
var
  Sender : TTaskBtn;
begin
  Sender := TTaskBtn(Message.LParam);
  if Sender <> Self then begin
    Down := False;
    Invalidate;
  end;
end;

procedure TTaskBtn.Paint;
var
  w : Integer;
  h : Integer;
  gp : TPoint;
  s : String;
  sx : Integer;
  sy : Integer;
  d : Integer;
begin
  WaitForSingleObject(BMutex, INFINITE);
  try
    inherited;
    w := Self.Width - 1;
    h := Self.Height - 1;

    if Down then begin
      gp.X := 2;
      gp.Y := 2;
    end
    else begin
      gp.X := 1;
      gp.Y := 1;
    end;

    if (Glyph.Width > 0) and (Glyph.Height > 0) then begin
      Glyph.DrawTo(Self.Canvas.Handle, gp.X, gp.Y);
    end;

    if Down then begin
      Self.Canvas.Pen.Style:= psSolid;
      Self.Canvas.Pen.Color := clBlack;
      Self.Canvas.MoveTo(0, h);
      Self.Canvas.LineTo(0, 0);
      Self.Canvas.LineTo(w, 0);
      Self.Canvas.Pen.Color := clWhite;
      Self.Canvas.LineTo(w, h);
      Self.Canvas.LineTo(0, h);
      Self.Canvas.Pen.Color := clGray;
      Self.Canvas.MoveTo(1, h - 1);
      Self.Canvas.LineTo(1, 1);
      Self.Canvas.LineTo(w - 1, 1);

      Self.Canvas.Pen.Color := clRed;
      Self.Canvas.Pen.Style:= psDot;
      Self.Canvas.Frame(2, 2, w - 1, h - 1);
    end
    else begin
      Self.Canvas.Pen.Style:= psSolid;
      Self.Canvas.Pen.Color := clWhite;
      Self.Canvas.MoveTo(0, h);
      Self.Canvas.LineTo(0, 0);
      Self.Canvas.LineTo(w, 0);
      Self.Canvas.Pen.Color := clBlack;
      Self.Canvas.LineTo(w, h);
      Self.Canvas.LineTo(0, h);
      Self.Canvas.Pen.Color := clGray;
      Self.Canvas.MoveTo(w - 1, 1);
      Self.Canvas.LineTo(w - 1, h - 1);
      Self.Canvas.LineTo(1, h - 1);
    end;

    if Self.BtnData <> nil then begin
      if Self.BtnData.ShowMark then begin
        if Self.Mark and (Self.MarkImageIndex >= 0) then begin
          Self.BtnData.ImageList.Draw(Self.Canvas, Self.BtnData.MarcRect.Left, Self.BtnData.MarcRect.Top, MarkImageIndex, True);

          Self.Canvas.Brush.Style:=bsClear;
          Self.Canvas.Font.Size:= 3;
          s := IntToStr(Self.MarkNum);
          sx := ( Self.BtnData.MarcRect.Right + Self.BtnData.MarcRect.Left - Self.Canvas.TextWidth(s) ) div 2;
          sy := ( Self.BtnData.MarcRect.Bottom + Self.BtnData.MarcRect.Top - Self.Canvas.TextHeight(s) ) div 2;
          Self.Canvas.TextOut(sx, sy, s);
        end
        else begin
          Self.BtnData.ImageList.Draw(Self.Canvas, Self.BtnData.MarcRect.Left, Self.BtnData.MarcRect.Top, 1, True);
        end;
      end;

      if Self.IconImageIndex >= 0 then begin
        Self.BtnData.IconList.Draw(Self.Canvas, Self.BtnData.IconRect.Left, Self.BtnData.IconRect.Top, Self.IconImageIndex, True);
      end;

      if Self.sys.IconIndex >= 0 then begin
        Self.BtnData.IconList.Draw(Self.Canvas, Self.BtnData.SysIconRect.Left, Self.BtnData.SysIconRect.Top, Self.sys.IconIndex, True);
      end;

      if Self.BtnData.HistShow then begin
        d := CurStepNum - Self.StepNum;
        if (Self.StepNum > 0) and (d > 0) and (d <= Self.BtnData.HistLength) then begin
          Self.BtnData.ImageList.Draw(Self.Canvas, Self.BtnData.HistRect.Left, Self.BtnData.HistRect.Top, 19, True);

          Self.Canvas.Brush.Style:=bsClear;
          Self.Canvas.Font.Size:= 3;
          s := IntToStr(d);
          sx := ( Self.BtnData.HistRect.Right + Self.BtnData.HistRect.Left - Self.Canvas.TextWidth(s) ) div 2;
          sy := ( Self.BtnData.HistRect.Bottom + Self.BtnData.HistRect.Top - Self.Canvas.TextHeight(s) ) div 2;
          Self.Canvas.TextOut(sx, sy, s);
        end;
      end;
    end;
  finally
    ReleaseMutex(BMutex);
  end;
end;

{ TSAPTaskBar }

function WndCallback(Ahwnd: HWND; uMsg: UINT; wParam: WParam; lParam: LParam):LRESULT; stdcall;
begin
  if uMsg=WM_SIZING then begin
    fSAPTaskBar.sizing := 5;
    fSAPTaskBar.HideTiker := 8;
  end;
  result:=CallWindowProc(PrevWndProc,Ahwnd, uMsg, WParam, LParam);
end;

procedure TSAPTaskBar.FormCreate(Sender: TObject);
begin
  Self.Caption:= SelfWindowName;
  Self.plArea.OnResize:= nil;

  AppHandle := TWin32WidgetSet(WidgetSet).AppHandle;

  Taskbar := CreateComObject(CLSID_TaskbarList) as ITaskbarList;
  Taskbar.HrInit;

  SelfDir :=  ExtractFilePath(ParamStr(0));

  Self.BtnData.ImageList := Self.ImageList;
  Self.BtnData.IconList  := Self.IconList;

  DrawSapTitle := True;

  SLList := TStringList.Create;
  TBList := TList.Create;
  CTBList:= TList.Create;
  RTBList:= TList.Create;
  CMutex := CreateMutex(nil, FALSE, 'SAPTaskBar_BTNGliph');
  BMutex := CreateMutex(nil, FALSE, 'SAPTaskBar_BTNLeave');
  SysList:= TList.Create;

  IconMapList := TStringList.Create;

  sbmp   := TBitmap32.Create;

  dbmp   := TBitmap32.Create;
  dbmp.Font.Color := TColor(1);
  dbmp.Font.Style := [fsBold];

  SideBarOn := False;
  BtnMoving := False;

  Self.plTasks.DoubleBuffered:=True;

  LoadIcons;
  LoadIconsMap;

  Randomize;

// Не ловятся некоторые сообщения, чтоб побороть это делаем подмену WndProc
// этот способ рекомендован http://wiki.lazarus.freepascal.org/Win32/64_Interface#Processing_non-user_messages_in_your_window
  PrevWndProc:={%H-}Windows.WNDPROC(SetWindowLongPtr(Self.Handle,GWL_WNDPROC,{%H-}PtrInt(@WndCallback)));
end;

procedure TSAPTaskBar.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose := MessageDlg(rsMsg001, mtConfirmation, [mbYes, mbNo], 0) = mrYes; // Do you want to exit from SAPTaskBar?
end;

procedure TSAPTaskBar.btnGroupActionClick(Sender: TObject);
var
  i : Integer;
  j : Integer;
  ctb : TTaskBtn;
  mi : TMenuItem;
  MarkFound : Boolean;
  HideFound : Boolean;
  ctMark : Integer;
  pt : TPoint;
  ctNotMarked : Integer;
begin
  MarkFound := False;
  HideFound := False;
  ctMark    := 0;

  for j := 0 to ppmGroupAction.Items.Count - 1 do begin
    mi := ppmGroupAction.Items[j];
    if mi.Hint = '' then Continue;
    mi.Tag:= 0;
  end;

  ctNotMarked := TBList.Count;
  for i := 0 to TBList.Count - 1 do begin
    ctb := TTaskBtn(TBList[i]);
    if not ctb.Visible and not ctb.Mark then HideFound := True;
    if not ctb.Mark then Continue;

    MarkFound := True;
    Dec(ctNotMarked);

    for j := 0 to ppmGroupAction.Items.Count - 1 do begin
      mi := ppmGroupAction.Items[j];
      if mi.ImageIndex <> ctb.MarkImageIndex then Continue;
      mi.Tag := mi.Tag + 1;
    end;
  end;
  micxNotMarked.Tag:= ctNotMarked;

  for j := 0 to ppmGroupAction.Items.Count - 1 do begin
    mi := ppmGroupAction.Items[j];
    if mi.Hint = '' then Continue;
    mi.Caption:= mi.Hint +' '+ IntToStr(mi.Tag);
    if not mi.Visible and (mi.Tag > 0) then mi.Checked:= True;
    mi.Visible:= mi.Tag > 0;

    if mi.ImageIndex = btnGroupAction.ImageIndex then ctMark := mi.Tag;
  end;

  if MarkFound and not micxNotMarked.Visible then micxNotMarked.Checked:= True;
  micxNotMarked.Visible:= MarkFound;
  miSpliter2.Visible:= MarkFound;

  if not MarkFound and HideFound and not micxNotMarked.Checked then begin
    micxNotMarked.Visible:= True;
    miSpliter2.Visible:= True;
  end;

  miLikeColumn.Enabled:= ctMark > 1;
  miLikeRows.Enabled  := ctMark > 1;
  miRestore.Enabled   := ctMark >= 1;

  miThreeWin1.Visible:= ctMark = 3;
  miThreeWin2.Visible:= ctMark = 3;
  miThreeWin3.Visible:= ctMark = 3;
  miThreeWin4.Visible:= ctMark = 3;

  miFourWin.Visible  := ctMark = 4;

  pt.X := btnGroupAction.Left;
  pt.Y := btnGroupAction.Top + btnGroupAction.Height + 1;

  pt := ClientToScreen(pt);

  ppmGroupAction.Popup(pt.X, pt.Y);
end;

procedure TSAPTaskBar.btnHideKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Key := 0;
end;

procedure TSAPTaskBar.btnOptionsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  pt : TPoint;
begin
  if not (ssRight in Shift) then Exit;
  pt.x:= btnOptions.Left;
  pt.y:= btnOptions.Top + btnOptions.Height;
  pt := ClientToScreen(pt);

  ppmOption.PopUp(pt.x, pt.y);
end;

procedure TSAPTaskBar.btnScrollTopClick(Sender: TObject);
var
  i : Integer;
  ctb : TTaskBtn;
  g   : Integer;
  m   : Integer;
begin
  m := -1;
  g := - plTasks.Top;
  for i := 0 to TBList.Count - 1 do begin
    ctb := TTaskBtn(TBList[i]);
    if (ctb.Top > m) and (ctb.Top < g) then m := ctb.Top;
  end;
  if m < 0 then Exit;

  plTasks.Top := - m;
end;

procedure TSAPTaskBar.btnShowHidenClick(Sender: TObject);
begin
  miFilter.Checked := False;
  miSelFilter.Checked := False;
  micxNotMarked.Visible := False;
  ApplyFilers;
end;

procedure TSAPTaskBar.btnScrollBottomClick(Sender: TObject);
var
  i : Integer;
  ctb : TTaskBtn;
  g   : Integer;
  s   : Integer;
  m   : Integer;
begin
  m := high(m);
  g := plArea.Height - plTasks.Top;
  for i := 0 to TBList.Count - 1 do begin
    ctb := TTaskBtn(TBList[i]);
    s := ctb.Top + ctb.Height;
    if (s > g) and (s < m) then m := s;
  end;
  if m = high(m) then Exit;

  plTasks.Top :=  plArea.Height - m;
end;

procedure TSAPTaskBar.btnScrollLeftClick(Sender: TObject);
var
  i : Integer;
  ctb : TTaskBtn;
  g   : Integer;
  m   : Integer;
begin
  m := -1;
  g := - plTasks.Left;
  for i := 0 to TBList.Count - 1 do begin
    ctb := TTaskBtn(TBList[i]);
    if (ctb.Left > m) and (ctb.Left < g) then m := ctb.Left;
  end;
  if m < 0 then Exit;

  plTasks.Left := - m;
end;

procedure TSAPTaskBar.btnScrollRightClick(Sender: TObject);
var
  i : Integer;
  ctb : TTaskBtn;
  g   : Integer;
  s   : Integer;
  m   : Integer;
begin
  m := high(m);
  g := plArea.Width - plTasks.Left;
  for i := 0 to TBList.Count - 1 do begin
    ctb := TTaskBtn(TBList[i]);
    s := ctb.Left + ctb.Width;
    if (s > g) and (s < m) then m := s;
  end;
  if m = high(m) then Exit;

  plTasks.Left :=  plArea.Width - m;
end;

procedure TSAPTaskBar.btnGroupActionMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  pt : TPoint;
begin
  if not (ssRight in Shift) then Exit;
  pt.x:= btnGroupAction.Left;
  pt.y:= btnGroupAction.Top + btnGroupAction.Height;
  pt := ClientToScreen(pt);

  ppmMarkIcons.PopUp(pt.x, pt.y);
end;

procedure TSAPTaskBar.TrayIconDblClick(Sender: TObject);
begin
  if miShow.Visible
  then miShowClick(Sender)
  else BtnHideClick(Sender);
end;

procedure TSAPTaskBar.FormPaint(Sender: TObject);
var
  SHPriority: TThreadPriority;
begin
  Self.OnPaint:= nil;

  Self.Hide;

  Windows.SetFocus(0);

  ReadSelfVersion;
  LoadSys;
  LoadOptions;
  GuiTuning;
  ReadSapLogon;

  if not DebugPrepare then begin // Если установлен Hook зависает debuger на любой строчке
    if CotrolLanguage
    then SetHook
    else SetHookNLng;
  end;

  AeroEnabled := not IgnoreAero and ISAeroEnabled;

//Remove title Bar
  SetWindowLong(Self.Handle, GWL_EXSTYLE, getWindowLong(Self.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW);
  SetWindowLong(Self.Handle, GWL_STYLE, (getWindowLong(Self.Handle, GWL_STYLE) {%H-}or WS_POPUP) AND (NOT WS_DLGFRAME));

// Прячем свою кнопку в TaskBar-e
  if HideTaskBtn then begin
    HideTaskButton(AppHandle);
  end;

// Прячем кнопку SAPLogon в TaskBar-е
  if HideSapLogonTaskBtn then begin
    HideTaskButton(GetSapLogonWnd);
  end;

  Self.Show;

  ApplyOptions;
  sizing := 2; // Чтоб немного ускорить начало обновления

  plTasks.OnChangeBounds:= plTasksResize;

  CThread := TBtnGlyphThread.Create(True);

  SHPriority := tpNormal;
  case SHThreadPriority of
    0 : SHPriority := tpNormal;
    1 : SHPriority := tpLower;
    2 : SHPriority := tpLowest;
    3 : SHPriority := tpIdle;
  end;
  CThread.ScreenCaptureInterval:= Self.ScreenCaptureInterval;
  CThread.Priority:= SHPriority;

  CThread.Resume{%H-};

  Timer.Enabled := True;
end;

procedure TSAPTaskBar.FormResize(Sender: TObject);
begin
  Self.btnHide.Top:= 0;
  Self.btnHide.Left:= Self.Width - Self.btnHide.Width;
end;

procedure TSAPTaskBar.miCloseSapGuiWindowClick(Sender: TObject);
var
   btn : TTaskBtn;
begin
  btn := TTaskBtn(ppmButton.Tag);
  if btn = nil then Exit;
  ShowSapGUI(btn);
  PostMessage(btn.hw, WM_SYSCOMMAND, SC_CLOSE, 0);
end;

procedure TSAPTaskBar.micxNotMarkedClick(Sender: TObject);
begin
  ApplyFilers;
end;

procedure TSAPTaskBar.miGatherGroupClick(Sender: TObject);
var
  btn : TTaskBtn;
  i   : Integer;
  ctb : TTaskBtn;

  bl  : TList;

  ins_index : Integer;

  ct : Integer;
  k  : Integer;
  max_num   : Integer;
  max_index : Integer;
begin
  btn := TTaskBtn(ppmButton.Tag);
  if btn = nil then Exit;
  if not btn.Mark then Exit;

  bl := TList.Create;

  ins_index := -1;

  for i := TBList.Count - 1 downto 0 do begin
    ctb := TTaskBtn(TBList[i]);
    if not ctb.Mark then Continue;
    if ctb.MarkImageIndex <> btn.MarkImageIndex then Continue;

    if ctb = btn then ins_index := i;

    bl.Add(ctb);
    TBList.Delete(i);
  end;

  ct := bl.Count;
  if ins_index >= 0 then begin
    for k := 1 to ct do begin
      max_num := -1;
      max_index := -1;
      for i := 0 to bl.Count - 1 do begin
        ctb := TTaskBtn(bl[i]);
        if max_num < ctb.MarkNum then begin
          max_num   := ctb.MarkNum;
          max_index := i;
        end;
      end;

      if max_index >= 0 then begin
        ctb := TTaskBtn(bl[max_index]);
        TBList.Insert(ins_index, ctb);
        bl.Delete(max_index);
      end;
    end;
  end;

  bl.Free;

  RefreshButtons;
end;

procedure TSAPTaskBar.miMarkGroupClick(Sender: TObject);
begin
  ApplyFilers;
end;

procedure TSAPTaskBar.SetSapWinToPos(Mode: Integer);
var
  ImageIndex : Integer;
  ct  : Integer;
  m   : Integer;
  mnum: Integer;
  i   : Integer;
  ctb : TTaskBtn;
  btn : TTaskBtn;
  hw  : HWND;
  mr  : TRect;
  mhw : Integer;
  mhh : Integer;
  num : Integer;
  wr  : TRect;
  cx  : Integer;
  cy  : Integer;
  xMode : Integer;
begin
  ImageIndex := btnGroupAction.ImageIndex;

  ct := 0;
  mnum := 0;
  for i := 0 to TBList.Count - 1 do begin
    ctb := TTaskBtn(TBList[i]);
    if not ctb.Mark then Continue;
    if ctb.MarkImageIndex <> ImageIndex then Continue;

    Inc(ct);
    if mnum < ctb.MarkNum then mnum := ctb.MarkNum;

    if ctb.Restore = 0 then begin
      if IsZoomed(ctb.hw) then ctb.Restore:= 1
      else if IsIconic(ctb.hw) then ctb.Restore:= 2
      else ctb.Restore:= 3;

      MyShowWindow(ctb.hw, SW_RESTORE);
      GetWindowRect(ctb.hw, ctb.RestoreRect);
    end;
  end;
  if ct <= 1 then Exit;

  mr := Screen.WorkAreaRect;

  mhw := mr.Left + (mr.Right - mr.Left) div 2;
  mhh := mr.Top  + (mr.Bottom - mr.Top) div 2;

  Inc(BtnGroupIndex);

  num := 0;
  for m := 1 to mnum do begin
    hw := 0;
    btn := nil;
    for i := 0 to TBList.Count - 1 do begin
      ctb := TTaskBtn(TBList[i]);
      if ctb.Mark and (ctb.MarkImageIndex = ImageIndex) and (ctb.MarkNum = m) then begin
        btn := ctb;
        hw := ctb.hw;
        Break;
      end;
    end;
    if hw = 0 then Continue;

    Inc(num);

    wr := mr;

    xMode := Mode * 10 + num;
    case xMode of
      // в верху 2 снизу 1
      11: begin
        wr.Right  := mhw;
        wr.Bottom := mhh;
      end;
      12: begin
        wr.Left   := mhw;
        wr.Bottom := mhh;
      end;
      13: begin
        wr.Top    := mhh;
      end;
      // в верху 1 снизу 2
      21: begin
        wr.Bottom:= mhh;
      end;
      22: begin
        wr.Right  := mhw;
        wr.Top    := mhh;
      end;
      23: begin
        wr.Left   := mhw;
        wr.Top    := mhh;
      end;
      // с лева 1 с права 2
      31: begin
        wr.Right  := mhw;
      end;
      32: begin
        wr.Left   := mhw;
        wr.Bottom := mhh;
      end;
      33: begin
        wr.Left   := mhw;
        wr.Top    := mhh;
      end;
      // с лева 2 с права 1
      41: begin
        wr.Right  := mhw;
        wr.Bottom := mhh;
      end;
      42: begin
        wr.Left   := mhw;
      end;
      43: begin
        wr.Right  := mhw;
        wr.Top    := mhh;
      end;
      // с лева 2 с права 2
      51: begin
        wr.Right  := mhw;
        wr.Bottom := mhh;
      end;
      52: begin
        wr.Left   := mhw;
        wr.Bottom := mhh;
      end;
      53: begin
        wr.Right  := mhw;
        wr.Top    := mhh;
      end;
      54: begin
        wr.Left   := mhw;
        wr.Top    := mhh;
      end;
      else begin
        if Mode = 6 then begin // Как столбцы
          cx := (wr.Right - wr.Left) div ct;
          wr.Left := wr.Left + cx * (num - 1);
          wr.Right:= wr.Left + cx;
        end;
        if Mode = 7 then begin // Как строки
          cy := (wr.Bottom - wr.Top) div ct;
          wr.Top   := wr.Top + cy * (num - 1);
          wr.Bottom:= wr.Top + cy;
        end;
      end;
    end;

    btn.GrpIndex := BtnGroupIndex;
    btn.GrpRect  := wr;

    MyShowWindow(hw, SW_RESTORE);
    MySetWindowPos(hw, wr);
    MySetForegroundWindow(hw);

    GetBtnGlyph(btn, False);
  end;
end;

procedure TSAPTaskBar.miMaximizeClick(Sender: TObject);
var
  i   : Integer;
  ctb : TTaskBtn;
begin
  for i := 0 to TBList.Count - 1 do begin
    ctb := TTaskBtn(TBList[i]);
    if not ctb.Visible then Continue;

    if IsZoomed(ctb.hw)
    then CheckWindowPos(ctb.hw)
    else MyShowWindow(ctb.hw, SW_MAXIMIZE);

    GetBtnGlyph(ctb, False);
  end;
end;

procedure TSAPTaskBar.miRestoreClick(Sender: TObject);
var
  j   : Integer;
  ctb : TTaskBtn;
  ImageIndex : Integer;
begin
  ImageIndex := btnGroupAction.ImageIndex;

  for j := 0 to TBList.Count - 1 do begin
    ctb := TTaskBtn(TBList[j]);
    if not ctb.Mark then Continue;
    if ctb.MarkImageIndex <> ImageIndex then Continue;

    MyShowWindow(ctb.hw, SW_RESTORE);
    MySetWindowPos(ctb.hw, ctb.RestoreRect);

    if ctb.Restore = 1 then begin
      MyShowWindow(ctb.hw, SW_MAXIMIZE);
      Continue;
    end;

    if ctb.Restore = 2 then begin
      MyShowWindow(ctb.hw, SW_MINIMIZE);
      Continue;
    end;
  end;

  for j := 0 to TBList.Count - 1 do begin
    ctb := TTaskBtn(TBList[j]);
    if not ctb.Mark then Continue;
    if ctb.MarkImageIndex <> ImageIndex then Continue;

    ctb.Restore := 0;
    ctb.GrpIndex:= 0;
    GetBtnGlyph(ctb, False);
  end;
end;

procedure TSAPTaskBar.miSapLogonClick(Sender: TObject);
var
  path : String;
begin
  SapLogon_hw := GetSapLogonWnd;
  if SapLogon_hw <> 0 then begin
    if IsIconic(SapLogon_hw)
    then MyShowWindow(SapLogon_hw, SW_RESTORE)
    else MySetForegroundWindow(SapLogon_hw);
    Exit;
  end;

  path := SapGuiPath + '\saplogon.exe';
  if not FileExists(path) then Exit;

  ShellExecute(0, 'open', PAnsiChar(path), nil, '', SW_SHOW);
end;

procedure TSAPTaskBar.miShowBtnMarkerClick(Sender: TObject);
begin
  ShowBtnMarker := miShowBtnMarker.Checked;
  Self.BtnData.ShowMark  := ShowBtnMarker;
  btnGroupAction.Visible := ShowBtnMarker;
  plTasks.Invalidate;
end;

procedure TSAPTaskBar.miShowStepHistoryClick(Sender: TObject);
begin
  ShowStepHistory := miShowStepHistory.Checked;
  Self.BtnData.HistShow:= ShowStepHistory;
  plTasks.Invalidate;
end;

procedure TSAPTaskBar.miWinPosClick(Sender: TObject);
begin
  SetSapWinToPos(TMenuItem(Sender).Tag);
end;

procedure TSAPTaskBar.plTasksResize(Sender: TObject);
var
  g : Integer;
begin
// Кнопки btnScroll* размещены на панели plTasks потому что эти кнопки TSpeedButton
// графические рисуются окном владельца и поэтому перекрываются любым вше лижащим окном
// т.е. если разместить их на plArea то они будут перекрываться plTasks
// Других подходящих компонентов не нашол

  if not ShowScrollButton then Exit;

  if Direct = dtVertical then begin
    g := (plTasks.Width - btnScrollTop.Width) div 2;

    btnScrollTop.Left:= g;
    if plTasks.Top < 0 then begin
      btnScrollTop.Top:= - plTasks.Top;
      btnScrollTop.Visible:= True;
      btnScrollTop.BringToFront;
    end
    else btnScrollTop.Visible := False;

    btnScrollBottom.Left:= g;
    if (plTasks.Top + plTasks.Height) > plArea.Height then begin
      btnScrollBottom.Top := plArea.Height - plTasks.Top - btnScrollBottom.Height;
      btnScrollBottom.Visible:= True;
      btnScrollBottom.BringToFront;
    end
    else btnScrollBottom.Visible:= False;

    btnScrollLeft.Visible := False;
    btnScrollRight.Visible:= False;
  end;

  if Direct = dtHorizontal then begin
    g := (plTasks.Height - btnScrollLeft.Height) div 2;

    btnScrollLeft.Top:= g;
    if plTasks.Left < 0 then begin
      btnScrollLeft.Left:= - plTasks.Left;
      btnScrollLeft.Visible:= True;
      btnScrollLeft.BringToFront;
    end
    else btnScrollLeft.Visible := False;

    btnScrollRight.Top:= g;
    if (plTasks.Left + plTasks.Width) > plArea.Width then begin
      btnScrollRight.Left := plArea.Width - plTasks.Left - btnScrollRight.Width;
      btnScrollRight.Visible:= True;
      btnScrollRight.BringToFront;
    end
    else btnScrollRight.Visible:= False;

    btnScrollTop.Visible := False;
    btnScrollBottom.Visible:= False;
  end;
end;

procedure TSAPTaskBar.ppmOptionPopup(Sender: TObject);
begin
  miAutoHide.Visible := PanelMode <> oppmAlignToTaskBar;
  miAutoHide.Checked := PanelMode = oppmAutoHide;
  miShowBtnMarker.Checked:= ShowBtnMarker;
  miShowStepHistory.Checked := ShowStepHistory;
end;

procedure TSAPTaskBar.ppmTrayIconPopup(Sender: TObject);
var
  i : Integer;
  sys : PSapSys;
begin
  RefreshButtons;

  for i := ppmTrayIcon.Items.Count - 1 downto 0 do begin
    ppmTrayIcon.Items.Delete(i);
  end;
  for i := ppmSapSys.Items.Count - 1 downto 0 do begin
    ppmSapSys.Items.Delete(i);
  end;

  if Self.Visible
  then ppmTrayIcon.Items.Add(miTrayIcon_Hide)
  else ppmTrayIcon.Items.Add(miTrayIcon_Show);

  ppmTrayIcon.Items.Add(miTrayIcon_Exit);

  ppmTrayIcon.Items.Add(miTrayIcon_Splitter);

  ppmTrayIcon.Items.Add(miSapLogon);

  for i := 0 to SysList.Count - 1 do begin
    sys := PSapSys(SysList[i]);
    if sys.Count <> 0 then Continue;
    if sys.Name = invalid_sys_name then Continue;

    sys.mi.Caption := sys.desc;
    sys.mi.ShowAlwaysCheckable:=False;
    sys.mi.AutoCheck:=False;
    sys.mi.RadioItem:=False;
    sys.mi.GroupIndex:=0;
    sys.mi.Checked:=False;

    ppmTrayIcon.Items.Add(sys.mi);
  end;

end;

procedure TSAPTaskBar.miSelFilterClick(Sender: TObject);
var
  i   : Integer;
  sys : PSapSys;
begin
  for i := 0 to SysList.Count - 1 do begin
    sys := PSapSys(SysList[i]);
    sys.mi.Checked:= False;
  end;

  if miSelFilter.Checked then begin
    miFilter.Checked:= False;
  end;

  ApplyFilers;
end;

procedure TSAPTaskBar.miFilterClick(Sender: TObject);
var
  i   : Integer;
  sys : PSapSys;
begin
  for i := 0 to SysList.Count - 1 do begin
    sys := PSapSys(SysList[i]);
    sys.mi.ShowAlwaysCheckable:=True;
    sys.mi.AutoCheck:=True;
    sys.mi.RadioItem:=False;
    sys.mi.GroupIndex:=0;
    sys.mi.Checked:= miFilter.Checked;
  end;

  if miFilter.Checked then begin
    miSelFilter.Checked:= False;
  end;

  ApplyFilers;
end;

procedure TSAPTaskBar.miMapIconClick(Sender: TObject);
var
  tb : TTaskBtn;
begin
  tb := TTaskBtn(ppmButton.Tag);
  MapIconEx(tb);
end;

procedure TSAPTaskBar.MapIconEx(tb : TTaskBtn);
var
  i : Integer;
  mi : TMenuItem;
  found : Boolean;
  sl : TStringList;
  mr : Integer;
  s : String;
begin
  fmMapIcon.cbxIcon.Items.Clear;

  for i := 0 to miIcons.Count - 1 do begin
    mi := miIcons.Items[i];
    if mi.Name <> '' then Continue;

    fmMapIcon.cbxIcon.Items.AddObject(mi.Caption, mi);
  end;

  fmMapIcon.edTitle.Text:= tb.title;

  fmMapIcon.edMask.Text:= tb.IconMask;
  fmMapIcon.edMask.OnChange(nil);

  fmMapIcon.btnDel.Visible:= tb.IconMask <> '';

  fmMapIcon.cbxIcon.ItemIndex:= tb.IconImageIndex;
  fmMapIcon.btnOk.Enabled:=False;

  mr := fmMapIcon.ShowModal;

  if mr = mrCancel then Exit;

  if mr = mrAbort then begin // Удаление присвоения
     s := '$||'+ tb.IconMask;

    found := False;
    for i := 0 to IconMapList.Count - 1 do begin
      if SameText(s, IconMapList[i]) then begin
        found := True;
        IconMapList.Delete(i);
        Break;
      end;
    end;
    if not found then Exit;
  end;

  if mr = mrOk then begin
    s := '$||'+ fmMapIcon.edMask.Text;

    found := False;
    for i := 0 to IconMapList.Count - 1 do begin

      if SameText(s, IconMapList[i]) then begin
        found := True;
        IconMapList.Objects[i] := fmMapIcon.cbxIcon.Items.Objects[fmMapIcon.cbxIcon.ItemIndex];
        Break;
      end;
    end;

    if not found then begin
      IconMapList.AddObject(s, fmMapIcon.cbxIcon.Items.Objects[fmMapIcon.cbxIcon.ItemIndex]);
    end;
  end;

  sl := TStringList.Create;

  for i := 0 to IconMapList.Count - 1 do begin
    sl.Add(IconMapList[i] +'&'+ TMenuItem(IconMapList.Objects[i]).Caption);
  end;

  sl.SaveToFile(SelfDir + scIconMap);
  sl.Free;

  for i := 0 to TBList.Count -1 do begin
    tb := TTaskBtn(TBList[i]);
    MapIcon(tb);
  end;
end;

procedure TSAPTaskBar.miMarkIconClick(Sender: TObject);
var
  mi : TMenuItem;
begin
  mi := TMenuItem(Sender);
  btnGroupAction.ImageIndex:= mi.ImageIndex;
end;

procedure TSAPTaskBar.miLockChangeSizeClick(Sender: TObject);
begin
  LockChangeSize := Self.miLockChangeSize.Checked;
end;

procedure TSAPTaskBar.miRemoveIconClick(Sender: TObject);
var
  tb : TTaskBtn;
begin
  tb := TTaskBtn(ppmButton.Tag);
  if tb.IconImageIndex < 0 then Exit;

  if tb.IconMask <> '' then begin
    MapIconEx(tb);
    Exit;
  end;

  tb.IconImageIndex:= -1;
  tb.Invalidate;
end;

procedure TSAPTaskBar.miRestartClick(Sender: TObject);
var
  Str : String;
begin
  Str := Application.ExeName;
  ShellExecute(0, 'Open', PAnsiChar(Str), nil, nil, SW_RESTORE);
  Timer.Enabled:= False;
  SaveLastRunWndList;
  Terminate;
end;

procedure TSAPTaskBar.miSapSystemsListClick(Sender: TObject);
begin
  EditOptions(fmOptions.tsSapSys);
end;

procedure TSAPTaskBar.FormDestroy(Sender: TObject);
var
  i : Integer;
  ctb : TTaskBtn;
begin
  Timer.Enabled:= False;
  CThread.Free;

  if not NotSave then begin
    SaveSys;
    SaveOptions;
  end;
  
  UnHook;
  SideBarRemove;

  if HideSapLogonTaskBtn then begin
    ShowTaskButton(GetSapLogonWnd);
  end;

  if HideSapGuiTaskBtn then begin
    for i := 0 to TBList.Count - 1 do begin
      ctb := TTaskBtn(TBList[i]);
      ShowTaskButton(ctb.hw);
      MyShowWindow(ctb.hw, SW_SHOWNA);
    end;
  end;

  TBList.Free;
  sbmp.Free;
  dbmp.Free;

  for i := 0 to SLList.Count - 1 do begin
    Dispose(PSLItem(SLList.Objects[i]));
  end;
  SLList.Free;

  for i := 0 to SysList.Count - 1 do begin
    Dispose(PSapSys(SysList[i]));
  end;
  SysList.Free;

  IconMapList.Free;
  if cbmp <> nil then cbmp.Free;

  if LastRunWndList <> nil then LastRunWndList.Free;

  Taskbar := nil;
  CloseHandle(CMutex);
  CloseHandle(BMutex);
  CTBList.Free;
  RTBList.Free;
end;

procedure TSAPTaskBar.ApplyOptions;
var
  xAlign : TAlign;
begin
  Self.plArea.OnResize := nil;
  xAlign := alNone;

  if PanelMode = oppmAlignToTaskBar then begin
    xAlign := GetTaskBarAlign;
  end
  else begin
    case SelectAlign of
      opsaLeft   : xAlign := alLeft;
      opsaRight  : xAlign := alRight;
      opsaTop    : xAlign := alTop;
      opsaBottom : xAlign := alBottom;
    end;
  end;

  fmPlug.Visible := Plug_Visible;
  if Plug_Visible and (Plug_AlphaBlend > 0) then begin
    fmPlug.AlphaBlend:= True;
    fmPlug.AlphaBlendValue:= 255 - Plug_AlphaBlend;
  end;
  SetTransparent(Plug_AlphaBlend > 0);

  if (xAlign <> SAlign) or (SideBarOn <> (PanelMode = oppmLikeTaskBar)) then begin
    SetFormAlign(xAlign);
  end;

  btnHide.Visible:= PanelMode = oppmLikeTaskBar;
  miHide.Visible := PanelMode = oppmLikeTaskBar;

  btnScrollLeft.Visible   := False;
  btnScrollTop.Visible    := False;
  btnScrollRight.Visible  := False;
  btnScrollBottom.Visible := False;

  plLabel.Visible:= False;
  if Direct = dtHorizontal then begin
    ToolBar.Align := alLeft;

    if PanelMode = oppmLikeTaskBar then begin
      plLabel.Width:= btnHide.Width - 1;
      plLabel.BevelOuter:= bvNone;
      plLabel.Visible:= True;
      plLabel.Align:= alRight;
      plLabel.SendToBack;
    end;
  end;

  if Direct = dtVertical then begin
    ToolBar.Align := alTop;
  end;

  btnGroupAction.Visible := ShowBtnMarker;

  btnSapSys.Align      := alNone;
  btnOptions.Align     := alNone;
  btnGroupAction.Align := alNone;
  btnShowHiden.Align   := alNone;

  case SAlign of
    alTop    : begin
      btnSapSys.Align      := alBottom;
      btnGroupAction.Align := alBottom;
      btnShowHiden.Align   := alBottom;
      btnOptions.Align     := alBottom;
      ToolBar.Width:= ToolBar.ButtonWidth + 1;
    end;

    alBottom : begin
      btnSapSys.Align      := alTop;
      btnGroupAction.Align := alTop;
      btnShowHiden.Align   := alTop;
      btnOptions.Align     := alTop;
      ToolBar.Width:= ToolBar.ButtonWidth + 1;
    end;

    alLeft   : begin
      btnOptions.Align     := alLeft;
      btnShowHiden.Align   := alLeft;
      btnGroupAction.Align := alLeft;
      btnSapSys.Align      := alLeft;
      ToolBar.Height:= ToolBar.ButtonHeight + 1;
    end;

    alRight  : begin
      btnSapSys.Align      := alLeft;
      btnGroupAction.Align := alLeft;
      btnShowHiden.Align   := alLeft;
      btnOptions.Align     := alLeft;
      ToolBar.Height:= ToolBar.ButtonHeight + 1;
    end;
  end;

  Self.plArea.OnResize:= plAreaResize;
  plAreaResize(Self); // Вызывыет в конце RefreshButtons
end;

procedure TSAPTaskBar.plAreaResize(Sender: TObject);
var
  i : Integer;
  ctb : TTaskBtn;
  dr: TRect;
  r : TRect;
  sr : TRect;
  sw : Integer;
  sh : Integer;
begin
  SetPlug;

  sizing := 5;
  HideTiker := 8;

  if Self.Width  < LowLimitThumbSize then Self.Width  := LowLimitThumbSize;
  if Self.Height < LowLimitThumbSize then Self.Height := LowLimitThumbSize;

  sr := Screen.WorkAreaRect; // меняются пропорции экрана - меняются размеры кнопок при переключениии ориентации пнели
//  sr := Rect(0, 0, Screen.Width, Screen.Height);
  sw := sr.Right - sr.Left;
  sh := sr.Bottom - sr.Top;

  if Direct = dtVertical then begin
    ThumbWidth  := plArea.Width;
    ThumbHeight := (ThumbWidth * sh) div (sw);
    plTasks.Width := plArea.Width;

    Self.BtnData.MarcRect.Top  := ThumbHeight div 2 - Self.BtnData.ImageList.Height div 2;
    Self.BtnData.MarcRect.Bottom := Self.BtnData.MarcRect.Top + Self.BtnData.ImageList.Height;
    if SAlign = alLeft then begin
      Self.BtnData.MarcRect.Left  := ThumbWidth - Self.BtnData.ImageList.Width;
      Self.BtnData.MarcRect.Right := ThumbWidth;
    end
    else begin
      Self.BtnData.MarcRect.Left  := 0;
      Self.BtnData.MarcRect.Right := Self.BtnData.ImageList.Width;
    end;

    Self.BtnData.IconRect := Self.BtnData.MarcRect;
    Self.BtnData.IconRect.Top    := Self.BtnData.IconRect.Top    - Self.BtnData.ImageList.Height - 1;
    Self.BtnData.IconRect.Bottom := Self.BtnData.IconRect.Bottom - Self.BtnData.ImageList.Height - 1;

    Self.BtnData.HistRect := Self.BtnData.MarcRect;
    Self.BtnData.HistRect.Top    := Self.BtnData.HistRect.Top    + Self.BtnData.ImageList.Height + 1;
    Self.BtnData.HistRect.Bottom := Self.BtnData.HistRect.Bottom + Self.BtnData.ImageList.Height + 1;
  end;

  if Direct = dtHorizontal then begin
    ThumbHeight := plArea.Height;
    ThumbWidth  := (ThumbHeight * sw) div (sh);
    plTasks.Height := plArea.Height;

    Self.BtnData.MarcRect.Left  := ThumbWidth div 2 - Self.BtnData.ImageList.Width div 2;
    Self.BtnData.MarcRect.Right := Self.BtnData.MarcRect.Left + Self.BtnData.ImageList.Width;
    if SAlign = alTop then begin
      Self.BtnData.MarcRect.Top    := ThumbHeight - Self.BtnData.ImageList.Height;
      Self.BtnData.MarcRect.Bottom := ThumbHeight;
    end
    else begin
      Self.BtnData.MarcRect.Top    := 0;
      Self.BtnData.MarcRect.Bottom := Self.BtnData.ImageList.Height;
    end;

    Self.BtnData.IconRect := Self.BtnData.MarcRect;
    Self.BtnData.IconRect.Left  := Self.BtnData.IconRect.Left  - Self.BtnData.ImageList.Width - 1;
    Self.BtnData.IconRect.Right := Self.BtnData.IconRect.Right - Self.BtnData.ImageList.Width - 1;

    Self.BtnData.HistRect := Self.BtnData.MarcRect;
    Self.BtnData.HistRect.Left  := Self.BtnData.HistRect.Left  + Self.BtnData.ImageList.Width + 1;
    Self.BtnData.HistRect.Right := Self.BtnData.HistRect.Right + Self.BtnData.ImageList.Width + 1;
  end;

  case SAlign of
    alLeft, alTop : begin
      Self.BtnData.SysIconRect.Left   := 0;
      Self.BtnData.SysIconRect.Top    := 0;
      Self.BtnData.SysIconRect.Right  := Self.BtnData.ImageList.Width;
      Self.BtnData.SysIconRect.Bottom := Self.BtnData.ImageList.Height;
    end;

    alRight : begin
      Self.BtnData.SysIconRect.Left   := ThumbWidth - Self.BtnData.ImageList.Width;
      Self.BtnData.SysIconRect.Top    := 0;
      Self.BtnData.SysIconRect.Right  := ThumbWidth;
      Self.BtnData.SysIconRect.Bottom := Self.BtnData.ImageList.Height;
    end;

    alBottom : begin
      Self.BtnData.SysIconRect.Left   := 0;
      Self.BtnData.SysIconRect.Top    := ThumbHeight - Self.BtnData.ImageList.Height;
      Self.BtnData.SysIconRect.Right  := Self.BtnData.ImageList.Width;
      Self.BtnData.SysIconRect.Bottom := ThumbHeight;
    end;
  end;

  r := ImageRect;

  ImageRect := Rect(0, 0, ThumbWidth - 3, ThumbHeight - 3);
  dbmp.Width  := ImageRect.Right;
  dbmp.Height := ImageRect.Bottom;

  dr := ImageRect;

  for i := 0 to TBList.Count - 1 do begin
    ctb := TTaskBtn(TBList[i]);

    if ctb.Glyph.Width = 0 then begin
      ctb.Width  := ThumbWidth;
      ctb.Height := ThumbHeight;
      Continue;
    end;

    sbmp.Draw(0, 0, ctb.Glyph);
    dbmp.FillRect(0, 0, dbmp.Width, dbmp.Height, Color32(ctb.Color));
    SetStretchBltMode(dbmp.Canvas.Handle, STRETCH_HALFTONE);//устанавливаем режим сглаживания
    StretchBlt(dbmp.Canvas.Handle, dr.Left, dr.Top, dr.Right - dr.Left, dr.Bottom - dr.Top,
               sbmp.Canvas.Handle,  r.Left,  r.Top,  r.Right -  r.Left,  r.Bottom  - r.Top, cmSrcCopy);

    ctb.Width  := ThumbWidth;
    ctb.Height := ThumbHeight;

    ctb.Glyph.Width  := ImageRect.Right;
    ctb.Glyph.Height := ImageRect.Bottom;

    ctb.Glyph.Draw(0,0, dbmp);
  end;

  RefreshButtons;
end;

procedure TSAPTaskBar.RefreshButtons;
var
  hw  : hwnd;
  ctb : TTaskBtn;
  tb  : TTaskBtn;
  i   : Integer;
  found : Boolean;
  InsIndex : Integer;
  bl : TList;
  sl : TList;
  sys: PSapSys;
  cursys : PSapSys;
  selsys : PSapsys;
  j : Integer;
begin
  bl := TList.Create;
  sl := TList.Create;

  for i := 0 to TBList.Count - 1 do begin
    ctb := TTaskBtn(TBList[i]);
    ctb.intMark := 0;
  end;

  hw := 0;

  while true do begin
    hw := FindWindowEx(0, hw, SapWindowClass, nil);
    if hw = 0 then Break;

    found := False;
    for i := 0 to TBList.Count - 1 do begin
      ctb := TTaskBtn(TBList[i]);
      if ctb.hw = hw then begin
        found := True;
        ctb.intMark := 1;
        Break;
      end;
    end;
    if found then Continue;

    tb := TTaskBtn.Create(Self);
    tb.hw := hw;
    tb.ftime := Now;

    if HideSapGuiTaskBtn then HideTaskButton(hw);
    
    tb.intMark := 2;

    tb.Parent := plTasks;
    tb.Width  := ThumbWidth;
    tb.Height := ThumbHeight;

    tb.OnMouseDown := Self.BtnMouseDown;
    tb.OnMouseMove := Self.BtnMouseMove;
    tb.OnMouseUp   := Self.BtnMouseUp;
    tb.OnClick     := Self.BtnClick;
    tb.OnMouseLeave:= Self.BtnMouseLeave;
    tb.OnMarkChange:= Self.BtnMarkChange;
    tb.OnContextPopup:= Self.BtnPopUp;
    tb.PopupMenu := ppmButton;

    tb.BtnData:= @Self.BtnData;

    tb.OnShowHint:= Self.BtnShowHint;
    tb.ShowHint:=True;

    SplitSAPWindowText(tb);
    SetTaskBtnSys(tb);

    if (tb.mandt = ZeroMandt) and (tb.modno = 1) then LogonBtn := True;
    if (tb.sysid = '') or (tb.mandt = '') then InvalidSysName := True;

    InsIndex := -1;

    if tb.jdbmn >= 0 then begin  // окно отладки, рассполагаем рядом с отлаживаемым
      for i := 0 to TBList.Count - 1 do begin
        ctb := TTaskBtn(TBList[i]);
        if (ctb.sys = tb.sys) and (ctb.modno = tb.jdbmn) then begin
          InsIndex := i + 1;
          Break;
        end;
      end;
    end;

    if InsIndex < 0 then begin
      for i := 0 to TBList.Count - 1 do begin
        ctb := TTaskBtn(TBList[i]);
        if ctb.sys = tb.sys then InsIndex := i + 1;
      end;
    end;

    if InsIndex > 0 then begin
      TBList.Insert(InsIndex, tb);
    end
    else begin
      bl.Add(tb);
      if sl.IndexOf(tb.sys) < 0 then sl.Add(tb.sys);
    end;
  end;

  for i := TBList.Count - 1 downto 0 do begin
    ctb := TTaskBtn(TBList[i]);
    if ctb.intMark = 0 then begin
      TBList.Delete(i);
//    ctb.Free;
      DeleteButton(ctb);
    end;
  end;

  RefreshSysCount;

  for i := 0 to sl.Count - 1 do begin
    sys := PSapSys(sl[i]);

    selsys := nil;
    for j := 0 to SysList.Count - 1 do begin
      cursys := PSapSys(SysList[j]);
      if cursys = sys then Break;
      if cursys.Count = 0 then Continue;
      selsys := cursys;
    end;

    InsIndex := 0; // Компилятор ругается
    if selsys = nil then begin // Вставляем в начало
      InsIndex := 0;
    end
    else begin // Вставляем после selsys
      for j := 0 to TBList.Count - 1 do begin
        ctb := TTaskBtn(TBList[j]);
        if ctb.sys = selsys then InsIndex := j + 1;
      end;
    end;

    for j := 0 to bl.Count - 1 do begin
      ctb := TTaskBtn(bl[j]);
      if ctb.sys <> sys then Continue;

      TBList.Insert(InsIndex, ctb);
      Inc(ctb.sys.Count);
      Inc(InsIndex);
    end;
  end;

//-------------------
  RefreshBtnPos;

  bl.Free;
  sl.Free;

  if SysListChanged then SaveSys;
  RefreshSysCount;

  if LastRunWndList <> nil then SetLastRunWndList;
end;

procedure TSAPTaskBar.RefreshBtnPos;
var
  i : Integer;
  ctb : TTaskBtn;
  ptb : TTaskBtn;
begin
  if Direct = dtHorizontal then begin
    plTasks.Width := TBList.Count * (ThumbWidth + BThumbSize) + SysList.Count * BSysSize + 2;

    ptb := nil;
    for i := 0 to TBList.Count - 1 do begin
      ctb := TTaskBtn(TBList[i]);
      if not ctb.Visible then Continue;

      if ptb <> nil then begin
        if ctb.sys = ptb.sys
        then ctb.Left := ptb.Left + ThumbWidth + BThumbSize
        else ctb.Left := ptb.Left + ThumbWidth + BSysSize;
      end
      else ctb.Left := 0;

      ctb.Top:= 0;
      ptb := ctb;
    end;

    if ptb <> nil
    then plTasks.Width := ptb.Left + ThumbWidth;
  end;

  if Direct = dtVertical then begin
    plTasks.Height := TBList.Count * (ThumbHeight + BThumbSize) + SysList.Count * BSysSize + 2;

    ptb := nil;
    for i := 0 to TBList.Count - 1 do begin
      ctb := TTaskBtn(TBList[i]);
      if not ctb.Visible then Continue;

      if ptb <> nil then begin
        if ctb.sys = ptb.sys
        then ctb.Top := ptb.Top + ThumbHeight + BThumbSize
        else ctb.Top := ptb.Top + ThumbHeight + BSysSize;
      end
      else ctb.Top := 0;

      ctb.Left:= 0;
      ptb := ctb;
    end;

    if ptb <> nil
    then plTasks.Height := ptb.Top + ThumbHeight;
  end;
end;

procedure TSAPTaskBar.SortButtons;
var
  bl  : TList;
  i   : Integer;
  sys : PSapSys;
  j   : Integer;
  ctb : TTaskBtn;
begin
  bl := TList.Create;
  bl.Assign(TBList);

  TBList.Clear;

  for i := 0 to SysList.Count - 1 do begin
    sys := PSapSys(SysList[i]);

    for j := 0 to bl.Count - 1 do begin
      ctb := TTaskBtn(bl[j]);
      if ctb.sys <> sys then Continue;

      TBList.Add(ctb);
    end;
  end;

  bl.Free;

  RefreshButtons;
end;

function TSAPTaskBar.GetTaskBarAlign:TAlign;
var
  Data : TAppBarData;
  tbr : TRect;
  w : Integer;
  h : Integer;
begin
  FillChar(MyTaskBar, SizeOf(TAppBarData), 0);
  Data.hWnd := FindWindow('Shell_TrayWnd', nil);
  Data.cbSize := SizeOf(TAppBarData);

  Result := alNone;

  if SHAppBarMessage(ABM_GETTASKBARPOS, @Data) <> 1 then Exit;

  tbr := Data.rc;

  w := tbr.Right - tbr.Left;
  h := tbr.Bottom - tbr.Top;

  if tbr.Left > 3 then Result := alRight  else
  if tbr.Top  > 3 then Result := alBottom else
  if w > h        then Result := alTop    else Result := alLeft;
end;

procedure TSAPTaskBar.SetFormAlign(fAlign: TAlign);
var
  sr : TRect;
  sw : Integer;
  sh : Integer;

  l : Integer = 0;
  t : Integer = 0;
  w : Integer = 0;
  h : Integer = 0;
begin
  if SideBarOn then SideBarRemove;

  sr := Screen.WorkAreaRect;
  sw := sr.Right - sr.Left;
  sh := sr.Bottom - sr.Top;

  plTasks.Left  := 0;
  plTasks.Top   := 0;
  plTasks.Width := ThumbWidth;
  plTasks.Height:= ThumbHeight;

  SAlign := fAlign;

  case SAlign of
    alTop,  alBottom : Direct := dtHorizontal;
    alLeft, alRight  : Direct := dtVertical;
  end;

  if Direct = dtHorizontal then begin
    l := sr.Left;
    w := sw;
    h := ThumbHeight + GetSystemMetrics(SM_CYSIZEFRAME) * 2;
  end;

  if Direct = dtVertical then begin
    t := sr.Top;
    h := sh;
    w := ThumbWidth + GetSystemMetrics(SM_CXSIZEFRAME) * 2;
  end;

  case fAlign of
    alTop    : t := sr.Top;
    alBottom : t := sr.Bottom - h;
    alLeft   : l := sr.Left;
    alRight  : l := sr.Right - w;
  end;

  MySetWindowPos(Self.Handle, Rect(l, t, l + w, t + h));

  SideBarSet(fAlign);
end;

procedure TSAPTaskBar.SideBarSet(fAlign: TAlign);
begin
  if SideBarOn then SideBarRemove;

  FillChar(MyTaskBar, SizeOf(TAppBarData), 0);
  MyTaskBar.cbSize := SizeOf(TAppBarData);
  MyTaskBar.hWnd   := Self.Handle;

  case fAlign of
    alTop    : MyTaskBar.uEdge := ABE_TOP;
    alBottom : MyTaskBar.uEdge := ABE_BOTTOM;
    alLeft   : MyTaskBar.uEdge := ABE_LEFT;
    alRight  : MyTaskBar.uEdge := ABE_RIGHT;
  end;

  GetWindowRect(Self.Handle, MyTaskBar.rc);

  SHAppBarMessage(ABM_QUERYPOS, @MyTaskBar);
  MySetWindowPos(Self.Handle, MyTaskBar.rc);

  SetPlug;

  if PanelMode <> oppmLikeTaskBar then Exit; // Только в этом режиме устанавливается панель, в остальных только выставляется положение

  MyTaskBar.uCallbackMessage := WM_USER+777;  //Define my own Mesaage
  SHAppBarMessage(ABM_NEW, @MyTaskBar);
  SHAppBarMessage(ABM_SETPOS, @MyTaskBar);

  MyTaskBar.lParam:=LPARAM(True);
  SHAppBarMessage(ABM_ACTIVATE, @MyTaskBar);
  Sleep(300);

  SideBarOn := True;
  SWAR := Screen.WorkAreaRect;
end;

procedure TSAPTaskBar.SideBarPosChanged;
begin
//    SideBarRemove;
//    SideBarSet(SAlign);
  MyTaskBar.cbSize:= SizeOf(MyTaskBar);
  MyTaskBar.hWnd:=Self.Handle;
  GetWindowRect(Self.Handle, MyTaskBar.rc);
  SHAppBarMessage(ABM_SETPOS, @MyTaskBar);
  Sleep(300);
  swar := Screen.WorkAreaRect;
//  SHAppBarMessage(ABM_WINDOWPOSCHANGED, @MyTaskBar);
end;

procedure TSAPTaskBar.SideBarRemove;
begin
  if not SideBarOn then Exit;
  SHAppBarMessage(ABM_Remove, @MyTaskBar);

  SideBarOn := False;
end;

procedure TSAPTaskBar.SplitSAPWindowText(btn : TTaskBtn);
var
  str : String;

  sysid : String;
  mandt : String;
  modno : Integer;
  title : String;

  i: Integer;
  j: Integer;
  smodno : String;
  map : Boolean;
begin
  sysid := '';
  mandt := '';
  modno := 0;
  title := '';

  map := False;
  try
    str := GetControlText(btn.hw);

    i := Pos(')/', str);
    if i <= 0 then Exit;

    mandt := Copy(str, i+2, 3);
    title := Copy(str, i+6, 300);
    j := Pos('(',str);
    if (j = 0) or (j > i) then Exit;

    sysid := Copy(str, 1, j - 1);

    smodno := Copy(str, j + 1, i - j - 1);
    modno := StrToInt(smodno);
  finally
    map := btn.title <> title;

    btn.sysid:= Trim(sysid);
    btn.mandt:= Trim(mandt);
    btn.modno:= modno;
    btn.title:= Trim(title);
    btn.jdbmn:= isABAPDebugWin(sysid, title);
  end;

  if map then MapIcon(btn);
end;


procedure TSAPTaskBar.BtnMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MDPoint.X := X;
  MDPoint.Y := Y;
  BtnMoving := False;
end;

procedure TSAPTaskBar.BtnMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  d : Integer;
  btn : TTaskBtn;
begin
  if BigPreview then begin
    if (GetKeyState(VK_CONTROL) < 0) and (GetKeyState(VK_MENU) < 0)
    then PreviewShow(TTaskBtn(Sender))
    else PreviewEnd;
  end;

  if not (ssLeft in Shift) then Exit;

  btn := TTaskBtn(Sender);

  if Direct = dtHorizontal then begin
    d := X - MDPoint.X;

    if abs(d) > 5 then begin
      btn.BringToFront;
      BtnMoving := True;
    end;

    if BtnMoving then begin
      btn.Left := btn.Left + d;
      BtnMove(btn);
    end;
  end;

  if Direct = dtVertical then begin
    d := Y - MDPoint.Y;

    if abs(d) > 5 then begin
      btn.BringToFront;
      BtnMoving := True;
    end;

    if BtnMoving then begin
      btn.Top := btn.Top + d;
      BtnMove(btn);
    end;
  end;
end;

procedure TSAPTaskBar.BtnMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if BtnMoving then begin
    RefreshButtons;
    BtnMoving := False;
  end;
end;

procedure TSAPTaskBar.ShowSapGUI(btn : TTaskBtn);
procedure IntGetWindowRect(hw: HWND; var r: TRect);
var
  wp : TWindowPlacement;
  war : TRect;
begin
  if IsIconic(hw) then begin
    wp.length:= SizeOf(wp);
    GetWindowPlacement(hw, wp);
    r := wp.rcNormalPosition;
    war := Screen.WorkAreaRect;
    Inc(r.Top, war.Top);
    Inc(r.Bottom, war.Top);
    Inc(r.Left, war.Left);
    Inc(r.Right, war.Left);
  end
  else GetWindowRect(hw, r);
end;

var
  i : Integer;
  ctb : TTaskBtn;
  br : TRect;
  cr : TRect;
  ir : TRect;
begin
  if btn.Mark and (btn.GrpIndex > 0) then begin
    IntGetWindowRect(btn.hw, br);
    for i := 0 to TBList.Count - 1 do begin
      ctb := TTaskBtn(TBList[i]);
      if not ctb.Mark then Continue;
      if ctb.GrpIndex <> btn.GrpIndex then Continue;
      if ctb = btn then Continue;
      IntGetWindowRect(ctb.hw, cr);
      if not IntersectRect(ir, br, cr) then begin
        if not WindowIsTop(ctb.hw) then begin
          if IsIconic(ctb.hw)
          then MyShowWindow(ctb.hw, SW_RESTORE)
          else MySetForegroundWindow(ctb.hw);
        end;
      end;
    end;
  end;

  if IsIconic(btn.hw) then begin
    MyShowWindow(btn.hw, SW_RESTORE);
  end;

  MySetForegroundWindow(btn.hw);

  CheckWindowPos(btn.hw);
end;

procedure TSAPTaskBar.SaveLastRunWndList;
var
  i   : Integer;
  ctb : TTaskBtn;
  sl  : TStringList;
  j   : Integer;
  mi  : TMenuItem;
  ic  : String;
begin
  sl := TStringList.Create;
  for i := 0 to TBList.Count - 1 do begin
    ctb := TTaskBtn(TBList[i]);

    ic := '';
    if (ctb.IconImageIndex >= 0) and (ctb.IconMask = '') then begin
      for j := 0 to miIcons.Count - 1 do begin
        mi := miIcons.Items[j];
        if mi.ImageIndex <> ctb.IconImageIndex then Continue;
        ic := mi.Caption;
        Break;
      end;
    end;

    sl.Add('$' + IntToHex(ctb.hw,8) +'|'+ ctb.sysid +'|'+ ic);
  end;
  sl.SaveToFile(SelfDir + scLastRunWnd);
  sl.Free;
end;

procedure TSAPTaskBar.SetLastRunWndList;
var
  bl : TList;
  j : Integer;
  s : String;
  i : Integer;
  ctb : TTaskBtn;
  hw : HWND;
  sysid : String;

  ic : String;
  iii : Integer;
begin
  bl := TList.Create;
  try
    bl.Assign(TBList);

    TBList.Clear;

    for j := 0 to LastRunWndList.Count - 1 do begin;
      s := LastRunWndList[j];
      hw := HWND(StrToInt(ExtractWord(s, 1, '|', '00000000')));
      sysid := ExtractWord(s, 2, '|', '');
      ic := ExtractWord(s, 3, '|', '');

      iii := GetIconIndex(ic);

      for i := 0 to bl.Count - 1 do begin
        ctb := TTaskBtn(bl[i]);
        if ctb = nil then Continue;
        if (iii = -1) and (ctb.IconImageIndex <> - 1) and (ctb.IconMask <> '') then Continue;

        if (ctb.hw = hw) and (ctb.sysid = sysid) then begin
          TBList.Add(ctb);
          ctb.IconImageIndex:= iii;
          bl[i] := nil;
        end;
      end;
    end;

    for i := 0 to bl.Count - 1 do begin
      ctb := TTaskBtn(bl[i]);
      if ctb = nil then Continue;
//    ctb.Free;
      DeleteButton(ctb);
    end;
  finally
    bl.Free;
    LastRunWndList.Free;
    LastRunWndList := nil;
  end;

  RefreshButtons;
end;

procedure TSAPTaskBar.Terminate;
begin
  NotSave := True;
  Application.Terminate;
end;

procedure TSAPTaskBar.ReadSelfVersion;
var VISize:   cardinal;
    VIBuff:   pointer;
    trans:    pointer;
    buffsize: cardinal;
    temp: integer;
    str: pchar;
    LangCharSet: string;
    LanguageInfo: string;
    Filename : String;
    s : String;

  function GetStringValue(const From: string): string;
  begin
    VerQueryValue(VIBuff,pchar('\StringFileInfo\'+LanguageInfo+'\'+From), pointer(str),
                  buffsize);
    if buffsize > 0 then Result := str else Result := 'n/a';
  end;

begin
// Почти целеком взято сдесь http://www.delphimaster.ru/articles/versioninfo.html
  Filename := Paramstr(0);

  ProductName    := '';
  ProductVersion := '';
  FileVersion    := '';

  VIBuff := nil;
  if not fileexists(Filename) then raise EFilerError.Create('File not found: '+Filename);
  VISize := GetFileVersionInfoSize(pchar(Filename),buffsize);
  if VISize < 1 then raise EReadError.Create('Invalid version info record in file '+Filename);
  VIBuff := AllocMem(VISize);
  try
    GetFileVersionInfo(pchar(Filename),cardinal(0),VISize,VIBuff);

    VerQueryValue(VIBuff,'\VarFileInfo\Translation',Trans,buffsize);
    if buffsize >= 4 then
    begin
      temp:=0;
      StrLCopy(@temp, pchar(Trans), 2);
      LangCharSet:=IntToHex(temp, 4);
      StrLCopy(@temp, pchar(Trans)+2, 2);
      LanguageInfo := LangCharSet+IntToHex(temp, 4);
    end else raise EReadError.Create('Invalid language info in file '+Filename);

//  CompanyName      := GetStringValue('CompanyName');
//  FileDescription  := GetStringValue('FileDescription');
//  InternalName     := GetStringValue('InternalName');
//  LegalCopyright   := GetStringValue('LegalCopyright');
//  OriginalFilename := GetStringValue('OriginalFilename');
//  Comments         := GetStringValue('Comments');

    ProductName    := GetStringValue('ProductName');
    FileVersion    := GetStringValue('FileVersion');
    ProductVersion := GetStringValue('ProductVersion');
  finally
    FreeMem(VIBuff,VISize);
  end;

  s := fmOptions.meAbout.Lines.Text;
  s := Format(s, [ProductVersion]);
  fmOptions.meAbout.Lines.Text := s;
end;

procedure TSAPTaskBar.BtnClick(Sender: TObject);
var
  btn : TTaskBtn;
  i : Integer;
  ctb : TTaskBtn;
  d : Integer;
begin
  btn := TTaskBtn(Sender);
  if not btn.Down then Exit;

  ShowSapGUI(btn);

  if (CurStepNum = 0) or (btn.StepNum <> CurStepNum) then begin
    Inc(CurStepNum);
    btn.StepNum:= CurStepNum;

    if Self.BtnData.HistShow then begin
      for i := 0 to TBList.Count - 1 do begin
        ctb := TTaskBtn(TBList[i]);
        if not ctb.Visible then Continue;
        d := CurStepNum - ctb.StepNum;
        if (ctb.StepNum > 0) and (d > 0) and (d < StepHistoryLength) then ctb.Invalidate;
      end;
    end;
  end;
end;

procedure TSAPTaskBar.BtnMouseLeave(Sender: TObject);
begin
  PreviewEnd;
end;

procedure TSAPTaskBar.BtnMarkChange(Sender: TObject);
var
  i : Integer;
  ctb : TTaskBtn;
  MaxNum : Integer;
  ImageIndex : Integer;
begin
  ctb := TTaskBtn(Sender);
  if not  ctb.Mark then Exit;

  ctb.MarkImageIndex:= btnGroupAction.ImageIndex;

  ImageIndex := ctb.MarkImageIndex;

  MaxNum := 0;
  for i := 0 to TBList.Count - 1 do begin
    ctb := TTaskBtn(TBList[i]);

    if not ctb.Mark then Continue;
    if ctb.MarkImageIndex <> ImageIndex then Continue;

    if MaxNum < ctb.MarkNum then MaxNum := ctb.MarkNum;
  end;

  ctb := TTaskBtn(Sender);
  if ctb.Mark and (ctb.MarkNum = 0) then ctb.MarkNum:= MaxNum + 1;
end;

procedure TSAPTaskBar.BtnPopUp(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
var
  btn : TTaskBtn;
  ct  : Integer;

  i   : Integer;
  ctb : TTaskBtn;
begin
  btn := TTaskBtn(Sender);

  ct := 0;
  if btn.Mark then begin
    for i := TBList.Count - 1 downto 0 do begin
      ctb := TTaskBtn(TBList[i]);
      if not ctb.Mark then Continue;
      if ctb.MarkImageIndex <> btn.MarkImageIndex then Continue;
      Inc(ct);
    end;
  end;
  miGatherGroup.Visible:= ct > 1;

  ppmButton.Tag:= Ptrint(btn);
end;

procedure TSAPTaskBar.BtnShowHint(Sender: TObject; HintInfo: PHintInfo);
var
  tb : TTaskBtn;
begin
  tb := TTaskBtn(Sender);
  HintInfo.HintStr:= tb.title +#13+
            tb.sttxt +#13+
            tb.sysid +' '+ tb.mandt +' '+ IntToStr(tb.modno) +#13+
            tb.sys.connm +#13+
            tb.sys.desc +#13+
            tb.Hint;
  tb.ShowHint:= True;
end;

procedure TSAPTaskBar.FormHide(Sender: TObject);
var
  i : Integer;
  ctb : TTaskBtn;
begin
  if fmPlug <> nil then begin
    ShowWindow(fmPlug.Handle, SW_HIDE); // Странно, почемуто не срабатывает fmPlug.Hide
  end;

  if not btnHide.Visible then Exit;

  if ShowTBinWTBwhenSTBHide then begin
    for i := 0 to TBList.Count - 1 do begin;
      ctb := TTaskBtn(TBList[i]);
      if not ctb.Visible then MyShowWindow(ctb.hw, SW_SHOW);
      ShowTaskButton(ctb.hw);
    end;
  end
  else begin
    if HideSapGuiTaskBtn then begin
      for i := 0 to TBList.Count - 1 do begin;
        ctb := TTaskBtn(TBList[i]);
        MyShowWindow(ctb.hw, SW_HIDE);
      end;
    end
    else begin
      for i := 0 to TBList.Count - 1 do begin;
        ctb := TTaskBtn(TBList[i]);
        if not ctb.Visible then MyShowWindow(ctb.hw, SW_SHOW);
      end;
    end;
  end;
end;

procedure TSAPTaskBar.FormShow(Sender: TObject);
var
  i : Integer;
  ctb : TTaskBtn;
begin
  SetPlug;

  for i := 0 to TBList.Count - 1 do begin;
    ctb := TTaskBtn(TBList[i]);
    if ctb.Visible
    then MyShowWindow(ctb.hw, SW_SHOWNA)
    else MyShowWindow(ctb.hw, SW_HIDE);
    if HideSapGuiTaskBtn then HideTaskButton(ctb.hw);
  end;
end;

procedure TSAPTaskBar.miAutoHideClick(Sender: TObject);
begin
  if PanelMode = oppmAlignToTaskBar then Exit;

  if miAutoHide.Checked
  then PanelMode := oppmAutoHide
  else PanelMode := oppmLikeTaskBar;

  ApplyOptions;
end;

procedure TSAPTaskBar.miAddIconFromFileClick(Sender: TObject);
var
  mi : TMenuItem;
begin
  mi := LoadIconFromFile;
  if mi = nil then Exit;

  miIconSelectClick(mi);
end;

procedure TSAPTaskBar.BtnMove(btn: TTaskBtn);
var
  i : Integer;
  d : Integer;
  j : Integer = -1;

  ctb : TTaskBtn;
  tb : TTaskBtn;

  l : Integer;
  t : Integer;
begin
  tb := nil;
  if Direct = dtVertical then begin
    d := ThumbHeight div 2;
    for i := 0 to TBList.Count - 1 do begin;
      ctb := TTaskBtn(TBList[i]);
      if ctb = btn then Continue;
      if not ctb.Visible then Continue;

      if ( (ctb.Top < btn.Top) and (ctb.Top + d > btn.Top) )
      or ( (ctb.Top + d < btn.Top + ThumbHeight) and (ctb.Top + ThumbHeight > btn.Top + ThumbHeight) )
      then begin
        tb := ctb;
        j := i;
        Break;
      end;
    end;
  end;

  if Direct = dtHorizontal then begin
    d := ThumbWidth div 2;
    for i := 0 to TBList.Count - 1 do begin;
      ctb := TTaskBtn(TBList[i]);
      if not ctb.Visible then Continue;

      if (ctb.Left < btn.Left) and (ctb.Left + d >= btn.Left)
      or ( (ctb.Left + d < btn.Left + ThumbWidth) and (ctb.Left + ThumbWidth > btn.Left + ThumbWidth) )
      then begin
        tb := ctb;
        j := i;
        Break;
      end;
    end;
  end;
  if tb = nil then Exit;

  i := TBList.IndexOf(btn);

  TBList[j] := btn;
  TBList[i] := tb;

  l := btn.Left;
  t := btn.Top;
  RefreshBtnPos;
  btn.Left := l;
  btn.Top  := t;
end;

procedure TSAPTaskBar.GetBtnGlyph(btn: TTaskBtn; ex : Boolean);
var
  tdif: Double;
begin
  if IsIconic(btn.hw) then Exit;

  if btn.ftime <> 0 then begin
    tdif := (Now - btn.ftime) * 86400;
    if tdif < 2 then Exit; // 2 секунды от момента обноружения окна
    btn.ftime := 0;
    if not IsWindowVisible(btn.hw) then MyShowWindow(btn.hw, SW_SHOWNA);
    if MaximizeNewWin then begin
      ShowWindowAsync(btn.hw, SW_MAXIMIZE);
      Sleep(300);
      PostMessage(btn.hw, WM_PAINT, 0, 0); // Боремся с глюком перерисовки GUI
    end;
    CheckWindowPos(btn.hw);
    if HideSapGuiTaskBtn then HideTaskButton(btn.hw);
  end;

  WaitForSingleObject(CMutex, INFINITE);
  try
    btn.ExPrint:= ex;
    if CTBList.IndexOf(btn) < 0 then CTBList.Add(btn); // Добавляем кнопку в очередь на обработку для потока
  finally
    ReleaseMutex(CMutex);
  end;

//  GetBtnGlyphEx(btn, ex); // Вызывается из потока
end;

// Вызывается только из потока
procedure TSAPTaskBar.GetBtnGlyphEx(btn: TTaskBtn; ex : Boolean);
var
  r : TRect;
  str : String;
  i : Integer;
  dy : Integer;
  dx : Integer;
begin
  if IsIconic(btn.hw) then Exit;
  for i := 0 to 3 do begin
    dbmp.FillRect(0, 0, dbmp.Width, dbmp.Height, Color32(btn.Color));
    if GetWindowScreenShot(btn.hw, ex) then begin
      if BigPreview then MakeBigScreenShot(btn);
      Break;
    end;
    if IsIconic(btn.hw) then Exit;
    Sleep(100);
  end;

  GetWindowRect(btn.hw, r{%H-});

  if (btn.sys <> nil) and (btn.sys.Color = TColor(0)) then begin
    SetSysColor(btn.sys, CalcSystemColor(sbmp) );
  end;

  dx := 0; dy := 0;
  if SAlign = alTop   then dy := 8; // Если выравнивание к верху текст надо писать чуть повыше
  if SAlign = alRight then dx := 16;

  if DrawSapSys then begin
    dbmp.Textout(3 + dx, dbmp.Height - 46 - dy, btn.sys.desc);
  end;

  if DrawSapTitle and (btn.title <> '') then begin
    str := GetControlText(btn.hw);
    i := Pos(')/', str);
    if i > 0
    then btn.title := Copy(str, i+6, 300)
    else btn.title := str;

    dbmp.Textout(3+ dx, dbmp.Height - 20 - dy, btn.title);
  end;

  btn.Glyph.Width  := ImageRect.Right;
  btn.Glyph.Height := ImageRect.Bottom;

  dbmp.DrawTo(btn.Glyph);
  btn.Invalidate;
end;

function TSAPTaskBar.CalcSystemColor(bmp : TBitmap32): TColor;
var
  dbmp : TBitmap32;
begin
  dbmp := TBitmap32.Create;
  dbmp.Width := 6;
  dbmp.Height:= 6;

  SetStretchBltMode(dbmp.Canvas.Handle, STRETCH_HALFTONE);//устанавливаем режим сглаживания
  StretchBlt(dbmp.Canvas.Handle, 0, 0, 5, 5, sbmp.Canvas.Handle, 0, 0, sbmp_w,  sbmp_h, cmSrcCopy);

  Result := dbmp.Canvas.Pixels[1, 4];

  dbmp.Free;
end;

// Проверяем есть ли окна перекрвыющее наше суммарно более чем на 5%
function WindowIsTop(hw : HWND): Boolean;
var
  r   : TRect;
  chw : HWND;
  cr  : TRect;
  p   : Integer;
  ir  : TRect;
  ip  : Integer;
  k   : Integer;
  cname : String;
begin
  Result := False;

  if not IsWindowVisible(hw) then Exit;
  if IsIconic(hw) then Exit;

  if not GetWindowRect(hw, r) then Exit;
  p := (r.Right - r.Left) * (r.Bottom - r.Top);

  ip := 0;
  chw := 0;

  while True do begin
    if chw = 0
    then chw := GetTopWindow(0)
    else chw := GetNextWindow(chw, GW_HWNDNEXT);

//    chw := FindWindowEx(0, chw, nil, nil);

    if chw = 0 then Exit; // Косяк, не нашли наше окно в z-order
    if chw = hw then Break;
    if not IsWindowVisible(chw) then Continue;
    if not GetWindowRect(chw, cr) then Exit;

    if not IntersectRect(ir, r, cr) then Continue;

    cname := GetWndClassName(chw);
    if cname = '#32771' then Exit; // The class for the task switch window.
    if cname = 'Windows.UI.Core.CoreWindow' then Continue; // прозрачное окно над всем экраном

    ip := ip + (ir.Right - ir.Left) * (ir.Bottom - ir.Top);
    if p < ip then Exit;
  end;

  if chw <> hw then Exit;

  k := (ip * 100) div p;
  Result := k <= 5;
end;

procedure TSAPTaskBar.PrintWindowMy(hw: HWND; w, h: Integer; ex : Boolean);
var
  dc : HDC;
begin
// PrintWindowMode: 0 - PW + Redraw, 1 - PW, 2 - PW + Option, 3 - Copy from screen

  if AeroEnabled or (ex and WindowIsTop(hw)) then begin // Under DWM (Aero) each window has its own surface backed up by GPU memory. Without DWM, that is under classic renderer, all pixels covered by another window are simply discarded
    dc := GetWindowDC(hw);
    BitBlt(sbmp.Canvas.Handle, 0, 0, w, h, DC, 0, 0, SRCCOPY); // Копируем с экрана
    ReleaseDC(hw, dc) ;
    Exit;
  end;

  if PrintWindowMode = 0 then begin
    PrintWindow(hw, sbmp.Canvas.Handle, 0);
    // Исправляем глюки от PrintWindow, рисуем то что получили обратно в окно, как это ни удивительно - помогает
    dc := GetWindowDC(hw);
    BitBlt(dc, 0, 0, w, h, sbmp.Canvas.Handle, 0, 0, SRCCOPY);
    ReleaseDC(hw, dc);
    Exit;
  end;

  if PrintWindowMode = 1 then begin
    PrintWindow(hw, sbmp.Canvas.Handle, 0);
    Exit;
  end;

  if PrintWindowMode = 2 then begin
    PrintWindow(hw, sbmp.Canvas.Handle, 2); // Загадочная не описаная в msdn опция
    Exit;
  end;

  if PrintWindowMode = 3 then begin
    dc := GetWindowDC(hw);
    BitBlt(sbmp.Canvas.Handle, 0, 0, w, h, DC, 0, 0, SRCCOPY); // Копируем с экрана
    ReleaseDC(hw, dc) ;
    Exit;
  end;

  if PrintWindowMode = 4 then begin // С пердварительной блокировкой LockWindowUpdate
    LockWindowUpdate(hw);
    try
      PrintWindow(hw, sbmp.Canvas.Handle, 0);
    finally
      LockWindowUpdate(0);
    end;
    Exit;
  end;

  if PrintWindowMode = 5 then begin // С пердварительной блокировкой WM_SETREDRAW
    SendMessage(h, WM_SETREDRAW, 0, 0);
    try
      PrintWindow(hw, sbmp.Canvas.Handle, 0);
    finally
      SendMessage(h, WM_SETREDRAW, 1, 0);
    end;
    Exit;
  end;
end;

function TSAPTaskBar.GetWindowScreenShot(hw : HWND; ex : Boolean):Boolean;
var
  r  : TRect;
  w  : Integer;
  h  : Integer;
  dr : TRect;
  hn : Integer;
  wn : Integer;
  d  : Integer;

  x : Integer;
  y : Integer;
  c : PColor32;
  ct : Integer;
begin
  Result := false;

  GetWindowRect(hw, r{%H-});
  w := r.Right - r.Left + 1;
  h := r.Bottom - r.Top + 1;
  if (w <= 0) or (h <= 0) then Exit;

  if sbmp.Width  < w then sbmp.Width  := w;
  if sbmp.Height < h then sbmp.Height := h;

  sbmp_w := w;
  sbmp_h := h;

  PrintWindowMy(hw, w, h, ex);

  r.Left   := 0;
  r.Top    := 0;
  r.Right  := w - 1;
  r.Bottom := h - 1;

  wn := dbmp.Width;
  hn := (wn * h) div w;
  if hn <= dbmp.Height then begin
    d  := (dbmp.Height - hn) div 2;
    dr := Rect(0, d, dbmp.Width, dbmp.Height - d);
  end
  else begin
    hn := dbmp.Height;
    wn := (hn * w) div h;

    d  := (dbmp.Width - wn) div 2;
    dr := Rect(d, 0, dbmp.Width - d, dbmp.Height);
  end;

  SetStretchBltMode(dbmp.Canvas.Handle, STRETCH_HALFTONE);//устанавливаем режим сглаживания
  StretchBlt(dbmp.Canvas.Handle, dr.Left, dr.Top, dr.Right - dr.Left, dr.Bottom - dr.Top,
             sbmp.Canvas.Handle,  r.Left,  r.Top,  r.Right -  r.Left,  r.Bottom  - r.Top, cmSrcCopy);

// Проверим на наличие глюков PrintWindow
  ct := 0;
  for y := 0 to dbmp.Height - 1 do begin
  for x := 0 to dbmp.Width  - 1 do begin
    c := dbmp.PixelPtr[x, y];
    if Integer(c^) = 0 then Inc(ct);
  end;
  end;

  Result :=  ct < ((dbmp.Width * dbmp.Height) div 20);
end;

procedure TSAPTaskBar.TimerTimer(Sender: TObject);
var
  fhw : HWND;
  WindowClass : String;
  i : Integer;
  ctb : TTaskBtn;
  ptb : TTaskBtn = nil;
  dtb : TTaskBtn;
  ftb : TTaskBtn;
  found : Boolean;
  rn :Boolean;

  mp : TPoint;
  r  : TRect;
begin
  if CheckTiks = 1 then begin
  end;
  Dec(CheckTiks);
  if CheckTiks <= 0 then CheckTiks := 3000; // 15 минут, это только попытка, проверка выполняется не чаще чем раз в сутки

  if Tiks = 0 then begin
    RefreshButtons;

    if Self.Visible then begin
      r := Screen.WorkAreaRect;
      if not CompareMem(@r, @SWAR, SizeOf(TRect)) then begin
        SWAR := r;
        ApplyOptions;
      end;
    end;

    // Прячем свою кнопку в TaskBar-e
    if HideTaskBtn then begin
      HideTaskButton(AppHandle);
    end;

    // Прячем кнопку SAPLogon в TaskBar-е
    if HideSapLogonTaskBtn then begin
      HideTaskButton(GetSapLogonWnd);
    end;
  end;
  Inc(Tiks);
  if Tiks >= 10 then Tiks := 0;

  if WaitSap and (TBList.Count > 0) then begin  // Пора просыпаться
    WaitSap := False;
    Self.Visible := True;
    miShow.Visible := False;
    miHide.Visible := True;
    ApplyOptions;
    RefreshScreenShots;
  end;
  if WaitSap and (TBList.Count = 0) then begin  // Продолжаем спать
    Exit;
  end;
  if (TBList.Count = 0) and HideIfNoSap and (not WaitSap)  then begin // Засыпаем
    BtnHideClick(Self);
    WaitSap := True;
    Timer.Enabled := True;
    Exit;
  end;

  PreviewEnd;

  if (PanelMode = oppmAlignToTaskBar) or (PanelMode = oppmAutoHide) then begin
    Dec(HideTiker);
    if HideTiker <= 0 then begin
      GetCursorPos(mp{%H-});
      GetWindowRect(Self.Handle, r{%H-});
      if PtInRect(r, mp)
      then HideTiker := 4
      else begin
        if (PanelMode = oppmAlignToTaskBar) and (not IsIconic(Self.Handle))
        then Application.Minimize;
        if (PanelMode = oppmAutoHide) and (Self.Visible)
        then AutoHide;
      end;
    end;
  end;

  if sizing > 0 then begin // plAreaResize
    if sizing = 1 then begin
      sizing := 0;
      SideBarPosChanged;
      RefreshScreenShots;
    end
    else Dec(sizing);
  end;

  if LogonBtn then begin
    RefreshSysCount;

    found := False;
    rn := False;
    for i := TBList.Count - 1 downto 0 do begin
      ctb := TTaskBtn(TBList[i]);
      if (ctb.mandt = ZeroMandt) and (ctb.modno = 1) then begin
        SplitSAPWindowText(ctb);
        if (ctb.mandt <> ZeroMandt) or (ctb.modno <> 1) then begin // Вошли в систему
          Dec(ctb.sys.Count);
          if ctb.sys.Count = 0 then begin
            SysList.Remove(ctb.sys);
            Dispose(ctb.sys);
            ctb.sys := nil;
          end;

          TBList.Delete(i);
//        ctb.Free;
          DeleteButton(ctb);
          rn := True;
        end
        else found := True;
      end;
    end;
    LogonBtn := found;
    if rn then RefreshButtons;
  end;

  if InvalidSysName then begin
    found := False;
    rn := False;
    for i := TBList.Count - 1 downto 0 do begin
      ctb := TTaskBtn(TBList[i]);
      if (ctb.sysid = '') or (ctb.mandt = '') then begin
        SplitSAPWindowText(ctb);
        if (ctb.sysid <> '') and (ctb.mandt <> '') then begin
          Dec(ctb.sys.Count);
          if ctb.sys.Count = 0 then begin
            SysList.Remove(ctb.sys);
            Dispose(ctb.sys);
            ctb.sys := nil;
          end;

          TBList.Delete(i);
//        ctb.Free;
          DeleteButton(ctb);
          rn := True;
        end
        else found := True;
      end;
    end;
    InvalidSysName := found;
    if rn then RefreshButtons;
  end;

  for i := 0 to TBList.Count - 1 do begin
    ctb := TTaskBtn(TBList[i]);
    if ctb.ftime <> 0 then GetBtnGlyph(ctb, False);
  end;
  
  fhw := GetForegroundWindow;
  WindowClass := GetWndClassName(fhw);
  if WindowClass <> SapWindowClass then begin
    hwCur := 0;
    if WindowClass <> 'Window' then BtnUnDown;
    Exit;
  end;

  if hwCur <> fhw then begin
    hwCur := fhw;
    Exit; // Обработаем на следующем проходе, задержка нужна чтоб правльно взять картинку
  end;

  dtb := nil;
  for i := 0 to TBList.Count - 1 do begin
    ctb := TTaskBtn(TBList[i]);
    if not ctb.Down then Continue;
    dtb := ctb;
    Break;
  end;

  ftb := nil;
  for i := 0 to TBList.Count - 1 do begin
    ctb := TTaskBtn(TBList[i]);
    if ctb.hw <> fhw then Continue;

    if (ctb <> dtb) and (dtb <> nil) then begin
      PrevBtn := dtb;
      PrevBtnTiks := 15;
    end;
    if ctb = PrevBtn then PrevBtn := nil;

    ftb := ctb;

    GetBtnGlyph(ftb, True);

    if HideSapGuiTaskBtn then HideTaskButton(ctb.hw);
    ctb.Down := True;
    Break;
  end;

  if ftb = nil then RefreshButtons;

  if GetGlyphTiks = 0 then begin
    if TBList.Count > 0 then begin
      Inc(GetGlyphIndex);
      if GetGlyphIndex >= TBList.Count then GetGlyphIndex := 0;
      ptb := TTaskBtn(TBList[GetGlyphIndex]);
      if ptb <> ftb then GetBtnGlyph(ptb, True);
    end;
  end;
  Inc(GetGlyphTiks);
  if GetGlyphTiks >= 3 then GetGlyphTiks := 0;

  if (PrevBtn <> nil) and (TBList.IndexOf(PrevBtn) >= 0) then begin
    Dec(PrevBtnTiks);
    case PrevBtnTiks of
      0 : PrevBtn := nil;
      3, 6, 9, 12: if PrevBtn <> ptb then GetBtnGlyph(PrevBtn, True);
    end;
  end;
end;

// Блокируем минимизацию окна
procedure TSAPTaskBar.WMShowWindow(var Msg: TWMShowWindow);
begin
  if not Msg.Show
  then Msg.Result := 0
  else inherited;
end;

procedure TSAPTaskBar.WM_MyMouseWheel(var M: TMessage);
var
  i : SmallInt;
  WheelDelta: Integer;
  v : Integer;
  lv : Integer;
begin
  i := M.LParamHi;
  WheelDelta := i div 2;

  if Direct = dtVertical then begin
    v := plTasks.Top + WheelDelta;

    if ScrollLimitInCentre then begin
      lv := plArea.Height div 2;
      if plTasks.Height < lv then begin
        if v < 0 then v := 0;
        if (v + plTasks.Height ) > plArea.Height then v := plArea.Height - plTasks.Height;
      end
      else begin
        if (v + plTasks.Height ) < lv then v := lv - plTasks.Height;
        if  v > lv then v := lv;
      end;
    end
    else begin
      if plTasks.Height < plArea.Height then v:= 0;
      if v > 0 then v := 0;
      if (plTasks.Height >= plArea.Height) and ((v + plTasks.Height) < plArea.Height) then v := plArea.Height - plTasks.Height;
    end;

    plTasks.Top := v;
  end;

  if Direct = dtHorizontal then begin
    v := plTasks.Left + WheelDelta;

    if ScrollLimitInCentre then begin
      lv := plArea.Width div 2;
      if plTasks.Width < lv then begin
        if v < 0 then v := 0;
        if (v + plTasks.Width ) > plArea.Width then v := plArea.Width - plTasks.Width;
      end
      else begin
        if (v + plTasks.Width ) < lv then v := lv - plTasks.Width;
        if  v > lv then v := lv;
      end;
    end
    else begin
      if plTasks.Width < plArea.Width then v:= 0;
      if v > 0 then v := 0;
      if (plTasks.Width >= plArea.Width) and ((v + plTasks.Width) < plArea.Width) then v := plArea.Width - plTasks.Width;
    end;

    plTasks.Left := v;
  end;
end;

procedure TSAPTaskBar.WM_MyMouseMove(var M: TMessage);
var
  wr : TRect;
  x : Integer;
  y : Integer;

  d : Integer;
begin
  if not ((PanelMode = oppmAutoHide) and not Self.Visible) then Exit;

  GetWindowRect(Self.Handle, wr);
  x := GET_X_LPARAM(M.lParam);
  y := GET_Y_LPARAM(M.lParam);

  case SAlign of
    alLeft   : d := x - wr.Left;
    alTop    : d := y - wr.Top;
    alRight  : d := wr.Right - x;
    alBottom : d := wr.Bottom - y;
    else Exit;
  end;
  if (d < 0) or (d > AutoShowWidth) then Exit;

  Self.Show;
  RefreshButtons;
end;

procedure TSAPTaskBar.WM_MyKey(var M: TMessage);

procedure ShowSAPWindows(nCmdShow:longint);
var
  ctb : TTaskBtn;
  i : Integer;
begin
  for i := 0 to TBList.Count - 1 do begin
    ctb := TTaskBtn(TBList[i]);
    if not IsWindowVisible(ctb.hw) then Continue;

    MyShowWindow(ctb.hw, nCmdShow);
  end;
end;

procedure CheckAndShowPreview;
var
  pt   : TPoint;
  r    : TRect;
  Control : TControl;
begin
  GetCursorPos(pt);
  GetWindowRect(Self.Handle, r);
  if PtInRect(r, pt) then begin
    pt :=Self.plTasks.ScreenToClient(pt);
    Control := Self.plTasks.ControlAtPos(pt, False);
    if Control is TTaskBtn then PreviewShow(TTaskBtn(Control));
  end;
end;

procedure SetFocusToOkCodeWin;
var
  fgd_hwnd: HWND;
  afx_wnd : HWND;
  cb_wnd  : HWND;
  ed_wnd  : HWND;
begin
  fgd_hwnd := GetForegroundWindow;
  if fgd_hwnd = 0 then Exit;

  if GetWndClassName(fgd_hwnd) <> SapWindowClass then Exit;

  afx_wnd := GetWindow(fgd_hwnd, GW_CHILD); // Afx:...
  if afx_wnd = 0 then Exit;

  cb_wnd := GetWindow(afx_wnd, GW_CHILD); // ComboBox
  if cb_wnd = 0 then Exit;

  ed_wnd := GetWindow(cb_wnd, GW_CHILD); // Edit
  if GetWndClassName(ed_wnd) <> 'Edit' then Exit;

  if GetWndClassName(cb_wnd) <> 'ComboBox' then Exit;

  PostMessage(cb_wnd, WM_SETFOCUS, 0, 0);
end;

var
  Down : Boolean;
begin
  Down := (M.lParam and $80000000) = 0;

// Если ранее было зафиксировано нажатие клавиш, проверяем ещё раз, нажытыли они всё ещё
  if KeyDown_Win  then KeyDown_Win  := KeyIsDown(VK_LWIN) or KeyIsDown(VK_RWIN);
  if KeyDown_Ctrl then KeyDown_Ctrl := KeyIsDown(VK_CONTROL);
  if KeyDown_Alt  then KeyDown_Alt  := KeyIsDown(VK_MENU);

  case M.wParam of
    VK_LWIN,
    VK_RWIN   : KeyDown_Win  := Down;
    VK_CONTROL: KeyDown_Ctrl := Down;
    VK_MENU   : KeyDown_Alt  := Down;
    VK_M      : if KeyDown_Win and not Down then ShowSAPWindows(SW_MINIMIZE);
    191       : if KeyDown_Ctrl and Down then SetFocusToOkCodeWin; // "/"
  end;

  if (KeyDown_Alt and KeyDown_Ctrl) and ((M.wParam = VK_MENU) or (M.wParam = VK_CONTROL)) and Down then begin
    if not Self.BtnData.HistShow then begin
      Self.BtnData.HistShow := True;
      Self.plTasks.Invalidate;
    end;

    CheckAndShowPreview;
  end;

  if not Down and ((M.wParam = VK_MENU) or (M.wParam = VK_CONTROL)) then begin
    if Self.BtnData.HistShow and not ShowStepHistory then begin
      Self.BtnData.HistShow := ShowStepHistory;
      Self.plTasks.Invalidate;
    end;

    if fmPreview.Visible then PreviewEnd;
  end;

//  meLog.Lines.Add(IntToHex(M.lParam, 8) +' | '+ IntToHex(M.wParam, 8));
end;

procedure TSAPTaskBar.WM_MyExitSizeMove(var M: TMessage);

procedure CheckSide(b, nb: Integer; var s : Integer; bmin, bmax, smin, smax: Integer; var rmv: Boolean);
begin
  if abs(b - s) > 3 then Exit;
  if smax <= bmin then Exit;
  if smin >= bmax then Exit;

  s := nb;
  rmv := True;
end;

procedure CheckAndSet(m : Integer; obr, nbr, sr : TRect; tb : TTaskBtn);
var
  mv : Boolean;
begin
  if m = 0 then Exit;

  mv := False;
  case m of
    1: CheckSide(obr.Left,   nbr.Left, sr.Right, obr.Top, obr.Bottom, sr.Top, sr.Bottom, mv); // Move left   side
    2: CheckSide(obr.Top,    nbr.Top, sr.Bottom, obr.Left, obr.Right, sr.Left, sr.Right, mv); // Move top    side
    4: CheckSide(obr.Right,  nbr.Right, sr.Left, obr.Top, obr.Bottom, sr.Top, sr.Bottom, mv); // Move right  side
    8: CheckSide(obr.Bottom, nbr.Bottom, sr.Top, obr.Left, obr.Right, sr.Left, sr.Right, mv); // Move bottom side
  end;
  if not mv then Exit;

  MySetWindowPos(tb.hw, sr);

  tb.intMark := 1; // Требуется обработка изменения размеров
end;

var
  i : Integer;
  ctb : TTaskBtn;
  btn : TTaskBtn;
  gr  : TRect;
  nr  : TRect;
  cr  : TRect;
  k   : Integer;
  found : Boolean;
  XM : TMessage;
begin
  btn := nil;
  for i := 0 to TBList.Count - 1 do begin
    ctb := TTaskBtn(TBList[i]);
    if not ctb.Visible then Continue;

    if LongWord(ctb.hw) = LongWord(m.wParam) then begin
      btn := ctb;
      Break;
    end;
  end;
  if btn = nil then Exit;
  if btn.GrpIndex <= 0 then Exit;

  if M.lParam = 0 then begin
    for i := 0 to TBList.Count - 1 do begin
      ctb := TTaskBtn(TBList[i]);
      if ctb.GrpIndex <> btn.GrpIndex then Continue;
      ctb.intMark:= 0;
    end;
  end;

  gr := btn.GrpRect; // Старые размеры
  GetWindowRect(btn.hw, nr); // Новые размеры

  k := 0;
  if nr.Left   <> gr.Left   then k := k or 1; // 0001
  if nr.Top    <> gr.Top    then k := k or 2; // 0010
  if nr.Right  <> gr.Right  then k := k or 4; // 0100
  if nr.Bottom <> gr.Bottom then k := k or 8; // 1000

  case k of
    1, 2, 4, 8, 3, 6, 9, 12 : begin end; // Изменение размеров
    else Exit; // Перемещение
  end;

  for i := 0 to TBList.Count - 1 do begin
    ctb := TTaskBtn(TBList[i]);
    if ctb.GrpIndex <> btn.GrpIndex then Continue;
    if ctb = btn then Continue;
    if not ctb.Visible then Continue;
    if ctb.intMark = 2 then Continue;

    GetWindowRect(ctb.hw, cr);

    CheckAndSet(k and 1, gr, nr, cr, ctb);
    CheckAndSet(k and 2, gr, nr, cr, ctb);
    CheckAndSet(k and 4, gr, nr, cr, ctb);
    CheckAndSet(k and 8, gr, nr, cr, ctb);
  end;

  btn.GrpRect := nr;
  btn.intMark := 2; // Обработка изменения размеров завершена

  if M.lParam <> 0 then Exit;

  while True do begin
    found := False;
    for i := 0 to TBList.Count - 1 do begin
      ctb := TTaskBtn(TBList[i]);
      if ctb.GrpIndex <> btn.GrpIndex then Continue;
      if ctb.intMark <> 1 then Continue;

      found := True;
      XM.wParam:= ctb.hw;
      XM.lParam:= 1;
      WM_MyExitSizeMove(XM);
    end;

    if not found then Break;
  end;

  for i := 0 to TBList.Count - 1 do begin
    ctb := TTaskBtn(TBList[i]);
    if ctb.GrpIndex <> btn.GrpIndex then Continue;
    if ctb.intMark <> 2 then Continue;

    GetBtnGlyph(ctb, False);
  end;
end;

procedure TSAPTaskBar.WMWindowPosChanging(var Message: TWMWindowPosChanging);
function CheckSize(w, h: Integer): Boolean;
begin
  Result := (w >= LowLimitThumbSize) and (h >= LowLimitThumbSize)
end;

begin
  if Assigned(Self.plArea.OnResize) then begin;
    with Message.WindowPos^ do begin
      if (flags and SWP_NOSIZE = 0) and not CheckSize(cx, cy)
      then flags := flags or SWP_NOSIZE;
    end;
  end;

  inherited;
end;

procedure TSAPTaskBar.WM_NCHITest(var Message: TMessage);
begin
  inherited;

  case Message.Result of
    HTTOPLEFT, HTTOPRIGHT, HTBOTTOMLEFT, HTBOTTOMRIGHT : begin
      Message.Result := HTCLIENT;
      Exit;
    end;
  end;

  if not LockChangeSize then begin
    case SAlign of
      alLeft:
        case Message.Result of
          HTLEFT, HTBOTTOM, HTTOP   : Message.Result := HTCLIENT;
        end;
      alTop:
        case Message.Result of
          HTLEFT, HTRIGHT, HTTOP    : Message.Result := HTCLIENT;
        end;
      alRight:
        case Message.Result of
          HTRIGHT, HTBOTTOM, HTTOP  : Message.Result := HTCLIENT;
        end;
      alBottom:
        case Message.Result of
          HTLEFT, HTRIGHT, HTBOTTOM : Message.Result := HTCLIENT;
        end;
    end;
    Exit;
  end;

  case Message.Result of
    HTLEFT, HTRIGHT, HTBOTTOM, HTTOP : Message.Result := HTCLIENT;
  end;
end;

function ExtractWord(const S : String; WordNum : Integer; const Separator : String; const DefValue : String = ''): String;
  function ExtractWord_(const S : String; WordNum : Integer; const Separator : String): String;
  var
    Cur : PChar;
    i : Integer;
    j : Integer;
    sl : Integer;
  begin
    Result := '';
    Cur := PChar(S);
    j := WordNum;
    sl := Length(Separator);
    while True do begin
      if j = 1 then Break;
      i := Pos(Separator, Cur);
      if i = 0 then Break;
      Cur := Cur + (i + sl - 1);
      Dec(j);
    end;
    if j <> 1 then Exit;

    i := Pos(Separator, Cur);
    if i = 0 then begin
      Result := Trim(Cur);
      Exit;
    end;

    Result := Trim(Copy(Cur, 1, i - 1));
  end;
begin
  Result := ExtractWord_(S, WordNum, Separator);
  if Result = '' then Result := DefValue;
end;

procedure TSAPTaskBar.LoadSys;
var
  fini : String;
  sl : TStringList;
  i: Integer;
  s : Utf8String;
  sys : PSapSys;
begin
  fini := SelfDir + scSapSys;
  if not FileExists(fini) then Exit;

  sl := TStringList.Create;
  sl.LoadFromFile(fini);

  for i := 0 to sl.Count -1 do begin
    s := sl[i];
    New(sys);
    FillChar(sys^, SizeOf(sys^), 0);
    
    sys.Name  := ExtractWord(s, 1, #9);
    sys.Color := TColor(StrToInt(ExtractWord(s, 2, #9, '0')));
    sys.Login := ExtractWord(s, 3, #9);
    sys.desc  := ExtractWord(s, 4, #9);
    sys.connm := ExtractWord(s, 5, #9);
    sys.Lang  := ExtractWord(s, 6, #9);
    sys.PassIndex := StrToInt(ExtractWord(s, 7, #9, '0'));
    sys.IconName  := ExtractWord(s, 8, #9);
    sys.IconIndex := GetIconIndex(sys.IconName);
    SysList.Add(sys);

    sys.sysid := ExtractWord(sys.Name, 1, '\');
    sys.mandt := ExtractWord(sys.Name, 2, '\');

    sys.mi := TMenuItem.Create(Self);
    sys.mi.Hint := sys.Name;
    sys.mi.Caption := sys.desc;
    sys.mi.OnClick := miSapSysClick;
  end;

  sl.Free;
end;

procedure TSAPTaskBar.SaveSys;
var
  i : Integer;
  s : String;
  sys : PSapSys;
  sl : TStringList;
begin
  if SysList.Count = 0 then Exit;

  sl := TStringList.Create;

  for i := 0 to SysList.Count - 1 do begin
    sys := PSapSys(SysList[i]);
    if (sys.mandt = ZeroMandt) and (sys.Login = '') then Continue;
    if sys.Name = invalid_sys_name then Continue;

    s := sys.Name +#9+ '$'+ IntToHex(Integer(sys.Color), 8) +#9+ sys.Login +#9+
         sys.desc + #9+ sys.connm +#9+ sys.Lang +#9+ IntToStr(sys.PassIndex) +#9+
         sys.IconName;
    sl.Add(s);
  end;

  sl.SaveToFile(SelfDir + scSapSys);

  sl.Free;
  SysListChanged := False;
end;

procedure TSAPTaskBar.LoadPass;
var
  fs : String;
  ds : String;

  fini : String;
  sl   : TStringList;
  i    : Integer;
  s    : String;
  PassIndex : Integer;
  Password  : String;
  j   : Integer;
  sys : PSapSys;
  DefPass : String;
begin
  if PassLoaded then Exit;

  fini := SelfDir + scPassDat;
  if not FileExists(fini) then begin
    PassLoaded := True;
    Exit;
  end;

  fs := FileToStr(fini); // Зашифрованая строка
// Изначально мы не знаем был ли задан пароль пользователем, поэтому сначала пытаемся расшифровать дефалтовым паролем
  DefPass := MD5Print(MD5String(SapWindowClass + scLicenseSubStr_en));
  ds := decrypt(DefPass, fs, scIconsDir);
  if ds = '' then begin // Не удалось расшифровать
    fmPassword.lbPassTitle.Caption:= 'Input master password';
    fmPassword.edPassword.Text := '';
    if fmPassword.ShowModal <> mrOk then Exit;

    ds := decrypt(MD5Print(MD5String(fmPassword.edPassword.Text + scLicenseSubStr_en)), fs, scIconsDir);
    if ds = '' then begin
      MessageDlg('Incorrect password', mtError, [mbOk], 0);
      Exit;
    end;

    MasterPass := fmPassword.edPassword.Text;

    ds := decrypt(DefPass,ds, scIconsDir);
    if ds = '' then begin
      MessageDlg('Password file corrupted', mtError, [mbOk], 0);
      Exit;
    end;
  end;

  sl := TStringList.Create;
  sl.Text:= ds;

  for i := 0 to sl.Count -1 do begin
    s := sl[i];

    Password  := ExtractWord(s, 2, #9);
    if Password = '' then Continue;

    PassIndex := StrToInt(ExtractWord(s, 1, #9));

    for j := 0 to SysList.Count - 1 do begin
      sys := PSapSys(SysList[j]);
      if sys.Passindex = PassIndex then begin
        sys.Password  := Password;
      end;
    end;

    if MaxPassIndex < PassIndex then MaxPassIndex := PassIndex;
  end;

  sl.Free;

  PassLoaded := True;
end;

procedure TSAPTaskBar.SavePass;
var
  i : Integer;
  s : String;
  sl : TStringList;
  sys : PSapSys;

  es : String;
begin
  sl := TStringList.Create;

  for i := 0 to SysList.Count - 1 do begin
    sys := PSapSys(SysList[i]);
    if sys.Passindex = 0 then Continue;
    s := IntToStr(sys.Passindex) +#9+ sys.Password;
    sl.Add(s);
  end;

  es := encrypt(MD5Print(MD5String(SapWindowClass + scLicenseSubStr_en)), sl.Text, scIconsDir);
  if MasterPass <> '' then begin
    es := encrypt(MD5Print(MD5String(MasterPass + scLicenseSubStr_en)), es, scIconsDir);
  end;

  StrToFile(SelfDir + scPassDat, es);

  sl.Free;
  PassListChanged := False;
end;

procedure TSAPTaskBar.SetTaskBtnSys(tb: TTaskBtn);
var
  i : Integer;
  sys : PSapSys;
  sname : String;
  found : Boolean;
  csli : PSLItem;
  ct : Integer;
  j : Integer;
begin
  if (tb.sysid = '') or (tb.mandt = '')
  then sname := invalid_sys_name
  else sname := tb.sysid +'\'+ tb.mandt;

  found := False;
  for i := 0 to SysList.Count - 1 do begin
    sys := PSapSys(SysList[i]);
    if sys.Name = sname then begin
      tb.sys := sys;
      if sys.Color <> TColor(0) then tb.Color := sys.Color;
      found := True;
    end;
  end;

  if not found then begin
    New(sys);
    FillChar(sys^, SizeOf(sys^), 0);
    
    sys.Name  := sname;
    sys.Color := TColor(0);
    sys.Login := '';
    sys.desc  := sname;
    SysList.Add(sys);

    sys.sysid := tb.sysid;
    sys.mandt := tb.mandt;

    sys.IconIndex := -1;

    sys.mi := TMenuItem.Create(Self);
    sys.mi.Hint    := sys.Name;
    sys.mi.Caption := sys.desc;
    sys.mi.OnClick := miSapSysClick;

    ct := 0; j := 0;
    for i := 0 to SLList.Count - 1 do begin
      csli := PSLItem(SLList.Objects[i]);
      if csli.sysid = sys.sysid then begin
        j := i;
        Inc(ct);
      end;
    end;
    if ct = 1 then begin
      csli := PSLItem(SLList.Objects[j]);
      sys.connm := csli.connm;
      sys.desc := sys.connm +' \ '+ sys.mandt;
    end;

    tb.sys := sys;
    SysListChanged := True;
  end;
end;

procedure TSAPTaskBar.miSortClick(Sender: TObject);
begin
  SortButtons;
end;

procedure TSAPTaskBar.miExitClick(Sender: TObject);
begin
  Self.OnCloseQuery:= nil;
  Self.Close;
end;

procedure TSAPTaskBar.miOptionsClick(Sender: TObject);
begin
  EditOptions(fmOptions.tsOptions);
end;

function TSAPTaskBar.EditOptions(ActPage: TTabSheet): Boolean;

// При переходе из горизонтального положения в вертикальное - рассчитывае новую ширину панели исходя из высоты кнопки
procedure CalcPanelNewWidth(nSelectAlign: Integer);
var
  nDirect : TDirect;
  sr : TRect;
  sw : Integer;
  sh : Integer;
  wr : TRect;
begin
  if PanelMode <> oppmLikeTaskBar then Exit;

  case nSelectAlign of
    opsaLeft, opsaRight : nDirect := dtVertical;
    opsaTop, opsaBottom : nDirect := dtHorizontal;
    else Exit;
  end;

  if not ((Direct = dtHorizontal) and (nDirect = dtVertical)) then Exit;

  GetWindowRect(Self.Handle, wr);

  sr := Screen.WorkAreaRect;
  sw := sr.Right - sr.Left;
  sh := sr.Bottom - sr.Top + (wr.Bottom - wr.Top); // Увеличиваем высоту новой рабочей облости на высоту нашего окна
  ThumbWidth := (ThumbHeight * sw) div (sh + ThumbHeight);
end;

// function TSAPTaskBar.EditOptions(ActPage: TTabSheet): Boolean;
var
  i : Integer;
  j : Integer;
  sys : PSapSys;
  sl : TStrings;
  Str : String;
begin
  Result := False;
  fmOptions.PageControl.ActivePage := ActPage;
  
  fmOptions.edLogin.Text           := DefLogin;
  fmOptions.edLanguage.Text        := Language;
  fmOptions.edSapLogon.Text        := SapLogonPath;
  fmOptions.rgAlign.ItemIndex      := SelectAlign;
  fmOptions.rgPanelMode.ItemIndex  := PanelMode;
  fmOptions.cbStartWithWin.Checked := StartWithWin;
  fmOptions.cbHideIfNoSap.Checked  := HideIfNoSap;
  fmOptions.cbHideTaskBtn.Checked  := HideTaskBtn;
  fmOptions.cbHideSapGuiTaskBtn.Checked   := HideSapGuiTaskBtn;
  fmOptions.cbShowTBinWTBwhenSTBHide.Checked := ShowTBinWTBwhenSTBHide;
  fmOptions.cbHideSapLogonTaskBtn.Checked := HideSapLogonTaskBtn;
  fmOptions.cbBigPreview.Checked:= BigPreview;

  fmOptions.seStepHistoryLength.Value:= StepHistoryLength;
  fmOptions.cbShowStepHistory.Checked:= ShowStepHistory;

  fmOptions.cbCotrolLanguage.Checked:= CotrolLanguage;
  fmOptions.cbMaximizeNewWin.Checked:= MaximizeNewWin;
  fmOptions.cbScrollLimitInCentre.Checked:= ScrollLimitInCentre;
  fmOptions.cbShowScrollButton.Checked:= ShowScrollButton;

  fmOptions.cbHideTransparentBorders.Checked := HideTransparentBorders;
  fmOptions.trbPlug_AlphaBlend.Position := Plug_AlphaBlend;

  fmOptions.cbDrawSapSys.Checked := DrawSapSys;
  fmOptions.cbDrawSapTitle.Checked := DrawSapTitle;
  fmOptions.cbShowBtnMarker.Checked := ShowBtnMarker;

  fmOptions.cobPrintWindowMode.ItemIndex    := PrintWindowMode;
  fmOptions.cobSHThreadPriority.ItemIndex   := SHThreadPriority;
  fmOptions.seScreenCaptureInterval.Value   := ScreenCaptureInterval;
  fmOptions.cbIgnoreAero.Checked            := IgnoreAero;
  fmOptions.cobHideTaskButtonMode.ItemIndex := HideTaskButtonMode;
  fmOptions.seStatusBarWordNum.Value        := StatusBarWordNum;

  fmOptions.edSapLogon.Enabled := not NoEditSapLogonPath;
  fmOptions.btnSapLogon.Enabled:= not NoEditSapLogonPath;

  RefreshSysCount;

//  LoadPass;

  fmOptions.sgSapSys.RowCount := SysList.Count + 1;
  j := 0;
  for i := 0 to SysList.Count - 1 do begin
    sys := PSapSys(SysList[i]);
    if (sys.mandt = ZeroMandt) and (sys.Login = '') then Continue;
    if sys.Name = invalid_sys_name then Continue;

    Inc(j);
    fmOptions.sgSapSys.Cells[fdSysnm, j] := sys.Name;
    fmOptions.sgSapSys.Cells[fdLogin, j] := sys.Login;
    fmOptions.sgSapSys.Cells[fdLang,  j] := sys.Lang;
    fmOptions.sgSapSys.Cells[fdConnm, j] := sys.Connm;
    fmOptions.sgSapSys.Cells[fdColor, j] := '$'+IntToHex(Integer(sys.Color), 8);
    fmOptions.sgSapSys.Cells[fdDesc , j] := Sys.desc;
    fmOptions.sgSapSys.Cells[fdCount, j] := IntToStr(Sys.Count);
    fmOptions.sgSapSys.Cells[fdIcon,  j] := Sys.IconName;

    if sys.Password <> '' then begin
      fmOptions.sgSapSys.Cells[fdPass,  j] := IntToStr(sys.PassIndex) +#9+ sys.Password;
    end;
  end;
  fmOptions.sgSapSys.RowCount := j + 1;

  fmOptions.btnInputMasterPass.Visible := PassLoaded;
  fmOptions.btnPasswords.Visible:= not PassLoaded;
  if PassLoaded then begin
    fmOptions.sgSapSys.ColWidths[fdPass] := fdwPass;
  end
  else begin
    fmOptions.sgSapSys.ColWidths[fdPass] := 0;
  end;

  Timer.Enabled:= False;
  try
    if fmOptions.ShowModal <> mrOk then Exit;

    sl := fmOptions.sgSapSys.Cols[fdSysnm];
    for i := SysList.Count - 1 downto 0 do begin
      sys := PSapSys(SysList[i]);
      j := sl.IndexOf(sys.Name);
      if j >= 0 then begin
        sl.Objects[j] := TObject(sys);
        SysList.Delete(i);
      end;
      if (j < 0) and (sys.Count = 0) then begin
        Dispose(sys);
        SysList.Delete(i);
      end;
    end;

    for i := 1 to sl.Count - 1 do begin
      sys := PSapSys(sl.Objects[i]);
      sys.Login := fmOptions.sgSapSys.Cells[fdLogin, i];
      sys.Lang  := fmOptions.sgSapSys.Cells[fdLang, i];
      sys.Connm := fmOptions.sgSapSys.Cells[fdConnm, i];
      sys.Color := Integer(StrToInt(fmOptions.sgSapSys.Cells[fdColor, i]));
      sys.desc  := fmOptions.sgSapSys.Cells[fdDesc, i];
      sys.IconName:= fmOptions.sgSapSys.Cells[fdIcon, i];;
      sys.IconIndex:= GetIconIndex(sys.IconName);

      str       := fmOptions.sgSapSys.Cells[fdPass, i];
      if str <> '' then begin
        sys.PassIndex := StrToInt(ExtractWord(str, 1, #9, '0'));
        sys.Password  := ExtractWord(str, 2, #9);
      end
      else begin
        sys.PassIndex := 0;
        sys.Password  := '';
      end;

      if sys.desc = '' then sys.desc := sys.Name;
      SysList.Add(sys);

      sys.mi.Caption := sys.desc;
    end;

    SaveSys;
    SortButtons;

    DefLogin     := fmOptions.edLogin.Text;
    Language     := fmOptions.edLanguage.Text;
    SapLogonPath := fmOptions.edSapLogon.Text;
    PanelMode    := fmOptions.rgPanelMode.ItemIndex;
    StartWithWin := fmOptions.cbStartWithWin.Checked;
    HideIfNoSap  := fmOptions.cbHideIfNoSap.Checked;
    HideTaskBtn  := fmOptions.cbHideTaskBtn.Checked;
    HideSapGuiTaskBtn := fmOptions.cbHideSapGuiTaskBtn.Checked;
    ShowTBinWTBwhenSTBHide := fmOptions.cbShowTBinWTBwhenSTBHide.Checked;
    HideSapLogonTaskBtn := fmOptions.cbHideSapLogonTaskBtn.Checked;
    BigPreview := fmOptions.cbBigPreview.Checked;

    StepHistoryLength := fmOptions.seStepHistoryLength.Value;
    Self.BtnData.HistLength:= StepHistoryLength;
    ShowStepHistory := fmOptions.cbShowStepHistory.Checked;
    Self.BtnData.HistShow:= ShowStepHistory;

    CotrolLanguage := fmOptions.cbCotrolLanguage.Checked;
    MaximizeNewWin := fmOptions.cbMaximizeNewWin.Checked;
    ScrollLimitInCentre := fmOptions.cbScrollLimitInCentre.Checked;
    ShowScrollButton    := fmOptions.cbShowScrollButton.Checked;
    HideTransparentBorders := fmOptions.cbHideTransparentBorders.Checked;
    Plug_AlphaBlend        := fmOptions.trbPlug_AlphaBlend.Position;

    DrawSapSys           := fmOptions.cbDrawSapSys.Checked;
    DrawSapTitle         := fmOptions.cbDrawSapTitle.Checked;
    ShowBtnMarker        := fmOptions.cbShowBtnMarker.Checked;
    Self.BtnData.ShowMark:= ShowBtnMarker;

    PrintWindowMode    := fmOptions.cobPrintWindowMode.ItemIndex;
    SHThreadPriority   := fmOptions.cobSHThreadPriority.ItemIndex;
    ScreenCaptureInterval := fmOptions.seScreenCaptureInterval.Value;
    IgnoreAero         := fmOptions.cbIgnoreAero.Checked;
    HideTaskButtonMode := fmOptions.cobHideTaskButtonMode.ItemIndex;
    StatusBarWordNum   := fmOptions.seStatusBarWordNum.Value;

    if SelectAlign <> fmOptions.rgAlign.ItemIndex then CalcPanelNewWidth(fmOptions.rgAlign.ItemIndex);  // Изменилось расположение панели

    SelectAlign  := fmOptions.rgAlign.ItemIndex;

    SaveOptions;

    if PassListChanged then SavePass;

    if MessageDlg(rsMsg002, mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin
      Str := Application.ExeName;
      ShellExecute(0, 'Open', PAnsiChar(Str), nil, nil, SW_RESTORE);
      Timer.Enabled:= False;
      Terminate;
    end
    else begin
      ApplyOptions;
      RefreshScreenShots;
    end;


    Result := True;
  finally
    Timer.Enabled:= True;
  end;
end;

procedure TSAPTaskBar.BtnHideClick(Sender: TObject);
begin
  Timer.Enabled := False;
  SideBarRemove;
  Self.Hide;
  miShow.Visible := True;
  miHide.Visible := False;
end;

procedure TSAPTaskBar.miShowClick(Sender: TObject);
begin
  Self.Visible := True;
  ApplyOptions;
  RefreshScreenShots;
  Timer.Enabled := True;
  miShow.Visible := False;
  miHide.Visible := True;
end;

procedure TSAPTaskBar.miSapSysClick(Sender: TObject);
var
  i : Integer;
  sys : PSapSys;
  ctb : TTaskBtn;
  mi  : TMenuItem;
begin
  mi  := TMenuItem(Sender);
  sys := nil;
  for i := 0 to SysList.Count - 1 do begin
    sys := PSapSys(SysList[i]);
    if sys.mi = mi then Break;
  end;

  if sys.Count = 0 then begin
    OpenNewSapSys(sys);
    Exit;
  end;

  if miSelFilter.Checked or miFilter.Checked then begin
    ApplyFilers;
    Exit;
  end;

  ctb := nil;
  for i := 0 to TBList.Count - 1 do begin
    ctb := TTaskBtn(TBList[i]);
    if not ctb.Visible then Continue;
    if ctb.sys = sys then Break;
  end;

  if Direct = dtVertical then begin
    plTasks.Top := - ctb.Top;
  end;

  if Direct = dtHorizontal then begin
    plTasks.Left := - ctb.Left;
  end;
end;

procedure TSAPTaskBar.miIconSelectClick(Sender: TObject);
var
  mi : TMenuItem;
  tb : TTaskBtn;
begin
  mi := TMenuItem(Sender);
  tb := TTaskBtn(ppmButton.Tag);
  tb.IconImageIndex:= mi.ImageIndex;
  tb.IconMask := '';
  tb.Invalidate;
end;

procedure TSAPTaskBar.btnSapSysClick(Sender: TObject);
var
  pt  : TPoint;
  i   : Integer;
  sys : PSapSys;
  zex : Boolean;
begin
  RefreshButtons;

  for i := ppmTrayIcon.Items.Count - 1 downto 0 do begin
    ppmTrayIcon.Items.Delete(i);
  end;
  for i := ppmSapSys.Items.Count - 1 downto 0 do begin
    ppmSapSys.Items.Delete(i);
  end;
  
  zex := False;
  for i := 0 to SysList.Count - 1 do begin
    sys := PSapSys(SysList[i]);
    if sys.Count = 0 then begin
      zex := True;
      Continue;
    end;

    sys.mi.Caption := IntToStr(sys.Count) +' '+ sys.desc;
    if miSelFilter.Checked then begin
      sys.mi.ShowAlwaysCheckable:=True;
      sys.mi.AutoCheck:=True;
      sys.mi.GroupIndex:=1;
      sys.mi.RadioItem:=True;
    end;
    if miFilter.Checked then begin
      sys.mi.ShowAlwaysCheckable:=True;
      sys.mi.AutoCheck:=True;
      sys.mi.RadioItem:=False;
      sys.mi.GroupIndex:=0;
    end;
    if not miSelFilter.Checked and not miFilter.Checked then begin
      sys.mi.ShowAlwaysCheckable:=False;
      sys.mi.AutoCheck:=False;
      sys.mi.RadioItem:=False;
      sys.mi.GroupIndex:=0;
      sys.mi.Checked:=False;
    end;

    ppmSapSys.Items.Add(sys.mi);
  end;

  ppmSapSys.Items.Add(miSpliter);

  if zex then begin

    for i := 0 to SysList.Count - 1 do begin
      sys := PSapSys(SysList[i]);
      if sys.Count <> 0 then Continue;
      if sys.Name = invalid_sys_name then Continue;

      sys.mi.Caption := sys.desc;
      sys.mi.ShowAlwaysCheckable:=False;
      sys.mi.AutoCheck:=False;
      sys.mi.RadioItem:=False;
      sys.mi.GroupIndex:=0;
      sys.mi.Checked:=False;

      ppmSapSys.Items.Add(sys.mi);
    end;
  end;

  ppmSapSys.Items.Add(miSapLogon);

  ppmSapSys.Items.Add(miSpliter1);
  ppmSapSys.Items.Add(miSelFilter);
  ppmSapSys.Items.Add(miFilter);

  pt.X := btnSapSys.Left;
  pt.Y := btnSapSys.Top + btnSapSys.Height + 1;

  pt := ClientToScreen(pt);

  ppmSapSys.Popup(pt.X, pt.Y);
end;

procedure TSAPTaskBar.OpenNewSapSys(sys: PSapSys);
var
  sl : TStringList;
  fsap : String;
  i : Integer;
  csli : PSLItem;
  connm : String;
  ct : Integer;
  j : Integer;

  mhw : HWND;
  bhw : HWND;
  ehw : HWND;
  desc: String;
  Password : String;
begin
  connm := sys.connm;
  if connm <> '' then begin
    if SLList.IndexOf(connm) < 0 then connm := '';
  end;

  if connm = '' then begin // Пробуем найти имя соединения
    ct := 0; j := 0;
    for i := 0 to SLList.Count - 1 do begin
      csli := PSLItem(SLList.Objects[i]);
      if csli.sysid = sys.sysid then begin
        j := i;
        Inc(ct);
      end;
    end;

    if ct = 1 then begin
      csli := PSLItem(SLList.Objects[j]);
      sys.connm := csli.connm;
      connm := sys.connm;
    end;
    
    if ct = 0 then connm := sys.connm; // Нам всё равно нечего предложить
  end;

  if connm = '' then begin
    fmConNameQuery.lbSys_Desc.Caption := sys.desc;
    fmConNameQuery.cbConName.Items.Clear;
    for i := 0 to SLList.Count - 1 do begin
      csli := PSLItem(SLList.Objects[i]);
      if csli.sysid = sys.sysid then begin
        fmConNameQuery.cbConName.Items.Add(csli.connm);
      end;
    end;

    fmConNameQuery.cbConName.Text := '';
    fmConNameQuery.cbSave.Checked:= False;
    if fmConNameQuery.ShowModal <> mrOk then Exit;

    connm := fmConNameQuery.cbConName.Text;

    if fmConNameQuery.cbSave.Checked then begin
      sys.connm := connm;
      SaveSys;
    end;
  end;

  sl := TStringList.Create;

  sl.Add('[System]');
  sl.Add('Name='+ sys.sysid);
  sl.Add('Description='+ connm);
  sl.Add('Client='+ sys.mandt);
  sl.Add('[User]');

  if sys.Login <> '' then begin
    sl.Add('Name='+ sys.Login)
  end
  else begin
    if DefLogin <> '' then sl.Add('Name='+ DefLogin);
  end;

  if sys.Lang <> '' then begin
    sl.Add('Language='+ sys.Lang)
  end
  else begin
    if Language <> '' then sl.Add('Language='+ Language);
  end;

  sl.Add('[Function]');
  sl.Add('Title='+ sys.desc);
  sl.Add('Command=SESSION_MANAGER');
  sl.Add('[Options]');
  sl.Add('Reuse=1');

  fsap := SelfDir + sys.sysid +'_'+ sys.mandt + '.sap';
  sl.Text:= Utf8ToAnsi(sl.Text);
  sl.SaveToFile(fsap);
  sl.Free;

  LoadPass;

  MyShowWindow(GetSapLogonWnd, SW_MINIMIZE); // Если он не свёрнут - зачемто выскакивает
  ShellExecute(Self.Handle, 'Open', PAnsiChar(fsap), nil, '', SW_SHOW);

  if sys.Password = '' then Exit;

// Ожидаем появление окна и вводим пароль

  desc := Utf8ToAnsi(sys.desc);
  for i := 0 to 400 do begin
    mhw := FindWindow('#32770', PChar(desc));
    if mhw = 0 then begin
      Sleep(100);
      Application.ProcessMessages;
      Continue;
    end;

    Break;
  end;
  if mhw = 0 then Exit;

  Sleep(200);

  bhw := FindWindowEX(mhw, 0, 'Button', '&Logon');
  if bhw = 0 then Exit;

  ehw := FindWindowEX(mhw, 0, 'Edit', nil);
  if ehw = 0 then Exit;
  ehw := GetWindow(ehw, GW_HWNDNEXT);
  if ehw = 0 then Exit;

  Password := sys.Password;
  Clipboard.AsText:= Password;
  try
    PostMessage(ehw, WM_PASTE, 0, 0);
    Sleep(100);
    PostMessage(bhw, WM_KEYDOWN, VK_SPACE, 0);
    Sleep(100);
    PostMessage(bhw, WM_KEYUP, VK_SPACE, 0);
  finally
    Sleep(100);
    Clipboard.AsText := '';
    Clipboard.Clear;
  end;
end;

procedure TSAPTaskBar.RefreshSysCount;
var
  i : Integer;
  sys : PSapSys;
  ctb : TTaskBtn;
begin
  for i := 0 to SysList.Count - 1 do begin
    sys := PSapSys(SysList[i]);
    sys.Count := 0;
  end;

  for i := 0 to TBList.Count - 1 do begin
    ctb := TTaskBtn(TBList[i]);
    Inc(ctb.sys.Count);
  end;
end;

procedure TSAPTaskBar.SetSysColor(sys: PSapSys; AColor: TColor);
var
  i : Integer;
  ctb : TTaskBtn;
begin
  sys.Color := AColor;
  for i := 0 to TBList.Count - 1 do begin
    ctb := TTaskBtn(TBList[i]);
    if ctb.sys <> sys then Continue;
    ctb.Color := AColor;
  end;
end;

procedure TSAPTaskBar.AutoHide;
begin
  if sizing > 0 then Exit;

  Self.Hide;

  RedrawWindow(hwCur, nil, 0, RDW_UPDATENOW); // Лечим глюк от PrintWindow
end;

function GetFileCreationTime(const AFileName: AnsiString): TDateTime;
var
  SearchRec: TSearchRec;
  SysTime: SYSTEMTIME;
  FileTime: TFILETIME;
begin
  Result := 0;
  if FindFirst(AFileName, faAnyFile, SearchRec) = 0 then
  begin
    FileTimeToLocalFileTime(SearchRec.FindData.ftCreationTime, FileTime);
    FileTimeToSystemTime(FileTime, SysTime);
    Result := SystemTimeToDateTime(SysTime);
  end;
end;

function NoEnLngEx:Boolean;
var
  AList : array [0..9] of HKL;
  i : Integer;
  Cur : HKL;
begin
  Result := False;
  for i := 0 to GetKeyboardLayoutList(SizeOf(AList), AList) - 1 do begin
    Cur := AList[i] and $0000FFFF;
    case Cur of
      $00000419: // Перечисляем языки письменность которых основана не на латинеце
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
end;

procedure TSAPTaskBar.LoadOptions;
var
  fop : String;
  ini: TIniFile;
  reg: TRegistry;
  path : String;
  i :Integer;
  FirstRun : Boolean;
begin
  reg := TRegistry.Create;
  reg.Access:= KEY_READ;
  reg.RootKey:= HKEY_CLASSES_ROOT;

// Sap GUI path
  path := '';
  if reg.OpenKey('Sapgui.Shortcut.File\shell\Open\command', false) then begin
    path := reg.ReadString('');
    reg.CloseKey;
  end;

  if path <> '' then begin
    path := Copy(path, 2, Length(path) - 1);

    i := Pos('.exe', path);
    if i = 0 then i := Pos('.EXE', path);
    if i = 0 then Exit;

    path := Copy(path, 1, i+3);

    SapGuiPath := ExtractFilePath(path);
  end;

// Read Options.ini
  fop := SelfDir + scOptionsIni;

  FirstRun := not FileExists(fop);

  ini:= TIniFile.Create(fop);

  DefLogin     := ini.ReadString('Enter', 'Login'   , '');
  Language     := UpperCase(ini.ReadString('Enter', 'Language', ''));
  SapLogonPath := ini.ReadString('Enter', 'SapLogon', '');

  SelectAlign  := ini.ReadInteger('Options', 'Align'    , 1);
  PanelMode    := ini.ReadInteger('Options', 'PanelMode', 0);

  StartWithWin := ini.ReadBool('Options', 'StartWithWin', True);
  HideIfNoSap  := ini.ReadBool('Options', 'HideIfNoSap' , True);
  HideTaskBtn  := ini.ReadBool('Options', 'HideTaskBtn' , True);
  HideSapGuiTaskBtn := ini.ReadBool('Options', 'HideSapGuiTaskBtn' , True);
  ShowTBinWTBwhenSTBHide := ini.ReadBool('Options', 'ShowTBinWTBwhenSTBHide' , True);
  HideSapLogonTaskBtn := ini.ReadBool('Options', 'HideSapLogonTaskBtn' , False);

  BigPreview := ini.ReadBool('Options', 'BigPreview' , True);
  PreviewWidth := ini.ReadInteger('Options', 'PreviewWidth', Screen.Width div 4);
  PreviewHeight := ini.ReadInteger('Options', 'PreviewHeight', Screen.Height div 4);

  StepHistoryLength := ini.ReadInteger('Options', 'StepHistoryLength', 4);
  Self.BtnData.HistLength:= StepHistoryLength;
  ShowStepHistory := ini.ReadBool('Options', 'ShowStepHistory', False);
  Self.BtnData.HistShow:= ShowStepHistory;

  LockChangeSize := ini.ReadBool('Options', 'LockChangeSize' , False);
  Self.miLockChangeSize.Checked:= LockChangeSize;

  CotrolLanguage := ini.ReadBool('Options', 'CotrolLanguage' , False);
  MaximizeNewWin := ini.ReadBool('Options', 'MaximizeNewWin' , False);
  ScrollLimitInCentre := ini.ReadBool('Options', 'ScrollLimitInCentre' , False);
  ShowScrollButton := ini.ReadBool('Options', 'ShowScrollButton' , True);

  HideTransparentBorders := ini.ReadBool('Options', 'HideTransparentBorders' , False);
  Plug_AlphaBlend := ini.ReadInteger('Options', 'AlphaBlend', 0);

  PrintWindowMode      := ini.ReadInteger('Options', 'PrintWindowMode', 0);
  SHThreadPriority     := ini.ReadInteger('Options', 'SHThreadPriority', 3); // Idle
  ScreenCaptureInterval:= ini.ReadInteger('Options', 'ScreenCaptureInterval', 300);

  IgnoreAero           := ini.ReadBool('Options', 'IgnoreAero' , False);
  HideTaskButtonMode   := ini.ReadInteger('Options', 'HideTaskButtonMode', 0);
  StatusBarWordNum     := ini.ReadInteger('Options', 'StatusBarWordNum', 0);

  DrawSapSys           := ini.ReadBool('TaskButton', 'DrawSapSys' , True);
  DrawSapTitle         := ini.ReadBool('TaskButton', 'DrawSapTitle', True);
  ShowBtnMarker        := ini.ReadBool('TaskButton', 'ShowBtnMarker', True);
  Self.BtnData.ShowMark  := ShowBtnMarker;
  ThumbWidth           := ini.ReadInteger('TaskButton', 'ThumbWidth' , Screen.Width  div 10);
  ThumbHeight          := ini.ReadInteger('TaskButton', 'ThumbHeight', Screen.Height div 10);
  if ThumbWidth  < LowLimitThumbSize then ThumbWidth  := LowLimitThumbSize;
  if ThumbHeight < LowLimitThumbSize then ThumbHeight := LowLimitThumbSize;

  ini.Free;

// Correct options if First run
  if FirstRun then begin
    if GetWinVer >= 62 then begin // Ver >= Windows 8.0
      PrintWindowMode := 2;
      HideTransparentBorders := True;
    end;

    if NoEnLngEx then begin
      CotrolLanguage := True;
    end;
  end;

  Plug_Visible := HideTransparentBorders or ((Plug_AlphaBlend > 0) and (Plug_AlphaBlend < 255));

// Sap logon path
  reg.Access:= KEY_READ;
  reg.RootKey:= HKEY_CURRENT_USER;

  path := '';
  if reg.OpenKey('Software\SAP\SAPLogon\ConfigFilesLastUsed', false) then begin
    path := reg.ReadString('ConnectionConfigFile');
    reg.CloseKey;
  end;

  if (path <> '') and not FileExists(path) then path := '';

  if (path <> '') and (SapLogonPath = '') then SapLogonPath := path;

  if (SapLogonPath <> '') and not FileExists(SapLogonPath) then SapLogonPath := '';

  NoEditSapLogonPath := (path <> '') and (SapLogonPath = path);

  reg.Free;

// Load last previus run data
  path := Selfdir + scLastRunWnd;
  if FileExists(path) then begin
    LastRunWndList := TStringList.Create;
    LastRunWndList.LoadFromFile(path);
  end;
end;

procedure TSAPTaskBar.SaveOptions;
var
  ini: TIniFile;
begin
  ini:= TIniFile.Create(SelfDir + scOptionsIni);

  ini.WriteString('Enter', 'Login'   , DefLogin     );
  ini.WriteString('Enter', 'Language', Language    );
  ini.WriteString('Enter', 'SapLogon', SapLogonPath);

  ini.WriteInteger('Options', 'Align'    , SelectAlign);
  ini.WriteInteger('Options', 'PanelMode', PanelMode  );

  ini.WriteBool('Options', 'StartWithWin', StartWithWin);
  ini.WriteBool('Options', 'HideIfNoSap' , HideIfNoSap );
  ini.WriteBool('Options', 'HideTaskBtn' , HideTaskBtn );
  ini.WriteBool('Options', 'HideSapGuiTaskBtn', HideSapGuiTaskBtn);
  ini.WriteBool('Options', 'ShowTBinWTBwhenSTBHide', ShowTBinWTBwhenSTBHide);
  ini.WriteBool('Options', 'HideSapLogonTaskBtn', HideSapLogonTaskBtn);

  ini.WriteBool('Options', 'BigPreview', BigPreview);
  ini.WriteInteger('Options', 'PreviewWidth', PreviewWidth);
  ini.WriteInteger('Options', 'PreviewHeight', PreviewHeight);

  ini.WriteInteger('Options', 'StepHistoryLength', StepHistoryLength);
  ini.WriteBool('Options', 'ShowStepHistory' , ShowStepHistory);

  ini.WriteBool('Options', 'LockChangeSize' , LockChangeSize);

  ini.WriteBool('Options', 'CotrolLanguage' , CotrolLanguage);
  ini.WriteBool('Options', 'MaximizeNewWin' , MaximizeNewWin);
  ini.WriteBool('Options', 'ScrollLimitInCentre' , ScrollLimitInCentre);
  ini.WriteBool('Options', 'ShowScrollButton' , ShowScrollButton);

  ini.WriteBool('Options', 'HideTransparentBorders' , HideTransparentBorders);
  ini.WriteInteger('Options', 'AlphaBlend', Plug_AlphaBlend);

  ini.WriteInteger('Options', 'PrintWindowMode', PrintWindowMode);
  ini.WriteInteger('Options', 'SHThreadPriority', SHThreadPriority);
  ini.WriteInteger('Options', 'ScreenCaptureInterval', ScreenCaptureInterval);

  ini.WriteBool('Options', 'IgnoreAero' , IgnoreAero);
  ini.WriteInteger('Options', 'HideTaskButtonMode', HideTaskButtonMode);
  ini.WriteInteger('Options', 'StatusBarWordNum', StatusBarWordNum);

  ini.WriteBool('TaskButton', 'DrawSapSys' , DrawSapSys);
  ini.WriteBool('TaskButton', 'DrawSapTitle', DrawSapTitle);
  ini.WriteBool('TaskButton', 'ShowBtnMarker', ShowBtnMarker);
  ini.WriteInteger('TaskButton', 'ThumbWidth', ThumbWidth);
  ini.WriteInteger('TaskButton', 'ThumbHeight', ThumbHeight);

  ini.Free;

  SaveLastRunWndList;
end;

procedure TSAPTaskBar.ReadSapLogon;
var
  ini  : TIniFile;
  i    : Integer;
  sl   : TStringList;
  csli : PSLItem;
  nm   : string;
  j    : Integer;

  astr : AnsiString;
  ustr : string;
  fs : TFileStream;
  ss : TStringStream;
begin
  if SapLogonPath = '' then Exit;

  fs := TFileStream.Create(SapLogonPath, fmOpenRead);
  try
    if fs.Size > 0 then
    begin
      SetLength(astr, fs.Size);
      FS.ReadBuffer(Pointer(astr)^, fs.Size);
    end;
  finally
    fs.Free;
  end;

  ustr := ConvertEncoding(astr, GetDefaultTextEncoding, 'UTF-8');
  ss := TStringStream.Create(ustr);

  ini:= TIniFile.Create( ss );

  sl := TStringList.Create;

  ini.ReadSectionValues('Description', sl);

  for i := 0 to sl.Count - 1 do begin
    new(csli);
    FillChar(csli^, SizeOf(csli^), 0);
    
    nm := sl.Names[i];
    SLList.AddObject(nm, TObject(csli));
    csli.connm := sl.Values[nm];
  end;

  sl.Clear;
  ini.ReadSectionValues('MSSysName', sl);

  for i := 0 to sl.Count - 1 do begin
    nm := sl.Names[i];
    j := SLList.IndexOf(nm);
    if j >= 0 then begin
      csli := PSLItem(SLList.Objects[j]);
      csli.sysid := sl.Values[nm];
    end;
  end;

  sl.Free;
  ss.Free;

  for i := 0 to SLList.Count - 1 do begin
    csli := PSLItem(SLList.Objects[i]);
    SLList[i] := csli.connm;
  end;
end;

procedure TSAPTaskBar.ApplicationEventsRestore(Sender: TObject);
begin
  HideTiker := 8;
end;

procedure TSAPTaskBar.ToolButton1Click(Sender: TObject);
begin
end;

procedure TSAPTaskBar.RefreshScreenShots;
var
  i : Integer;
  ctb : TTaskBtn;
  min : Boolean;
  fhw : HWND;
begin
  Timer.Enabled:= False;
  fhw := GetForegroundWindow;
  for i := 0 to TBList.Count - 1 do begin
    ctb := TTaskBtn(TBList[i]);

    min := False;
    if IsIconic(ctb.hw) then begin
      min := True;
      MyShowWindow(ctb.hw, SW_RESTORE);
    end;

    if ctb.ftime <> 0 then begin
      ctb.ftime:= Now - 0.01;
    end;

    GetBtnGlyph(ctb, False);

    if min then MyShowWindow(ctb.hw, SW_MINIMIZE);
  end;
  MySetForegroundWindow(fhw);
  Timer.Enabled:= True;
end;

procedure TSAPTaskBar.TrayIconClick(Sender: TObject);
//var
//  pt : TPoint;
begin
// Выпавшее меню плохо скрывается, и блокирует реакцию на DubleClick
//  if not GetCursorPos(pt) then Exit;
//  TrayIcon.PopUpMenu.PopUp(pt.x, pt.y);
end;

procedure TSAPTaskBar.BtnUnDown;
var
  i : Integer;
  ctb : TTaskBtn;
begin
  for i := 0 to TBList.Count - 1 do begin
    ctb := TTaskBtn(TBList[i]);
    if ctb.Down then ctb.Down:= False;
  end;
end;

procedure TSAPTaskBar.HideTaskButton(hw : HWND);
var
  exstyle : LONG;
begin
  if hw = 0 then Exit;

  if HideTaskButtonMode = 0 then begin
    Taskbar.DeleteTab(hw);
  end;
  if HideTaskButtonMode = 1 then begin
    exstyle := getWindowLong(hw, GWL_EXSTYLE);
    if (exstyle and WS_EX_TOOLWINDOW) <> 0 then Exit; // Уже стоит

    MyShowWindow(hw, SW_HIDE);
    SetWindowLong(hw, GWL_EXSTYLE, exstyle or WS_EX_TOOLWINDOW);
    MyShowWindow(hw, SW_SHOWNA);
  end;
end;

procedure TSAPTaskBar.ShowTaskButton(hw: HWND);
begin
  if hw = 0 then Exit;

  if HideTaskButtonMode = 0 then begin
    Taskbar.AddTab(hw);
  end;
  if HideTaskButtonMode = 1 then begin
    MyShowWindow(hw, SW_HIDE);
    SetWindowLong(hw, GWL_EXSTYLE, getWindowLong(hw, GWL_EXSTYLE) and not WS_EX_TOOLWINDOW);
    MyShowWindow(hw, SW_SHOWNA);
  end;
end;

function TSAPTaskBar.GetSapLogonWnd: HWND;
var
  hw : HWND;
  str : string;
begin
  if SapLogon_hw <> 0 then begin
    Result := SapLogon_hw;
    Exit;
  end;

  Result := 0;
  hw := 0;
  while True do begin
    hw := FindWindowEx(0, hw, '#32770', nil);
    if hw = 0 then Exit;
    str := GetControlText(hw);
    if Pos('SAP Logon', str) > 0 then begin
      SapLogon_hw := hw;
      Result := hw;
      Exit;
    end;
  end;
end;

procedure TSAPTaskBar.CheckWindowPos(hw : HWND);
var
  wr : TRect;
  mr : TRect;
  ir : TRect;
  cp : Boolean;
begin
  if IsIconic(hw) then Exit;

  GetWindowRect(hw, wr);
  mr := Screen.WorkAreaRect;

  if not IntersectRect(ir, wr, mr) then Exit;

  if IsZoomed(hw) then begin
    MyShowWindow(hw, SW_MAXIMIZE);
    Exit;
  end;

  cp := False;

  if (wr.Right - wr.Left) > (mr.Right - mr.Left) then begin
    wr.Left  := mr.Left;
    wr.Right := mr.Right;
    cp := True;
  end
  else begin
     if wr.Left < mr.Left then begin
       wr.Right:= wr.Right + mr.Left - wr.Left;
       wr.Left := mr.Left;
       cp := True;
     end;
     if wr.Right > mr.Right then begin
       wr.Left:= wr.Left - (wr.Right - mr.Right);
       wr.Right := mr.Right;
       cp := True;
     end;
  end;

  if (wr.Bottom - wr.Top) > (mr.Bottom - mr.Top) then begin
    wr.Top  := mr.Top;
    wr.Bottom := mr.Bottom;
    cp := True;
  end
  else begin
     if wr.Top < mr.Top then begin
       wr.Bottom:= wr.Bottom + mr.Top - wr.Top;
       wr.Top := mr.Top;
       cp := True;
     end;
     if wr.Bottom > mr.Bottom then begin
       wr.Top:= wr.Top - (wr.Bottom - mr.Bottom);
       wr.Bottom := mr.Bottom;
       cp := True;
     end;
  end;

  if not cp then Exit;

  MySetWindowPos(hw, wr);
end;

procedure TSAPTaskBar.LoadIcons;
var
  SL: TStringList;
  SR: TSearchRec;
  i : Integer;
  fname : String;

  png: TPortableNetworkGraphic;
  j  : Integer;
  mi : TMenuItem;
begin
  SL := TStringList.Create;
  png:= TPortableNetworkGraphic.Create;
  try
    if FindFirst(scIconsDir + '\*.png', faAnyFile and not faDirectory and not faHidden, SR) = 0 then
    repeat
      SL.Add(scIconsDir +'\'+ SR.Name)
    until FindNext(SR) <> 0;

    FindClose(SR);

    if SL.Count = 0 then Exit;


    for i := 0 to SL.Count - 1 do begin
      fname := SL[i];
      png.LoadFromFile(fname);
      if not png.Masked then png.Mask(png.Canvas.Pixels[0,0]);
      j := IconList.Add(png, nil);

      mi := TMenuItem.Create(Self);
      fname := ExtractFileName(fname);
      mi.Caption:= Copy(fname, 1, Length(fname) - Length(ExtractFileExt(fname)));
      miIcons.Add(mi);
      mi.ImageIndex:= j;
      mi.OnClick:= miIconSelectClick;
    end;
  finally
    SL.Free;
    png.Free;
  end;
end;

procedure TSAPTaskBar.LoadIconsMap;
var
  fini : String;
  sl : TStringList;
  i : Integer;
  s : String;

  xs : String;
  nm  : String;
  j   : Integer;
  mi  : TMenuItem;
begin
  fini := SelfDir + scIconMap;
  if not FileExists(fini) then Exit;

  sl := TStringList.Create;
  sl.LoadFromFile(fini);

  for i := 0 to sl.Count - 1 do begin
    s := sl[i];
    xs := ExtractWord(s, 1, '&');
    nm := ExtractWord(s, 2, '&');

    for j := 0 to miIcons.Count - 1 do begin
      mi := miIcons.Items[j];
      if mi.Name <> '' then Continue;

      if SameText(mi.Caption, nm) then begin
        IconMapList.AddObject(xs, mi);
        Break;
      end;
    end;
  end;

  sl.Free;
end;

procedure TSAPTaskBar.MapIcon(btn : TTaskBtn);
var
  i : Integer;
  s : String;
  mask : String;
  k : Integer;
  mk : Integer;
  m_mask : String;
  m_ii   : Integer = 0;
begin
  mk := -1;
  for i := 0 to IconMapList.Count - 1 do begin
    s := IconMapList[i];
    mask  := '';
    k := 0;

    if s[1] = '@' then begin
      mask  := ExtractWord(s, 3, '|');
    end;
    if s[1] = '$' then begin
      mask := ExtractWord(s, 3, '|');
    end;

    if (mask <> '') and MatchesMask(btn.title, mask) then Inc(k);
    if (k > 0) and (mk < k) then begin
      mk     := k;
      m_mask := mask;
      m_ii   := TMenuItem(IconMapList.Objects[i]).ImageIndex;
    end;
  end;

  if mk >= 0 then begin
    btn.IconMask   := m_mask;

    if btn.IconImageIndex <> m_ii then begin
      btn.IconImageIndex := m_ii;
      btn.Invalidate;
    end;
  end;

  if (mk < 0) and (btn.IconMask <> '') then begin
    btn.IconImageIndex := -1;
    btn.IconMask       := '';
    btn.Invalidate;
  end;
end;

function TSAPTaskBar.LoadIconFromFile: TMenuItem;
var
  png: TPortableNetworkGraphic;
  fname : String;

  buf : array[0..MAX_PATH] of char;
  fpc : PChar;
  exf : String;

  mi : TMenuItem;
  j : Integer;
begin
  Result := nil;
  if not IconOpenDialog.Execute then Exit;

  png := TPortableNetworkGraphic.Create;
  try
    png.LoadFromFile(IconOpenDialog.FileName);
    if (png.Width > 16) or (png.Height > 16) then begin
      MessageDlg(rsMsg007, mtError, [mbCancel], 0);
      Exit;
    end;

    fname := scIconsDir +'\' + ExtractFileName(IconOpenDialog.FileName);
    if FileExists(fname) then begin
      GetFullPathName(PChar(fname), SizeOf(buf), @buf, fpc);
      exf := buf;
      if SameText(exf, IconOpenDialog.FileName) then Exit;

      if MessageDlg(Format(rsMsg008,[ExtractFileName(IconOpenDialog.FileName)]), mtConfirmation, [mbOk, mbCancel], 0) = mrCancel then Exit;

      DeleteFile(fname);
    end;
    if not DirectoryExists(SelfDir +'\'+ scIconsDir) then CreateDir(SelfDir + '\'+ scIconsDir);
    png.SaveToFile(fname);

    if not png.Masked then png.Mask(png.Canvas.Pixels[0,0]);
    j := IconList.Add(png, nil);

    mi := TMenuItem.Create(Self);
    fname := ExtractFileName(fname);
    mi.Caption:= Copy(fname, 1, Length(fname) - Length(ExtractFileExt(fname)));
    miIcons.Add(mi);
    mi.ImageIndex:= j;
    mi.OnClick:= miIconSelectClick;

    Result := mi;
  finally
    png.Free;;
  end;
end;

function TSAPTaskBar.GetIconIndex(const IconName: String): Integer;
var
  i  : Integer;
  mi : TMenuItem;
begin
  Result := -1;
  if IconName = '' then Exit;

  for i := 0 to miIcons.Count - 1 do begin
    mi := miIcons.Items[i];
    if mi.Name <> '' then Continue;

    if SameText(mi.Caption, IconName) then begin
      Result := mi.ImageIndex;
      Break;
    end;
  end;
end;

procedure TSAPTaskBar.ApplyFilers;
// Применяем фильтры исходя из всех выбранных пользователем настроек
// Фильтры Систм и фильтры маркировки соеденены через или
// Если срабатывает какой либо фильтр - кнопка не видима, иначе видима

function MarkMI(const ImageIndex : Integer):TMenuItem;
var
  j  : Integer;
  mi : TMenuItem;
begin
  Result := nil;

  for j := 0 to ppmGroupAction.Items.Count - 1 do begin
    mi := ppmGroupAction.Items[j];
    if mi.ImageIndex = ImageIndex then begin
      Result := mi;
      Exit;
    end;
  end;
end;

var
  i : Integer;
  ctb : TTaskBtn;
  vt : Boolean;
  found : Boolean;

  mi : TMenuItem;
  SelFilterSelected : Boolean;

  filtered : Boolean;
begin
  found := False;
  filtered := False;

  SelFilterSelected := False;
  if miSelFilter.Checked then begin
    for i := 0 to ppmSapSys.Items.Count - 1 do begin
      mi := ppmSapSys.Items[i];
      if mi.GroupIndex <= 0 then Continue;
      if mi.Checked then begin
        SelFilterSelected := True;
        Break;
      end;
    end;
  end;

  for i := 0 to TBList.Count - 1 do begin
    ctb := TTaskBtn(TBList[i]);
    vt := True;

    if miFilter.Checked then begin
      if not ctb.sys.mi.Checked then vt := False;
    end;

    if miSelFilter.Checked and SelFilterSelected then begin
      if not ctb.sys.mi.Checked then vt := False;
    end;

    if micxNotMarked.Visible then begin
      if ctb.Mark then begin
        if not MarkMI(ctb.MarkImageIndex).Checked then vt := False;
      end;
      if not ctb.Mark then begin
        if not micxNotMarked.Checked then vt := False;
      end;
    end;

    if not vt then filtered := True;

    if ctb.Visible = vt then Continue;

    ctb.Visible := vt;

    if vt
    then MyShowWindow(ctb.hw, SW_SHOWNA)
    else MyShowWindow(ctb.hw, SW_HIDE);

    found := True;
  end;

  btnShowHiden.Visible:= filtered;

  if not found then Exit;

  SortButtons;

  plTasks.Left := 0;
  plTasks.Top  := 0;
end;

procedure TSAPTaskBar.MakeBigScreenShot(btn: TTaskBtn);
var
  w  : Integer;
  h  : Integer;
  dbmp : TBitmap32;

  hn : Integer;
  wn : Integer;
begin
  if btn.PreviewBmp = nil then btn.PreviewBmp := TBitmap32.Create;
  if Self.PreviewWidth  <= 0 then Self.PreviewWidth  := Screen.Width  div 4;
  if Self.PreviewHeight <= 0 then Self.PreviewHeight := Screen.Height div 4;

  w := sbmp_w;
  h := sbmp_h;

  wn := Self.PreviewWidth;
  hn := (wn * h) div w;
  if hn > Self.PreviewHeight then begin
    hn := Self.PreviewHeight;
    wn := (hn * w) div h;
  end;

  dbmp := btn.PreviewBmp;
  dbmp.Width := wn;
  dbmp.Height:= hn;

  SetStretchBltMode(dbmp.Canvas.Handle, STRETCH_HALFTONE);//устанавливаем режим сглаживания
  StretchBlt(dbmp.Canvas.Handle, 0, 0, wn, hn, sbmp.Canvas.Handle, 0, 0, w,  h, cmSrcCopy);

  btn.PreviewWidth  := wn;
  btn.PreviewHeight := hn;
end;

procedure TSAPTaskBar.PreviewShow(btn: TTaskBtn);
var
  pt : TPoint;
  r  : TRect;
  rw : Integer;
  rh : Integer;
  sr : TRect;
  wr : TRect;
begin
  if fmPreView.Visible and (fmPreView.Btn = btn) then Exit;

  if not Self.BtnData.HistShow then begin
    Self.BtnData.HistShow := True;
    Self.plTasks.Invalidate;
  end;

  fmPreView.Btn := Btn;

  GetWindowRect(fmPreView.Handle, r);

  rw := Btn.PreviewWidth  + GetSystemMetrics(SM_CXSIZEFRAME) * 2;
  rh := Btn.PreviewHeight + GetSystemMetrics(SM_CYSIZEFRAME) * 2;

  GetWindowRect(Self.Handle, sr);
  wr := Screen.WorkAreaRect;

  pt := btn.ClientToScreen(Point(btn.Width div 2, btn.Height div 2));

  if Direct = dtHorizontal then begin
    r.Left:= pt.x - rw div 2;
    if SAlign = alTop
    then r.Top:= sr.Bottom
    else r.Top:= sr.Top - rh;
  end;
  if Direct = dtVertical then begin
    r.Top:= pt.y - rh div 2;
    if SAlign = alLeft
    then r.Left:= sr.Right
    else r.Left:= sr.Left - rw;
  end;

  r.Right:= r.Left + rw;
  r.Bottom:= r.Top + rh;

  if r.Left < wr.Left then r.Left:= wr.Left;
  if r.Top < wr.Top then r.Top:= wr.Top;
  if r.Right > wr.Right then r.Left:= wr.Right - rw;
  if r.Bottom > wr.Bottom then r.Top:= wr.Bottom - rh;

  r.Right:= r.Left + rw;
  r.Bottom:= r.Top + rh;

  fmPreView.Visible:= True;

  MySetWindowPos(fmPreView.Handle, r);

  fmPreView.Invalidate;
end;

procedure TSAPTaskBar.PreviewEnd;
begin
  if not fmPreView.Visible then Exit;
  if KeyIsDown(VK_CONTROL) and KeyIsDown(VK_MENU) then Exit;

  fmPreView.Hide;
  if Self.BtnData.HistShow and not ShowStepHistory then begin
    Self.BtnData.HistShow := ShowStepHistory;
    Self.plTasks.Invalidate;
  end;
end;

procedure TSAPTaskBar.SetPlug;
var
  r : TRect;
begin
  if not Plug_Visible then Exit;

 GetWindowRect(Self.Handle, r);
 SetWindowPos(fmPlug.Handle, Self.Handle, r.Left, r.Top, r.Right - r.Left, r.Bottom - r.Top, SWP_SHOWWINDOW or SWP_NOACTIVATE);
end;

function TSAPTaskBar.isABAPDebugWin(const sysid, str: String): Integer;
var
  i : Integer;
  j : Integer;
  mask : String;
  num : String;
begin
  Result := -1;
  mask   := 'ABAP*(*)*(*)(*_'+sysid+'_??)';
  if not MatchesMask(str, mask) then Exit;
  i := Pos('(', str);
  j := Pos(')', str);

  num := Copy(str, i + 1, j - i - 1);
  Result := StrToInt(num);
end;

procedure TSAPTaskBar.SetTransparent(ATransparent: Boolean);
var
  attrib:longint;
begin
  if ATransparent then begin
    Self.Color:= $000002EE;
    attrib := GetWindowLong(Self.Handle, GWL_EXSTYLE);
    if (attrib and WS_EX_LAYERED) = 0 then begin
      SetWindowLong(Self.Handle, GWL_EXSTYLE, attrib or WS_EX_LAYERED);
      SetLayeredWindowAttributes(Self.Handle, Self.Color, 0, 1);
    end;
  end
  else begin
    Self.Color := clDefault;
  end;
end;

procedure TSAPTaskBar.GuiTuning;
var
  reg: TRegistry;
  int : Integer;
begin
  reg := TRegistry.Create;
  reg.Access:= KEY_READ or KEY_WRITE or KEY_WOW64_64KEY;
  reg.RootKey:= HKEY_CURRENT_USER;

  int := 0;
  if reg.OpenKey('Software\SAP\SAPGUI Front\SAP Frontend Server\Administration', True) then begin
    if reg.ValueExists('ShowAdditionalTitleInfo') then int := reg.ReadInteger('ShowAdditionalTitleInfo');

    if int <> 1 then begin
      reg.WriteInteger('ShowAdditionalTitleInfo', 1);
      if FindWindow(SapWindowClass, nil) <> 0
      then MessageDlg(rsMsg016, mtInformation, [mbOk], 0);
    end;

    reg.CloseKey;
  end;

  reg.Free;
end;

procedure TSAPTaskBar.DeleteButton(btn : TTaskBtn);
begin
  WaitForSingleObject(BMutex, INFINITE);
  try
    btn.Free;
  finally
    ReleaseMutex(BMutex);
  end;
end;

procedure MyShowWindow(hWnd:HWND; nCmdShow:longint);
var
  ar : TRect;
  tm : Integer;
  bsx : Integer;
  bsy : Integer;

function ShowWindowInt(xCmdShow:longint): Boolean;
var
  wr : TRect;
  i : Integer;
begin
  Result := False;

  case xCmdShow of
    SW_HIDE     : Result := not IsWindowVisible(hWnd);
    SW_SHOWNA   : Result := IsWindowVisible(hWnd);
    SW_MINIMIZE : Result := IsIconic(hWnd);
    SW_MAXIMIZE : begin
      if IsZoomed(hWnd) then begin
        GetWindowRect(hWnd, wr);
        if (Abs(wr.Left   - ar.Left)   > 3)
        or (Abs(wr.Top    - ar.Top)    > 3)
        or (Abs(wr.Right  - ar.Right)  > 3)
        or (Abs(wr.Bottom - ar.Bottom) > 4) // это не с проста так
        then begin
          PostMessage(hWnd, WM_SYSCOMMAND, SC_RESTORE, 0);
          for i := 0 to 20 do begin
            Sleep(100);
            Inc(tm);
            if tm > 20 then Exit;
            if not IsZoomed(hWnd) then Break;
          end;
        end
        else Result := True;
      end;
    end;
  end;

  if Result then Exit;

  case xCmdShow of
    SW_MAXIMIZE: PostMessage(hWnd, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
    SW_MINIMIZE: PostMessage(hWnd, WM_SYSCOMMAND, SC_MINIMIZE, 0);
  else ShowWindowAsync(hWnd, xCmdShow);
  end;
end;

function GetWindowState: Integer;
begin
  Result := 0;
  if IsIconic(hWnd) then Result := Result or $1;
  if IsZoomed(hWnd) then Result := Result or $2;
end;

var
  i  : Integer;
  wr  : TRect;
  WndState : Integer;
begin
// можно попробовать ещё SendMessageTimeout, SendMessageCallback
  tm := 0;
  case nCmdShow of
    SW_MAXIMIZE: begin
      ar := Screen.WorkAreaRect;
      GetWindowRect(hWnd, wr);
      bsx := GetSystemMetrics(SM_CXSIZEFRAME);
      Dec(ar.Left, bsx); Inc(ar.Right , bsx);
      bsy := GetSystemMetrics(SM_CYSIZEFRAME);
      Dec(ar.Top , bsy); Inc(ar.Bottom, bsy);
    end;
    SW_RESTORE : begin // Нельзя повторять restory несколько раз
      WndState := GetWindowState;
      if WndState = 0 then Exit;

      PostMessage(hWnd, WM_SYSCOMMAND, SC_RESTORE, 0);
      for i := 0 to 20 do begin
        if WndState <> GetWindowState then Exit;
      end;

      Exit;
    end;
  end;

  for i := 0 to 20 do begin
    if ShowWindowInt(nCmdShow) then Exit;
    Sleep(100);
    Inc(tm);
    if tm > 20 then Exit;
  end;
end;

procedure MySetWindowPos(hWnd: HWND; Rect: TRect);
var
  r : TRect;
  i : Integer;
begin
  for i := 0 to 20 do begin
    GetWindowRect(hWnd, r);
    if CompareMem(@Rect, @r, SizeOf(TRect)) then Break;
    SetWindowPos(hWnd, HWND_TOP, Rect.Left, Rect.Top, Rect.Right - Rect.Left, Rect.Bottom - Rect.Top, SWP_SHOWWINDOW or SWP_ASYNCWINDOWPOS);
    Sleep(100);
  end;
end;

procedure MySetForegroundWindow(hWnd: HWND);
var
  fhw : HWND;
  i : Integer;
begin
  for i := 0 to 10 do begin
    fhw := GetForegroundWindow;
    if hWnd = fhw then Break;

    SetForegroundWindow(hWnd); //BringWindowToTop(btn.hw);

    if i > 0 then Sleep(100);
    if i > 0 then Application.ProcessMessages;
  end;
end;

function WaitTerminationPrevRan:Boolean;
var
  i : Integer;
  wh : HWND;
begin
  Result := False;
  for i := 0 to 100 do begin
    wh := FindWindow('Window', SelfWindowName);
    if wh = 0 then begin
      Result := True;
      Exit;
    end;
    Sleep(100);
  end;
end;

function GetWndClassName(WND: HWND): String;
var
  buf: array[0..255] of char;
begin
  FillChar(buf{%H-}, SizeOf(buf), 0);
  GetClassName(WND, buf, SizeOf(buf));
  Result := buf;
end;

function GetWinVer: Integer;
var
  OSVersionInfo : TOSVersionInfo;
begin
  Result := 0;
  OSVersionInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  if not GetVersionEx(OSVersionInfo) then Exit;
// https://msdn.microsoft.com/en-us/library/windows/desktop/ms724834%28v=vs.85%29.aspx
  Result := OSVersionInfo.DwMajorVersion * 10 + OSVersionInfo.DwMinorVersion;
end;

function ISAeroEnabled: Boolean;
type
  _DwmIsCompositionEnabledFunc = function(var IsEnabled: Boolean): HRESULT; stdcall;
var
  Flag                       : Boolean;
  DllHandle                  : THandle;
  OsVersion                  : TOSVersionInfo;
  DwmIsCompositionEnabledFunc: _DwmIsCompositionEnabledFunc;
begin
  Result:=False;
  ZeroMemory(@OsVersion, SizeOf(OsVersion));
  OsVersion.dwOSVersionInfoSize := SizeOf(TOSVERSIONINFO);

  if ((GetVersionEx(OsVersion)) and (OsVersion.dwPlatformId = VER_PLATFORM_WIN32_NT) and (OsVersion.dwMajorVersion >= 6)) then //is Vista or Win7?
  begin
    DllHandle := LoadLibrary('dwmapi.dll');
    try
      if DllHandle <> 0 then
      begin
        @DwmIsCompositionEnabledFunc := GetProcAddress(DllHandle, 'DwmIsCompositionEnabled');
        if (@DwmIsCompositionEnabledFunc <> nil) then
        begin
          if DwmIsCompositionEnabledFunc(Flag)= S_OK then
           Result:=Flag;
        end;
      end;
    finally
      if DllHandle <> 0 then
        FreeLibrary(DllHandle);
    end;
  end;
end;


procedure OpenMySite;
begin
  ShellExecute(0, 'Open', PAnsiChar(MySite), nil, nil, SW_SHOWNORMAL);
end;

function KeyIsDown(vKey:longint): Boolean;
begin
  Result:=(Word(GetAsyncKeyState(vKey)) and $8000)<>0;
end;

procedure StrToFile(const FileName, SourceString : string);
var
  Stream : TFileStream;
begin
  Stream:= TFileStream.Create(FileName, fmCreate);
  try
    Stream.WriteBuffer(Pointer(SourceString)^, Length(SourceString));
  finally
    Stream.Free;
  end;
end;

function FileToStr(const FileName : string):string;
var
  Stream : TFileStream;
begin
  Stream:= TFileStream.Create(FileName, fmOpenRead);
  try
    SetLength(Result, Stream.Size);
    Stream.Position:=0;
    Stream.ReadBuffer(Pointer(Result)^, Stream.Size);
  finally
    Stream.Free;
  end;
end;

function Encrypt(const AKey, AValue, ACheckStr: string): string;
var
  EncSt: TBlowFishEncryptStream;
  sStream: TStringStream;
begin
  sStream := TStringStream.Create('');
  EncSt := TBlowFishEncryptStream.Create(AKey, sStream);
  EncSt.WriteAnsiString(EncodeStringBase64(ACheckStr + AValue));
  EncSt.Free;
  result := EncodeStringBase64(sStream.DataString);
  sStream.Free;
end;

function Decrypt(const AKey, AValue, ACheckStr: string): string;
var
  DecSt: TBlowFishDecryptStream;
  sStream: TStringStream;
  str : String;
  len : Integer;
begin
  Result := '';

  sStream := TStringStream.Create(DecodeStringBase64(AValue));
  DecSt := TBlowFishDeCryptStream.Create(AKey, sStream);
  try
    str := DecodeStringBase64(DecSt.ReadAnsiString);
  except
    on e: exception do begin;
    end;
  end;

  if Pos(ACheckStr, str) = 1 then begin
    len := Length(ACheckStr);
    Result := Copy(str, len + 1, Length(str) - len);
  end;

  DecSt.Free;
  sStream.Free;
end;

function Utf8ToAnsi(const Utf8Str: string): string;
begin
  result := ConvertEncoding(Utf8Str, 'UTF-8', GetDefaultTextEncoding);
end;





end.
