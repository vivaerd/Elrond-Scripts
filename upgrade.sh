:: Node Upgrade Script 

@echo off
if not exist "%userprofile%\node-pem-backup" mkdir "%userprofile%\node-pem-backup"
if not exist "%userprofile%\node-pem-backup\db_backup" mkdir "%userprofile%\node-pem-backup\db_backup"
:: *Making backup directories for node2 and node3 
if not exist "%userprofile%\node-pem-backup2" mkdir "%userprofile%\node-pem-backup2"
if not exist "%userprofile%\node-pem-backup2\db_backup" mkdir "%userprofile%\node-pem-backup2\db_backup"

if not exist "%userprofile%\node-pem-backup3" mkdir "%userprofile%\node-pem-backup3"
if not exist "%userprofile%\node-pem-backup3\db_backup" mkdir "%userprofile%\node-pem-backup3\db_backup"

cd "%GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node\config"

::backup your keys
copy /Y initialBalancesSk.pem "%userprofile%\node-pem-backup"
copy /Y initialNodesSk.pem "%userprofile%\node-pem-backup"
:: Backup your database
robocopy /E "%GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node\db" "%userprofile%\node-pem-backup\db_backup"

:: *Backing up node2 and node3 
cd "%GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node2\config"

::backup your keys
copy /Y initialBalancesSk.pem "%userprofile%\node-pem-backup2"
copy /Y initialNodesSk.pem "%userprofile%\node-pem-backup2"
:: Backup your database
robocopy /E "%GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node2\db" "%userprofile%\node-pem-backup2\db_backup"

cd "%GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node3\config"

::backup your keys
copy /Y initialBalancesSk.pem "%userprofile%\node-pem-backup3"
copy /Y initialNodesSk.pem "%userprofile%\node-pem-backup3"
:: Backup your database
robocopy /E "%GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node3\db" "%userprofile%\node-pem-backup3\db_backup"

:: *Backups done so far

cd "%GOPATH%\src\github.com\ElrondNetwork"

:: Delete previously cloned repos

@RD /S /Q "%GOPATH%\src\github.com\ElrondNetwork\elrond-go"
if exist "%GOPATH%\src\github.com\ElrondNetwork\elrond-go" @RD /S /Q "%GOPATH%\src\github.com\ElrondNetwork\elrond-go"
@RD /S /Q "%GOPATH%\src\github.com\ElrondNetwork\elrond-config"
if exist "%GOPATH%\src\github.com\ElrondNetwork\elrond-config" @RD /S /Q "%GOPATH%\src\github.com\ElrondNetwork\elrond-config"
timeout 15
if exist "%GOPATH%\src\github.com\ElrondNetwork\elrond-go" @RD /S /Q "%GOPATH%\src\github.com\ElrondNetwork\elrond-go"
if exist "%GOPATH%\src\github.com\ElrondNetwork\elrond-config" @RD /S /Q "%GOPATH%\src\github.com\ElrondNetwork\elrond-config"

cd %userprofile%
SET BINTAG=v1.0.24
SET CONFTAG=BoN-ph1-w1-p1
cd %GOPATH%\src\github.com\ElrondNetwork

:: Clone elrond-go & elrond-config repos
git clone --branch %BINTAG% https://github.com/ElrondNetwork/elrond-go
git clone --branch %CONFTAG% https://github.com/ElrondNetwork/elrond-config

if not exist "%GOPATH%\src\github.com\ElrondNetwork" mkdir "%GOPATH%\src\github.com\ElrondNetwork"
cd %GOPATH%\src\github.com\ElrondNetwork
cd %GOPATH%\src\github.com\ElrondNetwork\elrond-config
copy /Y *.* "%GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node\config"
copy /Y *.* "%GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node2\config"
copy /Y *.* "%GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node3\config"

:: *Copying config also for node2 and node3 (though later on the robocopy will replace again)

:: Build the node executable
cd %GOPATH%\pkg\mod\cache
del /s *.lock
cd %GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node

@echo on
SET GO111MODULE=on
go mod vendor
go build -i -v -ldflags="-X main.appVersion=%BINTAG%"
@echo off

:: *Copy compiled node and associated files to node2 and node3
robocopy /E "%GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node\" "%GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node2"
robocopy /E "%GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node\" "%GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node3"

:: *Restoring keys and db for all nodes

:: restore your keys
cd %userprofile%\node-pem-backup
copy /Y initialBalancesSk.pem "%GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node\config"
copy /Y initialNodesSk.pem "%GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node\config"

:: restore your db
robocopy /E "%userprofile%\node-pem-backup\db_backup" "%GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node\db" 
@RD /S /Q "%userprofile%\node-pem-backup\db_backup"

:: restore your keys
cd %userprofile%\node-pem-backup2
copy /Y initialBalancesSk.pem "%GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node2\config"
copy /Y initialNodesSk.pem "%GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node2\config"

:: restore your db
robocopy /E "%userprofile%\node-pem-backup2\db_backup" "%GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node2\db" 
@RD /S /Q "%userprofile%\node-pem-backup2\db_backup"

:: restore your keys
cd %userprofile%\node-pem-backup3
copy /Y initialBalancesSk.pem "%GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node3\config"
copy /Y initialNodesSk.pem "%GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node3\config"

:: restore your db
robocopy /E "%userprofile%\node-pem-backup3\db_backup" "%GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node3\db" 
@RD /S /Q "%userprofile%\node-pem-backup3\db_backup"


:: *All nodes restored (node, node2, node3)

:: *now run them nodes individually ( open terminal, do the commands from the two lines below, or let other .bat scripts to do this for you)
:: cd %GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node
:: node.exe --rest-api-port 8081 

cd %GOPATH%
start call %GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node\node.exe --rest-api-port 8081
start call %GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node2\node.exe --rest-api-port 8082
start call %GOPATH%\src\github.com\ElrondNetwork\elrond-go\cmd\node3\node.exe --rest-api-port 8083
