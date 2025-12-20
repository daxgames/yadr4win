@ECHO OFF

pushd %userprofile%
call :clean_backups
popd

if defined CMDER_ROOT (
  pushd %CMDER_ROOT%
  call :clean_backups
  popd

  pushd %CMDER_ROOT%\config
  call :clean_backups
  popd
)

exit /b

:clean_backups
  setlocal enabledelayedexpansion
  echo Cleaning "%cd%"...
  for /f "tokens=5" %%A in ('dir ^| findstr /i "\.yadr4win\."') do (

    REM if %%A is a symlink, remove the link instead of the target
    REM if it is a folder use rmdir, if it is a file use del

    set is_symlink=false
    fsutil reparsepoint query "%%A" >nul 2>&1
    if "!errorlevel!" == "0" (
        set is_symlink=true
    )

    if "!is_symlink!" == "true" (
      echo Deleting symlink "%%A"
      if exist "%%A\" (
        echo rmdir "%%A"
        rmdir "%%A"
      ) else (
        echo del "%%A"
        del "%%A"
      )
    ) else (
      if exist "%%A\" (
        echo Deleting directory "%%A"
        echo rmdir /s /q "%%A"
        rmdir /s /q "%%A"
      ) else (
        echo Deleting file "%%A"
        echo del "%%A"
        del "%%A"
      )
    )

    echo.
  )
  endlocal
  exit /b
