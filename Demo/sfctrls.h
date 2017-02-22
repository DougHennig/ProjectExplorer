* Include other include files.

#include FOXPRO.H

* Control character constants.

#define ccCRLF						chr(13) + chr(10)
#define ccCR						chr(13)
#define ccLF						chr(10)
#define ccNULL						chr(0)
#define ccTAB						chr(9)
#define ccAMP						chr(38)
#define ccREGISTERED_MARK			chr(174)
#define ccSINGLE_QUOTE				chr(39)
#define ccPLACEHOLDER				chr(127)

* Strings to substitute in error and other messages.

#define ccMSG_INSERT1				'<Insert1>'
#define ccMSG_INSERT2				'<Insert2>'
#define ccMSG_INSERT3				'<Insert3>'
#define ccMSG_INSERT4				'<Insert4>'

* Error resolution return values.

#define ccMSG_RETRY					'Retry'
#define ccMSG_CONTINUE				'Continue'
#define ccMSG_CLOSEFORM				'Close Form'
#define ccMSG_QUIT					'Quit'
#define ccMSG_CANCEL				'Cancel'
#define ccMSG_DEBUG					'Debug'

* Error message strings.

#define ccMSG_ERROR_NUM				'Error #:    '
#define ccMSG_MESSAGE				'Message:    '
#define ccMSG_LINE_NUM				'Line #:     '
#define ccMSG_CODE					'Code:       '
#define ccMSG_METHOD				'Method:     '

* AERROR() array dimensions, including added extensions:

#define cnAERR_NUMBER				 1
#define cnAERR_MESSAGE				 2
#define cnAERR_OBJECT				 3
#define cnAERR_WORKAREA				 4
#define cnAERR_TRIGGER				 5
#define cnAERR_EXTRA1				 6
#define cnAERR_EXTRA2				 7
#define cnAERR_METHOD				 8
#define cnAERR_LINE					 9
#define cnAERR_SOURCE				10
#define cnAERR_DATETIME				11
#define cnAERR_USER					12
#define cnAERR_MAX					cnAERR_USER
#define cnAERR_VFP_MAX				cnAERR_EXTRA2

* Windows messages.

#define WM_DESTROY					0x0002
#define WM_SETTEXT					0x000C

* VFP error numbers:

#define cnERR_FILE_NOT_FOUND		   1
	* File does not exist
#define cnERR_FILE_IN_USE			   3
	* File is in use
#define cnERR_DATA_TYPE_MISMATCH	   9
	* Data type mismatch
#define cnERR_ARGUMENT_INVALID		  11
	* Function argument value, type, or count is invalid
#define cnERR_VARIABLE_NOTFOUND		  12
	* Variable is not found
#define cnERR_ALIAS_NOTFOUND		  13
	* Alias is not found
#define cnERR_NOT_A_TABLE			  15
	* Not a table
#define cnERR_INDEX_FILE_TABLE		  19
	* Index file doesn't match table
#define cnERR_INVALID_SUBSCRIPT		  31
	* Invalid subscrip reference
#define cnERR_MEMO_FILE_CORRUPT		  41
	* Memo file is missing or invalid
#define cnERR_NO_FIELDS				  47
	* No fields found to process
#define cnERR_NO_TABLE_SELECTED		  52
	* No table is open in the current work area
#define cnERR_NEED_MORE_PARAMETERS	  94
	* Must specify additional parameters
#define cnERR_CANNOT_CREATE_FILE	 102
	* Cannot create file
#define cnERR_FILEINUSE				 108
	* File in use by another user
#define cnERR_RECINUSE				 109
	* Record in use by another user
#define cnERR_INDEX_MATCH_TABLE		 114
	* Index doesn't match table
#define cnERR_PRINTER_NOT_READY		 125
	* Printer not ready
#define cnERR_INVALID_PATH_OR_FILE   202
	* Invalid path or filename
#define cnERR_ARRAYDIM				 230
	* Array dimensions are invalid
#define cnERR_NOT_AN_ARRAY			 232
	* Not an array
#define cnERR_USER_DEFINED			1098
	* User-defined error
#define cnERR_TOO_FEW_ARGS			1229
	* Too few arguments
#define cnERR_SUBSCRIPT_RANGE		1234
	* Subscript is outside defined range
#define cnERR_BAND_TOO_LARGE		1298
	* Band is too large to fit on a page
#define cnERR_RUN_FAILED			1405
	* RUN command failed
#define cnERR_OLE_EXEC_FAIL			1426
	* OLE error: remote procedure call failed
#define cnERR_OLE_ERROR				1429
	* OLE error
#define cnERR_OLE_OBJECT_CORRUPT	1440
	* OLE object may be corrupt
#define cnERR_CONN_HANDLE_INVALID	1466
	* Connection handle is invalid
#define cnERR_EXECUTION_CANCELED	1523
	* Execution was canceled by user
#define cnODBC_ERROR				1526
	* ODBC error
#define cnERR_TRIGGER_FAILED		1539
	* Trigger failed
#define cnERR_PROPERTY_INVALID		1560
	* Property value invalid
#define cnERR_PRIM_KEY_INVALID		1567
	* Primary key property invalid
#define cnERR_NONULLS				1581
	* Field does not accept null values
#define cnERR_FIELD_RULE_FAILED		1582
	* Field validation rule is violated
#define cnERR_TABLE_RULE_FAILED		1583
	* Record validation rule is violated
#define cnERR_RECMODIFIED			1585
	* Update conflict
#define cnERR_TAG_NOT_FOUND			1683
	* Index tag is not found
#define cnERR_ACCESS_DENIED			1705
	* File access is denied
#define cnERR_CDX_NOT_FOUND			1707
	* Structural CDX not found
#define cnDB_OBJECT_IN_USE			1709
	* Database object is being used by someone else
#define cnERR_PROPERTY_TYPE_INVALID	1732
	* Data type invalid for this property
#define cnERR_CLASS_DEF_NOT_FOUND	1733
	* Class definition not found
#define cnERR_PROPERTY_NOT_FOUND	1734
	* Property not found
#define cnERR_PROPERTY_READ_ONLY	1743
	* Property is read-only
#define cnERR_CANNOT_FIND_DLL_ENTRY	1754
	* Cannot find entry point in DLL
#define cnERR_SQL_COLUMN_NOT_FOUND  1806
	* SQL: column not found
#define cnERR_TOO_MANY_FIELDS		1872
	* Too many fields
#define cnERR_DUPLKEY				1884
	* Uniqueness of index is violated
#define cnERR_COLLATE_NOT_FOUND		1915
	* Collate sequence not found
#define cnERR_MEMBER_NOT_OBJECT		1943
	* Member does not evaluate to object
#define cnERR_PRINTER_DRIVER		1958
	* Error loading printer driver
#define cnERR_DE_UNLOADED			1967
	* Data environment is already unloaded
#define cnERR_TABLE_IN_USE			1995
	* Error loading the data environment: table is in use
#define cnERR_TABLE_MOVED			2004
	* The table has moved
#define cnERR_CANT_SET_FOCUS		2012
	* Cannot call SetFocus from within a When, Valid ...
#define cnERR_INVALID_DATE			2034
	* Date/DateTime evaluated to an invalid value
#define cnERR_KEY_MUST_BE_SPECIFIED	2063
	* A Key must be specified when adding an item to this collection.
#define cnERR_USER_THROWN			2071
	* User thrown error
#define cnERR_GDI_RESOURCES			2203
	* Insufficient GDI resources
