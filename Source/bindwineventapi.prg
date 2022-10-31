* Declare Win32 API functions 
* Greg Green: The problem is we are both declare Win API functions and then clearing them 
*	as part of our clean-up.  I have found that by using a function wrapper around the DECLARE - DLL 
*	call that you don't have to worry that another program has released a DECLARE of yours.  
*	The SET PROCEDURE TO ensures that your program will always find the wrapper.  
FUNCTION CallWindowProc
LPARAMETERS lpPrevWndFunc, hWnd, nMsg, wParam, lParam
	Declare Integer CallWindowProc In Win32API Integer lpPrevWndFunc, Integer hWnd, Integer nMsg, Integer wParam, Integer lParam
	RETURN CallWindowProc(lpPrevWndFunc, hWnd, nMsg, wParam, lParam)
ENDFUNC


FUNCTION GetWindowLong
LPARAMETERS hWnd, nIndex
	Declare Integer GetWindowLong In Win32API Integer hWnd, Integer nIndex
	RETURN GetWindowLong(hWnd, nIndex)
ENDFUNC
