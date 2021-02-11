*-***********************************************************************************************
*-*  Written by:  Gregory A. Green & Joel Leach
*-*  Initial Development: 6 May 2009
*-* 
*-*  Change History
*-*  6 May 2009    Added check in UnBindEvent to execute UNBINDEVENTS() if no longer requested
*-*                Renamed method UnBindEvent to UnBindEvents to match VFP name
*-*
*-*	 10 April 2010 Joel Leach made several changes to design and implementation, but overall
*-*                concept is the same.
*-***********************************************************************************************
*-*  Class for managing the BINDEVENT() Command for a common foundation for Win32 Events
*-*
*-*  && Sample for implementation and use
*-*  && Check if class is loaded
*-*  IF !PEMSTATUS(_SCREEN,"oEventHandler",5)
*-*  	_SCREEN.NewObject("oEventHandler","VFPxWin32EventHandler","VFPxWin32EventHandler.prg")
*-*  ENDIF
*-*  
*-*  && To bind to a Win32 Event
*-*  _SCREEN.oEventHandler.BindEvent(0, WM_CREATE, this, "MyEventHandler", lnFlags)
*-*  
*-* && To unbind to a Win32 Event
*-*  lhWnd     = 0
*-*  lnMessage = WM_CREATE	
*-*  _SCREEN.oEventHandler.UnBindEvent(lhWnd, lnMessage, loEventHandler, lcDelegate)
*-*  Pass 0 to lnMessage to unbind all messages from hWnd/Delegate.
*-*
*-***********************************************************************************************
#define GWL_WNDPROC         (-4)

DEFINE CLASS VFPxWin32EventHandler AS Collection 
	bDebug   = .F.
	hdlDebug = -1
	PrevWndFunc = 0

	PROCEDURE BindEvent
		LPARAMETERS thWnd, tnMessage, toEventHandler, tcDelegate, tnFlags
		LOCAL loBind as WinEvent of VFPxWin32EventHandler.prg, lnNum, lnNdx, lbEventNotBinded, lcKey, lnReturn
		LOCAL ARRAY laEvents[1,4]
*-*		Add the requested Event Binding to the collection
		lcKey = Transform(thWnd) + "~" + Transform(tnMessage)
		If this.GetKey(lcKey) = 0
			loBind = NewObject("WinEvent", "VFPxWin32EventHandler.prg")
			loBind.hWnd = thWnd
			loBind.nMessage = tnMessage
			loBind.PrevWndFunc = This.PrevWndFunc 
			this.Add(loBind,lcKey) 
			* Bind Win event to collection
			BindEvent(thWnd, tnMessage, loBind, "EventFired")
		Else 
			loBind = This.Item(lcKey)
		EndIf 
		* Bind collection object to event handler/delegate
		IF PCOUNT() = 4
			lnReturn = BindEvent(loBind, "EventFired", toEventHandler, tcDelegate)
		ELSE
			lnReturn = BindEvent(loBind, "EventFired", toEventHandler, tcDelegate, tnFlags)
		EndIf
		
		This.CleanupEvents()
		
		Return lnReturn 

	ENDPROC

	
	PROCEDURE Init
		IF this.bDebug
			this.hdlDebug = FCREATE("GKKWin32EventHandler.log",0)
		ENDIF
		
		IF !('FoxTabsDeclareAPI' $ SET( 'Procedure' ))
			SET PROCEDURE TO FoxTabsDeclareAPI ADDITIVE
		ENDIF

		* Store handle for use in CallWindowProc
		This.PrevWndFunc = GetWindowLong(_Vfp.hWnd, GWL_WNDPROC)

	ENDPROC


	PROCEDURE Destroy
		IF this.bDebug
			=FCLOSE(this.hdlDebug)
			this.hdlDebug = -1
		ENDIF
	ENDPROC


	* Unbind Win events. Supports all UnBindEvents interfaces
	Procedure UnBindEvents
		LPARAMETERS thWnd, tnMessage, toEventHandler, tcDelegate
		Local lcKey, loWinEvent as WinEvent of VFPxWin32EventHandler.prg, lnItem
		DO CASE
		CASE Pcount() = 1
			* UNBINDEVENTS(oEventObject) 
			* Unbinds all events associated with this object. This includes events that are bound 
			*	to it as an event source and its delegate methods that serve as event handlers.
			UnBindEvents(thWnd)
		CASE Pcount() = 4
			If !Empty(tnMessage)
				* Unbind specific event/message
				lcKey = Transform(thWnd) + "~" + Transform(tnMessage)
				If This.GetKey(lcKey) <> 0
					loWinEvent = This.Item(lcKey)
					UnBindEvents(loWinEvent, "EventFired", toEventHandler, tcDelegate)
				EndIf 
			Else
				* Unbind all messages for hWnd and delegate
				FOR lnItem = 1 to This.Count
					loWinEvent = This.Item(lnItem)
					If loWinEvent.hWnd = thWnd
						UnBindEvents(loWinEvent, "EventFired", toEventHandler, tcDelegate)
					EndIf 
				ENDFOR
			EndIf 
		Otherwise
			Assert .f. Message "UnBindEvents requires 1 or 4 parameters. Syntax: " + Chr(13) + Chr(13) + ;
				"UnBindEvents(oEventObject)" + Chr(13) + "UnBindEvents(thWnd, tnMessage, toEventHandler, tcDelegate)"
		ENDCASE

		This.CleanupEvents()

	EndProc 

	* Check all events and remove any objects that are no longer used
	Procedure CleanupEvents
		Local array laObjEvents[1,5], laWinEvents[1,4]
		Local lnItem, loWinEvent as WinEvent of VFPxWin32EventHandler.prg, lnRow, llEventFound
		
		* Array of current Win event bindings
		AEvents(laWinEvents, 1)

		* For loops don't work well when removing items from collection
		lnItem = 1
		Do While lnItem <= This.Count

			llEventFound = .f.
			loWinEvent = This.Item(lnItem)
			
			* Check if there are any bindings for this Win event
			For lnRow = 1 to Alen(laWinEvents, 1)
				If laWinEvents[lnRow,1] = loWinEvent.hWnd and laWinEvents[lnRow,2] = loWinEvent.nMessage
					llEventFound = .t.
					Exit 
				EndIf 
			EndFor 
			* No Win events for this object, so remove
			If !llEventFound
				This.Remove(lnItem)
				Loop
			EndIf 
			
			* If no bindings to this object, remove
			If AEvents(laObjEvents, This.Item(lnItem)) = 0
				This.Remove(lnItem)
				Loop
			EndIf 
			
			lnItem = lnItem + 1 
			
		EndDo 

	EndProc 
	
EndDefine

DEFINE CLASS WinEvent AS Custom

	hWnd = 0
	nMessage = 0
	PrevWndFunc = 0

	* Bind events to this method
	PROCEDURE EventFired
		LPARAMETERS thWnd, tnMessage, twParam, tnParam
		Local lnReturn
		* Pass message on. Must do here or VFP will crash in some scenarios.
		* See https://vfpx.codeplex.com/workitem/33260
		lnReturn = CallWindowProc(This.PrevWndFunc, thWnd, tnMessage, twParam, tnParam)
		Return lnReturn		
	ENDPROC

ENDDEFINE
