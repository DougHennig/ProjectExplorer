*==============================================================================
* Method:			GetInput
* Purpose:			A replacement for the VFP INPUTBOX function
* Author:			Doug Hennig
* Last Revision:	01/14/2015
* Parameters:		tcPrompt      - the prompt for the dialog
*					tcCaption     - the caption for the dialog
*					tcDefault     - the default value
*					tcCancelValue - the value to return if the user cancelled
*						(optional: blank is returned if not specified)
* Returns:			the value the user entered if they clicked OK or the value
*						in tcCancelValue if not
* Environment in:	none
* Environment out:	none
*==============================================================================

lparameters tcPrompt, ;
	tcCaption, ;
	tcDefault, ;
	tcCancelValue
loForm = newobject('ProjectExplorerModalDialog', 'ProjectExplorerCtrls.vcx')
loForm.Caption = evl(tcCaption, 'Input Value')
loForm.NewObject('lblPrompt', 'ProjectExplorerLabel', ;
	'ProjectExplorerCtrls.vcx')
with loForm.lblPrompt
	.Caption = tcPrompt
	.Visible = .T.
	.Left    = 10
	.Top     = 10
endwith
loForm.NewObject('txtValue', 'ProjectExplorerTextBox', ;
	'ProjectExplorerCtrls.vcx')
with loForm.txtValue
	.Visible = .T.
	.Left    = 10
	.Top     = loForm.lblPrompt.Top + loForm.lblPrompt.Height + 5
	.Width   = 380
	.Value   = evl(tcDefault, '')
endwith
loForm.Width = loForm.txtValue.Width + 2 * loForm.txtValue.Left
loForm.NewObject('cmdOK', 'ProjectExplorerOKButton', ;
	'ProjectExplorerButton.vcx')
with loForm.cmdOK
	.Visible = .T.
	.Left    = (loForm.Width - (.Width * 2 + 5))/2
	.Top     = loForm.txtValue.Top + loForm.txtValue.Height + 10
endwith
loForm.NewObject('cmdCancel', 'ProjectExplorerCancelButton', ;
	'ProjectExplorerButton.vcx')
with loForm.cmdCancel
	.Visible = .T.
	.Left    = loForm.cmdOK.Left + loForm.cmdOK.Width + 5
	.Top     = loForm.cmdOK.Top
endwith
loForm.Height = loForm.cmdOK.Top + loForm.cmdOK.Height + 6
loForm.Show()
if vartype(loForm) = 'O'
	lcReturn = trim(loForm.txtValue.Value)
else
	lcReturn = evl(tcCancelValue, '')
endif vartype(loForm) = 'O'
return lcReturn
