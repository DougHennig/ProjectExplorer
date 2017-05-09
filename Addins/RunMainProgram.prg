lparameters toParameter1, ;
	tuParameter2, ;
	tuParameter3

* If this is a registration call, tell the addin manager which method we're
* an addin for.

if pcount() = 1
	toParameter1.Method = 'AfterAddMenu'
	toParameter1.Active = .F.
	return
endif

* Add a menu function to the Project Explorer pad to run the main program for the project.

toParameter1.oMenu.ProjectExplorerPad.AddBar('RunMainBar', sys(16), 'RunMain')
toParameter1.oMenu.ProjectExplorerPad.Refresh()
return .T.

define class RunMainBar as ProjectExplorerBar of ;
	Source\ProjectExplorerMenu.vcx
	cCaption        = [Run Main Program]
	cStatusBarText  = [Runs the main program in the project]
	cOnClickCommand = [_screen.ActiveForm.RunItem(_screen.ActiveForm.oProject.oProject.MainFile)]
	cSkipFor        = [empty(_screen.ActiveForm.oProject.oProject.MainFile)]
	cBarPosition    = [before ProjectExplorerExit]
enddefine
