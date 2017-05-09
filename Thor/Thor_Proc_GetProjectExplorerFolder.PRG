* The simplest way to customize this plug-in is to specify the full path to
* your installation of Project Explorer in this constant, something like the
* following (the final backslash is optional, since it will be added later if
* you don't include it):

*!*	#define PROJECT_EXPLORER_CUSTOM_INSTALL_FOLDER	'C:\SomeFolder\SomeOtherFolder\ProjectExplorer\'
#define PROJECT_EXPLORER_CUSTOM_INSTALL_FOLDER		''

* The subfolder of Thor's tools folder where we expect to find Project Explorer
* installed.

#define PROJECT_EXPLORER_THOR_TOOLS_SUBFOLDER		'Apps\ProjectExplorer\'

* The name of the main APP file we expect to find in the Project Explorer folder.

#define PROJECT_EXPLORER_MAIN_APP_FILENAME			'ProjectExplorer.APP'

lparameters tlDoNotPrompt
local lcProjectExplorerFolder

* If PROJECT_EXPLORER_CUSTOM_INSTALL_FOLDER contains a valid install folder for
* Project Explorer, use it. If not, look for Project Explorer under the Thor
* Tools folder.

if not empty(PROJECT_EXPLORER_CUSTOM_INSTALL_FOLDER) and ;
	file(addbs(PROJECT_EXPLORER_CUSTOM_INSTALL_FOLDER) + ;
	PROJECT_EXPLORER_MAIN_APP_FILENAME)
	lcProjectExplorerFolder = addbs(PROJECT_EXPLORER_CUSTOM_INSTALL_FOLDER)
else
	lcProjectExplorerFolder = execscript(_screen.cThorDispatcher, ;
		'Tool Folder=')
	lcProjectExplorerFolder = addbs(lcProjectExplorerFolder) + ;
		PROJECT_EXPLORER_THOR_TOOLS_SUBFOLDER
endif not empty(PROJECT_EXPLORER_CUSTOM_INSTALL_FOLDER) ...
do case

* Project Explorer was installed by Thor where we expect it.

	case file(lcProjectExplorerFolder + PROJECT_EXPLORER_MAIN_APP_FILENAME)

* Project Explorer is in the same folder as this program.

	case file(addbs(justpath(sys(16))) + PROJECT_EXPLORER_MAIN_APP_FILENAME)
		lcProjectExplorerFolder = addbs(justpath(sys(16)))

* Project Explorer was found in the current VFP path.

	case file( PROJECT_EXPLORER_MAIN_APP_FILENAME)
		lcProjectExplorerFolder = addbs(justpath(fullpath(PROJECT_EXPLORER_MAIN_APP_FILENAME)))

* Project Explorer wasn't found and we're not supposed to prompt.

	case tlDoNotPrompt 
		lcProjectExplorerFolder = ''

* We don't know where Project Explorer is located, so ask.

	otherwise
		lcProjectExplorerFolder = ''
		do while not file(lcProjectExplorerFolder + ;
			PROJECT_EXPLORER_MAIN_APP_FILENAME)
			lcProjectExplorerFolder = getdir(_VFP.DefaultFilePath, ;
				'Select the folder where Project Explorer is installed', ;
				'Find Project Explorer Folder', 1 + 64)
			if empty(lcProjectExplorerFolder)
				exit
			else
				lcProjectExplorerFolder = addbs(lcProjectExplorerFolder)
			endif empty(lcProjectExplorerFolder)
		enddo while not file(lcProjectExplorerFolder ...
endcase

* Return the result.

return execscript(_Screen.cThorDispatcher, 'Result=', lcProjectExplorerFolder)
