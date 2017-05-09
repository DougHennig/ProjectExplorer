lparameters toParameter1, ;
	tuParameter2, ;
	tuParameter3

* If this is a registration call, tell the addin manager which method we're
* an addin for.

if pcount() = 1
	toParameter1.Method = 'BeforeBuildProject'
	toParameter1.Active = .T.
	toParameter1.Name   = 'Set version number on build'
	toParameter1.Order  = 1
	return
endif

* This is an addin call, so do it.

lnJulian = val(sys(11, date())) - val(sys(11, {^2000-01-01}))
lcJulian = padl(transform(lnJulian), 4, '0')
toParameter1.VersionNumber = left(toParameter1.VersionNumber, ;
	rat('.', toParameter1.VersionNumber)) + lcJulian
return .T.
