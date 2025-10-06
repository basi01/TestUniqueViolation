setlocal
@set "PROMPT=.\>"

@rem run optional goto command:
%*

@set ERRORLEVEL2=1
pushd %~dp0..\zzz-internal || goto :err

@set ERRORLEVEL2=0
call :do_it || set ERRORLEVEL2=%ERRORLEVEL%

:err
echo exiting with %ERRORLEVEL2%

call docker compose -f 900-run-compose.yml down

pause
exit /b %ERRORLEVEL2%

@rem xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
:do_it
@echo starting the composition and detach...
call docker compose -f 900-run-compose.yml up --wait || goto :ennd
@echo following the logs in a separate window...
start cmd /c "%~f0" goto :start_docker_compose_logs
@echo opening browser via socat proxy...
start "" "http://localhost:4078"
@echo Interactive proxy ready. You can launch http://localhost:4078 in your browser.
@echo MxAdmin password: n0t-A-s3cRet
@echo press any key to switch from app0 to app1
@call docker attach testuniqueviolation-portproxy || goto :ennd
goto :ennd
@rem xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

@rem xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
:start_docker_compose_logs
call docker compose -f 900-run-compose.yml logs -f
pause
goto :ennd
@rem xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

:ennd
