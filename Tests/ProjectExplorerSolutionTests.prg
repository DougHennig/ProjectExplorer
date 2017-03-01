define class ProjectExplorerSolutionTests as FxuTestCase of FxuTestCase.prg
	#IF .f.
	LOCAL THIS AS ProjectExplorerSolutionTests OF ProjectExplorerSolutionTests.PRG
	#ENDIF
	
	oSolution       = .NULL.
	cProject        = ''
	cTestFolder     = ''
	cTestDataFolder = ''
	icTestPrefix    = 'Test_'
	cSolution       = ''
	cFile           = ''
	cSolutionFile   = ''
	cTestProgram    = ''

	* the icTestPrefix property in the base FxuTestCase class defaults
	* to "TEST" (not case sensitive). There is a setting on the interface
	* tab of the options form (accessible via right-clicking on the
	* main FoxUnit form and choosing the options item) labeld as
	* "Load and run only tests with the specified icTestPrefix value in test classes"
	
********************************************************************
* Setup for the tests
********************************************************************
	function Setup
		local lcProgram
		lcProgram        = sys(16)
		This.cTestFolder = addbs(justpath(substr(lcProgram, ;
			at(' ', lcProgram, 2) + 1)))
		This.cTestDataFolder = This.cTestFolder + 'TestData\'
		if not directory(This.cTestDataFolder)
			md (This.cTestDataFolder)
		endif not directory(This.cTestDataFolder)
		This.oSolution     = newobject('ProjectExplorerSolution', ;
			'..\Source\ProjectExplorerEngine.vcx')
		This.cProject      = This.cTestDataFolder + sys(2015) + '.pjx'
		This.cFile         = This.cTestDataFolder + sys(2015) + '.txt'
		This.cSolutionFile = This.cTestDataFolder + 'Solution.xml'
		This.cTestProgram  = This.cTestFolder + 'ProjectExplorerSolutionTests.prg'
		strtofile('xxx', This.cFile)
		erase (This.cSolutionFile)
		public gcFile
		gcFile = This.cFile
	endfunc
	
********************************************************************
* Clean up on exit.
********************************************************************
	function TearDown
		if not empty(This.cProject) and file(This.cProject)
			try
				loProject = _vfp.Projects[This.cProject]
				loProject.Close()
			catch
			endtry
			erase (This.cProject)
			erase forceext(This.cProject, 'pjt')  
		endif not empty(This.cProject) ...
		erase (This.cSolutionFile)
		erase (This.cFile)
	endfunc

**********************************************************************
* Helper method to set up the specified solution
**********************************************************************
*** TODO: this is being called as a test even though icTestPrefix is "Test"
	function SetupSolution(toSolution)
		if vartype(toSolution) = 'O'
			toSolution.cProjectEngineClass   = 'MockProjectEngine'
			toSolution.cProjectEngineLibrary = This.cTestProgram
			create project (This.cProject) nowait noshow
			_vfp.ActiveProject.Files.Add(This.cFile)
			_vfp.ActiveProject.Close()
		endif vartype(toSolution) = 'O'
		text to This.cSolution noshow textmerge
<solution>
	<projects>
		<project name="<<lower(justfname(This.cProject))>>" buildaction="0" recompile="false" displayerrors="true" regenerate="false" runafterbuild="false" outputfile="" />
	</projects>
	<versioncontrol class="MockVersionControl" library="D:\PROJECT EXPLORER\TESTS\ProjectExplorerSolutionTests.prg" includeinversioncontrol="1" autocommit="true" fileaddmessage="A" fileremovemessage="B" />
</solution>
		endtext
	endfunc

**********************************************************************
* Test that AddProject returns .F. if an invalid project file is
* specified (this actually tests all the ways it can fail in one test)
**********************************************************************
	function Test_AddProject_Fails_InvalidProject
		llOK = This.oSolution.AddProject()
		This.AssertFalse(llOK, 'Did not return .F. when nothing passed')
		llOK = This.oSolution.AddProject(5)
		This.AssertFalse(llOK, 'Did not return .F. when non-char passed')
		llOK = This.oSolution.AddProject('test')
		This.AssertFalse(llOK, 'Did not return .F. when PJX not passed')
		llOK = This.oSolution.AddProject(This.cProject)
		This.AssertFalse(llOK, 'Did not return .F. when non-existent PJX passed')
	endfunc

**********************************************************************
* Test that AddProject adds a project to the oProjects collection
**********************************************************************
	function Test_AddProject_AddsProjectToCollection
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.AssertTrue(This.oSolution.oProjects.Count = 1, ;
			'Did not add project to collection')
	endfunc

**********************************************************************
* Test that AddProject creates a solution file
**********************************************************************
	function Test_AddProject_CreatesSolutionFile
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.AssertTrue(file(This.cSolutionFile), ;
			'Did not create solution file')
	endfunc

**********************************************************************
* Test that AddProject calls the BeforeAddProjectToSolution addin
**********************************************************************
	function Test_AddProject_CallsBeforeAddProjectToSolution
		loAddins   = createobject('MockAddin')
		loSolution = newobject('ProjectExplorerSolution', ;
			'..\Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		loSolution.AddProject(This.cProject)
		llAddin = ascan(loAddins.aMethods, 'BeforeAddProjectToSolution') > 0
		This.AssertTrue(llAddin, ;
			'Did not call BeforeAddProjectToSolution')
	endfunc

**********************************************************************
* Test that AddProject calls the AfterAddProjectToSolution addin
**********************************************************************
	function Test_AddProject_CallsAfterAddProjectToSolution
		loAddins   = createobject('MockAddin')
		loSolution = newobject('ProjectExplorerSolution', ;
			'..\Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		loSolution.AddProject(This.cProject)
		llAddin = ascan(loAddins.aMethods, 'AfterAddProjectToSolution') > 0
		This.AssertTrue(llAddin, ;
			'Did not call AfterAddProjectToSolution')
	endfunc

**********************************************************************
* Test that AddProject fails if the BeforeAddProjectToSolution addin
* returns .F.
**********************************************************************
	function Test_AddProject_Fails_IfBeforeAddProjectToSolutionReturnsFalse
		loAddins = createobject('MockAddin')
		loAddins.lValueToReturn = .F.
		loSolution = newobject('ProjectExplorerSolution', ;
			'..\Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		llOK = loSolution.AddProject(This.cProject)
		This.AssertFalse(llOK, ;
			'Did not return .F.')
	endfunc

**********************************************************************
* Test that RemoveProject returns .F. if an invalid project file is
* specified (this actually tests all the ways it can fail in one test)
**********************************************************************
	function Test_RemoveProject_Fails_InvalidProject
		llOK = This.oSolution.RemoveProject()
		This.AssertFalse(llOK, 'Did not return .F. when nothing passed')
		llOK = This.oSolution.RemoveProject(5)
		This.AssertFalse(llOK, 'Did not return .F. when non-char passed')
		llOK = This.oSolution.RemoveProject('test')
		This.AssertFalse(llOK, 'Did not return .F. when PJX not passed')
		llOK = This.oSolution.RemoveProject(This.cProject)
		This.AssertFalse(llOK, 'Did not return .F. when non-existent PJX passed')
		create project (This.cProject) nowait noshow
		_vfp.ActiveProject.Files.Add(This.cFile)
		_vfp.ActiveProject.Close()
		llOK = This.oSolution.RemoveProject(This.cProject)
		This.AssertFalse(llOK, 'Did not return .F. when PJX not in solution passed')
	endfunc

**********************************************************************
* Test that RemoveProject removes a project from the oProjects collection
**********************************************************************
	function Test_RemoveProject_RemovesProjectFromCollection
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.RemoveProject(This.cProject)
		This.AssertTrue(This.oSolution.oProjects.Count = 0, ;
			'Did not remove project from collection')
	endfunc

**********************************************************************
* Test that RemoveProject creates a solution file
**********************************************************************
	function Test_RemoveProject_CreatesSolutionFile
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		erase (This.cSolutionFile)
		This.oSolution.RemoveProject(This.cProject)
		This.AssertTrue(file(This.cSolutionFile), ;
			'Did not create solution file')
	endfunc

**********************************************************************
* Test that RemoveProject calls the BeforeRemoveProjectFromSolution addin
**********************************************************************
	function Test_RemoveProject_CallsBeforeRemoveProjectFromSolution
		loAddins   = createobject('MockAddin')
		loSolution = newobject('ProjectExplorerSolution', ;
			'..\Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		loSolution.AddProject(This.cProject)
		loSolution.RemoveProject(This.cProject)
		llAddin = ascan(loAddins.aMethods, 'BeforeRemoveProjectFromSolution') > 0
		This.AssertTrue(llAddin, ;
			'Did not call BeforeRemoveProjectFromSolution')
	endfunc

**********************************************************************
* Test that RemoveProject calls the AfterRemoveProjectFromSolution addin
**********************************************************************
	function Test_RemoveProject_CallsAfterRemoveProjectFromSolution
		loAddins   = createobject('MockAddin')
		loSolution = newobject('ProjectExplorerSolution', ;
			'..\Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		loSolution.AddProject(This.cProject)
		loSolution.RemoveProject(This.cProject)
		llAddin = ascan(loAddins.aMethods, 'AfterRemoveProjectFromSolution') > 0
		This.AssertTrue(llAddin, ;
			'Did not call AfterRemoveProjectFromSolution')
	endfunc

**********************************************************************
* Test that RemoveProject fails if the BeforeRemoveProjectFromSolution addin
* returns .F.
**********************************************************************
	function Test_RemoveProject_Fails_IfBeforeRemoveProjectFromSolution
		loAddins = createobject('MockAddin')
		loSolution = newobject('ProjectExplorerSolution', ;
			'..\Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		loSolution.AddProject(This.cProject)
		loAddins.lValueToReturn = .F.
		llOK = loSolution.RemoveProject(This.cProject)
		This.AssertFalse(llOK, ;
			'Did not return .F.')
	endfunc

**********************************************************************
* Test that OpenProjects opens the projects
**********************************************************************
	function Test_OpenProject_OpensProjects
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.OpenProjects()
		This.AssertTrue(This.oSolution.oProjects.Item(1).lOpenProjectCalled, ;
			'Did not call OpenProject')
	endfunc

**********************************************************************
* Test that CloseProjects closes the projects
**********************************************************************
	function Test_CloseProject_ClosesProjects
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.CloseProjects()
		This.AssertTrue(This.oSolution.oProjects.Item(1).lCloseProjectCalled, ;
			'Did not call CloseProject')
	endfunc

**********************************************************************
* Test that lHaveVersionControl is .T. if version control is used
**********************************************************************
	function Test_lHaveVersionControl_ReturnsTrueIfVersionControl
		This.oSolution.oVersionControl = createobject('Empty')
		llOK = This.oSolution.lHaveVersionControl
		This.oSolution.oVersionControl = .NULL.
		This.AssertTrue(llOK, ;
			'Did not return .T.')
	endfunc

**********************************************************************
* Test that lHaveVersionControl is .F. if version control isn't used
**********************************************************************
	function Test_lHaveVersionControl_ReturnsFalseIfNoVersionControl
		llOK = This.oSolution.lHaveVersionControl
		This.AssertFalse(llOK, ;
			'Did not return .F.')
	endfunc

**********************************************************************
* Test that GetStatusForAllFiles calls GetStatusForAllFiles
**********************************************************************
	function Test_GetStatusForAllFiles_CallsGetStatusForAllFiles
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		This.oSolution.GetStatusForAllFiles()
		This.AssertTrue(This.oSolution.oVersionControl.lGetStatusForAllFilesCalled, ;
			'Did not call GetStatusForAllFiles')
	endfunc

**********************************************************************
* Test that AddVersionControl fails if no projects
**********************************************************************
	function Test_AddVersionControl_FailsIfNoProjects
		llOK = This.oSolution.AddVersionControl()
		This.AssertFalse(llOK, ;
			'Did not return .F.')
	endfunc

**********************************************************************
* Test that AddVersionControl creates a version control object
**********************************************************************
	function Test_AddVersionControl_CreatesVersionControlObject
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .F., '', '', '')
		This.AssertNotNull(This.oSolution.oVersionControl, ;
			'Did not set oVersionControl')
	endfunc

**********************************************************************
* Test that AddVersionControl sets the version control object of the
* projects
**********************************************************************
	function Test_AddVersionControl_SetsVersionControl
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .F., '', '', '')
		This.AssertNotNull(This.oSolution.oProjects.Item(1).oVersionControl, ;
			'Did not set project version control')
	endfunc

**********************************************************************
* Test that AddVersionControl creates a solution file
**********************************************************************
	function Test_AddVersionControl_CreatesSolutionFile
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		erase (This.cSolutionFile)
		This.oSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .F., '', '', '')
		This.AssertTrue(file(This.cSolutionFile), ;
			'Did not create Solution.xml')
	endfunc

**********************************************************************
* Test that AddVersionControl creates a repository
**********************************************************************
	function Test_AddVersionControl_CreatesRepository
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .F., '', '', '')
		This.AssertTrue(This.oSolution.oVersionControl.lCreateRepositoryCalled, ;
			'Did not create repository')
	endfunc

**********************************************************************
* Test that AddVersionControl adds .hgignore to the repository
**********************************************************************
	function Test_AddVersionControl_AddsIgnoreToRepository
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .F., '', '', '')
		llAdded = ascan(This.oSolution.oVersionControl.aFiles, '.hgignore') >0 
		This.AssertTrue(llAdded, ;
			'Did not add .hgignore')
	endfunc

**********************************************************************
* Test that AddVersionControl adds the solution file to the repository
**********************************************************************
	function Test_AddVersionControl_AddsSolutionToRepository
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .F., '', '', '')
		llAdded = ascan(This.oSolution.oVersionControl.aFiles, 'solution.xml') > 0
		This.AssertTrue(llAdded, ;
			'Did not add solution file')
	endfunc

**********************************************************************
* Test that AddVersionControl adds the project file to the repository
**********************************************************************
	function Test_AddVersionControl_AddsProjectToRepository
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .F., '', '', '')
		llAdded = ascan(This.oSolution.oVersionControl.aFiles, lower(justfname(This.cProject))) > 0
		This.AssertTrue(llAdded, ;
			'Did not add project file')
	endfunc

**********************************************************************
* Test that AddVersionControl adds project items to the repository
**********************************************************************
	function Test_AddVersionControl_AddsProjectItemsToRepository
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .F., '', '', '')
		llAdded = ascan(This.oSolution.oVersionControl.aFiles, lower(justfname(This.cFile))) > 0
		This.AssertTrue(llAdded, ;
			'Did not add project item')
	endfunc

**********************************************************************
* Test that AddVersionControl commits all changes if auto-commit
**********************************************************************
	function Test_AddVersionControl_CommitsAllChangesIfAutoCommit
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .T., '', '', '')
		This.AssertTrue(This.oSolution.oProjects.Item(1).lCloseProjectCalled, ;
			'Did not close project')
		This.AssertTrue(This.oSolution.oVersionControl.lCommitAllFilesCalled, ;
			'Did not commit all changes')
		This.AssertTrue(This.oSolution.oProjects.Item(1).lOpenProjectCalled, ;
			'Did not reopen project')
	endfunc

**********************************************************************
* Test that AddVersionControl doesn't commit changes if not auto-commit
**********************************************************************
	function Test_AddVersionControl_DoesntCommitsChangesIfNotAutoCommit
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .F., '', '', '')
		This.AssertFalse(This.oSolution.oVersionControl.lCommitAllFilesCalled, ;
			'Committed all changes')
	endfunc

**********************************************************************
* Test that AddVersionControl calls the BeforeAddVersionControl addin
**********************************************************************
	function Test_AddVersionControl_CallsBeforeAddVersionControl
		loAddins   = createobject('MockAddin')
		loSolution = newobject('ProjectExplorerSolution', ;
			'..\Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		loSolution.AddProject(This.cProject)
		loSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .F., '', '', '')
		llAddin = ascan(loAddins.aMethods, 'BeforeAddVersionControl') > 0
		This.AssertTrue(llAddin, ;
			'Did not call BeforeAddVersionControl')
	endfunc

**********************************************************************
* Test that AddVersionControl calls the AfterAddVersionControl addin
**********************************************************************
	function Test_AddVersionControl_CallsAfterAddVersionControl
		loAddins   = createobject('MockAddin')
		loSolution = newobject('ProjectExplorerSolution', ;
			'..\Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		loSolution.AddProject(This.cProject)
		loSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .F., '', '', '')
		llAddin = ascan(loAddins.aMethods, 'AfterAddVersionControl') > 0
		This.AssertTrue(llAddin, ;
			'Did not call AfterAddVersionControl')
	endfunc

**********************************************************************
* Test that AddVersionControl fails if the BeforeAddVersionControl addin
* returns .F.
**********************************************************************
	function Test_AddVersionControl_Fails_IfBeforeAddVersionControlReturnsFalse
		loAddins = createobject('MockAddin')
		loSolution = newobject('ProjectExplorerSolution', ;
			'..\Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		loSolution.AddProject(This.cProject)
		loAddins.lValueToReturn = .F.
		llOK = loSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .F., '', '', '')
		This.AssertFalse(llOK, ;
			'Did not return .F.')
	endfunc

**********************************************************************
* Test that OpenSolution returns .F. if an invalid folder is specified
* (this actually tests all the ways it can fail in one test)
**********************************************************************
	function Test_OpenSolution_Fails_InvalidFolder
		llOK = This.oSolution.OpenSolution()
		This.AssertFalse(llOK, 'Did not return .F. when nothing passed')
		llOK = This.oSolution.OpenSolution(5)
		This.AssertFalse(llOK, 'Did not return .F. when non-char passed')
		llOK = This.oSolution.OpenSolution('test')
		This.AssertFalse(llOK, 'Did not return .F. when non-existent folder passed')
		llOK = This.oSolution.AddProject(This.cTestDataFolder)
		This.AssertFalse(llOK, 'Did not return .F. when folder has no solution file')
		strtofile('xxx', This.cSolutionFile)
		llOK = This.oSolution.AddProject(This.cTestDataFolder)
		This.AssertFalse(llOK, 'Did not return .F. when folder has invalid solution file')
	endfunc

**********************************************************************
* Test that OpenSolution sets the version control object
**********************************************************************
	function Test_OpenSolution_SetsVersionControl
		This.SetupSolution(This.oSolution)
		strtofile(This.cSolution, This.cSolutionFile)
		This.oSolution.OpenSolution(This.cTestDataFolder)
		This.AssertNotNull(This.oSolution.oVersionControl, ;
			'Did not set version control')
	endfunc

**********************************************************************
* Test that OpenSolution adds the projects
**********************************************************************
	function Test_OpenSolution_AddsProjects
		This.SetupSolution(This.oSolution)
		strtofile(This.cSolution, This.cSolutionFile)
		This.oSolution.OpenSolution(This.cTestDataFolder)
		This.AssertNotNull(This.oSolution.oProjects.Count = 1, ;
			'Did not add projects')
	endfunc

**********************************************************************
* Test that SaveSolution creates the correct solution file
**********************************************************************
	function Test_SaveSolution_CreatesCorrectFile
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .T., 'A', 'B', 'C')
		lcSolution = filetostr(This.cSolutionFile)
		This.AssertEquals(chrtran(upper(lcSolution), chr(13) + chr(10), ''), ;
			chrtran(upper(This.cSolution), chr(13) + chr(10), ''), ;
			'Solution file not correct')
	endfunc
enddefine

**********************************************************************
* Mock classes
**********************************************************************
define class MockProjectEngine as Custom
	oVersionControl     = .NULL.
	oProjectSettings    = .NULL.
	oProjectItems       = .NULL.
	cProject            = ''
	lOpenProjectCalled  = .F.
	lCloseProjectCalled = .F.

	function Init(toAddins)
		This.oProjectSettings = newobject('ProjectSettings', ;
			'..\Source\ProjectExplorerEngine.vcx')
			&& note: we don't use a mock object here because it has to have
			&& all of the properties of ProjectSettings and we'd have to keep
			&& the mock class up-to-date
		This.oProjectItems = createobject('Collection')
	endfunc

	function SetProject(tcProject)
		This.cProject = tcProject
		loItem = createobject('Empty')
		addproperty(loItem, 'IsFile', .T.)
		addproperty(loItem, 'Path', gcFile)
		This.oProjectItems.Add(loItem)
	endfunc

	function OpenProject()
		This.lOpenProjectCalled = .T.
	endfunc

	function CloseProject()
		This.lCloseProjectCalled = .T.
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

define class MockVersionControl as Custom
	lGetStatusForAllFilesCalled = .F.
	lCreateRepositoryCalled     = .F.
	lCommitAllFilesCalled       = .F.
	dimension aFiles[1]
	
	function Init(tnIncludeInVersionControl, tlAutoCommit, tcFileAddMessage, ;
		tcFileRemoveMessage)
	endfunc

	function GetStatusForAllFiles(toItems, tcFolder)
		This.lGetStatusForAllFilesCalled = .T.
	endfunc

	function CreateRepository(tcPath)
		This.lCreateRepositoryCalled = .T.
	endfunc

	function AddFile(tcFile, tcFolder, tlNoAutoCommit)
		if empty(This.aFiles[1])
			lnFiles = 1
		else
			lnFiles = alen(This.aFiles) + 1
			dimension This.aFiles[lnFiles]
		endif empty(This.aFiles[1])
		This.aFiles[lnFiles] = lower(justfname(tcFile))
	endfunc

	function CommitAllFiles(tcMessage, tcProject, tlNoText)
		This.lCommitAllFilesCalled = .T.
	endfunc

	function Release
	endfunc
enddefine
