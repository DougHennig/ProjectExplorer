lparameters toParameter1, ;
	tuParameter2, ;
	tuParameter3
local llReturn, ;
	lcEditor

* If this is a registration call, tell the addin manager which method we're
* an addin for.

if pcount() = 1
	toParameter1.Method = 'BeforeModifyItem'
	toParameter1.Active = .F.
	return
endif

* This is an addin call, so if a view is being modified and if so, whether
* ViewEditor Professional is installed. If so, use it to edit the view. Note
* that we call it modelessly and set the DesignerCaption property of the item
* so Project Explorer is notified when the window is closed. Also note we
* return .F. to indicate we don't want the normal behavior.

llReturn = .T.
if inlist(toParameter1.Type, 'r', 'l')
	lcEditor = _screen.oProjectExplorers.Item(1).oRegistry.GetKey('Software\' + ;
		'WhiteLightComputingTools\ViewEditor\3.0\Options', 'cVePath')
	if not empty(lcEditor) and file(lcEditor)
		do (lcEditor) with toParameter1.ItemName, toParameter1.ParentPath
		toParameter1.DesignerCaption = 'ViewEditor Professional'
		llReturn = .F.
	endif not empty(lcEditor) ...
endif inlist(toParameter1.Type, 'r', 'l')
return llReturn
