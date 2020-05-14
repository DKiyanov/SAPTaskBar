unit UHook;

{$MODE Delphi}

interface

uses Windows, SysUtils, Messages, UHookMsg;

type
  PMSLLHookStruct = ^TMSLLHookStruct;
  TMSLLHookStruct = packed record
    pt         : TPoint;
    mouseData  : DWORD;
    flag       : DWORD;
    time       : DWORD;
    dwExtraInfo: DWORD;
  end;

var
  WndHook   : HHook;
  MouseHook : HHook;
  KeyBoardHook: HHook;
  
  fWnd  : HWND;

  Lng : Boolean;

const
  WindowName = 'SAPTaskBar';
  WindowClass = 'Window'; //'TSAPTaskBar';

  SapWindowClass = 'SAP_FRONTEND_SESSION';

  WH_MOUSE_LL = 14;

procedure SetHook; stdcall;
procedure SetHookNLng; stdcall;
procedure UnHook; stdcall;

implementation

function GetWndClassName(WND: HWND): String;
var
  buf: array[0..355] of char;
begin
  FillChar(buf{%H-}, SizeOf(buf), 0);
  GetClassName(WND, buf, SizeOf(buf));
  Result := buf;
end;

procedure CheckAndSetLng(wnd : HWND);
var
  fgd_hwnd: HWND;
  afx_wnd : HWND;
  cb_wnd  : HWND;
  ed_wnd  : HWND;
begin
  if not Lng then Exit;

  if GetWndClassName(wnd) <> 'Edit' then Exit;

  fgd_hwnd := GetForegroundWindow;
  if fgd_hwnd = 0 then Exit;

  if GetWndClassName(fgd_hwnd) <> SapWindowClass then Exit;

  afx_wnd := GetWindow(fgd_hwnd, GW_CHILD); // Afx:...
  if afx_wnd = 0 then Exit;

  cb_wnd := GetWindow(afx_wnd, GW_CHILD); // ComboBox
  if cb_wnd = 0 then Exit;

  ed_wnd := GetWindow(cb_wnd, GW_CHILD); // Edit
  if ed_wnd <> wnd then Exit;

  if GetWndClassName(cb_wnd) <> 'ComboBox' then Exit;

  if (GetKeyboardLayout(0) and $0000FFFF) <> $00000409 // not english
  then LoadKeyboardLayout('00000409', KLF_ACTIVATE); // english
end;

function WndHookProc(code: integer; wParam: integer; lParam: integer): longword; stdcall;
var
  cwps : PCWPStruct;

function isSapWindow(wnd : HWND):Boolean;
// Столкнулся с проблемой - встроенный в сап Excel при закрытии вызывал WM_EXITSIZEMOVE
// при этом контекст dll уже был выгружен, в результате не возможно пользоваться константами и литералами
// обявленными в коде, хоть глобальными хоть локальными - без разницы
// обращение к константе приводило к падению Excel
var
  str : String;
  cur : PChar;
  hash : Integer;
begin
  Result := False;
  str := GetWndClassName(wnd);
  if Length(str) <> 20 then Exit;
  cur := PChar(str);
  hash := PInteger(cur)^ + PInteger(cur+4)^ + PInteger(cur+8)^ + PInteger(cur+12)^ + PInteger(cur+16)^;
  if hash <> -1820166753 then Exit;
  Result := True;
end;

begin
  if code< 0 then begin
    Result:=CallNextHookEx(WndHook,code,wParam,lparam);
    Exit;
  end;

  cwps := {%H-}PCWPStruct(lParam);

  if cwps.message = WM_SETFOCUS then begin
    CheckAndSetLng(cwps.hwnd);
  end;

  if cwps.message = WM_EXITSIZEMOVE then begin
    if isSapWindow(cwps.hwnd) then begin
      if fWnd = 0 then begin
        fWnd := FindWindow(WindowClass, WindowName);
      end;

      if fWnd <> 0 then begin
        PostMessage(fWnd, wm_My_ExitSizeMove, cwps.hwnd, 0);
      end;
    end;
  end;

  Result:=CallNextHookEx(WndHook,code,wParam,lparam);
end;

function WndHookProcLng(code: integer; wParam: integer; lParam: integer): longword; stdcall;
begin
  Lng := True;
  Result := WndHookProc(code, wParam, lParam);
end;

function WndHookProcNLng(code: integer; wParam: integer; lParam: integer): longword; stdcall;
begin
  Lng := False;
  Result := WndHookProc(code, wParam, lParam);
end;

function MouseHookProc(code: integer; wParam: integer; lParam: integer): longword; stdcall;
var
  wr : TRect;
  pm : PMSLLHookStruct;
begin
  if code< 0 then begin
    Result:=CallNextHookEx(MouseHook,code,wParam,lparam);
    Exit;
  end;

  if fWnd = 0 then begin
    fWnd := FindWindow(WindowClass, WindowName);
  end;

  if fWnd <> 0 then begin
    if IsWindowVisible(fWnd) then begin
      if wParam = WM_MOUSEWHEEL then begin // Нас интересует только прокрутка
        GetWindowRect(fWnd, wr{%H-});
        pm := {%H-}PMSLLHookStruct(lParam);
        if PtInRect(wr, pm.pt) then begin
          PostMessage(fWnd, wm_My_MouseWheel, wParam, LongInt(pm.mouseData));
          Result := 1;
          Exit;
        end;
      end;
    end
    else begin // not Visible
      if wParam = WM_MOUSEMOVE then begin
        GetWindowRect(fWnd, wr{%H-});
        pm := {%H-}PMSLLHookStruct(lParam);
        if PtInRect(wr, pm.pt) then begin
          PostMessage(fWnd, wm_My_MouseMove, wParam, MAKELPARAM(pm.pt.x, pm.pt.y) );
//          Result := 1;
//          Exit;
        end;
      end;
    end;
  end;

  Result:=CallNextHookEx(MouseHook,code,wParam,lparam);
end;

function KeyBoardHookProc(code: integer; wParam: integer; lParam: integer): longword; stdcall;
begin
  if code< 0 then begin
    Result:=CallNextHookEx(KeyBoardHook,code,wParam,lparam);
    Exit;
  end;

  if fWnd = 0 then begin
    fWnd := FindWindow(WindowClass, WindowName);
  end;

  if fWnd <> 0 then begin
    PostMessage(fWnd, wm_My_Key, wParam, lParam);
  end;

  Result:=CallNextHookEx(KeyBoardHook,code,wParam,lparam);
end;

procedure SetHook; stdcall;
begin
  WndHook  :=SetWindowsHookEx(WH_CALLWNDPROC, @WndHookProcLng, HInstance, 0);
  MouseHook:=SetWindowsHookEx(WH_MOUSE_LL   , @MouseHookProc, HInstance, 0);
  KeyBoardHook:=SetWindowsHookEx(WH_KEYBOARD, @KeyBoardHookProc,HInstance, 0);
end;

procedure SetHookNLng; stdcall;
begin
  WndHook  :=SetWindowsHookEx(WH_CALLWNDPROC, @WndHookProcNLng, HInstance, 0);
  MouseHook:=SetWindowsHookEx(WH_MOUSE_LL   , @MouseHookProc, HInstance, 0);
  KeyBoardHook:=SetWindowsHookEx(WH_KEYBOARD, @KeyBoardHookProc,HInstance, 0);
end;

procedure UnHook; stdcall;
begin
  UnhookWindowshookEx(WndHook);
  UnhookWindowshookEx(MouseHook);
  UnhookWindowshookEx(KeyBoardHook);
end;

initialization
  fWnd := 0;
  Lng := True;
end.
