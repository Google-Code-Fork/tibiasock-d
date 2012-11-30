mkdir Release
set PATH=C:\Dlang\dmd2\windows\bin;c:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\\bin;%PATH%
dmd -release -X -Xf"Release\Tibiasock_Test.json" -I"C:\Dlang\dmd2\src\phobos" -I"C:\Dlang\dmd2\src\druntime\import" -deps="Release\Tibiasock_Test.dep" -c -of"Release\Tibiasock_Test.obj" tibia\packet.d tibia\tibiasock.d tibia\winapi.d main.d
if errorlevel 1 goto reportError

set LIB="C:\Dlang\dmd2\windows\bin\\..\lib";\dm\lib

echo "Release\Tibiasock_Test.obj","Release\Tibiasock_Test.exe","Release\Tibiasock_Test.map",user32.lib+kernel32.lib,,/NOMAP/NOI >Release\Tibiasock_Test.build.lnkarg

"C:\Program Files (x86)\VisualD\pipedmd.exe" -deps Release\Tibiasock_Test.lnkdep C:\Dlang\dmd2\windows\bin\\link.exe  @Release\Tibiasock_Test.build.lnkarg
if errorlevel 1 goto reportError
if not exist "Release\Tibiasock_Test.exe" (echo "Release\Tibiasock_Test.exe" not created! && goto reportError)

goto noError

:reportError
echo Building Release\Tibiasock_Test.exe failed!

:noError
