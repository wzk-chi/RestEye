#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#ifndef SourceDir
  #define SourceDir "build\\windows\\x64\\runner\\Release"
#endif
#ifndef OutputDir
  #define OutputDir "artifacts"
#endif

[Setup]
AppId={{8F50D0A4-1A13-4F5D-9A5B-7F7C50C1D7E8}
AppName=RestEye
AppVersion={#AppVersion}
AppPublisher=RestEye
AppPublisherURL=https://github.com/
DefaultDirName={localappdata}\\Programs\\RestEye
DefaultGroupName=RestEye
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir={#OutputDir}
OutputBaseFilename=RestEye-{#AppVersion}-windows-x64-setup
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
UninstallDisplayName=RestEye
Uninstallable=yes

[Files]
Source: "{#SourceDir}\\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\\RestEye"; Filename: "{app}\\rest_eye.exe"; WorkingDir: "{app}"
Name: "{autodesktop}\\RestEye"; Filename: "{app}\\rest_eye.exe"; WorkingDir: "{app}"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "创建桌面快捷方式"; GroupDescription: "附加快捷方式："

[Run]
Filename: "{app}\\rest_eye.exe"; Description: "启动 RestEye"; Flags: nowait postinstall skipifsilent unchecked
