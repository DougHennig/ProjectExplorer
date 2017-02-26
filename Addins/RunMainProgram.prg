lparameters toParameter1, ;
	tuParameter2

* If this is a registration call, tell the addin manager which method we're
* an addin for.

if pcount() = 1
	toParameter1.Method = 'AfterAddMenu'
	toParameter1.Active = .F.
	return
endif

* Add a menu function to the File pad to run the main program for the project.

toParameter1.oMenu.FilePad.AddBar('FileRunMainBar', sys(16), 'FileRunMain')
toParameter1.oMenu.FilePad.Refresh()
return .T.

define class FileRunMainBar as ProjectExplorerBar of ;
	Source\ProjectExplorerMenu.vcx
	cCaption        = [Run Main Program]
	cStatusBarText  = [Runs the main program in the project]
	cOnClickCommand = [do (_screen.ActiveForm.oProject.oProject.MainFile)]
	cSkipFor        = [empty(_screen.ActiveForm.oProject.oProject.MainFile)]
	cBarPosition    = [before FileExit]
enddefine
