@echo off

setlocal enabledelayedexpansion
set debug=0 ::This slows things down a lot if set to greater than 0

FOR /F "TOKENS=2" %%A IN ('ECHO %DATE%') DO @FOR /F "TOKENS=1,2,3 DELIMS=/" %%B IN ('ECHO %%A') DO (
  @SET TIME_SHORT=%TIME::=%
  @SET TIME_SHORT=!TIME_SHORT: =!
  @SET BAK_EXT=yadr4win.%%D%%B%%C_!TIME_SHORT!
)

call :is_admin
call :debug_echo "%is_admin%"
if "%is_admin%" == "0" (
  echo.
  echo Checking for "%USERPROFILE%\.vimrc" soft link...
  call :is_symlink "%USERPROFILE%\.vimrc" ".yadr4win\\vimrc]"
  if "!is_symlink!" EQU "1" (
    echo Backing up "%USERPROFILE%\.vimrc" to ".vimrc.%bak_ext%
    if exist "%USERPROFILE%\.vimrc" ren "%USERPROFILE%\.vimrc" ".vimrc.%bak_ext%"
    mklink "%USERPROFILE%\.vimrc" "%USERPROFILE%\.yadr4win\vimrc"
  ) else (
    echo -^> %USERPROFILE%\.vimrc is already symlinked, nothing done.
  )

  echo.
  echo Checking for "%USERPROFILE%\.gitconfig" soft link...
  call :is_symlink "%USERPROFILE%\.gitconfig" ".yadr4win\\git\\gitconfig]"
  if "!is_symlink!" EQU "1" (
    echo Backing up "%USERPROFILE%\.gitconfig" to ".gitconfig.%bak_ext%
    if exist "%USERPROFILE%\.gitconfig" ren "%USERPROFILE%\.gitconfig" ".gitconfig.%bak_ext%"
    mklink "%USERPROFILE%\.gitconfig" "%USERPROFILE%\.yadr4win\git\gitconfig"
  ) else (
    echo -^> %USERPROFILE%\.gitconfig is already symlinked, nothing done.
  )

  echo.
  echo Checking for "%USERPROFILE%\.tmux.conf" soft link...
  call :is_symlink "%USERPROFILE%\.tmux.conf" ".yadr4win\\tmux\\tmux.conf]"
  if "!is_symlink!" EQU "1" (
    echo Backing up "%USERPROFILE%\.tmux.conf" to ".tmux.conf.%bak_ext%
    if exist "%USERPROFILE%\.tmux.conf" ren "%USERPROFILE%\.tmux.conf" ".tmux.conf.%bak_ext%"
    mklink "%USERPROFILE%\.tmux.conf" "%USERPROFILE%\.yadr4win\tmux\tmux.conf"
  ) else (
    echo -^> %USERPROFILE%\.tmux.conf is already symlinked, nothing done.
  )

  echo.
  echo Checking for "%USERPROFILE%\.vim" soft link...
  call :is_symlink "%USERPROFILE%" ".yadr4win\\vim]"
  if "!is_symlink!" EQU "1" (
    echo Backing up "%USERPROFILE%\.vim" to ".vim.%bak_ext%
    if exist "%USERPROFILE%\.vim" move "%USERPROFILE%\.vim" "%USERPROFILE%\.vim.yad4rwin"
    mklink /d "%USERPROFILE%\.vim" "%USERPROFILE%\.yadr4win\vim"
  ) else (
    echo -^> %USERPROFILE%\.vim is already symlinked, nothing done.
  )

  echo.
  echo Checking for "%USERPROFILE%\.vim\bundle\vundle.vim" install...
  if not exist "%USERPROFILE%\.vim\bundle" (
    mkdir "%USERPROFILE%\.vim\bundle"
  ) else (
    echo -^> %USERPROFILE%\.vim\bundle is already created, nothing done.
  )

  if not exist "%USERPROFILE%\.vim\bundle\vundle.vim" (
    echo Installing 'vundle.vim'...
    git clone https://github.com/VundleVim/Vundle.vim.git "%USERPROFILE%\.vim\bundle\vundle.vim"
  ) else (
    echo -^> %USERPROFILE%\.vim\bundle\vundle.vim is already installed, nothing done.
  )

  echo.
  echo Checking for "Cmder" install...
  if defined CMDER_ROOT (
    echo CMDER was found, configuring it if necessary...
    call :is_symlink "%CMDER_ROOT%\MyCmder.cmd" ".yadr4win\\cmder\\MyCmder.cmd"
    if "!is_symlink!" EQU "1" (
      mklink "%CMDER_ROOT%\MyCmder.cmd" "%USERPROFILE%\.yadr4win\cmder\MyCmder.cmd"
    ) else (
      echo -^> %CMDER_ROOT%\MyCmder.cmd is already symlinked, nothing done.
    )

    if exist "%CMDER_ROOT%\Mycmder.bat" del "%CMDER_ROOT%\Mycmder.bat"

    call :is_symlink "%CMDER_ROOT%\config\user-ConEmu.xml" ".yadr4win\\cmder\\user-Conemu.xml"
    if "!is_symlink!" EQU "1" (
      if exist "%CMDER_ROOT%\config\user-ConEmu.xml" mv "%CMDER_ROOT%\config\user-ConEmu.xml" "%CMDER_ROOT%\config\user-ConEmu.xml.%bak_ext%"
      mklink "%CMDER_ROOT%\config\user-ConEmu.xml" "%USERPROFILE%\.yadr4win\cmder\user-ConEmu.xml"
    ) else (
      echo -^> %CMDER_ROOT%\config\user-ConEmu.xml is already symlinked, nothing done.
    )

    set ALIASES_PATH=%CMDER_ROOT%\config\aliases
    set ALIASES_SH_PATH=%CMDER_ROOT%\config\user-aliases.sh
  ) else (
    set ALIASES_PATH=%USER_PROFILE%\.aliases
    set ALIASES_SH_PATH=%USER_PROFILE%\.aliases.sh
  )

  echo.
  echo Checking for "!ALIASES_PATH!" hard link...
  :: Need hardlink here because doskey.exe does not deal with symlinks
  call :debug_echo ALIASES=!ALIASES_PATH!
  call :is_hardlink "!ALIASES_PATH!" ".yadr4win\\aliases"
  if "!is_hardlink!" == "1" (
    echo Backing up "!ALIASES_PATH!" to "!ALIASES_PATH!.%bak_ext%"
    move "!ALIASES_PATH!" "!ALIASES_PATH!.%bak_ext%"
    mklink /h "!ALIASES_PATH!" "!USERPROFILE!\.yadr4win\aliases.doskey"
  ) else (
    echo -^> !ALIASES_SH_PATH! is already hard linked, nothing done.
  )

  echo.
  echo Checking for "!ALIASES_SH_PATH!" soft link...
  call :debug_echo ALIASES_SH=!ALIASES_SH_PATH!
  call :is_symlink "!ALIASES_SH_PATH!" ".yadr4win\\aliases.sh"
  if "!is_symlink!" == "1" (
    echo Backing up "!ALIASES_SH_PATH!" to "!ALIASES_SH_PATH!.%bak_ext%"
    if exist "!ALIASES_SH_PATH!" move "!ALIASES_SH_PATH!" "!ALIASES_SH_PATH!.%bak_ext%"
    mklink "!ALIASES_SH_PATH!" "!USERPROFILE!\.yadr4win\aliases.sh"
  ) else (
    echo -^> !ALIASES_SH_PATH! is already symlinked, nothing done.
  )

  echo.
  echo Checking for "%USERPROFILE%\.gitconfig.user" configuration...
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
  echo All files that were not linked to YADR4Win files were backed up with a "[FILENAME].%BAK_EXT%".
  echo.
  echo If you are sure you have not lost anything you can clean these up by typing the following:
  echo   "%userprofile%\.yadr4win\cleanup.cmd"
)

exit /b

:is_symlink
  set symlink=%~1
  set symlink_target=%~2

  dir !symlink! | findstr /i "symlink" | findstr /i "!symlink_target!" >nul
  set "is_symlink=%errorlevel%"
  call :debug_echo %is_symlink%:%symlink%
  exit /b

:is_hardlink
  set hardlink=%~1
  set hardlink_target=%~2

  fsutil hardlink list !hardlink! | findstr /i "!hardlink_target!" >nul
  set "is_hardlink=%errorlevel%"
  call :debug_echo %is_hardlink%:%hardlink%
  exit /b

:debug_echo
  if "%debug%" GTR "0" (
    %Windir%\System32\WindowsPowerShell\v1.0\Powershell.exe -noprofile write-host -foregroundcolor Yellow DEBUG: %*
  )
  exit /b

:is_admin
  if exist "%TEMP%\test.tmp" del "%TEMP%\test.tmp"
  mklink "%TEMP%\test.tmp" %~DP0README.md>nul
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

:do_gitconfig.user
  echo We need to setup your user Git configuration so your commits are attributed to you.
  echo.
  echo All custom user Git configuration should go in "%USERPROFILE%\.gitconfig.user"
  echo.

  set /p "user.name=Type Your Name: "
  set /p "user.email=Type Your Email Address: "

  if "%user.name%" neq "" if "%user.email%" neq "" (
    move "%USERPROFILE%\.gitconfig.user" "%USERPROFILE%\.gitconfig.user.bak"
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
  dos2unix --help>nul
  if "%errorlevel%" == "0" (
    cd /d %~DP0
    find . -type f -name '*.sh' -exec dos2unix '{}' +
    find . -type f -name '*.vim' -exec dos2unix '{}' +
    find . -type f -name '*.vundle' -exec dos2unix '{}' +
    dos2unix ./vimrc
    dos2unix ./git/gitconfig
    dos2unix ./tmux/tmux.conf
  ) else (
    echo.
    echo WARNING: 'dos2unix' is not found!  Some things may not work in that require unix file endings.
  )
  exit /b
