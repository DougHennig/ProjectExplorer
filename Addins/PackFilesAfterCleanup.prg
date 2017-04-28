lparameters toParameter1, ;
	tuParameter2, ;
	tuParameter3

* If this is a registration call, tell the addin manager which method we're
* an addin for.

if pcount() = 1
	toParameter1.Method = 'AfterCleanupSolution'
	toParameter1.Active = .T.
	return
endif

* This is an addin call, so do it.

lnSelect = select()
select 0
for each loProject in toParameter1.oProjects foxobject
	for each loItem in loProject.oProjectItems foxobject
		if loItem.IsBinary
			try
				use (loItem.Path) exclusive
				pack
				use
			catch
			endtry
		endif loItem.IsBinary
	next loItem
next loProject
messagebox('Files packed')
select (lnSelect)
return .T.
