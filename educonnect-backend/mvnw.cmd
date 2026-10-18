@REM ----------------------------------------------------------------------------
@REM Maven Wrapper startup batch script
@REM ----------------------------------------------------------------------------
@IF "%__MVNW_ARG0_NAME__%"=="" (SET "MVN_CMD=mvn.cmd") ELSE (SET "MVN_CMD=%__MVNW_ARG0_NAME__%")

@SET MAVEN_WRAPPER_JAR="%MAVEN_PROJECTBASEDIR%\.mvn\wrapper\maven-wrapper.jar"
@SET MAVEN_WRAPPER_PROPERTIES="%MAVEN_PROJECTBASEDIR%\.mvn\wrapper\maven-wrapper.properties"
@SET DOWNLOAD_URL="https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/3.2.0/maven-wrapper-3.2.0.jar"

@FOR /F "usebackq tokens=1,2 delims==" %%A IN (%MAVEN_WRAPPER_PROPERTIES%) DO (
    @IF "%%A"=="wrapperUrl" SET DOWNLOAD_URL=%%B
)

@SET JAVA_HOME_CANDIDATE="%JAVA_HOME%"
@IF NOT EXIST "%JAVA_HOME_CANDIDATE%\bin\java.exe" (
    @FOR /F "tokens=*" %%F IN ('where java.exe 2^>nul') DO @SET "JAVA_EXE=%%F" & goto :found_java
    @echo Java not found. Please set JAVA_HOME or add java to PATH.
    @exit /b 1
)
:found_java

@SET JAVA_EXE="%JAVA_HOME%\bin\java.exe"

@IF NOT EXIST %MAVEN_WRAPPER_JAR% (
    @echo Downloading Maven Wrapper...
    @"%JAVA_EXE%" -classpath "" org.apache.maven.wrapper.MavenWrapperMain %* 2>nul
    @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -Command ^
        "$webclient = new-object System.Net.WebClient; $webclient.DownloadFile('%DOWNLOAD_URL%', '%MAVEN_WRAPPER_JAR%')"
)

@"%JAVA_EXE%" -classpath %MAVEN_WRAPPER_JAR% org.apache.maven.wrapper.MavenWrapperMain %*
