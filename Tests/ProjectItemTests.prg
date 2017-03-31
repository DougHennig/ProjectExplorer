* This is used in Test_EditItem_CallsClassBrowserForClasslib

lparameters tcFileName
public plClassBrowserCalled
plClassBrowserCalled = .T.

*******************************************************************************
define class ProjectItemTests as FxuTestCase of FxuTestCase.prg
*******************************************************************************
	#IF .f.
	LOCAL THIS AS ProjectItemTests OF ProjectItemTests.PRG
	#ENDIF
	
	cTestFolder     = ''
	cTestDataFolder = ''
	cTestProgram    = ''
	icTestPrefix    = 'Test_'
	
	oItem           = .NULL.
	oProject        = .NULL.
	cCurrPath       = ''
	cFile           = ''
	lExecuteFileCalled    = .F.
	cExecuteFileOperation = ''
	dimension aTypes[1]

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

		This.oItem = newobject('ProjectItem', ;
			'Source\ProjectExplorerItems.vcx')

* This array defines the different types of items and what the expected
* capability is: column 2 is whether it's a file, column 3 is whether it can be
* edited, column 4 is whether it can be included in the project, column 5 is
* whether it can be removed, column 6 is whether it can be run, column 7 is
* whether it can be the main file, column 8 is whether it can be renamed,
* column 9 is whether the item has a description, column 10 is whether the item
* has children, column 11 is whether it needs to be reloaded after editing,
* column 12 is whether the item has a parent, column 13 is whether the item has
* User info or not

		dimension This.aTypes[21, 13]
		This.aTypes[ 1, 1] = 'ProjectItemApplication'
		This.aTypes[ 2, 1] = 'ProjectItemClass'
		This.aTypes[ 3, 1] = 'ProjectItemClasslib'
		This.aTypes[ 4, 1] = 'ProjectItemConnection'
		This.aTypes[ 5, 1] = 'ProjectItemDatabase'
		This.aTypes[ 6, 1] = 'ProjectItemField'
		This.aTypes[ 7, 1] = 'ProjectItemForm'
		This.aTypes[ 8, 1] = 'ProjectItemFreeTable'
		This.aTypes[ 9, 1] = 'ProjectItemIndex'
		This.aTypes[10, 1] = 'ProjectItemLabel'
		This.aTypes[11, 1] = 'ProjectItemLibrary'
		This.aTypes[12, 1] = 'ProjectItemLocalView'
		This.aTypes[13, 1] = 'ProjectItemMenu'
		This.aTypes[14, 1] = 'ProjectItemOther'
		This.aTypes[15, 1] = 'ProjectItemProgram'
		This.aTypes[16, 1] = 'ProjectItemQuery'
		This.aTypes[17, 1] = 'ProjectItemRemoteView'
		This.aTypes[18, 1] = 'ProjectItemReport'
		This.aTypes[19, 1] = 'ProjectItemStoredProc'
		This.aTypes[20, 1] = 'ProjectItemTableInDBC'
		This.aTypes[21, 1] = 'ProjectItemText'
		for lnI = 1 to alen(This.aTypes, 1)
			lcType = This.aTypes[lnI, 1]
			This.aTypes[lnI, 2] = lcType == 'ProjectItemClasslib' or ;
				not inlist(lcType, 'ProjectItemClass', ;
				'ProjectItemConnection', 'ProjectItemField', ;
				'ProjectItemIndex', 'ProjectItemLocalView', ;
				'ProjectItemRemoteView', 'ProjectItemStoredProc')
				&& everything but these is a file
			This.aTypes[lnI, 3] = lcType <> 'ProjectItemLibrary'
				&& can edit anything but an API library, although there are
				&& special cases for Other and Application
			This.aTypes[lnI, 4] = not inlist(lcType, 'ProjectItemLibrary', ;
				'ProjectItemApplication') and This.aTypes[lnI, 2]
				&& can include any file except API library and application
			This.aTypes[lnI, 5] = This.aTypes[lnI, 2] or ;
				inlist(lcType, 'ProjectItemClass', 'ProjectItemConnection', ;
				'ProjectItemLocalView', 'ProjectItemRemoteView', ;
				'ProjectItemTableInDBC')
				&& can remove any file plus these items
			This.aTypes[lnI, 6] = inlist(lcType, 'ProjectItemApplication', ;
				'ProjectItemField', 'ProjectItemForm', ;
				'ProjectItemFreeTable', 'ProjectItemIndex', ;
				'ProjectItemLabel', 'ProjectItemLocalView', ;
				'ProjectItemMenu', 'ProjectItemProgram', ;
				'ProjectItemQuery', 'ProjectItemRemoteView', ;
				'ProjectItemReport', 'ProjectItemTableInDBC')
				&& can run forms, programs, reports, labels, free tables,
				&& tables in a DBC, fields, indexes, views, queries, menus, and
				&& applications
			This.aTypes[lnI, 7] = inlist(lcType, 'ProjectItemProgram', ;
				'ProjectItemForm')
				&& can set programs and forms as main
			This.aTypes[lnI, 8] = This.aTypes[lnI, 2] or ;
				inlist(lcType, 'ProjectItemClass', 'ProjectItemConnection', ;
				'ProjectItemLocalView', 'ProjectItemRemoteView', ;
				'ProjectItemTableInDBC')
				&& can rename any file plus these items
			This.aTypes[lnI, 9] = This.aTypes[lnI, 2] or ;
				not inlist(lcType, 'ProjectItemField', 'ProjectItemIndex', ;
				'ProjectItemStoredProc')
				&& any file plus all items except these has a description
			This.aTypes[lnI, 10] = inlist(lcType, 'ProjectItemFreeTable', ;
				'ProjectItemTableInDBC', 'ProjectItemLocalView', ;
				'ProjectItemRemoteView', 'ProjectItemClasslib', ;
				'ProjectItemDatabase')
				&& these types have children
			This.aTypes[lnI, 11] = inlist(lcType, 'ProjectItemFreeTable', ;
				'ProjectItemDatabase')
				&& these types have to be reloaded after editing
			This.aTypes[lnI, 12] = lcType == 'ProjectItemClass' or ;
				inlist(lcType, 'ProjectItemRemoteView', ;
				'ProjectItemConnection', 'ProjectItemField', ;
				'ProjectItemIndex', 'ProjectItemStoredProc', ;
				'ProjectItemTableInDBC', 'ProjectItemLocalView')
				&& these types have a parent
			This.aTypes[lnI, 13] = lcType == 'ProjectItemClass' or ;
				(This.aTypes[lnI, 2] and lcType <> 'ProjectItemTableInDBC')
				&& all file types except table in a DBC plus class have User
		next lnI

* Create a project and a file.

		This.oProject = createobject('MockProject')
		This.cFile    = This.cTestDataFolder + sys(2015) + '.txt'
		strtofile('xxx', This.cFile)

* Save the current path and set it.

		This.cCurrPath = set('PATH')
		set path to 'Source' additive
	endfunc

*******************************************************************************
* Clean up on exit.
*******************************************************************************
	function TearDown
		set path to (This.cCurrPath)
		erase (This.cFile)
	endfunc

*******************************************************************************
* Helper method to bind to ExecuteFile
*******************************************************************************
	function ExecuteFileCalled(tcFileName, tcOperation)
		This.cExecuteFileOperation = tcOperation
		This.lExecuteFileCalled    = .T.
	endfunc

*******************************************************************************
* Test that ProjectItem has a Tags collection
*******************************************************************************
	function Test_Init_CreatesTags
		This.AssertTrue(vartype(This.oItem.Tags) = 'O', ;
			'Did not create Tags collection')
	endfunc

*******************************************************************************
* Test that SaveTagString saves tags
*******************************************************************************
	function Test_SaveTagString_SavesTags
		This.oItem.SaveTagString('tag1' + chr(13) + 'tag2')
		This.AssertTrue(This.oItem.Tags.Count = 2, ;
			'Did not save tags')
	endfunc

*******************************************************************************
* Test that SaveTagString only saves last tags
*******************************************************************************
	function Test_SaveTagString_OnlySavesLastTags
		This.oItem.SaveTagString('tag1' + chr(13) + 'tag2')
		This.oItem.SaveTagString('tag3' + chr(13) + 'tag4')
		This.AssertTrue(This.oItem.Tags.Count = 2, ;
			'Added to previous tags')
	endfunc

*******************************************************************************
* Test that GetTagString returns blank when no tags
*******************************************************************************
	function Test_GetTagString_ReturnsBlank_NoTags
		lcTags = This.oItem.GetTagString()
		This.AssertTrue(empty(lcTags), ;
			'Returned non-blank')
	endfunc

*******************************************************************************
* Test that GetTagString returns tags
*******************************************************************************
	function Test_GetTagString_ReturnsTags
		lcSource = 'tag1' + chr(13) + chr(10) + 'tag2' + chr(13) + chr(10)
		This.oItem.SaveTagString(lcSource)
		lcTags = This.oItem.GetTagString()
		This.AssertEquals(lcTags, lcSource, ;
			'Did not return correct tags')
	endfunc

*******************************************************************************
* Test that GetTagString returns tags comma-delimited
*******************************************************************************
	function Test_GetTagString_ReturnsTagsCommaDelimited
		lcSource = 'tag1' + chr(13) + 'tag2'
		This.oItem.SaveTagString(lcSource)
		lcTags = This.oItem.GetTagString(.T.)
		This.AssertEquals(lcTags, strtran(lcSource, chr(13), ','), ;
			'Did not return correct tags')
	endfunc

*******************************************************************************
* Test that IsFile is set the way it's supposed to be
*******************************************************************************
	function Test_IsFile_Correct
		for lnI = 1 to alen(This.aTypes, 1)
			loItem = newobject(This.aTypes[lnI, 1], ;
				'Source\ProjectExplorerItems.vcx')
			This.AssertEquals(This.aTypes[lnI, 2], loItem.IsFile, ;
				'IsFile not correct for ' + This.aTypes[lnI, 1])
		next lnI
	endfunc

*******************************************************************************
* Test that CanEdit is set the way it's supposed to be
*******************************************************************************
	function Test_CanEdit_Correct
		for lnI = 1 to alen(This.aTypes, 1)
			loItem = newobject(This.aTypes[lnI, 1], ;
				'Source\ProjectExplorerItems.vcx')
			do case
				case This.aTypes[lnI, 1] = 'ProjectItemApplication'
					loItem.Path = This.cTestDataFolder + sys(2015) + '.pjx'
					strtofile('x', loItem.Path)
				case This.aTypes[lnI, 1] = 'ProjectItemOther'
					loItem.Path = This.cTestDataFolder + sys(2015) + '.bmp'
					strtofile('x', loItem.Path)
			endcase
			llCanEdit = loItem.CanEdit
			if not empty(loItem.Path)
				erase (loItem.Path)
			endif not empty(loItem.Path)
			This.AssertEquals(This.aTypes[lnI, 3], llCanEdit, ;
				'CanEdit not correct for ' + This.aTypes[lnI, 1])
		next lnI
	endfunc

*******************************************************************************
* Test that CanEdit is set the way it's supposed to be for non-existent project
*******************************************************************************
	function Test_CanEdit_Correct_NonExistentProject
		loItem = newobject('ProjectItemApplication', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.Path = This.cTestDataFolder + sys(2015) + '.pjx'
		This.AssertFalse(loItem.CanEdit, ;
			'CanEdit not correct when no project for ProjectItemApplication')
	endfunc

*******************************************************************************
* Test that CanEdit is set the way it's supposed to be for non-image
*******************************************************************************
	function Test_CanEdit_Correct_NonImage
		loItem = newobject('ProjectItemOther', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.Path = This.cTestDataFolder + sys(2015) + '.xxx'
		This.AssertFalse(loItem.CanEdit, ;
			'CanEdit not correct when not image for ProjectItemOther')
	endfunc

*******************************************************************************
* Test that CanInclude is set the way it's supposed to be
*******************************************************************************
	function Test_CanInclude_Correct
		for lnI = 1 to alen(This.aTypes, 1)
			loItem = newobject(This.aTypes[lnI, 1], ;
				'Source\ProjectExplorerItems.vcx')
			This.AssertEquals(This.aTypes[lnI, 4], loItem.CanInclude, ;
				'CanInclude not correct for ' + This.aTypes[lnI, 1])
		next lnI
	endfunc

*******************************************************************************
* Test that CanRemove is set the way it's supposed to be
*******************************************************************************
	function Test_CanRemove_Correct
		for lnI = 1 to alen(This.aTypes, 1)
			loItem = newobject(This.aTypes[lnI, 1], ;
				'Source\ProjectExplorerItems.vcx')
			This.AssertEquals(This.aTypes[lnI, 5], loItem.CanRemove, ;
				'CanRemove not correct for ' + This.aTypes[lnI, 1])
		next lnI
	endfunc

*******************************************************************************
* Test that CanRun is set the way it's supposed to be
*******************************************************************************
	function Test_CanRun_Correct
		for lnI = 1 to alen(This.aTypes, 1)
			loItem = newobject(This.aTypes[lnI, 1], ;
				'Source\ProjectExplorerItems.vcx')
			This.AssertEquals(This.aTypes[lnI, 6], loItem.CanRun, ;
				'CanRun not correct for ' + This.aTypes[lnI, 1])
		next lnI
	endfunc

*******************************************************************************
* Test that CanSetMain is set the way it's supposed to be
*******************************************************************************
	function Test_CanSetMain_Correct
		for lnI = 1 to alen(This.aTypes, 1)
			loItem = newobject(This.aTypes[lnI, 1], ;
				'Source\ProjectExplorerItems.vcx')
			This.AssertEquals(This.aTypes[lnI, 7], loItem.CanSetMain, ;
				'CanSetMain not correct for ' + This.aTypes[lnI, 1])
		next lnI
	endfunc

*******************************************************************************
* Test that CanRename is set the way it's supposed to be
*******************************************************************************
	function Test_CanRename_Correct
		for lnI = 1 to alen(This.aTypes, 1)
			loItem = newobject(This.aTypes[lnI, 1], ;
				'Source\ProjectExplorerItems.vcx')
			This.AssertEquals(This.aTypes[lnI, 8], loItem.CanRename, ;
				'CanRename not correct for ' + This.aTypes[lnI, 1])
		next lnI
	endfunc

*******************************************************************************
* Test that HasDescription is set the way it's supposed to be
*******************************************************************************
	function Test_HasDescription_Correct
		for lnI = 1 to alen(This.aTypes, 1)
			loItem = newobject(This.aTypes[lnI, 1], ;
				'Source\ProjectExplorerItems.vcx')
			This.AssertEquals(This.aTypes[lnI, 9], loItem.HasDescription, ;
				'HasDescription not correct for ' + This.aTypes[lnI, 1])
		next lnI
	endfunc

*******************************************************************************
* Test that HasDescription is set the way it's supposed to be for a field in a
* table in a DBC
*******************************************************************************
	function Test_HasDescription_Correct_FieldInFreeTable
		loItem = newobject('ProjectItemField', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.ParentType = 't'
		This.AssertTrue(loItem.HasDescription, ;
			'HasDescription not correct for field in free table')
	endfunc

*******************************************************************************
* Test that HasDescription is set the way it's supposed to be for a field in a
* local view
*******************************************************************************
	function Test_HasDescription_Correct_FieldInLocaView
		loItem = newobject('ProjectItemField', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.ParentType = 'l'
		This.AssertTrue(loItem.HasDescription, ;
			'HasDescription not correct for field in local view')
	endfunc

*******************************************************************************
* Test that HasDescription is set the way it's supposed to be for a field in a
* remote view
*******************************************************************************
	function Test_HasDescription_Correct_FieldInRemoteView
		loItem = newobject('ProjectItemField', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.ParentType = 'r'
		This.AssertTrue(loItem.HasDescription, ;
			'HasDescription not correct for field in remote view')
	endfunc

*******************************************************************************
* Test that HasDescription is set the way it's supposed to be for an index in a
* table in a DBC
*******************************************************************************
	function Test_HasDescription_Correct_IndexInFreeTable
		loItem = newobject('ProjectItemIndex', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.ParentType = 't'
		This.AssertTrue(loItem.HasDescription, ;
			'HasDescription not correct for index in free table')
	endfunc

*******************************************************************************
* Test that HasDescription is set the way it's supposed to be for an index in a
* local view
*******************************************************************************
	function Test_HasDescription_Correct_IndexInLocaView
		loItem = newobject('ProjectItemIndex', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.ParentType = 'l'
		This.AssertTrue(loItem.HasDescription, ;
			'HasDescription not correct for field in local view')
	endfunc

*******************************************************************************
* Test that HasDescription is set the way it's supposed to be for an index in a
* remote view
*******************************************************************************
	function Test_HasDescription_Correct_IndexInRemoteView
		loItem = newobject('ProjectItemIndex', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.ParentType = 'r'
		This.AssertTrue(loItem.HasDescription, ;
			'HasDescription not correct for field in remote view')
	endfunc

*******************************************************************************
* Test that HasChildren is set the way it's supposed to be
*******************************************************************************
	function Test_HasChildren_Correct
		for lnI = 1 to alen(This.aTypes, 1)
			loItem = newobject(This.aTypes[lnI, 1], ;
				'Source\ProjectExplorerItems.vcx')
			This.AssertEquals(This.aTypes[lnI, 10], loItem.HasChildren, ;
				'HasChildren not correct for ' + This.aTypes[lnI, 1])
		next lnI
	endfunc

*******************************************************************************
* Test that HasParent is set the way it's supposed to be
*******************************************************************************
	function Test_HasParent_Correct
		for lnI = 1 to alen(This.aTypes, 1)
			loItem = newobject(This.aTypes[lnI, 1], ;
				'Source\ProjectExplorerItems.vcx')
			This.AssertEquals(This.aTypes[lnI, 12], loItem.HasParent, ;
				'HasParent not correct for ' + This.aTypes[lnI, 1])
		next lnI
	endfunc

*******************************************************************************
* Test that HasUser is set the way it's supposed to be
*******************************************************************************
	function Test_HasUser_Correct
		for lnI = 1 to alen(This.aTypes, 1)
			loItem = newobject(This.aTypes[lnI, 1], ;
				'Source\ProjectExplorerItems.vcx')
			This.AssertEquals(This.aTypes[lnI, 13], loItem.HasUser, ;
				'HasUser not correct for ' + This.aTypes[lnI, 1])
		next lnI
	endfunc

*******************************************************************************
* Test that ReloadAfterEdit is set the way it's supposed to be
*******************************************************************************
	function Test_ReloadAfterEdit_Correct
		for lnI = 1 to alen(This.aTypes, 1)
			loItem = newobject(This.aTypes[lnI, 1], ;
				'Source\ProjectExplorerItems.vcx')
			This.AssertEquals(This.aTypes[lnI, 11], loItem.ReloadAfterEdit, ;
				'ReloadAfterEdit not correct for ' + This.aTypes[lnI, 1])
		next lnI
	endfunc

*******************************************************************************
* Test that Clone creates a clone
*******************************************************************************
	function Test_Clone_CreatesClone
		loItem = This.oItem.Clone()
		This.AssertEquals('projectitem', lower(loItem.Class), ;
			'Did not create clone of correct class')
	endfunc

*******************************************************************************
* Test that Clone clones properties
*******************************************************************************
	function Test_Clone_ClonesProperties
		This.oItem.Type = 'Z'
		loItem = This.oItem.Clone()
		This.AssertEquals('Z', loItem.Type, ;
			'Did not copy properties')
	endfunc

*******************************************************************************
* Test that Clone clones Tags
*******************************************************************************
	function Test_Clone_ClonesTags
		lcTags = 'a' + chr(13) + chr(10) + 'b' + chr(13) + chr(10)
		This.oItem.SaveTagString(lcTags)
		loItem = This.oItem.Clone()
		lcCloneTags = loItem.GetTagString()
		This.AssertEquals(lcTags, lcCloneTags, ;
			'Did not copy Tags')
	endfunc

*******************************************************************************
* Test that UpdateFromClone fails if invalid item passed (this actually tests
* all the ways it can fail)
*******************************************************************************
	function Test_UpdateFromClone_Fails_InvalidObject
		llOK = This.oItem.UpdateFromClone()
		This.AssertFalse(llOK, 'Returned .T. with no object passed')
		llOK = This.oItem.UpdateFromClone(createobject('Line'))
		This.AssertFalse(llOK, 'Returned .T. with wrong class of object passed')
	endfunc

*******************************************************************************
* Test that UpdateFromClone clones properties
*******************************************************************************
	function Test_UpdateFromClone_ClonesProperties
		This.oItem.Type = 'Z'
		loItem = This.oItem.Clone()
		loItem.Type = 'A'
		This.oItem.UpdateFromClone(loItem)
		This.AssertEquals('A', This.oItem.Type, ;
			'Did not copy properties')
	endfunc

*******************************************************************************
* Test that UpdateFromClone clones Tags
*******************************************************************************
	function Test_UpdateFromClone_ClonesTags
		loItem = This.oItem.Clone()
		lcTags = 'a' + chr(13) + chr(10) + 'b' + chr(13) + chr(10)
		loItem.SaveTagString(lcTags)
		This.oItem.UpdateFromClone(loItem)
		lcCloneTags = This.oItem.GetTagString()
		This.AssertEquals(lcTags, lcCloneTags, ;
			'Did not copy Tags')
	endfunc

*******************************************************************************
* Test that RemoveItem removes file from project
*******************************************************************************
	function Test_RemoveItem_RemovesItem
		This.oProject.Files.Add(This.cFile)
		loItem = newobject('ProjectItemFile', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.Path = This.cFile
		loItem.RemoveItem(This.oProject)
		This.AssertTrue(This.oProject.Files.Count = 0, 'Did not remove item')
	endfunc

*******************************************************************************
* Test that RemoveItem deletes the file
*******************************************************************************
	function Test_RemoveItem_DeletesFile
		loFile = This.oProject.Files.Add(This.cFile)
		loItem = newobject('ProjectItemFile', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.Path = This.cFile
		loItem.RemoveItem(This.oProject, .T.)
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

		loItem = newobject('ProjectItemClass', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.Path     = This.cTestDataFolder + 'test.vcx'
		loItem.ItemName = 'test'
		loItem.RemoveItem(This.oProject)
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

		loItem = newobject('ProjectItemTableInDBC', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.ParentPath = This.cTestDataFolder + 'test.dbc'
		loItem.Path       = This.cTestDataFolder + 'test.dbf'
		loItem.ItemName   = 'test'
		loItem.RemoveItem(This.oProject)
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

		loItem = newobject('ProjectItemTableInDBC', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.ParentPath = This.cTestDataFolder + 'test.dbc'
		loItem.Path       = This.cTestDataFolder + 'test.dbf'
		loItem.ItemName   = 'test'
		loItem.RemoveItem(This.oProject, .T.)
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

		loItem = newobject('ProjectItemLocalView', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.ParentPath = This.cTestDataFolder + 'test.dbc'
		loItem.ItemName   = 'testview'
		loItem.RemoveItem(This.oProject)
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

		loItem = newobject('ProjectItemLocalView', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.ParentPath = This.cTestDataFolder + 'test.dbc'
		loItem.ItemName   = 'testview'
		loItem.RemoveItem(This.oProject)
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

		loItem = newobject('ProjectItemConnection', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.ParentPath = This.cTestDataFolder + 'test.dbc'
		loItem.ItemName   = 'testconn'
		loItem.RemoveItem(This.oProject)
		llOK = not indbc('testconn', 'Connection')
		close databases
		erase (This.cTestDataFolder + 'test.dbc')
		erase (This.cTestDataFolder + 'test.dct')
		erase (This.cTestDataFolder + 'test.dcx')
		This.AssertTrue(llOK, 'Did not remove connection')
	endfunc

*******************************************************************************
* Test that EditItem fails if the file can't be edited
*******************************************************************************
	function Test_EditItem_FailsForFile
		loItem = newobject('ProjectItemFile', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.CanEdit = .F.
		llReturn = loItem.EditItem(This.oProject)
		This.AssertFalse(llReturn, 'Did not return false when cannot edit')
	endfunc

*******************************************************************************
* Test that EditItem calls Modify for a file
*******************************************************************************
	function Test_EditItem_CallsModifyForFile
		loFile = This.oProject.Files.Add(This.cFile)
		loItem = newobject('ProjectItemFile', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.Path = This.cFile
		loItem.EditItem(This.oProject)
		loItem = This.oProject.Files.Item(1)
		This.AssertTrue(loItem.lModifyCalled, 'Did not call Modify')
	endfunc

*******************************************************************************
* Test that EditItem calls Modify for a class
*******************************************************************************
	function Test_EditItem_CallsModifyForClass
		loFile = This.oProject.Files.Add(This.cFile)
		loItem = newobject('ProjectItemClass', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.Path     = This.cFile
		loItem.ItemName = 'test'
		loItem.EditItem(This.oProject)
		loFile = This.oProject.Files.Item(1)
		This.AssertEquals('test', loFile.cClass, 'Did not pass class to Modify')
	endfunc

*******************************************************************************
* Test that EditItem calls ExecuteFile for an image
*******************************************************************************
	function Test_EditItem_CallsExecuteFileForImage
		loItem = newobject('ProjectItemOther', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.Path = This.cTestDataFolder + 'test.bmp'
		bindevent(loItem, 'ExecuteFile', This, 'ExecuteFileCalled', 4)
		loItem.EditItem(This.oProject)
		This.AssertEquals('Edit', This.cExecuteFileOperation, ;
			'Did not pass edit to Modify')
	endfunc

*******************************************************************************
* Test that EditItem fires a projecthook's QueryModifyFile for an image
*******************************************************************************
	function Test_EditItem_CallsQueryModifyFileForImage
		This.oProject.ProjectHook = createobject('MockProjectHook')
		lcFile = This.cTestDataFolder + 'test.bmp'
		This.oProject.Files.Add(lcFile)
		loItem = newobject('ProjectItemOther', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.Path = lcFile
		loItem.EditItem(This.oProject)
		This.AssertEquals(lcFile, This.oProject.ProjectHook.cFile, ;
			'Did not call QueryModifyFile')
	endfunc

*******************************************************************************
* Test that EditItem calls the Class Browser for a classlib
*******************************************************************************
	function Test_EditItem_CallsClassBrowserForClasslib
		loItem = newobject('ProjectItemClasslib', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.Path = This.cTestDataFolder + 'test.vcx'
		lcBrowser = _browser
		_browser  = This.cTestProgram
		loItem.EditItem(This.oProject)
		_browser = lcBrowser
		This.AssertTrue(plClassBrowserCalled, ;
			'Did not call Class Browser')
	endfunc

*******************************************************************************
* Test that EditItem fires a projecthook's QueryModifyFile for a classlib
*******************************************************************************
	function Test_EditItem_CallsQueryModifyFileForClasslib
		This.oProject.ProjectHook = createobject('MockProjectHook')
		lcFile = This.cTestDataFolder + 'test.vcx'
		This.oProject.Files.Add(lcFile)
		loItem = newobject('ProjectItemClasslib', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.Path = lcFile
		lcBrowser   = _browser
		_browser    = This.cTestProgram
		loItem.EditItem(This.oProject)
		_browser = lcBrowser
		This.AssertEquals(lcFile, This.oProject.ProjectHook.cFile, ;
			'Did not call QueryModifyFile')
	endfunc

*** TODO: tests for EditItem for Application, Connection, Field, Index,
*			LocalView, RemoveView, StoredProc, TableInDBC. Problem is that they
*			open a designer

*******************************************************************************
* Test that RunItem fails if the file can't be run
*******************************************************************************
	function Test_RunItem_FailsForFile
		loItem = newobject('ProjectItemFile', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.CanRun = .F.
		llReturn = loItem.RunItem(This.oProject)
		This.AssertFalse(llReturn, 'Did not return false when cannot run')
	endfunc

*******************************************************************************
* Test that RunItem calls Run for a file
*******************************************************************************
	function Test_RunItem_CallsRunForFile
		This.oProject.Files.Add(This.cFile)
		loItem = newobject('ProjectItemFile', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.CanRun = .T.
		loItem.Path   = This.cFile
		loItem.RunItem(This.oProject)
		loItem = This.oProject.Files.Item(1)
		This.AssertTrue(loItem.lRunCalled, 'Did not call Run')
	endfunc

*** TODO: tests for RunItem for Application, Form, Menu, Program, Query, and TableInDBC.
*			Problem is that they actually run something

*** TODO: tests for NewItem for Class, ClassLib, Connection, Database, Form, FreeTable,
***			Label, LocalView, Menu, Program, Query, RemoteView, Report, TableInDBC and
***			Text. Problem is that they open an editor

*******************************************************************************
* Test that GetProperties gets the properties for a field in a table in a DBC
*******************************************************************************
	function Test_GetProperties_HandlesFieldInTableInDBC

* Create a table in a database.

		lcComment = 'test'
		lcDBC     = This.cTestDataFolder + 'test.dbc'
		lcTable   = This.cTestDataFolder + 'test.dbf'
		create database (lcDBC)
		create table (lcTable) (field1 c(1))
		dbsetprop('test.field1', 'Field', 'Comment', lcComment)
		close databases

* Do the test.

		loItem = newobject('ProjectItemField', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.ParentPath = lcDBC
		loItem.ParentKey  = 'test|test'
		loItem.ParentType = 't'
		loItem.Path       = lcTable
		loItem.ItemName   = 'field1'
		loItem.GetProperties()
		close databases
		erase (lcDBC)
		erase (forceext(lcDBC, 'dct'))
		erase (forceext(lcDBC, 'dcx'))
		erase (lcTable)
		This.AssertEquals(lcComment, loItem.Description, ;
			'Did not get properties')
	endfunc

*******************************************************************************
* Test that GetProperties gets the properties for an index in a table in a DBC
*******************************************************************************
	function Test_GetProperties_HandlesIndexInTableInDBC

* Create a table in a database.

		lcComment = 'test'
		lcDBC     = This.cTestDataFolder + 'test.dbc'
		lcTable   = This.cTestDataFolder + 'test.dbf'
		create database (lcDBC)
		create table (lcTable) (field1 c(1))
		index on field1 tag field1
		close databases
		use (lcDBC)
		locate for OBJECTTYPE = 'Index'
		do PUTPROP with 7, 'test'
		use

* Do the test.

		loItem = newobject('ProjectItemIndex', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.ParentPath = lcDBC
		loItem.ParentKey  = 'test|test'
		loItem.ParentType = 't'
		loItem.Path       = lcTable
		loItem.ItemName   = 'field1'
		loItem.GetProperties()
		close databases
		erase (lcDBC)
		erase (forceext(lcDBC, 'dct'))
		erase (forceext(lcDBC, 'dcx'))
		erase (lcTable)
		erase (forceext(lcTable, 'cdx'))
		This.AssertEquals(lcComment, loItem.Description, ;
			'Did not get properties')
	endfunc

*******************************************************************************
* Test that GetProperties gets the properties for a table in a DBC
*******************************************************************************
	function Test_GetProperties_HandlesTableInDBC

* Create a table in a database.

		lcComment = 'test'
		lcDBC     = This.cTestDataFolder + 'test.dbc'
		lcTable   = This.cTestDataFolder + 'test.dbf'
		create database (lcDBC)
		create table (lcTable) (field1 c(1))
		dbsetprop('test', 'Table', 'Comment', lcComment)
		close databases

* Do the test.

		loItem = newobject('ProjectItemTableInDBC', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.ParentPath = lcDBC
		loItem.ItemName   = 'test'
		loItem.GetProperties()
		close databases
		erase (lcDBC)
		erase (forceext(lcDBC, 'dct'))
		erase (forceext(lcDBC, 'dcx'))
		erase (lcTable)
		This.AssertEquals(lcComment, loItem.Description, ;
			'Did not get properties')
	endfunc

*******************************************************************************
* Test that GetProperties gets the properties for a view
*******************************************************************************
	function Test_GetProperties_HandlesView

* Create a table and a view in a database.

		lcComment = 'test'
		lcDBC     = This.cTestDataFolder + 'test.dbc'
		lcTable   = This.cTestDataFolder + 'test.dbf'
		create database (lcDBC)
		create table (lcTable) (field1 c(1))
		create view TestView as select * from test
		dbsetprop('TestView', 'View', 'Comment', lcComment)
		close databases

* Do the test.

		loItem = newobject('ProjectItemLocalView', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.ParentPath = lcDBC
		loItem.ItemName   = 'TestView'
		loItem.GetProperties()
		close databases
		erase (lcDBC)
		erase (forceext(lcDBC, 'dct'))
		erase (forceext(lcDBC, 'dcx'))
		erase (lcTable)
		This.AssertEquals(lcComment, loItem.Description, ;
			'Did not get properties')
	endfunc

*******************************************************************************
* Test that GetProperties gets the properties for a connection
*******************************************************************************
	function Test_GetProperties_HandlesConnection

* Create a connection in a database.

		lcComment = 'test'
		lcDBC     = This.cTestDataFolder + 'test.dbc'
		create database (lcDBC)
		create connection test datasource 'Northwind SQL'
		dbsetprop('test', 'Connection', 'Comment', lcComment)
		close databases

* Do the test.

		loItem = newobject('ProjectItemConnection', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.ParentPath = lcDBC
		loItem.ItemName   = 'test'
		loItem.GetProperties()
		close databases
		erase (lcDBC)
		erase (forceext(lcDBC, 'dct'))
		erase (forceext(lcDBC, 'dcx'))
		This.AssertEquals(lcComment, loItem.Description, ;
			'Did not get properties')
	endfunc

*******************************************************************************
* Test that GetProperties gets the properties for a file
*******************************************************************************
	function Test_GetProperties_HandlesFile
		loFile = This.oProject.Files.Add('test.txt')
		loItem = newobject('ProjectItemFile', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.Path = 'test.txt'
		loItem.GetProperties(This.oProject)
		This.AssertEquals(loFile.Exclude, loItem.Exclude, ;
			'Did not get Exclude')
		This.AssertEquals(loFile.CodePage, loItem.CodePage, ;
			'Did not get CodePage')
		This.AssertEquals(loFile.ReadOnly, loItem.ReadOnly, ;
			'Did not get ReadOnly')
		This.AssertEquals(loFile.LastModified, loItem.LastModified, ;
			'Did not get LastModified')
		This.AssertEquals(loFile.Description, loItem.Description, ;
			'Did not get Description')
	endfunc

*******************************************************************************
* Test that GetProperties gets the properties for a form
*******************************************************************************
	function Test_GetProperties_HandlesForm
		loFile = This.oProject.Files.Add('test.txt')
		loItem = newobject('ProjectItemForm', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.Path = 'test.txt'
		loItem.GetProperties(This.oProject)
		This.AssertEquals(loFile.FileClass, loItem.ItemClass, ;
			'Did not get ItemClass')
		This.AssertEquals(lower(justfname(loFile.FileClassLibrary)), ;
			lower(justfname(loItem.ItemLibrary)), 'Did not get ItemLibrary')
	endfunc

*******************************************************************************
* Test that GetProperties gets the properties for a class
*******************************************************************************
	function Test_GetProperties_HandlesClass

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
	<test>
		<platform>WINDOWS</platform>
		<uniqueid>_4VK0UNDN4</uniqueid>
		<timestamp>1247898146</timestamp>
		<class>test</class>
		<classloc>test.vcx</classloc>
		<baseclass>custom</baseclass>
		<objname>testclass</objname>
		<parent/>
		<properties>Name = "testclass"
</properties>
		<protected/>
		<methods/>
		<objcode/>
		<ole/>
		<ole2/>
		<reserved1>Class</reserved1>
		<reserved2>1</reserved2>
		<reserved3/>
		<reserved4>toolbar.ico</reserved4>
		<reserved5>icon.ico</reserved5>
		<reserved6>Pixels</reserved6>
		<reserved7>my description</reserved7>
		<reserved8>projectexplorer.h</reserved8>
		<user>testuser</user>
	</test>
	<test>
		<platform>COMMENT</platform>
		<uniqueid>RESERVED</uniqueid>
		<timestamp>0</timestamp>
		<class/>
		<classloc/>
		<baseclass/>
		<objname>testclass</objname>
		<parent/>
		<properties/>
		<protected/>
		<methods/>
		<objcode/>
		<ole/>
		<ole2/>
		<reserved1/>
		<reserved2>OLEPublic</reserved2>
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
		lcVCX = This.cTestDataFolder + 'test.vcx'
		copy to (lcVCX)
		use
		use in ProjectExplorerMenu

* Do the test.

		loFile = This.oProject.Files.Add(This.cTestDataFolder + 'test.vcx')
		loItem = newobject('ProjectItemClass', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.ItemName = 'testclass'
		loItem.Path     = lcVCX
		loItem.GetProperties(This.oProject)
		erase (lcVCX)
		erase (forceext(lcVCX, 'vct'))
		This.AssertEquals('custom', loItem.ItemBaseClass, ;
			'Did not get ItemBaseClass')
		This.AssertEquals('test', loItem.ItemParentClass, ;
			'Did not get ItemParentClass')
		This.AssertEquals('test.vcx', loItem.ItemParentLibrary, ;
			'Did not get ItemParentLibrary')
		This.AssertEquals('projectexplorer.h', loItem.IncludeFile, ;
			'Did not get IncludeFile')
		This.AssertEquals('testuser', loItem.User, ;
			'Did not get User')
		This.AssertEquals('toolbar.ico', loItem.ToolbarIcon, ;
			'Did not get ToolbarIcon')
		This.AssertEquals('icon.ico', loItem.Icon, ;
			'Did not get Icon')
		This.AssertEquals('my description', loItem.Description, ;
			'Did not get Description')
		This.AssertTrue(loItem.OLEPublic, 'Did not get OLEPublic')
		This.AssertEquals(datetime(2017, 3, 1, 13, 17, 4), ;
			loItem.LastModified, 'Did not get LastModified')
	endfunc

*******************************************************************************
* Test that SaveItem saves the properties for a field in a table in a DBC
*******************************************************************************
	function Test_SaveItem_HandlesFieldInTableInDBC

* Create a table in a database.

		lcComment = 'test'
		lcDBC     = This.cTestDataFolder + 'test.dbc'
		lcTable   = This.cTestDataFolder + 'test.dbf'
		create database (lcDBC)
		create table (lcTable) (field1 c(1))
		close databases

* Do the test.

		loItem = newobject('ProjectItemField', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.ParentPath  = lcDBC
		loItem.ParentKey   = 'test|test'
		loItem.ParentType  = 't'
		loItem.Path        = lcTable
		loItem.ItemName    = 'field1'
		loItem.Description = lcComment
		loItem.SaveItem()
		lcDescription = dbgetprop('test.field1', 'Field', 'Comment')
		close databases
		erase (lcDBC)
		erase (forceext(lcDBC, 'dct'))
		erase (forceext(lcDBC, 'dcx'))
		erase (lcTable)
		This.AssertEquals(lcComment, lcDescription, ;
			'Did not save properties')
	endfunc

*******************************************************************************
* Test that SaveItem saves the properties for an index in a table in a DBC
*******************************************************************************
	function Test_SaveItem_HandlesIndexInTableInDBC

* Create a table in a database.

		lcComment = 'test'
		lcDBC     = This.cTestDataFolder + 'test.dbc'
		lcTable   = This.cTestDataFolder + 'test.dbf'
		create database (lcDBC)
		create table (lcTable) (field1 c(1))
		index on field1 tag field1
		close databases

* Do the test.

		loItem = newobject('ProjectItemIndex', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.ParentPath  = lcDBC
		loItem.ParentKey   = 'test|test'
		loItem.ParentType  = 't'
		loItem.Path        = lcTable
		loItem.ItemName    = 'field1'
		loItem.Description = lcComment
		loItem.SaveItem()
		close databases
		use (lcDBC)
		locate for OBJECTTYPE = 'Index'
		lcDescription = strextract(PROPERTY, chr(7), chr(0))
		use
		erase (lcDBC)
		erase (forceext(lcDBC, 'dct'))
		erase (forceext(lcDBC, 'dcx'))
		erase (lcTable)
		This.AssertEquals(lcComment, lcDescription, ;
			'Did not save properties')
	endfunc

*******************************************************************************
* Test that SaveItem saves the properties for a table in a DBC
*******************************************************************************
	function Test_SaveItem_HandlesTableInDBC

* Create a table in a database.

		lcComment = 'test'
		lcDBC     = This.cTestDataFolder + 'test.dbc'
		lcTable   = This.cTestDataFolder + 'test.dbf'
		create database (lcDBC)
		create table (lcTable) (field1 c(1))
		close databases

* Do the test.

		loItem = newobject('ProjectItemTableInDBC', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.ParentPath  = lcDBC
		loItem.ItemName    = 'test'
		loItem.Description = lcComment
		loItem.SaveItem()
		lcDescription = dbgetprop('test', 'Table', 'Comment')
		close databases
		erase (lcDBC)
		erase (forceext(lcDBC, 'dct'))
		erase (forceext(lcDBC, 'dcx'))
		erase (lcTable)
		This.AssertEquals(lcComment, lcDescription, ;
			'Did not save properties')
	endfunc

*******************************************************************************
* Test that SaveItem saves gets the properties for a view
*******************************************************************************
	function Test_SaveItem_HandlesView

* Create a table and a view in a database.

		lcComment = 'test'
		lcDBC     = This.cTestDataFolder + 'test.dbc'
		lcTable   = This.cTestDataFolder + 'test.dbf'
		create database (lcDBC)
		create table (lcTable) (field1 c(1))
		create view TestView as select * from test
		close databases

* Do the test.

		loItem = newobject('ProjectItemLocalView', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.ParentPath  = lcDBC
		loItem.ItemName    = 'TestView'
		loItem.Description = lcComment
		loItem.SaveItem()
		lcDescription = dbgetprop('TestView', 'View', 'Comment')
		close databases
		erase (lcDBC)
		erase (forceext(lcDBC, 'dct'))
		erase (forceext(lcDBC, 'dcx'))
		erase (lcTable)
		This.AssertEquals(lcComment, lcDescription, ;
			'Did not save properties')
	endfunc

*******************************************************************************
* Test that SaveItem saves the properties for a connection
*******************************************************************************
	function Test_SaveItem_HandlesConnection

* Create a connection in a database.

		lcComment = 'test'
		lcDBC     = This.cTestDataFolder + 'test.dbc'
		create database (lcDBC)
		create connection test datasource 'Northwind SQL'
		close databases

* Do the test.

		loItem = newobject('ProjectItemConnection', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.ParentPath  = lcDBC
		loItem.ItemName    = 'test'
		loItem.Description = lcComment
		loItem.SaveItem()
		lcDescription = dbgetprop('test', 'Connection', 'Comment')
		close databases
		erase (lcDBC)
		erase (forceext(lcDBC, 'dct'))
		erase (forceext(lcDBC, 'dcx'))
		This.AssertEquals(lcComment, lcDescription, ;
			'Did not save properties')
	endfunc

*******************************************************************************
* Test that SaveItem saves the properties for a file
*******************************************************************************
	function Test_SaveItem_HandlesFile

* Create a project and add a file to it.

		lcProject = This.cTestDataFolder + 'test.pjx'
		create project (lcProject) nowait noshow
		loProject = _vfp.ActiveProject
		lcKey = sys(2015)
		lcPRG = This.cTestDataFolder + 'test.prg'
		strtofile('xxx', lcPRG)
		loFile = loProject.Files.Add(lcPRG)
		use (lcProject) again shared
		locate for NAME = 'test.prg'
		replace DEVINFO with lcKey
		use

* Do the test.

		loItem = newobject('ProjectItemFile', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.Path        = lcPRG
		loItem.Key         = lcKey
		loItem.MainFile    = .T.
		loItem.Description = 'test'
		loItem.User        = 'test user'
		loItem.SaveItem(loProject)
		lcMainFile    = loProject.MainFile
		loFile        = loProject.Files(1)
		lcDescription = loFile.Description
		loProject.Close()
		use (lcProject)
		locate for DEVINFO = lcKey
		lcUser = USER
		use
		erase (lcProject)
		erase (forceext(lcProject, 'pjt'))
		erase (lcPRG)
		This.AssertEquals(loItem.Description, lcDescription, ;
			'Did not save Description')
		This.AssertEquals(lower(lcPRG), lcMainFile, ;
			'Did not save MainFile')
		This.AssertEquals('test user', lcUser, ;
			'Did not save User')
	endfunc

*******************************************************************************
* Test that SaveItem turns off main file for project
*******************************************************************************
	function Test_SaveItem_TurnsOffMainFile

* Create a project and add a file to it.

		lcProject = This.cTestDataFolder + 'test.pjx'
		create project (lcProject) nowait noshow
		loProject = _vfp.ActiveProject
		lcKey = sys(2015)
		lcPRG = This.cTestDataFolder + 'test.prg'
		strtofile('xxx', lcPRG)
		loFile = loProject.Files.Add(lcPRG)
		loProject.SetMain(lcPRG)
		use (lcProject) again shared
		locate for NAME = 'test.prg'
		replace DEVINFO with lcKey
		use

* Do the test.

		loItem = newobject('ProjectItemFile', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.Path     = lcPRG
		loItem.ItemName = 'test'
		loItem.Key      = lcKey
		loItem.GetProperties(loProject)
		loItem.MainFile = .F.
		loItem.SaveItem(loProject)
		loProject.Close()
			&& loProject.MainFile doesn't get reset until close and reopen project
		modify project (lcProject) nowait noshow
		loProject  = _vfp.ActiveProject
		lcMainFile = loProject.MainFile
		loProject.Close()
		use
		erase (lcProject)
		erase (forceext(lcProject, 'pjt'))
		erase (lcPRG)
		This.AssertEquals('', lcMainFile, 'Did not turn off MainFile')
	endfunc

*******************************************************************************
* Test that SaveItem handles Exclude for a file
*******************************************************************************
	function Test_SaveItem_HandlesExcludeForFile

* Create a project and add a file to it.

		lcProject = This.cTestDataFolder + 'test.pjx'
		create project (lcProject) nowait noshow
		loProject = _vfp.ActiveProject
		lcKey  = sys(2015)
		lcFile = This.cTestDataFolder + 'test.txt'
		strtofile('xxx', lcFile)
		loFile = loProject.Files.Add(lcFile)
		use (lcProject) again shared
		locate for NAME = 'test.txt'
		replace DEVINFO with lcKey
		use

* Do the test.

		loItem = newobject('ProjectItemFile', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.Path    = lcFile
		loItem.Key     = lcKey
		loItem.Exclude = .T.
		loItem.SaveItem(loProject)
		loFile    = loProject.Files(1)
		llExclude = loFile.Exclude
		loProject.Close()
		erase (lcProject)
		erase (forceext(lcProject, 'pjt'))
		erase (lcFile)
		This.AssertTrue(llExclude, 'Did not save Exclude')
	endfunc

*******************************************************************************
* Test that SaveItem saves the properties for a class
*******************************************************************************
	function Test_SaveItem_HandlesClass

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
		lcVCX = This.cTestDataFolder + 'test.vcx'
		copy to (lcVCX)
		use
		use in ProjectExplorerMenu

* Do the test.

		loFile = This.oProject.Files.Add(lcVCX)
		loItem = newobject('ProjectItemClass', ;
			'Source\ProjectExplorerItems.vcx')
		loItem.ItemName    = 'test'
		loItem.Path        = lcVCX
		loItem.Description = 'test'
		loItem.User        = 'test user'
		loItem.SaveItem(This.oProject)
		use (lcVCX)
		locate for OBJNAME == 'test'
		lcDescription = RESERVED7
		lcUser        = USER
		use
		erase (lcVCX)
		erase (forceext(lcVCX, 'vct'))
		This.AssertEquals(loItem.Description, lcDescription, ;
			'Did not get Description')
		This.AssertEquals(loItem.User, lcUser, ;
			'Did not get User')
	endfunc
enddefine

*******************************************************************************
* Mock classes
*******************************************************************************
define class MockProject as Custom
	Files       = .NULL.
	ProjectHook = .NULL.
	Name        = 'test'
	MainFile    = ''

	function Init
		This.Files = createobject('MockFileCollection')
	endfunc
	
	function SetMain(tcFile)
		This.MainFile = tcFile
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
	cFile            = ''
	oCollection      = .NULL.
	lModifyCalled    = .F.
	lRunCalled       = .F.
	lDeleteFile      = .F.
	cClass           = ''
	LastModified     = {/:}
	Description      = 'test'
	FileClass        = 'testclass'
	FileClassLibrary = 'test.vcx'
	CodePage         = 1
	ReadOnly         = .T.
	Exclude          = .T.

	function Init
		This.LastModified = datetime()
	endfunc
	
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

define class MockProjectHook as Custom
	cFile = ''

	function QueryModifyFile(toFile)
		This.cFile = toFile.cFile
	endfunc
enddefine
