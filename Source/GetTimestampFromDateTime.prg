*==============================================================================
* Function:			GetTimestampFromDateTime
* Purpose:			Converts a DateTime to a VFP timestamp
* Author:			Adapted from _FRXCursor.GetFRXTimeStamp by Doug Hennig
* Last revision:	03/31/2017
* Parameters:		ttDateTime - the DateTime value
* Returns:			the timestamp equivalent of the DateTime
* Environment in:	none
* Environment out:	none
*==============================================================================

lparameter ttDateTime
local lnTemp, ;
	lnFoxTimeStamp

*-------------------------------------------------------
* bits 4-0, seconds in two-second increments
*-------------------------------------------------------
lnTemp = sec(ttDateTime) / 2
lnFoxTimeStamp = padl(right(IntToBin(lnTemp), 5), 5, '0')

*-------------------------------------------------------
* bits 10-5, minutes
*-------------------------------------------------------
lnTemp = minute(ttDateTime)
lnFoxTimeStamp = padl(right(IntToBin(lnTemp), 6), 6, '0') + lnFoxTimeStamp

*-------------------------------------------------------
* bits 15-11, hours
*-------------------------------------------------------
lnTemp = hour(ttDateTime)
lnFoxTimeStamp = padl(right(IntToBin(lnTemp), 5), 5, '0') + lnFoxTimeStamp

*-------------------------------------------------------
* bits 20-16, days
*-------------------------------------------------------
lnTemp = day(ttDateTime)
lnFoxTimeStamp = padl(right(IntToBin(lnTemp), 5), 5, '0') + lnFoxTimeStamp

*-------------------------------------------------------
* bits 24-21, months
*-------------------------------------------------------
lnTemp = month(ttDateTime)
lnFoxTimeStamp = padl(right(IntToBin(lnTemp), 4), 4, '0') + lnFoxTimeStamp

*-------------------------------------------------------
* bits 31-25, years with a 1980 offset
*-------------------------------------------------------
lnTemp = year(ttDateTime) - 1980
lnFoxTimeStamp = padl(right(IntToBin(lnTemp), 7), 7, '0') + lnFoxTimeStamp
lnFoxTimeStamp = BinToInt(lnFoxTimeStamp)
return lnFoxTimeStamp

*=======================================================
* Returns a binary form of an integer
*=======================================================
function IntToBin(tnInteger)
local lnInteger, ;
	lcBinary, ;
	lnCount, ;
	lnDivisor
if empty(tnInteger)
	return '0'
endif empty(tnInteger)
lnInteger = int(tnInteger)
lcBinary  = ''
for lnCount = 31 to 0 step -1
	lnDivisor = 2^lnCount
	if lnDivisor > lnInteger
		lcBinary = lcBinary + '0'
		loop
	endif lnDivisor > lnInteger
	lcBinary  = lcBinary + iif((lnInteger/lnDivisor) > 0, '1', '0')
	lnInteger = int(lnInteger - lnDivisor)
next lnCount
return lcBinary

*=======================================================
* Returns an integer form of binary data
*=======================================================
function BinToInt(tcBinary)
local lnStrLen, ;
	lnInteger, ;
	lnCount
if empty(tcBinary)
	return 0
endif empty(tcBinary)
lnStrLen  = len(tcBinary)
lnInteger = 0
for lnCount = 0 to lnStrLen - 1
	if substr(tcBinary, lnStrLen - lnCount, 1) = '1'
		lnInteger = lnInteger + 2^lnCount
	endif substr(tcBinary, lnStrLen - lnCount, 1) = '1'
next lnCount
return int(lnInteger)
