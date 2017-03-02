**********************************************************************
define class MercurialOperationsTests as FxuTestCase of FxuTestCase.prg
**********************************************************************
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

********************************************************************
* Setup for the tests
********************************************************************
	function Setup

* Get the folder the tests are running from, the name of this test
* program, and create a test data folder if necessary.

		lcProgram            = sys(16)
		This.cTestProgram    = substr(lcProgram, at(' ', lcProgram, 2) + 1)
		This.cTestFolder     = addbs(justpath(This.cTestProgram))
		This.cTestDataFolder = addbs(sys(2023)) + addbs(sys(2015))
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

********************************************************************
* Clean up on exit.
********************************************************************
	function TearDown
*		erase (This.cFile)
set step on 
		lcFolder = '"' + left(This.cTestDataFolder, ;
			len(This.cTestDataFolder) - 1) + '"'
		run /n rmdir &lcFolder /s /q
		set path to (This.cCurrPath)
	endfunc

********************************************************************
* Helper method to set up the operations object and create a repository.
********************************************************************
	function SetupOperations(tnIncludeInVersionControl, tlAutoCommit)
		This.oOperations = newobject('MercurialOperations', ;
			'Source\ProjectExplorerEngine.vcx', '', ;
			tnIncludeInVersionControl, tlAutoCommit, 'file added', ;
			'file removed')
set step on 
		This.oOperations.CreateRepository(This.cTestDataFolder)
	endfunc

********************************************************************
* Test that CreateRepository fails if an invalid folder is passed (this actually tests
* all the ways it can fail in one test)
********************************************************************
	function Test_CreateRepository_Fails_InvalidFolder
		llOK = This.oOperations.CreateRepository()
		This.AssertFalse(llOK, 'Returned .T. when no folder passed')
		llOK = This.oOperations.CreateRepository('')
		This.AssertFalse(llOK, 'Returned .T. when empty folder passed')
		llOK = This.oOperations.CreateRepository('xxx')
		This.AssertFalse(llOK, 'Returned .T. when non-existent folder passed')
	endfunc

********************************************************************
* Test that CreateRepository creates a repository
********************************************************************
	function Test_CreateRepository_CreatesRepository
		This.AssertTrue(directory(This.cRepoFolder), 'Did not create .hg')
	endfunc
enddefine
