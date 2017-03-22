*** TODO: clean up code

*=======================================================
* GetTimeStampString( iStamp )
* Taken from _FRXCursor.GetTimeStampString
*
* Returns a datetime version of a Fox system 
* timestamp, using current date settings
*=======================================================
lparameter tiStamp 

IF EMPTY(tiStamp) OR TYPE("tiStamp") # "N"  
   RETURN {/:}
ENDIF
LOCAL lnYearoffset,lcYear,lcMonth,;
      lcDay,lcHour,lcMinute,lcSecond

*-------------------------------------------------------
* lnYearoffset = INT(tiStamp/2^25)   && bits 31-25
*-------------------------------------------------------
lnYearoffset = BITRSHIFT(tiStamp,25)
lnYear = 1980 + lnYearoffset

*-------------------------------------------------------
* lcMonth = STR(INT(tiStamp/2^21) % 2^4)  && bits 24-21
*-------------------------------------------------------
lnMonth = BITRSHIFT(tiStamp,21) % 2^4

*-------------------------------------------------------
* lcDay = STR(INT(tiStamp/2^16) % 2^5)    && bits 20-16
*-------------------------------------------------------
lnDay = BITRSHIFT(tiStamp,16) % 2^5

*-------------------------------------------------------
* lcHour = STR(INT(tiStamp/2^11) % 2^5)   && bits 15-11
*-------------------------------------------------------
lnHour = BITRSHIFT(tiStamp,11) % 2^5

*-------------------------------------------------------
* lcMinute = STR(INT(tiStamp/2^5) % 2^6)  && bits 10-5
*-------------------------------------------------------
lnMinute = BITRSHIFT(tiStamp,5) % 2^6

*-------------------------------------------------------
* lcSecond = STR(INT(tiStamp%2^5) * 2)    && bits 4-0 (two-second increments)   
*-------------------------------------------------------
lnSecond = BITLSHIFT(tiStamp%2^5,1)

*RETURN TTOC({^&lcYear./&lcMonth./&lcDay. &lcHour.:&lcMinute.:&lcSecond.})	
return datetime(lnYear, lnMonth, lnDay, lnHour, lnMinute, lnSecond)	
