ResEdit
=======

Overview
--------

ResEdit is an open source application to delete/update/add resources to an Executable or DLL


Examples
--------

* To change the current ico file:
```
ResEdit --update-resource-ico Path/to/the/exe/or/dll IDI_ICON1 Path/to/the/ico/resource
```

* To list all resources:
```
ResEdit --list-resources Path/to/the/exe/or/dll
```

Usage
-----

```
CTKResEdit.exe --help

Option
  -h, --help              Display available command line arguments.
  -l, --list-resources    List all resources of an executable or library.
  --add-resource-bitmap   Add resource using the provided <path/to/exec/or/lib> <resourceName> and <path/to/resource>
  --update-resource-ico   Add resource using the provided <path/to/exec/or/lib> <resourceName> and <path/to/resource>
  --delete-resource       Delete resource using the provided <path/to/exec/or/lib> <resourceType> <resourceName>
```

Prerequistes
------------

* Qt >= 4.7
* CMake >= 2.8.2 - http://cmake.org
* Visual Studio >= 2008
* Git - http://git-scm.com/downloads

Checkout, Configure and Build
-----------------------------

1. Start Git bash
2. Execute the following commands:

```
git clone git://github.com/jcfr/ResEdit.git CTKResEdit
mkdir CTKResEdit-Release
cmake -G "Visual Studio 9 2008" ../CTKResEdit
cmake --build . --config Release
```

Test
----

1. Start Windows cmd line
2. Execute the following commands:

```
cd \path\to\CTKResEdit-Release
.\SetEnv.bat
.\Release\CTKResEdit.exe --help
cmake --build . --config Release --target RUN_TESTS
```

