@ECHO OFF

cd %userprofile%
call :clean_backups

if defined CMDER_ROOT (
  cd %CMDER_ROOT%
  call :clean_backups
  
  cd %CMDER_ROOT%\config
  call :clean_backups
)

cd %userprofile%
exit /b

:clean_backups
  for /f "tokens=5" %%A in ('dir ^| findstr /v /i "symlink dir" ^| findstr /i "\.yadr4win"') do (
    echo Deleting %%A
    del /p %%A
  )
  exit /b
