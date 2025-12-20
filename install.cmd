@echo off

:: Enable delayed expansion
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

if not exist "%APPDATA%/../Local/nvim-data/site/autoload/plug.vim" (
  echo Installing 'vim-plug'...
  curl -fLo "%APPDATA%/../Local/nvim-data/site/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
) else (
  echo -^> vim-plug is already installed, nothing done.
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

call :install_symlinks git
call :install_symlinks tmux
call :install_symlinks vimrc
call :install_symlinks vimify
call :install_symlink_dir "%USERPROFILE%\.vim" "%USERPROFILE%\.yadr4win\vim"
call :install_symlink_dir "%USERPROFILE%\.config\nvim" "%USERPROFILE%\.yadr4win\nvim"
call :install_symlink_dir "%USERPROFILE%\AppData\Local\nvim" "%USERPROFILE%\.yadr4win\nvim"

echo.
if defined CMDER_ROOT (
  echo CMDER was found, configuring it...

  call :install_symlink "%CMDER_ROOT%\config\user-ConEmu.xml" "%USERPROFILE%\.yadr4win\cmder\config\user-Conemu.xml"
  pause
  call :install_hardlink "%CMDER_ROOT%\config\user_aliases.cmd" "%USERPROFILE%\.yadr4win\user_aliases.cmd"
  call :install_symlink "%CMDER_ROOT%\config\user_profile.cmd" "%USERPROFILE%\.yadr4win\cmder\config\user_profile.cmd"
  call :install_symlink "%CMDER_ROOT%\config\user_aliases.sh" "%USERPROFILE%\.yadr4win\user_aliases.sh"
  call :install_symlink "%CMDER_ROOT%\config\user_profile.sh" "%USERPROFILE%\.yadr4win\cmder\config\user_profile.sh"
  call :install_symlink "%CMDER_ROOT%\config\user_aliases.ps1" "%USERPROFILE%\.yadr4win\user_aliases.ps1"
  call :install_symlink "%CMDER_ROOT%\config\user_profile.ps1" "%USERPROFILE%\.yadr4win\cmder\config\user_profile.ps1"
  call :check_powershell_profile "%CMDER_ROOT%\config\user_aliases.ps1" "%CMDER_ROOT%\config\user_profile.ps1"
) else (
  call :install_hardlink "%USERPROFILE%\.user_aliases.cmd" "%USERPROFILE%\.yadr4win\user_aliases.cmd"
  call :install_symlink "%USERPROFILE%\.user_aliases.sh" "%USERPROFILE%\.yadr4win\user_aliases.sh"
  call :install_symlink "%USERPROFILE%\Documents\WindowsPowerShell\user_aliases.ps1" "%USERPROFILE%\.yadr4win\user_aliases.ps1"
  call :check_powershell_profile "%USERPROFILE%\Documents\WindowsPowerShell\user_aliases.ps1" "%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
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
echo All files that were not linked to .yadr4win files were backed up with a "[FILENAME].%BAK_EXT%".
echo.
echo If you are sure you have not lost anything you can clean these up by typing the following:
echo   "%USERPROFILE%\.yadr4win\cleanup.cmd"

endlocal
exit /b

:: =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
:: Functions below here
:: =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

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

  echo Checking for "!symlink!\" directory symlink...
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
  )

  set "is_symlink=%exit_code%"

  call :debug_echo !is_symlink! "%symlink%"

  exit /b

:is_hardlink
  set "hardlink=%~1"
  set "hardlink_target=%~2"

  :: Remove '[drive letter]:' from target for comparison.
  if "%hardlink_target:~1,1%" == ":" (
    set "hardlink_target=%hardlink_target:~2%"
  )

  if not exist "%hardlink%" (
    echo.
    set "is_hardlink=1"
    call :debug_echo !is_hardlink! "%hardlink%"
    exit /b
  )

  echo.
  echo Checking for "!hardlink!" hardlink...
  fsutil hardlink list "!hardlink!" | findstr /i /c:"!hardlink_target:\=\\!" >nul
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

:install_hardlink
  set "link=%~1"
  set "link_target=%~2"

  call :is_hardlink "%link%" "%link_target%"
  if "%is_hardlink%" EQU "1" (
      CALL :do_backup "%link%" %BAK_EXT%
      fsutil hardlink create "%link%" "%link_target%"
  ) else (
      echo -^> %link% is already a hardlink, nothing done.
  )

  exit /b

:install_symlink
  set "link=%~1"
  set "link_target=%~2"

  call :is_symlink "%link%" "%link_target%"
  if "%is_symlink%" EQU "1" (
    CALL :do_backup "%link%" %BAK_EXT%
    mklink "%link%" "%link_target%"
  ) else (
    echo -^> %link% is already a symlink, nothing done.
  )

  exit /b

:install_symlink_dir
  set "link=%~1"
  set "link_target=%~2"

  call :is_dir_symlink "%link%" "%link_target%"
  if "!is_symlink!" EQU "1" (
    CALL :do_backup "%link%" %BAK_EXT%
    mklink /d "%link%" "%link_target%"
  ) else (
    echo -^> %link% is already a folder symlink, nothing done.
  )

  exit /b

:install_symlinks
  set "item=%WORKDIR%\%~1"

  :: if %item% is a folder add a \* to loop through files
  if exist "%item%\*" set "item=%item%\*"

  :: Loop through files in the .\vimify item and create symlinks in the user's home directory
  for %%f in ("%item%") do (
    set filename=%%~nxf
    if "!filename!" NEQ "README.md" (
      set "link=%USERPROFILE%\.!filename!"
      set "link_target=%%f"

      call :install_symlink "!link!" "!link_target!"
    )
  )

  exit /b

:check_powershell_profile
  set ALIASES_PS1_PS_PATH=%USERPROFILE%\.yadr4win\user_aliases.ps1
  set PROFILE_PS1_PATH=%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1

  echo "Checking '!ALIASES_PS1_PS_PATH!' is sourced in Powershell '!PROFILE_PS1_PATH!'..."
  type "!PROFILE_PS1_PATH!" | findstr /i /r /c:"^. \"!ALIASES_PS1_PS_PATH:\=\\!\"">nul
  if "!ERRORLEVEL!" == "1" (
    CALL :do_backup "!PROFILE_PS1_PATH!" !BAK_EXT!
    echo "Sourcing '!ALIASES_PS1_PS_PATH!' in Powershell '!PROFILE_PS1_PATH!'"
    echo . "!ALIASES_PS1_PS_PATH!" >> "!PROFILE_PS1_PATH!"
  ) else (
    call :debug_echo 0 "'!ALIASES_PS1_PS_PATH!' is already sourced in Powershell '!PROFILE_PS1_PATH!'."
  )

  exit /b
