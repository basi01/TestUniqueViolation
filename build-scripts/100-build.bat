setlocal

pushd %~dp0 || exit /b 1

@rem We expect that only a working docker executable is available. The docker daemon can be in WSL or even on a remote host.
@rem A builder image with Git and Python necessary to run the build-mda-dir task will be used.
@rem It's easier to use a dockerfile rather than `docker cp` to copy the project dir to the builder image,
@rem in particular, because it supports .dockerignore.
@rem However, the task itself requires docker, but docker.sock can't be mounted while building a dockerfile.
@rem So we first build the image and then run it with the necessary socket. 
@rem  


set "TAG_SUF=%RANDOM%_%RANDOM%_%RANDOM%_%RANDOM%" || exit /b 1
set "DOD_TAG=testuniqueviolation-builder:%TAG_SUF%" || exit /b 1
set "APP_TAG=testuniqueviolation-app" || exit /b 1

set ERRORLEVEL2=0
call :create_images || set ERRORLEVEL2=%ERRORLEVEL%

call docker image rm -- "%DOD_TAG%" || echo. >nul

@rem endlocal & set ERRORLEVEL2=%ERRORLEVEL2%

exit /b %ERRORLEVEL2%

:create_images

call docker build -t "%DOD_TAG%" -f 100-run-docker-mendix-buildpack.dockerfile .. || exit /b 1

@rem TODO: I only tested it with a regular WSL Ubuntu dockerd, not Docker for Desktop
call docker run --rm -it ^
  -e "APP_TAG=%APP_TAG%" ^
  --volume /var/run/docker.sock:/var/run/docker.sock ^
  --entrypoint bash ^
  "%DOD_TAG%" /workdir/src/build-scripts/100-run-docker-mendix-buildpack/500-build-mda-dir.sh || exit /b 1

goto :ennd

:ennd
