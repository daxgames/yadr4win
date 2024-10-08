@echo off

setlocal enabledelayedexpansion
set debug=0 ::This slows things down a lot if set to greater than 0
if exist "%cmder_root%\vendor\git-for-windows" (
  set cmder_full=1
)

if not "%~1" == "" call :%~1 & exit /b

call SetEscChar.cmd
if "%ConEmuANSI%" == "ON" (
  set green=%esc%[1;32;40m
  set red=%esc%[1;31;40m
  set gray=%esc%[0m
  set white=%esc%[1;37;40m
  set yellow=%esc%[33;40m
  set orange=%esc%[93;40m
) else (
  set green=
  set red=
  set gray=
  set white=
  set yellow=
  set orange=
)

FOR /F "TOKENS=2" %%A IN ('ECHO %DATE%') DO @FOR /F "TOKENS=1,2,3 DELIMS=/" %%B IN ('ECHO %%A') DO (
  @SET TIME_SHORT=%TIME::=%
  @SET TIME_SHORT=!TIME_SHORT: =!
  @SET BAK_EXT=yadr4win.%%D%%B%%C_!TIME_SHORT!
)

cd > "%TEMP%\curdir.txt"

set /p workdir=<"%TEMP%\curdir.txt"
if not defined HOME set "HOME=%USERPROFILE%"

if not "%WORKDIR%" == "%HOME%\.yadr4win" (
  if not exist "%HOME%\.yadr4win" md "%HOME%\.yadr4win"

  xcopy /s /e "%~DP0*" "%HOME%\.yadr4win\"
) else (
  echo "%WORKDIR%" == "%HOME%\.yadr4win"
)

call :is_dev_mode
if "%is_admin%" == "1" (
  call :debug_echo 3 "This script Must be run as Admin or Developer Mode must be enabled!"
  exit /b
else
  call :debug_echo "%is_admin%" "You are running as Admin or Developer Mode is enabled!"
)

set MSYS=winsymlinks:nativestict

call :is_symlink "%HOME%\.vimrc" ".yadr4win\vimrc"
if "%is_symlink%" EQU "1" (
  call :do_backup "%HOME%\.vimrc" !BAK_EXT! 
  ln -nsf "%HOME%\.yadr4win\vimrc" "%HOME%\.vimrc"
) else (
  echo -^> %HOME%\.vimrc is already hardlinked, nothing done.
)

call :is_symlink "%HOME%\.gitconfig" ".yadr4win\git\gitconfig"
if "%is_symlink%" EQU "1" (
  call :do_backup "%HOME%\.gitconfig" !BAK_EXT! 
  ln -nsf "%HOME%\.yadr4win\git\gitconfig" "%HOME%\.gitconfig"
) else (
  echo -^> %HOME%\.gitconfig is already hardlinked, nothing done.
)

REM call :is_symlink "%HOME%\.tmux.conf" ".yadr4win\tmux\tmux.conf"
REM if "%is_symlink%" EQU "1" (
REM   CALL :do_backup "%HOME%\.tmux.conf" !BAK_EXT! 
REM   ln -nsf "%HOME%\.yadr4win\tmux\tmux.conf" "%HOME%\.tmux.conf"
REM ) else (
REM   echo -^> %HOME%\.tmux.conf is already hardlinked, nothing done.
REM )

call :is_dir_symlink "%HOME%\.vim" "%HOME:\=\\%\\.yadr4win\\vim"
if "!is_symlink!" EQU "1" (
  CALL :do_backup "%HOME%\.vim" !BAK_EXT! 
  ln -nsf "%HOME%\.yadr4win\vim" "%HOME%\.vim"
) else (
  echo -^> %HOME%\.vim is already a symlink, nothing done.
)

if not exist "%HOME%\.vim\bundle" (
  echo mkdir "%HOME%\.vim\bundle"
  mkdir "%HOME%\.vim\bundle"
) else (
  echo -^> %HOME%\.vim\bundle is already created, nothing done.
)

if not exist "%HOME%\.vim\bundle\vundle.vim" (
  echo Installing 'vundle.vim'...
  git clone https://github.com/VundleVim/Vundle.vim.git "%HOME%\.vim\bundle\vundle.vim"
) else (
  echo -^> %HOME%\.vim\bundle\vundle.vim is already installed, nothing done.
)

echo.
if defined CMDER_ROOT (
  echo CMDER was found, configuring it if necessary...
  call :is_symlink "%CMDER_ROOT%\config\user-ConEmu.xml" ".yadr4win\cmder\user-Conemu.xml"
  if "!is_symlink!" EQU "1" (
    echo here
    CALL :do_backup "%CMDER_ROOT%\config\user-ConEmu.xml" !BAK_EXT! 
    ln -nsf "%HOME%\.yadr4win\cmder\user-ConEmu.xml" "%CMDER_ROOT%\config\user-ConEmu.xml"
  ) else (
    echo -^> %CMDER_ROOT%\config\user-ConEmu.xml is already hardlinked, nothing done.
  )

  echo Updating Cmder 'conemu.xml' with our version...
  CALL :do_backup "%CMDER_ROOT%\vendor\conemu-maximus5\ConEmu.xml" !BAK_EXT!
  cp "%CMDER_ROOT%\config\user-ConEmu.xml" "%CMDER_ROOT%\vendor\conemu-maximus5\ConEmu.xml"

  set ALIASES_CMD_PATH=%CMDER_ROOT%\config\user_aliases.cmd
  set PROFILE_CMD_PATH=%CMDER_ROOT%\config\user_profile.cmd
  set ALIASES_SH_PATH=%CMDER_ROOT%\config\user_aliases.sh
  set PROFILE_SH_PATH=%CMDER_ROOT%\config\user_profile.sh
  set ALIASES_PS1_PATH=%CMDER_ROOT%\config\user_aliases.ps1
  set PROFILE_PS1_PATH=%CMDER_ROOT%\config\user_profile.ps1
  set ALIASES_PS1_PS_PATH=$env:CMDER_ROOT\config\user_aliases.ps1
  set PROFILE_PS1_PS_PS_PATH=$env:CMDER_ROOT\config\user_profile.ps1

  set workdir=%cd%
  cd /d "%cmder_root%\bin"
  curl -LkO https://github.com/dandavison/delta/releases/download/0.17.0/delta-0.17.0-x86_64-pc-windows-msvc.zip
  unzip delta-0.17.0-x86_64-pc-windows-msvc.zip
  mv delta-0.17.0-x86_64-pc-windows-msvc\delta.exe .\
  rm delta-0.17.0-x86_64-pc-windows-msvc.zip
  curl -LkO https://github.com/cli/cli/releases/download/v2.54.0/gh_2.54.0_windows_amd64.zip
  unzip gh_2.54.0_windows_amd64.zip
  mv bin\gh.exe ./
  rm -rf bin
  rm -f gh_2.54.0_windows_amd64.zip
  cd /d "%workdir%"
) else (
  set ALIASES_CMD_PATH=%HOME%\.user_aliases.cmd
  set ALIASES_SH_PATH=%HOME%\.user_aliases.sh
  set ALIASES_PS1_PATH=%HOME%\Documents\WindowsPowerShell\user_aliases.ps1
  set PROFILE_PS1_PATH=%HOME%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
)

call :is_symlink "!ALIASES_CMD_PATH!" ".yadr4win\\user_aliases.cmd"
:: Need hardlink here because doskey.exe does not deal with softlinks
if "%is_symlink%" == "1" (
  call :do_backup "!ALIASES_CMD_PATH!" !BAK_EXT! 
  ln -nsf "!HOME!\.yadr4win\user_aliases.cmd" "!ALIASES_CMD_PATH!"
) else (
  echo -^> !ALIASES_CMD_PATH! is already hard linked, nothing done.
)

call :is_symlink "!ALIASES_PS1_PATH!" ".yadr4win\\user_aliases.ps1"
if "%is_symlink%" == "1" (
  call :do_backup "!ALIASES_PS1_PATH!" !BAK_EXT! 
  ln -nsf "!HOME!\.yadr4win\user_aliases.ps1" "!ALIASES_PS1_PATH!"
) else (
  echo -^> !ALIASES_PS1_PATH! is already hardlinked, nothing done.
)

echo "Checking '!ALIASES_PS1_PS_PATH!' is sourced in Powershell '!PROFILE_PS1_PATH!'..."
rem echo type "!PROFILE_PS1_PATH!" ^| findstr /i /r /c:"^^. !ALIASES_PS1_PS_PATH:\=\\!"
type "!PROFILE_PS1_PATH!" | findstr /i /r /c:"^. \"!ALIASES_PS1_PS_PATH:\=\\!\"">nul
if "!ERRORLEVEL!" == "1" (
  REM CALL :do_backup "!PROFILE_PS1_PATH!" !BAK_EXT!
  echo "Sourcing '!ALIASES_PS1_PS_PATH!' in Powershell '!PROFILE_PS1_PATH!'"
  echo . "!ALIASES_PS1_PS_PATH!" >> "!PROFILE_PS1_PATH!"
) else (
  call :debug_echo 0 "'!ALIASES_PS1_PS_PATH!' is already sourced in Powershell '!PROFILE_PS1_PATH!'."
)

call :is_symlink "!ALIASES_SH_PATH!" ".yadr4win\\user_aliases.sh"
if "%is_symlink%" == "1" (
  CALL :do_backup "!ALIASES_SH_PATH!" !BAK_EXT! 
  ln -nsf "!HOME!\.yadr4win\user_aliases.sh" "!ALIASES_SH_PATH!"
) else (
  echo -^> !ALIASES_SH_PATH! is already hardlinked, nothing done.
)

REM echo.
REM set do_gitconfig.user=0
REM if not exist "%HOME%\.gitconfig.user" (
REM   set do_gitconfig.user=8
REM ) else (
REM   type "%HOME%\.gitconfig.user" | findstr /i /R /C:"^\[user\]$">nul
REM   if !ERRORLEVEL! GTR 0 ( set /a do_gitconfig.user+=4 )
REM   type "%HOME%\.gitconfig.user" | findstr /i /R /C:"^ *name *= *[a-z]*.*$">nul
REM   if !ERRORLEVEL! GTR 0 ( set /a do_gitconfig.user+=2 )
REM   type "%HOME%\.gitconfig.user" | findstr /i /r /c:"^ *email *= .*@.*$">nul
REM   if !ERRORLEVEL! GTR 0 ( set /a do_gitconfig.user+=1 )
REM 
REM   if "%do_gitconfig.user%" == "8" (
REM     call :do_gitconfig.user
REM   ) else if "%do_gitconfig.user%" GEQ "1" if "%do_gitconfig.user%" LEQ "7" (
REM     call :do_gitconfig.user
REM   )
REM )

call :do_dos2unix

echo.
echo All files that were not linked to .yadr4win files were backed up with a "[FILENAME].%BAK_EXT%".
echo.
echo If you are sure you have not lost anything you can clean these up by typing the following:
echo   "%HOME%\.yadr4win\cleanup.cmd"

echo.
echo Verifying...
set debug=1
call :is_symlink "%HOME%\.vimrc" ".yadr4win\\vimrc"
call :is_dir_symlink "%HOME%\.vim" ".yadr4win\\vim"
call :is_symlink "%HOME%\.gitconfig" ".yadr4win\\git\\gitconfig"
call :is_symlink "%HOME%\.tmux.conf" ".yadr4win\\tmux\\tmux.conf"
call :is_symlink "%CMDER_ROOT%\config\user-ConEmu.xml" ".yadr4win\\cmder\\user-Conemu.xml"
call :is_symlink "!ALIASES_CMD_PATH!" ".yadr4win\\user_aliases.cmd"
call :is_symlink "!ALIASES_PS1_PATH!" ".yadr4win\\user_aliases.ps1"
call :is_symlink "!ALIASES_SH_PATH!" ".yadr4win\\user_aliases.sh"

exit /b

:do_backup
  set SOURCE_FILE=%~1
  set BACKUP_FILE=%~1.%~2

  if exist "%SOURCE_FILE%" (
    echo.
    echo Backing up "%SOURCE_FILE%" to "%BACKUP_FILE%"
    move "%SOURCE_FILE%" "%BACKUP_FILE%"
  )
  exit /b

:is_junction
  set junction=%~1
  set junction_target=%~2

  echo.
  echo Checking for "!junction!" junction...
  dir !junction!\.. | findstr /i "junction" | findstr /i "!junction_target!" >nul
  set "is_junction=%errorlevel%"
  call :debug_echo %is_junction% "%junction%"
  exit /b

:is_dir_symlink
  set symlink=%~1
  set symlink_name=%~nx1
  set symlink_target=%~2

  echo.
  echo Checking for "!symlink!\" directory symlink...
  rem echo dir !symlink!\.. ^| findstr /i "symlinkd" ^| findstr /i /c:" %symlink_name% " ^| findstr /r "[!symlink_target!]"
  dir !symlink!\.. | findstr /i "symlinkd" | findstr /i /c:" %symlink_name% " | findstr /r "[!symlink_target!]">nul
  set "is_symlink=%errorlevel%"
  call :debug_echo !is_symlink! "%symlink%"
  exit /b

:is_symlink
  set symlink=%~1
  set symlink_target=%~2

  echo.
  echo Checking for "!symlink!" symlink...
  dir !symlink! | findstr /i "symlink" | findstr /i "!symlink_target!" >nul
  set "is_symlink=%errorlevel%"
  REM call :debug_echo %is_symlink%:%symlink%
  call :debug_echo !is_symlink! "%symlink%"
  exit /b

:create_symlink
  if "%~1" == "/d" (
    set mklink_args=%~1\
    set mklink_source=%~2
    set mklink_dest=%~3
  ) else (
    set mklink_source=%~1
    set mklink_dest=%~2
  )

  if exist "%mklink_dest%" ( del /y "%mklink_dest%" )
  
  mklink %mklink_args% "%mklink_dest%" "%mklink_source%"
  exit /b

:is_hardlink
  set hardlink=%~1
  set hardlink_target=%~2

  if not exist "%hardlink%" (
    echo.
    set "is_hardlink=1"
    call :debug_echo !is_hardlink! "%hardlink%"
    exit /b
  )

  echo.
  echo Checking for "!hardlink!" hardlink...
  rem fsutil hardlink list "!hardlink!"
  rem echo fsutil hardlink list "!hardlink!" ^| findstr /i /c:"!hardlink_target!"
  fsutil hardlink list "!hardlink!" | findstr /i /c:"!hardlink_target!"
  set "is_hardlink=%errorlevel%"
  call :debug_echo !is_hardlink! "%hardlink%"
  exit /b

:debug_run
  if "%debug%" GTR "0" (
    %Windir%\System32\WindowsPowerShell\v1.0\Powershell.exe -noprofile -command "& { $output = %* | out-string ; write-host -foregroundcolor Yellow DEBUG: %*`n$output }
  )
  exit /b

:debug_echo
  set status=%~1
  set message=%~2
  shift

  if "%status%" == "0" (
    set color=%green%
  )

  if "%status%" == "1" (
    set color=%yellow%
  )

  if "%status%" == "3" (
    set color=%red%
  )

  echo %color%%message%%white%

  exit /b

:is_dev_mode
  if exist "%TEMP%\test.tmp" del "%TEMP%\test.tmp"
  ln -nsf %~DP0README.md "%TEMP%\test.tmp" >nul
  if "%ERRORLEVEL%" == "0" (
    if exist "%TEMP%\test.tmp" del "%TEMP%\test.tmp"
    set is_admin=0
    exit /b
  ) else (
    echo This script requires that you have administrative privileges.
    set is_admin=1
    pause
    exit /b
  )
  exit /b

REM :do_gitconfig.user
REM   echo We need to setup your user Git configuration so your commits are attributed to you.
REM   echo.
REM   echo All custom user Git configuration should go in "%HOME%\.gitconfig.user"
REM   echo.
REM 
REM   set /p "user.name=Type Your Name: "
REM   set /p "user.email=Type Your Email Address: "
REM 
REM   if "%user.name%" neq "" if "%user.email%" neq "" (
REM     CALL :do_backup "%HOME%\.gitconfig.user !BAK_EXT! 
REM     echo [user]>"%HOME%\.gitconfig.user"
REM     echo   name = %user.name%>>"%HOME%\.gitconfig.user
REM     echo   email = %user.email%>>"%HOME%\.gitconfig.user
REM 
REM     if %do_gitconfig.user% GEQ 1 if %do_gitconfig.user% LEQ 7 (
REM       type "%HOME%\.gitconfig.user.bak" | Findstr /v /i /R /C:"^\n$" | Findstr /v /i /R /C:"^\[user\]$" | findstr /v /i /R /C:"^ *name *= *[a-z]*.*$" | findstr /v /i /r /c:"^ *email *= *[a-z]*@.*$" >> "%HOME%\.gitconfig.user"
REM       del "%HOME%\.gitconfig.user.bak"
REM     )
REM     echo User git config is done.
REM   ) else (
REM     echo Either username or email was not specified no changes will be made.
REM   )
REM   exit /b

:do_dos2unix
  if exist "%cmder_root%\vendor\git-for-windows\usr\bin\find.exe" (
    set find_path="%cmder_root%\vendor\git-for-windows\usr\bin\find.exe"
  )

  echo find=%find_path%

  if exist "%cmder_root%\vendor\git-for-windows\usr\bin\dos2unix.exe" (
    set dos2unix_path=%cmder_root%\vendor\git-for-windows\usr\bin\dos2unix.exe
  )

  echo dos2unix=%dos2unix_path%

  if exist "%cmder_root%\vendor\git-for-windows\usr\bin\find.exe" (
    if exist "%cmder_root%\vendor\git-for-windows\usr\bin\dos2unix.exe" (
      if exist "%cmder_root%\vendor\git-for-windows\usr\bin\xargs.exe" (
        echo Please wait converting required files to unix format...
        cd /d %~DP0
        echo %find_path% . -type f -name '*.sh' ^| xargs "%dos2unix_path%"
        %find_path% . -type f -name '*.sh' | xargs "%dos2unix_path%" 2>nul

        echo %find_path% . -type f -name '*.vim' ^| xargs "%dos2unix_path%"
        %find_path% . -type f -name '*.vim' | xargs "%dos2unix_path%" 2>nul

        echo %find_path% . -type f -name '*.vundle' ^| xargs "%dos2unix_path%"
        %find_path% . -type f -name '*.vundle' | xargs "%dos2unix_path%" 2>nul
      )
    )
  ) else (
    echo.
    echo WARNING: dos2unix is not found!  Some things may not work in that require unix file endings.
  )
  exit /b
