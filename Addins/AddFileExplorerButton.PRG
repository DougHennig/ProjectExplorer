lparameters toParameter1, ;
	tuParameter2

* If this is a registration call, tell the addin manager which method we're
* an addin for.

if pcount() = 1
	toParameter1.Method = 'Activate'
	toParameter1.Active = .F.
	return
endif

* Add a button to the toolbar that opens File Explorer for the selected file.

loToolbar = toParameter1.oProjectToolbar
if type('loToolbar.cmdOpenFileExplorer') <> 'O'
	loToolbar.AddObject('cmdOpenFileExplorer', 'FileExplorerButton')
	loButton             = loToolbar.cmdOpenFileExplorer
	loButton.Visible     = .T.
	loButton.Top         = loToolbar.cmdBack.Top
	loButton.Left        = loToolbar.cmdBack.Left + loToolbar.cmdBack.Width + 5
	loButton.ToolTipText = 'Open File Explorer'
endif type('loToolbar.cmdOpenFileExplorer') <> 'O'
return .T.

define class FileExplorerButton as ProjectExplorerToolbarButton of ;
	Source\ProjectExplorerButton.vcx
	Picture = 'Addins\folder.png'

	function Click
		declare integer ShellExecute in SHELL32.DLL ;
			integer nWinHandle, ;	&& handle of parent window
			string cOperation, ;	&& operation to perform
			string cFileName, ;		&& filename
			string cParameters, ;	&& parameters for the executable
			string cDirectory, ;	&& default directory
			integer nShowWindow		&& window state
		ShellExecute(0, '', justpath(Thisform.oItem.Path), '', '', 0)
	endfunc

	function Refresh
		This.Enabled = vartype(Thisform.oItem) = 'O' and Thisform.oItem.IsFile
	endfunc
enddefine
