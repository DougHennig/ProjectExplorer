*==============================================================================
* Function:			CopyProperties
* Purpose:			Copies all possible properties from one object to another
* Author:			Doug Hennig
* Last revision:	03/20/2016
* Parameters:		toSource - the object to copy properties from
*					toTarget - the object to copy properties to
* Returns:			.T.
* Environment in:	toSource and toTarget must be objects
* Environment out:	all possible properties (those that exist in the target and
*						aren't read-only or protected) are copied from toSource
*						to toTarget
*==============================================================================

lparameters toSource, ;
	toTarget
local laProperties[1], ;
	lnProperties, ;
	lnI, ;
	lcProperty, ;
	luValue, ;
	lnRows, ;
	lnCols
lnProperties = amembers(laProperties, toSource)
for lnI = 1 to lnProperties
	lcProperty = upper(laProperties[lnI])
	if not inlist(lcProperty + ' ', 'BASECLASS ', 'CLASS ', 'CLASSLIBRARY ', ;
		'CONTROLCOUNT ', 'CONTROLS ', 'NAME ', 'OBJECTS ', 'PARENT ', ;
		'PARENTCLASS ')
		&& the space is added so an exact match is found
		luValue = evaluate('toSource.' + lcProperty)

* Ensure the property exists in the target object, is not read-only, and not
* protected. Note: having separate statements for PEMSTATUS is a workaround
* because VFP has a problem with two such commands within one line of code.

		if pemstatus(toTarget, lcProperty, 5) 
			if not pemstatus(toTarget, lcProperty, 1)
				if not pemstatus(toTarget, lcProperty, 2)

* If this is an array property, use ACOPY (the check for element 0 is a
* workaround for a VFP bug that makes native properties look like arrays; that
* is, TYPE('OBJECT.NAME[1]') is not "U"). Otherwise, save the value in the
* property.

					if type('toTarget.' + lcProperty + '[0]') = 'U' and ;
						type('toTarget.' + lcProperty + '[1]') <> 'U'
						lnRows = alen(toSource.&lcProperty, 1)
						lnCols = alen(toSource.&lcProperty, 2)
						if lnCols > 0
							dimension toTarget.&lcProperty[lnRows, lnCols]
						else
							dimension toTarget.&lcProperty[lnRows]
						endif lnCols > 0
						acopy(toSource.&lcProperty, toTarget.&lcProperty)
					else
						store luValue to ('toTarget.' + lcProperty)
					endif type('toTarget.' + lcProperty + '[0]') = 'U' ...
				endif not pemstatus(toTarget, lcProperty, 2)
			endif not pemstatus(toTarget, lcProperty, 1)
		endif pemstatus(toTarget, lcProperty, 5) 
	endif not inlist(lcProperty, ...
next lnI
return
