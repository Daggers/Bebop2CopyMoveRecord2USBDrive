@echo off
REM ------- MENU -----------
cls
ECHO.
ECHO ====================================================
ECHO This installer is for PARROT BEBOP DRONE and BEBOP 2
ECHO.
ECHO ====================================================
ECHO You are about to install scripts to your drone
ECHO that will enable you to copy and move media files 
ECHO directly to USB OTG pendrive. Also to be able to 
ECHO record directly to the pendrive.
ECHO ====================================================
ECHO.
ECHO 1 - Install scripts to your Drone
ECHO 2 - Remove installed scripts from your Drone
ECHO 3 - Format USB Drive
ECHO 4 - Read the nfo file.
ECHO 5 - EXIT
ECHO.
SET /P M=Type 1, 2, 3, or 4 then press ENTER: 
IF %M%==1 GOTO installer
IF %M%==2 GOTO remove
IF %M%==3 GOTO format
IF %M%==4 GOTO nfofile
IF %M%==5 GOTO exit

REM ---------- INSTALLER ---------
:installer
cls
echo.
echo Turn ON your Drone.
echo Connect to it's WI-FI network in Windows.
echo.
echo When connected press any key to continue . . .
pause >nul
cls
echo.
echo Please press the POWER BUTTON 4 times on your drone.
echo.
echo When done press any key to continue . . .
pause >nul
cls
echo.
echo Copying files to your Drone
WinSCP.com /script=ftp.scr > ftp.res
if %errorlevel% equ 1 goto ftp_cantconnect

find /c "100%" ftp.res >nul
if %errorlevel% equ 1 goto ftp_err
del ftp.res >nul
echo Done
goto ftp_ok

:ftp_err
del ftp.res >nul
echo Failed to copy files to Drone. Installation terminate . . .
pause
goto ftp_cleanup

:ftp_cantconnect
del ftp.res >nul
echo Failed to connect to Drone. Installation terminate . . .
echo Press any key to EXIT
pause>nul
goto exit

:ftp_ok
echo.
echo Installing Scripts on your Drone.
plink.exe -telnet -P 23 192.168.42.1 < install_telnet.scr > install_telnet.res
if %errorlevel% equ 1 goto telnet_err
find /c "mv: can't rename" install_telnet.res >nul
if %errorlevel% equ 0 goto telnet_err
del install_telnet.res >nul
echo Done
goto telnet_ok

:telnet_err
del install_telnet.res >nul
echo Failed to intall files to Drone. Installation terminate . . .
pause
goto ftp_cleanup
:telnet_ok


echo.
echo Installation Successful.
echo Please wait until your drone restarts.
echo.
echo Press any key to EXIT
pause>nul
goto exit

:ftp_cleanup
echo Removing installation files from your Drone.
WinSCP.com /script=ftp_cleanup.scr >nul
WinSCP.com /script=ftp_ls.scr > ftp_ls.res
find /c "shortpress_" ftp_ls.res >nul
if %errorlevel% equ 0 goto ftp_cleanup_err
del ftp_ls.res >nul
echo Done.
echo Press any key to EXIT.
pause >nul
goto exit
:ftp_cleanup_err
del ftp_ls.res >nul
echo.
echo Could not remove installation files from Drone.
echo.
echo Please reset your drone to factory settings by pressing 
echo and holding the POWER BUTTON for 10 seconds.
echo It will take a up to 5 minutes to complete 
echo then your drone will reboot.
pause
goto exit


REM -------- REMOVE INSTALLED SCRIPTS ------------
:remove
cls
echo.
echo Turn ON your Drone.
echo Connect to it's WI-FI network in Windows.
echo.
echo When connected press any key to continue . . .
pause >nul
cls
echo.
echo Please press the POWER BUTTON 4 times on your drone.
echo.
echo When done press any key to continue . . .
pause >nul
cls
echo.
echo Removing Scripts from your Drone.
plink.exe -telnet -P 23 192.168.42.1 < remove_telnet.scr >nul
if %errorlevel% equ 1 goto remove_cantconnect
plink.exe -telnet -P 23 192.168.42.1 < remove_ls_telnet.scr > remove_ls_telnet.res

find /c "shortpress_9" remove_ls_telnet.res >nul
if %errorlevel% equ 1 goto remove_telnet_ok
del remove_ls_telnet.res >nul
echo.
echo Failed to remove files from Drone. Terminate . . .
echo.
echo Please reset your drone to factory settings by pressing 
echo and holding the POWER BUTTON for 10 seconds.
echo It will take a up to 5 minutes to complete 
echo then your drone will reboot.
echo.
echo Press any key to EXIT
pause >nul
goto exit

:remove_telnet_ok
del remove_ls_telnet.res >nul
echo.
echo Successfully removed files.
echo Please wait until your drone restarts.
echo.
echo Press any key to EXIT
pause >nul
goto exit

:remove_cantconnect
echo.
echo Failed to connect to Drone . . .
echo.
echo Please make sure your drone is turned on, computer is connected
echo to the drone and you have pressed the 
echo power button 4 times on your drone.
echo.
echo If the problem still exists then please reset your drone to 
echo factory settings by pressing and holding the 
echo POWER BUTTON for 10 seconds.
echo It will take a up to 5 minutes to complete 
echo then your drone will reboot.
echo.
echo Press any key to EXIT
pause>nul
goto exit


REM ---------- FORMAT ------------
:format
cls
echo.
echo ===============
echo FAT32 formatter
echo ===============
echo.
echo You can format your pendrive by connection it 
echo to your PC and using this application.
echo It supports pen drives up to 2TB.
echo.
echo Credit for the author: http://www.ridgecrop.demon.co.uk/
pause
echo.
echo ===========================================
echo  PLEASE SAVE ANY OPEN JOBS BEFORE CONTINUE
echo ===========================================
echo.
echo "explorer.exe" will restart before opening the format tool.
pause
taskkill /f /im explorer.exe >nul && start explorer
guiformat.exe
goto exit


REM ---------- NFO ------------
:nfofile
notepad.exe howto.txt
goto exit



REM ---------- EXIT ------------
:exit
