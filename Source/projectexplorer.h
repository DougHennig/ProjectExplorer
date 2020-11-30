#include ProjectExplorerTreeView.H
#include ProjectExplorerRegistry.H

#define ccVFP_OPTIONS					'Software\Microsoft\VisualFoxPro\9.0\Options'
	&& the HKEY_CURRENT_USER location for VFP options
#define ccPROJECT_EXPLORER_KEY			'Software\ProjectExplorer'
	&& the HKEY_CURRENT_USER location for Project Explorer options

#define ccSOLUTION_FILE					'Solution.xml'
	&& the name of older solution files
#define ccSOLUTION_EXT					'slx'
	&& the extension for solution files
#define ccMETADATA_FILE					'_MetaData.dbf'
	&& the suffix to add to the project filename for the meta data table

#define ccHEADER_TYPE					'H'
	&& the type for header records in the TreeView cursor
#define ccVFPX_PAGE						'http://github.com/DougHennig/ProjectExplorer'
	&& Project Explorer page on VFPX
#define ccSTACK_SEPARATOR				'@'
	&& the separator used between information of items added to the stack

* Version control status.

#define ccVC_STATUS_ADDED				'A'
#define ccVC_STATUS_CLEAN				'C'
#define ccVC_STATUS_UNTRACKED			'?'
#define ccVC_STATUS_MODIFIED			'M'
#define ccVC_STATUS_IGNORED				'I'
#define ccVC_STATUS_REMOVED				'R'
#define ccVC_STATUS_UNMERGED			'U'
#define ccGIT_STATUS_REMOVED			'D'

* Project item types (most are in FOXPRO.H as FILETYPE_* constants).

#define FILETYPE_REMOTE_VIEW			'r'
#define FILETYPE_LOCAL_VIEW				'l'
#define FILETYPE_CONNECTION				'c'
#define FILETYPE_STORED_PROCEDURE		'p'
#define FILETYPE_CLASS					'Class'
#define FILETYPE_FIELD					'Field'
#define FILETYPE_INDEX					'Index'
#define FILETYPE_TABLE_IN_DBC			't'
#define FILETYPE_PROJECT				'H'

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
#define ccTITLE_CLASS_BROWSER			' - Class Browser'

* The descriptive names for the types.

#define DESC_DATABASE					'Database'
#define DESC_FREETABLE					'Free Table'
#define DESC_QUERY						'Query'
#define DESC_FORM						'Form'
#define DESC_REPORT						'Report'
#define DESC_LABEL						'Label'
#define DESC_CLASSLIB					'Visual Class Library'
#define DESC_PROGRAM					'Program'
#define DESC_APILIB						'API Library'
#define DESC_APPLICATION				'Application'
#define DESC_MENU						'Menu'
#define DESC_TEXT						'Text File'
#define DESC_OTHER						'Other File'
#define DESC_REMOTE_VIEW				'Remote View'
#define DESC_LOCAL_VIEW					'Local View'
#define DESC_CONNECTION					'Connection'
#define DESC_STORED_PROCEDURE			'Stored Procedure'
#define DESC_CLASS						'Class'
#define DESC_FIELD						'Field'
#define DESC_INDEX						'Index'
#define DESC_TABLE_IN_DBC				'Table'

* Windows events.

#define WM_DESTROY						0x0002
#define GWL_WNDPROC						-4
