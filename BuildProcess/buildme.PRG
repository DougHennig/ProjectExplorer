* Update ccVERSION_NUMBER in ProjectExplorer.h.

lcContent = filetostr('Source\ProjectExplorer.h')
lcVersion = strextract(lcContent, '#define ccVERSION_NUMBER', chr(13), 1, 4)
lcVersion = strextract(lcVersion, "'", "'")
lcContent = strtran(lcContent, lcVersion, pcVersion + '.' + padl(date() - date(2000, 1, 1), 5, '0'))
strtofile(lcContent, 'Source\ProjectExplorer.h')
