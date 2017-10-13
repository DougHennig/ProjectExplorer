lnJulian = val(sys(11, date())) - val(sys(11, {^2000-01-01}))
lcJulian = padl(transform(lnJulian), 4, '0')
_cliptext = '1.0.' + lcJulian
