*==============================================================================================================
*  PROGRAM:	AddipsQSearchToToolbar.prg
*
*  AUTHOR:
*		Shonnon Morris
*		Interactive Payroll Solutions Ltd.
*		Suite 29A, The Trade Centre,
*		30-32 Red Hills Road,
*		Kingston 10
*		Jamaica
*		shonnon@ipsjm.com
*
*  LICENSE FOR VFPX
*
*  PROGRAM DESCRIPTION:
*		This program is an addin for the VFPX ProjectExplorer written by Doug Hennig.
*		This addin adds a textbox that allows you to quickly search for a file within
*		the ProjectExplorer by entering any part of the file name, regardless of which
*		treeview is currently active. Once the file is located, you can select the file
*		which triggers the edit from the toolbar.
*
*		This program adds the following classes to ProjectExplorer Form:
*			:txtIPSQSearch		- Class: Textbox					Parent: m.toParameter1.oProjectToolbar
*			:contSearchResults	- Class: ProjectExplorerContainer	Parent:	m.toParameter1
*			:lstBoxMenu			- Class: ProjectExplorerListBox		Parent: m.toParameter1.contSearchResults
*
*  CALLING SYNTAX:
*		Drop this program into the ProjectExplorer Addin Folder. No need to run it any other way
*
*  INPUT PARAMETERS:
*		toParameter1 = 	A reference to an addin parameter object if only one parameter is passed
*						(meaning this is a registration call) or a reference to ProjectExplorerForm object.
*		tuParameter2 = 	ProjectExplorerShortcutMenu object
*		tuParameter3 = 	Not used
*
*  FUTURE ENHANCEMENTS:
*		The ability to search for not only files, but classes in a class library
*
*  Comment Section based on a layout from Rick Schummer
*--------------------------------------------------------------------------------------------------------------
*											C H A N G E   L O G
*
*  Date				Developer						Version		Description
*  -------------	----------------------------	-------		-----------------------------------------------
*  Jan. 17, 2020	Shonnon Morris					   Beta		Wondered if I could? Let's see if I can.
*  Jan. 26, 2020	Shonnon Morris					    1.0		I guess I can. Created Program
*  Feb. 11, 2020	Shonnon Morris					    2.0		V1.0 tried to figure out what tables PE opened
*																by scanning all opened cursors, then getting
*																what was needed from them. V2.0 used properties
*																from PE to get those cursor names instead.
*
*==============================================================================================================

LPARAMETERS toParameter1, tuParameter2, tuParameter3
LOCAL loToolbar, loSearchText, llSuccess

* If this is a registration call, tell the addin manager which method we're an addin for.
IF PCOUNT() = 1
	m.toParameter1.Method = 'OnStartup'
	m.toParameter1.Active = .F.
	RETURN
ENDIF

loToolbar = m.toParameter1.oProjectToolbar

* Try to add a ipsQSearch Textbox to the toolbar and contSearchResults to PE Form
TRY
	* Load data for search before objects are created, apparently, list boxes need data before they are instantiated.
	=LoadPEItems(m.toParameter1.oProject)	&& Send a reference to project
	IF USED("PEFiles")	&& If this is not available, something went wrong, so move along, nothing to see here.
		m.loToolbar.AddObject('txtIPSQSearch', 'IPSQSearchTextbox', m.toParameter1.oProject)
		m.loToolbar.Parent.AddObject('contSearchResults', 'ipsPESearchResultsCnt')
		IF TYPE("loToolbar.txtIPSQSearch") != 'U' AND TYPE("loToolbar.Parent.contSearchResults") != 'U'
			m.loToolbar.Parent.contSearchResults.oTxtSearch = m.loToolbar.txtIPSQSearch
			m.loSearchText = m.loToolbar.txtIPSQSearch
			m.loSearchText.Left = 200
			m.loSearchText.Width = 200
			m.loSearchText.TabIndex = 27
			m.loSearchText.Top = 2
			m.loSearchText.Visible = .T.
			toParameter1.SetToolbarControlLocation(m.loSearchText)
			llSuccess = .T.
		ENDIF
	ENDIF
CATCH
	* Remove only if instantiated or you'll get errors
	IF TYPE('loToolbar.txtIPSQSearch') = 'O'
		loToolbar.RemoveObject('txtIPSQSearch')
	ENDIF
	IF TYPE('loToolbar.Parent.contSearchResults') = 'O'
		loToolbar.Parent.RemoveObject('contSearchResults')
	ENDIF
ENDTRY
RETURN m.llSuccess


DEFINE CLASS IPSQSearchTextbox AS Textbox
	Height = 23
	
	oProject = .NULL.	&& Reference to PE Object
	lHasFocus = .F.		&& contSearchResults will need to know if the textbox has focus
*** DH 2020-03-11: added properties
	nWidth = 0			&& The saved width of the TreeView control
	lSettingFocus = .F.	&& .T. if we're about to set focus to the list
*** DH 2020-03-11: end of new code

	nTreeViewContainerWidth = 0
	
	PROCEDURE Init
	LPARAMETERS toProject
		This.oProject = m.toProject
		
		* Sticking with Doug's init code. Could not subclass as PE's textbox came with other "strings attached"
		IF os(3) >= '6'
			This.FontName = 'Segoe UI'
		ELSE
			This.FontName = 'Tahoma'
		ENDIF
		
		This.Value = "Enter file name to begin QSearch..."
		This.ForeColor = RGB(192,192,192)
		
		*** SM Mar. 13, 2020: New property to Store original TreeViewContainerWidth
		This.nTreeViewContainerWidth = this.Parent.Parent.oTreeViewContainer.Width
		*** SM Mar. 13, 2020: End
	ENDPROC
	
	PROCEDURE GotFocus
		DODEFAULT()

		=LoadPEItems(This.oProject)		&& Load again in case something changed since the last time it got focus

		* Need to ensure contSearchResults is positioned right below txtIPSQSearch

		WITH this.Parent.Parent.contSearchResults
			.Top = This.height
			.Left = This.Left
			.Width = This.Width

			*** SM Mar. 13, 2020: Move Splitter if TreeViewContainer is Greater than Textbox Left
			IF This.nTreeViewContainerWidth > This.Left
				this.Parent.Parent.oSplitter.MoveSplitterToPosition(This.Left)
			ENDIF
			.ZOrder(0)
			*** SM Mar. 13, 2020: End
			
			.lstBoxMenu.Width = This.Width
		ENDWITH

*** SM Mar. 13, 2020: Commented DH Code - May not need to do this since we are now moving the splitter
***						Moving splitter also ensures that if the TreeView is in the way because of the 
***						user preference, it will be temporarily resized.
*** DH 2020-03-11: if Project Explorer is collapsed, shrink the TreeView so the listbox isn't covered by it
*** 		if not This.Parent.Parent.lExpanded and This.nWidth = 0
*** 			This.nWidth = This.Parent.Parent.oCurrentTreeViewContainer.Width
*** 			This.Parent.Parent.oCurrentTreeViewContainer.Width = This.Left
*** 		endif not This.Parent.Parent.lExpanded ...
*** DH 2020-03-11: end of new code

		* Clearly, nothing has been entered as yet so get rid of our friendly neighbourhood prompt
		IF "enter" $ LOWER(This.Value) AND "qsearch..." $ LOWER(This.Value)
			This.Value = ""
		ENDIF
		
		This.ForeColor = RGB(0,0,0)
		IF !EMPTY(This.Value)	&& If something is here, display contSearchResults
			This.InteractiveChange()
		ENDIF
		
		This.lHasFocus = .T.	&& Need to know that txtIPSQSearch has the current focus
		Thisform.KeyPreview = .F.	&& This allows us to capture the KeyPress events before sending to the form
	ENDPROC

	PROCEDURE LostFocus
		DODEFAULT()

		* You are leaving with an empty Value, so set it back to our friendly neighbourhood prompt
		IF EMPTY(This.Value)
			This.ForeColor = RGB(192,192,192)
			This.Value = "Enter file name to begin QSearch..."
		ELSE
			This.ForeColor = RGB(0,0,0)
		ENDIF
		This.lHasFocus = .F.	&& Need to know that txtIPSQSearch no longer has the current focus

*** DH 2020-03-11: check if we're about to change focus
***		IF !this.Parent.Parent.contSearchResults.lstBoxMenu.lHasFocus
		IF !this.Parent.Parent.contSearchResults.lstBoxMenu.lHasFocus and not This.lSettingFocus
			* If contSearchResults doesn't have focus then, nothing to see here
			this.Parent.Parent.contSearchResults.Visible = .F.
			
			*** SM Mar. 13, 2020: Set Splitter back to original position
			this.Parent.Parent.oSplitter.MoveSplitterToPosition(This.nTreeViewContainerWidth)
			*** SM Mar. 13, 2020: End

*** SM Mar. 13, 2020: Commented DH Code - May not need to do this since we are now moving the splitter
***						Moving splitter also ensures that if the TreeView is in the way because of the 
***						user preference, it will be temporarily resized.			
*** DH 2020-03-11: restore the TreeView width
***			if not This.Parent.Parent.lExpanded
***				This.Parent.Parent.oCurrentTreeViewContainer.Width = This.nWidth
***				This.nWidth = 0
***			endif not This.Parent.Parent.lExpanded

			Thisform.KeyPreview = .T.
*** DH 2020-03-11: end of new code
		ENDIF
*** DH 2020-03-11: setting KeyPreview was moved so it's only done when we're finished
*		Thisform.KeyPreview = .T.
	ENDPROC
	
	PROCEDURE InteractiveChange
		LOCAL _cFilter

		DODEFAULT()
		
		IF !ISNULL(This.Parent.Parent.contSearchResults)
			WITH This.Parent.Parent.contSearchResults
				_cFilter = [']+ALLTRIM(LOWER(This.Value))+[' $ LOWER(PEFiles.pe_item)]
				.SetFilter(m._cFilter)
				Thisform.LockScreen = .T.
				.UpdateListBox(This.Value, This.nTreeViewContainerWidth)	&& Display contSearchResults
				Thisform.LockScreen = .F.
			ENDWITH
		ENDIF
	ENDPROC
	
	PROCEDURE KeyPress
	LPARAMETERS nKeyCode, nShiftAltCtrl
		DO CASE
			CASE m.nKeyCode = 9		&& Tab - Not sure if this feature will stay or how best to use it
				WITH This.Parent.Parent.contSearchResults.lstBoxMenu
					IF !EMPTY(This.Value) AND !(':' $ This.Value) AND	.Visible AND !EMPTY(.List[.ListIndex])
						NODEFAULT
						This.Value = LEFT(.List[.ListIndex,1],AT(':',.List[.ListIndex,1]))+' '+ALLTRIM(This.Value)
						This.SelStart = LEN(ALLTRIM(This.Value))
					ENDIF
				ENDWITH
			CASE m.nKeyCode = 13	&& Enter - Edit the selected Item
				NODEFAULT
				IF !ISNULL(This.Parent.Parent.contSearchResults)
					WITH This.Parent.Parent.contSearchResults
						.SelectItem(.cSelectedMenuItem, .cSelectedMenuDescription)
					ENDWITH
				ENDIF
			CASE m.nKeyCode = 24	&& Down Arrow - Set focus to contSearchResults, if it was visible
				NODEFAULT
				IF !ISNULL(This.Parent.Parent.contSearchResults) AND This.Parent.Parent.contSearchResults.Visible
*** DH 2020-03-11: flag that we're changing focus
					This.lSettingFocus = .T.
					This.Parent.Parent.contSearchResults.lstBoxMenu.SetFocus()
					This.Parent.Parent.contSearchResults.lstBoxMenu.InteractiveChange()
*** DH 2020-03-11: flag that we're done changing focus
					This.lSettingFocus = .F.
				ENDIF
			CASE m.nKeyCode = 27	&& Escape - This will not work without Thisform.KeyPreview = .F.
				This.ToolTipText = ""
				IF !EMPTY(This.Value)
					NODEFAULT
					This.Value = ""
				ENDIF
				This.Parent.Parent.contSearchResults.Visible = .F.

				*** SM Mar. 21, 2020: Set Splitter back to original position
				this.Parent.Parent.oSplitter.MoveSplitterToPosition(This.nTreeViewContainerWidth)
				*** SM Mar. 21, 2020: End
			OTHERWISE
				This.Parent.Parent.contSearchResults.Visible = .T.
		ENDCASE
	ENDPROC
	
	PROCEDURE Destroy
		* Good bye Cruel World
		ON KEY LABEL CHR(96)
		IF USED("PEFiles")
			USE IN PEFiles
		ENDIF
		DODEFAULT()
	ENDPROC
ENDDEFINE



DEFINE CLASS ipsPESearchResultsCnt AS ProjectExplorerContainer OF ProjectExplorerCtrls.vcx
	BorderWidth = 0
	Height = 255
	Width = 302
	
	lHasFocus = .F.		&& Does the container have focus. Can it?
	cSelectedMenuItem = ""	&& ID of selected Item
	cSelectedMenuDescription = ""	&& Description of Selected Item
	oTxtSearch = .NULL.		&& Reference to txtIPSQSearch
*** DH 2020-03-11: don't need this property since the textbox controls KeyPreview
*	lFormKeyPreviewSetting = .F.	&& Current KeyPreview of the form is stored here
	
	ADD OBJECT lstBoxMenu AS symPElstBoxMenu WITH ;
		RowSourceType = 2, ;
		RowSource = "PEFiles", ;
		Height = 213, ;
		Left = 0, ;
		TabIndex = 1, ;
		Top = 1, ;
		Width = 299, ;
		ZOrderSet = 1
	
*** DH 2020-03-11: don't need this method since the textbox controls KeyPreview
*	PROCEDURE Init
*		This.lFormKeyPreviewSetting = Thisform.KeyPreview
*		DODEFAULT()
*	ENDPROC
		
	PROCEDURE GotFocus
		This.lHasFocus = .T.
		This.Visible = .T.
		This.oTxtSearch.ForeColor = RGB(0,0,0)	&& If This has focus, txtIPSQSearch value should not be faded
	ENDPROC
	
	PROCEDURE LostFocus
		DODEFAULT()
		This.lHasFocus = .F.
		This.Visible = .F.
	ENDPROC
	
	*-- Activate Menu Selection: All the real work happens here
	PROCEDURE SelectItem
	LPARAMETERS cMenuItem, cMenuDescription
	LOCAL cProjectKey, cCurrentNodeID, oItem

		*** SM Mar. 21, 2020: Set Splitter back to original position
		this.Parent.oSplitter.MoveSplitterToPosition(This.oTxtSearch.nTreeViewContainerWidth)
		*** SM Mar. 21, 2020: End
	
		This.oTxtSearch.Value = m.cMenuDescription
		cProjectKey = This.oTxtSearch.oProject.oProjectItem.Key		&& Not sure if this will work for multiple projects in a Solution
		cCurrentNodeID = Thisform.cCurrentNodeID	&& Save the CurrentNodeID
		Thisform.cCurrentNodeID = m.cProjectKey+'~'+m.cMenuItem		&& Set CurrentNodeID to the newly found Item

		oItem = This.Parent.GetItemForNode(Thisform.cCurrentNodeID)	&& Grab the Item so we can interrogate it later
		* In theory, we could have tried to run oItem.EditItem() however, running it from the Toolbar allows whatever 
		* Addins and checks that PE normally does, to be executed as if the user had clicked Edit themselves
		IF TYPE("oItem") = 'O' AND TYPE("oItem.Path") = 'C'
			This.oTxtSearch.ToolTipText = "Path: "+m.oItem.Path+CHR(13)+"Last Modified: "+TTOC(m.oItem.LastModified)
		ENDIF
		This.Visible = .F.
		Thisform.oProjectToolbar.cmdEdit.Click()	&& Activate PE's Edit Method from the Toolbar
		Thisform.cCurrentNodeID = m.cCurrentNodeID	&& Play Nice and set it back as if we were never here
	ENDPROC
	
	PROCEDURE SetFilter
	LPARAMETERS cFilter

		SET FILTER TO &cFilter IN PEFiles
	ENDPROC

	* Controls what is diplayed
	PROCEDURE UpdateListBox
	LPARAMETERS cValue, nTreeViewContainerWidth
	LOCAL _cFilter

		*** SM Mar. 26, 2020: Move Splitter if Initialized or Current TreeViewContainer is Greater than Textbox Left
		IF this.Parent.oTreeViewContainer.Width > This.oTxtSearch.Left OR m.nTreeViewContainerWidth > This.oTxtSearch.Left
			this.Parent.oSplitter.MoveSplitterToPosition(This.oTxtSearch.Left)
		ENDIF
		*** SM Mar. 26, 2020: End

		This.Left = This.oTxtSearch.Left
		This.Top = This.oTxtSearch.Height
		This.Width = This.oTxtSearch.Width

		WITH this.lstBoxMenu
			.Requery()
			.Visible = .T.
			IF .listcount = 0 AND !EMPTY(m.cValue)
				KEYBOARD '{BACKSPACE}'
				_cFilter = ["]+ALLTRIM(LOWER(m.cValue))+[" $ LOWER(PEFiles.pe_item)]
				.Parent.SetFilter(m._cFilter)
				.Requery()
			ENDIF
			.Selected(1) = .T.
			this.cSelectedMenuItem = ALLTRIM(.List[.ListIndex,2])
			this.cSelectedMenuDescription = ALLTRIM(.List[.ListIndex,1])
		ENDWITH
	ENDPROC
ENDDEFINE



DEFINE CLASS symPElstBoxMenu AS ProjectExplorerListBox OF ProjectExplorerCtrls.vcx
	lHasFocus = .F.
	
	FUNCTION GotFocus
		DODEFAULT()
		This.lHasFocus = .T.
*** DH 2020-03-11: KeyPreview is already .F.
*		Thisform.KeyPreview = .F.

*** SM Mar. 13, 2020: Move Splitter if TreeViewContainer is Greater than Textbox Left
		IF This.Parent.oTxtSearch.nTreeViewContainerWidth > This.Parent.oTxtSearch.Left
			this.Parent.Parent.oSplitter.MoveSplitterToPosition(This.Parent.oTxtSearch.Left)
		ENDIF
*** SM Mar. 13, 2020: End
	ENDFUNC
	
	FUNCTION LostFocus
		DODEFAULT()
		This.lHasFocus = .F.
		IF !This.Parent.oTxtSearch.lHasFocus
			This.Visible = .F.
		ENDIF
*** DH 2020-03-11: don't restore it since the textbox does that
*		Thisform.KeyPreview = This.Parent.lFormKeyPreviewSetting

		*** SM Mar. 13, 2020: Set Splitter back to original position
		this.Parent.Parent.oSplitter.MoveSplitterToPosition(This.Parent.oTxtSearch.nTreeViewContainerWidth)
		*** SM Mar. 13, 2020: End
	ENDFUNC
	
	FUNCTION DblClick
		IF !EMPTY(this.Parent.cSelectedMenuItem)
			this.Parent.SelectItem(this.Parent.cSelectedMenuItem, this.Parent.cSelectedMenuDescription)
		ENDIF
	ENDFUNC
	
	FUNCTION Init
		DODEFAULT()
	ENDFUNC
	
	FUNCTION InteractiveChange
		This.Parent.oTxtSearch.Value = This.List[This.ListIndex,1]
		this.Parent.cSelectedMenuItem = ALLTRIM(this.List[this.ListIndex,2])
		this.Parent.cSelectedMenuDescription = ALLTRIM(this.List[this.ListIndex,1])
	ENDFUNC
	
	FUNCTION KeyPress
	LPARAMETERS nKeyCode, nShiftAltCtrl

		DO CASE
			CASE m.nKeyCode = 5		&& Up Arrow
				IF this.ListIndex = 1
					NODEFAULT
					This.Parent.oTxtSearch.SetFocus()
				ENDIF
			CASE m.nKeyCode = 13	&& Enter - Edit the selected Item
				NODEFAULT
				this.Parent.SelectItem(this.Parent.cSelectedMenuItem, this.Parent.cSelectedMenuDescription)
			CASE m.nKeyCode = 27	&& Escape
				NODEFAULT
				this.Visible = .F.
				WITH This.Parent.oTxtSearch 
					.SelStart = LEN(ALLTRIM(.Value))
					.SetFocus()
				ENDWITH
		ENDCASE
	ENDFUNC
	
	FUNCTION When
		RETURN !EMPTY(this.ListCount)
	ENDFUNC
ENDDEFINE


PROCEDURE LoadPEItems
LPARAMETERS toProject
LOCAL cCurrentAlias, cPEItems, cPETags
LOCAL cPETags_Tags, cPETags_Key, cPEItems_Name, cPEItems_Key

	cCurrentAlias = ALIAS()

	cPEItems = m.toProject.cItemCursor
	cPETags = m.toProject.cMetaDataAlias
	
	cPETags_Tags = m.cPETags+'.tags'
	cPETags_Key = m.cPETags+'.key'
	
	cPEItems_Name = m.cPEItems+'.name'
	cPEItems_Key = m.cPEItems+'.key'
	cPEItems_ID = m.cPEItems+'.key'
	SELECT DISTINCT PADR(STRTRAN(STRTRAN(STRTRAN(&cPETags_Tags,CHR(13)),CHR(10)),",UnCommitted")			+': '+JUSTFNAME(&cPEItems_Name),50) AS pe_item, ;
		&cPEItems_ID AS item_id ;
		FROM &cPEItems ;
			LEFT JOIN &cPETags ;
				ON &cPEItems_Key = LEFT(&cPETags_Key,10) ;
		INTO CURSOR PEFiles

	IF !EMPTY(m.cCurrentAlias)
		SELECT (m.cCurrentAlias)
	ENDIF
RETURN