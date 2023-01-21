*==============================================================================
* Program:			SetCurDirOnProjectOpen.prg
* Purpose:			Sets the VFP current directory to the solution folder
*						when a solution is opened
* Author:			Doug Hennig
* Last Revision:	01/17/2023
* Parameters:		toParameter1 - a reference to an addin parameter object if
*						only one parameter is passed (meaning this is a
*						registration call) or a reference to an object; see the
*						documentation for the type of object passed for each
*						method
*					tuParameter2 - the solution path
*					tuParameter3 - ignored
* Returns:			.T.
*==============================================================================

lparameters toParameter1, ;
	tuParameter2, ;
	tuParameter3

* If this is a registration call, tell the addin manager which method we're
* an addin for.

if pcount() = 1
	toParameter1.Method = 'AfterOpenSolution'
	toParameter1.Active = .T.	&& set to .F. to disable addin
	toParameter1.Name   = 'Sets the VFP current directory to the solution folder'
	toParameter1.Order  = 1		&& specify order to process (optional)
	return
endif

* This is an addin call, so do it.

cd (justpath(tuParameter2))
return .T.
