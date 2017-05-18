lparameters toParameter1, ;
	tuParameter2, ;
	tuParameter3
	
* If this is a registration call, tell the addin manager which method we're
* an addin for.

if pcount() = 1
	toParameter1.Method = 'BeforeSaveProjectItem'
	toParameter1.Active = .F.
	return
endif

* Display a message.

messagebox('addin')

*** RETURN .F. IF METHOD SHOULD NOT CONTINUE
return .T.
