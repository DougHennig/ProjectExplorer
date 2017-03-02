*******************************************************************************
define class ProjectOperationsTests as FxuTestCase of FxuTestCase.prg
*******************************************************************************
	#IF .f.
	LOCAL THIS AS ProjectOperationsTests OF ProjectOperationsTests.PRG
	#ENDIF
	
	cTestFolder     = ''
	cTestDataFolder = ''
	cTestProgram    = ''
	icTestPrefix    = 'Test_'
	ilAllowDebug    = .T.
	
	oOperations     = .NULL.
	oProject        = .NULL.
	oAddins         = .NULL.
	oItem           = .NULL.
	cFile           = ''

*******************************************************************************
* Setup for the tests
*******************************************************************************
	function Setup

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

		This.oOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx')
		This.oAddins     = createobject('MockAddin')
		This.oProject    = createobject('MockProject')
		This.cFile       = This.cTestDataFolder + sys(2015) + '.txt'
		strtofile('xxx', This.cFile)
		This.oItem = createobject('MockItem')
		This.oItem.Path = This.cFile
	endfunc

*******************************************************************************
* Clean up on exit.
*******************************************************************************
	function TearDown
		erase (This.cFile)
	endfunc

*******************************************************************************
* Test that AddItem fails if an invalid project is passed (this actually tests
* all the ways it can fail in one test)
*******************************************************************************
	function Test_AddItem_Fails_InvalidProject
		loFile = This.oOperations.AddItem()
		This.AssertTrue(vartype(loFile) <> 'O', 'Returned file when no project passed')
		loFile = This.oOperations.AddItem(5)
		This.AssertTrue(vartype(loFile) <> 'O', 'Returned file when no project object passed')
	endfunc

*******************************************************************************
* Test that AddItem fails if an invalid file is passed (this actually tests all
* the ways it can fail in one test)
*******************************************************************************
	function Test_AddItem_Fails_InvalidFile
		loFile = This.oOperations.AddItem(This.oProject)
		This.AssertTrue(vartype(loFile) <> 'O', 'Returned file when no file passed')
		loFile = This.oOperations.AddItem(This.oProject, 5)
		This.AssertTrue(vartype(loFile) <> 'O', 'Returned file when non-char passed')
		loFile = This.oOperations.AddItem(This.oProject, '')
		This.AssertTrue(vartype(loFile) <> 'O', 'Returned file when empty passed')
		loFile = This.oOperations.AddItem(This.oProject, 'xxx.txt')
		This.AssertTrue(vartype(loFile) <> 'O', 'Returned file when non-existent file passed')
	endfunc

*******************************************************************************
* Test that AddItem adds a file to the collection
*******************************************************************************
	function Test_AddItem_AddsFile
		This.oOperations.AddItem(This.oProject, This.cFile)
		This.AssertTrue(This.oProject.Files.Count = 1, ;
			'File not added')
	endfunc

*******************************************************************************
* Test that AddItem returns the added file
*******************************************************************************
	function Test_AddItem_AddsFile
		loFile = This.oOperations.AddItem(This.oProject, This.cFile)
		This.AssertNotNull(loFile, 'File not returned')
	endfunc

*******************************************************************************
* Test that AddItem calls the BeforeAddItem addin
*******************************************************************************
	function Test_AddItem_CallsBeforeAddItem
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
		loOperations.AddItem(This.oProject, This.cFile)
		llAddin = ascan(This.oAddins.aMethods, 'BeforeAddItem') > 0
		This.AssertTrue(llAddin, ;
			'Did not call BeforeAddItem')
	endfunc

*******************************************************************************
* Test that AddItem calls the AfterAddItem addin
*******************************************************************************
	function Test_AddItem_CallsAfterAddItem
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
		loOperations.AddItem(This.oProject, This.cFile)
		llAddin = ascan(This.oAddins.aMethods, 'AfterAddItem') > 0
		This.AssertTrue(llAddin, ;
			'Did not call AfterAddItem ')
	endfunc

*******************************************************************************
* Test that AddItem fails if the BeforeAddItem addin returns .F.
*******************************************************************************
	function Test_AddItem_Fails_IfBeforeAddItem
		This.oAddins.lValueToReturn = .F.
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
		loFile = loOperations.AddItem(This.oProject, This.cFile)
		This.AssertTrue(vartype(loFile) <> 'O', 'Added file')
	endfunc

*******************************************************************************
* Test that RemoveItem fails if an invalid project is passed
*******************************************************************************
	function Test_RemoveItem_Fails_InvalidProject
		llOK = This.oOperations.RemoveItem()
		This.AssertFalse(llOK, 'Returned .T. when no project passed')
	endfunc

*******************************************************************************
* Test that RemoveItem fails if an invalid file is passed
*******************************************************************************
	function Test_RemoveItem_Fails_InvalidFile
		llOK = This.oOperations.RemoveItem(This.oProject)
		This.AssertFalse(llOK, 'Returned .T. when no file passed')
	endfunc

*******************************************************************************
* Test that RemoveItem fails if the item can't be removed
*******************************************************************************
	function Test_RemoveItem_Fails_CantRemoveItem
		This.oOperations.AddItem(This.oProject, This.cFile)
		This.oItem.CanRemove = .F.
		llOK = This.oOperations.RemoveItem(This.oProject, This.oItem)
		This.AssertFalse(llOK, 'Returned .T. when item cannot be removed')
	endfunc

*******************************************************************************
* Test that RemoveItem returns .T. when it removes the item
*******************************************************************************
	function Test_RemoveItem_ReturnsTrue
		This.oOperations.AddItem(This.oProject, This.cFile)
		llOK = This.oOperations.RemoveItem(This.oProject, This.oItem)
		This.AssertTrue(llOK, 'Returned .F. when item removed')
	endfunc

*******************************************************************************
* Test that RemoveItem removes item from collection
*******************************************************************************
	function Test_RemoveItem_RemovesItem
		This.oOperations.AddItem(This.oProject, This.cFile)
		This.oOperations.RemoveItem(This.oProject, This.oItem)
		This.AssertTrue(This.oProject.Files.Count = 0, 'Did not remove item')
	endfunc

*******************************************************************************
* Test that RemoveItem tells the project to delete the file
*******************************************************************************
	function Test_RemoveItem_DeletesFile
		loFile = This.oOperations.AddItem(This.oProject, This.cFile)
		This.oOperations.RemoveItem(This.oProject, This.oItem, .T.)
		This.AssertTrue(loFile.lDeleteFile, 'Did not delete file')
	endfunc

*******************************************************************************
* Test that RemoveItem deletes a class
*******************************************************************************
	function Test_RemoveItem_DeletesClass

* Create a class in a class library.

		text to lcXML noshow
<?xml version = "1.0" encoding="Windows-1252" standalone="yes"?>
<VFPData>
	<test>
		<platform>COMMENT</platform>
		<uniqueid>Class</uniqueid>
		<timestamp>0</timestamp>
		<class/>
		<classloc/>
		<baseclass/>
		<objname/>
		<parent/>
		<properties/>
		<protected/>
		<methods/>
		<objcode/>
		<ole/>
		<ole2/>
		<reserved1>VERSION =   3.00</reserved1>
		<reserved2/>
		<reserved3/>
		<reserved4/>
		<reserved5/>
		<reserved6/>
		<reserved7/>
		<reserved8/>
		<user/>
	</test>
	<test>
		<platform>WINDOWS</platform>
		<uniqueid>_4UZ0SGY1D</uniqueid>
		<timestamp>1247898146</timestamp>
		<class>custom</class>
		<classloc/>
		<baseclass>custom</baseclass>
		<objname>test</objname>
		<parent/>
		<properties>Name = "test"
</properties>
		<protected/>
		<methods/>
		<objcode/>
		<ole/>
		<ole2/>
		<reserved1>Class</reserved1>
		<reserved2>1</reserved2>
		<reserved3/>
		<reserved4/>
		<reserved5/>
		<reserved6>Pixels</reserved6>
		<reserved7/>
		<reserved8/>
		<user/>
	</test>
	<test>
		<platform>COMMENT</platform>
		<uniqueid>RESERVED</uniqueid>
		<timestamp>0</timestamp>
		<class/>
		<classloc/>
		<baseclass/>
		<objname>test</objname>
		<parent/>
		<properties/>
		<protected/>
		<methods/>
		<objcode/>
		<ole/>
		<ole2/>
		<reserved1/>
		<reserved2/>
		<reserved3/>
		<reserved4/>
		<reserved5/>
		<reserved6/>
		<reserved7/>
		<reserved8/>
		<user/>
	</test>
</VFPData>
		endtext
		lcCursor = sys(2015)
		select * from Source\ProjectExplorerMenu.vcx into cursor (lcCursor) nofilter readwrite
		delete all
		xmltocursor(lcXML, lcCursor, 8192)
		copy to (This.cTestDataFolder + 'test.vcx')
		use
		use in ProjectExplorerMenu

* Do the test.

		This.oOperations.AddItem(This.oProject, This.cTestDataFolder + 'test.vcx')
		This.oItem.Path     = This.cTestDataFolder + 'test.vcx'
		This.oItem.Type     = 'Class'
		This.oItem.ItemName = 'test'
		This.oItem.IsFile   = .F.
		This.oOperations.RemoveItem(This.oProject, This.oItem)
		use (This.cTestDataFolder + 'test.vcx')
		locate for OBJNAME = 'test'
		llOK = not found()
		use
		erase (This.cTestDataFolder + 'test.vcx')
		erase (This.cTestDataFolder + 'test.vct')
		This.AssertTrue(llOK, 'Did not delete class')
	endfunc

*******************************************************************************
* Test that RemoveItem removes a table in a DBC.
*******************************************************************************
	function Test_RemoveItem_RemovesTable

* Create a table in a database.

		create database (This.cTestDataFolder + 'test')
		create table (This.cTestDataFolder + 'test') (field1 c(1))
		close databases

* Do the test.

		This.oOperations.AddItem(This.oProject, This.cTestDataFolder + 'test.dbc')
		This.oItem.ParentPath = This.cTestDataFolder + 'test.dbc'
		This.oItem.Path       = This.cTestDataFolder + 'test.dbf'
		This.oItem.Type       = 't'
		This.oItem.ItemName   = 'test'
		This.oItem.IsFile     = .F.
		This.oOperations.RemoveItem(This.oProject, This.oItem)
		llOK = not indbc('test', 'Table')
		close databases
		erase (This.cTestDataFolder + 'test.dbc')
		erase (This.cTestDataFolder + 'test.dct')
		erase (This.cTestDataFolder + 'test.dcx')
		erase (This.cTestDataFolder + 'test.dbf')
		This.AssertTrue(llOK, 'Did not remove table')
	endfunc

*******************************************************************************
* Test that RemoveItem deletes a table in a DBC.
*******************************************************************************
	function Test_RemoveItem_DeletesTable

* Create a table in a database.

		create database (This.cTestDataFolder + 'test')
		create table (This.cTestDataFolder + 'test') (field1 c(1))
		close databases

* Do the test.

		This.oOperations.AddItem(This.oProject, This.cTestDataFolder + 'test.dbc')
		This.oItem.ParentPath = This.cTestDataFolder + 'test.dbc'
		This.oItem.Path       = This.cTestDataFolder + 'test.dbf'
		This.oItem.Type       = 't'
		This.oItem.ItemName   = 'test'
		This.oItem.IsFile     = .F.
		This.oOperations.RemoveItem(This.oProject, This.oItem, .T.)
		close databases
		llOK = not file(This.cTestDataFolder + 'test.dbf')
		erase (This.cTestDataFolder + 'test.dbc')
		erase (This.cTestDataFolder + 'test.dct')
		erase (This.cTestDataFolder + 'test.dcx')
		This.AssertTrue(llOK, 'Did not delete table')
	endfunc

*******************************************************************************
* Test that RemoveItem removes a local view.
*******************************************************************************
	function Test_RemoveItem_RemovesLocalView

* Create a table and a view in a database.

		create database (This.cTestDataFolder + 'test')
		create table (This.cTestDataFolder + 'test') (field1 c(1))
		create view testview as select * from test
		close databases

* Do the test.

		This.oOperations.AddItem(This.oProject, This.cTestDataFolder + 'test.dbc')
		This.oItem.ParentPath = This.cTestDataFolder + 'test.dbc'
		This.oItem.Type       = 'LocalView'
		This.oItem.ItemName   = 'testview'
		This.oItem.IsFile     = .F.
		This.oOperations.RemoveItem(This.oProject, This.oItem)
		llOK = not indbc('testview', 'View')
		close databases
		erase (This.cTestDataFolder + 'test.dbc')
		erase (This.cTestDataFolder + 'test.dct')
		erase (This.cTestDataFolder + 'test.dcx')
		erase (This.cTestDataFolder + 'test.dbf')
		This.AssertTrue(llOK, 'Did not remove view')
	endfunc

*******************************************************************************
* Test that RemoveItem removes a remote view.
*******************************************************************************
	function Test_RemoveItem_RemovesRemoteView

* Create a view in a database.

		create database (This.cTestDataFolder + 'test')
		create view testview connection 'Northwind SQL' as select * from customers
		close databases

* Do the test.

		This.oOperations.AddItem(This.oProject, This.cTestDataFolder + 'test.dbc')
		This.oItem.ParentPath = This.cTestDataFolder + 'test.dbc'
		This.oItem.Type       = 'RemoteView'
		This.oItem.ItemName   = 'testview'
		This.oItem.IsFile     = .F.
		This.oOperations.RemoveItem(This.oProject, This.oItem)
		llOK = not indbc('testview', 'View')
		close databases
		erase (This.cTestDataFolder + 'test.dbc')
		erase (This.cTestDataFolder + 'test.dct')
		erase (This.cTestDataFolder + 'test.dcx')
		This.AssertTrue(llOK, 'Did not remove view')
	endfunc

*******************************************************************************
* Test that RemoveItem removes a connection.
*******************************************************************************
	function Test_RemoveItem_RemovesConnection

* Create a view in a database.

		create database (This.cTestDataFolder + 'test')
		create connection testconn datasource 'Northwind SQL'
		close databases

* Do the test.

		This.oOperations.AddItem(This.oProject, This.cTestDataFolder + 'test.dbc')
		This.oItem.ParentPath = This.cTestDataFolder + 'test.dbc'
		This.oItem.Type       = 'Connection'
		This.oItem.ItemName   = 'testconn'
		This.oItem.IsFile     = .F.
		This.oOperations.RemoveItem(This.oProject, This.oItem)
		llOK = not indbc('testconn', 'Connection')
		close databases
		erase (This.cTestDataFolder + 'test.dbc')
		erase (This.cTestDataFolder + 'test.dct')
		erase (This.cTestDataFolder + 'test.dcx')
		This.AssertTrue(llOK, 'Did not remove connection')
	endfunc

*******************************************************************************
* Test that RemoveItem calls the BeforeRemoveItem addin
*******************************************************************************
	function Test_RemoveItem_CallsBeforeRemoveItem
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
		loOperations.AddItem(This.oProject, This.cFile)
		loOperations.RemoveItem(This.oProject, This.oItem)
		llAddin = ascan(This.oAddins.aMethods, 'BeforeRemoveItem') > 0
		This.AssertTrue(llAddin, ;
			'Did not call BeforeRemoveItem')
	endfunc

*******************************************************************************
* Test that RemoveItem calls the AfterRemoveItem addin
*******************************************************************************
	function Test_RemoveItem_CallsAfterRemoveItem
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
		loOperations.AddItem(This.oProject, This.cFile)
		loOperations.RemoveItem(This.oProject, This.oItem)
		llAddin = ascan(This.oAddins.aMethods, 'AfterRemoveItem') > 0
		This.AssertTrue(llAddin, ;
			'Did not call AfterRemoveItem')
	endfunc

*******************************************************************************
* Test that RemoveItem fails if the BeforeRemoveItem addin returns .F.
*******************************************************************************
	function Test_RemoveItem_Fails_IfBeforeRemoveItem
		This.oAddins.lValueToReturn = .F.
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
		loOperations.AddItem(This.oProject, This.cFile)
		llOK = loOperations.RemoveItem(This.oProject, This.oItem)
		This.AssertFalse(llOK, 'Removed file')
	endfunc

*******************************************************************************
* Test that BuildProject fails if an invalid project is passed
*******************************************************************************
	function Test_BuildProject_Fails_InvalidProject
		llOK = This.oOperations.BuildProject()
		This.AssertFalse(llOK, 'Returned .T. when no project passed')
	endfunc

*******************************************************************************
* Test that BuildProject calls project Build
*******************************************************************************
	function Test_BuildProject_CallsBuild
		This.oOperations.BuildProject(This.oProject)
		This.AssertTrue(This.oProject.lBuildCalled, ;
			'Did not call Build')
	endfunc

*******************************************************************************
* Test that BuildProject calls the BeforeBuildProject addin
*******************************************************************************
	function Test_BuildProject_CallsBeforeBuildProject
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
		loOperations.BuildProject(This.oProject)
		llAddin = ascan(This.oAddins.aMethods, 'BeforeBuildProject') > 0
		This.AssertTrue(llAddin, ;
			'Did not call BeforeBuildProject')
	endfunc

*******************************************************************************
* Test that BuildProject calls the AfterBuildProject addin
*******************************************************************************
	function Test_BuildProject_CallsAfterBuildProject
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
		loOperations.BuildProject(This.oProject)
		llAddin = ascan(This.oAddins.aMethods, 'AfterBuildProject') > 0
		This.AssertTrue(llAddin, ;
			'Did not call AfterBuildProject')
	endfunc

*******************************************************************************
* Test that BuildProject fails if the BeforeBuildProject addin returns .F.
*******************************************************************************
	function Test_BuildProject_Fails_IfBeforeBuildProject
		This.oAddins.lValueToReturn = .F.
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
		llOK = loOperations.BuildProject(This.oProject)
		This.AssertFalse(llOK, 'Built project')
	endfunc

*******************************************************************************
* Test that EditItem fails if an invalid project is passed
*******************************************************************************
	function Test_EditItem_Fails_InvalidProject
		llOK = This.oOperations.EditItem()
		This.AssertFalse(llOK, 'Returned .T. when no project passed')
	endfunc

*******************************************************************************
* Test that EditItem fails if an invalid file is passed
*******************************************************************************
	function Test_EditItem_Fails_InvalidFile
		llOK = This.oOperations.EditItem(This.oProject)
		This.AssertFalse(llOK, 'Returned .T. when no file passed')
	endfunc

*******************************************************************************
* Test that EditItem fails if the item can't be edited
*******************************************************************************
	function Test_EditItem_Fails_CantEditItem
		This.oOperations.AddItem(This.oProject, This.cFile)
		This.oItem.CanEdit = .F.
		llOK = This.oOperations.EditItem(This.oProject, This.oItem)
		This.AssertFalse(llOK, 'Returned .T. when item cannot be edited')
	endfunc

*******************************************************************************
* Test that EditItem returns .T. when it edits the item
*******************************************************************************
	function Test_EditItem_ReturnsTrue
		This.oOperations.AddItem(This.oProject, This.cFile)
		llOK = This.oOperations.EditItem(This.oProject, This.oItem)
		This.AssertTrue(llOK, 'Returned .F. when item edited')
	endfunc

*** TODO: tests for V, Z, image, t, Field, Index, view, connection, sproc. For
*** V and image check that QueryModifyFile of projecthook called. This will be
*** doable once there are individual classes for each type: can then subclass
*** them here and override EditItem method to do nothing.

*******************************************************************************
* Test that EditItem calls Modify for a file
*******************************************************************************
	function Test_EditItem_CallsModifyForFile
		This.oOperations.AddItem(This.oProject, This.cFile)
		This.oOperations.EditItem(This.oProject, This.oItem)
		loItem = This.oProject.Files.Item(1)
		This.AssertTrue(loItem.lModifyCalled, 'Did not call Modify')
	endfunc

*******************************************************************************
* Test that EditItem calls Modify for a class
*******************************************************************************
	function Test_EditItem_CallsModifyForClass
		This.oOperations.AddItem(This.oProject, This.cFile)
		This.oItem.IsFile   = .F.
		This.oItem.ItemName = 'test'
		This.oItem.Path     = This.cFile
		This.oItem.Type     = 'Class'
		This.oOperations.EditItem(This.oProject, This.oItem)
		loItem = This.oProject.Files.Item(1)
		This.AssertTrue(loItem.lModifyCalled, 'Did not call Modify')
		This.AssertEquals('test', loItem.cClass, 'Did not pass class to Modify')
	endfunc

*******************************************************************************
* Test that EditItem calls the BeforeModifyItem addin
*******************************************************************************
	function Test_EditItem_CallsBeforeModifyItem
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
		loOperations.EditItem(This.oProject, This.oItem)
		llAddin = ascan(This.oAddins.aMethods, 'BeforeModifyItem') > 0
		This.AssertTrue(llAddin, ;
			'Did not call BeforeModifyItem')
	endfunc

*******************************************************************************
* Test that EditItem fails if the BeforeModifyItem addin returns .F.
*******************************************************************************
	function Test_EditItem_Fails_IfBeforeModifyItem
		This.oAddins.lValueToReturn = .F.
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
		llOK = loOperations.EditItem(This.oProject, This.oItem)
		This.AssertFalse(llOK, 'Edited item')
	endfunc

*******************************************************************************
* Test that RunItem fails if an invalid project is passed
*******************************************************************************
	function Test_RunItem_Fails_InvalidProject
		llOK = This.oOperations.RunItem()
		This.AssertFalse(llOK, 'Returned .T. when no project passed')
	endfunc

*******************************************************************************
* Test that RunItem fails if an invalid file is passed
*******************************************************************************
	function Test_RunItem_Fails_InvalidFile
		llOK = This.oOperations.RunItem(This.oProject)
		This.AssertFalse(llOK, 'Returned .T. when no file passed')
	endfunc

*******************************************************************************
* Test that RunItem fails if the item can't be run
*******************************************************************************
	function Test_RunItem_Fails_CantRuntem
		This.oOperations.AddItem(This.oProject, This.cFile)
		This.oItem.CanRun = .F.
		llOK = This.oOperations.RunItem(This.oProject, This.oItem)
		This.AssertFalse(llOK, 'Returned .T. when item cannot be run')
	endfunc

*******************************************************************************
* Test that RunItem returns .T. when it runs the item
*******************************************************************************
	function Test_RunItem_ReturnsTrue
		This.oOperations.AddItem(This.oProject, This.cFile)
		llOK = This.oOperations.RunItem(This.oProject, This.oItem)
		This.AssertTrue(llOK, 'Returned .F. when item run')
	endfunc

*** TODO: tests for P, Q, Z, L, M, D, t, Field, Index, view. This will be
*** doable once there are individual classes for each type: can then subclass
*** them here and override RunItem method to do nothing.

*******************************************************************************
* Test that RunItem calls Run for a file
*******************************************************************************
	function Test_RunItem_CallsRunForFile
		This.oOperations.AddItem(This.oProject, This.cFile)
		This.oOperations.RunItem(This.oProject, This.oItem)
		loItem = This.oProject.Files.Item(1)
		This.AssertTrue(loItem.lRunCalled, 'Did not call Run')
	endfunc

*******************************************************************************
* Test that RunItem calls the BeforeRunItem addin
*******************************************************************************
	function Test_RunItem_CallsBeforeRunItem
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
		loOperations.RunItem(This.oProject, This.oItem)
		llAddin = ascan(This.oAddins.aMethods, 'BeforeRunItem') > 0
		This.AssertTrue(llAddin, ;
			'Did not call BeforeRunItem')
	endfunc

*******************************************************************************
* Test that RunItem calls the AfterRunItem addin
*******************************************************************************
	function Test_RunItem_CallsAfterRunItem
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
		loOperations.RunItem(This.oProject, This.oItem)
		llAddin = ascan(This.oAddins.aMethods, 'AfterRunItem') > 0
		This.AssertTrue(llAddin, ;
			'Did not call AfterRunItem')
	endfunc

*******************************************************************************
* Test that RunItem fails if the BeforeRunItem addin returns .F.
*******************************************************************************
	function Test_RunItem_Fails_IfBeforeModifyItem
		This.oAddins.lValueToReturn = .F.
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
		llOK = loOperations.RunItem(This.oProject, This.oItem)
		This.AssertFalse(llOK, 'Ran item')
	endfunc
enddefine

*******************************************************************************
* Mock classes
*******************************************************************************
define class MockProject as Custom
	Files        = .NULL.
	lBuildCalled = .F.
	ProjectHook  = .NULL.
	
	function Init
		This.Files = createobject('MockFileCollection')
	endfunc

	function Build(tcOutputName, tnBuildAction, tlRebuildAll, ;
		tlShowErrors, tlBuildNewGUIDs)
		This.lBuildCalled = .T.
	endfunc
enddefine

define class MockFileCollection as Collection
	function Add(tcFile)
		loFile = createobject('MockFile')
		loFile.cFile       = tcFile
		loFile.oCollection = This
		dodefault(loFile, tcFile)
		nodefault
		return loFile
	endfunc
enddefine

define class MockFile as Custom
	cFile         = ''
	oCollection   = .NULL.
	lModifyCalled = .T.
	lRunCalled    = .T.
	lDeleteFile   = .F.
	cClass        = ''

	function Release
		This.oCollection = .NULL.
	endfunc

	function Remove(tlDelete)
		This.oCollection.Remove(This.cFile)
		This.oCollection = .NULL.
		This.lDeleteFile = tlDelete
	endfunc

	function Modify(tcClass)
		This.lModifyCalled = .T.
		This.cClass        = tcClass
	endfunc

	function Run
		This.lRunCalled = .T.
	endfunc
enddefine

define class MockAddin as Custom
	dimension aMethods[1]
	lValueToReturn = .T.

	function ExecuteAddin(tcMethod, tuParameter1, tuParameter2)
		if empty(This.aMethods[1])
			lnMethods = 1
		else
			lnMethods = alen(This.aMethods) + 1
			dimension This.aMethods[lnMethods]
		endif empty(This.aMethods[1])
		This.aMethods[lnMethods] = tcMethod
		return This.lValueToReturn
	endfunc
enddefine

define class MockItem as Custom
	Type       = ''
	Path       = ''
	ItemName   = ''
	ParentPath = ''
	IsFile     = .T.
	CanEdit    = .T.
	CanRemove  = .T.
	CanRun     = .T.
enddefine

define class MockProjectHook as Custom
	cFile = ''

	function QueryModifyFile(toFile)
		This.cFile = toFile.cFile
	endfunc
enddefine
