setlocal

@rem run optional goto command:
%*

pushd %~dp0 || exit /b 1


set "POSTGRES_DB=testuniqueviolation"
set "POSTGRES_USER=testuniqueviolation"
set "POSTGRES_PASSWORD=testuniqueviolation"

set "APP_TAG=testuniqueviolation-app"
set "ADMIN_PASSWORD=psc54F2clNKGq3CH0uVQ-"

docker pull postgres >nul || exit /b 1

start cmd /c %~f0 goto :start_postgres

set sleepcommand=ping 127.0.0.1 -w 1 -n
%sleepcommand% 2

FOR /F "tokens=*" %%i IN ('docker inspect -f "{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}" testuniqueviolation-postgres') DO (
  set DATABASE_HOST=%%i
)

echo DATABASE_HOST=%DATABASE_HOST%

set "DATABASE_ENDPOINT=postgres://%POSTGRES_USER%:%POSTGRES_PASSWORD%@%DATABASE_HOST%/%POSTGRES_DB%"

set CF_INSTANCE_INDEX=0
start cmd /c %~f0 goto :start_app

set CF_INSTANCE_INDEX=1
start cmd /c %~f0 goto :start_app

exit /b 0

:start_postgres

call docker run --rm -it --name testuniqueviolation-postgres -p 4079:5432 -m 2g ^
  -e POSTGRES_DB ^
  -e POSTGRES_USER ^
  -e POSTGRES_PASSWORD ^
  postgres

pause

goto :ennd

:start_app

call docker run --rm -it ^
  --name testuniqueviolation-app-%CF_INSTANCE_INDEX% ^
  -p 408%CF_INSTANCE_INDEX%:8080 ^
  -e CF_INSTANCE_INDEX ^
  -e ADMIN_PASSWORD ^
  -e DATABASE_ENDPOINT ^
  "%APP_TAG%"

pause

goto :ennd

:start_some

echo ok

pause

goto :ennd

:ennd
