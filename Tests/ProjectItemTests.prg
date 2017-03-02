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
			'Source\ProjectExplorerEngine.vcx')

* This array defines the different types of items and what the expected
* capability is: column 2 is whether it's a file, column 3 is whether it can be
* edited, column 4 is whether it can be included in the project, column 5 is
* whether it can be removed, column 6 is whether it can be run, and column 7 is
* whether it can be the main file.

		dimension This.aTypes[21, 7]
		This.aTypes[ 1, 1] = 'Class'
		This.aTypes[ 2, 1] = 'Connection'
		This.aTypes[ 3, 1] = 'RemoteView'
		This.aTypes[ 4, 1] = 'LocalView'
		This.aTypes[ 5, 1] = 'Field'
		This.aTypes[ 6, 1] = 'Index'
		This.aTypes[ 7, 1] = 'SProc'
		This.aTypes[ 8, 1] = 'V'	&& VCX
		This.aTypes[ 9, 1] = 'P'	&& PRG
		This.aTypes[10, 1] = 'K'	&& form
		This.aTypes[11, 1] = 'x'	&& file
		This.aTypes[12, 1] = 'T'	&& text file
		This.aTypes[13, 1] = 'D'	&& free table
		This.aTypes[14, 1] = 'M'	&& menu
		This.aTypes[15, 1] = 'R'	&& report
		This.aTypes[16, 1] = 'B'	&& label
		This.aTypes[17, 1] = 'Q'	&& query
		This.aTypes[18, 1] = 'd'	&& DBC
		This.aTypes[19, 1] = 't'	&& table in DBC
		This.aTypes[20, 1] = 'Z'	&& application
		This.aTypes[21, 1] = 'L'	&& library
		for lnI = 1 to alen(This.aTypes, 1)
			lcType = This.aTypes[lnI, 1]
			This.aTypes[lnI, 2] = not inlist(lcType, 'Class', 'Connection', ;
				'RemoteView', 'LocalView', 'Field', 'Index', 'SProc')
				&& everything but these is a file
			This.aTypes[lnI, 3] = lcType <> 'L'
				&& can edit anything but an API library
			This.aTypes[lnI, 4] = not lcType $ 'LZ' and This.aTypes[lnI, 2]
				&& can include any file except API library and application
			This.aTypes[lnI, 5] = This.aTypes[lnI, 2] or ;
				inlist(lcType, 'Connection', 'Class', 'RemoteView', 'LocalView', 't')
				&& can remove any file plus these items
			This.aTypes[lnI, 6] = inlist(lcType, 'K', 'P', 'R', 'B', 'D', ;
				't', 'Field', 'Index', 'LocalView', 'RemoteView', 'Q', 'M', ;
				'Z')
				&& can run forms, programs, reports, labels, free tables,
				&& tables in a DBC, fields, indexes, views, queries, menus, and
				&& applications
			This.aTypes[lnI, 7] = lcType $ 'PK'
				&& can set programs and forms as main
		next lnI
	endfunc

*******************************************************************************
* Clean up on exit.
*******************************************************************************
	function TearDown
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
* Test that CanEdit is set the way it's supposed to be
*******************************************************************************
	function Test_CanEdit_Correct
		for lnI = 1 to alen(This.aTypes, 1)
			This.oItem.Type   = This.aTypes[lnI, 1]
			This.oItem.IsFile = This.aTypes[lnI, 2]
			This.AssertEquals(This.aTypes[lnI, 3], This.oItem.CanEdit, ;
				'CanEdit not correct for ' + This.oItem.Type)
		next lnI
	endfunc

*******************************************************************************
* Test that CanInclude is set the way it's supposed to be
*******************************************************************************
	function Test_CanInclude_Correct
		for lnI = 1 to alen(This.aTypes, 1)
			This.oItem.Type   = This.aTypes[lnI, 1]
			This.oItem.IsFile = This.aTypes[lnI, 2]
			This.AssertEquals(This.aTypes[lnI, 4], This.oItem.CanInclude, ;
				'CanInclude not correct for ' + This.oItem.Type)
		next lnI
	endfunc

*******************************************************************************
* Test that CanRemove is set the way it's supposed to be
*******************************************************************************
	function Test_CanRemove_Correct
		for lnI = 1 to alen(This.aTypes, 1)
			This.oItem.Type   = This.aTypes[lnI, 1]
			This.oItem.IsFile = This.aTypes[lnI, 2]
			This.AssertEquals(This.aTypes[lnI, 5], This.oItem.CanRemove, ;
				'CanRemove not correct for ' + This.oItem.Type)
		next lnI
	endfunc

*******************************************************************************
* Test that CanRun is set the way it's supposed to be
*******************************************************************************
	function Test_CanRun_Correct
		for lnI = 1 to alen(This.aTypes, 1)
			This.oItem.Type   = This.aTypes[lnI, 1]
			This.oItem.IsFile = This.aTypes[lnI, 2]
			This.AssertEquals(This.aTypes[lnI, 6], This.oItem.CanRun, ;
				'CanRun not correct for ' + This.oItem.Type)
		next lnI
	endfunc

*******************************************************************************
* Test that CanSetMain is set the way it's supposed to be
*******************************************************************************
	function Test_CanSetMain_Correct
		for lnI = 1 to alen(This.aTypes, 1)
			This.oItem.Type   = This.aTypes[lnI, 1]
			This.oItem.IsFile = This.aTypes[lnI, 2]
			This.AssertEquals(This.aTypes[lnI, 7], This.oItem.CanSetMain, ;
				'CanSetMain not correct for ' + This.oItem.Type)
		next lnI
	endfunc
enddefine
