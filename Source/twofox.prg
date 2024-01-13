*========================================================================================
* Version history:
*
* 2007-02Feb-19: Implemented EncodeMemo and DecodeMemo to deal with extended properties
*                in VFP 9
*
* 2007-06Jun-21: Fixed the problem with report files and label files
*                Fixed an issue with extended properties in forms
*                Output in classes is now sorted to retain a constant order when
*                comparing files
*                Fixed an issue with forms that only have a single method
*
* 2007-08Aug-08: Fixed an issue with corrupt VCX files
*
* 2008-09Sep-30: Fixed the problem with ZOrder changes when generating code. Added
*                the SORT_METHODS switch below to reverse to the old behavior.
*                Fixed the problem with CDATA sections in converted source code
*                Fixed the issue of binary data in methods
*
* 2009-07Jul-14: Refactoring to minimize code duplication
*                Added support for MNX files
*                Removed the confirmation dialog in GenCode
*
* Acknowledgements:
*
* Many thanks to (in no particular order)
*
*  - Ulli Gellesch
*  - John Beard
*  - Larry Bradley
*  - Jorge Mota
*  - Matthew Osborn
*  - Peter Steinke 
*  - Toni Feltman
*  - Steve Sawyer
*  - Bogdan Zamfir
*  - Alan Stevens
* 
* for finding bugs, offering solutions, and making suggestions.
*========================================================================================


*========================================================================================
* Some global switches
*========================================================================================

	*------------------------------------------------------------------
	* Uncomment this setting, if you want all elements to be sorted
	* alphabetically. The drawback is that in this case you cannot use
	* SendToBack anymore. On the positive side you never get any false
	* positives when VFP rearranges classes.
	*------------------------------------------------------------------
	*#DEFINE SORT_METHODS


*========================================================================================
* Generic Merging class
*========================================================================================
Define Class CMerge as Session
	
	DataSession = 2
	
	Procedure Convert(tcFile)
	EndProc
	
	Procedure Init
		Set Deleted on
	EndProc 
	
	Procedure Msg(tcText)
		Wait WINDOW nowait m.tcText
	EndProc 
	
*========================================================================================
* Creates a backup of the existing file
*========================================================================================
Procedure BackupExisting
Lparameters tcFile
	
	Local lcNew
	If File(m.tcFile)
		lcNew = Addbs(JustPath(m.tcFile))+".##"+TtoC(Datetime(),1)+"."+JustFname(m.tcFile)
		Rename (m.tcFile) to (m.lcNew)
	EndIf
	
EndProc 

*========================================================================================
* Replaces binary characters 
*========================================================================================
Procedure DecodeMemo( tcMemo )
	
	Local lcMemo, lnCode
	lcMemo = m.tcMemo
	
	For m.lnCode=0 to 27
		lcMemo = Strtran(m.lcMemo,"{"+Transform(m.lnCode)+"}",Chr(m.lnCode))
	EndFor
	lcMemo = Strtran(m.lcMemo,"{33}","!")
	lcMemo = Strtran(m.lcMemo,"{93}","]")

	If "{123}" $ m.lcMemo
		lcMemo = Strtran(m.lcMemo,"{123}","{")
	EndIf 

Return m.lcMemo

EndDefine


*========================================================================================
* Handles VCX classes
*========================================================================================
Define Class CMergeVCX as CMerge

	cFile = ""

*========================================================================================
* Creates a class library from a set of XML files.
*========================================================================================
Procedure Convert
LParameter tcFile
	This.cFile = m.tcFile
	If File(This.cFile+".xml")
		This.BackupExisting( This.cFile )
		This.BackupExisting( ForceExt(This.cFile,"vct") )
		Create Classlib (This.cFile)
		USE (This.cFile) Alias VCX Shared In Select("VCX")
		This.LoadHeader()
		Select ClassList
		Scan
			This.LoadClass( Alltrim(ClassList.ObjName) )
		EndScan 
		USE in Select("VCX")
		USE in Select("ClassList")
		USE in Select("Class")
		Compile CLASSLIB (This.cFile)
	EndIf 
EndProc


*========================================================================================
* Loads the XML file that lists all classes
*========================================================================================
Procedure LoadHeader
	This.Msg( JustFname(This.cFile) )
	XMLToCursor( This.cFile+".xml", "ClassList", 512 )
EndProc


*========================================================================================
* Inserts a class from an XML file
*
* Use a SCAN loop with a temporary index here, because one version of TwoFox might have
* created an XML file where records are in the wrong order.
*========================================================================================
Procedure LoadClass
LParameter tcClass
	Local loRecord
	This.Msg( JustFname(This.cFile)+"."+m.tcClass )
	USE in Select("Class")
	XMLToCursor( FileToStr(This.cFile+"."+m.tcClass+".xml"), "Class" )
	Select Class
	Replace all Properties with ;
		This.DecodeMemo(Strtran(Properties,Chr(10),Chr(13)+Chr(10)))
	Replace all Protected with Strtran(Protected,Chr(10),Chr(13)+Chr(10))
	Replace all Methods with This.DecodeMemo(Strtran(Methods,Chr(10),Chr(13)+Chr(10)))
	Replace all Reserved3 with Strtran(Reserved3,Chr(10),Chr(13)+Chr(10))
	#IFDEF SORT_METHODS
		Index on ;
			Iif(Platform=="WINDOWS ","1","2") + ;
			Padr(Padr(Parent,50)+padr(Sys(2007,Parent),10) + ;
			Padr(ObjName,50)+Padr(Sys(2007,ObjName),10),120) ;
		Tag _Fixed
	#ENDIF
	Scan 
		Scatter name loRecord Memo 
		Select VCX
		Append Blank
		Gather name loRecord Memo
	EndScan
EndProc

EndDefine 


*========================================================================================
* Handles SCX forms
*========================================================================================
Define Class CMergeSCX as CMerge

	cFile = ""

*========================================================================================
* Creates a form from an XML files.
*========================================================================================
Procedure Convert
LParameter tcFile
	This.cFile = m.tcFile
	If File(This.cFile+".xml")
		This.BackupExisting( This.cFile )
		This.BackupExisting( ForceExt(This.cFile,"sct") )
		This.LoadForm()
		Compile Form (This.cFile)
	EndIf 
EndProc


*========================================================================================
* Inserts a class from an XML file
*========================================================================================
Procedure LoadForm
LParameter tcClass
	This.Msg( JustFname(This.cFile) )
	XMLToCursor( FileToStr(This.cFile+".xml"), "Form" )
	Select Form
	Replace all Properties with ;
		This.DecodeMemo(Strtran(Properties,Chr(10),Chr(13)+Chr(10)))
	Replace all Protected with Strtran(Protected,Chr(10),Chr(13)+Chr(10))
	Replace all Methods with This.DecodeMemo(Strtran(Methods,Chr(10),Chr(13)+Chr(10)))
	Replace all Reserved3 with Strtran(Reserved3,Chr(10),Chr(13)+Chr(10))
	Copy To (This.cFile)
EndProc

EndDefine 



*========================================================================================
* Handles Projects
*========================================================================================
Define Class CMergePJX as CMerge

	cFile = ""

*========================================================================================
* Creates a project from an XML files.
*========================================================================================
Procedure Convert
LParameter tcFile
	This.cFile = m.tcFile
	If File(This.cFile)
		This.BackupExisting( ForceExt(This.cFile,"pjx") )
		This.BackupExisting( ForceExt(This.cFile,"pjt") )
		This.LoadProject()
	EndIf 
EndProc


*========================================================================================
* Recreates the project file from the XML string 
*========================================================================================
Procedure LoadProject
LParameter tcClass
	Set Safety off
	This.Msg( JustFname(This.cFile) )
	XMLToCursor( FileToStr(This.cFile), "curProject" )
	StrToFile("*","x.prg")
	Build Project (ForceExt(This.cFile,"pjx")) from x.prg
	Erase x.prg
	Use (ForceExt(This.cFile,"pjx")) Alias Project Exclusive In Select("Project")
	Select Project
	Zap
	Append From Dbf("curProject")
	Use in Select("curProject")
	Use in Select("Project")
ENDPROC



EndDefine 


*========================================================================================
* Handles FRX forms
*========================================================================================
Define Class CMergeFRX as CMerge

	cFile = ""

*========================================================================================
* Creates a form from an XML files.
*========================================================================================
Procedure Convert
LParameter tcFile
	This.cFile = m.tcFile
	If File(This.cFile+".xml")
		This.BackupExisting( This.cFile )
		This.BackupExisting( ForceExt(This.cFile,"frt") )
		This.LoadReport()
		Compile Report (This.cFile)
	EndIf 
EndProc


*========================================================================================
* Inserts a class from an XML file
*========================================================================================
Procedure LoadReport
LParameter tcClass
	This.Msg( JustFname(This.cFile) )
	XMLToCursor( FileToStr(This.cFile+".xml"), "Report" )
	SELECT Report
	Replace all Expr with Strtran(Expr,Chr(10),Chr(13)+Chr(10))  
	Select 0
	Create Cursor curDummy (cField C(10))
	Create Report (This.cFile) from Dbf("curDummy")
	Use in Select("curDummy")
	Use (This.cFile) Again Alias __reportnew Exclusive
	Zap
	Append From Dbf("Report")
	Use in ("Report")
	Use in ("__reportnew")
EndProc


EndDefine 


*========================================================================================
* Handles MNX menus
*========================================================================================
Define Class CMergeMNX as CMerge

	cFile = ""

*========================================================================================
* Creates a menu from an XML files.
*========================================================================================
Procedure Convert
LParameter tcFile
	This.cFile = m.tcFile
	If File(This.cFile+".xml")
		This.BackupExisting( This.cFile )
		This.BackupExisting( ForceExt(This.cFile,"mnt") )
		This.LoadMenu()
	EndIf 
EndProc


*========================================================================================
* Performs the actual conversion from an XML file into an MNX file
*========================================================================================
Procedure LoadMenu
	This.Msg( JustFname(This.cFile) )
	XMLToCursor( FileToStr(This.cFile+".xml"), "Menu" )
	Select Menu

	Replace all Mark with This.DecodeMemo(Mark)
	Replace all Procedure with This.DecodeMemo(Procedure)
	Replace all Prompt with This.DecodeMemo(Prompt)
	Replace all ItemNum with Padl(Alltrim(ItemNum),3)

	Alter Table Menu alter column Mark C(1)

	Copy To (This.cFile)
	Use in ("Menu")
EndProc


EndDefine 


*========================================================================================
* Generic Splitting class
*========================================================================================
Define Class CSplit as Session
	
	DataSession = 2
	
	Procedure Convert(tcFile)
	EndProc
	
	Procedure Init
		Set Deleted on
	EndProc 
	
	Procedure Msg(tcText)
		Wait WINDOW nowait m.tcText
	EndProc 
	
	*========================================================================================
	* Produces an XML file from an existing cursor.
	*========================================================================================
	Procedure CursorToXML
	Lparameters tcAlias, tcFile
		Local lcXML, lcOldContent
		CursorToXML( m.tcAlias, "lcXML", 1, 0+8, 0, "1", "", "" )
		lcXML = Strtran( m.lcXML, ;
			[<xsd:choice maxOccurs="unbounded">]+Chr(13)+Chr(10)+Replicate(Chr(9),5)+[<xsd:element name="class">], ;
			[<xsd:choice maxOccurs="unbounded">]+Chr(13)+Chr(10)+Replicate(Chr(9),5)+[<xsd:element name="class" minOccurs="0" maxOccurs="unbounded">] ;
		)
		If not [<xsd:anyAttribute namespace="http://www.w3.org/XML/1998/namespace" processContents="lax"/>] $ m.lcXML
			lcXML = Strtran( m.lcXML, ;
				[</xsd:choice>]+Chr(13)+Chr(10), ;
				[</xsd:choice>]+Chr(13)+Chr(10)+Replicate(Chr(9),4)+[<xsd:anyAttribute namespace="http://www.w3.org/XML/1998/namespace" processContents="lax"/>]+Chr(13)+Chr(10) ;
			)
		EndIf 
		If File(m.tcFile)
			lcOldContent = FileToStr(m.tcFile)
		Else
			m.lcOldContent = ""
		EndIf
		If not m.lcOldContent == m.lcXML
			StrToFile( m.lcXML, m.tcFile )
		EndIf 
	EndProc 

*========================================================================================
* Replaces binary characters 
*========================================================================================
Procedure EncodeMemo( tcMemo )
	
	Local lcMemo, lnCode
	lcMemo = m.tcMemo
	
	If "{" $ m.lcMemo
		lcMemo = Strtran(m.lcMemo,"{","{123}")
	EndIf 
	lcMemo = Strtran(m.lcMemo,Chr(13)+Chr(10),"{1310}")
	For m.lnCode=0 to 27
		IF m.lnCode != 9
			lcMemo = Strtran(m.lcMemo,Chr(m.lnCode),"{"+Transform(m.lnCode)+"}")
		ENDIF
	EndFor
	lcMemo = Strtran(m.lcMemo,"{1310}",Chr(13)+Chr(10))

	lcMemo = STRTRAN( m.lcMemo, "<![CDATA[>", "<{33}[CDATA[>" )
	lcMemo = STRTRAN( m.lcMemo, "]]>", "{93}{93}>" )

Return m.lcMemo

	
EndDefine



*========================================================================================
* Handles VCX classes
*========================================================================================
Define Class CSPlitVCX as CSplit

	cFile = ""

*========================================================================================
* Converts a class library into a set of XML file, one for the class library itself, and
* one for each class. The XML files are placed into the same directory as the class 
* library and only replaced if the contents has changed
*========================================================================================
Procedure Convert
LParameter tcFile
	This.cFile = m.tcFile
	If File(This.cFile)
		USE (This.cFile) Alias VCX Shared In Select("VCX")
		This.GenerateHeader()
		Select ClassList
		Scan
			This.GenerateClass( Alltrim(ClassList.ObjName) )
		EndScan 
		USE in Select("VCX")
		USE in Select("ClassList")
		USE in Select("Class")
	EndIf 
EndProc


*========================================================================================
* Creates an XML file with just the classes in a library
*========================================================================================
Procedure GenerateHeader
	This.Msg( JustFname(This.cFile) )
	Select Lower(PadR(ObjName,128)) as ObjName ;
		from VCX ;
		Where Empty(Parent) ;
		  and Platform == "WINDOWS" ;
		  and Reserved1 == "Class" ;
		order by 1 ;
		into TABLE 'c:\temp\twofox\ClassList'
		
		SELECT classlist
		GO TOP 
		
	This.CursorToXML( "ClassList", This.cFile+".xml" )
EndProc


*========================================================================================
* Produces an XML file for a single class
*========================================================================================
Procedure GenerateClass
LParameter tcClass

	This.Msg( JustFname(This.cFile)+"."+m.tcClass )
	Local lnStart, lnEnd
	Select VCX
	Locate for objname == m.tcClass ;
		and Empty(Parent) ;
		and Platform == "WINDOWS " ; 
		and Reserved1 == "Class"
	lnStart = Recno()
	lnEnd = Recno() + Val(Reserved2)
	USE in Select("Class")
	
	Select * ;
		From VCX ;
		Where Recno()	Between m.lnStart and m.lnEnd ;
		Nofilter ;
		ReadWrite ;
		into TABLE 'c:\temp\twofox\Class'
	
	SELECT class
	GO BOTTOM 
	GO TOP 
	
	
	Alter Table Class Drop Column TimeStamp
	Alter Table Class Drop Column ObjCode
	Alter Table Class alter column OLE M NoCPTrans
	Go Bottom
	Blank FIELDS Reserved1    && time stamp of all include files
	Blank FIELDS properties   && Class designer settings: grid spacing, font size
	Scan for not Empty(Methods)
		Replace Methods with This.SortMethod("ENDPROC"+Chr(13)+Chr(10)+Methods+Chr(13)+Chr(10)+"ENDPROC")
	EndScan 
	Scan for not Empty(Properties)
		Replace Properties with This.EncodeMemo(Properties)
	EndScan 
	Replace all Methods with This.EncodeMemo(Methods)
		
	#IFDEF SORT_METHODS
		Index on ;
			Iif(Platform=="WINDOWS ","1","2") + ;
			Padr(Padr(Parent,50)+padr(Sys(2007,Parent),10) + ;
			Padr(ObjName,50)+Padr(Sys(2007,ObjName),10),120) ;
		Tag _Fixed
	#ENDIF
	
	This.CursorToXML( "Class", This.cFile+"."+m.tcClass+".xml" )

EndProc


*========================================================================================
* Sorts all procedures in a method
*========================================================================================
Function SortMethod
Lparameter tcMethod
	Local laCode[1], lcMethod, lcSorted, lnMethod, lnCount, lcSep
	lcSep =Chr(13)+Chr(10)
	lcSorted = ""
	lnCount = Occurs("ENDPROC"+lcSep,m.tcMethod)-1
	If lnCount=0
		lnCount = Occurs("ENDPROC",m.tcMethod)-1
		lcSep = []
	Endif
	Dimension laCode[m.lnCount]
	For lnMethod = 1 To m.lnCount
		laCode[m.lnMethod] = Strextract( ;
			M.tcMethod, ;
			"ENDPROC"+lcSep, ;
			"ENDPROC"+lcSep, ;
			M.lnMethod )
		laCode[m.lnMethod] = laCode[m.lnMethod] + "ENDPROC"+Chr(13)+Chr(10)
	Endfor
	Asort( laCode, -1, -1, 0, 1 )
	For Each lcMethod In laCode
		lcSorted = m.lcSorted + m.lcMethod
	Endfor
Return m.lcSorted


EndDefine 



*========================================================================================
* Handles SCX classes
*========================================================================================
Define Class CSPlitSCX as CSplit

	cFile = ""

*========================================================================================
* Converts a class library into a set of XML file, one for the class library itself, and
* one for each class. The XML files are placed into the same directory as the class 
* library and only replaced if the contents has changed
*========================================================================================
Procedure Convert
LParameter tcFile
	This.cFile = m.tcFile
	If File(This.cFile)
		This.GenerateForm()
	EndIf 
EndProc


*========================================================================================
* Produces an XML file for a single class
*========================================================================================
Procedure GenerateForm

	This.Msg( JustFname(This.cFile) )

	Select * from (This.cFile) into TABLE 'c:\temp\twofox\Form' Nofilter ReadWrite
	SELECT form
	GO BOTTOM 
	GO TOP 
	
	Blank All FIELDS ObjCOde		
	Blank all FIELDS TimeStamp
	Alter Table Form alter column OLE M NoCPTrans
	Go Bottom
	Blank FIELDS Reserved1    && time stamp of all include files
	Blank FIELDS properties   && Class designer settings: grid spacing, font size
	Scan for not Empty(Methods)
		Replace Methods with This.SortMethod("ENDPROC"+Chr(13)+Chr(10)+Methods)
	EndScan 
	Scan for not Empty(Properties)
		Replace Properties with This.EncodeMemo(Properties)
	EndScan 
	Replace all Methods with ;
		Chrtran(Methods,Chr(0)+Chr(1)+Chr(2)+Chr(3)+Chr(4)+Chr(5)+Chr(6),"")

	This.CursorToXML( "Form", This.cFile+".xml" )
	
	USE in Select("Form")

EndProc
 

*========================================================================================
* Sorts all procedures in a method
*========================================================================================
Function SortMethod
Lparameter tcMethod
	Local laCode[1], lcMethod, lcSorted, lnMethod, lnCount, lcSep
	lcSep =Chr(13)+Chr(10)
	lcSorted = ""
	lnCount = Occurs("ENDPROC"+lcSep,m.tcMethod)-1
	If lnCount=0
		lnCount = Occurs("ENDPROC",m.tcMethod)-1
		lcSep = []
	Endif
	Dimension laCode[m.lnCount]
	For lnMethod = 1 To m.lnCount
		laCode[m.lnMethod] = Strextract( ;
			M.tcMethod, ;
			"ENDPROC"+lcSep, ;
			"ENDPROC"+lcSep, ;
			M.lnMethod )
		laCode[m.lnMethod] = laCode[m.lnMethod] + "ENDPROC"+Chr(13)+Chr(10)
	Endfor
	Asort( laCode, -1, -1, 0, 1 )
	For Each lcMethod In laCode
		lcSorted = m.lcSorted + m.lcMethod
	Endfor
Return m.lcSorted

EndDefine 


*========================================================================================
* Handles PJX files
*========================================================================================
Define Class CSPlitPJX as CSplit

	cFile = ""

*========================================================================================
* Converts a class library into a set of XML file, one for the class library itself, and
* one for each class. The XML files are placed into the same directory as the class 
* library and only replaced if the contents has changed
*========================================================================================
Procedure Convert
LParameter tcFile
	This.cFile = m.tcFile
	If File(This.cFile)
		This.GenerateProject()
	EndIf 
EndProc


*========================================================================================
* Produces an XML file for a single class
*========================================================================================
Procedure GenerateProject

	This.Msg( JustFname(This.cFile) )

	Select * from (This.cFile) into TABLE 'c:\temp\twofox\Project' Nofilter ReadWrite
	
	SELECT project
	GO BOTTOM 
	GO TOP 
	
	Alter Table Project Drop Column TimeStamp
	Alter Table Project Drop Column Symbols
	Blank FIELDS DevInfo for Recno()>1
	Blank FIELDS Object for Recno()>1
	Alter Table Project alter column SCCData M NoCPTrans
	Alter Table Project alter column DevInfo M NoCPTrans

	Replace all Name with Chrtran(Name,Chr(0),"")
	Replace all Comments with Chrtran(Comments,Chr(0),"")
	Replace all Outfile with Chrtran(Outfile,Chr(0),"")
	Replace all Reserved1 with Chrtran(Reserved1,Chr(0),"")
	Replace all HomeDir with Chrtran(HomeDir,Chr(0),"")
	Replace Outfile with Chrtran(outfile,Chr(0),"") for Recno()==1
	Replace Object with Chrtran(Object,Chr(0),"") for Recno()==1

	This.CursorToXML( "Project", ForceExt(This.cFile,"twofox") )
	
	USE in Select("Project")

EndProc

	
EndDefine 


*========================================================================================
* Handles FRX classes
*========================================================================================
Define Class CSPlitFRX as CSplit

	cFile = ""

*========================================================================================
* Converts a class library into a set of XML file, one for the class library itself, and
* one for each class. The XML files are placed into the same directory as the class 
* library and only replaced if the contents has changed
*========================================================================================
Procedure Convert
LParameter tcFile
	This.cFile = m.tcFile
	If File(This.cFile)
		This.GenerateReport()
	EndIf 
EndProc


*========================================================================================
* Produces an XML file for a single report
*========================================================================================
Procedure GenerateReport

	This.Msg( JustFname(This.cFile) )

	Select * from (This.cFile) into TABLE 'c:\temp\twofox\Report' Nofilter ReadWrite
	SELECT report
	GO BOTTOM 
	GO TOP 
	
	Blank FIELDS Tag, Tag2 for Recno() == 1
	Blank FIELDS Tag2 for InList(OBJTYPE,25,26)
	Replace all Expr with Chrtran(Expr,Chr(0),"")
	
	This.CursorToXML( "Report", This.cFile+".xml" )
	USE in Select("Report")

EndProc
 
	
EndDefine 


*========================================================================================
* Handles menu files (MNX)
*========================================================================================
Define Class CSPlitMNX as CSplit

	cFile = ""

*========================================================================================
* Converts an MNX file into a single XML file
*========================================================================================
Procedure Convert
LParameter tcFile
	This.cFile = m.tcFile
	If File(This.cFile)
		This.GenerateMenu()
	EndIf 
EndProc


*========================================================================================
* Produces an XML file for the menu
*========================================================================================
Procedure GenerateMenu

	This.Msg( JustFname(This.cFile) )

	Select * from (This.cFile) into TABLE 'c:\temp\twofox\Menu' Nofilter ReadWrite

	SELECT menu
	GO BOTTOM 
	GO TOP 
	
	Alter Table Menu alter column Mark C(5)
	
	Replace all Mark with This.EncodeMemo(Mark)
	Replace all Procedure with This.EncodeMemo(Procedure)
	Replace all Prompt with This.EncodeMemo(Prompt)
	
	This.CursorToXML( "Menu", This.cFile+".xml" )
	USE in Select("Menu")

EndProc

	
EndDefine 


*========================================================================================
* Performs a conversion of a FoxPro file. 
*========================================================================================
Define Class CConverter as Custom

	cHomeDir = ""
	oFactory = NULL

*========================================================================================
* A factory is injected here that defines what kind of conversion is performed
*========================================================================================
Procedure Init( toFactory )

	*--------------------------------------------------------------------------------------
	* Assertions
	*--------------------------------------------------------------------------------------
	Assert Vartype(m.toFactory) == "O"
	
	*--------------------------------------------------------------------------------------
	* Save dependencies
	*--------------------------------------------------------------------------------------
	This.oFactory = m.toFactory

EndProc

*========================================================================================
* If no file type is specified, the file extension determines the type.
*========================================================================================
Procedure Convert( tcFileName, tcType )

	*--------------------------------------------------------------------------------------
	* Assertions
	*--------------------------------------------------------------------------------------
	Assert Vartype(m.tcFileName) == "C"
	Assert Vartype(m.tcType) $ "CL"
	
	*--------------------------------------------------------------------------------------
	* Determine the file type
	*--------------------------------------------------------------------------------------
	Local lcType
	If Vartype(m.tcType) == "C"
		lcType = Lower(Alltrim(m.tcType))
	Else 
		lcType = This.InferType(m.tcFileName)
	EndIf
	
	*--------------------------------------------------------------------------------------
	* Convert the file based on the type
	*--------------------------------------------------------------------------------------
	Local loConverter, lcFileName
	loConverter = This.oFactory.GetObject(m.lcType)
	lcFileName = This.GetName(m.tcFileName)
	loConverter.Convert( m.lcFileName )
	
EndProc

*========================================================================================
* Infers the type of a file from its file extension
*========================================================================================
Procedure InferType( tcFileName)

	Local lcExtension, lcType
	lcExtension = JustExt(Lower(m.tcFileName))
	
	Do case
	Case m.lcExtension == "scx"
		lcType = "scx"
	Case m.lcExtension == "vcx"
		lcType = "vcx"
	Case m.lcExtension == "frx"
		lcType = "frx"
	Case m.lcExtension == "lbx"
		lcType = "frx"
	Case m.lcExtension == "mnx"
		lcType = "mnx"
	Case m.lcExtension == "pjx"
		lcType = "pjx"
	Otherwise
		lcType = ""
	EndCase
	
Return m.lcType

*========================================================================================
* Returns the full path to the file. Adds the home directory if required.
*========================================================================================
Procedure GetName( tcFileName )

	Local lcFileName
	lcFileName = m.tcFileName
	If not ":" $ m.tcFileName and not "\\" $ m.tcFileName
		lcFileName = Addbs(This.cHomeDir) + m.tcFileName
	EndIf

Return m.lcFileName

EndDefine 


*========================================================================================
* This factory class returns a CSplit object based on the type
*========================================================================================
Define Class CSplitFactory as Custom

Procedure GetObject( tcType )
	Local loSplit
	DO case
	Case m.tcType == "vcx"
		loSplit = NewObject("CSPlitVCX", This.ClassLibrary)
	Case m.tcType == "scx"
		loSplit = NewObject("CSPlitSCX", This.ClassLibrary)
	Case m.tcType == "frx"
		loSplit = NewObject("CSPlitFRX", This.ClassLibrary)
	Case m.tcType == "mnx"
		loSplit = NewObject("CSPlitMNX", This.ClassLibrary)
	Otherwise 
		loSplit = NULL
	EndCase 
Return m.loSplit

EndDefine 


*========================================================================================
* This factory class returns a CMerge object based on the type
*========================================================================================
Define Class CMergeFactory as Custom

Procedure GetObject( tcType )
	Local loSplit
	DO case
	Case m.tcType == "vcx"
		loSplit = NewObject("CMergeVCX", This.ClassLibrary)
	Case m.tcType == "scx"
		loSplit = NewObject("CMergeSCX", This.ClassLibrary)
	Case m.tcType == "frx"
		loSplit = NewObject("CMergeFRX", This.ClassLibrary)
	Case m.tcType == "mnx"
		loSplit = NewObject("CMergeMNX", This.ClassLibrary)
	Otherwise 
		loSplit = NULL
	EndCase 
Return m.loSplit

EndDefine 
