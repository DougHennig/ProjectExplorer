**************************************************
*-- Class:        api_apprun (e:\processclass\process.vcx)
*-- ParentClass:  custom
*-- BaseClass:    custom
* Author: Ed Rauh
*
DEFINE CLASS api_apprun AS custom

	* Process handle for process started by this object
	PROTECTED inprocesshandle
	inprocesshandle = .NULL.
	* Initial thread handle for process started by this object
	PROTECTED inthreadhandle
	inthreadhandle = .NULL.
	* Command line to execute to start this process
	iccommandline = (space(0))
	* Dir to start process from
	iclaunchdir = (space(0))
	* Window mode to use at process startup, one of:
	*	(empty)	Executable's default window mode
	*	NOR		ShowWindow Normal 0x1
	*	MIN		ShowWindow Minimized 0x2
	*	MAX		ShowWindow Maximumized 0x3
	*	HID		ShowWindow Hidden 0x0
	*			in this mode, there is no hookable WinMain
	icwindowmode = (space(0))
	*	Last error encountered desciptor (output)
	icerrormesage = (space(0))
	Name = "api_apprun"
	icerrormessage = .F.


	PROCEDURE LaunchApp
		*  Launch executable by CreateProcess() and return immediately
		LOCAL cCommandLine, uFromDir, cWindowMode
		WITH This
			.icErrorMessage = ''
			IF TYPE('.icCommandLine') # 'C'
				*	Command line must be a character string
				.icErrorMessage = 'icCommandLine must be set, and a string value'
				RETURN .F.
			ELSE
				cCommandLine = ALLTRIM(.icCommandLine)
			ENDIF
			IF TYPE('.icLaunchDir') # 'C' OR EMPTY(.icLaunchDir)
				*	If not a character string, pass a null pointer, defaulting to Current Working Dir
				uFromDir = 0
			ELSE
				*	Otherwise, null pad the string
				uFromDir = .icLaunchDir + CHR(0)
			ENDIF
			IF TYPE('.icWindowMode') # 'C'
				*	If not passed, set to null string
				cWindowMode = ''
			ELSE
				*	Translate the passed window mode to uppercase
				cWindowMode = UPPER(.icWindowMode)
			ENDIF
			*	This API call does the work.  The parameters are as follows:
			*		lpszModuleName - ptr-> file name of module to execute.  
			*		  Since we aren't launching .CPLs, do not use
			*		lpszCommandLine - ptr-> command to execute, as passed in method
			*		lpSecurityAttributesProcess - ptr-> SECURITY_ATTRIBUTES structure for Process.  
			*		  Pass a null pointer
			*		lpSecurityAttributesThread - ptr-> SECURITY_ATTRIBUTES structure for first thread.  
			*		  Pass a null pointer
			*		bInheritHandles - whether or not chlid inherits parent handles.  
			*		  Since no SECURITY_ATTRIBUTES passed, default to FALSE
			*		dwCreateFlags - Process Creation Mode flag set.  
			*		  We use the default mode at normal priority, ie 0
			*		lpvEnvironment	- ptr-> a set of environment strings as if a MULTI_SZ.  
			*		  We don't set, so pass a null pointer
			*		lpszStartupDir - ptr-> the starting directory.  
			*		  If none provided to method, pass a null pointer
			*		lpStartInfo - ptr-> a STARTUPINFO structure.  
			*		  We use one structure member at times.
			*		lpProcessInfo - ptr-> a PROCESS_INFORMATION structure, used to return PID/PHANDLE detail.  
			*		  We use one member to retain the Process handle, and destroy the thread handle
			DECLARE SHORT CreateProcess IN WIN32API AS CrPr ;
				STRING lpszModuleName, ;
				STRING @lpszCommandLine, ;
				STRING lpSecurityAttributesProcess, ;
				STRING lpSecurityAttributesThread, ;
				SHORT bInheritHandles, ;
				INTEGER dwCreateFlags, ;
				STRING lpvEnvironment, ;
				STRING lpszStartupDir, ;
				STRING @lpStartInfo, ;
				STRING @lpProcessInfo

			LOCAL cProcessInfo, cStartUpInfo

			*	Make default Structures for the CreateProcess call
			*
			*	ProcessInfo -	struc, 4 DWORDs, a Process Handle, a Thread Handle, a ProcessID and a ThreadID
			*					we save the Process and Thread Handles in member properties to ensure that
			*					they are properly disposed at Destroy by CloseHandle().  We dispose of the
			*					thread handle immediately

			cProcessInfo = REPL(CHR(0),16)

			*	StartUpInfo is a 68 byte long complex structure;  we either have 68 bytes with a cb member (byte 1) 68
			*	or with cb of 68, dwFlag low order byte (byte 45) of 1, and low order byte wShowWindow (byte 49) set to
			*	the SW_ value appropriate for the Window Mode desired.

			DO CASE
			CASE cWindowMode = 'HID'
				*	Hide - use STARTF_USESHOWFLAG and value of 0
				cStartUpInfo = CHR(68) + ;
								REPL(CHR(0),43) + ;
								CHR(1) + ;
								REPL(CHR(0),23)
			CASE cWindowMode = 'NOR'
				*	Normal - use STARTF_USESHOWFLAG and value of 1
				cStartUpInfo = CHR(68) + ;
								REPL(CHR(0),43) + ;
								CHR(1) + ;
								REPL(CHR(0),3) + ;
								CHR(1) + ;
								REPL(CHR(0),19)
			CASE cWindowMode = 'MIN'
				*	Minimize - use STARTF_USESHOWFLAG and value of 2
				cStartUpInfo = CHR(68) + ;
								REPL(CHR(0),43) + ;
								CHR(1) +  ;
								REPL(CHR(0),3) + ;
								CHR(2) + ;
								REPL(CHR(0),19)
			CASE cWindowMode = 'MAX'
				*	Maximize - use STARTF_USESHOWFLAG and value of 3
				cStartUpInfo = CHR(68) + ;
								REPL(CHR(0),43) + ;
								CHR(1) +  ;
								REPL(CHR(0),3) + ;
								CHR(3) + ;
								REPL(CHR(0),19)
			OTHERWISE
				*	Use default of application
				cStartUpInfo = CHR(68) + REPL(CHR(0),67)
			ENDCASE
			*	Do it!
			LOCAL lResult
			lResult = CrPr(	0, ;
							cCommandLine, ;
							0, 0, 0, 0, 0, ;
							uFromDir, ;
							@cStartUpInfo, ;
							@cProcessInfo)
			*	Strip the handles from the PROCESS_INFORMATION structure and save in private properties
			IF lResult = 1
				.ParseProcessInfoStruc(cProcessInfo)
				RETURN .T.
			ELSE
				.icErrorMessage = 'Process Specified by icCommandLine could not be started'
				RETURN .F.
			ENDIF
		ENDWITH
	ENDPROC


	PROCEDURE LaunchAppAndWait
		*	Invoke LaunchApp(), and then wait on the process to terminate before returning control
		#DEFINE cnINFINITE 		0xFFFFFFFF
		#DEFINE cnHalfASecond	500	&& milliseconds
		#DEFINE cnTimedOut		258	&& 0x0102
		*	We need some API calls, declare here
		*	GetCurrentProcess returns the pseudohandle of the current process (ie VFP instance)
		DECLARE INTEGER GetCurrentProcess IN WIN32API AS GetCurrProc
		*	WaitForIdleInput waits until the application is instantiated and at it's event loop
		DECLARE INTEGER WaitForInputIdle IN WIN32API AS WaitInpIdle ;
			INTEGER nProcessHandle, ;
			INTEGER nWaitForDuration
		*	WaitForSingleObject waits until the handle in parm 1 is signalled or the timeout period expires
		DECLARE INTEGER WaitForSingleObject IN WIN32API AS WaitOnAppExit ;
			INTEGER hProcessHandle, ;
			INTEGER dwTimeOut
		*	Save the Process handle if any and the result of LaunchApp
		*	Fire the app and save the process handle
		LOCAL uResult
		uResult = 0
		WITH This
			.icErrorMessage = ''
			IF .LaunchApp()
				uResult = 1
				*	It's been launched;  wait until we're idling along
				=WaitInpIdle(GetCurrProc(),cnINFINITE)
				*	As long as the other process exists, wait for it
				DO WHILE WaitOnAppExit(.inProcessHandle, cnHalfASecond) = cnTimedOut
					*	Give us an out in case the other app hangs - let <Esc> terminate waits
					IF INKEY() = 27
						*	Still running but we aren't waiting - return a -1 as a warning
						.icErrorMessage = 'Process started but user did not wait on termination'
						uResult = 0
						EXIT
					ENDIF
				ENDDO
			ELSE
				*	Return 0 to indicate failure
				uResult = 0
			ENDIF
		ENDWITH
		RETURN (uResult = 1)
	ENDPROC


	PROCEDURE CheckProcessExitCode
		*	examine the Process handle object's termination code member
		*	Provide the user with the option to examine another process
		*	termination code by passing an explicit handle, otherwise
		*	use the object's process instance
		LPARAMETER nProcessToCheck
		IF TYPE('nProcessToCheck') # 'N'
			nProcessToCheck = this.inProcessHandle
		ENDIF
		DECLARE SHORT GetExitCodeProcess IN Win32API AS CheckExitCode ;
			INTEGER hProcess, ;
			INTEGER @lpdwExitCode
		LOCAL nExitCode
		nExitCode = 0
		IF ! ISNULL(nProcessToCheck)
			IF CheckExitCode(nProcessToCheck, @nExitCode) = 1
				*	We retrieved an exit code (259 means still running, tho)
				RETURN nExitCode
			ELSE
				*	Process did not exist in process table - no exit status
				this.icErrorMessage = 'Process to check not in active Process Table'
				RETURN NULL
			ENDIF
		ELSE
			this.icErrorMessage = 'NULL process handle passed to CheckProcessExitCode()'
			RETURN NULL
		ENDIF
	ENDPROC

	PROTECTED PROCEDURE ReleaseHandle
		*  This uses CloseHandle to release a handle of any type.  I didn't expose it,
		*  mostly so that people wouldn't accidentally mash up things they shouldn't when
		*  experimenting
		LPARAMETER nHandleToRelease
		LOCAL nResult
		*	Use CloseHandle(), returns a BOOL;  0 = False
		DECLARE SHORT CloseHandle IN Win32API AS CloseHand INTEGER nHandleToClose
		IF TYPE('nHandleToRelease') = 'N' AND ! ISNULL(nHandleToRelease)
			nResult = CloseHand(nHandleToRelease)
			this.icErrorMessage = IIF(nResult = 0, 'CloseHandle() failed to close handle '+STR(nHandleToRelease),'')
		ELSE
			this.icErrorMessage = 'Invalid handle passed to ReleaseHandle() invocation'
			nResult = 0
		ENDIF
		RETURN (nResult = 1)
	ENDPROC


	PROCEDURE GetProcHandle
		*	Hand back the process handle in case someone needs it
		RETURN this.inProcessHandle
	ENDPROC


	PROCEDURE KillProc
		*  A wrapper on TerminateProcess(), it will terminate the process owned by
		*  the object unless you pass it another Process Handle.  If it's already dead,
		*  nothing interesting happens
		*
		*  TerminateProcess() does not shut down in an orderly fashion;  this is for emergencies!
		LPARAMETER nProcessToKill
		IF TYPE('nProcessToKill') # 'N'
			nProcessToKill = This.inProcessHandle
		ENDIF
		DECLARE SHORT TerminateProcess IN WIN32API AS KillProc ;
			INTEGER hProcess, ;
			INTEGER uExitCode
		LOCAL nResult
		IF ! ISNULL(nProcessToKill)
			nResult = KillProc(nProcessToKill,0)
			this.icErrorMessage = IIF(nResult = 0, 'TerminateProcess() could not kill process handle '+STR(nProcessToKill),'')
		ELSE
			this.icErrorMessage = 'NULL handle passed to KillProc()'
			nResult = 0
		ENDIF
		RETURN (nResult = 1)
	ENDPROC


	PROTECTED PROCEDURE ParsePROCESSINFOStruc
		*	Pull the Process and thread handles out of the PROCESSINFO structure
		LPARAMETER cProcessInfoStructure
		WITH This
			.inProcessHandle = .ExtractDWORD(cProcessInfoStructure)
			.inThreadHandle = .ExtractDWORD(SUBST(cProcessInfoStructure,5))
		ENDWITH

	ENDPROC


	PROCEDURE ExtractDWORD
		*  Convert a 4 byte string to an unsigned long (DWORD)
		LPARAMETER cStringToExtractFrom
		IF TYPE('cStringToExtractFrom')='C' AND LEN(cStringToExtractFrom) >= 4
			RETURN (((ASC(SUBST(cStringToExtractFrom,4,1))*256) + ;
									ASC(SUBST(cStringToExtractFrom,3,1)))*256 + ;
									ASC(SUBST(cStringToExtractFrom,2,1)))*256 + ;
									ASC(LEFT(cStringToExtractFrom,1))
		ELSE
			this.icErrorMessage = 'Invalid DWORD string passed for conversion'
			RETURN NULL
		ENDIF
	ENDPROC


	PROCEDURE Destroy
		*  Mommy, mommy make it go away!
		WITH THIS
			IF TYPE('.inThreadHandle') = 'N' AND NOT ISNULL(.inThreadHandle)
				*  If we still hold it, dispose the Thread handle
				.ReleaseHandle(.inThreadHandle)
				.inThreadHandle = NULL
			ENDIF
			IF TYPE('.inProcessHandle') = 'N' AND NOT ISNULL(.inProcessHandle)
				*  If we still hold it, dispose the Process handle
				.ReleaseHandle(.inProcessHandle)
				.inProcessHandle = NULL
			ENDIF
			*	NB - the process and thread object hang around until all handles to them are
			*	disposed by CloseHandle - going out of scope doesn't release them.
		ENDWITH
		DODEFAULT()
	ENDPROC


	PROCEDURE Init
		*
		*	API_AppRun - use the CreateProcess() API to launch, monitor, and kill an Executable
		*
		*	Properties:
		*
		*	inProcessHandle			(P)	ProcessHandle generated by CreateProcess()
		*	inThreadHandle			(P) ThreadHandle for First Thread of inProcessHandle
		*	icErrorMessage			R/O Error Message Detailed Description
		*	icCommandLine			R/W Command Line to launch via CreateProcess()
		*	icLaunchDir				R/W Directory to use as startup dir for CreateProcess()
		*	icWindowMode			R/W Window Start Mode, one of (HID, NOR, MIN, MAX) or empty
		*							defaults to empty, the default for the executable is used
		*
		*	Methods:
		*
		*	Init					(O) Command Line, (O) Start Dir, (O) Window Start Mode
		*							If sent, the icCommandLine, icLaunchDir and icWindowMode properties are set
		*	Destroy
		*	LaunchApp				// Launches .icComandLine from .icLaunchDir in .icWindowMode
		*							// NB - at least .icCommandLine must be set to not fail
		*							RETURNS: BOOL, check icErrorMessage on .F.
		*	LaunchAppAndWait		// Call LaunchApp() and wait on either user termination or process termination
		*							RETURNS: BOOL, check icErrorMessage on .F.
		*	CheckProcessExitCode	(O) Process handle to check, defaults to .inProcessHandle
		*							// Get Process named by Process Handle's Exit Code (259 = still running)
		*							RETURNS:  Integer, check on NULL, if NULL, check icErrorMessage
		*	ExtractDWORD			(R) String to convert
		*							//Converts a 4 byte or longer string to a DWORD integer
		*							RETURNS:  Integer, check on NULL, if NULL arg was invalid
		*	KillProc				(O) Process handle to Terminate, defaults to .inProcessHandle
		*							// Kills specified process using TerminateProcess()
		*							RETURNS:  BOOL, check icErrorMessage on .F.
		*	GetProcHandle			//  Returns the Process Handle for the current Process
		*							// NB - only useful for KillProc(), since Destroy will close the handle
		*							RETURNS:  Integer, check for NULL, if NULL no process was started yet
		*	ParsePROCESSINFOStruc	// Pulls the Process Handle and Thread Handle from the PROCESSINFO structure
		*							// Only used internally
		*	ReleaseHandle			(R)  Handle to Close
		*							//  Invokes CloseHandle() to explicitly release process/thread handles
		*							//  Only used internally, but can be externalized
		*							RETURNS:  BOOL, check .icErrorMessage on .F.
		*
		LPARAMETERS tcCommandLine, tcLaunchDir, tcWindowMode
		*	Set up the environment for the object
		LOCAL aDirTest[1,5]
		WITH THIS
			.icErrorMessage = ''
			.icCommandLine = ''
			.icLaunchDir = ''
			.icWindowMode = ''
			.inProcessHandle = NULL
			.inThreadHandle = NULL
			* store parameters if passed
			IF TYPE('tcCommandLine') = 'C'
				.icCommandLine = ALLTRIM(tcCommandLine)
			ENDIF
			DO CASE
			CASE TYPE('tcLaunchDir') # 'C'
				*	Not a character expression - ignore
			CASE ADIR(aDirTest, tcLaunchDir, 'D') # 1
				*	Either directory doesn't exist, or there's a wildcard in the expression
				.icErrorMessage = 'Invalid directory for startup passed to Init method'
			OTHERWISE
				*	Valid directory - save it
				.icLaunchDir = ALLTRIM(tcLaunchDir)
			ENDCASE
			DO CASE
			CASE TYPE('tcWindowMode') # 'C'
				*	Not passed in or not valid type
			CASE INLIST(PADR(UPPER(ALLTRIM(tcWindowMode)),3),'NOR','MIN','MAX','HID')
				*	Valid mode - set it
				.icWindowMode = PADR(UPPER(ALLTRIM(tcWindowMode)),3)
			OTHERWISE
				*	No a valid character string
				IF ! EMPTY(.icErrorMessage)
					.icErrorMessage = .icErrorMessage + ' &' + CHR(13) + CHR(10)
				ENDIF
				.icErrorMessage = .icErrorMessage + 'Invalid WindowMode passed to Init Method'
			ENDCASE
		ENDWITH
		RETURN .T.
	ENDPROC


ENDDEFINE
*
*-- EndDefine: api_apprun
**************************************************

#if .F.
SET PROCEDURE TO Process ADDITIVE
oProcess = CREATEOBJ('API_AppRun','NOTEPAD.EXE AUTOEXEC.BAT','C:\','NOR')
*Run the application and don't wait to terminate
oProcess.LaunchApp()
*Check the exit status;  259 means still running
IF oProcess.CheckProcessExitCode() = 259
	wait window 'Still running'
ELSE
	wait window 'Terminated with a '+alltrim(str(oProcess.CheckProcessExitCode()))
ENDIF
? oProcess.KillProc()
oProcess = ''
*  You can have multiple processes running at once
oProcess1 = CREATEOBJ('API_AppRun','REGEDIT','C:\','NOR')
oProcess2 = CREATEOBJ('API_AppRun','NET USE /? | MORE')
oProcess1.LaunchApp()
oProcess2.LaunchApp()
oProcess1 = ''
oProcess2 = ''
* Run them both and wait on the last to terminate
oProcess1 = CREATEOBJ('API_AppRun','NOTEPAD.EXE AUTOEXEC.BA','C:\','NOR')
oProcess2 = CREATEOBJ('API_AppRun','NOTEPAD.EXE CONFIG.SY','C:\','MIN')
oProcess1.LaunchApp()
oProcess2.LaunchAppAndWait()
#endif