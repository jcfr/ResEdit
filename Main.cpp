
// Qt includes
#include <QCoreApplication>
#include <QDebug>
#include <QFile>
#include <QTextStream>

// Windows includes
#include <Windows.h>

// STD includes
#include <cstdlib>
#include <iostream>

// ResEdit includes
#include "ctkCommandLineParser.h"
#include "ctkResEditVersionConfig.h"

// Store all the resources
//QHash<QString, QString> Resources;

// Declare callback functions.
BOOL EnumTypesFunc(HMODULE hModule, LPTSTR lpType, LONG lParam);
BOOL EnumNamesFunc(HMODULE hModule, LPTSTR lpType, LPTSTR lpName, LONG lParam);
BOOL EnumLangsFunc(HMODULE hModule, LPTSTR lpType, LPTSTR lpName, WORD wLang, LONG lParam);

HMODULE loadLibraryEx(LPCTSTR lpFileName, HANDLE hFile, DWORD dwFlags);
bool removeResource(QString exePath,  QString lpType, QString resourceName);
bool addResourceBITMAP(QString executablePath, QString resourceName, QString resourcePath);
bool updateResourceICO(QString executablePath, QString resourceName, QString resourcePath);

namespace icons
{
	WORD nMaxID=0;
	// These next two structs represent how the icon information is stored
	// in an ICO file.
	typedef struct
		{
		BYTE	bWidth;               // Width of the image
		BYTE	bHeight;              // Height of the image (times 2)
		BYTE	bColorCount;          // Number of colors in image (0 if >=8bpp)
		BYTE	bReserved;            // Reserved
		WORD	wPlanes;              // Color Planes
		WORD	wBitCount;            // Bits per pixel
		DWORD	dwBytesInRes;         // how many bytes in this resource?
		DWORD	dwImageOffset;        // where in the file is this image
		} ICONDIRENTRY, *LPICONDIRENTRY;
	typedef struct
		{
		WORD			idReserved;   		// Reserved
		WORD			idType;       		// resource type (1 for icons)
		WORD			idCount;      		// how many images?
		LPICONDIRENTRY	idEntries; 	// the entries for each image
		} ICONDIR, *LPICONDIR;

	// The following two structs are for the use of this program in
	// manipulating icons. They are more closely tied to the operation
	// of this program than the structures listed above. One of the
	// main differences is that they provide a pointer to the DIB
	// information of the masks.
	typedef struct
		{
		UINT					Width, Height, Colors; 	// Width, Height and bpp
		LPBYTE				lpBits;                	// ptr to DIB bits
		DWORD					dwNumBytes;            	// how many bytes?
		LPBITMAPINFO	lpbi;                 	// ptr to header
		LPBYTE				lpXOR;                 	// ptr to XOR image bits
		LPBYTE				lpAND;                 	// ptr to AND image bits
		} ICONIMAGE, *LPICONIMAGE;
	typedef struct
		{
		BYTE	bWidth;               // Width of the image
		BYTE	bHeight;              // Height of the image (times 2)
		BYTE	bColorCount;          // Number of colors in image (0 if >=8bpp)
		BYTE	bReserved;            // Reserved
		WORD	wPlanes;              // Color Planes
		WORD	wBitCount;            // Bits per pixel
		DWORD	dwBytesInRes;         // how many bytes in this resource?
		WORD	nID;                  // the ID
		} MEMICONDIRENTRY, *LPMEMICONDIRENTRY;
	typedef struct
		{
		WORD			idReserved;   			// Reserved
		WORD			idType;       			// resource type (1 for icons)
		WORD			idCount;      			// how many images?
		LPMEMICONDIRENTRY	idEntries; 	// the entries for each image
		} MEMICONDIR, *LPMEMICONDIR;

	// -------------------------------------------------------------------------
	LPICONIMAGE* ExtractIcoFromFile(LPSTR filename, LPICONDIR pIconDir)
	{
		BOOL res=true;
		HANDLE	hFile1 = NULL, hFile2=NULL, hFile3=NULL;
		DWORD	dwBytesRead;
		LPICONIMAGE pIconImage;
		LPICONIMAGE *arrayIconImage;
		DWORD cbInit=0,cbOffsetDir=0,cbOffset=0,cbInitOffset=0;
		BYTE *temp;
		int i;

		if( (hFile1 = CreateFileA( filename, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL )) == INVALID_HANDLE_VALUE )
			{
			QTextStream(stderr, QIODevice::WriteOnly) << "Error Opening File for Reading" << filename << "\n";
			return NULL;
			}
		ReadFile( hFile1, &(pIconDir->idReserved), sizeof( WORD ), &dwBytesRead, NULL );
		ReadFile( hFile1, &(pIconDir->idType), sizeof( WORD ), &dwBytesRead, NULL );
		ReadFile( hFile1, &(pIconDir->idCount), sizeof( WORD ), &dwBytesRead, NULL );

		pIconDir->idEntries = new ICONDIRENTRY[pIconDir->idCount];

		// Read the ICONDIRENTRY elements
		temp=new BYTE[sizeof(ICONDIRENTRY)];
		for(i=0;i<pIconDir->idCount;i++)
			{
			ReadFile( hFile1, &pIconDir->idEntries[i], sizeof(ICONDIRENTRY), &dwBytesRead, NULL );
			}
		arrayIconImage = new LPICONIMAGE[pIconDir->idCount];
		// Loop through and read in each image
		for(i=0;i<pIconDir->idCount;i++)
			{
			pIconImage = (LPICONIMAGE)malloc( pIconDir->idEntries[i].dwBytesInRes );
			SetFilePointer( hFile1, pIconDir->idEntries[i].dwImageOffset,NULL, FILE_BEGIN );
			ReadFile( hFile1, pIconImage, pIconDir->idEntries[i].dwBytesInRes,&dwBytesRead, NULL );
			arrayIconImage[i]=(LPICONIMAGE)malloc( pIconDir->idEntries[i].dwBytesInRes );
			memcpy( arrayIconImage[i],pIconImage, pIconDir->idEntries[i].dwBytesInRes );
			free(pIconImage);
			}

		CloseHandle(hFile1);
		return arrayIconImage;
	}

	BOOL ReplaceIconResource(LPSTR lpFileName, LPCTSTR lpName, UINT langId, LPICONDIR pIconDir,	LPICONIMAGE* pIconImage)
	{
		BOOL res=true;
		HANDLE	hFile3=NULL;
		LPMEMICONDIR lpInitGrpIconDir=new MEMICONDIR;

		//LPICONIMAGE pIconImage;
		HINSTANCE hUi;
		BYTE *test,*test1,*temp,*temp1;
		DWORD cbInit=0,cbOffsetDir=0,cbOffset=0,cbInitOffset=0;
		WORD cbRes=0;
		int i;

		hUi = LoadLibraryExA(lpFileName,NULL,DONT_RESOLVE_DLL_REFERENCES | LOAD_LIBRARY_AS_DATAFILE);
		HRSRC hRsrc = FindResourceEx(hUi, RT_GROUP_ICON, lpName,langId);
		//nu stiu de ce returneaza 104 wtf???
		//cbRes=SizeofResource( hUi, hRsrc );
		HGLOBAL hGlobal = LoadResource( hUi, hRsrc );
		test1 =(BYTE*) LockResource( hGlobal );
		temp1=test1;
	//	temp1=new BYTE[118];
	//	CopyMemory(temp1,test1,118);
		if (test1)
			{
			lpInitGrpIconDir->idReserved=(WORD)*test1;
			test1=test1+sizeof(WORD);
			lpInitGrpIconDir->idType=(WORD)*test1;
			test1=test1+sizeof(WORD);
			lpInitGrpIconDir->idCount=(WORD)*test1;
			test1=test1+sizeof(WORD);
			}
		else
			{
			lpInitGrpIconDir->idReserved=0;
			lpInitGrpIconDir->idType=1;
			lpInitGrpIconDir->idCount=0;
			}

		lpInitGrpIconDir->idEntries=new MEMICONDIRENTRY[lpInitGrpIconDir->idCount];

		for(i=0;i<lpInitGrpIconDir->idCount;i++)
			{
			lpInitGrpIconDir->idEntries[i].bWidth=(BYTE)*test1;
			test1=test1+sizeof(BYTE);
			lpInitGrpIconDir->idEntries[i].bHeight=(BYTE)*test1;
			test1=test1+sizeof(BYTE);
			lpInitGrpIconDir->idEntries[i].bColorCount=(BYTE)*test1;
			test1=test1+sizeof(BYTE);
			lpInitGrpIconDir->idEntries[i].bReserved=(BYTE)*test1;
			test1=test1+sizeof(BYTE);
			lpInitGrpIconDir->idEntries[i].wPlanes=(WORD)*test1;
			test1=test1+sizeof(WORD);
			lpInitGrpIconDir->idEntries[i].wBitCount=(WORD)*test1;
			test1=test1+sizeof(WORD);
			//nu merge cu (DWORD)*test
			lpInitGrpIconDir->idEntries[i].dwBytesInRes=pIconDir->idEntries[i].dwBytesInRes;
			test1=test1+sizeof(DWORD);
			lpInitGrpIconDir->idEntries[i].nID=(WORD)*test1;
			test1=test1+sizeof(WORD);
			}
		//	memcpy( lpInitGrpIconDir->idEntries, test, cbRes-3*sizeof(WORD) );

		UnlockResource((HGLOBAL)test1);

		LPMEMICONDIR lpGrpIconDir=new MEMICONDIR;
		lpGrpIconDir->idReserved=pIconDir->idReserved;
		lpGrpIconDir->idType=pIconDir->idType;
		lpGrpIconDir->idCount=pIconDir->idCount;
		cbRes=3*sizeof(WORD)+lpGrpIconDir->idCount*sizeof(MEMICONDIRENTRY);
		test=new BYTE[cbRes];
		temp=test;
		CopyMemory(test,&lpGrpIconDir->idReserved,sizeof(WORD));
		test=test+sizeof(WORD);
		CopyMemory(test,&lpGrpIconDir->idType,sizeof(WORD));
		test=test+sizeof(WORD);
		CopyMemory(test,&lpGrpIconDir->idCount,sizeof(WORD));
		test=test+sizeof(WORD);

		lpGrpIconDir->idEntries=new MEMICONDIRENTRY[lpGrpIconDir->idCount];
		for(i=0;i<lpGrpIconDir->idCount;i++)
			{
			lpGrpIconDir->idEntries[i].bWidth=pIconDir->idEntries[i].bWidth;
			CopyMemory(test,&lpGrpIconDir->idEntries[i].bWidth,sizeof(BYTE));
			test=test+sizeof(BYTE);
			lpGrpIconDir->idEntries[i].bHeight=pIconDir->idEntries[i].bHeight;
			CopyMemory(test,&lpGrpIconDir->idEntries[i].bHeight,sizeof(BYTE));
			test=test+sizeof(BYTE);
			lpGrpIconDir->idEntries[i].bColorCount=pIconDir->idEntries[i].bColorCount;
			CopyMemory(test,&lpGrpIconDir->idEntries[i].bColorCount,sizeof(BYTE));
			test=test+sizeof(BYTE);
			lpGrpIconDir->idEntries[i].bReserved=pIconDir->idEntries[i].bReserved;
			CopyMemory(test,&lpGrpIconDir->idEntries[i].bReserved,sizeof(BYTE));
			test=test+sizeof(BYTE);
			lpGrpIconDir->idEntries[i].wPlanes=pIconDir->idEntries[i].wPlanes;
			CopyMemory(test,&lpGrpIconDir->idEntries[i].wPlanes,sizeof(WORD));
			test=test+sizeof(WORD);
			lpGrpIconDir->idEntries[i].wBitCount=pIconDir->idEntries[i].wBitCount;
			CopyMemory(test,&lpGrpIconDir->idEntries[i].wBitCount,sizeof(WORD));
			test=test+sizeof(WORD);
			lpGrpIconDir->idEntries[i].dwBytesInRes=pIconDir->idEntries[i].dwBytesInRes;
			CopyMemory(test,&lpGrpIconDir->idEntries[i].dwBytesInRes,sizeof(DWORD));
			test=test+sizeof(DWORD);
			if(i<lpInitGrpIconDir->idCount) //nu am depasit numarul initial de RT_ICON
				lpGrpIconDir->idEntries[i].nID=lpInitGrpIconDir->idEntries[i].nID;
			else
				{
				nMaxID++;
				lpGrpIconDir->idEntries[i].nID=i+1; //adaug noile ICO la sfarsitul RT_ICON-urilor
				}
			CopyMemory(test,&lpGrpIconDir->idEntries[i].nID,sizeof(WORD));
			test=test+sizeof(WORD);
			}

		//offsetul de unde incep structurile ICONIMAGE
		cbInitOffset=3*sizeof(WORD)+lpGrpIconDir->idCount*sizeof(ICONDIRENTRY);
		cbOffset=cbInitOffset; //cbOffset=118

		FreeLibrary(hUi);

		HANDLE hUpdate;
//		_chmod((char*)lpFileName,_S_IWRITE);
		hUpdate = BeginUpdateResourceA(lpFileName, FALSE); //false sa nu stearga resursele neupdated
		if(hUpdate==NULL)
			{
			QTextStream(stderr, QIODevice::WriteOnly) << "error BeginUpdateResource " << lpFileName << "\n";
			res=false;
			}
		//aici e cu lang NEUTRAL
		//res=UpdateResource(hUpdate,RT_GROUP_ICON,MAKEINTRESOURCE(6000),langId,lpGrpIconDir,cbRes);
		res=UpdateResource(hUpdate,RT_GROUP_ICON,lpName,langId,temp,cbRes);
		if(res==false)
			QTextStream(stdout, QIODevice::WriteOnly) << "erreur UpdateResource RT_GROUP_ICON " << lpFileName << "\n";

		for(i=0;i<lpGrpIconDir->idCount;i++)
			{
			res=UpdateResource(hUpdate,RT_ICON,MAKEINTRESOURCE(lpGrpIconDir->idEntries[i].nID),langId,pIconImage[i],lpGrpIconDir->idEntries[i].dwBytesInRes);
			if(res==false)
				QTextStream(stderr, QIODevice::WriteOnly) << "error UpdateResource RT_ICON " << lpFileName << "\n";
			}

		for(i=lpGrpIconDir->idCount;i<lpInitGrpIconDir->idCount;++i)
			{
			res=UpdateResource(hUpdate,RT_ICON,MAKEINTRESOURCE(lpInitGrpIconDir->idEntries[i].nID),langId,NULL,0);
			if(res==false)
        QTextStream(stderr, QIODevice::WriteOnly) << "error deleting resource " << lpFileName << "\n";
			}

		if(!EndUpdateResource(hUpdate,FALSE)) //false ->resource updates will take effect.
			QTextStream(stderr, QIODevice::WriteOnly) << "error EndUpdateResource" << lpFileName << "\n";

		//	FreeResource(hGlobal);
		delete[] lpGrpIconDir->idEntries;
		delete lpGrpIconDir;
		delete[] temp;

		return res;
	}
}

namespace resources
{
	char *types[25]=
	{
	"NULL","RT_CURSOR","RT_BITMAP","RT_ICON","RT_MENU","RT_DIALOG","RT_STRING","RT_FONTDIR","RT_FONT",
	"RT_ACCELERATORS","RT_RCDATA","RT_MESSAGETABLE","RT_GROUP_CURSOR","NULL",
	"RT_GROUP_ICON","NULL","RT_VERSION","RT_DLGINCLUDE","NULL","RT_PLUGPLAY","RT_VXD","RT_ANICURSOR", //21 de la 0 
	"RT_ANIICON","RT_HTML","RT_MANIFEST"
	};

	typedef struct
	{
		QString Type;
		QString Name;
		QString Lang;
	} Resource;

	QList<Resource> Resources;

	QString convertToString(LPTSTR value)
	{
		QString newValue;
		if (!IS_INTRESOURCE(value))
			{
			newValue = QString("%1").arg((char*) value);
			}
		else
			{
			newValue = QString("%1").arg((USHORT) value);
			}
		return newValue;
	}
}


// ----------------------------------------------------------------------------------
int main(int argc, char* argv[])
{
	ctkCommandLineParser commandLine;
	commandLine.setArgumentPrefix("--", "-");

	commandLine.beginGroup(QString("Option"));
	commandLine.addArgument("version","v", QVariant::Bool,
	  "Show application version information");
	commandLine.addArgument("help", "h", QVariant::Bool,
		"Display available command line arguments.");
	commandLine.addArgument("list-resources", "l", QVariant::String,
		"List all resources of an executable or library.");
	commandLine.addArgument("add-resource-bitmap", "", QVariant::StringList,
		"Add resource using the provided <path/to/exec/or/lib> <resourceName> and <path/to/resource>");
	commandLine.addArgument("update-resource-ico", "", QVariant::StringList,
		"Add resource using the provided <path/to/exec/or/lib> <resourceName> and <path/to/resource>");
	commandLine.addArgument("delete-resource", "", QVariant::StringList,
		"Delete resource using the provided <path/to/exec/or/lib> <resourceType> <resourceName>");
	commandLine.endGroup();

	bool ok;
	QHash<QString, QVariant> parsedArgs = commandLine.parseArguments(argc, argv, &ok);
	if (!ok)
		{
		QTextStream(stderr, QIODevice::WriteOnly) << "Error parsing arguments : " << commandLine.errorString() << "\n";
		return EXIT_FAILURE;
		}

  if (parsedArgs.value("version").toBool())
    {
    QTextStream(stdout, QIODevice::WriteOnly) << "CTKResEdit version "CTKResEdit_VERSION << "\n";
    return EXIT_SUCCESS;
    }
	else if (parsedArgs.contains("help") || parsedArgs.contains("h"))
		{
		QTextStream(stdout, QIODevice::WriteOnly) << commandLine.helpText() << "\n";
		return EXIT_SUCCESS;
		}

  char* exePath;
	HMODULE hExe;       // handle to existing .EXE file

	if(parsedArgs.contains("list-resources") || parsedArgs.contains("l"))
    {
		// Load the .EXE file that contains the dialog box you want to copy.
    exePath = (char*) malloc(parsedArgs.value("list-resources").toString().size() + 1);
    strcpy(exePath, parsedArgs.value("list-resources").toString().toLatin1().constData());
    hExe = loadLibraryEx(TEXT(exePath), NULL, LOAD_LIBRARY_AS_IMAGE_RESOURCE);
    if (!hExe)
      {
      return EXIT_FAILURE;
      }

		// List all resources
		EnumResourceTypes(hExe, (ENUMRESTYPEPROC)EnumTypesFunc, 0);

		for (int i = 0; i < resources::Resources.size() ; ++i)
			{
			QTextStream(stdout, QIODevice::WriteOnly) << "Type : " << resources::Resources.at(i).Type <<  " -- " << resources::types[resources::Resources.at(i).Type.toInt()] << "\n";
			QTextStream(stdout, QIODevice::WriteOnly) << "\tName : " << resources::Resources.at(i).Name << "\n";
			QTextStream(stdout, QIODevice::WriteOnly) << "\t\tLang : " << resources::Resources.at(i).Lang << "\n";
			}

		// Clean up.
		if (!FreeLibrary(hExe))
			{
			QTextStream(stderr, QIODevice::WriteOnly) << "Could not free executable : " << exePath << "\n";
			return EXIT_FAILURE;
			}
		}

	else if(parsedArgs.contains("delete-resource"))
		{
		QStringList arguments = parsedArgs.value("delete-resource").toStringList();
    exePath = (char*) malloc(arguments.at(0).size() + 1);
    strcpy(exePath, arguments.at(0).toLatin1().constData());
    hExe = loadLibraryEx(TEXT(exePath), NULL, LOAD_LIBRARY_AS_IMAGE_RESOURCE);
    if (!hExe)
      {
      return EXIT_FAILURE;
      }

		// List all resources
		EnumResourceTypes(hExe, (ENUMRESTYPEPROC)EnumTypesFunc, 0);
		FreeLibrary(hExe);

		bool resultat = removeResource(arguments.at(0), arguments.at(1), arguments.at(2));
		if(!resultat)
			{
			return EXIT_FAILURE;
			}
		}

	else if(parsedArgs.contains("add-resource-bitmap"))
		{
		QStringList arguments = parsedArgs.value("add-resource-bitmap").toStringList();

		bool result = addResourceBITMAP(arguments.at(0), arguments.at(1), arguments.at(2));
		if(!result)
			{
			QTextStream(stderr, QIODevice::WriteOnly) << "Resource bitmap couldn't be added.\n";
			return EXIT_FAILURE;
			}
		QTextStream(stdout, QIODevice::WriteOnly) << "Resource bitmap added.\n";
		return EXIT_SUCCESS;
		}

	else if(parsedArgs.contains("update-resource-ico"))
		{
		QStringList arguments = parsedArgs.value("update-resource-ico").toStringList();

		bool result = updateResourceICO(arguments.at(0), arguments.at(1), arguments.at(2));
		if(!result)
			{
			QTextStream(stderr, QIODevice::WriteOnly) << "Resource ico couldn't be updated.\n";
			return EXIT_FAILURE;
			}
		QTextStream(stdout, QIODevice::WriteOnly) << "Resource ico updated.\n";
		return EXIT_SUCCESS;
		}

  return EXIT_SUCCESS;
}

//    FUNCTION: EnumTypesFunc(HANDLE, LPSTR, LONG)
//
//    PURPOSE:  Resource type callback
// ----------------------------------------------------------------------------------
BOOL EnumTypesFunc(HMODULE hModule, LPTSTR lpType, LONG lParam)
{
	// Find the names of all resources of type lpType.
  EnumResourceNames(hModule, lpType, (ENUMRESNAMEPROC)EnumNamesFunc, 0);
  return TRUE;
}

//    FUNCTION: EnumNamesFunc(HANDLE, LPSTR, LPSTR, LONG)
//
//    PURPOSE:  Resource name callback
// ----------------------------------------------------------------------------------
BOOL EnumNamesFunc(HMODULE hModule, LPTSTR lpType, LPTSTR lpName, LONG lParam)
{
  EnumResourceLanguages(hModule, lpType, lpName, (ENUMRESLANGPROC)EnumLangsFunc, 0);
  return TRUE;
}

//    FUNCTION: EnumLangsFunc(HANDLE, LPSTR, LPSTR, WORD, LONG)
//
//    PURPOSE:  Resource language callback
// ----------------------------------------------------------------------------------
BOOL EnumLangsFunc(HMODULE hModule,LPTSTR lpType, LPTSTR lpName, WORD wLang, LONG lParam)
{
  HRSRC hResInfo;

  hResInfo = FindResourceEx(hModule, lpType, lpName, wLang);

	resources::Resource newResource = {"", "", 0};
	QString wLangStr = QString("%1").arg((USHORT) wLang);
	QString pTypeStr = resources::convertToString(lpType);
	QString pNameStr = resources::convertToString(lpName);
	newResource.Name = pNameStr;
	newResource.Type = pTypeStr;
	newResource.Lang = wLangStr;
	resources::Resources.push_front(newResource);

  return TRUE;
}

// ----------------------------------------------------------------------------------
HMODULE loadLibraryEx(LPCTSTR lpFileName, HANDLE hFile, DWORD dwFlags)
{
	HMODULE hExe;
	hExe = LoadLibraryEx(TEXT(lpFileName), hFile, dwFlags);
	if (hExe == NULL)
		{
		QTextStream(stderr, QIODevice::WriteOnly) << "Could not load .exe " << lpFileName << "\n";
		return 0;
		}
	return hExe;
}

// ----------------------------------------------------------------------------------
bool removeResource(QString executablePath, QString resourceType, QString resourceName)
{
  char* exePath = (char*) malloc(executablePath.size() + 1);
    strcpy(exePath, executablePath.toLatin1().constData());
	// Start Update
	HANDLE hUpdateRes = BeginUpdateResource(TEXT(exePath), FALSE);
	if (hUpdateRes == NULL)
		{
		QTextStream(stderr, QIODevice::WriteOnly) << "Could not open file for writing.\n";
		return false;
		}

	int type = resourceType.toInt();

	// Suppr Resource
	bool result = false;
	if (resourceName.toInt() == 0)
		{
    char* name = (char*) malloc(resourceName.size() + 1);
    strcpy(name, resourceName.toLatin1().constData());
		qDebug() << "not int :" << resourceName << resourceType << name;
		result = UpdateResource(hUpdateRes, MAKEINTRESOURCE(type), name, MAKELANGID(LANG_ENGLISH, SUBLANG_ENGLISH_US), NULL, 0);
		}
	else
		{
		int nameID = resourceName.toInt();
		qDebug() << "int :" << resourceName << resourceType << nameID;
		result = UpdateResource(hUpdateRes, MAKEINTRESOURCE(type), MAKEINTRESOURCE(nameID), MAKELANGID(LANG_ENGLISH, SUBLANG_ENGLISH_US), NULL, 0);
		}
	if(!result)
		{
		QTextStream(stderr, QIODevice::WriteOnly) << "Resource could not be deleted \n";
		return false;
		}

	// Write changes to .EXE and then close it.
	if (!EndUpdateResource(hUpdateRes, FALSE))
		{
		QTextStream(stderr, QIODevice::WriteOnly) << "Could not write changes to file.\n";
		return false;
		}

	return true;
}

// ----------------------------------------------------------------------------------
bool addResourceBITMAP(QString executablePath, QString resourceName, QString resourcePath)
{
	// Load file
	// Get the bmp into memory
  char* resPath = (char*) malloc(resourcePath.size() + 1);
  strcpy(resPath, resourcePath.toLatin1().constData());
	//HANDLE hIcon = LoadImage(NULL, TEXT(resPath), IMAGE_ICON, 0, 0, LR_LOADFROMFILE|LR_DEFAULTSIZE);
	//LPVOID lpResLock = LockResource(hIcon);

	HANDLE hFile = CreateFile(resPath, GENERIC_READ, 0, NULL,
									  OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if(hFile == NULL)
		{
		QTextStream(stderr, QIODevice::WriteOnly) << "Could not load ico file.\n";
		return false;
		}

	DWORD FileSize = GetFileSize(hFile, NULL);

	//reading image into global memory.
	BYTE* pBuffer = new BYTE[FileSize];
	DWORD nRead = 0;
	ReadFile(hFile, pBuffer, FileSize, &nRead, NULL);

	qDebug() << "Resource: " << FileSize << hFile;

	// just skipping the header information and  calculating modifying size.
	BYTE *newBuffer   = pBuffer  + sizeof(BITMAPFILEHEADER);
	DWORD NewFileSize = FileSize - sizeof(BITMAPFILEHEADER);

	// Write in the new resources
  char* exePath = (char*) malloc(executablePath.size() + 1);
  strcpy(exePath, executablePath.toLatin1().constData());
	// Start Update
	HANDLE hUpdateRes = BeginUpdateResource(TEXT(exePath), FALSE);
	if (hUpdateRes == NULL)
		{
    QTextStream(stderr, QIODevice::WriteOnly) << "Could not open file for writing.\n";
    return false;
		}

	qDebug() << "name" << resourceName.toLatin1();
	qDebug() << "path " << resourcePath;
	// update resouce.
	bool result = UpdateResource(hUpdateRes,
										RT_ICON,
                    TEXT(resourceName.toLatin1().constData()),
										MAKELANGID(LANG_ENGLISH, SUBLANG_ENGLISH_US),
										(LPVOID)newBuffer, NewFileSize);
	if(!result)
		{
		QTextStream(stderr, QIODevice::WriteOnly) << "Resource Could not be added.\n";
		return false;
		}

	if(!EndUpdateResource(hUpdateRes, FALSE))
		{
		QTextStream(stderr, QIODevice::WriteOnly) << "Could not write changes to file.\n";
		return false;
		}

	// release handle and memory.
  CloseHandle(hFile);
	delete[] pBuffer;
	return true;
}

// ----------------------------------------------------------------------------------
bool updateResourceICO(QString executablePath, QString resourceName, QString resourcePath)
{
  char* resPath = (char*) malloc(resourcePath.size() + 1);
  strcpy(resPath, resourcePath.toLatin1().constData());
	// read ico file
	icons::LPICONDIR iconDir;
	iconDir = new icons::ICONDIR;
	icons::LPICONIMAGE* iconsImage = icons::ExtractIcoFromFile(resPath, iconDir);

	// Resource name
  char* resName = (char*) malloc(resourceName.size() + 1);
  strcpy(resName, resourceName.toLatin1().constData());

	// Write in the new resources
  char* exePath = (char*) malloc(executablePath.size() + 1);
  strcpy(exePath, executablePath.toLatin1().constData());
	// Start Update
	bool result = ReplaceIconResource(exePath,
											TEXT(resName),
											MAKELANGID(LANG_ENGLISH, SUBLANG_ENGLISH_US),
											iconDir,
											iconsImage);
	return result;
}
