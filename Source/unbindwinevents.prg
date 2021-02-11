* Unbind Win event bound with BindWinEvent()
* Allows multiple bindings for single Win Msg 
LPARAMETERS thWnd, tnMessage, toEventHandler, tcDelegate

IF !PEMSTATUS(_SCREEN,"oEventHandler",5) or IsNull(_Screen.oEventHandler)
	Return 
EndIf

DO CASE
CASE Pcount() = 1
	_Screen.oEventHandler.UnBindEvents(thWnd)
CASE Pcount() = 3
	_Screen.oEventHandler.UnBindEvents(thWnd, tnMessage)
Otherwise
	_Screen.oEventHandler.UnBindEvents(thWnd, tnMessage, toEventHandler, tcDelegate)
EndCase
