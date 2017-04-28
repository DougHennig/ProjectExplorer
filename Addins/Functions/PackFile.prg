lparameters tcFile
local lnSelect
lnSelect = select()
select 0
try
	use (tcFile) exclusive
	pack
	use
	messagebox(tcFile + ' was packed.')
catch
	messagebox('Cannot open ' + tcFile + ' exclusively.')
endtry
select (lnSelect)
