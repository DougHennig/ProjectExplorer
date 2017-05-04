*******************************************************************************
define class ProjectExplorerTests as FxuTestCase of FxuTestCase.prg
*******************************************************************************
	#IF .f.
	LOCAL THIS AS ProjectExplorerTests OF ProjectExplorerTests.PRG
	#ENDIF
	
	cTestFolder     = ''
	cTestDataFolder = ''
	cTestProgram    = ''
	cCurrPath       = ''
	icTestPrefix    = 'Test_'
	oExplorer       = .NULL.
	cProject        = ''
	
*******************************************************************************
* Setup for the tests
*******************************************************************************
	function Setup
		local lcProgram

* Save the path and add the Project Explorer source folder to it.

		This.cCurrPath = set('PATH')
		set path to 'Source' additive

* Get the folder the tests are running from, the name of this test
* program, and create a test data folder if necessary.

		lcProgram            = sys(16)
		This.cTestProgram    = substr(lcProgram, at(' ', lcProgram, 2) + 1)
		This.cTestFolder     = addbs(justpath(This.cTestProgram))
		This.cTestDataFolder = This.cTestFolder + 'TestData\'
		if not directory(This.cTestDataFolder)
			md (This.cTestDataFolder)
		endif not directory(This.cTestDataFolder)

* Set up other things.

		This.cProject  = This.cTestDataFolder + sys(2015) + '.pjx'
		This.oExplorer = This.SetupExplorer()

* Create a public variable the projecthook class at the end of this code can
* write to.

		public pcFileName
		pcFileName = ''
	endfunc
	
*******************************************************************************
* Clean up on exit.
*******************************************************************************
	function TearDown
		This.oExplorer.Release()
		close databases all
		lnFiles = adir(laFiles, This.cTestDataFolder + '*.*')
		for lnI = 1 to lnFiles
			erase (This.cTestDataFolder + laFiles[lnI, 1])
		next lnI
		try
			loFSO = createobject('Scripting.FileSystemObject')
			loFSO.DeleteFolder(This.cTestDataFolder + '.hg')
		catch
		endtry
		set path to (This.cCurrPath)
	endfunc

*******************************************************************************
* Helper method to set up Project Explorer
*******************************************************************************
	function SetupExplorer()

* Start by creating a project.

		create project (This.cProject) nowait noshow

* Copy the test files and add them to the project.

		lnFiles = adir(laFiles, This.cTestFolder + 'TestSourceFiles\*.*')
		for lnI = 1 to lnFiles
			lcFile   = laFiles[lnI, 1]
			lcTarget = This.cTestDataFolder + lcFile
			copy file (This.cTestFolder + 'TestSourceFiles\' + lcFile) to ;
				(lcTarget)
		next lnI
		for lnI = 1 to lnFiles
			lcFile = lower(laFiles[lnI, 1])
			if not inlist(lower(justext(lcFile)), 'pjt', 'vct', 'sct', 'mnt', ;
				'frt', 'lbt', 'cdx', 'fpt', 'dcx', 'dct')
				loFile = _vfp.ActiveProject.Files.Add(This.cTestDataFolder + lcFile)
				if lcFile = 'system.exe'
					loFile.Type = 'Z'
				endif lcFile = 'system.exe'
			endif not inlist(lower(justext(lcFile)) ...
		next lnI

* Open the project in Project Explorer.

		loExplorer = newobject('ProjectExplorerForm', ;
			'ProjectExplorerUI.vcx', '', This.cProject)
		loExplorer.oTreeViewContainer.lAutoLoadChildren = .T.
		return loExplorer
	endfunc

*******************************************************************************
* Helper method to select the specified item
*******************************************************************************
	function SelectItem(tcFile, tcType)
		lcExt  = lower(justext(tcFile))
		lcType = evl(tcType, '')
		lcFile = tcFile
		do case
			case lcType = 'Class'
				lcTag  = 'Classes'
				lcFile = 'classlib.vcx'
			case inlist(lcType, 'Field', 'Index') and lcFile = 'freetable'
				lcTag  = 'Data'
				lcFile = 'freetable.dbf'
			case inlist(lcType, 't', 'c', 'l', 'r', 'p', 'Field', 'Index')
				lcTag  = 'Data'
				lcFile = 'data.dbc'
			case lcExt = 'vcx'
				lcTag  = 'Classes'
				lcType = 'V'
			case lcExt = 'scx'
				lcTag  = 'Documents'
				lcType = 'K'
			case lcExt = 'lbx'
				lcTag  = 'Documents'
				lcType = 'B'
			case lcExt = 'frx'
				lcTag  = 'Documents'
				lcType = 'R'
			case lcExt = 'mnx'
				lcTag  = 'Other'
				lcType = 'M'
			case lcExt = 'xxx'
				lcTag  = 'Other'
				lcType = 'x'
			case lcExt = 'bmp'
				lcTag  = 'Other'
				lcType = 'x'
			case lcExt = 'txt'
				lcTag  = 'Other'
				lcType = 'T'
			case lcExt = 'dbf'
				lcTag  = 'Data'
				lcType = 'D'
			case lcExt = 'dbc'
				lcTag  = 'Data'
				lcType = 'd'
			case lcExt = 'qpr'
				lcTag  = 'Data'
				lcType = 'Q'
			case lcExt = 'prg'
				lcTag  = 'Code'
				lcType = 'P'
			case lcExt = 'fll'
				lcTag  = 'Code'
				lcType = 'L'
			case lcExt = 'exe'
				lcTag  = 'Code'
				lcType = 'Z'
		endcase
		This.oExplorer.cFilterTags = lcTag
		This.oExplorer.LoadSolution()
		loItem = This.oExplorer.oProject.GetItemForFile(This.cTestDataFolder + ;
			lcFile)
		do case
			case inlist(lcType, 'Class', 'c', 'l', 'r', 'p')
				lcKey = This.oExplorer.GetNodeKey(loItem) + '~' + lower(tcFile)
			case inlist(lcType, 'Field', 'Index') and lcFile = 'freetable'
				lcKey = strtran(This.oExplorer.GetNodeKey(loItem), '.pjx', ;
					'.pjx~' + lcType) + '~' + lower(justext(tcFile))
			case inlist(lcType, 'Field', 'Index')
				lcKey = strtran(This.oExplorer.GetNodeKey(loItem), '.pjx', ;
					'.pjx~' + lcType) + '~' + lower(tcFile)
			case lcType = 't'
				lcKey = This.oExplorer.GetNodeKey(loItem) + '~' + ;
					lower(juststem(tcFile))
			otherwise
				lcKey = This.oExplorer.GetNodeKey(loItem)
		endcase
		lcKey = This.oExplorer.oTreeViewContainer.GetNodeKey(lcType, lcKey)
		This.oExplorer.oTreeViewContainer.SelectNode(lcKey)
	endfunc

*******************************************************************************
* Helper method to get the item for the selected node
*******************************************************************************
	function GetItemForNode()
		lcKey  = This.oExplorer.oTreeViewContainer.oSelectedNode.Key
		lcKey  = substr(lcKey, at('~', lcKey) + 1)
		loItem = This.oExplorer.GetItemForNode(lcKey)
		return loItem
	endfunc

*******************************************************************************
* Test that the edit button is disabled for an application
*******************************************************************************
	function Test_Edit_Application_Disabled
		This.SelectItem('system.exe')
		This.AssertFalse(This.oExplorer.oProjectToolbar.cmdEdit.Enabled, ;
			'cmdEdit enabled for application')
	endfunc

*******************************************************************************
* Test that the edit button is enabled for a class
*******************************************************************************
	function Test_Edit_Class_Enabled
		This.SelectItem('myclass', 'Class')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdEdit.Enabled, ;
			'cmdEdit disabled for class')
	endfunc

*******************************************************************************
* Test that the edit button is enabled for a classlib
*******************************************************************************
	function Test_Edit_Classlib_Enabled
		This.SelectItem('classlib.vcx')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdEdit.Enabled, ;
			'cmdEdit disabled for classlib')
	endfunc

*******************************************************************************
* Test that the edit button is enabled for a database
*******************************************************************************
	function Test_Edit_Database_Enabled
		This.SelectItem('data.dbc')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdEdit.Enabled, ;
			'cmdEdit disabled for database')
	endfunc

*******************************************************************************
* Test that the edit button is enabled for a form
*******************************************************************************
	function Test_Edit_Form_Enabled
		This.SelectItem('form.scx')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdEdit.Enabled, ;
			'cmdEdit disabled for database')
	endfunc

*******************************************************************************
* Test that the edit button is enabled for a free table
*******************************************************************************
	function Test_Edit_FreeTable_Enabled
		This.SelectItem('freetable.dbf')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdEdit.Enabled, ;
			'cmdEdit disabled for free table')
	endfunc

*******************************************************************************
* Test that the edit button is enabled for a label
*******************************************************************************
	function Test_Edit_Label_Enabled
		This.SelectItem('label.lbx')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdEdit.Enabled, ;
			'cmdEdit disabled for label')
	endfunc

*******************************************************************************
* Test that the edit button is disabled for a library
*******************************************************************************
	function Test_Edit_Library_Disabled
		This.SelectItem('vfpcompression.fll')
		This.AssertFalse(This.oExplorer.oProjectToolbar.cmdEdit.Enabled, ;
			'cmdEdit enabled for library')
	endfunc

*******************************************************************************
* Test that the edit button is enabled for a menu
*******************************************************************************
	function Test_Edit_Menu_Enabled
		This.SelectItem('menu.mnx')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdEdit.Enabled, ;
			'cmdEdit disabled for menu')
	endfunc

*******************************************************************************
* Test that the edit button is disabled for other files
*******************************************************************************
	function Test_Edit_Other_Disabled
		This.SelectItem('file.xxx')
		This.AssertFalse(This.oExplorer.oProjectToolbar.cmdEdit.Enabled, ;
			'cmdEdit enabled for other file')
	endfunc

*******************************************************************************
* Test that the edit button is enabled for images
*******************************************************************************
	function Test_Edit_Image_Enabled
		This.SelectItem('image.bmp')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdEdit.Enabled, ;
			'cmdEdit disabled for image')
	endfunc

*******************************************************************************
* Test that the edit button is enabled for programs
*******************************************************************************
	function Test_Edit_Program_Enabled
		This.SelectItem('program.prg')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdEdit.Enabled, ;
			'cmdEdit disabled for program')
	endfunc

*******************************************************************************
* Test that the edit button is enabled for queries
*******************************************************************************
	function Test_Edit_Query_Enabled
		This.SelectItem('query.qpr')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdEdit.Enabled, ;
			'cmdEdit disabled for queries')
	endfunc

*******************************************************************************
* Test that the edit button is enabled for reports
*******************************************************************************
	function Test_Edit_Report_Enabled
		This.SelectItem('report.frx')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdEdit.Enabled, ;
			'cmdEdit disabled for reports')
	endfunc

*******************************************************************************
* Test that the edit button is enabled for tables in a DBC
*******************************************************************************
	function Test_Edit_TableInDBC_Enabled
		This.SelectItem('table.dbf', 't')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdEdit.Enabled, ;
			'cmdEdit disabled for table in DBC')
	endfunc

*******************************************************************************
* Test that the edit button is enabled for text files
*******************************************************************************
	function Test_Edit_Text_Enabled
		This.SelectItem('text.txt')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdEdit.Enabled, ;
			'cmdEdit disabled for text files')
	endfunc

*******************************************************************************
* Test that the edit button is enabled for connections
*******************************************************************************
	function Test_Edit_Connection_Enabled
		This.SelectItem('connection', 'c')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdEdit.Enabled, ;
			'cmdEdit disabled for connections')
	endfunc

*******************************************************************************
* Test that the edit button is enabled for fields in a DBC table
*******************************************************************************
	function Test_Edit_FieldInDBCTable_Enabled
		This.SelectItem('table.field1', 'Field')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdEdit.Enabled, ;
			'cmdEdit disabled for field in DBC table')
	endfunc

*******************************************************************************
* Test that the edit button is enabled for fields in a view
*******************************************************************************
	function Test_Edit_FieldInView_Enabled
		This.SelectItem('view.field1', 'Field')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdEdit.Enabled, ;
			'cmdEdit disabled for field in view')
	endfunc

*******************************************************************************
* Test that the edit button is enabled for fields in a free table
*******************************************************************************
	function Test_Edit_FieldInFreeTable_Enabled
		This.SelectItem('freetable.field1', 'Field')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdEdit.Enabled, ;
			'cmdEdit disabled for field in free table')
	endfunc

*******************************************************************************
* Test that the edit button is enabled for indexes in a DBC table
*******************************************************************************
	function Test_Edit_IndexInDBCTable_Enabled
		This.SelectItem('table.field1', 'Index')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdEdit.Enabled, ;
			'cmdEdit disabled for index in DBC table')
	endfunc

*******************************************************************************
* Test that the edit button is enabled for index in a free table
*******************************************************************************
	function Test_Edit_IndexInFreeTable_Enabled
		This.SelectItem('freetable.field1', 'Index')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdEdit.Enabled, ;
			'cmdEdit disabled for field in index table')
	endfunc

*******************************************************************************
* Test that the edit button is enabled for local views
*******************************************************************************
	function Test_Edit_LocalView_Enabled
		This.SelectItem('view', 'l')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdEdit.Enabled, ;
			'cmdEdit disabled for local views')
	endfunc

*******************************************************************************
* Test that the edit button is enabled for remote views
*******************************************************************************
	function Test_Edit_RemoteView_Enabled
		This.SelectItem('RemoteView', 'r')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdEdit.Enabled, ;
			'cmdEdit disabled for remote views')
	endfunc

*******************************************************************************
* Test that the edit button is enabled for stored procs
*******************************************************************************
	function Test_Edit_StoredProc_Enabled
		This.SelectItem('MyProc', 'p')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdEdit.Enabled, ;
			'cmdEdit disabled for stored proc')
	endfunc

*******************************************************************************
* Test that the new button is disabled for an application
*******************************************************************************
	function Test_New_Application_Disabled
		This.SelectItem('system.exe')
		This.AssertFalse(This.oExplorer.oProjectToolbar.cmdNew.Enabled, ;
			'cmdNew enabled for application')
	endfunc

*******************************************************************************
* Test that the new button is enabled for a class
*******************************************************************************
	function Test_New_Class_Enabled
		This.SelectItem('myclass', 'Class')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdNew.Enabled, ;
			'cmdNew disabled for class')
	endfunc

*******************************************************************************
* Test that the new button is enabled for a classlib
*******************************************************************************
	function Test_New_Classlib_Enabled
		This.SelectItem('classlib.vcx')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdNew.Enabled, ;
			'cmdNew disabled for classlib')
	endfunc

*******************************************************************************
* Test that the new button is enabled for a database
*******************************************************************************
	function Test_New_Database_Enabled
		This.SelectItem('data.dbc')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdNew.Enabled, ;
			'cmdNew disabled for database')
	endfunc

*******************************************************************************
* Test that the new button is enabled for a form
*******************************************************************************
	function Test_New_Form_Enabled
		This.SelectItem('form.scx')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdNew.Enabled, ;
			'cmdNew disabled for database')
	endfunc

*******************************************************************************
* Test that the new button is enabled for a free table
*******************************************************************************
	function Test_New_FreeTable_Enabled
		This.SelectItem('freetable.dbf')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdNew.Enabled, ;
			'cmdNew disabled for free table')
	endfunc

*******************************************************************************
* Test that the new button is enabled for a label
*******************************************************************************
	function Test_New_Label_Enabled
		This.SelectItem('label.lbx')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdNew.Enabled, ;
			'cmdNew disabled for label')
	endfunc

*******************************************************************************
* Test that the new button is disabled for a library
*******************************************************************************
	function Test_New_Library_Disabled
		This.SelectItem('vfpcompression.fll')
		This.AssertFalse(This.oExplorer.oProjectToolbar.cmdNew.Enabled, ;
			'cmdNew enabled for library')
	endfunc

*******************************************************************************
* Test that the new button is enabled for a menu
*******************************************************************************
	function Test_New_Menu_Enabled
		This.SelectItem('menu.mnx')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdNew.Enabled, ;
			'cmdNew disabled for menu')
	endfunc

*******************************************************************************
* Test that the new button is disabled for other files
*******************************************************************************
	function Test_New_Other_Disabled
		This.SelectItem('file.xxx')
		This.AssertFalse(This.oExplorer.oProjectToolbar.cmdNew.Enabled, ;
			'cmdNew enabled for other file')
	endfunc

*******************************************************************************
* Test that the new button is disabled for images
*******************************************************************************
	function Test_New_Image_Disabled
		This.SelectItem('image.bmp')
		This.AssertFalse(This.oExplorer.oProjectToolbar.cmdNew.Enabled, ;
			'cmdNew enabled for image')
	endfunc

*******************************************************************************
* Test that the new button is enabled for programs
*******************************************************************************
	function Test_New_Program_Enabled
		This.SelectItem('program.prg')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdNew.Enabled, ;
			'cmdNew disabled for program')
	endfunc

*******************************************************************************
* Test that the new button is enabled for queries
*******************************************************************************
	function Test_New_Query_Enabled
		This.SelectItem('query.qpr')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdNew.Enabled, ;
			'cmdNew disabled for queries')
	endfunc

*******************************************************************************
* Test that the new button is enabled for reports
*******************************************************************************
	function Test_New_Report_Enabled
		This.SelectItem('report.frx')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdNew.Enabled, ;
			'cmdNew disabled for reports')
	endfunc

*******************************************************************************
* Test that the new button is enabled for tables in a DBC
*******************************************************************************
	function Test_New_TableInDBC_Enabled
		This.SelectItem('table.dbf', 't')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdNew.Enabled, ;
			'cmdNew disabled for table in DBC')
	endfunc

*******************************************************************************
* Test that the new button is enabled for text files
*******************************************************************************
	function Test_New_Text_Enabled
		This.SelectItem('text.txt')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdNew.Enabled, ;
			'cmdNew disabled for text files')
	endfunc

*******************************************************************************
* Test that the new button is enabled for connections
*******************************************************************************
	function Test_New_Connection_Enabled
		This.SelectItem('connection', 'c')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdNew.Enabled, ;
			'cmdNew disabled for connections')
	endfunc

*******************************************************************************
* Test that the new button is enabled for fields in a DBC table
*******************************************************************************
	function Test_New_FieldInDBCTable_Enabled
		This.SelectItem('table.field1', 'Field')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdNew.Enabled, ;
			'cmdNew disabled for field in DBC table')
	endfunc

*******************************************************************************
* Test that the new button is enabled for fields in a view
*******************************************************************************
	function Test_New_FieldInView_Enabled
		This.SelectItem('view.field1', 'Field')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdNew.Enabled, ;
			'cmdNew disabled for field in view')
	endfunc

*******************************************************************************
* Test that the new button is enabled for fields in a free table
*******************************************************************************
	function Test_New_FieldInFreeTable_Enabled
		This.SelectItem('freetable.field1', 'Field')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdNew.Enabled, ;
			'cmdNew disabled for field in free table')
	endfunc

*******************************************************************************
* Test that the new button is enabled for indexes in a DBC table
*******************************************************************************
	function Test_New_IndexInDBCTable_Enabled
		This.SelectItem('table.field1', 'Index')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdNew.Enabled, ;
			'cmdNew disabled for index in DBC table')
	endfunc

*******************************************************************************
* Test that the new button is enabled for index in a free table
*******************************************************************************
	function Test_New_IndexInFreeTable_Enabled
		This.SelectItem('freetable.field1', 'Index')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdNew.Enabled, ;
			'cmdNew disabled for field in index table')
	endfunc

*******************************************************************************
* Test that the new button is enabled for local views
*******************************************************************************
	function Test_New_LocalView_Enabled
		This.SelectItem('view', 'l')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdNew.Enabled, ;
			'cmdNew disabled for local views')
	endfunc

*******************************************************************************
* Test that the new button is enabled for remote views
*******************************************************************************
	function Test_New_RemoteView_Enabled
		This.SelectItem('RemoteView', 'r')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdNew.Enabled, ;
			'cmdNew disabled for remote views')
	endfunc

*******************************************************************************
* Test that the new button is enabled for stored procs
*******************************************************************************
	function Test_New_StoredProc_Enabled
		This.SelectItem('MyProc', 'p')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdNew.Enabled, ;
			'cmdNew disabled for stored proc')
	endfunc

*******************************************************************************
* Test that the add button is enabled for an application
*******************************************************************************
	function Test_Add_Application_Enabled
		This.SelectItem('system.exe')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdAdd.Enabled, ;
			'cmdAdd disabled for application')
	endfunc

*******************************************************************************
* Test that the Add button is disabled for a class
*******************************************************************************
	function Test_Add_Class_Disabled
		This.SelectItem('myclass', 'Class')
		This.AssertFalse(This.oExplorer.oProjectToolbar.cmdAdd.Enabled, ;
			'cmdAdd enabled for class')
	endfunc

*******************************************************************************
* Test that the Add button is enabled for a classlib
*******************************************************************************
	function Test_Add_Classlib_Enabled
		This.SelectItem('classlib.vcx')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdAdd.Enabled, ;
			'cmdAdd disabled for classlib')
	endfunc

*******************************************************************************
* Test that the Add button is enabled for a database
*******************************************************************************
	function Test_Add_Database_Enabled
		This.SelectItem('data.dbc')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdAdd.Enabled, ;
			'cmdAdd disabled for database')
	endfunc

*******************************************************************************
* Test that the Add button is enabled for a form
*******************************************************************************
	function Test_Add_Form_Enabled
		This.SelectItem('form.scx')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdAdd.Enabled, ;
			'cmdAdd disabled for database')
	endfunc

*******************************************************************************
* Test that the Add button is enabled for a free table
*******************************************************************************
	function Test_Add_FreeTable_Enabled
		This.SelectItem('freetable.dbf')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdAdd.Enabled, ;
			'cmdAdd disabled for free table')
	endfunc

*******************************************************************************
* Test that the Add button is enabled for a label
*******************************************************************************
	function Test_Add_Label_Enabled
		This.SelectItem('label.lbx')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdAdd.Enabled, ;
			'cmdAdd disabled for label')
	endfunc

*******************************************************************************
* Test that the Add button is enabled for a library
*******************************************************************************
	function Test_Add_Library_Enabled
		This.SelectItem('vfpcompression.fll')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdAdd.Enabled, ;
			'cmdAdd disabled for library')
	endfunc

*******************************************************************************
* Test that the Add button is enabled for a menu
*******************************************************************************
	function Test_Add_Menu_Enabled
		This.SelectItem('menu.mnx')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdAdd.Enabled, ;
			'cmdAdd disabled for menu')
	endfunc

*******************************************************************************
* Test that the Add button is enabled for other files
*******************************************************************************
	function Test_Add_Other_Enabled
		This.SelectItem('file.xxx')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdAdd.Enabled, ;
			'cmdAdd disabled for other file')
	endfunc

*******************************************************************************
* Test that the Add button is enabled for images
*******************************************************************************
	function Test_Add_Image_Enabled
		This.SelectItem('image.bmp')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdAdd.Enabled, ;
			'cmdAdd disabled for image')
	endfunc

*******************************************************************************
* Test that the Add button is enabled for programs
*******************************************************************************
	function Test_Add_Program_Enabled
		This.SelectItem('program.prg')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdAdd.Enabled, ;
			'cmdAdd disabled for program')
	endfunc

*******************************************************************************
* Test that the Add button is enabled for queries
*******************************************************************************
	function Test_Add_Query_Enabled
		This.SelectItem('query.qpr')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdAdd.Enabled, ;
			'cmdAdd disabled for queries')
	endfunc

*******************************************************************************
* Test that the Add button is enabled for reports
*******************************************************************************
	function Test_Add_Report_Enabled
		This.SelectItem('report.frx')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdAdd.Enabled, ;
			'cmdAdd disabled for reports')
	endfunc

*******************************************************************************
* Test that the Add button is enabled for tables in a DBC
*******************************************************************************
	function Test_Add_TableInDBC_Enabled
		This.SelectItem('table.dbf', 't')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdAdd.Enabled, ;
			'cmdAdd disabled for table in DBC')
	endfunc

*******************************************************************************
* Test that the Add button is enabled for text files
*******************************************************************************
	function Test_Add_Text_Enabled
		This.SelectItem('text.txt')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdAdd.Enabled, ;
			'cmdAdd disabled for text files')
	endfunc

*******************************************************************************
* Test that the Add button is disabled for connections
*******************************************************************************
	function Test_Add_Connection_Disabled
		This.SelectItem('connection', 'c')
		This.AssertFalse(This.oExplorer.oProjectToolbar.cmdAdd.Enabled, ;
			'cmdAdd enabled for connections')
	endfunc

*******************************************************************************
* Test that the Add button is enabled for fields in a DBC table
*******************************************************************************
	function Test_Add_FieldInDBCTable_Enabled
		This.SelectItem('table.field1', 'Field')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdAdd.Enabled, ;
			'cmdAdd disabled for field in DBC table')
	endfunc

*******************************************************************************
* Test that the Add button is disabled for fields in a view
*******************************************************************************
	function Test_Add_FieldInView_Disabled
		This.SelectItem('view.field1', 'Field')
		This.AssertFalse(This.oExplorer.oProjectToolbar.cmdAdd.Enabled, ;
			'cmdAdd enabled for field in view')
	endfunc

*******************************************************************************
* Test that the Add button is enabled for fields in a free table
*******************************************************************************
	function Test_Add_FieldInFreeTable_Enabled
		This.SelectItem('freetable.field1', 'Field')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdAdd.Enabled, ;
			'cmdAdd disabled for field in free table')
	endfunc

*******************************************************************************
* Test that the Add button is enabled for indexes in a DBC table
*******************************************************************************
	function Test_Add_IndexInDBCTable_Enabled
		This.SelectItem('table.field1', 'Index')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdAdd.Enabled, ;
			'cmdAdd disabled for index in DBC table')
	endfunc

*******************************************************************************
* Test that the Add button is enabled for index in a free table
*******************************************************************************
	function Test_Add_IndexInFreeTable_Enabled
		This.SelectItem('freetable.field1', 'Index')
		This.AssertTrue(This.oExplorer.oProjectToolbar.cmdAdd.Enabled, ;
			'cmdAdd disabled for field in index table')
	endfunc

*******************************************************************************
* Test that the Add button is disabled for local views
*******************************************************************************
	function Test_Add_LocalView_Disabled
		This.SelectItem('view', 'l')
		This.AssertFalse(This.oExplorer.oProjectToolbar.cmdAdd.Enabled, ;
			'cmdAdd enabled for local views')
	endfunc

*******************************************************************************
* Test that the Add button is disabled for remote views
*******************************************************************************
	function Test_Add_RemoteView_Disabled
		This.SelectItem('RemoteView', 'r')
		This.AssertFalse(This.oExplorer.oProjectToolbar.cmdAdd.Enabled, ;
			'cmdAdd enabled for remote views')
	endfunc

*******************************************************************************
* Test that the Add button is disabled for stored procs
*******************************************************************************
	function Test_Add_StoredProc_Disabled
		This.SelectItem('MyProc', 'p')
		This.AssertFalse(This.oExplorer.oProjectToolbar.cmdAdd.Enabled, ;
			'cmdAdd enabled for stored proc')
	endfunc

*******************************************************************************
* Test that changing the icon for a class updates the TreeView
*******************************************************************************
	function Test_AfterEdit_Class_UpdatesIcon
		This.SelectItem('myclass', 'Class')
		select 0
		use (This.cTestDataFolder + 'classlib.vcx')
		locate for PLATFORM = 'WINDOWS' and OBJNAME = 'myclass'
		replace RESERVED5 with 'image.bmp'
		use
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		This.AssertEquals(loItem.Key, This.oExplorer.oTreeViewContainer.oSelectedNode.Image, ;
			'TreeView has wrong image')
	endfunc

*******************************************************************************
* Test that adding a table to a database adds it to the TreeView
*******************************************************************************
	function Test_AfterEdit_Database_ReloadsTreeView
		This.SelectItem('data.dbc')
		open database (This.cTestDataFolder + 'data')
		create table (This.cTestDataFolder + 'newtable') (field c(1))
		use
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		lcKey = This.oExplorer.GetNodeKey(loItem) + '~' + 'newtable'
		lcKey = This.oExplorer.oTreeViewContainer.GetNodeKey('t', lcKey)
		This.AssertEquals('O', ;
			type('This.oExplorer.oTreeViewContainer.oTree.Nodes[lcKey]'), ;
			'New table not added to TreeView')
	endfunc

*******************************************************************************
* Test that editing a free table updates the TreeView
*******************************************************************************
	function Test_AfterEdit_FreeTable_ReloadsTreeView
		This.SelectItem('freetable.dbf')
		use (This.cTestDataFolder + 'freetable') exclusive
		alter table FreeTable add column newfield c(1)
		use
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		lcKey = strtran(This.oExplorer.GetNodeKey(loItem), '.pjx', ;
			'.pjx~Field') + '~' + 'newfield'
		lcKey = This.oExplorer.oTreeViewContainer.GetNodeKey('Field', lcKey)
		This.AssertEquals('O', ;
			type('This.oExplorer.oTreeViewContainer.oTree.Nodes[lcKey]'), ;
			'New field not added to TreeView')
	endfunc

*******************************************************************************
* Test that editing a table in a DBC updates the TreeView
*******************************************************************************
	function Test_AfterEdit_TableInDBC_ReloadsTreeView
		This.SelectItem('table.dbf', 't')
		use (This.cTestDataFolder + 'table') exclusive
		alter table Table add column newfield c(1)
		use
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		lcKey = strtran(This.oExplorer.GetNodeKey(loItem), '.pjx', ;
			'.pjx~Field') + '.newfield'
		lcKey = This.oExplorer.oTreeViewContainer.GetNodeKey('Field', lcKey)
		This.AssertEquals('O', ;
			type('This.oExplorer.oTreeViewContainer.oTree.Nodes[lcKey]'), ;
			'New field not added to TreeView')
	endfunc

*******************************************************************************
* Test that editing a free table with a field selected updates the TreeView
*******************************************************************************
	function Test_AfterEdit_FreeTableField_ReloadsTreeView
		This.SelectItem('freetable.field1', 'Field')
		use (This.cTestDataFolder + 'freetable') exclusive
		alter table FreeTable add column newfield c(1)
		use
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		lcKey = strtran(This.oExplorer.GetNodeKey(loItem), 'field1', ;
			'newfield')
		lcKey = This.oExplorer.oTreeViewContainer.GetNodeKey('Field', lcKey)
		This.AssertEquals('O', ;
			type('This.oExplorer.oTreeViewContainer.oTree.Nodes[lcKey]'), ;
			'New field not added to TreeView')
	endfunc

*******************************************************************************
* Test that editing a table in a DBC with a field selected updates the TreeView
*******************************************************************************
	function Test_AfterEdit_TableInDBCField_ReloadsTreeView
		This.SelectItem('table.field1', 'Field')
		use (This.cTestDataFolder + 'table') exclusive
		alter table Table add column newfield c(1)
		use
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		lcKey = strtran(This.oExplorer.GetNodeKey(loItem), 'field1', ;
			'newfield')
		lcKey = This.oExplorer.oTreeViewContainer.GetNodeKey('Field', lcKey)
		This.AssertEquals('O', ;
			type('This.oExplorer.oTreeViewContainer.oTree.Nodes[lcKey]'), ;
			'New field not added to TreeView')
	endfunc

*******************************************************************************
* Test that editing a non-binary file without auto-commit updates status
*******************************************************************************
	function Test_AfterEdit_NonBinary_NoAutoCommit_UpdatesStatus
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 2, .F., 'add', 'remove', 'cleanup', ;
			'add vc', '', This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('text.txt')
		strtofile('new text', This.cTestDataFolder + 'text.txt')
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		This.AssertEquals('M', loItem.VersionControlStatus, ;
			'Did not update status')
	endfunc

*******************************************************************************
* Test that editing a non-binary file with auto-commit updates status
*******************************************************************************
	function Test_AfterEdit_NonBinary_AutoCommit_UpdatesStatus
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 2, .T., 'add', 'remove', 'cleanup', ;
			'add vc', '', This.cTestDataFolder, .T.)
		This.SelectItem('text.txt')
		strtofile('new text', This.cTestDataFolder + 'text.txt')
		This.oExplorer.cTestCommitMessage = 'edit'
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		This.AssertEquals('C', loItem.VersionControlStatus, ;
			'Did not update status')
	endfunc

*******************************************************************************
* Test that editing a binary file with binary only and without auto-commit
* updates status
*******************************************************************************
	function Test_AfterEdit_Binary_BinaryOnly_NoAutoCommit_UpdatesStatus
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 1, .F., 'add', 'remove', 'cleanup', ;
			'add vc', '', This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('form.scx')
		select 0
		use (This.cTestDataFolder + 'form.scx')
		locate for PLATFORM = 'WINDOWS' and OBJNAME = 'Form1'
		replace PROPERTIES with PROPERTIES + 'Tag = "x"' + chr(13) + chr(10)
		use
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		This.AssertEquals('M', loItem.VersionControlStatus, ;
			'Did not update status')
	endfunc

*******************************************************************************
* Test that editing a binary file with binary only and with auto-commit
* updates status
*******************************************************************************
	function Test_AfterEdit_Binary_BinaryOnly_AutoCommit_UpdatesStatus
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 1, .T., 'add', 'remove', 'cleanup', ;
			'add vc', '', This.cTestDataFolder, .T.)
		This.SelectItem('form.scx')
		select 0
		use (This.cTestDataFolder + 'form.scx')
		locate for PLATFORM = 'WINDOWS' and OBJNAME = 'Form1'
		replace PROPERTIES with PROPERTIES + 'Tag = "x"' + chr(13) + chr(10)
		use
		This.oExplorer.cTestCommitMessage = 'edit'
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		This.AssertEquals('C', loItem.VersionControlStatus, ;
			'Did not update status')
	endfunc

*******************************************************************************
* Test that editing a binary file with text only and without auto-commit
* updates status
*******************************************************************************
	function Test_AfterEdit_Binary_TextOnly_NoAutoCommit_UpdatesStatus
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 2, .F., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('form.scx')
		select 0
		use (This.cTestDataFolder + 'form.scx')
		locate for PLATFORM = 'WINDOWS' and OBJNAME = 'Form1'
		replace PROPERTIES with PROPERTIES + 'Tag = "x"' + chr(13) + chr(10)
		use
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		This.AssertEquals('M', loItem.VersionControlStatus, ;
			'Did not update status')
	endfunc

*******************************************************************************
* Test that editing a binary file with text only and with auto-commit
* updates status
*******************************************************************************
	function Test_AfterEdit_Binary_TextOnly_AutoCommit_UpdatesStatus
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 2, .T., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.SelectItem('form.scx')
		select 0
		use (This.cTestDataFolder + 'form.scx')
		locate for PLATFORM = 'WINDOWS' and OBJNAME = 'Form1'
		replace PROPERTIES with PROPERTIES + 'Tag = "x"' + chr(13) + chr(10)
		use
		This.oExplorer.cTestCommitMessage = 'edit'
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		This.AssertEquals('C', loItem.VersionControlStatus, ;
			'Did not update status')
	endfunc

*******************************************************************************
* Test that editing a binary file with both and without auto-commit
* updates status
*******************************************************************************
	function Test_AfterEdit_Binary_Both_NoAutoCommit_UpdatesStatus
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 3, .F., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('form.scx')
		select 0
		use (This.cTestDataFolder + 'form.scx')
		locate for PLATFORM = 'WINDOWS' and OBJNAME = 'Form1'
		replace PROPERTIES with PROPERTIES + 'Tag = "x"' + chr(13) + chr(10)
		use
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		This.AssertEquals('M', loItem.VersionControlStatus, ;
			'Did not update status')
	endfunc

*******************************************************************************
* Test that editing a binary file with both and with auto-commit
* updates status
*******************************************************************************
	function Test_AfterEdit_Binary_Both_AutoCommit_UpdatesStatus
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 3, .T., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.SelectItem('form.scx')
		select 0
		use (This.cTestDataFolder + 'form.scx')
		locate for PLATFORM = 'WINDOWS' and OBJNAME = 'Form1'
		replace PROPERTIES with PROPERTIES + 'Tag = "x"' + chr(13) + chr(10)
		use
		This.oExplorer.cTestCommitMessage = 'edit'
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		This.AssertEquals('C', loItem.VersionControlStatus, ;
			'Did not update status')
	endfunc

*******************************************************************************
* Test that editing a table in a DBC with binary only and without auto-commit
* updates status of table and DBC
*******************************************************************************
	function Test_AfterEdit_TableInDBC_BinaryOnly_NoAutoCommit_UpdatesStatus
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 1, .F., 'add', 'remove', 'cleanup', ;
			'add vc', '', This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('table.dbf', 't')
		select 0
		use (This.cTestDataFolder + 'table') exclusive
		alter table Table add column newfield c(1)
		use
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		This.AssertEquals('M', loItem.VersionControlStatus, ;
			'Did not update status of table')
		This.SelectItem('data.dbc')
		loItem = This.GetItemForNode()
		This.AssertEquals('M', loItem.VersionControlStatus, ;
			'Did not update status of DBC')
	endfunc

*******************************************************************************
* Test that editing a table in a DBC with binary only and with auto-commit
* updates status of table and DBC
*******************************************************************************
	function Test_AfterEdit_TableInDBC_BinaryOnly_AutoCommit_UpdatesStatus
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 1, .T., 'add', 'remove', 'cleanup', ;
			'add vc', '', This.cTestDataFolder, .T.)
		This.SelectItem('table.dbf', 't')
		select 0
		use (This.cTestDataFolder + 'table') exclusive
		alter table Table add column newfield c(1)
		use
		This.oExplorer.cTestCommitMessage = 'edit'
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		This.AssertEquals('C', loItem.VersionControlStatus, ;
			'Did not update status of table')
		This.SelectItem('data.dbc')
		loItem = This.GetItemForNode()
		This.AssertEquals('C', loItem.VersionControlStatus, ;
			'Did not update status of DBC')
	endfunc

*******************************************************************************
* Test that editing a table in a DBC with text only and without auto-commit
* updates status of table and DBC
*******************************************************************************
	function Test_AfterEdit_TableInDBC_TextOnly_NoAutoCommit_UpdatesStatus
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 2, .F., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('table.dbf', 't')
		select 0
		use (This.cTestDataFolder + 'table') exclusive
		alter table Table add column newfield c(1)
		use
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		This.AssertEquals('M', loItem.VersionControlStatus, ;
			'Did not update status of table')
		This.SelectItem('data.dbc')
		loItem = This.GetItemForNode()
		This.AssertEquals('M', loItem.VersionControlStatus, ;
			'Did not update status of DBC')
	endfunc

*******************************************************************************
* Test that editing a table in a DBC with text only and with auto-commit
* updates status of table and DBC
*******************************************************************************
	function Test_AfterEdit_TableInDBC_TextOnly_AutoCommit_UpdatesStatus
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 2, .T., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.SelectItem('table.dbf', 't')
		select 0
		use (This.cTestDataFolder + 'table') exclusive
		alter table Table add column newfield c(1)
		use
		This.oExplorer.cTestCommitMessage = 'edit'
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		This.AssertEquals('C', loItem.VersionControlStatus, ;
			'Did not update status of table')
		This.SelectItem('data.dbc')
		loItem = This.GetItemForNode()
		This.AssertEquals('C', loItem.VersionControlStatus, ;
			'Did not update status of DBC')
	endfunc

*******************************************************************************
* Test that editing a table in a DBC with both and without auto-commit
* updates status of table and DBC
*******************************************************************************
	function Test_AfterEdit_TableInDBC_Both_NoAutoCommit_UpdatesStatus
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 3, .F., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('table.dbf', 't')
		select 0
		use (This.cTestDataFolder + 'table') exclusive
		alter table Table add column newfield c(1)
		use
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		This.AssertEquals('M', loItem.VersionControlStatus, ;
			'Did not update status of table')
		This.SelectItem('data.dbc')
		loItem = This.GetItemForNode()
		This.AssertEquals('M', loItem.VersionControlStatus, ;
			'Did not update status of DBC')
	endfunc

*******************************************************************************
* Test that editing a table in a DBC with both and with auto-commit
* updates status of table and DBC
*******************************************************************************
	function Test_AfterEdit_TableInDBC_Both_AutoCommit_UpdatesStatus
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 3, .T., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.SelectItem('table.dbf', 't')
		select 0
		use (This.cTestDataFolder + 'table') exclusive 
		alter table Table add column newfield c(1)
		use
		This.oExplorer.cTestCommitMessage = 'edit'
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		This.AssertEquals('C', loItem.VersionControlStatus, ;
			'Did not update status of table')
		This.SelectItem('data.dbc')
		loItem = This.GetItemForNode()
		This.AssertEquals('C', loItem.VersionControlStatus, ;
			'Did not update status of DBC')
	endfunc

*******************************************************************************
* Test that editing a free table with binary only and without auto-commit
* updates status
*******************************************************************************
	function Test_AfterEdit_FreeTable_BinaryOnly_NoAutoCommit_UpdatesStatus
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 1, .F., 'add', 'remove', 'cleanup', ;
			'add vc', '', This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('freetable.dbf')
		select 0
		use (This.cTestDataFolder + 'freetable') exclusive
		alter table FreeTable add column newfield c(1)
		use
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		loItem = This.GetItemForNode()
			&& have to get the item again since AfterEditItem removes and
			&& re-adds it
		This.AssertEquals('M', loItem.VersionControlStatus, ;
			'Did not update status')
	endfunc

*******************************************************************************
* Test that editing a free table with binary only and with auto-commit
* updates status
*******************************************************************************
	function Test_AfterEdit_FreeTable_BinaryOnly_AutoCommit_UpdatesStatus
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 1, .T., 'add', 'remove', 'cleanup', ;
			'add vc', '', This.cTestDataFolder, .T.)
		This.SelectItem('freetable.dbf')
		select 0
		use (This.cTestDataFolder + 'freetable') exclusive
		alter table FreeTable add column newfield c(1)
		use
		This.oExplorer.cTestCommitMessage = 'edit'
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		loItem = This.GetItemForNode()
			&& have to get the item again since AfterEditItem removes and
			&& re-adds it
		This.AssertEquals('C', loItem.VersionControlStatus, ;
			'Did not update status')
	endfunc

*******************************************************************************
* Test that editing a free table with text only and without auto-commit
* updates status
*******************************************************************************
	function Test_AfterEdit_FreeTable_TextOnly_NoAutoCommit_UpdatesStatus
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 2, .F., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('freetable.dbf')
		select 0
		use (This.cTestDataFolder + 'freetable') exclusive
		alter table FreeTable add column newfield c(1)
		use
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		loItem = This.GetItemForNode()
			&& have to get the item again since AfterEditItem removes and
			&& re-adds it
		This.AssertEquals('M', loItem.VersionControlStatus, ;
			'Did not update status')
	endfunc

*******************************************************************************
* Test that editing a free table with text only and with auto-commit
* updates status
*******************************************************************************
	function Test_AfterEdit_FreeTable_TextOnly_AutoCommit_UpdatesStatus
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 2, .T., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.SelectItem('freetable.dbf')
		select 0
		use (This.cTestDataFolder + 'freetable') exclusive
		alter table FreeTable add column newfield c(1)
		use
		This.oExplorer.cTestCommitMessage = 'edit'
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		loItem = This.GetItemForNode()
			&& have to get the item again since AfterEditItem removes and
			&& re-adds it
		This.AssertEquals('C', loItem.VersionControlStatus, ;
			'Did not update status')
	endfunc

*******************************************************************************
* Test that editing a free table with both and without auto-commit
* updates status
*******************************************************************************
	function Test_AfterEdit_FreeTable_Both_NoAutoCommit_UpdatesStatus
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 3, .F., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('freetable', 't')
		select 0
		use (This.cTestDataFolder + 'freetable') exclusive
		alter table FreeTable add column newfield c(1)
		use
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		loItem = This.GetItemForNode()
			&& have to get the item again since AfterEditItem removes and
			&& re-adds it
		This.AssertEquals('M', loItem.VersionControlStatus, ;
			'Did not update status')
	endfunc

*******************************************************************************
* Test that editing a free table with both and with auto-commit updates status
*******************************************************************************
	function Test_AfterEdit_FreeTable_Both_AutoCommit_UpdatesStatus
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 3, .T., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.SelectItem('freetable.dbf')
		select 0
		use (This.cTestDataFolder + 'freetable') exclusive 
		alter table FreeTable add column newfield c(1)
		use
		This.oExplorer.cTestCommitMessage = 'edit'
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		loItem = This.GetItemForNode()
			&& have to get the item again since AfterEditItem removes and
			&& re-adds it
		This.AssertEquals('C', loItem.VersionControlStatus, ;
			'Did not update status')
	endfunc

*******************************************************************************
* Test that editing a free table when a field is selected with text only and
* without auto-commit updates status
*******************************************************************************
	function Test_AfterEdit_FreeTableField_TextOnly_NoAutoCommit_UpdatesStatus
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 2, .F., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('freetable.field1', 'Field')
		select 0
		use (This.cTestDataFolder + 'freetable') exclusive
		alter table FreeTable add column newfield c(1)
		use
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		This.SelectItem('freetable.dbf')
		loItem = This.GetItemForNode()
		This.AssertEquals('M', loItem.VersionControlStatus, ;
			'Did not update status')
	endfunc

*******************************************************************************
* Test that editing a table in a DBC when a field is selected with text only
* and without auto-commit updates status of table and DBC
*******************************************************************************
	function Test_AfterEdit_TableInDBCField_TextOnly_NoAutoCommit_UpdatesStatus
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 2, .F., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('table.field1', 'Field')
		select 0
		use (This.cTestDataFolder + 'table') exclusive
		alter table Table add column newfield c(1)
		use
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		This.SelectItem('table.dbf', 't')
		loItem = This.GetItemForNode()
		This.AssertEquals('M', loItem.VersionControlStatus, ;
			'Did not update status of table')
		This.SelectItem('data.dbc')
		loItem = This.GetItemForNode()
		This.AssertEquals('M', loItem.VersionControlStatus, ;
			'Did not update status of DBC')
	endfunc

*******************************************************************************
* Test that editing the stored procedures of a DBC with text only and without
* auto-commit updates status of the DBC
*******************************************************************************
	function Test_AfterEdit_StoredProc_TextOnly_NoAutoCommit_UpdatesStatus
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 2, .F., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('MyProc', 'p')
		open database (This.cTestDataFolder + 'data')
		strtofile('function BlahBlah', This.cTestDataFolder + 'x.txt')
		append procedures from (This.cTestDataFolder + 'x.txt')
		loItem = This.GetItemForNode()
		This.oExplorer.AfterEditItem(loItem)
		This.SelectItem('data.dbc')
		loItem = This.GetItemForNode()
		This.AssertEquals('M', loItem.VersionControlStatus, ;
			'Did not update status of DBC')
	endfunc

*******************************************************************************
* Test that adding a file adds it to the project
*******************************************************************************
	function Test_Add_AddsToProject
		This.oExplorer.LoadSolution()
		This.SelectItem('program.prg')
		lcFile = This.cTestDataFolder + 'x.prg'
		strtofile('function BlahBlah', lcFile)
		This.oExplorer.AddItem(lcFile)
		This.AssertEquals('O', ;
			type('This.oExplorer.oProject.oProject.Files(lcFile)'), ;
			'Did not add file to project')
	endfunc

*******************************************************************************
* Test that adding a file adds it to the collection
*******************************************************************************
	function Test_Add_AddsToCollection
		This.oExplorer.LoadSolution()
		This.SelectItem('program.prg')
		lcFile = This.cTestDataFolder + 'x.prg'
		strtofile('function BlahBlah', lcFile)
		This.oExplorer.AddItem(lcFile)
		loItem = This.oExplorer.oProject.GetItemForFile(lcFile)
		This.AssertEquals('O', vartype(loItem), ;
			'Did not add file to collection')
	endfunc

*******************************************************************************
* Test that adding a file adds it to the TreeView
*******************************************************************************
	function Test_Add_AddsToTreeView
		This.oExplorer.LoadSolution()
		This.SelectItem('program.prg')
		lcFile = This.cTestDataFolder + 'x.prg'
		strtofile('function BlahBlah', lcFile)
		This.oExplorer.AddItem(lcFile)
		This.SelectItem('x.prg')
		loItem = This.GetItemForNode()
		This.AssertEquals('O', vartype(loItem), ;
			'Did not add file to TreeView')
	endfunc

*******************************************************************************
* Test that adding a file adds it to version control
*******************************************************************************
	function Test_Add_AddsToVersionControl
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 2, .F., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('program.prg')
		lcFile = This.cTestDataFolder + 'x.prg'
		strtofile('function BlahBlah', lcFile)
		This.oExplorer.AddItem(lcFile)
		This.SelectItem('x.prg')
		loItem = This.GetItemForNode()
		This.AssertEquals('A', loItem.VersionControlStatus, ;
			'Did not add file to version control')
	endfunc

*******************************************************************************
* Test that adding a file to a project with binary only and without auto-commit
* updates status of the PJX
*******************************************************************************
	function Test_Add_BinaryOnly_NoAutoCommit_UpdatesProject
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 1, .F., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('program.prg')
		lcFile = This.cTestDataFolder + 'x.prg'
		strtofile('function BlahBlah', lcFile)
		This.oExplorer.AddItem(lcFile)
		This.AssertEquals('M', ;
			This.oExplorer.oProject.oProjectItem.VersionControlStatus, ;
			'Did not update status of PJX')
	endfunc

*******************************************************************************
* Test that adding a file to a project with binary only and with auto-commit
* updates status of the PJX
*******************************************************************************
	function Test_Add_BinaryOnly_AutoCommit_UpdatesProject
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 1, .T., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.SelectItem('program.prg')
		lcFile = This.cTestDataFolder + 'x.prg'
		strtofile('function BlahBlah', lcFile)
		This.oExplorer.AddItem(lcFile)
		This.AssertEquals('C', ;
			This.oExplorer.oProject.oProjectItem.VersionControlStatus, ;
			'Did not update status of PJX')
	endfunc

*******************************************************************************
* Test that adding a file to a project with text only and without auto-commit
* updates status of the PJX
*******************************************************************************
	function Test_Add_TextOnly_NoAutoCommit_UpdatesProject
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 2, .F., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('program.prg')
		lcFile = This.cTestDataFolder + 'x.prg'
		strtofile('function BlahBlah', lcFile)
		This.oExplorer.AddItem(lcFile)
		This.AssertEquals('M', ;
			This.oExplorer.oProject.oProjectItem.VersionControlStatus, ;
			'Did not update status of PJX')
	endfunc

*******************************************************************************
* Test that adding a file to a project with text only and with auto-commit
* updates status of the PJX
*******************************************************************************
	function Test_Add_TextOnly_AutoCommit_UpdatesProject
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 2, .T., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.SelectItem('program.prg')
		lcFile = This.cTestDataFolder + 'x.prg'
		strtofile('function BlahBlah', lcFile)
		This.oExplorer.AddItem(lcFile)
		This.AssertEquals('C', ;
			This.oExplorer.oProject.oProjectItem.VersionControlStatus, ;
			'Did not update status of PJX')
	endfunc

*******************************************************************************
* Test that adding a file to a project with both and without auto-commit
* updates status of the PJX
*******************************************************************************
	function Test_Add_Both_NoAutoCommit_UpdatesProject
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 3, .F., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('program.prg')
		lcFile = This.cTestDataFolder + 'x.prg'
		strtofile('function BlahBlah', lcFile)
		This.oExplorer.AddItem(lcFile)
		This.AssertEquals('M', ;
			This.oExplorer.oProject.oProjectItem.VersionControlStatus, ;
			'Did not update status of PJX')
	endfunc

*******************************************************************************
* Test that adding a file to a project with both and with auto-commit updates
* status of the PJX
*******************************************************************************
	function Test_Add_Both_AutoCommit_UpdatesProject
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 3, .T., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.SelectItem('program.prg')
		lcFile = This.cTestDataFolder + 'x.prg'
		strtofile('function BlahBlah', lcFile)
		This.oExplorer.AddItem(lcFile)
		This.AssertEquals('C', ;
			This.oExplorer.oProject.oProjectItem.VersionControlStatus, ;
			'Did not update status of PJX')
	endfunc

*******************************************************************************
* Test that adding a file fires the projecthook QueryAddFile event
*******************************************************************************
	function Test_Add_FiresQueryAddFile
		This.oExplorer.LoadSolution()
		This.oExplorer.oProject.oProject.ProjectHook = createobject('TestProjectHook')
		This.SelectItem('program.prg')
		lcFile = This.cTestDataFolder + 'x.prg'
		strtofile('function BlahBlah', lcFile)
		This.oExplorer.AddItem(lcFile)
		This.AssertEquals(lcFile, pcFileName, ;
			'Did not add fire QueryAddFile')
	endfunc

*******************************************************************************
* Test that adding a binary file to a project with binary only and without
* auto-commit updates status of the file (this also tests that the file is the
* selected item)
*******************************************************************************
	function Test_Add_Binary_BinaryOnly_NoAutoCommit_UpdatesFile
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 1, .F., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('freetable.dbf')
		lcFile = This.cTestDataFolder + 'newtable.dbf'
		create table (lcFile) (field1 c(1))
		use
		This.oExplorer.AddItem(lcFile)
		loItem = This.GetItemForNode()
		This.AssertEquals('A', loItem.VersionControlStatus, ;
			'Did not update status of file')
	endfunc

*******************************************************************************
* Test that adding a binary file to a project with binary only and with
* auto-commit updates status of the file
*******************************************************************************
	function Test_Add_Binary_BinaryOnly_AutoCommit_UpdatesFile
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 1, .T., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.SelectItem('freetable.dbf')
		lcFile = This.cTestDataFolder + 'newtable.dbf'
		create table (lcFile) (field1 c(1))
		use
		This.oExplorer.AddItem(lcFile)
		loItem = This.GetItemForNode()
		This.AssertEquals('C', loItem.VersionControlStatus, ;
			'Did not update status of file')
	endfunc

*******************************************************************************
* Test that adding a binary file to a project with text only and without
* auto-commit updates status of the file
*******************************************************************************
	function Test_Add_Binary_TextOnly_NoAutoCommit_UpdatesFile
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 2, .F., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('freetable.dbf')
		lcFile = This.cTestDataFolder + 'newtable.dbf'
		create table (lcFile) (field1 c(1))
		use
		This.oExplorer.AddItem(lcFile)
		loItem = This.GetItemForNode()
		This.AssertEquals('A', loItem.VersionControlStatus, ;
			'Did not update status of file')
	endfunc

*******************************************************************************
* Test that adding a binary file to a project with text only and with
* auto-commit updates status of the file
*******************************************************************************
	function Test_Add_Binary_TextOnly_AutoCommit_UpdatesFile
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 2, .T., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.SelectItem('freetable.dbf')
		lcFile = This.cTestDataFolder + 'newtable.dbf'
		create table (lcFile) (field1 c(1))
		use
		This.oExplorer.AddItem(lcFile)
		loItem = This.GetItemForNode()
		This.AssertEquals('C', loItem.VersionControlStatus, ;
			'Did not update status of file')
	endfunc

*******************************************************************************
* Test that adding a binary file to a project with both and without auto-commit
* updates status of the file
*******************************************************************************
	function Test_Add_Binary_Both_NoAutoCommit_UpdatesFile
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 3, .F., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('freetable.dbf')
		lcFile = This.cTestDataFolder + 'newtable.dbf'
		create table (lcFile) (field1 c(1))
		use
		This.oExplorer.AddItem(lcFile)
		loItem = This.GetItemForNode()
		This.AssertEquals('A', loItem.VersionControlStatus, ;
			'Did not update status of file')
	endfunc

*******************************************************************************
* Test that adding a binary file to a project with both and with auto-commit
* updates status of the file
*******************************************************************************
	function Test_Add_Binary_Both_AutoCommit_UpdatesFile
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 3, .T., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.SelectItem('freetable.dbf')
		lcFile = This.cTestDataFolder + 'newtable.dbf'
		create table (lcFile) (field1 c(1))
		use
		This.oExplorer.AddItem(lcFile)
		loItem = This.GetItemForNode()
		This.AssertEquals('C', loItem.VersionControlStatus, ;
			'Did not update status of file')
	endfunc

*******************************************************************************
* Test that adding a table to a DBC with binary only and without auto-commit
* updates status of the DBC
*******************************************************************************
	function Test_Add_TableToDBC_BinaryOnly_NoAutoCommit_UpdatesDBC
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 1, .F., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('table.dbf', 't')
		lcFile = This.cTestDataFolder + 'newtable.dbf'
		create table (lcFile) (field1 c(1))
		use
		This.oExplorer.AddItem(lcFile)
		This.SelectItem('data.dbc')
		loItem = This.GetItemForNode()
		This.AssertEquals('M', loItem.VersionControlStatus, ;
			'Did not update status of DBC')
	endfunc

*******************************************************************************
* Test that adding a table to a DBC with binary only and with auto-commit
* updates status of the DBC
*******************************************************************************
	function Test_Add_TableToDBC_BinaryOnly_AutoCommit_UpdatesDBC
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 1, .T., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.SelectItem('table.dbf', 't')
		lcFile = This.cTestDataFolder + 'newtable.dbf'
		create table (lcFile) (field1 c(1))
		use
		This.oExplorer.AddItem(lcFile)
		This.SelectItem('data.dbc')
		loItem = This.GetItemForNode()
		This.AssertEquals('C', loItem.VersionControlStatus, ;
			'Did not update status of DBC')
	endfunc

*******************************************************************************
* Test that adding a table to a DBC with text only and without auto-commit
* updates status of the DBC
*******************************************************************************
	function Test_Add_TableToDBC_TextOnly_NoAutoCommit_UpdatesDBC
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 2, .F., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('table.dbf', 't')
		lcFile = This.cTestDataFolder + 'newtable.dbf'
		create table (lcFile) (field1 c(1))
		use
		This.oExplorer.AddItem(lcFile)
		This.SelectItem('data.dbc')
		loItem = This.GetItemForNode()
		This.AssertEquals('M', loItem.VersionControlStatus, ;
			'Did not update status of DBC')
	endfunc

*******************************************************************************
* Test that adding a table to a DBC with text only and with auto-commit updates
* status of the DBC
*******************************************************************************
	function Test_Add_TableToDBC_TextOnly_AutoCommit_UpdatesDBC
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 2, .T., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.SelectItem('table.dbf', 't')
		lcFile = This.cTestDataFolder + 'newtable.dbf'
		create table (lcFile) (field1 c(1))
		use
		This.oExplorer.AddItem(lcFile)
		This.SelectItem('data.dbc')
		loItem = This.GetItemForNode()
		This.AssertEquals('C', loItem.VersionControlStatus, ;
			'Did not update status of DBC')
	endfunc

*******************************************************************************
* Test that adding a table to a DBC with both and without auto-commit updates
* status of the DBC
*******************************************************************************
	function Test_Add_TableToDBC_Both_NoAutoCommit_UpdatesDBC
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 3, .F., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('table.dbf', 't')
		lcFile = This.cTestDataFolder + 'newtable.dbf'
		create table (lcFile) (field1 c(1))
		use
		This.oExplorer.AddItem(lcFile)
		This.SelectItem('data.dbc')
		loItem = This.GetItemForNode()
		This.AssertEquals('M', loItem.VersionControlStatus, ;
			'Did not update status of DBC')
	endfunc

*******************************************************************************
* Test that adding a table to a DBC with both and with auto-commit updates
* status of the DBC
*******************************************************************************
	function Test_Add_TableToDBC_Both_AutoCommit_UpdatesDBC
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 3, .T., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.SelectItem('table.dbf', 't')
		lcFile = This.cTestDataFolder + 'newtable.dbf'
		create table (lcFile) (field1 c(1))
		use
		This.oExplorer.AddItem(lcFile)
		This.SelectItem('data.dbc')
		loItem = This.GetItemForNode()
		This.AssertEquals('C', loItem.VersionControlStatus, ;
			'Did not update status of DBC')
	endfunc

*******************************************************************************
* Test that creating a file adds it to the project
*******************************************************************************
	function Test_AfterNew_AddsToProject
		This.oExplorer.LoadSolution()
		This.SelectItem('program.prg')
		lcFile = This.cTestDataFolder + 'x.prg'
		strtofile('function BlahBlah', lcFile)
		loItem          = This.oExplorer.oProject.CreateItem('P')
		loItem.Path     = lcFile
		loItem.ItemName = lower(juststem(lcFile))
		loItem.Project  = This.cProject
		loItem.New      = .T.
		This.oExplorer.AfterNewItem(loItem)
		This.AssertEquals('O', ;
			type('This.oExplorer.oProject.oProject.Files(lcFile)'), ;
			'Did not add file to project')
	endfunc

*******************************************************************************
* Test that creating a file adds it to the collection
*******************************************************************************
	function Test_AfterNew_AddsToCollection
		This.oExplorer.LoadSolution()
		This.SelectItem('program.prg')
		lcFile = This.cTestDataFolder + 'x.prg'
		strtofile('function BlahBlah', lcFile)
		loItem          = This.oExplorer.oProject.CreateItem('P')
		loItem.Path     = lcFile
		loItem.ItemName = lower(juststem(lcFile))
		loItem.Project  = This.cProject
		loItem.New      = .T.
		This.oExplorer.AfterNewItem(loItem)
		This.AssertEquals('O', vartype(loItem), ;
			'Did not add file to collection')
	endfunc

*******************************************************************************
* Test that creating a file adds it to the TreeView
*******************************************************************************
	function Test_AfterNew_AddsToTreeView
		This.oExplorer.LoadSolution()
		This.SelectItem('program.prg')
		lcFile = This.cTestDataFolder + 'x.prg'
		strtofile('function BlahBlah', lcFile)
		loItem          = This.oExplorer.oProject.CreateItem('P')
		loItem.Path     = lcFile
		loItem.ItemName = lower(juststem(lcFile))
		loItem.Project  = This.cProject
		loItem.New      = .T.
		This.oExplorer.AfterNewItem(loItem)
		This.SelectItem('x.prg')
		loItem = This.GetItemForNode()
		This.AssertEquals('O', vartype(loItem), ;
			'Did not add file to TreeView')
	endfunc

*******************************************************************************
* Test that creating a file adds it to version control
*******************************************************************************
	function Test_AfterNew_AddsToVersionControl
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 2, .F., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('program.prg')
		lcFile = This.cTestDataFolder + 'x.prg'
		strtofile('function BlahBlah', lcFile)
		loItem          = This.oExplorer.oProject.CreateItem('P')
		loItem.Path     = lcFile
		loItem.ItemName = lower(juststem(lcFile))
		loItem.Project  = This.cProject
		loItem.New      = .T.
		This.oExplorer.AfterNewItem(loItem)
		This.SelectItem('x.prg')
		loItem = This.GetItemForNode()
		This.AssertEquals('A', loItem.VersionControlStatus, ;
			'Did not add file to version control')
	endfunc

*******************************************************************************
* Test that creating a file to a project with binary only and without auto-commit
* updates status of the PJX
*******************************************************************************
	function Test_AfterNew_BinaryOnly_NoAutoCommit_UpdatesProject
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 1, .F., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('program.prg')
		lcFile = This.cTestDataFolder + 'x.prg'
		strtofile('function BlahBlah', lcFile)
		loItem          = This.oExplorer.oProject.CreateItem('P')
		loItem.Path     = lcFile
		loItem.ItemName = lower(juststem(lcFile))
		loItem.Project  = This.cProject
		loItem.New      = .T.
		This.oExplorer.AfterNewItem(loItem)
		This.AssertEquals('M', ;
			This.oExplorer.oProject.oProjectItem.VersionControlStatus, ;
			'Did not update status of PJX')
	endfunc

*******************************************************************************
* Test that creating a file to a project with binary only and with auto-commit
* updates status of the PJX
*******************************************************************************
	function Test_AfterNew_BinaryOnly_AutoCommit_UpdatesProject
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 1, .T., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.SelectItem('program.prg')
		lcFile = This.cTestDataFolder + 'x.prg'
		strtofile('function BlahBlah', lcFile)
		loItem          = This.oExplorer.oProject.CreateItem('P')
		loItem.Path     = lcFile
		loItem.ItemName = lower(juststem(lcFile))
		loItem.Project  = This.cProject
		loItem.New      = .T.
		This.oExplorer.cTestCommitMessage = 'commit'
		This.oExplorer.AfterNewItem(loItem)
		This.AssertEquals('C', ;
			This.oExplorer.oProject.oProjectItem.VersionControlStatus, ;
			'Did not update status of PJX')
	endfunc

*******************************************************************************
* Test that creating a file to a project with text only and without auto-commit
* updates status of the PJX
*******************************************************************************
	function Test_AfterNew_TextOnly_NoAutoCommit_UpdatesProject
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 2, .F., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('program.prg')
		lcFile = This.cTestDataFolder + 'x.prg'
		strtofile('function BlahBlah', lcFile)
		loItem          = This.oExplorer.oProject.CreateItem('P')
		loItem.Path     = lcFile
		loItem.ItemName = lower(juststem(lcFile))
		loItem.Project  = This.cProject
		loItem.New      = .T.
		This.oExplorer.AfterNewItem(loItem)
		This.AssertEquals('M', ;
			This.oExplorer.oProject.oProjectItem.VersionControlStatus, ;
			'Did not update status of PJX')
	endfunc

*******************************************************************************
* Test that creating a file to a project with text only and with auto-commit
* updates status of the PJX
*******************************************************************************
	function Test_AfterNew_TextOnly_AutoCommit_UpdatesProject
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 2, .T., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.SelectItem('program.prg')
		lcFile = This.cTestDataFolder + 'x.prg'
		strtofile('function BlahBlah', lcFile)
		loItem          = This.oExplorer.oProject.CreateItem('P')
		loItem.Path     = lcFile
		loItem.ItemName = lower(juststem(lcFile))
		loItem.Project  = This.cProject
		loItem.New      = .T.
		This.oExplorer.cTestCommitMessage = 'commit'
		This.oExplorer.AfterNewItem(loItem)
		This.AssertEquals('C', ;
			This.oExplorer.oProject.oProjectItem.VersionControlStatus, ;
			'Did not update status of PJX')
	endfunc

*******************************************************************************
* Test that creating a file to a project with both and without auto-commit
* updates status of the PJX
*******************************************************************************
	function Test_AfterNew_Both_NoAutoCommit_UpdatesProject
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 3, .F., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('program.prg')
		lcFile = This.cTestDataFolder + 'x.prg'
		strtofile('function BlahBlah', lcFile)
		loItem          = This.oExplorer.oProject.CreateItem('P')
		loItem.Path     = lcFile
		loItem.ItemName = lower(juststem(lcFile))
		loItem.Project  = This.cProject
		loItem.New      = .T.
		This.oExplorer.AfterNewItem(loItem)
		This.AssertEquals('M', ;
			This.oExplorer.oProject.oProjectItem.VersionControlStatus, ;
			'Did not update status of PJX')
	endfunc

*******************************************************************************
* Test that creating a file to a project with both and with auto-commit updates
* status of the PJX
*******************************************************************************
	function Test_AfterNew_Both_AutoCommit_UpdatesProject
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 3, .T., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.SelectItem('program.prg')
		lcFile = This.cTestDataFolder + 'x.prg'
		strtofile('function BlahBlah', lcFile)
		loItem          = This.oExplorer.oProject.CreateItem('P')
		loItem.Path     = lcFile
		loItem.ItemName = lower(juststem(lcFile))
		loItem.Project  = This.cProject
		loItem.New      = .T.
		This.oExplorer.cTestCommitMessage = 'commit'
		This.oExplorer.AfterNewItem(loItem)
		This.AssertEquals('C', ;
			This.oExplorer.oProject.oProjectItem.VersionControlStatus, ;
			'Did not update status of PJX')
	endfunc

*******************************************************************************
* Test that creating a binary file to a project with binary only and without
* auto-commit updates status of the file (this also tests that the file is the
* selected item)
*******************************************************************************
	function Test_AfterNew_Binary_BinaryOnly_NoAutoCommit_UpdatesFile
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 1, .F., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('freetable.dbf')
		lcFile = This.cTestDataFolder + 'newtable.dbf'
		create table (lcFile) (field1 c(1))
		use
		loItem          = This.oExplorer.oProject.CreateItem('D')
		loItem.Path     = lcFile
		loItem.ItemName = lower(juststem(lcFile))
		loItem.Project  = This.cProject
		loItem.New      = .T.
		This.oExplorer.AfterNewItem(loItem)
		loItem = This.GetItemForNode()
		This.AssertEquals('A', loItem.VersionControlStatus, ;
			'Did not update status of file')
	endfunc

*******************************************************************************
* Test that creating a binary file to a project with binary only and with
* auto-commit updates status of the file
*******************************************************************************
	function Test_AfterNew_Binary_BinaryOnly_AutoCommit_UpdatesFile
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 1, .T., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.SelectItem('freetable.dbf')
		lcFile = This.cTestDataFolder + 'newtable.dbf'
		create table (lcFile) (field1 c(1))
		use
		loItem          = This.oExplorer.oProject.CreateItem('D')
		loItem.Path     = lcFile
		loItem.ItemName = lower(juststem(lcFile))
		loItem.Project  = This.cProject
		loItem.New      = .T.
		This.oExplorer.cTestCommitMessage = 'commit'
		This.oExplorer.AfterNewItem(loItem)
		loItem = This.GetItemForNode()
		This.AssertEquals('C', loItem.VersionControlStatus, ;
			'Did not update status of file')
	endfunc

*******************************************************************************
* Test that creating a binary file to a project with text only and without
* auto-commit updates status of the file
*******************************************************************************
	function Test_AfterNew_Binary_TextOnly_NoAutoCommit_UpdatesFile
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 2, .F., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('freetable.dbf')
		lcFile = This.cTestDataFolder + 'newtable.dbf'
		create table (lcFile) (field1 c(1))
		use
		loItem          = This.oExplorer.oProject.CreateItem('D')
		loItem.Path     = lcFile
		loItem.ItemName = lower(juststem(lcFile))
		loItem.Project  = This.cProject
		loItem.New      = .T.
		This.oExplorer.AfterNewItem(loItem)
		loItem = This.GetItemForNode()
		This.AssertEquals('A', loItem.VersionControlStatus, ;
			'Did not update status of file')
	endfunc

*******************************************************************************
* Test that creating a binary file to a project with text only and with
* auto-commit updates status of the file
*******************************************************************************
	function Test_AfterNew_Binary_TextOnly_AutoCommit_UpdatesFile
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 2, .T., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.SelectItem('freetable.dbf')
		lcFile = This.cTestDataFolder + 'newtable.dbf'
		create table (lcFile) (field1 c(1))
		use
		loItem          = This.oExplorer.oProject.CreateItem('D')
		loItem.Path     = lcFile
		loItem.ItemName = lower(juststem(lcFile))
		loItem.Project  = This.cProject
		loItem.New      = .T.
		This.oExplorer.cTestCommitMessage = 'commit'
		This.oExplorer.AfterNewItem(loItem)
		loItem = This.GetItemForNode()
		This.AssertEquals('C', loItem.VersionControlStatus, ;
			'Did not update status of file')
	endfunc

*******************************************************************************
* Test that creating a binary file to a project with both and without auto-commit
* updates status of the file
*******************************************************************************
	function Test_AfterNew_Binary_Both_NoAutoCommit_UpdatesFile
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 3, .F., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('freetable.dbf')
		lcFile = This.cTestDataFolder + 'newtable.dbf'
		create table (lcFile) (field1 c(1))
		use
		loItem          = This.oExplorer.oProject.CreateItem('D')
		loItem.Path     = lcFile
		loItem.ItemName = lower(juststem(lcFile))
		loItem.Project  = This.cProject
		loItem.New      = .T.
		This.oExplorer.AfterNewItem(loItem)
		loItem = This.GetItemForNode()
		This.AssertEquals('A', loItem.VersionControlStatus, ;
			'Did not update status of file')
	endfunc

*******************************************************************************
* Test that creating a binary file to a project with both and with auto-commit
* updates status of the file
*******************************************************************************
	function Test_AfterNew_Binary_Both_AutoCommit_UpdatesFile
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 3, .T., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.SelectItem('freetable.dbf')
		lcFile = This.cTestDataFolder + 'newtable.dbf'
		create table (lcFile) (field1 c(1))
		use
		loItem          = This.oExplorer.oProject.CreateItem('D')
		loItem.Path     = lcFile
		loItem.ItemName = lower(juststem(lcFile))
		loItem.Project  = This.cProject
		loItem.New      = .T.
		This.oExplorer.cTestCommitMessage = 'commit'
		This.oExplorer.AfterNewItem(loItem)
		loItem = This.GetItemForNode()
		This.AssertEquals('C', loItem.VersionControlStatus, ;
			'Did not update status of file')
	endfunc

*******************************************************************************
* Test that creating a stored procedures of a DBC with text only and without
* auto-commit updates status of the DBC
*******************************************************************************
	function Test_AfterNew_StoredProc_TextOnly_NoAutoCommit_UpdatesStatus
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 2, .F., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('data.dbc')
		loParent = This.GetItemForNode()
		This.SelectItem('MyProc', 'p')
		open database (This.cTestDataFolder + 'data')
		strtofile('function BlahBlah', This.cTestDataFolder + 'x.txt')
		append procedures from (This.cTestDataFolder + 'x.txt')
		loItem            = This.oExplorer.oProject.CreateItem('p')
		loItem.ParentPath = loParent.Path
		loItem.ParentKey  = loParent.Key
		loItem.Path       = loParent.Path
		loItem.Project    = This.cProject
		loItem.ItemName   = 'blahblah'
		loItem.New        = .T.
		This.oExplorer.AfterNewItem(loItem)
		This.SelectItem('data.dbc')
		loItem = This.GetItemForNode()
		This.AssertEquals('M', loItem.VersionControlStatus, ;
			'Did not update status of DBC')
	endfunc

*******************************************************************************
* Test that creating a stored procedure of a DBC reloads the DBC
*******************************************************************************
	function Test_AfterNew_StoredProc_ReloadsDBC
		This.oExplorer.LoadSolution()
		This.SelectItem('data.dbc')
		loParent = This.GetItemForNode()
		This.SelectItem('MyProc', 'p')
		open database (This.cTestDataFolder + 'data')
		strtofile('function BlahBlah', This.cTestDataFolder + 'x.txt')
		append procedures from (This.cTestDataFolder + 'x.txt')
		loItem            = This.oExplorer.oProject.CreateItem('p')
		loItem.ParentPath = loParent.Path
		loItem.ParentKey  = loParent.Key
		loItem.Path       = loParent.Path
		loItem.Project    = This.cProject
		loItem.ItemName   = 'blahblah'
		loItem.New        = .T.
		This.oExplorer.AfterNewItem(loItem)
		This.SelectItem('BlahBlah', 'p')
		loItem = This.GetItemForNode()
		This.AssertEquals('O', vartype(loItem), ;
			'Did not reload DBC')
	endfunc

*******************************************************************************
* Test that creating a table in a DBC reloads the DBC
*******************************************************************************
	function Test_AfterNew_TableInDBC_ReloadsDBC
		This.oExplorer.LoadSolution()
		This.SelectItem('data.dbc')
		loParent = This.GetItemForNode()
		This.SelectItem('table.dbf', 't')
		open database (This.cTestDataFolder) + 'data'
		lcFile = This.cTestDataFolder + 'newtable.dbf'
		create table (lcFile) (field1 c(1))
		use
		loItem            = This.oExplorer.oProject.CreateItem('t')
		loItem.ParentPath = loParent.Path
		loItem.ParentKey  = loParent.Key
		loItem.Path       = lcFile
		loItem.Project    = This.cProject
		loItem.ItemName   = 'newtable'
		loItem.New        = .T.
		This.oExplorer.AfterNewItem(loItem)
		This.SelectItem('newtable', 't')
		loItem = This.GetItemForNode()
		This.AssertEquals('O', vartype(loItem), ;
			'Did not reload DBC')
	endfunc

*******************************************************************************
* Test that creating a table in a DBC adds it to version control
*******************************************************************************
	function Test_AfterNew_TableInDBC_AddsToVersionControl
		This.oExplorer.LoadSolution()
		This.oExplorer.oSolution.AddVersionControl('MercurialOperations', ;
			'ProjectExplorerEngine.vcx', 2, .F., 'add', 'remove', 'cleanup', ;
			'add vc', 'D:\Development\Tools\Thor\Thor\Tools\Components\FoxBin2Prg\', ;
			This.cTestDataFolder, .T.)
		This.oExplorer.oSolution.CommitAllFiles('message')
		This.SelectItem('data.dbc')
		loParent = This.GetItemForNode()
		This.SelectItem('table.dbf', 't')
		open database (This.cTestDataFolder) + 'data'
		lcFile = This.cTestDataFolder + 'newtable.dbf'
		create table (lcFile) (field1 c(1))
		use
		loItem            = This.oExplorer.oProject.CreateItem('t')
		loItem.ParentPath = loParent.Path
		loItem.ParentKey  = loParent.Key
		loItem.Path       = lcFile
		loItem.Project    = This.cProject
		loItem.ItemName   = 'newtable'
		loItem.New        = .T.
		This.oExplorer.AfterNewItem(loItem)
		This.SelectItem('newtable', 't')
		loItem = This.GetItemForNode()
		This.AssertEquals('A', loItem.VersionControlStatus, ;
			'Did not add file to version control')
	endfunc

*******************************************************************************
* Test that adding a class selects the class
*******************************************************************************
	function Test_AfterNew_Class_SelectsClass
		This.oExplorer.LoadSolution()
		This.SelectItem('classlib.vcx')
		loParent = This.GetItemForNode()
		create class newclass of (This.cTestDataFolder + 'classlib') ;
			as custom nowait
		keyboard '{CTRL+W}'
		doevents
		This.SelectItem('myclass', 'Class')
		loItem                 = This.oExplorer.oProject.CreateItem('Class')
		loItem.ParentKey       = loParent.Key
		loItem.ItemParentClass = 'Custom'
		loItem.Path            = This.cTestDataFolder + 'classlib.vcx'
		loItem.Project         = This.cProject
		loItem.ItemName        = 'newclass'
		loItem.New             = .T.
		This.oExplorer.AfterNewItem(loItem)
		loItem = This.GetItemForNode()
		This.AssertEquals('newclass', loItem.ItemName, ;
			'Did not select new class')
	endfunc

*******************************************************************************
* Test that creating a view reloads the DBC
*******************************************************************************
	function Test_AfterNew_View_ReloadsDBC
		This.oExplorer.LoadSolution()
		This.SelectItem('data.dbc')
		loParent = This.GetItemForNode()
		This.SelectItem('view', 'l')
		open database (This.cTestDataFolder) + 'data'
		create sql view newview as select * from table
		loItem            = This.oExplorer.oProject.CreateItem('l')
		loItem.Path       = loParent.Path
		loItem.ParentPath = loParent.Path
		loItem.ParentKey  = loParent.Key
		loItem.Project    = This.cProject
		loItem.ItemName   = 'newview'
		loItem.New        = .T.
		This.oExplorer.AfterNewItem(loItem)
		loItem = This.GetItemForNode()
		This.AssertEquals('newview', loItem.ItemName, 'Did not reload DBC')
	endfunc
enddefine

*******************************************************************************
Helper classes
*******************************************************************************

define class TestProjectHook as ProjectHook
	function QueryAddFile(tcFileName)
		pcFileName = tcFileName
	endfunc
enddefine
