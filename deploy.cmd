@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off
 
:: ----------------------
:: KUDU Deployment Script
:: Version: 0.1.12
:: ----------------------
 
:: Prerequisites
:: -------------
 
:: Verify node.js installed
where node 2>nul >nul
IF %ERRORLEVEL% NEQ 0 (
  echo Missing node.js executable, please install node.js, if already installed make sure it can be reached from current environment.
  goto error
)
 
:: Setup
:: -----
 
setlocal enabledelayedexpansion
 
IF NOT DEFINED DEPLOYMENT_TEMP (
  SET ARTIFACTS=%~dp0%..\artifacts
) ELSE (
  SET ARTIFACTS=%HOMEDRIVE%%HOMEPATH%\artifacts
)
 
SET ARTIFACTS_OUT=%ARTIFACTS%\publish
 
IF NOT DEFINED DEPLOYMENT_SOURCE (
  SET DEPLOYMENT_SOURCE=%~dp0%.
)
 
IF NOT DEFINED DEPLOYMENT_TARGET (
  SET DEPLOYMENT_TARGET=%ARTIFACTS%\output
)
 
IF NOT DEFINED NEXT_MANIFEST_PATH (
  SET NEXT_MANIFEST_PATH=%ARTIFACTS%\manifest
 
  IF NOT DEFINED PREVIOUS_MANIFEST_PATH (
    SET PREVIOUS_MANIFEST_PATH=%ARTIFACTS%\manifest
  )
)
 
:: Remove wwwroot if deploying to default location
IF "%DEPLOYMENT_TARGET%" == "%WEBROOT_PATH%" (
  FOR /F %%i IN ("%DEPLOYMENT_TARGET%") DO IF "%%~nxi"=="wwwroot" (
    SET DEPLOYMENT_TARGET=%%~dpi
  )
)
 
:: Remove trailing slash if present
IF "%DEPLOYMENT_TARGET:~-1%"=="\" (
  SET DEPLOYMENT_TARGET=%DEPLOYMENT_TARGET:~0,-1%
)
 
IF NOT DEFINED KUDU_SYNC_CMD (
  :: Install kudu sync
  echo Installing Kudu Sync
  call npm install kudusync -g --silent
  IF !ERRORLEVEL! NEQ 0 goto error
 
  :: Locally just running "kuduSync" would also work
  SET KUDU_SYNC_CMD=%appdata%\npm\kuduSync.cmd
)
IF NOT DEFINED DEPLOYMENT_TEMP (
  SET DEPLOYMENT_TEMP=%temp%\___deployTemp%random%
  SET CLEAN_LOCAL_DEPLOYMENT_TEMP=true
)
 
IF DEFINED CLEAN_LOCAL_DEPLOYMENT_TEMP (
  IF EXIST "%DEPLOYMENT_TEMP%" rd /s /q "%DEPLOYMENT_TEMP%"
  mkdir "%DEPLOYMENT_TEMP%"
)
 
IF NOT DEFINED MSBUILD_PATH (
  SET MSBUILD_PATH=%WINDIR%\Microsoft.NET\Framework\v4.0.30319\msbuild.exe
)
 
SET KRE_VERSION=1.0.0-beta1 
SET KRE_ARCH=x86
SET KRE_CLR=CoreCLR
SET ProjectJsonFile=src\ttalviste.web\project.json
 
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Deployment
:: ----------
 
echo Handling ProjectK Web Application deployment.
 
:: Work around Kudu issue #1310
set HOME=%HOMEDRIVE%%HOMEPATH%
set KRE_HOME=%USERPROFILE%\.kre
 
:: 1. Install KRE
call kvm install %KRE_VERSION% -%KRE_ARCH% -r %KRE_CLR%
IF !ERRORLEVEL! NEQ 0 goto error
 
:: 2. Run KPM Restore
call :ExecuteCmd PowerShell -NoProfile -NoLogo -ExecutionPolicy unrestricted -Command "[System.Threading.Thread]::CurrentThread.CurrentCulture = ''; [System.Threading.Thread]::CurrentThread.CurrentUICulture = '';& 'kpm' %*" restore %ProjectJsonFile% --source %SCM_KRE_NUGET_API_URL% --source https://nuget.org/api/v2/
IF !ERRORLEVEL! NEQ 0 goto error
 
:: 3. Run KPM Pack
RMDIR /S /Q "%ARTIFACTS_OUT%"
call :ExecuteCmd PowerShell -NoProfile -NoLogo -ExecutionPolicy unrestricted -Command "[System.Threading.Thread]::CurrentThread.CurrentCulture = ''; [System.Threading.Thread]::CurrentThread.CurrentUICulture = '';& 'kpm' %*" pack %ProjectJsonFile% --out "%ARTIFACTS_OUT%" --runtime KRE-%KRE_CLR%-%KRE_ARCH%.%KRE_VERSION%
IF !ERRORLEVEL! NEQ 0 goto error
 
:: 4. KuduSync
call %KUDU_SYNC_CMD% -v 5000 -f "%ARTIFACTS_OUT%" -t "%DEPLOYMENT_TARGET%" -n "%NEXT_MANIFEST_PATH%" -p "%PREVIOUS_MANIFEST_PATH%" -i ".git;.hg;.deployment;deploy.cmd"
IF !ERRORLEVEL! NEQ 0 goto error
 
:: 5. Request homepage (warm-up)
IF "%WEBSITE_HOSTNAME%" NEQ "" ( 
  echo ==== http://%WEBSITE_HOSTNAME% ==== 
  curl --silent --show-error http://%WEBSITE_HOSTNAME%  
  echo. 
  echo ======== 
) 
 
 
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Post deployment stub
IF DEFINED POST_DEPLOYMENT_ACTION call "%POST_DEPLOYMENT_ACTION%"
IF !ERRORLEVEL! NEQ 0 goto error
 
goto end
 
:: Execute command routine that will echo out when error
:ExecuteCmd
setlocal
set _CMD_=%*
call %_CMD_%
if "%ERRORLEVEL%" NEQ "0" echo Failed exitCode=%ERRORLEVEL%, command=%_CMD_%
exit /b %ERRORLEVEL%
 
:error
endlocal
echo An error has occurred during web site deployment.
call :exitSetErrorLevel
call :exitFromFunction 2>nul
 
:exitSetErrorLevel
exit /b 1
 
:exitFromFunction
()
 
:end
endlocal
echo Finished successfully.