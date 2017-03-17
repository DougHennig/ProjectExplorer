#include ProjectExplorerCtrls.H

#define ccVFP_OPTIONS					'Software\Microsoft\VisualFoxPro\9.0\Options'
	&& the HKEY_CURRENT_USER location for VFP options
#define ccPROJECT_EXPLORER_KEY			'Software\ProjectExplorer'
	&& the HKEY_CURRENT_USER location for Project Explorer options
#define ccFOXBIN2PRG_MAIN_EXE_FILENAME	'FoxBin2Prg.EXE'

#define ccSOLUTION_FILE					'Solution.xml'
	&& the name of the solution file

* Version control status.

#define ccVC_STATUS_ADDED				'A'
#define ccVC_STATUS_CLEAN				'C'
#define ccVC_STATUS_UNTRACKED			'?'
#define ccVC_STATUS_MODIFIED			'M'

* Project item types (most are in FOXPRO.H as FILETYPE_* constants).

#define FILETYPE_VIEW					'View'
#define FILETYPE_REMOTE_VIEW			'RemoteView'
#define FILETYPE_LOCAL_VIEW				'LocalView'
#define FILETYPE_CONNECTION				'Connection'
#define FILETYPE_STORED_PROCEDURE		'SProc'
#define FILETYPE_CLASS					'Class'
#define FILETYPE_FIELD					'Field'
#define FILETYPE_INDEX					'Index'
#define FILETYPE_TABLE_IN_DBC			't'
#define FILETYPE_INDEX_IN_DBC			'I'

* Titles of VFP designer windows.

#define ccTITLE_VIEW_DESIGNER			'View Designer - '
#define ccTITLE_CONNECTION_DESIGNER		'Connection Designer - '
#define ccTITLE_STORED_PROCS			'Stored Procedures for '
#define ccTITLE_QUERY_DESIGNER			'Query Designer - '
#define ccTITLE_REPORT_DESIGNER			'Report Designer - '
#define ccTITLE_LABEL_DESIGNER			'Label Designer - '
#define ccTITLE_FORM_DESIGNER			'Form Designer - '
#define ccTITLE_MENU_DESIGNER			'Menu Designer - '
#define ccTITLE_CLASS_DESIGNER			'Class Designer - '
#define ccTITLE_DATABASE_DESIGNER		'Database Designer - '

* Windows events.

#define WM_DESTROY						0x0002
#define GWL_WNDPROC						-4
