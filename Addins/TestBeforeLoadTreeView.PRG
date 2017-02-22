* This addin sorts the TreeView in descending order by last modified date.

lparameters toParameter1, ;
	tuParameter2

* If this is a registration call, tell the addin manager which method we're
* an addin for.

if pcount() = 1
	toParameter1.Method = 'BeforeLoadTreeView'
	toParameter1.Active = .F.
	return
endif

* Sort the TreeView cursor in descending order by last modified date.

*index on LASTMOD descending tag LASTMOD

* Sort the TreeView cursor by color.

index on FORECOLOR descending tag FORECOLOR

replace all SORTED with .F.
