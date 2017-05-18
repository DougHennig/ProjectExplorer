lparameters tuParam

* Standard prefix for all tools for Thor, allowing this tool to tell Thor about
* itself.

if pcount() = 1 and vartype(tuParam) = 'O' and ;
	lower(tuParam.Class) == 'thorinfo'
	with tuParam

* Required

		.Prompt		   = 'Project Explorer' && used in menus
		
* Optional

		text to .Description noshow			&& a description for the tool
Project Explorer is a replacement for the VFP Project Manager.
		endtext 
		.StatusBarText = ''  
		.CanRunAtStartUp = .F.

* These are used to group and sort tools when they are displayed in menus or
* the Thor form.

		.Category      = 'Applications' 	&& creates categorization of tools
		.Sort		   = 0					&& the sort order for all items in
											&& the same category
		
* For public tools, such as PEM Editor, etc.

		.Version	   = ''					&& e.g., 'Version 7, May 18, 2011'
		.Author        = 'Doug Hennig'
		.Link          = ''					&& link to a page for this tool
		.VideoLink     = ''					&& link to a video for this tool
		.Plugins       = 'Get Project Explorer Location'
		.PlugInClasses = 'GetProjectExplorerFolderPlugIn'
	endwith
	return tuParam
endif pcount() = 1 ...

if pcount() = 0
	do ToolCode
else
	do ToolCode With tuParam
endif
return

*******************************************************************************
* Normal processing for this tool begins here.                  

procedure ToolCode
	lparameters tuParam
	lcFolder = execscript(_screen.cThorDispatcher, ;
		'Thor_Proc_GetProjectExplorerFolder')
	do (lcFolder + 'ProjectExplorer.app') with tuParam
endproc 

*******************************************************************************
* This class defines the plug-in for returning the Project Explorer folder,
* making it easy to point this tool at whatever folder you installed Project
* Explorer into.
*******************************************************************************

define class GetProjectExplorerFolderPlugIn as Custom
	Source				= 'Project Explorer'
	PlugIn				= 'Get Project Explorer Location'
	Description			= 'Returns the full path to the folder where ' + ;
		'Project Explorer is installed'
	Tools				= 'Project Explorer'
	FileNames			= 'Thor_Proc_GetProjectExplorerFolder.PRG'
	DefaultFileName		= '*Thor_Proc_GetProjectExplorerFolder.PRG'
	DefaultFileContents	= ''
enddefine
