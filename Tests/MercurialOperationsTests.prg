*******************************************************************************
define class MercurialOperationsTests as FxuTestCase of FxuTestCase.prg
*******************************************************************************
	#IF .f.
	LOCAL THIS AS MercurialOperationsTests OF MercurialOperationsTests.PRG
	#ENDIF
	
	cTestFolder     = ''
	cTestDataFolder = ''
	cTestProgram    = ''
	icTestPrefix    = 'Test_'
	ilAllowDebug    = .T.
	
	oOperations     = .NULL.
	cFile           = ''
	cCurrPath       = ''
	cRepoFolder     = ''

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

		This.cFile = This.cTestDataFolder + sys(2015) + '.txt'
		strtofile('xxx', This.cFile)
		This.SetupOperations(1, .F.)
		This.cRepoFolder = This.cTestDataFolder + '.hg'
		This.cCurrPath   = set('PATH')
		set path to 'Source' additive
	endfunc

*******************************************************************************
* Clean up on exit.
*******************************************************************************
	function TearDown
		erase (This.cFile)
		erase (This.cTestDataFolder + '*.orig')
		try
			loFSO = createobject('Scripting.FileSystemObject')
			loFSO.DeleteFolder(This.cRepoFolder)
		catch
		endtry
		set path to (This.cCurrPath)
	endfunc

*******************************************************************************
* Helper method to set up the operations object and create a repository.
*******************************************************************************
	function SetupOperations(tnIncludeInVersionControl, tlAutoCommit)
		This.oOperations = newobject('MercurialOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', ;
			tnIncludeInVersionControl, tlAutoCommit, 'file added', ;
			'file removed')
		This.oOperations.CreateRepository(This.cTestDataFolder)
	endfunc

*******************************************************************************
* Test that CreateRepository fails if an invalid folder is passed (this
* actually testsall the ways it can fail in one test)
*******************************************************************************
	function Test_CreateRepository_Fails_InvalidFolder
		llOK = This.oOperations.CreateRepository()
		This.AssertFalse(llOK, 'Returned .T. when no folder passed')
		llOK = This.oOperations.CreateRepository('')
		This.AssertFalse(llOK, 'Returned .T. when empty folder passed')
		llOK = This.oOperations.CreateRepository('xxx')
		This.AssertFalse(llOK, 'Returned .T. when non-existent folder passed')
	endfunc

*******************************************************************************
* Test that CreateRepository creates a repository
*******************************************************************************
	function Test_CreateRepository_CreatesRepository
		This.AssertTrue(directory(This.cRepoFolder), 'Did not create .hg')
	endfunc

*******************************************************************************
* Test that AddFile adds a file to the repository. Note that this and other
* tests also test GetStatusForFile, which is usually a no-no, but in this case
* it's easier than writing test code to get the file status.
*******************************************************************************
	function Test_AddFile_AddsToRepository
		This.oOperations.AddFile(This.cFile, This.cTestDataFolder)
		lcStatus = This.oOperations.GetStatusForFile(This.cFile, ;
			This.cTestDataFolder)
		This.AssertEquals('A', lcStatus, 'Did not add file')
	endfunc

*******************************************************************************
* Test that RemoveFile removes a file from the repository
*******************************************************************************
	function Test_RemoveFile_RemovesFromRepository
		This.oOperations.AddFile(This.cFile, This.cTestDataFolder)
		This.oOperations.RemoveFile(This.cFile, This.cTestDataFolder)
		lcStatus = This.oOperations.GetStatusForFile(This.cFile, ;
			This.cTestDataFolder)
		This.AssertEquals('?', lcStatus, 'Did not remove file')
	endfunc

*******************************************************************************
* Test that RevertFile reverts a file. Note that this also tests CommitFile
* but as noted earlier, it's easier to do this than write test code to commit.
*******************************************************************************
	function Test_RevertFile_Reverts
		This.oOperations.AddFile(This.cFile, This.cTestDataFolder)
		This.oOperations.CommitFile('commit', This.cFile)
		strtofile('test change', This.cFile)
		lcStatus = This.oOperations.GetStatusForFile(This.cFile, ;
			This.cTestDataFolder)
		This.AssertEquals('M', lcStatus, 'File not changed')
		This.oOperations.RevertFile(This.cFile, This.cTestDataFolder)
		lcStatus = This.oOperations.GetStatusForFile(This.cFile, ;
			This.cTestDataFolder)
		This.AssertEquals('C', lcStatus, 'Did not revert file')
	endfunc

*******************************************************************************
* Test that CommitFile commits a file
*******************************************************************************
	function Test_CommitFile_Commits
		This.oOperations.AddFile(This.cFile, This.cTestDataFolder)
		This.oOperations.CommitFile('commit', This.cFile)
		lcStatus = This.oOperations.GetStatusForFile(This.cFile, ;
			This.cTestDataFolder)
		This.AssertEquals('C', lcStatus, 'Did not commit file')
	endfunc

*******************************************************************************
* Test that CommitFiles commits several files
*******************************************************************************
	function Test_CommitFiles_Commits
		lcFile = This.cTestDataFolder + sys(2015) + '.txt'
		strtofile('another file', lcFile)
		This.oOperations.AddFile(This.cFile, This.cTestDataFolder)
		This.oOperations.AddFile(lcFile, This.cTestDataFolder)
		dimension laFiles[2]
		laFiles[1] = This.cFile
		laFiles[2] = lcFile
		This.oOperations.CommitFiles('commit', @laFiles)
		lcStatus1 = This.oOperations.GetStatusForFile(This.cFile, ;
			This.cTestDataFolder)
		lcStatus2 = This.oOperations.GetStatusForFile(lcFile, ;
			This.cTestDataFolder)
		erase (lcFile)
		This.AssertEquals('C', lcStatus1, 'Did not commit file 1')
		This.AssertEquals('C', lcStatus2, 'Did not commit file 2')
	endfunc

*******************************************************************************
* Test that CommitAllFiles commits all changes in a project
*******************************************************************************
	function Test_CommitAllFiles_Commits
		lcProject = This.cTestDataFolder + sys(2015) + '.pjx'
		lcPJT     = forceext(lcProject, 'pjt')
		create project (lcProject) nowait noshow
		_vfp.ActiveProject.Files.Add(This.cFile)
		This.oOperations.AddFile(lcProject,  This.cTestDataFolder)
		This.oOperations.AddFile(lcPJT,      This.cTestDataFolder)
		This.oOperations.AddFile(This.cFile, This.cTestDataFolder)
		_vfp.ActiveProject.Close()
		This.oOperations.CommitAllFiles('commit', lcProject)
		lcStatus1 = This.oOperations.GetStatusForFile(This.cFile, ;
			This.cTestDataFolder)
		lcStatus2 = This.oOperations.GetStatusForFile(lcProject, ;
			This.cTestDataFolder)
		lcStatus3 = This.oOperations.GetStatusForFile(lcPJT, ;
			This.cTestDataFolder)
		erase (lcProject)
		erase (lcPJT)
		This.AssertEquals('C', lcStatus1, 'Did not commit file 1')
		This.AssertEquals('C', lcStatus2, 'Did not commit file 2')
		This.AssertEquals('C', lcStatus3, 'Did not commit file 3')
	endfunc

*******************************************************************************
* Test that GetStatusForFile gets the status for VFP binary files
*******************************************************************************
	function Test_GetStatusForFile_GetsStatusForVFPBinary
		strtofile('x', This.cTestDataFolder + 'test.vcx')
		strtofile('x', This.cTestDataFolder + 'test.vct')
		This.oOperations.AddFile(This.cTestDataFolder + 'test.vcx', ;
			This.cTestDataFolder)
		This.oOperations.CommitFile('commit', This.cTestDataFolder + 'test.vcx')
		strtofile('xxx', This.cTestDataFolder + 'test.vct')
		lcStatus = This.oOperations.GetStatusForFile(This.cTestDataFolder + ;
			'test.vcx', This.cTestDataFolder)
		erase (This.cTestDataFolder + 'test.vc*')
		This.AssertEquals('M', lcStatus, 'Did not get status for other file')
	endfunc

*******************************************************************************
* Test that GetStatusForAllFiles gets the status for all files in a collection
*******************************************************************************
	function Test_GetStatusForAllFiles_GetsStatus
		local loFiles, loItem
		loFiles = createobject('ItemCollection')
		loItem  = createobject('Empty')
		addproperty(loItem, 'VersionControlStatus', '')
		addproperty(loItem, 'Path', This.cFile)
		loFiles.Add(loItem, loItem.Path)
		This.oOperations.AddFile(This.cFile, This.cTestDataFolder)
		This.oOperations.GetStatusForAllFiles(loFiles, ;
			This.cTestDataFolder)
		This.AssertEquals('A', loItem.VersionControlStatus, ;
			'Did not get status')
	endfunc

*******************************************************************************
* Test that GetStatusForAllFiles gets the status for VFP binary files
*******************************************************************************
	function Test_GetStatusForAllFiles_GetsStatusForVFPBinary
		local loFiles, loItem
		strtofile('x', This.cTestDataFolder + 'test.vcx')
		strtofile('x', This.cTestDataFolder + 'test.vct')

		loFiles = createobject('ItemCollection')
		loItem  = createobject('Empty')
		addproperty(loItem, 'VersionControlStatus', '')
		addproperty(loItem, 'Path', This.cTestDataFolder + 'test.vcx')
		loFiles.Add(loItem, loItem.Path)
		This.oOperations.AddFile(This.cTestDataFolder + 'test.vcx', ;
			This.cTestDataFolder)
		This.oOperations.CommitAllFiles('commit', ;
			This.cTestDataFolder + 'test.vct')

		strtofile('xxx', This.cTestDataFolder + 'test.vct')
		This.oOperations.GetStatusForAllFiles(loFiles, ;
			This.cTestDataFolder)

		lcStatus = loItem.VersionControlStatus
		erase (This.cTestDataFolder + 'test.vc*')
		This.AssertEquals('M', lcStatus, 'Did not get status for other file')
	endfunc
enddefine

*******************************************************************************
* Mock classes
*******************************************************************************
define class ItemCollection as Collection
	function GetItemForFile(tcFile)
		local loReturn, loItem
		loReturn = .NULL.
		for each loItem in This foxobject
			if upper(loItem.Path) == upper(tcFile)
				loReturn = loItem
				exit
			endif upper(loItem.Path) == upper(tcFile)
		next loItem
		return loReturn
	endfunc
enddefine
