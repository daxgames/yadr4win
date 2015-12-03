@echo off

setlocal enabledelayedexpansion

call :do_isAdmin

if "%is_admin%" == "1" (
  if exist "%USERPROFILE%\.vimrc" (
    echo Backing up "%USERPROFILE%\.vimrc" to ".vimrc.yadr4win
    ren "%USERPROFILE%\.vimrc" ".vimrc.yadr4win"
  )

  mklink /h "%USERPROFILE%\.vimrc" "%USERPROFILE%\.yadr4win\vimrc"

  if exist "%USERPROFILE%\.gitconfig" (
    echo Backing up "%USERPROFILE%\.gitconfig" to ".gitconfig.yadr4win
    ren "%USERPROFILE%\.gitconfig" ".gitconfig.yadr4win"
  )

  mklink /h "%USERPROFILE%\.gitconfig" "%USERPROFILE%\.yadr4win\git\gitconfig"

  if exist "%USERPROFILE%\.tmux.conf" (
    echo Backing up "%USERPROFILE%\.tmux.conf" to ".tmux.conf.yadr4win
    ren "%USERPROFILE%\.tmux.conf" ".tmux.conf.yadr4win"
  )

  mklink /h "%USERPROFILE%\.tmux.conf" "%USERPROFILE%\.yadr4win\tmux\tmux.conf"

  if exist "%USERPROFILE%\.vim" (
    dir %USERPROFILE%\.vim | findstr /i "%USERPROFILE%\.yadr4win\vim" >NULL
    if "!ERRORLEVEL!" == "1" (
      echo Backing up "%USERPROFILE%\.vim" to ".vim.yadr4win
      rendir "%USERPROFILE%\.vim" ".vim.yad4rwin"
    )
  )

  if not exist "%USERPROFILE%\.vim" (
    mklink /d "%USERPROFILE%\.vim" "%USERPROFILE%\.yadr4win\vim"
  )

  if not exist "%USERPROFILE%\.vim\bundle" (
    mkdir "%USERPROFILE%\.vim\bundle"
  )

  if not exist "%USERPROFILE%\.vim\bundle\vundle.vim" (
    echo Installing 'vundle.vim'...
    git clone https://github.com/VundleVim/Vundle.vim.git "%USERPROFILE%\.vim\bundle\vundle.vim"
  )

  if exist "%USERPROFILE%\.aliases.doskey" (
    "%USERPROFILE%\.aliases.doskey" "%USERPROFILE%\aliases.doskey.bak"
  )

  mklink /H "%USERPROFILE%\.aliases.doskey" "%USERPROFILE%\.yadr4win\aliases.doskey"

  if exist "%USERPROFILE%\.tmux.conf" (
    "%USERPROFILE%\.aliases.sh" "%USERPROFILE%\aliases.sh.bak"
  )
   
  mklink /H "%USERPROFILE%\.aliases.sh" "%USERPROFILE%\.yadr4win\aliases.sh"

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
)

exit /b

:do_isadmin
  fsutil>null
  if "%ERRORLEVEL%" == "0" (
    exit /b && set is_admin=1
  ) else (
    echo This script requires that you have administrative privileges.
    pause
    exit /b && set is_admin=0
  )
  exit /b

:do_gitconfig.user
  echo Error: %do_gitconfig.user% - We need to setup your user Git configuration so your commits are attributed to you.
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
  ) else (
    echo Either username or email was not specified no changes will be made.
  )
  exit /b
