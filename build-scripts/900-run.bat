setlocal

@rem run optional goto command:
%*

pushd %~dp0 || exit /b 1

@echo starting the composition and detach...
call docker compose -f 900-run-compose.yml up --wait || goto :err

@echo following the logs in a separate window...
start cmd /c %~f0 goto :start_docker_compose_logs

@echo opening browser via socat proxy...
start "" "http://localhost:4078"

@echo Interactive proxy ready. You can launch http://localhost:4078 in your browser.
@echo MxAdmin password: n0t-A-s3cRet
@echo press any key to switch from app0 to app1
@call docker attach testuniqueviolation-portproxy

:err

set ERRORLEVEL2=%ERRORLEVEL%

call docker compose -f 900-run-compose.yml down

pause
exit /b %ERRORLEVEL2%

@rem xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
:start_docker_compose_logs
call docker compose -f 900-run-compose.yml logs -f
pause
goto :ennd
@rem xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


:ennd
