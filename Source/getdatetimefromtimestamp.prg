*==============================================================================
* Function:			GetDateTimeFromTimestamp
* Purpose:			Converts a VFP timestamp to a DateTime
* Author:			Adapted from _FRXCursor.GetTimeStampString by Doug Hennig
* Last revision:	03/31/2017
* Parameters:		tiStamp - the timestamp value
* Returns:			the DateTime equivalent of the timestamp
* Environment in:	none
* Environment out:	none
*==============================================================================

lparameter tiStamp
local lnYearOffset, ;
	lnYear, ;
	lnMonth, ;
	lnDay, ;
	lnHour, ;
	lnMinute, ;
	lnSecond
if empty(tiStamp) or vartype(tiStamp) <> 'N'
	return {/:}
endif empty(tiStamp) ...
lnYearOffset = bitrshift(tiStamp, 25)
	&& bits 31-25
lnYear       = 1980 + lnYearOffset
lnMonth      = bitrshift(tiStamp, 21) % 2^4
	&& bits 24-21
lnDay        = bitrshift(tiStamp, 16) % 2^5
	&& bits 20-16
lnHour       = bitrshift(tiStamp, 11) % 2^5
	&& bits 15-11
lnMinute     = bitrshift(tiStamp,  5) % 2^6
	&& bits 10-5
lnSecond     = bitlshift(tiStamp % 2^5, 1)
	&& bits 4-0 (two-second increments)
return datetime(lnYear, lnMonth, lnDay, lnHour, lnMinute, lnSecond)
