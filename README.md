ResEdit
=======

Overview
--------

ResEdit is an open source application to delete/update/add resources to an Executable or DLL

Prerequistes
------------

Qt need to be compiled in static !

Otherwise after compiled the project, add new file SetEnv.bat into the executable directory.

SetEnv.bat contains following two lines :

```
@ECHO OFF
set PATH=C:\work\Qt\qt-everywhere-opensource-src-4.7.3\bin;%PATH% //link to Qt/bin
```


Checkout, Configure and Build
-----------------------------

Use the following git command line to checkout the project :

    git clone git://github.com/benjaminlong/ResEdit.git ResEdit

Then use cmake to configure and build.

Run
---
**1/ Go to the executable directory.**

If you have create the file SetEnv.bat, run the following command line first:

    SetEnv.bat

**2/ Now you can run the application.**

Some examples of command lines :

* To show all the command lines:

```
ResEdit --help
```
* To list all resources:

```
ResEdit --list-resources Path/to/the/exe/or/dll
ResEdit -l Path/to/the/exe/or/dll
```
* To change the current ico file:

```
ResEdit --update-resource-ico Path/to/the/exe/or/dll ResourceName Path/to/the/ico/resource
```