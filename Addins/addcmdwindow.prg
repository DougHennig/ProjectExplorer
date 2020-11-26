* Adds a "command" window to Project Explorer
* Created by Scott Rindlisbacher.

lparameters toParameter1, ;
	tuParameter2, ;
	tuParameter3

* If this is a registration call, tell the addin manager which method we're
* an addin for.

if pcount() = 1
	toParameter1.Method = 'OnStartup'
	toParameter1.Active = .F.
	toParameter1.Order  = 1 && run first (so our order is correct of items added to the ui)
	return
endif


loToolbar = toParameter1.oProjectToolbar
TRY 
	*loToolbar.AddObject('txtNameFilter', 'txtSortBox')
	loToolbar.AddObject('cntCmdWin', 'cntCmd')
	loButton             = loToolbar.cntCmdWin
	loButton.Height      = loToolbar.cmdBack.Height
	loButton.Width       = 200
	loButton.Visible     = .T.
	
	toParameter1.SetToolbarControlLocation(loButton)
	llOK = .T.
CATCH 
	loToolbar.RemoveObject('cntCmdWin')
	llOK = .F.
ENDTRY


* Add a shortcut to get to the 'command window'
*ON KEY LABEL CTRL+F3 DO setFocusCmdWin in SYS(16) && this .prg, path may not always exist so this sets the full path and the name of this prg
LOCAL m.keyShortCut
m.keyShortCut = 'ON KEY LABEL CTRL+F3 DO setFocusCmdWin in ' + SYS(16)
&keyShortCut

return llOK


*************************************************************************
DEFINE CLASS cntCmd as Container
	PROCEDURE init 
		this.Enabled = .T.

		this.AddObject('txtSort', 'txtSortBox')
		this.AddObject('lblClose', 'lblClose')
		
		this.txtSort.visible = .T.
		this.txtSort.width = this.Width 
		this.txtSort.height = this.Height
		this.txtSort.left = this.Left 
		this.txtSort.top = this.Top 
		this.txtSort.anchor = 10
		this.txtSort.zOrder(1) && send to back
		
		this.lblClose.visible = .T.
		this.lblClose.height = this.Height
		this.lblClose.fontSize = 12
		this.lblClose.caption = 'X'
		this.lblClose.left = this.Left + this.Width - 15
		this.lblClose.top = this.Top + 2
		this.lblClose.anchor = 8 && right
		this.lblClose.backStyle = 0 && transparent
		this.lblClose.ZOrder(0) && bring to front
		
	ENDPROC && init
ENDDEFINE && cntSort


*************************************************************************
DEFINE CLASS txtSortBox as TextBox 
	hintForeColor = ''
	hintShowing = .F.
	hint = 'Command (Ctrl+F3)'
	
	origForeColor = ''

	
	*********************************
	PROCEDURE init 
		IF EMPTY(this.hintForeColor)
			this.hintForeColor = RGB(128, 128, 128) && gray
		ENDIF 

		IF EMPTY(this.origForeColor)
			this.origForeColor = this.foreColor
		ENDIF 

		IF !EMPTY(this.Hint)
			this.showHint()
		ENDIF
	ENDPROC && init


	*********************************
	PROCEDURE keyPress
		LPARAMETERS nKeyCode, nShiftAltCtrl
		IF (nKeyCode = 127 OR m.nKeyCode = 1) AND This.SelStart = 0 AND This.SelLength = 0
			* Don't leave focus on backspace
			NODEFAULT
		ENDIF
	
		IF this.HintShowing 	
			this.removeHint()
		ENDIF
		
		IF nKeyCode = 13
			* Pressed Enter, figure out what the command is
			* Expecting something like 'modi comm hold', 'modi form hold', 'modi report hold' or 'do hold', 'do form hold'
			* All other command should go to the command window (Move them over automatically to be nice
			LOCAL ARRAY aCmd (1)
			LOCAL m.cmd
						
			m.cmd = ALLTRIM(this.Value)
			ALINES(aCmd, m.cmd, 1, ' ')
			
			DO CASE 
				CASE LEFT(LOWER(aCmd[1]), 4) = 'modi' OR LOWER(aCmd[1]) = 'do'
					* Modify something. Luanch it via Dougs stuff so it goes through his .git stuff for changes
					* Running something. Luanch it via Dougs stuff so it goes through his .git stuff for changes in case we do a debug -> Fix
					
					LOCAL m.commType && 'code', 'form', 'report' && got these from by putting on the debugger and browsing dougs table. SRR 11/10/2020
		
					* D - Free Tables / Data
					* H - Headers
					* K - Forms
					* L - API Libraries
					* M - Menu 
					* P - Prgs
					* R - Reports
					* V - Class Libraries (.vcx)
					* x - Other file
		
					DO CASE 
						CASE LEFT(LOWER(aCmd[2]), 4) = 'comm'
							m.commType = 'p' &&'code'
							
						CASE LEFT(LOWER(aCmd[2]), 4) = 'form'
							m.commType = 'k' &&'form'
						
						CASE LEFT(LOWER(aCmd[2]), 4) = 'repo'
							m.commType = 'r' &&'report'
						
						CASE LEFT(LOWER(aCmd[2]), 4) = 'menu'						
							m.commType = 'm' && 'menu'
						
						CASE LOWER(aCmd[1]) = 'do'
							* Something like 'Do hold'
							m.commType = 'p' &&'code'
							IF ALEN(aCmd) < 3
								DIMENSION aCmd (3)
								aCmd[3] = aCmd[2]
							ENDIF 
						
						OTHERWISE
							MESSAGEBOX('Invalid/Unsupported command specified!')
							this.Value = ''
							this.showHint()
							this.setFocus()
							
							RETURN 
					ENDCASE 

					SELECT (ALIAS())
					*LOCATE FOR LOWER(image) = LOWER(m.commtype) AND LOWER(text) = LOWER(ALLTRIM(aCmd[3]))
					LOCATE FOR LOWER(type) = LOWER(m.commtype) AND LOWER(text) = LOWER(ALLTRIM(aCmd[3]))
					IF !FOUND()
						IF LEFT(LOWER(aCmd[3]), 4) = 'hold' ; && we use hold a lot, just run it
							OR MESSAGEBOX(aCmd[3] + ICASE(m.commType = 'code', '.prg', m.commType = 'form', '.scx', m.commType = 'report', '.frx', + '.unknown') ;
								 + " doesn't exist or isn't part of the project." ;
								+ CHR(13) + 'Would you like to run this command in the command window?', 4, 'Run in command window') = 6
								
							KEYBOARD '{CTRL+F2}'
							KEYBOARD '{CTRL+END}'
							KEYBOARD m.cmd 
							KEYBOARD '{ENTER}'
						ENDIF 
						
						this.Value = ''
						this.showHint()
						this.setFocus()
						RETURN 
					ENDIF 
					
					Thisform.cCurrentNodeID = id
					thisform.oItem = Thisform.GetItemForNode(Thisform.cCurrentNodeID) && only needed for the 'run', the edit looks it up but doesn't hurt either way

					* NOTE: Doug puts the command in the command window but he has to do it so he can listen for the editor closing and detect changes to the file. SRR 11/10/2020	
					IF LOWER(aCmd[1]) = 'do'
						thisform.oProjectToolBar.cmdRun.click()
					ELSE 					
						thisform.oProjectToolBar.cmdEdit.click()
					ENDIF 
					
					
			
				OTHERWISE 				
					WAIT WINDOW 'Executing command in VFP command window...' NOWAIT 
					
					KEYBOARD '{CTRL+F2}'
					KEYBOARD '{CTRL+END}'
					KEYBOARD m.cmd 
					KEYBOARD '{ENTER}'
					
					WAIT CLEAR 

					this.SetFocus()
			ENDCASE 
			
			
			
			this.Value = ''
			this.LostFocus() && will show the hint
			*this.setFocus()
			*KEYBOARD '{CTRL+F3}'
			
			RETURN 
		ENDIF && nKeyCode = 13
	ENDPROC && keyPress
	
	
	*********************************
	PROCEDURE gotFocus
		DODEFAULT()
		
		* Make sure that the cursor is on the far left. Often times they just
		* randomly click in the text box and it goes in the middle and then it formats incorrectly. 
		* Force it to the far left SRR 04.15.2019
		IF this.hintshowing OR EMPTY(this.value) && AND VARTYPE(this.Value) != 'N')
			* NOTE: for whatever reason, can't get the 'selStart' property to work right, but issuing the keyboard command works perfectly.
			* setting this.selStart only works if we issue nodefault! SRR 04.15.2019
			this.SelStart = 0
			NODEFAULT 
		ENDIF 
	ENDPROC && gotFocus
	
	PROCEDURE lostFocus
		DODEFAULT()
		
		IF EMPTY(this.Value) AND !this.hintShowing
			this.showHint()
		ENDIF 
	ENDPROC && lostFocus
	
	
	*********************************
	PROCEDURE removeHint
		* Remove the 'hint' we were displaying

		this.ForeColor = this.origForeColor
		this.Value = ''
		this.HintShowing = .F.
	ENDPROC && removeHint


	*********************************
	PROCEDURE showHint
		* Show the 'hint' in the text box

		IF EMPTY(this.Hint)
			RETURN 
		ENDIF 

		this.ForeColor = this.hintForeColor
		this.Value = this.Hint
		this.HintShowing = .T.
	ENDPROC && showHint


	*********************************
*SRR*		PROCEDURE InteractiveChange
*SRR*			IF EMPTY(ALLTRIM(this.Value))
*SRR*				thisform.cItemFilter = ''
*SRR*			ELSE 
*SRR*				thisform.cItemFilter = "'" + LOWER(ALLTRIM(this.Value)) + "' $ LOWER(item.itemName)"
*SRR*			ENDIF 
*SRR*			
*SRR*			* To sort by last modified date
*SRR*			* thisform.cTreeViewSortExpression = 'LASTMOD'
*SRR*			* thisform.lSortTreeViewDescending = .T.
*SRR*			
*SRR*			thisform.flagTreeViewsForReload()
*SRR*			thisform.loadSolution()
*SRR*		ENDPROC && InteractiveChange
	
ENDDEFINE && txtSortBox



*************************************************************************
DEFINE CLASS lblClose as Label
	
	*********************************
	PROCEDURE init
	
	ENDPROC && init
	
	
	*********************************
	PROCEDURE click
		IF !EMPTY(this.Parent.txtSort.value) AND !this.Parent.txtSort.hintShowing
			this.Parent.txtSort.value = ''
			this.Parent.txtSort.showHint()
		ENDIF 
	ENDPROC && click
ENDDEFINE && lblClose



*************************************************************************
* Called via Ctrl+F3, set focus to the command window
PROCEDURE setFocusCmdWin

LOCAL m.x 
FOR m.x=1 TO _vfp.Forms.Count
	IF !'PROJECTEXPLORER' $ UPPER(_vfp.Forms.Item(m.x).name)
		LOOP
	ENDIF

	oExplorer = _vfp.Forms.Item(m.x)
	
	oExplorer.oProjectToolBar.cntcmdwin.txtsort.setFocus()

	EXIT
ENDFOR

ENDPROC && setFocusCmdWin