function backup-file {
  [cmdletbinding(
    SupportsShouldProcess=$True
  )]
  Param (
    [parameter(Position=0,ValueFromPipeline=$True,
      ValueFromPipelineByPropertyName=$True,Mandatory=$True)]
    [ValidateScript({
      If (Test-Path $_ -PathType Leaf) {$True} Else {
        Throw "`'$_`' doesn't exist or isn't a file!"
      }
    })]
    [string]$Path,
    [parameter(Mandatory=$True)]
    [string]$Ext
  )
  Process {
    if (test-path $Path) {
      write-host $("Backing up " + $Path + " to " + $($Path + $Ext)) 
      move $Path $($Path + $Ext)
    )
  }
} 

. .\lib\New-SymLink.ps1
. .\lib\New-HardLlink.ps1

$BAK_EXT=$(".yadr4win." + $(get-date -f MM-dd-yyyy_HH_mm_ss)) 

  CALL :do_backup "%USERPROFILE%\.vimrc" !BAK_EXT! 
  MKLINK /H "%USERPROFILE%\.vimrc" "%USERPROFILE%\.yadr4win\vimrc"
) else (
  echo -^> %USERPROFILE%\.vimrc is already hardlinked, nothing done.
)

call :is_hardlink "%USERPROFILE%\.gitconfig" ".yadr4win\\git\\gitconfig]"
if "!is_hardlink!" EQU "1" (
  CALL :do_backup "%USERPROFILE%\.gitconfig" !BAK_EXT! 
  MKLINK /H "%USERPROFILE%\.gitconfig" "%USERPROFILE%\.yadr4win\git\gitconfig"
) else (
  echo -^> %USERPROFILE%\.gitconfig is already hardlinked, nothing done.
)

call :is_hardlink "%USERPROFILE%\.tmux.conf" ".yadr4win\\tmux\\tmux.conf]"
if "!is_hardlink!" EQU "1" (
  CALL :do_backup "%USERPROFILE%\.tmux.conf" !BAK_EXT! 
  MKLINK /H "%USERPROFILE%\.tmux.conf" "%USERPROFILE%\.yadr4win\tmux\tmux.conf"
) else (
  echo -^> %USERPROFILE%\.tmux.conf is already hardlinked, nothing done.
)

call :is_symlink "%USERPROFILE%" ".yadr4win\\vim]"
if "!is_symlink!" EQU "1" (
  CALL :do_backup "%USERPROFILE%\.vim" !BAK_EXT! 
  MKLINK /D "%USERPROFILE%\.vim" "%USERPROFILE%\.yadr4win\vim"
) else (
  echo -^> %USERPROFILE%\.vim is already symlinked, nothing done.
)

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
if defined CMDER_ROOT (
  echo CMDER was found, configuring it if necessary...
  call :is_hardlink "%CMDER_ROOT%\MyCmder.cmd" ".yadr4win\\cmder\\MyCmder.cmd"
  if "!is_hardlink!" EQU "1" (
    CALL :do_backup "%CMDER_ROOT%\MyCmder.cmd" !BAK_EXT! 
    MKLINK /H "%CMDER_ROOT%\MyCmder.cmd" "%USERPROFILE%\.yadr4win\cmder\MyCmder.cmd"
  ) else (
    echo -^> %CMDER_ROOT%\MyCmder.cmd is already hardlinked, nothing done.
  )

  if exist "%CMDER_ROOT%\Mycmder.bat" del "%CMDER_ROOT%\Mycmder.bat"

  call :is_hardlink "%CMDER_ROOT%\config\user-ConEmu.xml" ".yadr4win\\cmder\\user-Conemu.xml"
  if "!is_hardlink!" EQU "1" (
    CALL :do_backup "%CMDER_ROOT%\config\user-ConEmu.xml" !BAK_EXT! 
    MKLINK /H "%CMDER_ROOT%\config\user-ConEmu.xml" "%USERPROFILE%\.yadr4win\cmder\user-ConEmu.xml"
  ) else (
    echo -^> %CMDER_ROOT%\config\user-ConEmu.xml is already hardlinked, nothing done.
  )

  $ALIASES_PATH=%CMDER_ROOT%\config\aliases
  $ALIASES_SH_PATH=%CMDER_ROOT%\config\user-aliases.sh
  $ALIASES_PS1_PATH=%CMDER_ROOT%\config\user-aliases.ps1
  $ALIASES_PS1_PS1PATH=$ENV:CMDER_ROOT\config\user-aliases.ps1
  $PROFILE_PS1_PATH=%CMDER_ROOT%\config\user-profile.ps1
) else (
  $ALIASES_PATH=%USER_PROFILE%\.aliases
  $ALIASES_SH_PATH=%USER_PROFILE%\.aliases.sh
  $ALIASES_PS1_PATH=%USER_PROFILE%\Documents\WindowsPowerShell\Aliases.ps1
  $ALIASES_PS1_PS1PATH=$ENV:USER_PROFILE\Documents\WindowsPowerShell\Aliases.ps1
  $PROFILE_PS1_PATH=%USER_PROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
)

call :is_hardlink "!ALIASES_PATH!" ".yadr4win\\aliases"
:: Need hardlink here because doskey.exe does not deal with hardlinks
if "!is_hardlink!" == "1" (
  CALL :do_backup "!ALIASES_PATH!" !BAK_EXT! 
  MKLINK /H "!ALIASES_PATH!" "!USERPROFILE!\.yadr4win\aliases.cmd"
) else (
  echo -^> !ALIASES_PATH! is already hard linked, nothing done.
)

call :is_hardlink "!ALIASES_PS1_PATH!" ".yadr4win\\aliases.ps1"
if "!is_hardlink!" == "1" (
  CALL :do_backup "!ALIASES_PS1_PATH!" !BAK_EXT! 
  MKLINK /H "!ALIASES_PS1_PATH!" "!USERPROFILE!\.yadr4win\aliases.ps1"
) else (
  echo -^> !ALIASES_PS1_PATH! is already hardlinked, nothing done.
)

type "!PROFILE_PS1_PATH!" | findstr /i /r "^\. !ALIASES_PS1_PS1PATH!">nul
if "!ERRORLEVEL!" == "1" (
  CALL :do_backup "!PROFIEL_PS1_PATH!" !BAK_EXT! 
  echo Including '!ALIASES_PS1_PS1PATH!' in Powershell '!PROFILE_PS1_PATH!' 
  powershell -command "& {'. !ALIASES_PS1_PS1PATH!' | out-file '!PROFILE_PS1_PATH!' -append }"
)

call :is_hardlink "!ALIASES_SH_PATH!" ".yadr4win\\aliases.sh"
if "!is_hardlink!" == "1" (
  CALL :do_backup "!ALIASES_SH_PATH!" !BAK_EXT! 
  MKLINK /H "!ALIASES_SH_PATH!" "!USERPROFILE!\.yadr4win\aliases.sh"
) else (
  echo -^> !ALIASES_SH_PATH! is already hardlinked, nothing done.
)

echo.
$do_gitconfig.user=0
if not exist "%USERPROFILE%\.gitconfig.user" (
  $do_gitconfig.user=8
) else (
  type "%USERPROFILE%\.gitconfig.user" | findstr /i /R /C:"^\[user\]$">nul
  if !ERRORLEVEL! GTR 0 ( $/a do_gitconfig.user+=4 )
  type "%USERPROFILE%\.gitconfig.user" | findstr /i /R /C:"^ *name *= *[a-z]*.*$">nul
  if !ERRORLEVEL! GTR 0 ( $/a do_gitconfig.user+=2 )
  type "%USERPROFILE%\.gitconfig.user" | findstr /i /r /c:"^ *email *= .*@.*$">nul
  if !ERRORLEVEL! GTR 0 ( $/a do_gitconfig.user+=1 )

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

echo.
echo Verifying...
$debug=1
call :is_hardlink "%USERPROFILE%\.vimrc" ".yadr4win\\vimrc]"
call :is_hardlink "%USERPROFILE%\.gitconfig" ".yadr4win\\git\\gitconfig]"
call :is_hardlink "%USERPROFILE%\.tmux.conf" ".yadr4win\\tmux\\tmux.conf]"
call :is_hardlink "%CMDER_ROOT%\MyCmder.cmd" ".yadr4win\\cmder\\MyCmder.cmd"
call :is_hardlink "%CMDER_ROOT%\config\user-ConEmu.xml" ".yadr4win\\cmder\\user-Conemu.xml"
call :is_hardlink "!ALIASES_PATH!" ".yadr4win\\aliases"
call :is_hardlink "!ALIASES_PS1_PATH!" ".yadr4win\\aliases.ps1"
call :is_hardlink "!ALIASES_SH_PATH!" ".yadr4win\\aliases.sh"


exit /b
# :is_symlink
#   $symlink=%~1
#   $symlink_target=%~2
# 
#   echo.
#   echo Checking for "!symlink!" symlink...
#   dir !symlink! | findstr /i "symlink" | findstr /i "!symlink_target!" >nul
#   $"is_symlink=%errorlevel%"
#   call :debug_echo %is_symlink%:%symlink%
#   exit /b
# 
# :is_hardlink
#   $hardlink=%~1
#   $hardlink_target=%~2
# 
#   echo.
#   echo Checking for "!hardlink!" hardlink...
#   fsutil hardlink list !hardlink! | findstr /i /r "!hardlink_target!$" >nul
#   $"is_hardlink=%errorlevel%"
#   call :debug_run fsutil hardlink list "!hardlink!"
#   call :debug_echo %is_hardlink%:%hardlink%
#   exit /b
# 
# :debug_run
#   if "%debug%" GTR "0" (
#     %Windir%\System32\WindowsPowerShell\v1.0\Powershell.exe -noprofile -command "& { $output = %* | out-string ; write-host -foregroundcolor Yellow DEBUG: %*`n$output }
#   )
#   exit /b
# 
# :debug_echo
#   if "%debug%" GTR "0" (
#     %Windir%\System32\WindowsPowerShell\v1.0\Powershell.exe -noprofile write-host -foregroundcolor Yellow DEBUG: %*
#   )
#   exit /b
# 
# :is_admin
#   if exist "%TEMP%\test.tmp" del "%TEMP%\test.tmp"
#   MKLINK /H "%TEMP%\test.tmp" %~DP0README.md>nul
#   if "%ERRORLEVEL%" == "0" (
#     if exist "%TEMP%\test.tmp" del "%TEMP%\test.tmp"
#     $is_admin=0
#     exit /b
#   ) else (
#     echo This script requires that you have administrative privileges.
#     $is_admin=1
#     pause
#     exit /b
#   )
#   exit /b

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
  dos2unix --help>nul
  if "%errorlevel%" == "0" (
    echo Please wait converting required files to unix format...
    cd /d %~DP0
    find . -type f -name '*.sh' -exec dos2unix '{}' + >nul 2>&1
    find . -type f -name '*.vim' -exec dos2unix '{}' + >nul 2>&1
    find . -type f -name '*.vundle' -exec dos2unix '{}' + >nul 2>&1
    dos2unix ./vimrc >nul 2>&1
    dos2unix ./git/gitconfig >nul 2>&1
    dos2unix ./tmux/tmux.conf >nul 2>&1
  ) else (
    echo.
    echo WARNING: 'dos2unix' is not found!  Some things may not work in that require unix file endings.
  )
  exit /b
