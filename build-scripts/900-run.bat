setlocal

pushd %~dp0 || exit /b 1

set "POSTGRES_DB=testuniqueviolation"
set "POSTGRES_USER=testuniqueviolation"
set "POSTGRES_PASSWORD=testuniqueviolation"

set "APP_TAG=testuniqueviolation-app"
set "DATABASE_ENDPOINT=postgres://%POSTGRES_USER%:%POSTGRES_PASSWORD%@localhost:4079/%POSTGRES_DB%"
set "ADMIN_PASSWORD=psc54F2clNKGq3CH0uVQ-"


docker pull postgres >nul || exit /b 1

start docker run --rm -it --name testuniqueviolation-postgres -p 4079:5432 -m 2g ^
  -e POSTGRES_DB ^
  -e POSTGRES_USER ^
  -e POSTGRES_PASSWORD ^
  postgres || exit /b 1

set CF_INSTANCE_INDEX=0
call :start_app || exit /b 1

@rem set CF_INSTANCE_INDEX=1
@rem call :start_app || exit /b 1

exit /b 0

:start_app

docker run --rm -it ^
  --network=host ^
  --name testuniqueviolation-app-%CF_INSTANCE_INDEX% ^
  -p 408%CF_INSTANCE_INDEX%:8080 ^
  -e CF_INSTANCE_INDEX ^
  -e ADMIN_PASSWORD ^
  -e DATABASE_ENDPOINT ^
  "%APP_TAG%" || exit /b 1

goto :ennd

:ennd
