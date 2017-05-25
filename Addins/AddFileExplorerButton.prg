lparameters toParameter1, ;
	tuParameter2, ;
	tuParameter3

* If this is a registration call, tell the addin manager which method we're
* an addin for.

if pcount() = 1
	toParameter1.Method = 'OnStartup'
	toParameter1.Active = .F.
	return
endif

* Add a button to the toolbar that opens File Explorer for the selected file.

loToolbar = toParameter1.oProjectToolbar
loToolbar.AddObject('cmdOpenFileExplorer', 'FileExplorerButton')
loButton             = loToolbar.cmdOpenFileExplorer
loButton.Visible     = .T.
loButton.Top         = loToolbar.cmdBack.Top
loButton.Left        = loToolbar.cmdBack.Left + loToolbar.cmdBack.Width + 5
loButton.ToolTipText = 'Open File Explorer'
return .T.

define class FileExplorerButton as ProjectExplorerToolbarButton of ;
	Source\ProjectExplorerButton.vcx

	function Init
		This.Picture = Thisform.cMainFolder + 'Addins\folder.png'
	endfunc
	
	function Click
		ExecuteFile(justpath(Thisform.oItem.Path))
	endfunc

	function Refresh
		This.Enabled = vartype(Thisform.oItem) = 'O' and Thisform.oItem.IsFile
	endfunc
enddefine
