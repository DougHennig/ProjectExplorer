*******************************************************************************
define class VersionControlOperationsTests as FxuTestCase of FxuTestCase.prg
*******************************************************************************
	#IF .f.
	LOCAL THIS AS VersionControlOperationsTests OF VersionControlOperationsTests.PRG
	#ENDIF
	
	cTestFolder     = ''
	cTestDataFolder = ''
	cTestProgram    = ''
	icTestPrefix    = 'Test_'
	ilAllowDebug    = .T.
	
	oOperations     = .NULL.
	oAddins         = .NULL.
	cFile           = ''
	cCurrPath       = ''

*******************************************************************************
* Setup for the tests
*******************************************************************************
	function Setup
		This.cCurrPath = set('PATH')
		set path to 'Source' additive

* Get the folder the tests are running from, the name of this test
* program, and create a test data folder if necessary.

		lcProgram            = sys(16)
		This.cTestProgram    = substr(lcProgram, at(' ', lcProgram, 2) + 1)
		This.cTestFolder     = addbs(justpath(This.cTestProgram))
		This.cTestDataFolder = GetProperFileCase(This.cTestFolder, .T.) + ;
			'TestData\'
		if not directory(This.cTestDataFolder)
			md (This.cTestDataFolder)
		endif not directory(This.cTestDataFolder)

* Set up other things.

		This.cFile = This.cTestDataFolder + sys(2015) + '.txt'
		strtofile('xxx', This.cFile)
		This.oAddins   = createobject('MockAddin')
		This.SetupOperations(1, .F.)
	endfunc

*******************************************************************************
* Helper method to set up the operations object.
*******************************************************************************
	function SetupOperations(tnIncludeInVersionControl, tlAutoCommit)
		lcFoxBin2PRG = execscript(_screen.cThorDispatcher, ;
		'Thor_Proc_GetFoxBin2PrgFolder')
		This.oOperations = createobject('MockVersionControlOperations', ;
			tnIncludeInVersionControl, tlAutoCommit, 'file added', ;
			'file removed', This.oAddins, lcFoxBin2PRG, This.cTestDataFolder)
	endfunc

*******************************************************************************
* Helper method to create a class in a class library
*******************************************************************************

	function CreateClass
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
		select * from Source\ProjectExplorerMenu.vcx into cursor (lcCursor) ;
			nofilter readwrite
		delete all
		xmltocursor(lcXML, lcCursor, 8192)
		copy to (This.cTestDataFolder + 'test.vcx')
		use
		use in ProjectExplorerMenu
	endfunc

*******************************************************************************
* Clean up on exit.
*******************************************************************************
	function TearDown
		erase (This.cFile)
		set path to (This.cCurrPath)
	endfunc

*******************************************************************************
* Test that AddFile adds a non-binary file
*******************************************************************************
	function Test_AddFile_AddsNonBinaryFile
		This.oOperations.AddFile(This.cFile)
		This.AssertEquals(This.cFile, This.oOperations.aFiles[1], ;
			'Did not add non-binary file')
	endfunc

*******************************************************************************
* Test that AddFile does not commit a file if not auto-commit
*******************************************************************************
	function Test_AddFile_NoCommit
		This.oOperations.AddFile(This.cFile)
		This.AssertFalse(This.oOperations.lCommitFilesCalled, 'Committed file')
	endfunc

*******************************************************************************
* Test that AddFile commits a file if auto-commit
*******************************************************************************
	function Test_AddFile_CommitsFileAutoCommit
		This.SetupOperations(1, .T.)
		This.oOperations.AddFile(This.cFile)
		This.AssertTrue(This.oOperations.lCommitFilesCalled, ;
			'Did not committed non-binary file')
		This.AssertEquals(This.cFile, This.oOperations.aCommitFiles[1], ;
			'Did not specify correct file')
	endfunc

*******************************************************************************
* Test that AddFile does not commit a file if not supposed to
*******************************************************************************
	function Test_AddFile_NoCommitAutoCommit
		This.SetupOperations(1, .T.)
		This.oOperations.AddFile(This.cFile, .T.)
		This.AssertFalse(This.oOperations.lCommitFilesCalled, ;
			'Committed file')
	endfunc

*******************************************************************************
* Test that AddFile adds a binary file
*******************************************************************************
	function Test_AddFile_AddsBinaryFile
		This.CreateClass()
		lcFile = This.cTestDataFolder + 'test.vcx'
		This.oOperations.AddFile(lcFile)
		erase (lcFile)
		erase (forceext(lcFile, 'vct'))
		This.AssertEquals(lcFile,  This.oOperations.aFiles[1], ;
			'Did not add binary file')
	endfunc

*******************************************************************************
* Test that AddFile adds the associated file of a binary file
*******************************************************************************
	function Test_AddFile_AddsAssociatedBinaryFile
		This.CreateClass()
		lcFile = This.cTestDataFolder + 'test.vcx'
		This.oOperations.AddFile(lcFile)
		erase (lcFile)
		lcVCT = forceext(lcFile, 'vct')
		erase (lcVCT)
		This.AssertEquals(lcVCT, This.oOperations.aFiles[2], ;
			'Did not add associated file')
	endfunc

*******************************************************************************
* Test that AddFile creates the text version of a binary file for text only
*******************************************************************************
	function Test_AddFile_CreatesTextVersion_TextOnly
		This.SetupOperations(2, .F.)
		This.CreateClass()
		lcFile = This.cTestDataFolder + 'test.vcx'
		This.oOperations.AddFile(lcFile)
		lcText   = forceext(lcFile, 'vc2')
		llExists = file(lcText)
		erase (lcFile)
		erase (forceext(lcFile, 'vct'))
		erase (lcText)
		This.AssertTrue(llExists, 'Did not create text file')
	endfunc

*******************************************************************************
* Test that AddFile creates the text version of a binary file for both text and
* binary
*******************************************************************************
	function Test_AddFile_CreatesTextVersion_Both
		This.SetupOperations(3, .F.)
		This.CreateClass()
		lcFile = This.cTestDataFolder + 'test.vcx'
		This.oOperations.AddFile(lcFile)
		lcText   = forceext(lcFile, 'vc2')
		llExists = file(lcText)
		erase (lcFile)
		erase (forceext(lcFile, 'vct'))
		erase (lcText)
		This.AssertTrue(llExists, 'Did not create text file')
	endfunc

*******************************************************************************
* Test that AddFile adds only the text version of a binary file
*******************************************************************************
	function Test_AddFile_AddsOnlyTextVersionOfBinaryFile
		This.SetupOperations(2, .F.)
		This.CreateClass()
		lcFile = This.cTestDataFolder + 'test.vcx'
		This.oOperations.AddFile(lcFile)
		erase (lcFile)
		erase (forceext(lcFile, 'vct'))
		This.AssertFalse(alen(This.oOperations.aFiles) > 1, ;
			'Added binary files')
		This.AssertEquals(forceext(lcFile, 'vc2'), ;
			This.oOperations.aFiles[1], 'Did not add text file')
	endfunc

*******************************************************************************
* Test that AddFile adds both text and binary files
*******************************************************************************
	function Test_AddFile_AddsTextAndBinaryFiles
		This.SetupOperations(3, .F.)
		This.CreateClass()
		lcFile = This.cTestDataFolder + 'test.vcx'
		This.oOperations.AddFile(lcFile)
		erase (lcFile)
		erase (forceext(lcFile, 'vct'))
		This.AssertEquals(3, alen(This.oOperations.aFiles), ;
			'Did not add all files')
	endfunc

*******************************************************************************
* Test that AddFile commits all files if auto-commit
*******************************************************************************
	function Test_AddFile_CommitsAllFilesAutoCommit
		This.SetupOperations(3, .T.)
		This.CreateClass()
		lcFile = This.cTestDataFolder + 'test.vcx'
		This.oOperations.AddFile(lcFile)
		erase (lcFile)
		erase (forceext(lcFile, 'vct'))
		This.AssertEquals(3, alen(This.oOperations.aCommitFiles), ;
			'Did not commit all files')
	endfunc

*******************************************************************************
* Test that AddFiles fails if an invalid array is passed (this actually
* tests all the ways it can fail in one test)
*******************************************************************************
	function Test_AddFiles_Fails_InvalidArray
		llOK = This.oOperations.AddFiles()
		This.AssertFalse(llOK, 'Returned .T. when no array passed')
		dimension laFiles[1]
		llOK = This.oOperations.AddFiles(@laFiles)
		This.AssertFalse(llOK, ;
			'Returned .T. when array with empty element passed')
		laFiles[1] = ''
		llOK = This.oOperations.AddFiles(@laFiles)
		This.AssertFalse(llOK, ;
			'Returned .T. when array with empty element passed')
		laFiles[1] = 'xxx'
		llOK = This.oOperations.AddFiles(@laFiles)
		This.AssertFalse(llOK, ;
			'Returned .T. when array with non-existent file passed')
	endfunc

*******************************************************************************
* Test that AddFiles succeeds
*******************************************************************************
	function Test_AddFiles_Succeeds
		dimension laFiles[1]
		laFiles[1] = This.cFile
		This.oOperations.AddFiles(@laFiles)
		This.AssertEquals(This.cFile, This.oOperations.aFiles[1], ;
			'Did not add file')
	endfunc

*******************************************************************************
* Test that AddFiles closes a table
*******************************************************************************
	function Test_AddFiles_ClosesTable
		lcFile = This.cTestDataFolder + 'test.dbf'
		create table (lcFile) (FIELD1 C(1))
		dimension laFiles[1]
		laFiles[1] = lcFile
		This.oOperations.AddFiles(@laFiles)
		erase (lcFile)
		This.AssertFalse(used('test'), 'Did not close table')
	endfunc

*******************************************************************************
* Test that AddFiles closes a database
*******************************************************************************
	function Test_AddFiles_ClosesDatabase
		lcFile = This.cTestDataFolder + 'test.dbc'
		create database (lcFile)
		dimension laFiles[1]
		laFiles[1] = lcFile
		This.oOperations.AddFiles(@laFiles)
		erase (lcFile)
		erase (forceext(lcFile, 'dcx'))
		erase (forceext(lcFile, 'dct'))
		This.AssertFalse(dbused(lcFile), 'Did not close database')
	endfunc

*******************************************************************************
* Test that AddFiles calls the BeforeAddFilesToVersionControl addin
*******************************************************************************
	function Test_AddFiles_CallsBeforeAddFilesToVersionControl
		dimension laFiles[1]
		laFiles[1] = This.cFile
		llWorks = This.oOperations.AddFiles(@laFiles)
		llAddin = ascan(This.oAddins.aMethods, 'BeforeAddFilesToVersionControl') > 0
		This.AssertTrue(llAddin, ;
			'Did not call BeforeAddFilesToVersionControl')
		This.AssertTrue(llWorks, ;
			'Returned .F. when addin returned .T.')
	endfunc

*******************************************************************************
* Test that AddFiles calls the AfterAddFilesToVersionControl addin
*******************************************************************************
	function Test_AddFiles_CallsAfterAddFiles
		dimension laFiles[1]
		laFiles[1] = This.cFile
		This.oOperations.AddFiles(@laFiles)
		llAddin = ascan(This.oAddins.aMethods, 'AfterAddFilesToVersionControl') > 0
		This.AssertTrue(llAddin, ;
			'Did not call AfterAddFilesToVersionControl')
	endfunc

*******************************************************************************
* Test that AddFiles fails if the BeforeAddFilesToVersionControl addin returns .F.
*******************************************************************************
	function Test_AddFiles_Fails_IfBeforeAddFileToVersionControlReturnsFalse
		dimension laFiles[1]
		laFiles[1] = This.cFile
		This.oAddins.lValueToReturn = .F.
		llWorks = This.oOperations.AddFiles(@laFiles)
		This.AssertFalse(llWorks, 'Returned .T. when addin returned .F.')
	endfunc

*******************************************************************************
* Test that RemoveFile removes a non-binary file
*******************************************************************************
	function Test_RemoveFile_RemovesNonBinaryFile
		This.oOperations.RemoveFile(This.cFile)
		This.AssertEquals(This.cFile, This.oOperations.aFiles[1], ;
			'Did not remove non-binary file')
	endfunc

*******************************************************************************
* Test that RemoveFile does not commit a file if not auto-commit
*******************************************************************************
	function Test_RemoveFile_NoCommit
		This.oOperations.RemoveFile(This.cFile)
		This.AssertFalse(This.oOperations.lCommitFilesCalled, ;
			'Committed file')
	endfunc

*******************************************************************************
* Test that RemoveFile commits a file if auto-commit
*******************************************************************************
	function Test_RemoveFile_CommitsFileAutoCommit
		This.SetupOperations(1, .T.)
		This.oOperations.RemoveFile(This.cFile)
		This.AssertTrue(This.oOperations.lCommitFilesCalled, ;
			'Did not committed non-binary file')
		This.AssertEquals(This.cFile, This.oOperations.aCommitFiles[1], ;
			'Did not specify correct file')
	endfunc

*******************************************************************************
* Test that RemoveFile removes a binary file
*******************************************************************************
	function Test_RemoveFile_RemovesBinaryFile
		This.CreateClass()
		lcFile = This.cTestDataFolder + 'test.vcx'
		This.oOperations.RemoveFile(lcFile)
		erase (lcFile)
		erase (forceext(lcFile, 'vct'))
		This.AssertEquals(lcFile, This.oOperations.aFiles[1], ;
			'Did not remove binary file')
	endfunc

*******************************************************************************
* Test that RemoveFile removes the associated file of a binary file
*******************************************************************************
	function Test_RemoveFile_RemovesAssociatedBinaryFile
		This.CreateClass()
		lcFile = This.cTestDataFolder + 'test.vcx'
		lcVCT  = forceext(lcFile, 'vct')
		This.oOperations.RemoveFile(lcFile)
		erase (lcFile)
		erase (lcVCT)
		This.AssertEquals(lcVCT, This.oOperations.aFiles[2], ;
			'Did not remove associated file')
	endfunc

*******************************************************************************
* Test that RemoveFile removes only the text version of a binary file
*******************************************************************************
	function Test_RemoveFile_RemovesOnlyTextVersionOfBinaryFile
		This.SetupOperations(2, .F.)
		This.CreateClass()
		lcFile = This.cTestDataFolder + 'test.vcx'
		This.oOperations.RemoveFile(lcFile)
		erase (lcFile)
		erase (forceext(lcFile, 'vct'))
		This.AssertFalse(alen(This.oOperations.aFiles) > 1, ;
			'Removed binary files')
		This.AssertEquals(forceext(lcFile, 'vc2'), ;
			This.oOperations.aFiles[1], 'Did not remove text file')
	endfunc

*******************************************************************************
* Test that RemoveFile removes both text and binary files
*******************************************************************************
	function Test_RemoveFile_RemovesTextAndBinaryFiles
		This.SetupOperations(3, .F.)
		This.CreateClass()
		lcFile = This.cTestDataFolder + 'test.vcx'
		This.oOperations.RemoveFile(lcFile)
		erase (lcFile)
		erase (forceext(lcFile, 'vct'))
		This.AssertEquals(3, alen(This.oOperations.aFiles), ;
			'Did not remove all files')
	endfunc

*******************************************************************************
* Test that RemoveFile commits all files if auto-commit
*******************************************************************************
	function Test_RemoveFile_CommitsAllFilesAutoCommit
		This.SetupOperations(3, .T.)
		This.CreateClass()
		lcFile = This.cTestDataFolder + 'test.vcx'
		This.oOperations.RemoveFile(lcFile)
		erase (lcFile)
		erase (forceext(lcFile, 'vct'))
		This.AssertEquals(3, alen(This.oOperations.aCommitFiles), ;
			'Did not commit all files')
	endfunc

*******************************************************************************
* Test that RemoveFiles fails if an invalid array is passed (this actually
* tests all the ways it can fail in one test)
*******************************************************************************
	function Test_RemoveFiles_Fails_InvalidArray
		llOK = This.oOperations.RemoveFiles()
		This.AssertFalse(llOK, 'Returned .T. when no array passed')
		dimension laFiles[1]
		llOK = This.oOperations.RemoveFiles(@laFiles)
		This.AssertFalse(llOK, ;
			'Returned .T. when array with empty element passed')
		laFiles[1] = ''
		llOK = This.oOperations.RemoveFiles(@laFiles)
		This.AssertFalse(llOK, ;
			'Returned .T. when array with empty element passed')
		laFiles[1] = 'xxx'
		llOK = This.oOperations.RemoveFiles(@laFiles)
		This.AssertFalse(llOK, ;
			'Returned .T. when array with non-existent file passed')
	endfunc

*******************************************************************************
* Test that RemoveFiles succeeds
*******************************************************************************
	function Test_RemoveFiles_Succeeds
		dimension laFiles[1]
		laFiles[1] = This.cFile
		This.oOperations.RemoveFiles(@laFiles)
		This.AssertEquals(This.cFile, This.oOperations.aFiles[1], ;
			'Did not remove file')
	endfunc

*******************************************************************************
* Test that RemoveFiles closes a table
*******************************************************************************
	function Test_RemoveFiles_ClosesTable
		lcFile = This.cTestDataFolder + 'test.dbf'
		create table (lcFile) (FIELD1 C(1))
		dimension laFiles[1]
		laFiles[1] = lcFile
		This.oOperations.RemoveFiles(@laFiles)
		erase (lcFile)
		This.AssertFalse(used('test'), 'Did not close table')
	endfunc

*******************************************************************************
* Test that RemoveFiles closes a database
*******************************************************************************
	function Test_RemoveFiles_ClosesDatabase
		lcFile = This.cTestDataFolder + 'test.dbc'
		create database (lcFile)
		dimension laFiles[1]
		laFiles[1] = lcFile
		This.oOperations.RemoveFiles(@laFiles)
		erase (lcFile)
		erase (forceext(lcFile, 'dcx'))
		erase (forceext(lcFile, 'dct'))
		This.AssertFalse(dbused(lcFile), 'Did not close database')
	endfunc

*******************************************************************************
* Test that RemoveFiles calls the BeforeRemoveFilesFromVersionControl addin
*******************************************************************************
	function Test_RemoveFiles_CallsBeforeRemoveFilesFromVersionControl
		dimension laFiles[1]
		laFiles[1] = This.cFile
		llWorks = This.oOperations.RemoveFiles(@laFiles)
		llAddin = ascan(This.oAddins.aMethods, 'BeforeRemoveFilesFromVersionControl') > 0
		This.AssertTrue(llAddin, ;
			'Did not call BeforeRemoveFilesFromVersionControl')
		This.AssertTrue(llWorks, ;
			'Returned .F. when addin returned .T.')
	endfunc

*******************************************************************************
* Test that RemoveFiles calls the AfterRemoveFilesFromVersionControl addin
*******************************************************************************
	function Test_RemoveFiles_CallsAfterRemoveFilesFromVersionControl
		dimension laFiles[1]
		laFiles[1] = This.cFile
		This.oOperations.RemoveFiles(@laFiles)
		llAddin = ascan(This.oAddins.aMethods, 'AfterRemoveFilesFromVersionControl') > 0
		This.AssertTrue(llAddin, ;
			'Did not call AfterRemoveFilesFromVersionControl')
	endfunc

*******************************************************************************
* Test that RemoveFiles fails if the BeforeRemoveFilesFromVersionControl addin returns .F.
*******************************************************************************
	function Test_RemoveFiles_Fails_IfBeforeRemoveFilesFromVersionControlReturnsFalse
		dimension laFiles[1]
		laFiles[1] = This.cFile
		This.oAddins.lValueToReturn = .F.
		llWorks = This.oOperations.RemoveFiles(@laFiles)
		This.AssertFalse(llWorks, 'Returned .T. when addin returned .F.')
	endfunc

*******************************************************************************
* Test that RevertFile reverts a non-binary file
*******************************************************************************
	function Test_RevertFile_RevertsNonBinaryFile
		This.oOperations.RevertFile(This.cFile)
		This.AssertEquals(This.cFile, This.oOperations.aFiles[1], ;
			'Did not revert non-binary file')
	endfunc

*******************************************************************************
* Test that RevertFile reverts a binary file
*******************************************************************************
	function Test_RevertFile_RevertsBinaryFile
		This.CreateClass()
		lcFile = This.cTestDataFolder + 'test.vcx'
		This.oOperations.RevertFile(lcFile)
		erase (lcFile)
		erase (forceext(lcFile, 'vct'))
		This.AssertEquals(lcFile, This.oOperations.aFiles[1], ;
			'Did not revert binary file')
	endfunc

*******************************************************************************
* Test that RevertFile reverts the associated file of a binary file
*******************************************************************************
	function Test_RevertFile_RevertsAssociatedBinaryFile
		This.CreateClass()
		lcFile = This.cTestDataFolder + 'test.vcx'
		lcVCT  = forceext(lcFile, 'vct')
		This.oOperations.RevertFile(lcFile)
		erase (lcFile)
		erase (lcVCT)
		This.AssertEquals(lcVCT, This.oOperations.aFiles[2], ;
			'Did not revert associated file')
	endfunc

*******************************************************************************
* Test that RevertFile reverts only the text version of a binary file
*******************************************************************************
	function Test_RevertFile_RevertsOnlyTextVersionOfBinaryFile
		This.SetupOperations(2, .F.)
		This.CreateClass()
		lcFile = This.cTestDataFolder + 'test.vcx'
		This.oOperations.RevertFile(lcFile)
		erase (lcFile)
		erase (forceext(lcFile, 'vct'))
		This.AssertFalse(alen(This.oOperations.aFiles) > 1, ;
			'Reverted binary files')
		This.AssertEquals(forceext(lcFile, 'vc2'), ;
			This.oOperations.aFiles[1], 'Did not revert text file')
	endfunc

*******************************************************************************
* Test that RevertFile reverts both text and binary files
*******************************************************************************
	function Test_RevertFile_RevertsTextAndBinaryFiles
		This.SetupOperations(3, .F.)
		This.CreateClass()
		lcFile = This.cTestDataFolder + 'test.vcx'
		This.oOperations.RevertFile(lcFile)
		erase (lcFile)
		erase (forceext(lcFile, 'vct'))
		This.AssertEquals(3, alen(This.oOperations.aFiles), ;
			'Did not revert all files')
	endfunc

*******************************************************************************
* Test that RevertFiles fails if an invalid array is passed (this actually
* tests all the ways it can fail in one test)
*******************************************************************************
	function Test_RevertFiles_Fails_InvalidArray
		llOK = This.oOperations.RevertFiles()
		This.AssertFalse(llOK, 'Returned .T. when no array passed')
		dimension laFiles[1]
		llOK = This.oOperations.RevertFiles(@laFiles)
		This.AssertFalse(llOK, ;
			'Returned .T. when array with empty element passed')
		laFiles[1] = ''
		llOK = This.oOperations.RevertFiles(@laFiles)
		This.AssertFalse(llOK, ;
			'Returned .T. when array with empty element passed')
		laFiles[1] = 'xxx'
		llOK = This.oOperations.RevertFiles(@laFiles)
		This.AssertFalse(llOK, ;
			'Returned .T. when array with non-existent file passed')
	endfunc

*******************************************************************************
* Test that RevertFiles succeeds
*******************************************************************************
	function Test_RevertFiles_Succeeds
		dimension laFiles[1]
		laFiles[1] = This.cFile
		This.oOperations.RevertFiles(@laFiles)
		This.AssertEquals(This.cFile, This.oOperations.aFiles[1], ;
			'Did not revert file')
	endfunc

*******************************************************************************
* Test that RevertFiles closes a table
*******************************************************************************
	function Test_RevertFiles_ClosesTable
		lcFile = This.cTestDataFolder + 'test.dbf'
		create table (lcFile) (FIELD1 C(1))
		dimension laFiles[1]
		laFiles[1] = lcFile
		This.oOperations.RevertFiles(@laFiles)
		erase (lcFile)
		This.AssertFalse(used('test'), 'Did not close table')
	endfunc

*******************************************************************************
* Test that RevertFiles closes a database
*******************************************************************************
	function Test_RevertFiles_ClosesDatabase
		lcFile = This.cTestDataFolder + 'test.dbc'
		create database (lcFile)
		dimension laFiles[1]
		laFiles[1] = lcFile
		This.oOperations.RevertFiles(@laFiles)
		erase (lcFile)
		erase (forceext(lcFile, 'dcx'))
		erase (forceext(lcFile, 'dct'))
		This.AssertFalse(dbused(lcFile), 'Did not close database')
	endfunc

*******************************************************************************
* Test that RevertFiles calls the BeforeRevertFiles addin
*******************************************************************************
	function Test_RevertFiles_CallsBeforeRevertFiles
		dimension laFiles[1]
		laFiles[1] = This.cFile
		llWorks = This.oOperations.RevertFiles(@laFiles)
		llAddin = ascan(This.oAddins.aMethods, 'BeforeRevertFiles') > 0
		This.AssertTrue(llAddin, ;
			'Did not call BeforeRevertFiles')
		This.AssertTrue(llWorks, ;
			'Returned .F. when addin returned .T.')
	endfunc

*******************************************************************************
* Test that RevertFiles calls the AfterRevertFiles addin
*******************************************************************************
	function Test_RevertFiles_CallsAfterRevertFiles
		dimension laFiles[1]
		laFiles[1] = This.cFile
		This.oOperations.RevertFiles(@laFiles)
		llAddin = ascan(This.oAddins.aMethods, 'AfterRevertFiles') > 0
		This.AssertTrue(llAddin, ;
			'Did not call AfterRevertFiles')
	endfunc

*******************************************************************************
* Test that RevertFiles fails if the BeforeRevertFiles addin returns .F.
*******************************************************************************
	function Test_RevertFiles_Fails_IfBeforeRevertFilesReturnsFalse
		dimension laFiles[1]
		laFiles[1] = This.cFile
		This.oAddins.lValueToReturn = .F.
		llWorks = This.oOperations.RevertFiles(@laFiles)
		This.AssertFalse(llWorks, 'Returned .T. when addin returned .F.')
	endfunc

*******************************************************************************
* Test that CommitFile commits a non-binary file
*******************************************************************************
	function Test_CommitFile_CommitsNonBinaryFile
		This.oOperations.CommitFile('commit', This.cFile)
		This.AssertEquals(This.cFile, ;
			This.oOperations.aCommitFiles[1], 'Did not commit non-binary file')
	endfunc

*******************************************************************************
* Test that CommitFile commits a binary file
*******************************************************************************
	function Test_CommitFile_CommitsBinaryFile
		This.CreateClass()
		lcFile = This.cTestDataFolder + 'test.vcx'
		This.oOperations.CommitFile('commit', lcFile)
		erase (lcFile)
		erase (forceext(lcFile, 'vct'))
		This.AssertEquals(lcFile, ;
			This.oOperations.aCommitFiles[1], 'Did not commit binary file')
	endfunc

*******************************************************************************
* Test that CommitFile commits the associated file of a binary file
*******************************************************************************
	function Test_CommitFile_CommitsAssociatedBinaryFile
		This.CreateClass()
		lcFile = This.cTestDataFolder + 'test.vcx'
		This.oOperations.CommitFile('commit', lcFile)
		erase (lcFile)
		lcVCT = forceext(lcFile, 'vct')
		erase (lcVCT)
		This.AssertEquals(lcVCT, ;
			This.oOperations.aCommitFiles[2], 'Did not commit associated file')
	endfunc

*******************************************************************************
* Test that CommitFile commits only the text version of a binary file
*******************************************************************************
	function Test_CommitFile_CommitsOnlyTextVersionOfBinaryFile
		This.SetupOperations(2, .F.)
		This.CreateClass()
		lcFile = This.cTestDataFolder + 'test.vcx'
		This.oOperations.CommitFile('commit', lcFile)
		lcText = forceext(lcFile, 'vc2')
		erase (lcFile)
		erase (forceext(lcFile, 'vct'))
		erase (lcText)
		This.AssertFalse(alen(This.oOperations.aCommitFiles) > 1, ;
			'Committed binary files')
		This.AssertEquals(lcText, ;
			This.oOperations.aCommitFiles[1], 'Did not commit text file')
	endfunc

*******************************************************************************
* Test that CommitFile commits both text and binary files
*******************************************************************************
	function Test_CommitFile_CommitsTextAndBinaryFiles
		This.SetupOperations(3, .F.)
		This.CreateClass()
		lcFile = This.cTestDataFolder + 'test.vcx'
		This.oOperations.CommitFile('commit', lcFile)
		erase (lcFile)
		erase (forceext(lcFile, 'vct'))
		This.AssertEquals(3, alen(This.oOperations.aCommitFiles), ;
			'Did not commit all files')
	endfunc

*******************************************************************************
* Test that CommitFile creates the text version of a binary file for text only
*******************************************************************************
	function Test_CommitFile_CreatesTextVersion_TextOnly
		This.SetupOperations(2, .F.)
		This.CreateClass()
		lcFile = This.cTestDataFolder + 'test.vcx'
		This.oOperations.CommitFile('commit', lcFile)
		lcText   = forceext(lcFile, 'vc2')
		llExists = file(lcText)
		erase (lcFile)
		erase (forceext(lcFile, 'vct'))
		erase (lcText)
		This.AssertTrue(llExists, 'Did not create text file')
	endfunc

*******************************************************************************
* Test that CommitFile creates the text version of a binary file for both text
* and binary
*******************************************************************************
	function Test_CommitFile_CreatesTextVersion_Both
		This.SetupOperations(3, .F.)
		This.CreateClass()
		lcFile = This.cTestDataFolder + 'test.vcx'
		This.oOperations.CommitFile('commit', lcFile)
		lcText   = forceext(lcFile, 'vc2')
		llExists = file(lcText)
		erase (lcFile)
		erase (forceext(lcFile, 'vct'))
		erase (lcText)
		This.AssertTrue(llExists, 'Did not create text file')
	endfunc

*******************************************************************************
* Test that CommitFiles fails if an invalid message is passed (this actually
* tests all the ways it can fail in one test)
*******************************************************************************
	function Test_CommitFiles_Fails_InvalidMessage
		llOK = This.oOperations.CommitFiles()
		This.AssertFalse(llOK, 'Returned .T. when no message passed')
		llOK = This.oOperations.CommitFiles('')
		This.AssertFalse(llOK, 'Returned .T. when empty message passed')
	endfunc

*******************************************************************************
* Test that CommitFiles fails if an invalid array is passed (this actually
* tests all the ways it can fail in one test)
*******************************************************************************
	function Test_CommitFiles_Fails_InvalidArray
		llOK = This.oOperations.CommitFiles('commit')
		This.AssertFalse(llOK, 'Returned .T. when no array passed')
		dimension laFiles[1]
		llOK = This.oOperations.CommitFiles('commit', @laFiles)
		This.AssertFalse(llOK, ;
			'Returned .T. when array with empty element passed')
		laFiles[1] = ''
		llOK = This.oOperations.CommitFiles('commit', @laFiles)
		This.AssertFalse(llOK, ;
			'Returned .T. when array with empty element passed')
		laFiles[1] = 'xxx'
		llOK = This.oOperations.CommitFiles('commit', @laFiles)
		This.AssertFalse(llOK, ;
			'Returned .T. when array with non-existent file passed')
	endfunc

*******************************************************************************
* Test that CommitFiles succeeds if parameters are correct
*******************************************************************************
	function Test_CommitFiles_Succeeds
		dimension laFiles[1]
		laFiles[1] = This.cFile
		llOK = This.oOperations.CommitFiles('commit', @laFiles)
		This.AssertTrue(llOK, 'Returned .F. when valid parameters passed')
	endfunc

*******************************************************************************
* Test that CommitFiles closes a table
*******************************************************************************
	function Test_CommitFiles_ClosesTable
		dimension laFiles[1]
		laFiles[1] = This.cTestDataFolder + 'test.dbf'
		create table (laFiles[1]) (FIELD1 C(1))
		This.oOperations.CommitFiles('commit', @laFiles)
		erase (laFiles[1])
		This.AssertFalse(used('test'), 'Did not close table')
	endfunc

*******************************************************************************
* Test that CommitFiles closes a database
*******************************************************************************
	function Test_CommitFiles_ClosesDatabase
		dimension laFiles[1]
		laFiles[1] = This.cTestDataFolder + 'test.dbc'
		create database (laFiles[1])
		This.oOperations.CommitFiles('commit', @laFiles)
		erase (laFiles[1])
		erase (forceext(laFiles[1], 'dcx'))
		erase (forceext(laFiles[1], 'dct'))
		This.AssertFalse(dbused(laFiles[1]), 'Did not close database')
	endfunc

*******************************************************************************
* Test that CommitFiles calls the BeforeCommitFiles addin
*******************************************************************************
	function Test_CommitFiles_CallsBeforeCommitFiles
		dimension laFiles[1]
		laFiles[1] = This.cFile
		llWorks = This.oOperations.CommitFiles('commit', @laFiles)
		llAddin = ascan(This.oAddins.aMethods, 'BeforeCommitFiles') > 0
		This.AssertTrue(llAddin, ;
			'Did not call BeforeCommitFiles')
		This.AssertTrue(llWorks, ;
			'Returned .F. when addin returned .T.')
	endfunc

*******************************************************************************
* Test that CommitFiles calls the AfterCommitFiles addin
*******************************************************************************
	function Test_CommitFiles_CallsAfterCommitFiles
		dimension laFiles[1]
		laFiles[1] = This.cFile
		llWorks = This.oOperations.CommitFiles('commit', @laFiles)
		llAddin = ascan(This.oAddins.aMethods, 'AfterCommitFiles') > 0
		This.AssertTrue(llAddin, ;
			'Did not call AfterCommitFiles')
	endfunc

*******************************************************************************
* Test that CommitFiles fails if the BeforeCommitFiles addin returns .F.
*******************************************************************************
	function Test_CommitFiles_Fails_IfBeforeCommitFilesReturnsFalse
		This.oAddins.lValueToReturn = .F.
		dimension laFiles[1]
		laFiles[1] = This.cFile
		llWorks = This.oOperations.CommitFiles('commit', @laFiles)
		This.AssertFalse(llWorks, 'Returned .T. when addin returned .F.')
	endfunc

*******************************************************************************
* Test that ConvertBinaryToText creates a text file for a binary file
*******************************************************************************
	function Test_ConvertBinaryToText_CreatesTextFile
		This.CreateClass()
		lcFile = This.cTestDataFolder + 'test.vcx'
		This.oOperations.ConvertBinaryToText(lcFile)
		lcText   = forceext(lcFile, 'vc2')
		llExists = file(lcFile)
		erase (lcFile)
		erase (forceext(lcFile, 'vct'))
		erase (lcText)
		This.AssertTrue(llExists, 'Did not create text file')
	endfunc

*******************************************************************************
* Test that CommitAllFiles fails if an invalid project is passed (this actually
* tests all the ways it can fail in one test)
*******************************************************************************
	function Test_CommitAllFiles_Fails_InvalidProject
		llOK = This.oOperations.CommitAllFiles('commit')
		This.AssertFalse(llOK, 'Returned .T. when no array passed')
		dimension laFiles[1]
		llOK = This.oOperations.CommitAllFiles('commit', @laFiles)
		This.AssertFalse(llOK, ;
			'Returned .T. when array with empty element passed')
		laFiles[1] = ''
		llOK = This.oOperations.CommitAllFiles('commit', @laFiles)
		This.AssertFalse(llOK, ;
			'Returned .T. when array with empty element passed')
		laFiles[1] = 'xxx'
		llOK = This.oOperations.CommitAllFiles('commit', @laFiles)
		This.AssertFalse(llOK, ;
			'Returned .T. when array with non-existent file passed')
	endfunc

*******************************************************************************
* Test that CommitAllFiles fails if an invalid message is passed (this actually
* tests all the ways it can fail in one test)
*******************************************************************************
	function Test_CommitAllFiles_Fails_InvalidMessage
		dimension laFiles[1]
		laFiles[1] = This.cFile
		llOK = This.oOperations.CommitAllFiles(.F., @laFiles)
		This.AssertFalse(llOK, 'Returned .T. when no message passed')
		llOK = This.oOperations.CommitAllFiles('', @laFiles)
		This.AssertFalse(llOK, 'Returned .T. when empty message passed')
	endfunc

*******************************************************************************
* Test that CommitAllFiles creates the text version of binary files for text
* only
*******************************************************************************
	function Test_CommitAllFiles_CreatesTextVersion_TextOnly
		This.SetupOperations(2, .F.)
		This.CreateClass()
		lcProject = This.cTestDataFolder + sys(2015) + '.pjx'
		lcFile    = This.cTestDataFolder + 'test.vcx'
		create project (lcProject) nowait noshow
		_vfp.ActiveProject.Files.Add(lcFile)
		dimension laFiles[1]
		laFiles[1] = lcProject
		This.oOperations.CommitAllFiles('commit', @laFiles)
		lcText          = forceext(lcFile, 'vc2')
		lcTextProject   = forceext(lcProject, 'pj2')
		llExists        = file(lcText)
		llExistsProject = file(lcTextProject)
		_vfp.ActiveProject.Close()
		erase (lcFile)
		erase (forceext(lcFile, 'vct'))
		erase (lcText)
		erase (lcTextProject)
		erase (lcProject)
		erase (forceext(lcProject, 'pjt'))
		This.AssertTrue(llExists, 'Did not create text file for class')
		This.AssertTrue(llExistsProject, 'Did not create text file for project')
	endfunc

*******************************************************************************
* Test that CommitAllFiles creates the text version of binary files for both
* text and binary
*******************************************************************************
	function Test_CommitAllFiles_CreatesTextVersion_Both
		This.SetupOperations(3, .F.)
		This.CreateClass()
		lcProject = This.cTestDataFolder + sys(2015) + '.pjx'
		lcFile    = This.cTestDataFolder + 'test.vcx'
		create project (lcProject) nowait noshow
		_vfp.ActiveProject.Files.Add(lcFile)
		dimension laFiles[1]
		laFiles[1] = lcProject
		This.oOperations.CommitAllFiles('commit', @laFiles)
		lcText          = forceext(lcFile, 'vc2')
		lcTextProject   = forceext(lcProject, 'pj2')
		llExists        = file(lcText)
		llExistsProject = file(lcTextProject)
		_vfp.ActiveProject.Close()
		erase (lcFile)
		erase (forceext(lcFile, 'vct'))
		erase (lcText)
		erase (lcTextProject)
		erase (lcProject)
		erase (forceext(lcProject, 'pjt'))
		This.AssertTrue(llExists, 'Did not create text file for class')
		This.AssertTrue(llExistsProject, 'Did not create text file for project')
	endfunc

*******************************************************************************
* Test that CommitAllFiles calls the BeforeCommitAllFiles addin
*******************************************************************************
	function Test_CommitAllFiles_CallsBeforeCommitAllFiles
		dimension laFiles[1]
		laFiles[1] = This.cFile
		llWorks = This.oOperations.CommitAllFiles('commit', @laFiles)
		llAddin = ascan(This.oAddins.aMethods, 'BeforeCommitAllFiles') > 0
		This.AssertTrue(llAddin, ;
			'Did not call BeforeCommitAllFiles')
		This.AssertTrue(llWorks, ;
			'Returned .F. when addin returned .T.')
	endfunc

*******************************************************************************
* Test that CommitAllFiles calls the AfterCommitAllFiles addin
*******************************************************************************
	function Test_CommitAllFiles_CallsAfterCommitAllFiles
		dimension laFiles[1]
		laFiles[1] = This.cFile
		llWorks = This.oOperations.CommitAllFiles('commit', @laFiles)
		llAddin = ascan(This.oAddins.aMethods, 'AfterCommitAllFiles') > 0
		This.AssertTrue(llAddin, ;
			'Did not call AfterCommitAllFiles')
	endfunc

*******************************************************************************
* Test that CommitAllFiles fails if the BeforeCommitAllFiles addin returns .F.
*******************************************************************************
	function Test_CommitAllFiles_Fails_IfBeforeCommitAllFilesReturnsFalse
		dimension laFiles[1]
		laFiles[1] = This.cFile
		This.oAddins.lValueToReturn = .F.
		llWorks = This.oOperations.CommitAllFiles('commit', @laFiles)
		This.AssertFalse(llWorks, 'Returned .T. when addin returned .F.')
	endfunc

*******************************************************************************
* Test that GetStatusForFile fails if an invalid file is passed (this actually
* tests all the ways it can fail in one test)
*******************************************************************************
	function Test_GetStatusForFile_Fails_InvalidFile
		llOK = This.oOperations.GetStatusForFile()
		This.AssertFalse(llOK, 'Returned .T. when no file passed')
		llOK = This.oOperations.GetStatusForFile('')
		This.AssertFalse(llOK, 'Returned .T. when empty file passed')
		llOK = This.oOperations.GetStatusForFile('xxx.txt')
		This.AssertFalse(llOK, 'Returned .T. when non-existent file passed')
	endfunc

*******************************************************************************
* Test that GetStatusForFile succeeds if parameters are correct
*******************************************************************************
	function Test_GetStatusForFile_Succeeds
		llOK = This.oOperations.GetStatusForFile(This.cFile)
		This.AssertTrue(llOK, 'Returned .F. when valid parameters passed')
	endfunc

*******************************************************************************
* Test that GetStatusForFile handles VFP binary files
*******************************************************************************
	function Test_GetStatusForFile_HandlesBinaryFiles
		strtofile('x', This.cTestDataFolder + 'test.vcx')
		strtofile('x', This.cTestDataFolder + 'test.vct')
		This.oOperations.GetStatusForFile(This.cTestDataFolder + 'test.vcx')
		erase (This.cTestDataFolder + 'test.vcx')
		erase (This.cTestDataFolder + 'test.vct')
		This.AssertEquals('"' + This.cTestDataFolder + 'test.vcx" "' + ;
			This.cTestDataFolder + 'test.vct"', ;
			This.oOperations.cStatusFile, 'Did not check binary file')
	endfunc

*******************************************************************************
* Test that GetStatusForFile closes a table
*******************************************************************************
	function Test_GetStatusForFile_ClosesTable
		dimension laFiles[1]
		laFiles[1] = This.cTestDataFolder + 'test.dbf'
		create table (laFiles[1]) (FIELD1 C(1))
		This.oOperations.GetStatusForFile(laFiles[1])
		erase (laFiles[1])
		This.AssertFalse(used('test'), 'Did not close table')
	endfunc

*******************************************************************************
* Test that GetStatusForFile closes a database
*******************************************************************************
	function Test_GetStatusForFile_ClosesDatabase
		dimension laFiles[1]
		laFiles[1] = This.cTestDataFolder + 'test.dbc'
		create database (laFiles[1])
		This.oOperations.GetStatusForFile(laFiles[1])
		erase (laFiles[1])
		erase (forceext(laFiles[1], 'dcx'))
		erase (forceext(laFiles[1], 'dct'))
		This.AssertFalse(dbused(laFiles[1]), 'Did not close database')
	endfunc

*******************************************************************************
* Test that GetStatusForAllFiles fails if an invalid collection is passed (this
* actually tests all the ways it can fail in one test)
*******************************************************************************
	function Test_GetStatusForAllFiles_Fails_InvalidCollection
		llOK = This.oOperations.GetStatusForAllFiles()
		This.AssertFalse(llOK, 'Returned .T. when nothing passed')
		llOK = This.oOperations.GetStatusForAllFiles(createobject('Empty'))
		This.AssertFalse(llOK, 'Returned .T. when no collection passed')
	endfunc

*******************************************************************************
* Test that GetStatusForAllFiles succeeds if parameters are correct
*******************************************************************************
	function Test_GetStatusForAllFiles_Succeeds
		loCollection = createobject('Collection')
		llOK = This.oOperations.GetStatusForAllFiles(loCollection)
		This.AssertTrue(llOK, 'Returned .F. when valid parameters passed')
	endfunc

*******************************************************************************
* Test that CreateRepository calls the BeforeCreateRepository addin
*******************************************************************************
	function Test_CreateRepository_CallsBeforeCreateRepository
		llWorks = This.oOperations.CreateRepository(curdir())
		llAddin = ascan(This.oAddins.aMethods, 'BeforeCreateRepository') > 0
		This.AssertTrue(llAddin, ;
			'Did not call BeforeCreateRepository')
		This.AssertTrue(llWorks, ;
			'Returned .F. when addin returned .T.')
	endfunc

*******************************************************************************
* Test that CreateRepository calls the AfterCreateRepository addin
*******************************************************************************
	function Test_CreateRepository_CallsAfterCreateRepository
		llWorks = This.oOperations.CreateRepository(curdir())
		llAddin = ascan(This.oAddins.aMethods, 'AfterCreateRepository') > 0
		This.AssertTrue(llAddin, ;
			'Did not call AfterCreateRepository')
	endfunc

*******************************************************************************
* Test that CreateRepository fails if the BeforeCreateRepository addin returns .F.
*******************************************************************************
	function Test_CreateRepository_Fails_IfBeforeCreateRepositoryReturnsFalse
		This.oAddins.lValueToReturn = .F.
		llWorks = This.oOperations.CreateRepository(curdir())
		This.AssertFalse(llWorks, 'Returned .T. when addin returned .F.')
	endfunc

*******************************************************************************
* Test that RepositoryBrowser calls the BeforeRepositoryBrowser addin
*******************************************************************************
	function Test_RepositoryBrowser_CallsBeforeRepositoryBrowser
		llWorks = This.oOperations.RepositoryBrowser()
		llAddin = ascan(This.oAddins.aMethods, 'BeforeRepositoryBrowser') > 0
		This.AssertTrue(llAddin, ;
			'Did not call BeforeRepositoryBrowser')
		This.AssertTrue(llWorks, ;
			'Returned .F. when addin returned .T.')
	endfunc

*******************************************************************************
* Test that RepositoryBrowser calls the AfterRepositoryBrowser addin
*******************************************************************************
	function Test_RepositoryBrowser_CallsAfterRepositoryBrowser
		llWorks = This.oOperations.RepositoryBrowser()
		llAddin = ascan(This.oAddins.aMethods, 'AfterRepositoryBrowser') > 0
		This.AssertTrue(llAddin, ;
			'Did not call AfterCreateRepository')
	endfunc

*******************************************************************************
* Test that RepositoryBrowser fails if the BeforeRepositoryBrowser addin returns .F.
*******************************************************************************
	function Test_RepositoryBrowser_Fails_IfBeforeRepositoryBrowserReturnsFalse
		This.oAddins.lValueToReturn = .F.
		llWorks = This.oOperations.RepositoryBrowser()
		This.AssertFalse(llWorks, 'Returned .T. when addin returned .F.')
	endfunc

*******************************************************************************
* Test that RevisionHistory fails if an invalid file is passed (this actually
* tests all the ways it can fail in one test)
*******************************************************************************
	function Test_RevisionHistory_Fails_InvalidFile
		llOK = This.oOperations.RevisionHistory()
		This.AssertFalse(llOK, 'Returned .T. when no file passed')
		llOK = This.oOperations.RevisionHistory('')
		This.AssertFalse(llOK, 'Returned .T. when empty file passed')
		llOK = This.oOperations.RevisionHistory('xxx.txt')
		This.AssertFalse(llOK, 'Returned .T. when non-existent file passed')
	endfunc

*******************************************************************************
* Test that RevisionHistory calls the BeforeRevisionHistory addin
*******************************************************************************
	function Test_RevisionHistory_CallsBeforeRevisionHistory
		llWorks = This.oOperations.RevisionHistory(This.cFile)
		llAddin = ascan(This.oAddins.aMethods, 'BeforeRevisionHistory') > 0
		This.AssertTrue(llAddin, ;
			'Did not call BeforeRevisionHistory')
		This.AssertTrue(llWorks, ;
			'Returned .F. when addin returned .T.')
	endfunc

*******************************************************************************
* Test that RevisionHistory calls the AfterRevisionHistory addin
*******************************************************************************
	function Test_RevisionHistory_CallsAfterRevisionHistory
		llWorks = This.oOperations.RevisionHistory(This.cFile)
		llAddin = ascan(This.oAddins.aMethods, 'AfterRevisionHistory') > 0
		This.AssertTrue(llAddin, ;
			'Did not call AfterRevisionHistory')
	endfunc

*******************************************************************************
* Test that RevisionHistory fails if the BeforeRevisionHistory addin returns .F.
*******************************************************************************
	function Test_RevisionHistory_Fails_IfBeforeRevisionHistoryReturnsFalse
		This.oAddins.lValueToReturn = .F.
		llWorks = This.oOperations.RevisionHistory(This.cFile)
		This.AssertFalse(llWorks, 'Returned .T. when addin returned .F.')
	endfunc

*******************************************************************************
* Test that VisualDiff fails if an invalid file is passed (this actually
* tests all the ways it can fail in one test)
*******************************************************************************
	function Test_VisualDiff_Fails_InvalidFile
		llOK = This.oOperations.VisualDiff()
		This.AssertFalse(llOK, 'Returned .T. when no file passed')
		llOK = This.oOperations.VisualDiff('')
		This.AssertFalse(llOK, 'Returned .T. when empty file passed')
		llOK = This.oOperations.VisualDiff('xxx.txt')
		This.AssertFalse(llOK, 'Returned .T. when non-existent file passed')
	endfunc

*******************************************************************************
* Test that VisualDiff calls the BeforeVisualDiff addin
*******************************************************************************
	function Test_VisualDiff_CallsBeforeVisualDiff
		llWorks = This.oOperations.VisualDiff(This.cFile)
		llAddin = ascan(This.oAddins.aMethods, 'BeforeVisualDiff') > 0
		This.AssertTrue(llAddin, ;
			'Did not call BeforeVisualDiff')
		This.AssertTrue(llWorks, ;
			'Returned .F. when addin returned .T.')
	endfunc

*******************************************************************************
* Test that VisualDiff calls the AfterVisualDiff addin
*******************************************************************************
	function Test_VisualDiff_CallsAfterVisualDiff
		llWorks = This.oOperations.VisualDiff(This.cFile)
		llAddin = ascan(This.oAddins.aMethods, 'AfterVisualDiff') > 0
		This.AssertTrue(llAddin, ;
			'Did not call AfterVisualDiff')
	endfunc

*******************************************************************************
* Test that VisualDiff fails if the BeforeVisualDiff addin returns .F.
*******************************************************************************
	function Test_VisualDiff_Fails_IfBeforeVisualDiffReturnsFalse
		This.oAddins.lValueToReturn = .F.
		llWorks = This.oOperations.VisualDiff(This.cFile)
		This.AssertFalse(llWorks, 'Returned .T. when addin returned .F.')
	endfunc

*******************************************************************************
* Test that RenameFile renames a non-binary file
*******************************************************************************
	function Test_RenameFile_RenamesNonBinaryFile
		This.oOperations.RenameFile(This.cTestDataFolder + 'xx.txt', ;
			juststem(This.cFile))
		This.AssertEquals(This.cFile, This.oOperations.aFiles[1], ;
			'Did not rename non-binary file')
	endfunc

*******************************************************************************
* Test that RenameFile does not commit a file if not auto-commit
*******************************************************************************
	function Test_RenameFile_NoCommit
		This.oOperations.RenameFile(This.cTestDataFolder + 'xx.txt', ;
			juststem(This.cFile))
		This.AssertFalse(This.oOperations.lCommitAllFilesCalled, ;
			'Committed file')
	endfunc

*******************************************************************************
* Test that RenameFile commits a file if auto-commit
*******************************************************************************
	function Test_RenameFile_CommitsFileAutoCommit
		This.SetupOperations(1, .T.)
		This.oOperations.RenameFile(This.cTestDataFolder + 'xx.txt', ;
			juststem(This.cFile), 'commit')
		This.AssertTrue(This.oOperations.lCommitAllFilesCalled, ;
			'Did not commit non-binary file')
	endfunc

*******************************************************************************
* Test that RenameFile renames a binary file
*******************************************************************************
	function Test_RenameFile_RenamesBinaryFile
		This.CreateClass()
		lcFile = This.cTestDataFolder + 'test.vcx'
		This.oOperations.RenameFile(This.cTestDataFolder + 'xx.vcx', 'test')
		erase (lcFile)
		erase (forceext(lcFile, 'vct'))
		This.AssertEquals(lcFile, This.oOperations.aFiles[1], ;
			'Did not rename binary file')
	endfunc

*******************************************************************************
* Test that RenameFile renames the associated file of a binary file
*******************************************************************************
	function Test_RenameFile_RenamesAssociatedBinaryFile
		This.CreateClass()
		lcFile = This.cTestDataFolder + 'test.vcx'
		lcVCT  = forceext(lcFile, 'vct')
		This.oOperations.RenameFile(This.cTestDataFolder + 'xx.vcx', 'test')
		erase (lcFile)
		erase (lcVCT)
		This.AssertEquals(lcVCT, This.oOperations.aFiles[2], ;
			'Did not rename associated file')
	endfunc

*******************************************************************************
* Test that RenameFile renames only the text version of a binary file
*******************************************************************************
	function Test_RenameFile_RenamesOnlyTextVersionOfBinaryFile
		This.SetupOperations(2, .F.)
		This.CreateClass()
		lcFile = This.cTestDataFolder + 'test.vcx'
		This.oOperations.RenameFile(This.cTestDataFolder + 'xx.vcx', 'test')
		erase (lcFile)
		erase (forceext(lcFile, 'vct'))
		This.AssertFalse(alen(This.oOperations.aFiles) > 1, ;
			'Removed binary files')
		This.AssertEquals(forceext(lcFile, 'vc2'), ;
			This.oOperations.aFiles[1], 'Did not rename text file')
	endfunc

*******************************************************************************
* Test that RenameFile renames both text and binary files
*******************************************************************************
	function Test_RenameFile_RemovesTextAndBinaryFiles
		This.SetupOperations(3, .F.)
		This.CreateClass()
		lcFile = This.cTestDataFolder + 'test.vcx'
		This.oOperations.RenameFile(This.cTestDataFolder + 'xx.vcx', 'test')
		erase (lcFile)
		erase (forceext(lcFile, 'vct'))
		This.AssertEquals(3, alen(This.oOperations.aFiles), ;
			'Did not rename all files')
	endfunc

*******************************************************************************
* Test that RenameFile fails if a invalid file is passed (this actually
* tests all the ways it can fail in one test)
*******************************************************************************
	function Test_RenameFile_Fails_InvalidFile
		llOK = This.oOperations.RenameFile()
		This.AssertFalse(llOK, 'Returned .T. when no file passed')
		llOK = This.oOperations.RenameFile('')
		This.AssertFalse(llOK, ;
			'Returned .T. when empty file passed')
		llOK = This.oOperations.RenameFile(This.cFile)
		This.AssertFalse(llOK, ;
			'Returned .T. when file exists')
	endfunc

*******************************************************************************
* Test that RenameFile fails if a invalid new file is passed (this actually
* tests all the ways it can fail in one test)
*******************************************************************************
	function Test_RenameFile_Fails_InvalidNewFile
		llOK = This.oOperations.RenameFile('xx.txt')
		This.AssertFalse(llOK, 'Returned .T. when no new file passed')
		llOK = This.oOperations.RenameFile('xx.txt', '')
		This.AssertFalse(llOK, ;
			'Returned .T. when empty new file passed')
		llOK = This.oOperations.RenameFile('xx.txt', 'yy.txt')
		This.AssertFalse(llOK, ;
			'Returned .T. when file does not exist')
	endfunc

*******************************************************************************
* Test that RenameFile fails if an invalid message is passed (this actually
* test all the ways it can fail in one test)
*******************************************************************************
	function Test_RenameFile_Fails_InvalidMessage
		This.oOperations.lAutoCommitChanges = .T.
		llOK = This.oOperations.RenameFile('xx.txt', This.cFile)
		This.AssertFalse(llOK, 'Returned .T. when no message passed')
		llOK = This.oOperations.RenameFile('xx.txt', This.cFile, '')
		This.AssertFalse(llOK, 'Returned .T. when empty message passed')
	endfunc

*******************************************************************************
* Test that RenameFile calls the BeforeRenameFileInVersionControl addin
*******************************************************************************
	function Test_RenameFile_CallsBeforeRenameFileInVersionControl
		llWorks = This.oOperations.RenameFile(This.cTestDataFolder + 'xx.txt', ;
			juststem(This.cFile))
		llAddin = ascan(This.oAddins.aMethods, 'BeforeRenameFileInVersionControl') > 0
		This.AssertTrue(llAddin, ;
			'Did not call BeforeRenameFileInVersionControl')
		This.AssertTrue(llWorks, ;
			'Returned .F. when addin returned .T.')
	endfunc

*******************************************************************************
* Test that RenameFile calls the AfterRenameFileInVersionControl addin
*******************************************************************************
	function Test_RenameFile_CallsAfterRenameFileInVersionControl
		This.oOperations.RenameFile(This.cTestDataFolder + 'xx.txt', ;
			juststem(This.cFile))
		llAddin = ascan(This.oAddins.aMethods, 'AfterRenameFileInVersionControl') > 0
		This.AssertTrue(llAddin, ;
			'Did not call AfterRenameFileInVersionControl')
	endfunc

*******************************************************************************
* Test that RenameFile fails if the BeforeRenameFileInVersionControl addin
* returns .F.
*******************************************************************************
	function Test_RenameFile_Fails_IfBeforeRenameFileInVersionControlReturnsFalse
		This.oAddins.lValueToReturn = .F.
		llWorks = This.oOperations.RenameFile(This.cTestDataFolder + 'xx.txt', ;
			juststem(This.cFile))
		This.AssertFalse(llWorks, 'Returned .T. when addin returned .F.')
	endfunc
enddefine

*******************************************************************************
* Mock classes
*******************************************************************************
define class MockVersionControlOperations as VersionControlOperations ;
	of Source\ProjectExplorerEngine.vcx
	lCommitFilesCalled    = .F.
	lCommitAllFilesCalled = .F.
	cStatusFile           = ''
	dimension aFiles[1]
	dimension aCommitFiles[1]

	function AddFilesInternal(taFiles)
		acopy(taFiles, This.aFiles)
	endfunc

	function RemoveFilesInternal(taFiles)
		acopy(taFiles, This.aFiles)
	endfunc

	function RevertFilesInternal(taFiles)
		acopy(taFiles, This.aFiles)
	endfunc

	function CommitFilesInternal(tcMessage, taFiles)
		This.lCommitFilesCalled = .T.
		acopy(taFiles, This.aCommitFiles)
	endfunc

	function CommitAllFilesInternal(tcMessage)
		This.lCommitAllFilesCalled = .T.
	endfunc
	
	function GetStatusForFileInternal(tcFile)
		This.cStatusFile = tcFile
	endfunc

	function RenameFileInternal(tcFile, tcNewName)
		lnFiles = iif(empty(This.aFiles[1]), 1, alen(This.aFiles) + 1)
		dimension This.aFiles[lnFiles]
		This.aFiles[lnFiles] = tcNewName
	endfunc
enddefine

define class MockAddin as Custom
	dimension aMethods[1]
	lSuccess       = .T.
	lValueToReturn = .T.

	function ExecuteAddin(tcMethod, tuParameter1, tuParameter2, tuParameter2)
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
