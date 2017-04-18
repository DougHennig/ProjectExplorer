*******************************************************************************
define class ProjectExplorerSolutionTests as FxuTestCase of FxuTestCase.prg
*******************************************************************************
	#IF .f.
	LOCAL THIS AS ProjectExplorerSolutionTests OF ProjectExplorerSolutionTests.PRG
	#ENDIF
	
	cTestFolder     = ''
	cTestDataFolder = ''
	cTestProgram    = ''
	icTestPrefix    = 'Test_'
	oSolution       = .NULL.
	cProject        = ''
	cSolution       = ''
	cFile           = ''
	cSolutionFile   = ''
	
*******************************************************************************
* Setup for the tests
*******************************************************************************
	function Setup
		local lcProgram

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

		This.oSolution     = newobject('ProjectExplorerSolution', ;
			'Source\ProjectExplorerEngine.vcx')
		This.cProject      = This.cTestDataFolder + sys(2015) + '.pjx'
		This.cSolutionFile = This.cTestDataFolder + 'Solution.xml'
		This.cFile         = This.cTestDataFolder + sys(2015) + '.txt'
		strtofile('xxx', This.cFile)
		erase (This.cSolutionFile)
		public gcFile
		gcFile = This.cFile
	endfunc
	
*******************************************************************************
* Clean up on exit.
*******************************************************************************
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

*******************************************************************************
* Helper method to set up the specified solution
*******************************************************************************
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
	<versioncontrol class="MockVersionControl" library="D:\PROJECT EXPLORER\TESTS\ProjectExplorerSolutionTests.fxp" includeinversioncontrol="1" autocommit="true" fileaddmessage="A" fileremovemessage="B" cleanupmessage="C" savedsolutionmessage="Solution settings changed" buildmessage="Built the project: version {Project.VersionNumber}" />
</solution>
		endtext
	endfunc

*******************************************************************************
* Test that AddProject returns .F. if an invalid project file is
* specified (this actually tests all the ways it can fail in one test)
*******************************************************************************
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

*******************************************************************************
* Test that AddProject adds a project to the oProjects collection
*******************************************************************************
	function Test_AddProject_AddsProjectToCollection
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.AssertTrue(This.oSolution.oProjects.Count = 1, ;
			'Did not add project to collection')
	endfunc

*******************************************************************************
* Test that AddProject creates a solution file
*******************************************************************************
	function Test_AddProject_CreatesSolutionFile
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.AssertTrue(file(This.cSolutionFile), ;
			'Did not create solution file')
	endfunc

*******************************************************************************
* Test that AddProject calls the BeforeAddProjectToSolution addin
*******************************************************************************
	function Test_AddProject_CallsBeforeAddProjectToSolution
		loAddins   = createobject('MockAddin')
		loSolution = newobject('ProjectExplorerSolution', ;
			'Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		loSolution.AddProject(This.cProject)
		llAddin = ascan(loAddins.aMethods, 'BeforeAddProjectToSolution') > 0
		This.AssertTrue(llAddin, ;
			'Did not call BeforeAddProjectToSolution')
	endfunc

*******************************************************************************
* Test that AddProject calls the AfterAddProjectToSolution addin
*******************************************************************************
	function Test_AddProject_CallsAfterAddProjectToSolution
		loAddins   = createobject('MockAddin')
		loSolution = newobject('ProjectExplorerSolution', ;
			'Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		loSolution.AddProject(This.cProject)
		llAddin = ascan(loAddins.aMethods, 'AfterAddProjectToSolution') > 0
		This.AssertTrue(llAddin, ;
			'Did not call AfterAddProjectToSolution')
	endfunc

*******************************************************************************
* Test that AddProject fails if the BeforeAddProjectToSolution addin returns
* .F.
*******************************************************************************
	function Test_AddProject_Fails_IfBeforeAddProjectToSolutionReturnsFalse
		loAddins = createobject('MockAddin')
		loAddins.lSuccess       = .F.
		loAddins.lValueToReturn = .F.
		loSolution = newobject('ProjectExplorerSolution', ;
			'Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		llOK = loSolution.AddProject(This.cProject)
		This.AssertFalse(llOK, 'Did not return .F.')
	endfunc

*******************************************************************************
* Test that AddProject succeeds if the BeforeAddProjectToSolution addin returns
* .F. but lSuccess is .T.
*******************************************************************************
	function Test_AddProject_Succeedss_IfBeforeAddProjectToSolutionSucceeds
		loAddins = createobject('MockAddin')
		loAddins.lSuccess       = .T.
		loAddins.lValueToReturn = .F.
		loSolution = newobject('ProjectExplorerSolution', ;
			'Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		llOK = loSolution.AddProject(This.cProject)
		This.AssertTrue(llOK,  'Did not return .T.')
	endfunc

*******************************************************************************
* Test that RemoveProject returns .F. if an invalid project file is specified
* (this actually tests all the ways it can fail in one test)
*******************************************************************************
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

*******************************************************************************
* Test that RemoveProject removes a project from the oProjects collection
*******************************************************************************
	function Test_RemoveProject_RemovesProjectFromCollection
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.RemoveProject(This.cProject)
		This.AssertTrue(This.oSolution.oProjects.Count = 0, ;
			'Did not remove project from collection')
	endfunc

*******************************************************************************
* Test that RemoveProject creates a solution file
*******************************************************************************
	function Test_RemoveProject_CreatesSolutionFile
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		erase (This.cSolutionFile)
		This.oSolution.RemoveProject(This.cProject)
		This.AssertTrue(file(This.cSolutionFile), ;
			'Did not create solution file')
	endfunc

*******************************************************************************
* Test that RemoveProject calls the BeforeRemoveProjectFromSolution addin
*******************************************************************************
	function Test_RemoveProject_CallsBeforeRemoveProjectFromSolution
		loAddins   = createobject('MockAddin')
		loSolution = newobject('ProjectExplorerSolution', ;
			'Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		loSolution.AddProject(This.cProject)
		loSolution.RemoveProject(This.cProject)
		llAddin = ascan(loAddins.aMethods, 'BeforeRemoveProjectFromSolution') > 0
		This.AssertTrue(llAddin, ;
			'Did not call BeforeRemoveProjectFromSolution')
	endfunc

*******************************************************************************
* Test that RemoveProject calls the AfterRemoveProjectFromSolution addin
*******************************************************************************
	function Test_RemoveProject_CallsAfterRemoveProjectFromSolution
		loAddins   = createobject('MockAddin')
		loSolution = newobject('ProjectExplorerSolution', ;
			'Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		loSolution.AddProject(This.cProject)
		loSolution.RemoveProject(This.cProject)
		llAddin = ascan(loAddins.aMethods, 'AfterRemoveProjectFromSolution') > 0
		This.AssertTrue(llAddin, ;
			'Did not call AfterRemoveProjectFromSolution')
	endfunc

*******************************************************************************
* Test that RemoveProject fails if the BeforeRemoveProjectFromSolution addin
* returns .F.
*******************************************************************************
	function Test_RemoveProject_Fails_IfBeforeRemoveProjectFromSolution
		loAddins   = createobject('MockAddin')
		loSolution = newobject('ProjectExplorerSolution', ;
			'Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		loSolution.AddProject(This.cProject)
		loAddins.lSuccess       = .F.
		loAddins.lValueToReturn = .F.
		llOK = loSolution.RemoveProject(This.cProject)
		This.AssertFalse(llOK, 'Did not return .F.')
	endfunc

*******************************************************************************
* Test that RemoveProject succeeds if the BeforeRemoveProjectFromSolution addin
* returns .F. but lSuccess is .T.
*******************************************************************************
	function Test_RemoveProject_Succeeds_IfBeforeRemoveProjectFromSolutionSucceeds
		loAddins   = createobject('MockAddin')
		loSolution = newobject('ProjectExplorerSolution', ;
			'Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		loSolution.AddProject(This.cProject)
		loAddins.lSuccess       = .T.
		loAddins.lValueToReturn = .F.
		llOK = loSolution.RemoveProject(This.cProject)
		This.AssertTrue(llOK, 'Did not return .T.')
	endfunc

*******************************************************************************
* Test that OpenProjects opens the projects
*******************************************************************************
	function Test_OpenProject_OpensProjects
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.OpenProjects()
		This.AssertTrue(This.oSolution.oProjects.Item(1).lOpenProjectCalled, ;
			'Did not call OpenProject')
	endfunc

*******************************************************************************
* Test that CloseProjects closes the projects
*******************************************************************************
	function Test_CloseProject_ClosesProjects
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.CloseProjects()
		This.AssertTrue(This.oSolution.oProjects.Item(1).lCloseProjectCalled, ;
			'Did not call CloseProject')
	endfunc

*******************************************************************************
* Test that lHaveVersionControl is .T. if version control is used
*******************************************************************************
	function Test_lHaveVersionControl_ReturnsTrueIfVersionControl
		This.oSolution.oVersionControl = createobject('Empty')
		llOK = This.oSolution.lHaveVersionControl
		This.oSolution.oVersionControl = .NULL.
		This.AssertTrue(llOK, ;
			'Did not return .T.')
	endfunc

*******************************************************************************
* Test that lHaveVersionControl is .F. if version control isn't used
*******************************************************************************
	function Test_lHaveVersionControl_ReturnsFalseIfNoVersionControl
		llOK = This.oSolution.lHaveVersionControl
		This.AssertFalse(llOK, ;
			'Did not return .F.')
	endfunc

*******************************************************************************
* Test that setting cFileAddMessage sets version control property
*******************************************************************************
	function Test_cFileAddMessage_SetVCProperty
		This.SetupSolution(This.oSolution)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		lcText = 'xxx'
		This.oSolution.cFileAddMessage = lcText
		This.AssertEquals(lcText, This.oSolution.oVersionControl.cFileAddMessage, ;
			'Did not set cFileAddMessage')
	endfunc

*******************************************************************************
* Test that setting cFileRemoveMessage sets version control property
*******************************************************************************
	function Test_cFileRemoveMessage_SetVCProperty
		This.SetupSolution(This.oSolution)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		lcText = 'xxx'
		This.oSolution.cFileRemoveMessage = lcText
		This.AssertEquals(lcText, This.oSolution.oVersionControl.cFileRemoveMessage, ;
			'Did not set cFileRemoveMessage')
	endfunc

*******************************************************************************
* Test that setting lAutoCommitChanges sets version control property
*******************************************************************************
	function Test_lAutoCommitChanges_SetVCProperty
		This.SetupSolution(This.oSolution)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		This.oSolution.lAutoCommitChanges = .T.
		This.AssertTrue(This.oSolution.oVersionControl.lAutoCommitChanges, ;
			'Did not set lAutoCommitChanges')
	endfunc

*******************************************************************************
* Test that setting nIncludeInVersionControl sets version control property
*******************************************************************************
	function Test_nIncludeInVersionControl_SetVCProperty
		This.SetupSolution(This.oSolution)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		This.oSolution.nIncludeInVersionControl = 3
		This.AssertEquals(3, This.oSolution.oVersionControl.nIncludeInVersionControl, ;
			'Did not set nIncludeInVersionControl')
	endfunc

*******************************************************************************
* Test that GetStatusForAllFiles calls GetStatusForAllFiles
*******************************************************************************
	function Test_GetStatusForAllFiles_CallsGetStatusForAllFiles
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		This.oSolution.OpenProjects()
		This.oSolution.GetStatusForAllFiles()
		This.AssertTrue(This.oSolution.oVersionControl.lGetStatusForAllFilesCalled, ;
			'Did not call GetStatusForAllFiles')
	endfunc

*******************************************************************************
* Test that GetStatusForFile fails if an invalid file is passed (this actually
* tests all the ways it can fail in one test)
*******************************************************************************
	function Test_GetStatusForFile_Fails_InvalidFile
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		lcStatus = This.oSolution.GetStatusForFile()
		This.AssertTrue(empty(lcStatus), 'Returned status when no file passed')
		lcStatus = This.oSolution.GetStatusForFile('')
		This.AssertTrue(empty(lcStatus), 'Returned status when empty file passed')
		lcStatus = This.oSolution.GetStatusForFile('xxx.txt')
		This.AssertTrue(empty(lcStatus), ;
			'Returned status when non-existent file passed')
	endfunc

*******************************************************************************
* Test that GetStatusForFile fails if an invalid folder is passed (this
* actually tests all the ways it can fail in one test)
*******************************************************************************
	function Test_GetStatusForFile_Fails_InvalidFolder
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		lcStatus = This.oSolution.GetStatusForFile(This.cFile)
		This.AssertTrue(empty(lcStatus), ;
			'Returned status when no folder passed')
		lcStatus = This.oSolution.GetStatusForFile(This.cFile, '')
		This.AssertTrue(empty(lcStatus), ;
			'Returned status when empty folder passed')
		lcStatus = This.oSolution.GetStatusForFile(This.cFile, 'xxx')
		This.AssertTrue(empty(lcStatus), ;
			'Returned status when non-existent folder passed')
	endfunc

*******************************************************************************
* Test that GetStatusForFile fails if there's no version control
*******************************************************************************
	function Test_GetStatusForFile_Fails_NoVersionControl
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		lcStatus = This.oSolution.GetStatusForFile(This.cFile, This.cTestDataFolder)
		This.AssertTrue(empty(lcStatus), ;
			'Returned status when no version control')
	endfunc

*******************************************************************************
* Test that GetStatusForFile calls GetStatusForFile
*******************************************************************************
	function Test_GetStatusForFile_CallsGetStatusForFile
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		lcStatus = This.oSolution.GetStatusForFile(This.cFile, This.cTestDataFolder)
		This.AssertTrue(This.oSolution.oVersionControl.lGetStatusForFileCalled, ;
			'Did not call GetStatusForFile')
		This.AssertEquals('C', lcStatus, 'Did not return status')
	endfunc

*******************************************************************************
* Test that CommitAllFiles fails if an invalid message is passed (this actually
* tests all the ways it can fail in one test)
*******************************************************************************
	function Test_CommitAllFiles_Fails_InvalidMessage
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		lcStatus = This.oSolution.CommitAllFiles()
		This.AssertTrue(empty(lcStatus), 'Returned status when no message passed')
		lcStatus = This.oSolution.CommitAllFiles('')
		This.AssertTrue(empty(lcStatus), 'Returned status when empty message passed')
	endfunc

*******************************************************************************
* Test that CommitAllFiles calls CommitAllFiles
*******************************************************************************
	function Test_CommitAllFiles_CallsCommitAllFiles
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		This.oSolution.CommitAllFiles('message')
		This.AssertTrue(This.oSolution.oVersionControl.lCommitAllFilesCalled, ;
			'Did not call CommitAllFiles')
	endfunc

*******************************************************************************
* Test that CommitAllFiles closes all projects if binary files are included
*******************************************************************************
	function Test_CommitAllFiles_ClosesProjectsIfBinary
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		This.oSolution.nIncludeInVersionControl = 1
		This.oSolution.CommitAllFiles('message')
		This.AssertTrue(This.oSolution.oProjects.Item(1).lCloseProjectCalled, ;
			'Did not call CloseProject')
	endfunc

*******************************************************************************
* Test that CommitFile fails if an invalid message is passed (this actually
* tests all the ways it can fail in one test)
*******************************************************************************
	function Test_CommitFile_Fails_InvalidMessage
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		lcStatus = This.oSolution.CommitFile()
		This.AssertTrue(empty(lcStatus), 'Returned status when no message passed')
		lcStatus = This.oSolution.CommitFile('')
		This.AssertTrue(empty(lcStatus), 'Returned status when empty message passed')
	endfunc

*******************************************************************************
* Test that CommitFile fails if an invalid file is passed (this actually
* tests all the ways it can fail in one test)
*******************************************************************************
	function Test_CommitFile_Fails_InvalidFile
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		lcStatus = This.oSolution.CommitFile('message')
		This.AssertTrue(empty(lcStatus), 'Returned status when no file passed')
		lcStatus = This.oSolution.CommitFile('message', '')
		This.AssertTrue(empty(lcStatus), 'Returned status when empty file passed')
		lcStatus = This.oSolution.CommitFile('message', 'xxx.txt')
		This.AssertTrue(empty(lcStatus), ;
			'Returned status when non-existent file passed')
	endfunc

*******************************************************************************
* Test that CommitFile fails if an invalid folder is passed (this
* actually tests all the ways it can fail in one test)
*******************************************************************************
	function Test_CommitFile_Fails_InvalidFolder
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		lcStatus = This.oSolution.CommitFile('message', This.cFile)
		This.AssertTrue(empty(lcStatus), ;
			'Returned status when no folder passed')
		lcStatus = This.oSolution.CommitFile('message', This.cFile, '')
		This.AssertTrue(empty(lcStatus), ;
			'Returned status when empty folder passed')
		lcStatus = This.oSolution.CommitFile('message', This.cFile, 'xxx')
		This.AssertTrue(empty(lcStatus), ;
			'Returned status when non-existent folder passed')
	endfunc

*******************************************************************************
* Test that CommitFile fails if there's no version control
*******************************************************************************
	function Test_CommitFile_Fails_NoVersionControl
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		lcStatus = This.oSolution.CommitFile()
		This.AssertTrue(empty(lcStatus), ;
			'Returned status when no version control')
	endfunc

*******************************************************************************
* Test that CommitFile calls CommitFile
*******************************************************************************
	function Test_CommitFile_CallsCommitFile
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		lcStatus = This.oSolution.CommitFile('message', This.cFile, This.cTestDataFolder)
		This.AssertTrue(This.oSolution.oVersionControl.lCommitFileCalled, ;
			'Did not call CommitFile')
		This.AssertEquals('C', lcStatus, 'Did not return status')
	endfunc

*******************************************************************************
* Test that CommitFile closes all projects if committing PJX and binary files
* are included
*******************************************************************************
	function Test_CommitFile_ClosesProjectsIfCommittingPJXBinary
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		This.oSolution.nIncludeInVersionControl = 1
		This.oSolution.CommitFile('message', This.cProject, This.cTestDataFolder)
		This.AssertTrue(This.oSolution.oProjects.Item(1).lCloseProjectCalled, ;
			'Did not call CloseProject')
	endfunc

*******************************************************************************
* Test that CommitFile doesn't closes all projects if committing PJX and binary
* files are not included
*******************************************************************************
	function Test_CommitFile_ClosesProjectsIfCommittingPJXNoBinary
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		This.oSolution.nIncludeInVersionControl = 2
		This.oSolution.CommitFile('message', This.cProject, This.cTestDataFolder)
		This.AssertFalse(This.oSolution.oProjects.Item(1).lCloseProjectCalled, ;
			'Called CloseProject')
	endfunc

*******************************************************************************
* Test that CommitFile closes all projects if committing DBC and binary files
* are included
*******************************************************************************
	function Test_CommitFile_ClosesProjectsIfCommittingDBCBinary
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		This.oSolution.nIncludeInVersionControl = 1
		lcFile = This.cTestDataFolder + 'x.dbc'
		strtofile('x', lcFile)
		This.oSolution.CommitFile('message', lcFile, This.cTestDataFolder)
		erase (lcFile)
		This.AssertTrue(This.oSolution.oProjects.Item(1).lCloseProjectCalled, ;
			'Did not call CloseProject')
	endfunc

*******************************************************************************
* Test that CommitFile doesn't close all projects if committing DBC and binary
* files aren't included
*******************************************************************************
	function Test_CommitFile_ClosesProjectsIfCommittingDBCNoBinary
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		This.oSolution.nIncludeInVersionControl = 2
		lcFile = This.cTestDataFolder + 'x.dbc'
		strtofile('x', lcFile)
		This.oSolution.CommitFile('message', lcFile, This.cTestDataFolder)
		erase (lcFile)
		This.AssertFalse(This.oSolution.oProjects.Item(1).lCloseProjectCalled, ;
			'Called CloseProject')
	endfunc

*******************************************************************************
* Test that CommitItems fails if an invalid message is passed (this actually
* tests all the ways it can fail in one test)
*******************************************************************************
	function Test_CommitItems_Fails_InvalidMessage
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		llOK = This.oSolution.CommitItems()
		This.AssertFalse(llOK, 'Returned true when no message passed')
		llOK = This.oSolution.CommitItems('')
		This.AssertFalse(llOK, 'Returned true when empty message passed')
	endfunc

*******************************************************************************
* Test that CommitItems fails if an invalid array is passed (this actually
* tests all the ways it can fail in one test)
*******************************************************************************
	function Test_CommitItems_Fails_InvalidArray
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		llOK = This.oSolution.CommitItems('message', , This.cTestDataFolder)
		This.AssertFalse(llOK, 'Returned true when no array passed')
		dimension laItems[1]
		llOK = This.oSolution.CommitItems('message', @laItems, ;
			This.cTestDataFolder)
		This.AssertFalse(llOK, 'Returned true when non-item passed')
		loItem = createobject('MockProjectItem')
		laItems[1] = loItem
		llOK = This.oSolution.CommitItems('message', @laItems, ;
			This.cTestDataFolder)
		This.AssertFalse(llOK, 'Returned true when non-existent file passed')
	endfunc

*******************************************************************************
* Test that CommitItems fails if an invalid folder is passed (this
* actually tests all the ways it can fail in one test)
*******************************************************************************
	function Test_CommitItems_Fails_InvalidFolder
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		llOK = This.oSolution.CommitItems('message')
		This.AssertFalse(llOK, 'Returned true when no folder passed')
		llOK = This.oSolution.CommitItems('message', , '')
		This.AssertFalse(llOK, 'Returned true when empty folder passed')
		llOK = This.oSolution.CommitItems('message', , 'xxx')
		This.AssertFalse(llOK, 'Returned true when non-existent folder passed')
	endfunc

*******************************************************************************
* Test that CommitItems fails if there's no version control
*******************************************************************************
	function Test_CommitItems_Fails_NoVersionControl
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		llOK = This.oSolution.CommitItems()
		This.AssertFalse(llOK, 'Returned true when no version control')
	endfunc

*******************************************************************************
* Test that CommitItems calls CommitFiles
*******************************************************************************
	function Test_CommitItems_CallsCommitFiles
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		loItem = createobject('MockProjectItem')
		loItem.Path = This.cFile
		dimension laItems[1]
		laItems[1] = loItem
		llOK = This.oSolution.CommitItems('message', @laItems, ;
			This.cTestDataFolder)
		This.AssertTrue(This.oSolution.oVersionControl.lCommitFilesCalled, ;
			'Did not call CommitFiles')
		This.AssertEquals('C', loItem.VersionControlStatus, ;
			'Did not set status')
	endfunc

*******************************************************************************
* Test that CommitItems sets the status of the items
*******************************************************************************
	function Test_CommitItems_SetsStatus
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		loItem = createobject('MockProjectItem')
		loItem.Path = This.cFile
		dimension laItems[1]
		laItems[1] = loItem
		llOK = This.oSolution.CommitItems('message', @laItems, ;
			This.cTestDataFolder)
		This.AssertEquals('C', loItem.VersionControlStatus, ;
			'Did not set status')
	endfunc

*******************************************************************************
* Test that CommitItems closes all projects if committing PJX and binary files
* are included
*******************************************************************************
	function Test_CommitItems_ClosesProjectsIfCommittingPJXBinary
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		This.oSolution.nIncludeInVersionControl = 1
		loItem = createobject('MockProjectItem')
		loItem.Path = This.cProject
		dimension laItems[1]
		laItems[1] = loItem
		This.oSolution.CommitItems('message', @laItems, This.cTestDataFolder)
		This.AssertTrue(This.oSolution.oProjects.Item(1).lCloseProjectCalled, ;
			'Did not call CloseProject')
	endfunc

*******************************************************************************
* Test that CommitItems doesn't close all projects if committing PJX and binary
* files are not included
*******************************************************************************
	function Test_CommitItems_ClosesProjectsIfCommittingPJXNoBinary
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		This.oSolution.nIncludeInVersionControl = 2
		loItem = createobject('MockProjectItem')
		loItem.Path = This.cProject
		dimension laItems[1]
		laItems[1] = loItem
		This.oSolution.CommitItems('message', @laItems, This.cTestDataFolder)
		This.AssertFalse(This.oSolution.oProjects.Item(1).lCloseProjectCalled, ;
			'Called CloseProject')
	endfunc

*******************************************************************************
* Test that CommitItems closes all projects if committing DBC and binary files
* are included
*******************************************************************************
	function Test_CommitItems_ClosesProjectsIfCommittingDBCBinary
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		This.oSolution.nIncludeInVersionControl = 1
		lcFile = This.cTestDataFolder + 'x.dbc'
		strtofile('x', lcFile)
		loItem = createobject('MockProjectItem')
		loItem.Path = lcFile
		dimension laItems[1]
		laItems[1] = loItem
		This.oSolution.CommitItems('message', @laItems, This.cTestDataFolder)
		erase (lcFile)
		This.AssertTrue(This.oSolution.oProjects.Item(1).lCloseProjectCalled, ;
			'Did not call CloseProject')
	endfunc

*******************************************************************************
* Test that CommitItems doesn't close all projects if committing DBC and binary
* files aren't included
*******************************************************************************
	function Test_CommitItems_ClosesProjectsIfCommittingDBCNoBinary
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		This.oSolution.nIncludeInVersionControl = 2
		lcFile = This.cTestDataFolder + 'x.dbc'
		strtofile('x', lcFile)
		loItem = createobject('MockProjectItem')
		loItem.Path = lcFile
		dimension laItems[1]
		laItems[1] = loItem
		This.oSolution.CommitItems('message', @laItems, This.cTestDataFolder)
		erase (lcFile)
		This.AssertFalse(This.oSolution.oProjects.Item(1).lCloseProjectCalled, ;
			'Called CloseProject')
	endfunc

*******************************************************************************
* Test that RevertFile fails if an invalid file is passed (this actually
* tests all the ways it can fail in one test)
*******************************************************************************
	function Test_RevertFile_Fails_InvalidFile
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		lcStatus = This.oSolution.RevertFile()
		This.AssertTrue(empty(lcStatus), 'Returned status when no file passed')
		lcStatus = This.oSolution.RevertFile('')
		This.AssertTrue(empty(lcStatus), 'Returned status when empty file passed')
		lcStatus = This.oSolution.RevertFile('xxx.txt')
		This.AssertTrue(empty(lcStatus), ;
			'Returned status when non-existent file passed')
	endfunc

*******************************************************************************
* Test that RevertFile fails if an invalid folder is passed (this
* actually tests all the ways it can fail in one test)
*******************************************************************************
	function Test_RevertFile_Fails_InvalidFolder
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		lcStatus = This.oSolution.RevertFile(This.cFile)
		This.AssertTrue(empty(lcStatus), ;
			'Returned status when no folder passed')
		lcStatus = This.oSolution.RevertFile(This.cFile, '')
		This.AssertTrue(empty(lcStatus), ;
			'Returned status when empty folder passed')
		lcStatus = This.oSolution.RevertFile(This.cFile, 'xxx')
		This.AssertTrue(empty(lcStatus), ;
			'Returned status when non-existent folder passed')
	endfunc

*******************************************************************************
* Test that RevertFile fails if there's no version control
*******************************************************************************
	function Test_RevertFile_Fails_NoVersionControl
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		lcStatus = This.oSolution.RevertFile()
		This.AssertTrue(empty(lcStatus), ;
			'Returned status when no version control')
	endfunc

*******************************************************************************
* Test that RevertFile calls RevertFile
*******************************************************************************
	function Test_RevertFile_CallsRevertFile
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		lcStatus = This.oSolution.RevertFile(This.cFile, This.cTestDataFolder)
		This.AssertTrue(This.oSolution.oVersionControl.lRevertFileCalled, ;
			'Did not call RevertFile')
		This.AssertEquals('C', lcStatus, 'Did not return status')
	endfunc

*******************************************************************************
* Test that RevertFile closes all projects if committing PJX and binary files
* are included
*******************************************************************************
	function Test_RevertFile_ClosesProjectsIfCommittingPJXBinary
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		This.oSolution.nIncludeInVersionControl = 1
		This.oSolution.RevertFile(This.cProject, This.cTestDataFolder)
		This.AssertTrue(This.oSolution.oProjects.Item(1).lCloseProjectCalled, ;
			'Did not call CloseProject')
	endfunc

*******************************************************************************
* Test that RevertFile doesn't closes all projects if committing PJX and binary
* files are not included
*******************************************************************************
	function Test_RevertFile_ClosesProjectsIfCommittingPJXNoBinary
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		This.oSolution.nIncludeInVersionControl = 2
		This.oSolution.RevertFile(This.cProject, This.cTestDataFolder)
		This.AssertFalse(This.oSolution.oProjects.Item(1).lCloseProjectCalled, ;
			'Called CloseProject')
	endfunc

*******************************************************************************
* Test that RevertFile closes all projects if committing DBC and binary files
* are included
*******************************************************************************
	function Test_RevertFile_ClosesProjectsIfCommittingDBCBinary
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		This.oSolution.nIncludeInVersionControl = 1
		lcFile = This.cTestDataFolder + 'x.dbc'
		strtofile('x', lcFile)
		This.oSolution.RevertFile(lcFile, This.cTestDataFolder)
		erase (lcFile)
		This.AssertTrue(This.oSolution.oProjects.Item(1).lCloseProjectCalled, ;
			'Did not call CloseProject')
	endfunc

*******************************************************************************
* Test that RevertFile doesn't close all projects if committing DBC and binary
* files aren't included
*******************************************************************************
	function Test_RevertFile_ClosesProjectsIfCommittingDBCNoBinary
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		This.oSolution.nIncludeInVersionControl = 2
		lcFile = This.cTestDataFolder + 'x.dbc'
		strtofile('x', lcFile)
		This.oSolution.RevertFile(lcFile, This.cTestDataFolder)
		erase (lcFile)
		This.AssertFalse(This.oSolution.oProjects.Item(1).lCloseProjectCalled, ;
			'Called CloseProject')
	endfunc

*******************************************************************************
* Test that CleanupSolution calls CleanupProject
*******************************************************************************
	function Test_CleanupSolution_CallsCleanupProject
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oProjects[1].OpenProject()
		This.oSolution.CleanupSolution()
		This.AssertTrue(This.oSolution.oProjects[1].lCleanupProjectCalled, ;
			'Did not call CleanupProject')
	endfunc

*** TODO: these tests should be modified as necessary and put into
*** ProjectEngineTests.prg once that is written

*!*	*******************************************************************************
*!*	* Test that CleanupSolution commits changes to project
*!*	*******************************************************************************
*!*		function Test_CleanupSolution_CommitsProject
*!*			This.SetupSolution(This.oSolution)
*!*			This.oSolution.AddProject(This.cProject)
*!*			This.oSolution.oVersionControl = createobject('MockVersionControl')
*!*			This.oSolution.oProjects[1].OpenProject()
*!*			This.oSolution.lAutoCommitChanges = .T.
*!*			This.oSolution.cCleanupMessage    = 'message'
*!*			This.oSolution.CleanupSolution()
*!*			This.AssertTrue(ascan(This.oSolution.oVersionControl.aCommitFiles, ;
*!*				lower(justfname(This.cProject))) > 0, 'Did not commit cleanup')
*!*		endfunc

*!*	*******************************************************************************
*!*	* Test that CleanupSolution commits changes to meta data
*!*	*******************************************************************************
*!*		function Test_CleanupSolution_CommitsMetaData
*!*			This.SetupSolution(This.oSolution)
*!*			This.oSolution.AddProject(This.cProject)

*!*			lcMetaData = This.oSolution.oProjects[1].cMetaDataTable
*!*			create table (lcMetaData) (FIELD1 C(10), TEXT M)
*!*			index on FIELD1 tag FIELD1
*!*			use

*!*			This.oSolution.oVersionControl = createobject('MockVersionControl')
*!*			This.oSolution.oProjects[1].OpenProject()
*!*			This.oSolution.lAutoCommitChanges = .T.
*!*			This.oSolution.cCleanupMessage    = 'message'
*!*			This.oSolution.CleanupSolution()
*!*			erase (lcMetaData)
*!*			erase (forceext(lcMetaData, 'CDX'))
*!*			erase (forceext(lcMetaData, 'FPT'))
*!*			This.AssertTrue(ascan(This.oSolution.oVersionControl.aCommitFiles, ;
*!*				lower(justfname(This.oSolution.oProjects[1].cMetaDataTable))) > 0, ;
*!*				'Did not commit cleanup')
*!*		endfunc

*******************************************************************************
* Test that CleanupSolution changes project status
*******************************************************************************
	function Test_CleanupSolution_SetProjectStatus
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		This.oSolution.oProjects[1].OpenProject()
		This.oSolution.CleanupSolution()
		This.AssertEquals('C', ;
			This.oSolution.oProjects[1].oProjectItem.VersionControlStatus, ;
			'Did not set status')
	endfunc

*******************************************************************************
* Test that CleanupSolution calls the BeforeCleanupSolution addin
*******************************************************************************
	function Test_CleanupSolution_CallsBeforeCleanupSolution
		loAddins   = createobject('MockAddin')
		loSolution = newobject('ProjectExplorerSolution', ;
			'Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		loSolution.AddProject(This.cProject)
		loSolution.oProjects[1].OpenProject()
		loSolution.CleanupSolution()
		llAddin = ascan(loAddins.aMethods, 'BeforeCleanupSolution') > 0
		This.AssertTrue(llAddin, ;
			'Did not call BeforeCleanupSolution')
	endfunc

*******************************************************************************
* Test that CleanupSolution calls the AfterCleanupSolution addin
*******************************************************************************
	function Test_CleanupSolution_CallsAfterCleanupSolution
		loAddins   = createobject('MockAddin')
		loSolution = newobject('ProjectExplorerSolution', ;
			'Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		loSolution.AddProject(This.cProject)
		loSolution.oProjects[1].OpenProject()
		loSolution.CleanupSolution()
		llAddin = ascan(loAddins.aMethods, 'AfterCleanupSolution') > 0
		This.AssertTrue(llAddin, ;
			'Did not call AfterCleanupSolution')
	endfunc

*******************************************************************************
* Test that CleanupSolution fails if the BeforeCleanupSolution addin
* returns .F.
*******************************************************************************
	function Test_CleanupSolution_Fails_IfBeforeCleanupSolutionReturnsFalse
		loAddins = createobject('MockAddin')
		loSolution = newobject('ProjectExplorerSolution', ;
			'Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		loSolution.AddProject(This.cProject)
		loSolution.oProjects[1].OpenProject()
		loAddins.lValueToReturn = .F.
		llOK = loSolution.CleanupSolution()
		This.AssertFalse(llOK, 'Did not return .F.')
	endfunc

*******************************************************************************
* Test that AddVersionControl fails if no projects
*******************************************************************************
	function Test_AddVersionControl_FailsIfNoProjects
		llOK = This.oSolution.AddVersionControl()
		This.AssertFalse(llOK, ;
			'Did not return .F.')
	endfunc

*******************************************************************************
* Test that AddVersionControl creates a version control object
*******************************************************************************
	function Test_AddVersionControl_CreatesVersionControlObject
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .F., '', '', '', '', '')
		This.AssertNotNull(This.oSolution.oVersionControl, ;
			'Did not set oVersionControl')
	endfunc

*******************************************************************************
* Test that AddVersionControl sets the version control object of the
* projects
*******************************************************************************
	function Test_AddVersionControl_SetsVersionControl
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .F., '', '', '', '', '')
		This.AssertNotNull(This.oSolution.oProjects.Item(1).oVersionControl, ;
			'Did not set project version control')
	endfunc

*******************************************************************************
* Test that AddVersionControl creates a solution file
*******************************************************************************
	function Test_AddVersionControl_CreatesSolutionFile
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		erase (This.cSolutionFile)
		This.oSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .F., '', '', '', '', '')
		This.AssertTrue(file(This.cSolutionFile), ;
			'Did not create Solution.xml')
	endfunc

*******************************************************************************
* Test that AddVersionControl creates a repository
*******************************************************************************
	function Test_AddVersionControl_CreatesRepository
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .F., '', '', '', '', '')
		This.AssertTrue(This.oSolution.oVersionControl.lCreateRepositoryCalled, ;
			'Did not create repository')
	endfunc

*******************************************************************************
* Test that AddVersionControl adds the solution file to the repository
*******************************************************************************
	function Test_AddVersionControl_AddsSolutionToRepository
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .F., '', '', '', '', '')
		llAdded = ascan(This.oSolution.oVersionControl.aFiles, ;
			'solution.xml') > 0
		This.AssertTrue(llAdded, ;
			'Did not add solution file')
	endfunc

*******************************************************************************
* Test that AddVersionControl adds the project file to the repository
*******************************************************************************
	function Test_AddVersionControl_AddsProjectToRepository
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .F., '', '', '', '', '')
		llAdded = ascan(This.oSolution.oVersionControl.aFiles, ;
			lower(justfname(This.cProject))) > 0
		This.AssertTrue(llAdded, ;
			'Did not add project file')
	endfunc

*******************************************************************************
* Test that AddVersionControl adds the meta data files to the repository
*******************************************************************************
	function Test_AddVersionControl_AddsMetaDataToRepository
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		lcMetaData = This.oSolution.oProjects[1].cMetaDataTable
		create table (lcMetaData) (FIELD1 C(10), TEXT M)
		index on FIELD1 tag FIELD1
		use
		This.oSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .F., '', '', '', '', '')
		llAdded = ascan(This.oSolution.oVersionControl.aFiles, ;
			lower(justfname(lcMetaData))) > 0
		erase (lcMetaData)
		erase (forceext(lcMetaData, 'CDX'))
		erase (forceext(lcMetaData, 'FPT'))
		This.AssertTrue(llAdded, ;
			'Did not add meta data')
	endfunc

*******************************************************************************
* Test that AddVersionControl adds project items to the repository
*******************************************************************************
	function Test_AddVersionControl_AddsProjectItemsToRepository
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .F., '', '', '', '', '')
		llAdded = ascan(This.oSolution.oVersionControl.aFiles, ;
			lower(justfname(This.cFile))) > 0
		This.AssertTrue(llAdded, ;
			'Did not add project item')
	endfunc

*******************************************************************************
* Test that AddVersionControl commits all changes if auto-commit
*******************************************************************************
	function Test_AddVersionControl_CommitsAllChangesIfAutoCommit
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .T., '', '', '', '', '')
		This.AssertTrue(This.oSolution.oProjects.Item(1).lCloseProjectCalled, ;
			'Did not close project')
		This.AssertTrue(This.oSolution.oVersionControl.lCommitAllFilesCalled, ;
			'Did not commit all changes')
		This.AssertTrue(This.oSolution.oProjects.Item(1).lOpenProjectCalled, ;
			'Did not reopen project')
	endfunc

*******************************************************************************
* Test that AddVersionControl doesn't commit changes if not auto-commit
*******************************************************************************
	function Test_AddVersionControl_DoesntCommitsChangesIfNotAutoCommit
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .F., '', '', '', '', '')
		This.AssertFalse(This.oSolution.oVersionControl.lCommitAllFilesCalled, ;
			'Committed all changes')
	endfunc

*******************************************************************************
* Test that AddVersionControl calls the BeforeAddVersionControl addin
*******************************************************************************
	function Test_AddVersionControl_CallsBeforeAddVersionControl
		loAddins   = createobject('MockAddin')
		loSolution = newobject('ProjectExplorerSolution', ;
			'Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		loSolution.AddProject(This.cProject)
		loSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .F., '', '', '', '', '')
		llAddin = ascan(loAddins.aMethods, 'BeforeAddVersionControl') > 0
		This.AssertTrue(llAddin, ;
			'Did not call BeforeAddVersionControl')
	endfunc

*******************************************************************************
* Test that AddVersionControl calls the AfterAddVersionControl addin
*******************************************************************************
	function Test_AddVersionControl_CallsAfterAddVersionControl
		loAddins   = createobject('MockAddin')
		loSolution = newobject('ProjectExplorerSolution', ;
			'Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		loSolution.AddProject(This.cProject)
		loSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .F., '', '', '', '', '')
		llAddin = ascan(loAddins.aMethods, 'AfterAddVersionControl') > 0
		This.AssertTrue(llAddin, ;
			'Did not call AfterAddVersionControl')
	endfunc

*******************************************************************************
* Test that AddVersionControl fails if the BeforeAddVersionControl addin
* returns .F.
*******************************************************************************
	function Test_AddVersionControl_Fails_IfBeforeAddVersionControlReturnsFalse
		loAddins = createobject('MockAddin')
		loSolution = newobject('ProjectExplorerSolution', ;
			'Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		loSolution.AddProject(This.cProject)
		loAddins.lSuccess       = .F.
		loAddins.lValueToReturn = .F.
		llOK = loSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .F., '', '', '', '', '')
		This.AssertFalse(llOK, 'Did not return .F.')
	endfunc

*******************************************************************************
* Test that AddVersionControl succeeds if the BeforeAddVersionControl addin
* returns .F. but lSuccess is .T.
*******************************************************************************
	function Test_AddVersionControl_Succeeds_IfBeforeAddVersionControlSucceeds
		loAddins = createobject('MockAddin')
		loSolution = newobject('ProjectExplorerSolution', ;
			'Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		loSolution.AddProject(This.cProject)
		loAddins.lSuccess       = .T.
		loAddins.lValueToReturn = .F.
		llOK = loSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .F., '', '', '', '', '')
		This.AssertTrue(llOK, 'Did not return .T.')
	endfunc

*******************************************************************************
* Test that OpenSolution returns .F. if an invalid folder is specified (this
* actually tests all the ways it can fail in one test)
*******************************************************************************
	function Test_OpenSolution_Fails_InvalidFolder
		llOK = This.oSolution.OpenSolution()
		This.AssertFalse(llOK, 'Did not return .F. when nothing passed')
		llOK = This.oSolution.OpenSolution(5)
		This.AssertFalse(llOK, 'Did not return .F. when non-char passed')
		llOK = This.oSolution.OpenSolution('test')
		This.AssertFalse(llOK, ;
			'Did not return .F. when non-existent folder passed')
		llOK = This.oSolution.AddProject(This.cTestDataFolder)
		This.AssertFalse(llOK, ;
			'Did not return .F. when folder has no solution file')
		strtofile('xxx', This.cSolutionFile)
		llOK = This.oSolution.AddProject(This.cTestDataFolder)
		This.AssertFalse(llOK, ;
			'Did not return .F. when folder has invalid solution file')
	endfunc

*******************************************************************************
* Test that OpenSolution sets the version control object
*******************************************************************************
	function Test_OpenSolution_SetsVersionControl
		This.SetupSolution(This.oSolution)
		strtofile(This.cSolution, This.cSolutionFile)
		This.oSolution.OpenSolution(This.cTestDataFolder)
		This.AssertNotNull(This.oSolution.oVersionControl, ;
			'Did not set version control')
	endfunc

*******************************************************************************
* Test that OpenSolution adds the projects
*******************************************************************************
	function Test_OpenSolution_AddsProjects
		This.SetupSolution(This.oSolution)
		strtofile(This.cSolution, This.cSolutionFile)
		This.oSolution.OpenSolution(This.cTestDataFolder)
		This.AssertNotNull(This.oSolution.oProjects.Count = 1, ;
			'Did not add projects')
	endfunc

*******************************************************************************
* Test that OpenSolution calls the BeforeOpenSolution addin
*******************************************************************************
	function Test_OpenSolution_CallsBeforeOpenSolution
		loAddins   = createobject('MockAddin')
		loSolution = newobject('ProjectExplorerSolution', ;
			'Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		strtofile(This.cSolution, This.cSolutionFile)
		loSolution.OpenSolution(This.cTestDataFolder)
		llAddin = ascan(loAddins.aMethods, 'BeforeOpenSolution') > 0
		This.AssertTrue(llAddin, ;
			'Did not call BeforeOpenSolution')
	endfunc

*******************************************************************************
* Test that OpenSolution calls the AfterOpenSolution addin
*******************************************************************************
	function Test_OpenSolution_CallsAfterOpenSolution
		loAddins   = createobject('MockAddin')
		loSolution = newobject('ProjectExplorerSolution', ;
			'Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		strtofile(This.cSolution, This.cSolutionFile)
		loSolution.OpenSolution(This.cTestDataFolder)
		llAddin = ascan(loAddins.aMethods, 'AfterOpenSolution') > 0
		This.AssertTrue(llAddin, ;
			'Did not call AfterOpenSolution')
	endfunc

*******************************************************************************
* Test that OpenSolution fails if the BeforeOpenSolution addin
* returns .F.
*******************************************************************************
	function Test_SaveSolution_Fails_IfBeforeOpenSolutionReturnsFalse
		loAddins = createobject('MockAddin')
		loSolution = newobject('ProjectExplorerSolution', ;
			'Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		loAddins.lValueToReturn = .F.
		strtofile(This.cSolution, This.cSolutionFile)
		llOK = loSolution.OpenSolution(This.cTestDataFolder)
		This.AssertFalse(llOK, 'Did not return .F.')
	endfunc

*******************************************************************************
* Test that SaveSolution creates the correct solution file
*******************************************************************************
	function Test_SaveSolution_CreatesCorrectFile
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.AddVersionControl('MockVersionControl', ;
			This.cTestProgram, 1, .T., 'A', 'B', 'C', 'D', '')
		lcSolution = filetostr(This.cSolutionFile)
		This.AssertEquals(chrtran(upper(lcSolution), chr(13) + chr(10), ''), ;
			chrtran(upper(This.cSolution), chr(13) + chr(10), ''), ;
			'Solution file not correct')
	endfunc

*******************************************************************************
* Test that SaveSolution commits changes
*******************************************************************************
	function Test_SaveSolution_CommitsChanges
		This.SetupSolution(This.oSolution)
		This.oSolution.AddProject(This.cProject)
		This.oSolution.oVersionControl = createobject('MockVersionControl')
		This.oSolution.lAutoCommitChanges = .T.
		This.oSolution.SaveSolution()
		This.AssertTrue(This.oSolution.oVersionControl.lCommitFileCalled, ;
			'Did not commit solution')
	endfunc

*******************************************************************************
* Test that SaveSolution calls the BeforeSaveSolution addin
*******************************************************************************
	function Test_SaveSolution_CallsBeforeSaveSolution
		loAddins   = createobject('MockAddin')
		loSolution = newobject('ProjectExplorerSolution', ;
			'Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		loSolution.AddProject(This.cProject)
		loSolution.SaveSolution()
		llAddin = ascan(loAddins.aMethods, 'BeforeSaveSolution') > 0
		This.AssertTrue(llAddin, ;
			'Did not call BeforeSaveSolution')
	endfunc

*******************************************************************************
* Test that SaveSolution calls the AfterSaveSolution addin
*******************************************************************************
	function Test_SaveSolution_CallsAfterSaveSolution
		loAddins   = createobject('MockAddin')
		loSolution = newobject('ProjectExplorerSolution', ;
			'Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		loSolution.AddProject(This.cProject)
		loSolution.SaveSolution()
		llAddin = ascan(loAddins.aMethods, 'AfterSaveSolution') > 0
		This.AssertTrue(llAddin, ;
			'Did not call AfterSaveSolution')
	endfunc

*******************************************************************************
* Test that SaveSolution fails if the BeforeSaveSolution addin
* returns .F.
*******************************************************************************
	function Test_SaveSolution_Fails_IfBeforeSaveSolutionReturnsFalse
		loAddins = createobject('MockAddin')
		loSolution = newobject('ProjectExplorerSolution', ;
			'Source\ProjectExplorerEngine.vcx', '', loAddins)
		This.SetupSolution(loSolution)
		loSolution.AddProject(This.cProject)
		loAddins.lValueToReturn = .F.
		llOK = loSolution.SaveSolution()
		This.AssertFalse(llOK, 'Did not return .F.')
	endfunc
enddefine

*******************************************************************************
* Mock classes
*******************************************************************************
define class MockProjectEngine as Custom
	oVersionControl       = .NULL.
	oProjectSettings      = .NULL.
	oProjectItems         = .NULL.
	oProjectItem          = .NULL.
	oProject              = .NULL.
	cProject              = ''
	lOpenProjectCalled    = .F.
	lCloseProjectCalled   = .F.
	lCleanupProjectCalled = .F.
	cMetaDataTable        = ''

	function Init(toAddins)
		This.oProjectSettings = newobject('ProjectSettings', ;
			'Source\ProjectExplorerEngine.vcx')
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
		This.cMetaDataTable = addbs(justpath(tcProject)) + sys(2015) + '.dbf'
	endfunc

	function OpenProject()
		This.lOpenProjectCalled = .T.
		This.oProject           = createobject('MockProject')
		This.oProjectItem       = createobject('MockProjectItem')
	endfunc

	function CloseProject()
		This.lCloseProjectCalled = .T.
	endfunc

	function CleanupProject(tlRemoveObjectCode, tcMessage)
		This.lCleanupProjectCalled = .T.
	endfunc
enddefine

define class MockProjectItem as Custom
	Path = ''
	VersionControlStatus = ''
enddefine

define class MockProject as Custom
	lCleanupCalled = .F.
	
	function Cleanup(tlRemoveObjectCode)
		This.lCleanupCalled = .T.
	endfunc
enddefine

define class MockAddin as Custom
	dimension aMethods[1]
	lSuccess       = .T.
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
	cFileAddMessage             = ''
	cFileRemoveMessage          = ''
	lAutoCommitChanges          = .F.
	nIncludeInVersionControl    = .F.
	cErrorMessage               = ''
	
	lGetStatusForAllFilesCalled = .F.
	lGetStatusForFileCalled     = .F.
	lCreateRepositoryCalled     = .F.
	lCommitAllFilesCalled       = .F.
	lCommitFileCalled           = .F.
	lCommitFilesCalled          = .F.
	lRevertFileCalled           = .F.
	dimension aFiles[1]
	dimension aCommitFiles[1]
	
	function Init(tnIncludeInVersionControl, tlAutoCommit, tcFileAddMessage, ;
		tcFileRemoveMessage, toAddins, tcFoxBin2PRGLocation)
	endfunc

	function GetStatusForAllFiles(toItems, tcFolder)
		This.lGetStatusForAllFilesCalled = .T.
	endfunc

	function GetStatusForFile(tcFile, tcFolder)
		This.lGetStatusForFileCalled = .T.
		return 'C'
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

	function CommitFile(tcMessage, tcFile, tcFolder)
		This.lCommitFileCalled = .T.
		if empty(This.aCommitFiles[1])
			lnFiles = 1
		else
			lnFiles = alen(This.aCommitFiles) + 1
			dimension This.aCommitFiles[lnFiles]
		endif empty(This.aCommitFiles[1])
		This.aCommitFiles[lnFiles] = lower(justfname(tcFile))
	endfunc

	function CommitAllFiles(tcMessage, tcProject, tlNoText)
		This.lCommitAllFilesCalled = .T.
	endfunc

	function CommitFiles(tcMessage, taFiles)
		This.lCommitFilesCalled = .T.
	endfunc

	function RevertFile(tcFile, tcFolder)
		This.lRevertFileCalled = .T.
	endfunc

	function Release
	endfunc
enddefine
