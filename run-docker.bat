setlocal
set "OPT_PAUSE=@echo >nul"

@call %~dp0build-scripts\windows\100-build.bat || @goto :err
@call %~dp0build-scripts\windows\900-run.bat || @goto :err

:err

pause
