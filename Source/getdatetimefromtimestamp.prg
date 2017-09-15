*==============================================================================
* Function:			GetDateTimeFromTimestamp
* Purpose:			Converts a VFP timestamp to a DateTime
* Author:			Adapted from _FRXCursor.GetTimeStampString by Doug Hennig
*						with valid checking by Phil Sherwood
* Last revision:	09/14/2017
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

* Ensure the values are valid.

if not between(lnYear, 1980, year(date()))
	lnYear = 1980
endif not between(lnYear...
if not between(lnMonth, 1, 12)
	lnMonth = 1
endif not between(lnMonth...
if not between(lnDay, 1, 31)
	lnDay = 1
endif not between(lnDay...
if not between(lnHour, 1, 24)
	lnHour = 12
endif not between(lnHour...
if not between(lnMinute, 0, 59)
	lnMinute = 0
endif not between(lnMinute...
if not between(lnSecond, 0, 60)
	lnSecond = 0
endif not between(lnSecond...
return datetime(lnYear, lnMonth, lnDay, lnHour, lnMinute, lnSecond)
