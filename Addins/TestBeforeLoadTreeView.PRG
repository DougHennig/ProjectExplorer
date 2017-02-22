* This addin sorts the TreeView in descending order by last modified date.

lparameters toObject1, ;
	toObject2

* If this is a registration call, tell the addin manager which method we're
* an addin for.

if pcount() = 1
	toObject1.Method = 'BeforeLoadTreeView'
	toObject1.Active = .F.
	return
endif

* This is an addin call, so do it.

index on iif(TYPE = 'H', 'Z', 'A' + ttoc(LASTMOD, 1)) descending tag LASTMOD
replace all SORTED with .F.

