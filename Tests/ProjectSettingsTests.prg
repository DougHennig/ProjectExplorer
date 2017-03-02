*******************************************************************************
define class ProjectSettingsTests as FxuTestCase of FxuTestCase.prg
*******************************************************************************
	#IF .f.
	LOCAL THIS AS ProjectSettingsTests OF ProjectSettingsTests.PRG
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
		
		This.cProject = This.CreateProject()
		modify project (This.cProject) noshow nowait
		This.oProject = _vfp.ActiveProject
		with This.oProject
			.AutoIncrement      = .T.
			.VersionComments    = 'H'
			.VersionCompany     = 'I'
			.VersionCopyright   = 'J'
			.VersionDescription = 'K'
			.VersionLanguage    = 'L'
			.VersionProduct     = 'M'
			.VersionTrademarks  = 'N'
			.VersionNumber      = '1.2.3'
			loFile = .Files.Add('source\executefile.prg')
			.SetMain('source\executefile.prg')
			.Build()
		endwith
	endfunc

*******************************************************************************
* Clean up on exit.
*******************************************************************************
	function TearDown
		This.oProject.Close()
		erase (This.cProject)
		erase (forceext(This.cProject, 'pjt'))
	endfunc

*******************************************************************************
* Helper method to create a project
*******************************************************************************

	function CreateProject
		text to lcXML noshow
<?xml version = "1.0" encoding="Windows-1252" standalone="yes"?>
<VFPData>
	<test>
		<name>D:\PROJECT EXPLORER\TESTS\TESTDATA\TEST.PJX</name>
		<type>H</type>
		<id>0</id>
		<timestamp>0</timestamp>
		<outfile></outfile>
		<homedir>d:\project explorer\tests\testdata</homedir>
		<exclude>false</exclude>
		<mainprog>false</mainprog>
		<savecode>true</savecode>
		<debug>true</debug>
		<encrypt>true</encrypt>
		<nologo>false</nologo>
		<cmntstyle>1</cmntstyle>
		<objrev>260</objrev>
		<devinfo/>
		<symbols/>
		<object>d:\project explorer\tests\testdata</object>
		<ckval>0</ckval>
		<cpid>0</cpid>
		<ostype/>
		<oscreator/>
		<comments/>
		<reserved1>D:\PROJECT EXPLORER\TESTS\TESTDATA\TEST.PJX</reserved1>
		<reserved2/>
		<sccdata/>
		<local>false</local>
		<key>TEST</key>
		<user>testuser</user>
	</test>
	<test>
		<name>..\..\source\images\labels.ico</name>
		<type>i</type>
		<id>0</id>
		<timestamp>0</timestamp>
		<outfile/>
		<homedir/>
		<exclude>false</exclude>
		<mainprog>false</mainprog>
		<savecode>false</savecode>
		<debug>false</debug>
		<encrypt>false</encrypt>
		<nologo>false</nologo>
		<cmntstyle>0</cmntstyle>
		<objrev>0</objrev>
		<devinfo/>
		<symbols/>
		<object/>
		<ckval>0</ckval>
		<cpid>0</cpid>
		<ostype/>
		<oscreator/>
		<comments/>
		<reserved1/>
		<reserved2/>
		<sccdata/>
		<local>false</local>
		<key>LABELS</key>
		<user/>
	</test>
</VFPData>
		endtext
		lcCursor = sys(2015)
		select * from ProjectExplorer.pjx again into cursor (lcCursor) ;
			nofilter readwrite
		delete all
		xmltocursor(lcXML, lcCursor, 8192)
		go top
		replace DEVINFO with padr('A', 46, chr(0)) + ;
			padr('B', 46, chr(0)) + ;
			padr('C', 46, chr(0)) + ;
			padr('D', 21, chr(0)) + ;
			padr('E', 6, chr(0)) + ;
			padr('F', 11, chr(0)) + ;
			padr('G', 46, chr(0))
		lcProject = (This.cTestDataFolder + sys(2015) + '.pjx')
		copy to (lcProject)
		use
		use in ProjectExplorer
		return lcProject
	endfunc

*******************************************************************************
* Test that Init gets the settings
*******************************************************************************
	function Test_Init_GetsSettings
		loSettings = newobject('ProjectSettings', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oProject)
		This.AssertEquals(addbs(lower(This.cTestDataFolder)), ;
			addbs(lower(loSettings.Home)), 'Did not read settings')
	endfunc

*******************************************************************************
* Test that GetSettings gets the settings (for performance reasons, these are
* combined into one test)
*******************************************************************************
	function Test_GetSettings_GetsSettings
		loSettings = newobject('ProjectSettings', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oProject)
		This.AssertEquals('A', loSettings.Author, 'Incorrect Author')
		This.AssertEquals('B', loSettings.Company, 'Incorrect Company')
		This.AssertEquals('C', loSettings.Address, 'Incorrect Address')
		This.AssertEquals('D', loSettings.City, 'Incorrect City')
		This.AssertEquals('E', loSettings.Region, 'Incorrect Region')
		This.AssertEquals('F', loSettings.PostalCode, 'Incorrect PostalCode')
		This.AssertEquals('G', loSettings.Country, 'Incorrect Country')
		This.AssertEquals('testuser', loSettings.User, 'Incorrect User')
		This.AssertTrue(loSettings.Debug, 'Incorrect Debug')
		This.AssertTrue(loSettings.Encrypted, 'Incorrect Encrypted')
		This.AssertEquals(addbs(lower(This.cTestDataFolder)), ;
			addbs(lower(loSettings.Home)), 'Incorrect home')
		This.AssertEquals(date(), ttod(loSettings.LastBuilt), ;
			'Incorrect LastBuilt')
		This.AssertEquals(lower(fullpath('source\images\labels.ico')), ;
			loSettings.Icon, 'Incorrect Icon')
		This.AssertEquals(lower(fullpath('source\executefile.prg')), ;
			loSettings.MainFile, 'Incorrect MainFile')
		This.AssertEquals('', loSettings.ProjectHookClass, ;
			'Incorrect ProjectHookClass')
		This.AssertEquals('', loSettings.ProjectHookLibrary, ;
			'Incorrect ProjectHookLibrary')
		This.AssertTrue(loSettings.AutoIncrement, 'Incorrect AutoIncrement')
		This.AssertEquals('H', loSettings.VersionComments, ;
			'Incorrect VersionComments')
		This.AssertEquals('I', loSettings.VersionCompany, ;
			'Incorrect VersionCompany')
		This.AssertEquals('J', loSettings.VersionCopyright, ;
			'Incorrect VersionCopyright')
		This.AssertEquals('K', loSettings.VersionDescription, ;
			'Incorrect VersionDescription')
		This.AssertEquals('L', loSettings.VersionLanguage, ;
			'Incorrect VersionLanguage')
		This.AssertEquals('M', loSettings.VersionProduct, ;
			'Incorrect VersionProduct')
		This.AssertEquals('N', loSettings.VersionTrademarks, ;
			'Incorrect VersionTrademarks')
		This.AssertEquals('1', loSettings.MajorVersionNumber, ;
			'Incorrect MajorVersionNumber')
		This.AssertEquals('2', loSettings.MinorVersionNumber, ;
			'Incorrect MinorVersionNumber')
		This.AssertEquals('3', loSettings.BuildNumber, ;
			'Incorrect BuildNumber')
	endfunc

*******************************************************************************
* Test that SaveSettings saves the settings (for performance reasons, these are
* combined into one test)
*******************************************************************************
	function Test_SaveSettings_SavesSettings
		loSettings = newobject('ProjectSettings', ;
			'Source\ProjectExplorerEngine.vcx', '', This.oProject)

* Set the settings to different values.

		loSettings.Author             = '1'
		loSettings.Company            = '2'
		loSettings.Address            = '3'
		loSettings.City               = '4'
		loSettings.Region             = '5'
		loSettings.PostalCode         = '6'
		loSettings.Country            = '7'
		loSettings.User               = '8'
		loSettings.Debug              = .F.
		loSettings.Encrypted          = .F.
		loSettings.Home               = sys(5) + curdir()
		loSettings.Icon               = 'source\images\form.ico'
		loSettings.AutoIncrement      = .F.
		loSettings.VersionComments    = '9'
		loSettings.VersionCompany     = '10'
		loSettings.VersionCopyright   = '11'
		loSettings.VersionDescription = '12'
		loSettings.VersionLanguage    = '13'
		loSettings.VersionProduct     = '14'
		loSettings.VersionTrademarks  = '15'
		loSettings.MajorVersionNumber = '2'
		loSettings.MinorVersionNumber = '3'
		loSettings.BuildNumber        = '4'
		loSettings.ProjectHookClass   = 'ProjectExplorerProjectHook'
		loSettings.ProjectHookLibrary = 'ProjectExplorerProjectHook.vcx'

* Save the settings.

		loSettings.SaveSettings()

* Test them.

		lnSelect  = select()
		select 0
		try
			use (This.oProject.Name) again shared
			lcAuthor     = strtran(substr(DEVINFO,   1, 46), chr(0))
			lcCompany    = strtran(substr(DEVINFO,  47, 46), chr(0))
			lcAddress    = strtran(substr(DEVINFO,  93, 46), chr(0))
			lcCity       = strtran(substr(DEVINFO, 139, 21), chr(0))
			lcRegion     = strtran(substr(DEVINFO, 160,  6), chr(0))
			lcPostalCode = strtran(substr(DEVINFO, 166, 11), chr(0))
			lcCountry    = strtran(substr(DEVINFO, 177, 46), chr(0))
			lcUser       = USER
			use
		catch
		endtry
		select (lnSelect)
		This.AssertEquals(loSettings.Author, lcAuthor, 'Incorrect Author')
		This.AssertEquals(loSettings.Company, lcCompany, 'Incorrect Company')
		This.AssertEquals(loSettings.Address, lcAddress, 'Incorrect Address')
		This.AssertEquals(loSettings.City, lcCity, 'Incorrect City')
		This.AssertEquals(loSettings.Region, lcRegion, 'Incorrect Region')
		This.AssertEquals(loSettings.PostalCode, lcPostalCode, ;
			'Incorrect PostalCode')
		This.AssertEquals(loSettings.Country, lcCountry, 'Incorrect Country')
		This.AssertEquals(loSettings.User, lcUser, 'Incorrect User')
		This.AssertFalse(This.oProject.Debug, 'Incorrect Debug')
		This.AssertFalse(This.oProject.Encrypted, 'Incorrect Encrypted')
		This.AssertEquals(addbs(upper(loSettings.Home)), ;
			addbs(upper(This.oProject.HomeDir)), 'Incorrect home')
		This.AssertEquals(lower(fullpath(loSettings.Icon)), ;
			lower(fullpath(This.oProject.Icon)), 'Incorrect Icon')
		This.AssertEquals(loSettings.ProjectHookClass, ;
			This.oProject.ProjectHookClass, 'Incorrect ProjectHookClass')
		This.AssertEquals(lower(fullpath(loSettings.ProjectHookLibrary)), ;
			lower(fullpath(This.oProject.ProjectHookLibrary)), ;
			'Incorrect ProjectHookLibrary')
		This.AssertFalse(This.oProject.AutoIncrement, ;
			'Incorrect AutoIncrement')
		This.AssertEquals(loSettings.VersionComments, ;
			This.oProject.VersionComments, 'Incorrect VersionComments')
		This.AssertEquals(loSettings.VersionCompany, ;
			This.oProject.VersionCompany, 'Incorrect VersionCompany')
		This.AssertEquals(loSettings.VersionCopyright, ;
			This.oProject.VersionCopyright, 'Incorrect VersionCopyright')
		This.AssertEquals(loSettings.VersionDescription, ;
			This.oProject.VersionDescription, 'Incorrect VersionDescription')
		This.AssertEquals(loSettings.VersionLanguage, ;
			This.oProject.VersionLanguage, 'Incorrect VersionLanguage')
		This.AssertEquals(loSettings.VersionProduct, ;
			This.oProject.VersionProduct, 'Incorrect VersionProduct')
		This.AssertEquals(loSettings.VersionTrademarks, ;
			This.oProject.VersionTrademarks, 'Incorrect VersionTrademarks')
		This.AssertEquals(loSettings.MajorVersionNumber + '.' + ;
			loSettings.MinorVersionNumber + '.' + loSettings.BuildNumber, ;
			This.oProject.VersionNumber, 'Incorrect VersionNumber')
	endfunc
enddefine
