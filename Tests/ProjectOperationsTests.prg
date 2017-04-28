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
		This.AssertTrue(vartype(loFile) <> 'O', ;
			'Returned file when no project passed')
		loFile = This.oOperations.AddItem(5)
		This.AssertTrue(vartype(loFile) <> 'O', ;
			'Returned file when no project object passed')
	endfunc

*******************************************************************************
* Test that AddItem fails if an invalid file is passed (this actually tests all
* the ways it can fail in one test)
*******************************************************************************
	function Test_AddItem_Fails_InvalidFile
		loFile = This.oOperations.AddItem(This.oProject)
		This.AssertTrue(vartype(loFile) <> 'O', ;
			'Returned file when no file passed')
		loFile = This.oOperations.AddItem(This.oProject, 5)
		This.AssertTrue(vartype(loFile) <> 'O', ;
			'Returned file when non-char passed')
		loFile = This.oOperations.AddItem(This.oProject, '')
		This.AssertTrue(vartype(loFile) <> 'O', ;
			'Returned file when empty passed')
		loFile = This.oOperations.AddItem(This.oProject, 'xxx.txt')
		This.AssertTrue(vartype(loFile) <> 'O', ;
			'Returned file when non-existent file passed')
	endfunc

*******************************************************************************
* Test that AddItem fails if an invalid type is passed (this actually tests all
* the ways it can fail in one test)
*******************************************************************************
	function Test_AddItem_Fails_InvalidType
		loFile = This.oOperations.AddItem(This.oProject, This.cFile, 5)
		This.AssertTrue(vartype(loFile) <> 'O', ;
			'Returned file when non-char passed')
		loFile = This.oOperations.AddItem(This.oProject, This.cFile, 'a')
		This.AssertTrue(vartype(loFile) <> 'O', ;
			'Returned file when invalid type passed')
	endfunc

*******************************************************************************
* Test that AddItem adds a file to the collection
*******************************************************************************
	function Test_AddItem_AddsFile
		This.oOperations.AddItem(This.oProject, This.cFile, 'T')
		This.AssertTrue(This.oProject.Files.Count = 1, ;
			'File not added')
	endfunc

*******************************************************************************
* Test that AddItem returns the added file
*******************************************************************************
	function Test_AddItem_ReturnsFile
		loFile = This.oOperations.AddItem(This.oProject, This.cFile, 'T')
		This.AssertNotNull(loFile, 'File not returned')
	endfunc

*******************************************************************************
* Test that AddItem sets the file type
*******************************************************************************
	function Test_AddItem_SetsFileType
		loFile = This.oOperations.AddItem(This.oProject, This.cFile, 'Q')
		This.AssertEquals(loFile.Type, 'Q', 'Did not set type')
	endfunc

*******************************************************************************
* Test that AddItem doesn't set MainFile for a VCX
*******************************************************************************
	function Test_AddItem_DoesntSetMainFileForVCX
		lcProject = This.cTestDataFolder + 'test.pjx'
		create project (lcProject) nowait noshow
		loProject = _vfp.ActiveProject
		lcVCX     = This.cTestDataFolder + 'test.vcx'
		lcVCT     = forceext(lcVCX, 'vct')
		strtofile('xxx', lcVCX)
		strtofile('xxx', lcVCT)

		loFile = This.oOperations.AddItem(loProject, lcVCX, 'V')
		loProject.Close()
			&& loProject.MainFile doesn't get reset until close and reopen project
		modify project (lcProject) nowait noshow
		loProject  = _vfp.ActiveProject
		lcMainFile = loProject.MainFile
		loProject.Close
		erase (lcProject)
		erase (forceext(lcProject, 'pjt'))
		erase (lcVCX)
		erase (lcVCT)
		This.AssertEquals('', lcMainFile, 'Did not turn off MainFile')
	endfunc

*******************************************************************************
* Test that AddItem calls the BeforeAddItem addin
*******************************************************************************
	function Test_AddItem_CallsBeforeAddItem
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
		loOperations.AddItem(This.oProject, This.cFile, 'T')
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
		loOperations.AddItem(This.oProject, This.cFile, 'T')
		llAddin = ascan(This.oAddins.aMethods, 'AfterAddItem') > 0
		This.AssertTrue(llAddin, ;
			'Did not call AfterAddItem ')
	endfunc

*******************************************************************************
* Test that AddItem fails if the BeforeAddItem addin returns .F.
*******************************************************************************
	function Test_AddItem_Fails_IfBeforeAddItemReturnsFalse
		This.oAddins.lSuccess       = .F.
		This.oAddins.lValueToReturn = .F.
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
		loFile = loOperations.AddItem(This.oProject, This.cFile, 'T')
		This.AssertTrue(vartype(loFile) <> 'O', 'Added file')
	endfunc

*******************************************************************************
* Test that AddItem succeeds if the BeforeAddItem addin returns .F. but
* lSuccess is .T.
*******************************************************************************
	function Test_AddItem_Succeeds_IfBeforeAddItemSucceeds
		This.oAddins.lSuccess       = .T.
		This.oAddins.lValueToReturn = .F.
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
		loFile = loOperations.AddItem(This.oProject, This.cFile, 'T')
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
		This.oItem.CanRemove = .F.
		llOK = This.oOperations.RemoveItem(This.oProject, This.oItem)
		This.AssertFalse(llOK, 'Returned .T. when item cannot be removed')
	endfunc

*******************************************************************************
* Test that RemoveItem calls item's RemoveItem method
*******************************************************************************
	function Test_RemoveItem_CallsRemoveItem
		This.oOperations.RemoveItem(This.oProject, This.oItem)
		This.AssertTrue(This.oItem.lRemoveItemCalled, 'Did not call RemoveItem')
	endfunc

*******************************************************************************
* Test that RemoveItem returns .T. when item RemoveItem does
*******************************************************************************
	function Test_RemoveItem_ReturnsTrue
		llOK = This.oOperations.RemoveItem(This.oProject, This.oItem)
		This.AssertTrue(llOK, 'Returned .F. when item removed')
	endfunc

*******************************************************************************
* Test that RemoveItem returns .F. when item RemoveItem does
*******************************************************************************
	function Test_RemoveItem_ReturnsFalse
		This.oItem.lRemoveItemReturns = .F.
		llOK = This.oOperations.RemoveItem(This.oProject, This.oItem)
		This.AssertFalse(llOK, 'Returned .T. when item not removed')
	endfunc

*******************************************************************************
* Test that RemoveItem calls the BeforeRemoveItem addin
*******************************************************************************
	function Test_RemoveItem_CallsBeforeRemoveItem
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
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
		loOperations.RemoveItem(This.oProject, This.oItem)
		llAddin = ascan(This.oAddins.aMethods, 'AfterRemoveItem') > 0
		This.AssertTrue(llAddin, ;
			'Did not call AfterRemoveItem')
	endfunc

*******************************************************************************
* Test that RemoveItem fails if the BeforeRemoveItem addin returns .F.
*******************************************************************************
	function Test_RemoveItem_Fails_IfBeforeRemoveItemReturnsFalse
		This.oAddins.lSuccess       = .F.
		This.oAddins.lValueToReturn = .F.
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
		llOK = loOperations.RemoveItem(This.oProject, This.oItem)
		This.AssertFalse(llOK, 'Removed file')
	endfunc

*******************************************************************************
* Test that RemoveItem succeeds if the BeforeRemoveItem addin returns .F. but
* lSuccess is .T.
*******************************************************************************
	function Test_RemoveItem_Succeeds_IfBeforeRemoveItemSucceeds
		This.oAddins.lSuccess       = .T.
		This.oAddins.lValueToReturn = .F.
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
		llOK = loOperations.RemoveItem(This.oProject, This.oItem)
		This.AssertTrue(llOK, 'Removed file')
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
	function Test_BuildProject_Fails_IfBeforeBuildProjectReturnsFalse
		This.oAddins.lSuccess       = .F.
		This.oAddins.lValueToReturn = .F.
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
		llOK = loOperations.BuildProject(This.oProject)
		This.AssertFalse(llOK, 'Built project')
	endfunc

*******************************************************************************
* Test that BuildProject succeeds if the BeforeBuildProject addin returns .F.
* but lSuccess is .T.
*******************************************************************************
	function Test_BuildProject_Succeeds_IfBeforeBuildProjectSucceeds
		This.oAddins.lSuccess       = .T.
		This.oAddins.lValueToReturn = .F.
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
		llOK = loOperations.BuildProject(This.oProject)
		This.AssertTrue(llOK, 'Built project')
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
		This.oItem.CanEdit = .F.
		llOK = This.oOperations.EditItem(This.oProject, This.oItem)
		This.AssertFalse(llOK, 'Returned .T. when item cannot be edited')
	endfunc

*******************************************************************************
* Test that EditItem calls item's EditItem method
*******************************************************************************
	function Test_EditItem_CallsEditItem
		This.oOperations.EditItem(This.oProject, This.oItem)
		This.AssertTrue(This.oItem.lEditItemCalled, 'Did not call EditItem')
	endfunc

*******************************************************************************
* Test that EditItem returns .T. when item EditItem does
*******************************************************************************
	function Test_EditItem_ReturnsTrue
		llOK = This.oOperations.EditItem(This.oProject, This.oItem)
		This.AssertTrue(llOK, 'Returned .F. when item edited')
	endfunc

*******************************************************************************
* Test that EditItem returns .F. when item EditItem does
*******************************************************************************
	function Test_EditItem_ReturnsFalse
		This.oItem.lEditItemReturns = .F.
		llOK = This.oOperations.EditItem(This.oProject, This.oItem)
		This.AssertFalse(llOK, 'Returned .T. when item not edited')
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
	function Test_EditItem_Fails_IfBeforeModifyItemReturnsFalse
		This.oAddins.lSuccess       = .F.
		This.oAddins.lValueToReturn = .F.
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
		llOK = loOperations.EditItem(This.oProject, This.oItem)
		This.AssertFalse(llOK, 'Edited item')
	endfunc

*******************************************************************************
* Test that EditItem succeeds if the BeforeModifyItem addin returns .F. but
* lSuccess is .T.
*******************************************************************************
	function Test_EditItem_Succeeds_IfBeforeModifyItemSucceeds
		This.oAddins.lSuccess       = .T.
		This.oAddins.lValueToReturn = .F.
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
		llOK = loOperations.EditItem(This.oProject, This.oItem)
		This.AssertTrue(llOK, 'Edited item')
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
		This.oItem.CanRun = .F.
		llOK = This.oOperations.RunItem(This.oProject, This.oItem)
		This.AssertFalse(llOK, 'Returned .T. when item cannot be run')
	endfunc

*******************************************************************************
* Test that RunItem calls item's RunItem method
*******************************************************************************
	function Test_RunItem_CallsRunItem
		This.oOperations.RunItem(This.oProject, This.oItem)
		This.AssertTrue(This.oItem.lRunItemCalled, 'Did not call RunItem')
	endfunc

*******************************************************************************
* Test that RunItem returns .T. when item RunItem does
*******************************************************************************
	function Test_RunItem_ReturnsTrue
		llOK = This.oOperations.RunItem(This.oProject, This.oItem)
		This.AssertTrue(llOK, 'Returned .F. when item run')
	endfunc

*******************************************************************************
* Test that RunItem returns .F. when item RunItem does
*******************************************************************************
	function Test_RunItem_ReturnsFalse
		This.oItem.lRunItemReturns = .F.
		llOK = This.oOperations.RunItem(This.oProject, This.oItem)
		This.AssertFalse(llOK, 'Returned .T. when item not run')
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
	function Test_RunItem_Fails_IfBeforeRunItemReturnsFalse
		This.oAddins.lSuccess       = .F.
		This.oAddins.lValueToReturn = .F.
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
		llOK = loOperations.RunItem(This.oProject, This.oItem)
		This.AssertFalse(llOK, 'Ran item')
	endfunc

*******************************************************************************
* Test that RunItem succeeds if the BeforeRunItem addin returns .F. but
* lSuccess is .T.
*******************************************************************************
	function Test_RunItem_Succeeds_IfBeforeRunItemSucceeds
		This.oAddins.lSuccess       = .T.
		This.oAddins.lValueToReturn = .F.
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
		llOK = loOperations.RunItem(This.oProject, This.oItem)
		This.AssertTrue(llOK, 'Ran item')
	endfunc

*******************************************************************************
* Test that NewItem fails if an invalid project is passed (this actually tests
* all the ways it can fail in one test)
*******************************************************************************
	function Test_NewItem_Fails_InvalidProject
		llOK = This.oOperations.NewItem()
		This.AssertFalse(llOK, 'Returned .T. when no project passed')
		llOK = This.oOperations.NewItem(5)
		This.AssertFalse(llOK, 'Returned .T. when no project object passed')
	endfunc

*******************************************************************************
* Test that NewItem fails if an invalid item is passed (this actually tests all
* the ways it can fail in one test)
*******************************************************************************
	function Test_NewItem_Fails_InvalidItem
		llOK = This.oOperations.NewItem(This.oProject)
		This.AssertFalse(llOK, 'Returned .T. when no item passed')
		llOK = This.oOperations.NewItem(This.oProject, 5)
		This.AssertFalse(llOK, 'Returned .T. when no item object passed')
	endfunc

*******************************************************************************
* Test that NewItem calls item's NewItem
*******************************************************************************
	function Test_NewItem_CallsNewItem
		This.oOperations.NewItem(This.oProject, This.oItem)
		This.AssertTrue(This.oItem.lNewItemCalled, 'Did not call NewItem')
	endfunc

*******************************************************************************
* Test that NewItem calls projecthook QueryNewFile
*******************************************************************************
	function Test_NewItem_CallsQueryNewFile
		This.oProject.ProjectHook = createobject('MockProjectHook')
		This.oOperations.NewItem(This.oProject, This.oItem)
		This.AssertEquals(This.oItem.Type, This.oProject.ProjectHook.cType, ;
			'Did not call QueryNewFile')
	endfunc

*******************************************************************************
* Test that NewItem calls the BeforeNewItem addin
*******************************************************************************
	function Test_NewItem_CallsBeforeNewItem
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
		loOperations.NewItem(This.oProject, This.oItem)
		llAddin = ascan(This.oAddins.aMethods, 'BeforeNewItem') > 0
		This.AssertTrue(llAddin, ;
			'Did not call BeforeNewItem')
	endfunc

*******************************************************************************
* Test that NewItem calls the AfterNewItem addin
*******************************************************************************
	function Test_NewItem_CallsAfterNewItem
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
		loOperations.NewItem(This.oProject, This.oItem)
		llAddin = ascan(This.oAddins.aMethods, 'AfterNewItem') > 0
		This.AssertTrue(llAddin, ;
			'Did not call AfterNewItem ')
	endfunc

*******************************************************************************
* Test that NewItem fails if the BeforeNewItem addin returns .F.
*******************************************************************************
	function Test_NewItem_Fails_IfBeforeNewItemReturnsFalse
		This.oAddins.lSuccess       = .F.
		This.oAddins.lValueToReturn = .F.
		loOperations = newobject('ProjectOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oAddins)
		llOK = loOperations.NewItem(This.oProject, This.oItem)
		This.AssertFalse(llOK, 'Returned .T.')
	endfunc
enddefine

*******************************************************************************
* Mock classes
*******************************************************************************
define class MockProject as Custom
	Files        = .NULL.
	ProjectHook  = .NULL.
	lBuildCalled = .F.
	MainFile     = ''
	
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
		loFile = createobject('Custom')
		addproperty(loFile, 'Type', 'T')
		dodefault(loFile, tcFile)
		nodefault
		return loFile
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

define class MockItem as Custom
	Type          = ''
	Path          = ''
	ItemName      = ''
	ParentPath    = ''
	IsFile        = .T.
	CanEdit       = .T.
	CanRemove     = .T.
	CanRun        = .T.
	cErrorMessage = ''

	lRemoveItemCalled  = .F.
	lRemoveItemReturns = .T.

	lEditItemCalled  = .F.
	lEditItemReturns = .T.

	lRunItemCalled  = .F.
	lRunItemReturns = .T.

	lNewItemCalled  = .F.
	lNewItemReturns = .T.
	
	function RemoveItem(toProject, tlDelete)
		This.lRemoveItemCalled = .T.
		return This.lRemoveItemReturns
	endfunc
	
	function EditItem(toProject)
		This.lEditItemCalled = .T.
		return This.lEditItemReturns
	endfunc
	
	function RunItem(toProject)
		This.lRunItemCalled = .T.
		return This.lRunItemReturns
	endfunc

	function NewItem
		This.lNewItemCalled = .T.
		return This.lNewItemReturns
	endfunc
enddefine

define class MockProjectHook as Custom
	cType = ''

	function QueryNewFile(tcType)
		This.cType = tcType
	endfunc
enddefine
