mkdir Debug
set PATH=C:\Dlang\dmd2\windows\bin;c:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\\bin;%PATH%
dmd -g -debug -X -Xf"Debug\Tibiasock_Test.json" -I"C:\Dlang\dmd2\src\phobos" -I"C:\Dlang\dmd2\src\druntime\import" -deps="Debug\Tibiasock_Test.dep" -c -of"Debug\Tibiasock_Test.obj" tibia\packet.d tibia\tibiasock.d tibia\winapi.d main.d
if errorlevel 1 goto reportError

set LIB="C:\Dlang\dmd2\windows\bin\\..\lib";\dm\lib

echo "Debug\Tibiasock_Test.obj","Debug\Tibiasock_Test.exe_cv","Debug\Tibiasock_Test.map",user32.lib+kernel32.lib,,/NOMAP/CO/NOI >Debug\Tibiasock_Test.build.lnkarg

"C:\Program Files (x86)\VisualD\pipedmd.exe" -deps Debug\Tibiasock_Test.lnkdep C:\Dlang\dmd2\windows\bin\\link.exe  @Debug\Tibiasock_Test.build.lnkarg
if errorlevel 1 goto reportError
if not exist "Debug\Tibiasock_Test.exe_cv" (echo "Debug\Tibiasock_Test.exe_cv" not created! && goto reportError)
echo Converting debug information...
"C:\Program Files (x86)\VisualD\cv2pdb\cv2pdb.exe" "Debug\Tibiasock_Test.exe_cv" "Debug\Tibiasock_Test.exe"
if errorlevel 1 goto reportError
if not exist "Debug\Tibiasock_Test.exe" (echo "Debug\Tibiasock_Test.exe" not created! && goto reportError)

goto noError

:reportError
echo Building Debug\Tibiasock_Test.exe failed!

:noError
