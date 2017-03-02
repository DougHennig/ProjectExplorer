*******************************************************************************
define class ProjectItemCollectionTests as FxuTestCase of FxuTestCase.prg
*******************************************************************************
	#IF .f.
	LOCAL THIS AS ProjectItemCollectionTests OF ProjectItemCollectionTests.PRG
	#ENDIF
	
	cTestFolder     = ''
	cTestDataFolder = ''
	cTestProgram    = ''
	icTestPrefix    = 'Test_'
	ilAllowDebug    = .T.
	
	cProject        = ''
	oProject        = .NULL.

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
	endfunc

*******************************************************************************
* Clean up on exit.
*******************************************************************************
	function TearDown
	endfunc

*******************************************************************************
* Test that GetItemForFile returns NULL if an invalid file is specified (this
* actually tests all the ways it can fail in one test)
*******************************************************************************
	function Test_GetItemForFile_Fails_InvalidFile
		loItems = newobject('ProjectItemCollection', ;
			'source\ProjectExplorerEngine.vcx')
		loItem = loItems.GetItemForFile()
		This.AssertTrue(isnull(loItem), ;
			'Did not return null when nothing passed')
		loItem = loItems.GetItemForFile(5)
		This.AssertTrue(isnull(loItem), ;
			'Did not return null when non-char passed')
	endfunc

*******************************************************************************
* Test that GetItemForFile finds the item for the specified file name
*******************************************************************************
	function Test_GetItemForFile_GetsItem
		loItems = newobject('ProjectItemCollection', ;
			'source\ProjectExplorerEngine.vcx')
		loItem1 = createobject('Empty')
		addproperty(loItem1, 'Key',    sys(2015))
		addproperty(loItem1, 'Path',   'x.txt')
		addproperty(loItem1, 'IsFile', .T.)
		loItems.Add(loItem1, loItem1.Key)
		loItem2 = createobject('Empty')
		addproperty(loItem2, 'Key',    sys(2015))
		addproperty(loItem2, 'Path',   'y.txt')
		addproperty(loItem2, 'IsFile', .T.)
		loItems.Add(loItem2, loItem2.Key)
		
		loItem = loItems.GetItemForFile('x.txt')
		This.AssertEquals(loItem1.Key, loItem.Key, 'Wrong item')
	endfunc

*******************************************************************************
* Test that GetItemForFile returns null when it doesn't finds the file
*******************************************************************************
	function Test_GetItemForFile_ReturnsNull_NoFile
		loItems = newobject('ProjectItemCollection', ;
			'source\ProjectExplorerEngine.vcx')
		loItem1 = createobject('Empty')
		addproperty(loItem1, 'Key',    sys(2015))
		addproperty(loItem1, 'Path',   'x.txt')
		addproperty(loItem1, 'IsFile', .T.)
		loItems.Add(loItem1, loItem1.Key)
		loItem2 = createobject('Empty')
		addproperty(loItem2, 'Key',    sys(2015))
		addproperty(loItem2, 'Path',   'y.txt')
		addproperty(loItem2, 'IsFile', .T.)
		loItems.Add(loItem2, loItem2.Key)
		
		loItem = loItems.GetItemForFile('z.txt')
		This.AssertTrue(isnull(loItem), 'Wrong item')
	endfunc
enddefine
