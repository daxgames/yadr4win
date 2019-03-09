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
  for /f "tokens=5" %%A in ('dir ^| findstr /v /i "symlink dir" ^| findstr /i "\.yadr4win"') do (
    echo Deleting %%A
    del /p %%A
  )
  exit /b
