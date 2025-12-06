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

if not "%WORKDIR%" == "%USERPROFILE%\.yadr4win" (
  if not exist "%USERPROFILE%\.yadr4win" md "%USERPROFILE%\.yadr4win"

  xcopy /s /e "%~DP0*" "%USERPROFILE%\.yadr4win\"
) else (
  echo "%WORKDIR%" == "%USERPROFILE%\.yadr4win"
)

powershell -f "%WORKDIR%\bin\install-windows-pre.ps1

call :is_dev_mode
if "%is_dev_mode%" == "1" (
  call :debug_echo 3 "This script Must be run as Admin or Developer Mode must be enabled!"
  exit /b
else
  call :debug_echo "%is_dev_mode%" "You are running as Admin or Developer Mode is enabled!"
)

call :is_symlink "%USERPROFILE%\.vimrc" ".yadr4win\vimrc"
if "%is_symlink%" EQU "1" (
  call :do_backup "%USERPROFILE%\.vimrc" !BAK_EXT!
  mklink "%USERPROFILE%\.vimrc" "%USERPROFILE%\.yadr4win\vimrc"
) else (
  echo -^> %USERPROFILE%\.vimrc is already symlinked, nothing done.
)

call :is_symlink "%USERPROFILE%\.gitconfig" ".yadr4win\git\gitconfig"
if "%is_symlink%" EQU "1" (
  call :do_backup "%USERPROFILE%\.gitconfig" !BAK_EXT!
  mklink "%USERPROFILE%\.gitconfig" "%USERPROFILE%\.yadr4win\git\gitconfig"
) else (
  echo -^> %USERPROFILE%\.gitconfig is already symlinked, nothing done.
)

call :is_symlink "%USERPROFILE%\.tmux.conf" ".yadr4win\tmux\tmux.conf"
if "%is_symlink%" EQU "1" (
  CALL :do_backup "%USERPROFILE%\.tmux.conf" !BAK_EXT!
  mklink "%USERPROFILE%\.tmux.conf" "%USERPROFILE%\.yadr4win\tmux\tmux.conf"
) else (
  echo -^> %USERPROFILE%\.tmux.conf is already symlinked, nothing done.
)

call :is_dir_symlink "%USERPROFILE%\.vim" "%USERPROFILE:\=\\%\\.yadr4win\\vim"
if "!is_symlink!" EQU "1" (
  CALL :do_backup "%USERPROFILE%\.vim" !BAK_EXT!
  mklink /d "%USERPROFILE%\.vim" "%USERPROFILE%\.yadr4win\vim"
) else (
  echo -^> %USERPROFILE%\.vim is already a symlink, nothing done.
)

if not exist "%USERPROFILE%\.vim\bundle" (
  echo mkdir "%USERPROFILE%\.vim\bundle"
  mkdir "%USERPROFILE%\.vim\bundle"
) else (
  echo -^> %USERPROFILE%\.vim\bundle is already created, nothing done.
)

if not exist "%USERPROFILE%\.vim\bundle\Vundle.vim" (
  echo Installing 'Vundle.vim'...
  git clone https://github.com/VundleVim/Vundle.vim.git "%USERPROFILE%\.vim\bundle\Vundle.vim"
) else (
  echo -^> %USERPROFILE%\.vim\bundle\Vundle.vim is already installed, nothing done.
)

echo.
if defined CMDER_ROOT (
  echo CMDER was found, configuring it if necessary...
  call :is_symlink "%CMDER_ROOT%\config\user-ConEmu.xml" ".yadr4win\cmder\user-Conemu.xml"
  if "!is_symlink!" EQU "1" (
    echo here
    CALL :do_backup "%CMDER_ROOT%\config\user-ConEmu.xml" !BAK_EXT!
    mklink "%CMDER_ROOT%\config\user-ConEmu.xml" "%USERPROFILE%\.yadr4win\cmder\user-ConEmu.xml"
  ) else (
    echo -^> %CMDER_ROOT%\config\user-ConEmu.xml is already symlinked, nothing done.
  )

  echo Updating Cmder 'conemu.xml' with our version...
  CALL :do_backup "%CMDER_ROOT%\vendor\conemu-maximus5\ConEmu.xml" !BAK_EXT!
  cp  "%CMDER_ROOT%\config\user-ConEmu.xml" "%CMDER_ROOT%\vendor\conemu-maximus5\ConEmu.xml"

  set ALIASES_CMD_PATH=%CMDER_ROOT%\config\user_aliases.cmd
  set PROFILE_CMD_PATH=%CMDER_ROOT%\config\user_profile.cmd
  set ALIASES_SH_PATH=%CMDER_ROOT%\config\user_aliases.sh
  set PROFILE_SH_PATH=%CMDER_ROOT%\config\user_profile.sh
  set ALIASES_PS1_PATH=%CMDER_ROOT%\config\user_aliases.ps1
  set PROFILE_PS1_PATH=%CMDER_ROOT%\config\user_profile.ps1
  set ALIASES_PS1_PS_PATH=$env:CMDER_ROOT\config\user_aliases.ps1
  set PROFILE_PS1_PS_PS_PATH=$env:CMDER_ROOT\config\user_profile.ps1
) else (
  set ALIASES_CMD_PATH=%USERPROFILE%\.user_aliases.cmd
  set ALIASES_SH_PATH=%USERPROFILE%\.user_aliases.sh
  set ALIASES_PS1_PATH=%USERPROFILE%\Documents\WindowsPowerShell\user_aliases.ps1
  set PROFILE_PS1_PATH=%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
)

if defined PROFILE_CMD_PATH (
  call :is_symlink "!PROFILE_CMD_PATH!" "%USERPROFILE%\.yadr4win\cmder\config\user_profile.cmd"
  if "%is_symlink%" == "1" (
    call :do_backup "!PROFILE_CMD_PATH!" !BAK_EXT!
    mklink "!PROFILE_CMD_PATH!" "%USERPROFILE%\.yadr4win\cmder\config\user_profile.cmd"
  ) else (
    echo -^> !PROFILE_CMD_PATH! is already symlinked, nothing done.
  )
) else (
  echo PROFILE_CMD_PATH not defined.
)

if defined ALIASES_CMD_PATH (
  call :is_hardlink "!ALIASES_CMD_PATH!" "%USERPROFILE%\.yadr4win\user_aliases.cmd"
  :: Need hardlink here because doskey.exe does not deal with softlinks
  if "%is_hardlink%" == "1" (
    call :do_backup "!ALIASES_CMD_PATH!" !BAK_EXT!
    fsutil hardlink create "!ALIASES_CMD_PATH!" "%USERPROFILE%\.yadr4win\user_aliases.cmd"
  ) else (
    echo -^> !ALIASES_CMD_PATH! is already hard linked, nothing done.
  )
) else (
  echo ALIASES_CMD_PATH not defined.
)
pause

if defined PROFILE_SH_PATH (
  call :is_symlink "!PROFILE_SH_PATH!" "%USERPROFILE%\.yadr4win\cmder\config\user_profile.sh"
  if "%is_symlink%" == "1" (
    call :do_backup "!PROFILE_SH_PATH!" !BAK_EXT!
    mklink "!PROFILE_SH_PATH!" "%USERPROFILE%\.yadr4win\cmder\config\user_profile.sh"
  ) else (
    echo -^> !PROFILE_SH_PATH! is already symlinked, nothing done.
  )
) else (
  echo PROFILE_SH_PATH not defined.
)

if defined ALIASES_SH_PATH (
  call :is_symlink "!ALIASES_SH_PATH!" "%USERPROFILE%\.yadr4win\user_aliases.sh"
  if "%is_symlink%" == "1" (
    CALL :do_backup "!ALIASES_SH_PATH!" !BAK_EXT!
    mklink "!ALIASES_SH_PATH!" "%USERPROFILE%\.yadr4win\user_aliases.sh"
  ) else (
    echo -^> !ALIASES_SH_PATH! is already symlinked, nothing done.
  )
) else (
  echo ALIASES_SH_PATH not defined.
)

if defined PROFILE_PS1_PATH (
  call :is_symlink "!PROFILE_PS1_PATH!" "%USERPROFILE%\.yadr4win\cmder\config\user_profile.ps1"
  if "%is_symlink%" == "1" (
    call :do_backup "!PROFILE_PS1_PATH!" !BAK_EXT!
    mklink "!PROFILE_PS1_PATH!" "%USERPROFILE%\.yadr4win\cmder\config\user_profile.ps1"
  ) else (
    echo -^> !PROFILE_PS1_PATH! is already symlinked, nothing done.
  )
) else (
  echo PROFILE_PS1_PATH not defined.
)

if defined ALIASES_PS1_PATH (
  call :is_symlink "!ALIASES_PS1_PATH!" "%USERPROFILE%\.yadr4win\user_aliases.ps1"
  if "%is_symlink%" == "1" (
    call :do_backup "!ALIASES_PS1_PATH!" !BAK_EXT!
    mklink "!ALIASES_PS1_PATH!" "%USERPROFILE%\.yadr4win\user_aliases.ps1"
  ) else (
    echo -^> !ALIASES_PS1_PATH! is already symlinked, nothing done.
  )
) else (
  echo ALIASES_PS1_PATH not defined.
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

echo.
set do_gitconfig.user=0
if not exist "%USERPROFILE%\.gitconfig.user" (
  set do_gitconfig.user=8
) else (
  type "%USERPROFILE%\.gitconfig.user" | findstr /i /R /C:"^\[user\]$">nul
  if !ERRORLEVEL! GTR 0 ( set /a do_gitconfig.user+=4 )
  type "%USERPROFILE%\.gitconfig.user" | findstr /i /R /C:"^ *name *= *[a-z]*.*$">nul
  if !ERRORLEVEL! GTR 0 ( set /a do_gitconfig.user+=2 )
  type "%USERPROFILE%\.gitconfig.user" | findstr /i /r /c:"^ *email *= .*@.*$">nul
  if !ERRORLEVEL! GTR 0 ( set /a do_gitconfig.user+=1 )

  if "%do_gitconfig.user%" == "8" (
    call :do_gitconfig.user
  ) else if "%do_gitconfig.user%" GEQ "1" if "%do_gitconfig.user%" LEQ "7" (
    call :do_gitconfig.user
  )
)

call :do_dos2unix

echo.
echo Verifying...
set debug=1
call :is_symlink "%USERPROFILE%\.vimrc" ".yadr4win\vimrc"
call :is_dir_symlink "%USERPROFILE%\.vim" ".yadr4win\vim"
call :is_symlink "%USERPROFILE%\.gitconfig" ".yadr4win\git\gitconfig"
call :is_symlink "%USERPROFILE%\.tmux.conf" ".yadr4win\tmux\tmux.conf"
call :is_symlink "%CMDER_ROOT%\config\user-ConEmu.xml" ".yadr4win\cmder\user-Conemu.xml"
call :is_hardlink "!ALIASES_CMD_PATH!" ".yadr4win\user_aliases.cmd"
call :is_symlink "!ALIASES_PS1_PATH!" ".yadr4win\user_aliases.ps1"
call :is_symlink "!ALIASES_SH_PATH!" ".yadr4win\user_aliases.sh"

echo.
echo All files that were not linked to .yadr4win files were backed up with a "[FILENAME].%BAK_EXT%".
echo.
echo If you are sure you have not lost anything you can clean these up by typing the following:
echo   "%USERPROFILE%\.yadr4win\cleanup.cmd"

endlocal
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
  dir !junction!\.. | findstr /i "junction" | findstr /i "!junction_target:\=\\!" >nul
  set "is_junction=%errorlevel%"
  call :debug_echo %is_junction% "%junction%"
  exit /b

:is_dir_symlink
  set symlink=%~1
  set symlink_name=%~nx1
  set symlink_target=%~2

  echo.
  echo Checking for "!symlink!\" directory symlink...
  rem echo dir !symlink!\.. ^| findstr /i "symlinkd" ^| findstr /i /c:" %symlink_name% " ^| findstr /r "[!symlink_target:\=\\!]"
  dir !symlink!\.. | findstr /i "symlinkd" | findstr /i /c:" %symlink_name% " | findstr /r "[!symlink_target:\=\\!]">nul
  set "is_symlink=%errorlevel%"
  call :debug_echo !is_symlink! "%symlink%"
  exit /b

:is_symlink
  set symlink=%~1
  set symlink_target=%~2

  echo.
  echo Checking for "!symlink_target!" in symlink "!symlink!"...
  dir !symlink! | findstr /i "symlink" | findstr /i "!symlink_target:\=\\!" >nul
  set exit_code=%errorlevel%
  if "%exit_code%" == "1" (
    echo !symlink! is not a symlink to !symlink_target!...
    pause
  )
  set "is_symlink=%exit_code%"
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
  fsutil hardlink list "!hardlink!" | findstr /i /c:"!hardlink_target:\=\\!"
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
  fsutil hardlink create "%TEMP%\test.tmp" %~DP0README.md>nul
  if "%ERRORLEVEL%" == "0" (
    if exist "%TEMP%\test.tmp" del "%TEMP%\test.tmp"
    set is_dev_mode=0
    exit /b
  ) else (
    echo This script requires that you have administrative privileges.
    set is_dev_mode=1
    exit /b
  )
  exit /b

:do_gitconfig.user
  echo We need to setup your user Git configuration so your commits are attributed to you.
  echo.
  echo All custom user Git configuration should go in "%USERPROFILE%\.gitconfig.user"
  echo.

  set /p "user.name=Type Your Name: "
  set /p "user.email=Type Your Email Address: "

  if "%user.name%" neq "" if "%user.email%" neq "" (
    CALL :do_backup "%USERPROFILE%\.gitconfig.user !BAK_EXT!
    echo [user]>"%USERPROFILE%\.gitconfig.user"
    echo   name = %user.name%>>"%USERPROFILE%\.gitconfig.user
    echo   email = %user.email%>>"%USERPROFILE%\.gitconfig.user

    if %do_gitconfig.user% GEQ 1 if %do_gitconfig.user% LEQ 7 (
      type "%USERPROFILE%\.gitconfig.user.bak" | Findstr /v /i /R /C:"^\n$" | Findstr /v /i /R /C:"^\[user\]$" | findstr /v /i /R /C:"^ *name *= *[a-z]*.*$" | findstr /v /i /r /c:"^ *email *= *[a-z]*@.*$" >> "%USERPROFILE%\.gitconfig.user"
      del "%USERPROFILE%\.gitconfig.user.bak"
    )
    echo User git config is done.
  ) else (
    echo Either username or email was not specified no changes will be made.
  )
  exit /b

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
