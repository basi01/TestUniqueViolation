setlocal
@set "PROMPT=.\>"

@rem run optional goto command:
%*

@set "ADMIN_PASSWORD=n0t-A-s3cRet"

@set "sleepcommand=@ping >nul 127.0.0.1 -w 1 -n"

pushd %~dp0..\zzz-internal || @goto :no_clean

call :do_it

:clean
set ERRORLEVEL2=%ERRORLEVEL%
@rem final clean (this resets ERRORLEVEL)
call docker compose -f 900-run-compose.yml down
@goto :main_exit

:no_clean
set ERRORLEVEL2=%ERRORLEVEL%

:main_exit
echo exiting with %ERRORLEVEL2%
%OPT_PAUSE% pause
exit /b %ERRORLEVEL2%

@rem xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
:do_it
@echo following the logs in a separate console window...
start /MIN cmd /c "%~f0" goto :start_docker_compose_logs
@echo starting the composition and detach...
call docker compose -f 900-run-compose.yml up --wait || @goto :ennd
@echo opening browser via socat proxy...
start "" "http://localhost:4078"
@echo You may attach a java debugger at ports 4076 and 4077
@echo Interactive proxy ready. You can launch http://localhost:4078 in your browser.
@echo Logs are opened in a separate window
@echo MxAdmin password: %ADMIN_PASSWORD%
@echo press any key to switch from app0 to app1
@call docker attach testuniqueviolation-portproxy || @goto :ennd
@goto :ennd
@rem xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

@rem xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
:start_docker_compose_logs
@rem give the parent some time to create the composition
%sleepcommand% 5
call docker compose -f 900-run-compose.yml logs -f
pause
@goto :ennd
@rem xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

:ennd
