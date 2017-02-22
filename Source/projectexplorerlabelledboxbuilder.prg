lparameters tu1, ;
	tu2, ;
	tu3
local laObjects[1], ;
	loObject, ;
	lcCaption
aselobj(laObjects)
loObject = laObjects[1]
with loObject
	.shpBox.Width  = .Width
	.shpBox.Height = .Height - .shpBox.Top
	lcCaption = inputbox('Caption:', 'Labeled Box Builder', .lblLabel.Caption)
	if not empty(lcCaption)
		.lblLabel.Caption = lcCaption
	endif not empty(lcCaption)
endwith
