* Bind Win event
* Allows multiple bindings for single Win Msg 
LPARAMETERS thWnd, tnMessage, toEventHandler, tcDelegate, tnFlags
Local lnReturn

IF !('BINDWINEVENTAPI' $ Upper(SET( 'Procedure' )))
	SET PROCEDURE TO BindWinEventAPI ADDITIVE
ENDIF

IF !PEMSTATUS(_SCREEN,"oEventHandler",5) or IsNull(_Screen.oEventHandler)
	_SCREEN.NewObject("oEventHandler","VFPxWin32EventHandler","VFPxWin32EventHandler.prg")
EndIf

DO CASE
CASE Pcount() = 4
	lnReturn = _Screen.oEventHandler.BindEvent(thWnd, tnMessage, toEventHandler, tcDelegate)
CASE Pcount() = 5
	lnReturn = _Screen.oEventHandler.BindEvent(thWnd, tnMessage, toEventHandler, tcDelegate, tnFlags)
Otherwise
	lnReturn = 0
	Assert .F. Message "BindWinEvent requires 4 or 5 parameters. Syntax: " + Chr(13) + Chr(13) + ;
		"BindWinEvent(thWnd, tnMessage, toEventHandler, tcDelegate, tnFlags)"
ENDCASE

Return lnReturn