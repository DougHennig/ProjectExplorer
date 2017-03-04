*******************************************************************************
define class ProjectAddinsTests as FxuTestCase of FxuTestCase.prg
*******************************************************************************
	#IF .f.
	LOCAL THIS AS ProjectAddinsTests OF ProjectAddinsTests.PRG
	#ENDIF
	
	cTestFolder     = ''
	cTestDataFolder = ''
	cTestProgram    = ''
	icTestPrefix    = 'Test_'
	
	oAddins             = .NULL.
	cAddinsFolder       = ''
	lErrorEventRaised   = .F.
	lExecuteEventRaised = .F.

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

		This.cAddinsFolder = This.cTestDataFolder + 'Addins\'
		if not directory(This.cAddinsFolder)
			md (This.cAddinsFolder)
		endif not directory(This.cAddinsFolder)
	endfunc

*******************************************************************************
* Clean up on exit.
*******************************************************************************
	function TearDown
		erase (This.cAddinsFolder + '*.prg')
		erase (This.cAddinsFolder + '*.fxp')
		erase (This.cAddinsFolder + '*.err')
		rd (This.cAddinsFolder)
	endfunc

*******************************************************************************
* Set up addins object.
*******************************************************************************
	function SetupAddins(tcMethod, tlActive, tcCode, tlReturn)
		erase (This.cAddinsFolder + 'addin.prg')
		if not empty(tcMethod)
			text to lcCode noshow textmerge
lparameters toParameter1, ;
	tuParameter2
if pcount() = 1
	toParameter1.Method = '<<tcMethod>>'
	toParameter1.Active = <<transform(tlActive)>>
	return
endif
<<tcCode>>
return <<transform(tlReturn)>>
			endtext
			strtofile(lcCode, This.cAddinsFolder + 'addin.prg')
		endif not empty(tcMethod)
		This.oAddins = newobject('ProjectAddins', ;
			'Source\ProjectExplorerEngine.vcx', '', This.cTestDataFolder)
	endfunc

*******************************************************************************
* Test that ExecuteAddin fails when invalid method passed.
*******************************************************************************
	function Test_ExecuteAddin_Fails_InvalidMethod
		This.SetupAddins()
		llOK = This.oAddins.ExecuteAddin()
		This.AssertFalse(llOK, 'Did not return .F. when nothing passed')
		llOK = This.oAddins.ExecuteAddin(5)
		This.AssertFalse(llOK, 'Did not return .F. when non-char passed')
		llOK = This.oAddins.ExecuteAddin('')
		This.AssertFalse(llOK, 'Did not return .F. when blank passed')
	endfunc

*******************************************************************************
* Test that ExecuteAddin returns .T. when there are no addins
*******************************************************************************
	function Test_ExecuteAddin_ReturnsTrue_NoAddins
		This.SetupAddins()
		llOK = This.oAddins.ExecuteAddin('test')
		This.AssertTrue(llOK, 'Did not return .T. when no addins')
	endfunc

*******************************************************************************
* Test that ExecuteAddin clears lAddinsExecuted when there are no addins
*******************************************************************************
	function Test_ExecuteAddin_ClearsAddinsExecutedFlag_NoAddins
		This.SetupAddins()
		This.oAddins.ExecuteAddin('test')
		This.AssertFalse(This.oAddins.lAddinsExecuted, ;
			'lAddinsExecuted is .T. when no addins')
	endfunc

*******************************************************************************
* Test that ExecuteAddin clears lAddinsExecuted when only inactive addins
*******************************************************************************
	function Test_ExecuteAddin_ClearsAddinsExecutedFlag_NoActiveAddins
		This.SetupAddins('test', .F., '', .T.)
		This.oAddins.ExecuteAddin('test')
		This.AssertFalse(This.oAddins.lAddinsExecuted, ;
			'lAddinsExecuted is .T. when no active addins')
	endfunc

*******************************************************************************
* Test that ExecuteAddin clears lAddinsExecuted when no addins for specified
* method
*******************************************************************************
	function Test_ExecuteAddin_ClearsAddinsExecutedFlag_NoAddinsForMethod
		This.SetupAddins('test', .F., '', .T.)
		This.oAddins.ExecuteAddin('test2')
		This.AssertFalse(This.oAddins.lAddinsExecuted, ;
			'lAddinsExecuted is .T. when no addins for method')
	endfunc

*******************************************************************************
* Test that ExecuteAddin sets lAddinsExecuted when addin executed
*******************************************************************************
	function Test_ExecuteAddin_SetsAddinsExecutedFlag
		This.SetupAddins('test', .T., '', .T.)
		This.oAddins.ExecuteAddin('test')
		This.AssertTrue(This.oAddins.lAddinsExecuted, ;
			'lAddinsExecuted is .F. when addin executed')
	endfunc

*******************************************************************************
* Test that ExecuteAddin returns .T. when addin returns .T.
*******************************************************************************
	function Test_ExecuteAddin_ReturnsTrue_WhenAddinDoes
		This.SetupAddins('test', .T., '', .T.)
		llOK = This.oAddins.ExecuteAddin('test')
		This.AssertTrue(llOK, 'Returned .F. when addin returned .T.')
	endfunc

*******************************************************************************
* Test that ExecuteAddin returns .F. when addin returns .F.
*******************************************************************************
	function Test_ExecuteAddin_ReturnsFalse_WhenAddinDoes
		This.SetupAddins('test', .T., '', .F.)
		llOK = This.oAddins.ExecuteAddin('test')
		This.AssertFalse(llOK, 'Returned .T. when addin returned .F.')
	endfunc

*******************************************************************************
* Test that ExecuteAddin raises ErrorOccurred when an error occurs
* during addin execution
*******************************************************************************
	function Test_ExecuteAddin_RaisesErrorOccurred
		This.SetupAddins('test', .T., 'x = y', .F.)
		bindevent(This.oAddins, 'ErrorOccurred', This, 'ErrorEventRaised')
		This.oAddins.ExecuteAddin('test')
		This.AssertTrue(This.lErrorEventRaised, 'Event not raised')
	endfunc

	function ErrorEventRaised(tcMessage)
		This.lErrorEventRaised = .T.
	endfunc

*******************************************************************************
* Test that ExecuteAddin raises AddinsExecuted
*******************************************************************************
	function Test_ExecuteAddin_RaisesAddinsExecuted
		This.SetupAddins('test', .T., '', .T.)
		bindevent(This.oAddins, 'AddinsExecuted', This, 'ExecuteEventRaised')
		This.oAddins.ExecuteAddin('test')
		This.AssertTrue(This.lExecuteEventRaised, 'Event not raised')
	endfunc

	function ExecuteEventRaised(tcMessage)
		This.lExecuteEventRaised = .T.
	endfunc

*******************************************************************************
* Test that GetAddins compiles PRGs
*******************************************************************************
	function Test_GetAddins_CompilesPRGs
		This.SetupAddins('test', .T., '', .F.)
		This.AssertTrue(file(This.cAddinsFolder + 'addin.fxp'), ;
			'Did not compile PRG')
	endfunc

*******************************************************************************
* Test that GetAddins sets cErrorMessage when run fails
*******************************************************************************
	function Test_GetAddins_SetsErrorMessage_RunFails
		This.SetupAddins('test', 5, '', .F.)
		This.AssertTrue(not empty(This.oAddins.cErrorMessage), ;
			'Did not set cErrorMessage')
	endfunc

*******************************************************************************
* Test that GetAddins sets cErrorMessage when compile fails
*******************************************************************************
	function Test_GetAddins_SetsErrorMessage_CompileFails
		strtofile('xxx', This.cAddinsFolder + 'addin2.prg')
		This.SetupAddins('test', .T., '', .F.)
		This.AssertTrue(not empty(This.oAddins.cErrorMessage), ;
			'Did not set cErrorMessage')
	endfunc
enddefine
