@echo off

setlocal enabledelayedexpansion

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

set debug=1

set ALIASES_CMD_PATH=%CMDER_ROOT%\config\user_aliases.cmd
set PROFILE_CMD_PATH=%CMDER_ROOT%\config\user_profile.cmd
set ALIASES_SH_PATH=%CMDER_ROOT%\config\user_aliases.sh
set PROFILE_SH_PATH=%CMDER_ROOT%\config\user_profile.sh
set ALIASES_PS1_PATH=%CMDER_ROOT%\config\user_aliases.ps1
set PROFILE_PS1_PATH=%CMDER_ROOT%\config\user_profile.ps1
set ALIASES_PS1_PS_PATH=%CMDER_ROOT%\config\user_aliases.ps1
set PROFILE_PS1_PS_PS_PATH=%CMDER_ROOT%\config\user_profile.ps1


call :is_symlink "%HOME%\.vimrc" ".yadr4win\\vimrc"
call :is_dir_symlink "%HOME%\.vim" ".yadr4win\\vim"
call :is_symlink "%HOME%\.gitconfig" ".yadr4win\\git\\gitconfig"
call :is_symlink "%HOME%\.tmux.conf" ".yadr4win\\tmux\\tmux.conf"
call :is_symlink "%CMDER_ROOT%\config\user-ConEmu.xml" ".yadr4win\\cmder\\user-Conemu.xml"
call :is_symlink "%ALIASES_CMD_PATH%" ".yadr4win\\user_aliases.cmd"
call :is_symlink "%ALIASES_PS1_PATH%" ".yadr4win\\user_aliases.ps1"
call :is_symlink "%ALIASES_SH_PATH%" ".yadr4win\\user_aliases.sh"

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

:is_symlink
  set symlink=%~1
  set symlink_target=%~2

  echo.
  echo Checking for "!symlink!" symlink...
  echo dir !symlink! ^| findstr /i "symlink" ^| findstr /i "!symlink_target!"
  dir !symlink! | findstr /i "symlink" | findstr /i "!symlink_target!" >nul
  set "is_symlink=%errorlevel%"
  REM call :debug_echo %is_symlink%:%symlink%
  echo %symlink%: %is_symlink%
  rem call :debug_echo !is_symlink! "%symlink%"
  exit /b

:is_dir_symlink
  set symlink=%~1
  set symlink_name=%~nx1
  set symlink_target=%~2

  echo.
  echo Checking for "!symlink!\" directory symlink...
  echo dir !symlink!\.. ^| findstr /i "symlinkd" ^| findstr /i /c:" %symlink_name% " ^| findstr /r "[!symlink_target!]"
  dir !symlink!\.. | findstr /i "symlinkd" | findstr /i /c:" %symlink_name% " | findstr /r "[!symlink_target!]">nul
  set "is_symlink=%errorlevel%"
  echo %symlink%: %is_symlink%
  rem call :debug_echo !is_symlink! "%symlink%"
  exit /b

