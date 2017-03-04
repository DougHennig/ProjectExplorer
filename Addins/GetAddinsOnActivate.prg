* This addin gets addins when the Project Explorer is activated.

lparameters toParameter1, ;
	tuParameter2

* If this is a registration call, tell the addin manager which method we're
* an addin for.

if pcount() = 1
	toParameter1.Method = 'Activate'
	toParameter1.Active = .F.
	return
endif

* Refresh registered addins.

toParameter1.oAddins.GetAddins()
