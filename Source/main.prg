*==============================================================================
* Program:			MAIN.PRG
* Purpose:			Startup program for Project Explorer
* Author:			Doug Hennig
* Last Revision:	02/18/2017
* Parameters:		tuStartupParameter - a parameter to pass to the Project
*						Explorer (optional)
* Returns:			none
* Environment in:	if we're being run from this PRG, the current folder is
*						the root of the source code
* Environment out:	none
*==============================================================================

lparameters tuStartupParameter
local lcCurrTalk, ;
	lcCurrPath, ;
	loProjectExplorer

* Save the current TALK setting and turn it off.

if set('TALK') = 'ON'
	set talk off
	lcCurrTalk = 'ON'
else
	lcCurrTalk = 'OFF'
endif set('TALK') = 'ON'

* Run the ProjectExplorer form. Note that we attach it to _screen so it can
* live once this program is done.

if lower(justext(sys(16, 1))) <> 'app'
	lcCurrPath = set('PATH')
	set path to &lcCurrPath., Source, Source\Images
endif lower(justext(sys(16, 1))) <> 'app'
loProjectExplorer = newobject('ProjectExplorerForm', 'ProjectExplorerUI.vcx', ;
	'', tuStartupParameter)
if vartype(loProjectExplorer) = 'O'
	addproperty(_screen, '_oProjectExplorer', loProjectExplorer)
	loProjectExplorer.Show()
endif vartype(loProjectExplorer) = 'O'

* Restore the settings we changed.

if lcCurrTalk = 'ON'
	set talk on
endif lcCurrTalk = 'ON'
if not empty(lcCurrPath)
	set path to &lcCurrPath
endif not empty(lcCurrPath)
