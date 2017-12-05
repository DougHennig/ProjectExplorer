* This addin sets the font when the Project Explorer is started.

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

* Set the font to the desired size.

toParameter1.SetAll('FontSize', 12)
