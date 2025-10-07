setlocal
@set "PROMPT=.\>"

pushd %~dp0..\zzz-internal || @goto :no_clean

@rem We expect that only a working docker executable is available. The docker daemon can be in WSL or even on a remote host.
@rem A builder image with Git and Python necessary to run the build-mda-dir task will be used.
@rem It's easier to use a dockerfile rather than `docker cp` to copy the project dir to the builder image,
@rem in particular, because it supports .dockerignore.
@rem However, the task itself requires docker, but docker.sock can't be mounted while building a dockerfile.
@rem So we first build the image and then run it with the necessary socket. 
@rem  

call :do_it

:clean
set ERRORLEVEL2=%ERRORLEVEL%
@rem final clean (this resets ERRORLEVEL)
call docker compose -f 100-build-with-compose.yml down --rmi local || echo. >nul
@goto :main_exit

:no_clean
set ERRORLEVEL2=%ERRORLEVEL%

:main_exit
echo exiting with %ERRORLEVEL2%
%OPT_PAUSE% pause
exit /b %ERRORLEVEL2%

@rem xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
:do_it
@rem set BUILDPACK_XTRACE=true
@rem set BUILDKIT_PROGRESS=plain
@rem do not reuse existing :temp image
call docker compose -f 100-build-with-compose.yml down --rmi local || @goto :ennd
@rem build
call docker compose -f 100-build-with-compose.yml run --rm --build builder || @goto :ennd
@goto :ennd
@rem xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

:ennd
