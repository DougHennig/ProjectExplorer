* Registered with Thor: 10/16/17 01:50:37 PM
Lparameters lxParam1

****************************************************************
****************************************************************
* Standard prefix for all tools for Thor, allowing this tool to
*   tell Thor about itself.

If Pcount() = 1						  ;
		And 'O' = Vartype (lxParam1)  ;
		And 'thorinfo' = Lower (lxParam1.Class)

	With lxParam1

		* Required
		.Prompt             = 'Project Explorer' && used when tool appears in a menu
		.Description        = 'Project Explorer'
		.PRGName            = 'Thor_Tool_ProjectExplorer' && a unique name for the tool; note the required prefix

		* Optional 
		.FolderName         = 'D:\DEVELOPMENT\TOOLS\THOR\Thor\Tools\Apps\Project Explorer\' && folder name for APP   
		.CanRunAtStartup    = .F. 

		* For public tools, such as PEM Editor, etc.
		.Category           = 'Applications' 
	Endwith

	Return lxParam1
Endif

If Pcount() = 0
	Do ToolCode
Else
	Do ToolCode With lxParam1
Endif

Return

****************************************************************
****************************************************************
* Normal processing for this tool begins here.                  
Procedure ToolCode
    Lparameters lxParam1
do ('D:\DEVELOPMENT\TOOLS\THOR\Thor\Tools\Apps\Project Explorer\ProjectExplorer.app')
EndProc 
