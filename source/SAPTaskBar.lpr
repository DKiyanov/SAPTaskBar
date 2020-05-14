program SAPTaskBar;

{$MODE Delphi}

uses
  Forms, Interfaces,
  USAPTaskBar in 'USAPTaskBar.pas' {SAPTaskBar},
  UOptions in 'UOptions.pas' {fmOptions},
  UConNameQuery in 'UConNameQuery.pas' {fmConNameQuery},
  UMapIcon in 'UMapIcon.pas' {fmMapIcon},
  UPreView in 'UPreView.pas' {fmPreView},
  UPlug in 'UPlug.pas' {fmPPlug},
  uPass in 'uPass.pass' {fmPassword};

{$R *.res}

begin
  if not WaitTerminationPrevRan then Exit;

  Application.Initialize;
  Application.CreateForm(TSAPTaskBar, fSAPTaskBar);
  Application.CreateForm(TfmOptions, fmOptions);
  Application.CreateForm(TfmConNameQuery, fmConNameQuery);
  Application.CreateForm(TfmMapIcon, fmMapIcon);
  Application.CreateForm(TfmPreView, fmPreView);
  Application.CreateForm(TfmPlug, fmPlug);
  Application.CreateForm(TfmPassword, fmPassword);
  Application.Run;
end.
