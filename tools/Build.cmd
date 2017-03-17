@echo off

call %~dp0\EnsureWebSdkEnv.cmd

REM Copy the files required for signing
xcopy \\aspnetci\share\tools\Microsoft.Web.MsBuildTasks2.dll %WebSdkTools% /y /C
xcopy \\aspnetci\share\tools\7za.exe %WebSdkTools% /y /C
xcopy \\aspnetci\share\tools\Microsoft.NET.Sdk.Web.Sign.targets %WebSdkTools% /y /C
xcopy \\aspnetci\share\tools\WebDeploy\* %WebSdkTools%WebDeploy\* /y /C /e /s /f

call dotnet restore %WebSdkRoot%Microsoft.Net.Sdk.Web.Sln /p:configuration=Release
if errorlevel 1 GOTO ERROR

call dotnet build %WebSdkRoot%src\Microsoft.NET.Sdk.Publish\Microsoft.NET.Sdk.Publish.csproj /p:configuration=Release
if errorlevel 1 GOTO ERROR

REM Copy Publish Sdks
xcopy %WebSdkSource%Microsoft.NET.Sdk.Publish\Targets\Sdk.props  %DOTNET_INSTALL_DIR%\Sdk\%DOTNET_VERSION%\Sdks\Microsoft.NET.Sdk.Publish\Sdk\ /y /C
xcopy %WebSdkSource%Microsoft.NET.Sdk.Publish\Targets\Sdk.targets  %DOTNET_INSTALL_DIR%\Sdk\%DOTNET_VERSION%\Sdks\Microsoft.NET.Sdk.Publish\Sdk\ /y /C

REM Copy Project System Sdks
xcopy %WebSdkSource%Microsoft.NET.Sdk.Web.ProjectSystem\Targets\Sdk.props  %DOTNET_INSTALL_DIR%\Sdk\%DOTNET_VERSION%\Sdks\Microsoft.NET.Sdk.Web.ProjectSystem\Sdk\ /y /C
xcopy %WebSdkSource%Microsoft.NET.Sdk.Web.ProjectSystem\Targets\Sdk.targets  %DOTNET_INSTALL_DIR%\Sdk\%DOTNET_VERSION%\Sdks\Microsoft.NET.Sdk.Web.ProjectSystem\Sdk\ /y /C

REM Copy Web Sdks
xcopy %WebSdkSource%Microsoft.NET.Sdk.Web\Targets\Sdk.props  %DOTNET_INSTALL_DIR%\Sdk\%DOTNET_VERSION%\Sdks\Microsoft.NET.Sdk.Web\Sdk\ /y /C
xcopy %WebSdkSource%Microsoft.NET.Sdk.Web\Targets\Sdk.targets  %DOTNET_INSTALL_DIR%\Sdk\%DOTNET_VERSION%\Sdks\Microsoft.NET.Sdk.Web\Sdk\ /y /C

REM Copy Targets
xcopy %WebSdkSource%Microsoft.NET.Sdk.Publish\Targets\netstandard1.0\*  %DOTNET_INSTALL_DIR%\Sdk\%DOTNET_VERSION%\Sdks\Microsoft.NET.Sdk.Publish\build\netstandard1.0\* /y /C /e /s /f
xcopy %WebSdkSource%Microsoft.NET.Sdk.Web.ProjectSystem\Targets\netstandard1.0\*  %DOTNET_INSTALL_DIR%\Sdk\%DOTNET_VERSION%\Sdks\Microsoft.NET.Sdk.Web.ProjectSystem\build\netstandard1.0\* /y /C /e /s /f

REM Copy Tasks
xcopy %WebSdkBin%Release\net46\Microsoft.NET.Sdk.Publish.Tasks.dll %DOTNET_INSTALL_DIR%\Sdk\%DOTNET_VERSION%\Sdks\Microsoft.NET.Sdk.Publish\tools\net46\ /y /C
xcopy %WebSdkBin%Release\netstandard1.3\Microsoft.NET.Sdk.Publish.Tasks.dll %DOTNET_INSTALL_DIR%\Sdk\%DOTNET_VERSION%\Sdks\Microsoft.NET.Sdk.Publish\tools\netcoreapp1.0\ /y /C

REM Tests
call dotnet build %WebSdkRoot%test\Publish\Microsoft.NET.Sdk.Publish.Tasks.Tests\Microsoft.NET.Sdk.Publish.Tasks.Tests.csproj /p:configuration=Release
if errorlevel 1 GOTO ERROR

REM dotnet test does not report errors if a test fails and target framework is not passed to the dotnet test command. dotnet test silently fails. Hence, calling the dotnet test 2 times, one for each framework.
call dotnet test %WebSdkRoot%test\Publish\Microsoft.NET.Sdk.Publish.Tasks.Tests\Microsoft.NET.Sdk.Publish.Tasks.Tests.csproj /p:configuration=Release;TargetFramework=net46
if errorlevel 1 GOTO ERROR

call dotnet test %WebSdkRoot%test\Publish\Microsoft.NET.Sdk.Publish.Tasks.Tests\Microsoft.NET.Sdk.Publish.Tasks.Tests.csproj /p:configuration=Release;TargetFramework=netcoreapp1.0
if errorlevel 1 GOTO ERROR

msbuild %WebSdkRoot%build.proj /p:configuration=Release /t:Pack;Sign
if errorlevel 0 exit /b 0

:ERROR
endlocal
exit /b 1