OVERVIEW
ResEdit is an open source application to delete/update/add resources to an Executable or DLL

PREREQUISTES
Qt need to be compiled in static
Otherwise after compiled the project, add new file SetEnv.bat into the executable directory
SetEnv.bat contains following two lines :
@ECHO OFF
set PATH=C:\work\Qt\qt-everywhere-opensource-src-4.7.3\bin;%PATH% //link to Qt/bin

CHECKOUT, CONFIGURE and BUILD
git clone git://github.com/benjaminlong/ResEdit.git ResEdit
then use cmake to configure and build.

RUN
ResEdit -help to show all the command lines

//--------------------
To list all resources:
ResEdit --list-resources Path/to/the/exe/or/dll
ResEdit -l Path/to/the/exe/or/dll

//--------------------
To change the current ico file:
ResEdit --update-resource-ico Path/to/the/exe/or/dll ResourceName Path/to/the/ico/resource