lparameters toParameter1, ;
	tuParameter2, ;
	tuParameter3

* If this is a registration call, tell the addin manager which method we're
* an addin for.

if pcount() = 1
	toParameter1.Method = 'AfterCreateMenu'
	toParameter1.Active = .T.
	return
endif

* Add an item to the Project Explorer menu to run the main program for the project.

tuParameter2.AddMenuBar('R\<un Main Program', ;
	'loForm.RunItem(loForm.oProject.oProject.MainFile)', ;
	'empty(loForm.oProject.oProject.MainFile)', ;
	'', ;
	tuParameter2.nBarCount - 1)
return .T.
