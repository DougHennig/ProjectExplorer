* Written by Rick Borup.

lparameters toParameter1, ;
	tuParameter2, ;
	tuParameter3

* If this is a registration call, tell the addin manager which method we're
* an addin for.

if pcount() = 1
	toParameter1.Method = 'OnStartup'
	toParameter1.Active = .F.
	return
endif

* Add a button to the toolbar to open the White Light Computing (WLC) Project
* Builder dialog for the active project.
* Requires the WLC Project Hook class library cprojecthook5.vcx (download from
* http://whitelightcomputing.com/prodprojectbuilder.htm)
* To use: 1) Set toParameter1.Active = .T. (above)
*         2) Set the value of WLCProjectBuilderButton.cWLCProjectBuilderClass
*			 (below)

loToolbar = toParameter1.oProjectToolbar
try
	loToolbar.AddObject('cmdWLCProjectBuilder', 'WLCProjectBuilderButton')
	loButton             = loToolbar.cmdWLCProjectBuilder
	loButton.Height      = loToolbar.cmdBack.Height
	loButton.Width       = 30
	loButton.Caption     = 'PB'
	loButton.ToolTipText = 'Open WLC Project Builder Dialog'
	loButton.Visible     = .T.
	toParameter1.SetToolbarControlLocation(loButton)
	llOK = .T.
catch
	loToolbar.RemoveObject('cmdWLCProjectBuilder')
	llOK = .F.
endtry
return llOK

define class WLCProjectBuilderButton as CommandButton

* Set cWLCProjectBuilderClass to the path and file name of the WLC
* cprojecthook5.vcx class library (or your subclass library).

	cWLCProjectBuilderClass   = '\Development\Tools\VFP\WLCProjectBuilder\' + ;
		'cProjectHook5.vcx'
	oWLCProjectBuilderToolbar = null
		
	function Init
		This.oWLCProjectBuilderToolbar = newobject('tbrProjectTools', ;
			This.cWLCProjectBuilderClass)
		return vartype( This.oWLCProjectBuilderToolbar) = 'O' and ;
			not isnull( This.oWLCProjectBuilderToolbar)
	endfunc
	
	function Click
		This.oWLCProjectBuilderToolbar.cmdProjectBuilder.Click()
	endfunc
enddefine
