lparameters toObject1, ;
	toObject2

* If this is a registration call, tell the addin manager which method we're
* an addin for.

if pcount() = 1
	toObject1.Method = 'BeforeRunItem'
	return
endif

* This is an addin call, so do it.

messagebox('before run addin')

*** RETURN .F. IF METHOD SHOULD NOT CONTINUE
return .T.
