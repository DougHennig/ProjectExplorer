lparameters toParameter1, ;
	tuParameter2, ;
	tuParameter3

* If this is a registration call, tell the addin manager which method we're
* an addin for.

if pcount() = 1
	toParameter1.Method = 'AfterCreateShortcutMenu'
	toParameter1.Active = .F.
	toParameter1.Name   = 'Add Pack to Shortcut Menu'
	return
endif

* This is an addin call, so add "Pack File" as the third item in the shortcut
* menu.

tuParameter2.AddMenuBar('Pack File', ;
	"do (loForm.cMainFolder + 'Addins\Functions\PackFile') with loForm.oItem.Path", ;
	"vartype(loForm.oItem) <> 'O' or not loForm.oItem.IsBinary", ;
	, ;
	3)
return .T.
