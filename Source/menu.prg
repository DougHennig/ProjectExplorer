*=================================================================================
define class ProjectExplorerFormMenu as ProjectExplorerMenu of ProjectExplorerMenu.vcx
*=================================================================================
	procedure DefineMenu
		with This
			.AddPad('FilePad', 'menu.prg', 'FilePad')
			.AddPad('EditPad', 'menu.prg', 'EditPad')
*** TODO: remove this pad and associated classes?
			.AddPad('HelpPad', 'menu.prg', 'HelpPad')
		endwith
	endproc
enddefine

*==============================================================================
define class FilePad as ProjectExplorerPad of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption       = [\<File]
	cKey           = [ALT+F]
	cStatusBarText = [File operations]
	cPopupName     = [FilePopup]

	procedure AddBars
		with This
			.AddBar('FileAddProject',        'menu.prg', 'FileAddProject')
			.AddBar('FileRemoveProject',     'menu.prg', 'FileRemoveProject')
			.AddSeparatorBar()
			.AddBar('FileAddVersionControl', 'menu.prg', 'FileAddVersionControl')
			.AddSeparatorBar()
			.AddBar('FileSortFilter',        'menu.prg', 'FileSortFilter')
			.AddSeparatorBar()
			.AddBar('FileTagEditor',         'menu.prg', 'FileTagEditor')
			.AddBar('FileCategoryEditor',    'menu.prg', 'FileCategoryEditor')
			.AddBar('FileOptions',           'menu.prg', 'FileOptions')
			.AddSeparatorBar()
			.AddBar('FileExit',              'menu.prg', 'FileExit')
		endwith
	endproc
enddefine

*==============================================================================
define class FileAddProject as ProjectExplorerBar of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption          = [\<Add Project to Solution]
	cKey              = []
	cKeyText          = []
	cStatusBarText    = [Adds a project to the solution]
	cOnClickCommand   = []
	cActiveFormMethod = [AddProjectToSolution]
	cSkipFor          = []
	cPictureResource  = []
	cPictureFile      = [add.bmp]
	cSystemBar        = []
enddefine

*==============================================================================
define class FileRemoveProject as ProjectExplorerBar of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption          = [\<Remove Project from Solution]
	cKey              = []
	cKeyText          = []
	cStatusBarText    = [Removes a project from the solution]
	cOnClickCommand   = []
	cActiveFormMethod = [RemoveProjectFromSolution]
	cSkipFor          = [_screen.ActiveForm.oSolution.oProjects.Count < 2 or vartype(_screen.ActiveForm.oItem) = 'O']
		&& skip if there's only one project or a project isn't selected
	cPictureResource  = []
	cPictureFile      = [remove.bmp]
	cSystemBar        = []
enddefine

*==============================================================================
define class FileAddVersionControl as ProjectExplorerBar of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption          = [Add \<Version Control to Solution...]
	cKey              = []
	cKeyText          = []
	cStatusBarText    = [Adds version control to the solution]
	cOnClickCommand   = []
	cActiveFormMethod = [AddVersionControl]
	cSkipFor          = [_screen.ActiveForm.oSolution.lHaveVersionControl]
	cPictureResource  = []
	cPictureFile      = [RepoBrowser.bmp]
	cSystemBar        = []
enddefine

*==============================================================================
define class FileSortFilter as ProjectExplorerBar of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption          = [\<Sort and Filter...]
	cKey              = []
	cKeyText          = []
	cStatusBarText    = [Allows you to specify how to sort and filter the TreeView]
	cOnClickCommand   = []
	cActiveFormMethod = [SortFilter]
	cSkipFor          = []
	cPictureResource  = []
	cPictureFile      = [Filter.ico]
	cSystemBar        = []
enddefine

*==============================================================================
define class FileTagEditor as ProjectExplorerBar of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption          = [\<Tag Editor]
	cKey              = []
	cKeyText          = []
	cStatusBarText    = [Maintain tags]
	cOnClickCommand   = []
	cActiveFormMethod = [EditTags]
	cSkipFor          = []
	cPictureResource  = []
	cPictureFile      = [Tags.ico]
	cSystemBar        = []
enddefine

*==============================================================================
define class FileCategoryEditor as ProjectExplorerBar of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption          = [\<Category Editor]
	cKey              = []
	cKeyText          = []
	cStatusBarText    = [Maintain categories]
	cOnClickCommand   = []
	cActiveFormMethod = [EditCategories]
	cSkipFor          = []
	cPictureResource  = []
	cPictureFile      = [Category.ico]
	cSystemBar        = []
enddefine

*==============================================================================
define class FileOptions as ProjectExplorerBar of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption          = [\<Options...]
	cKey              = []
	cKeyText          = []
	cStatusBarText    = [Maintain Project Explorer options]
	cOnClickCommand   = []
	cActiveFormMethod = [GetOptions]
	cSkipFor          = []
	cPictureResource  = []
	cPictureFile      = [options.bmp]
	cSystemBar        = []
enddefine

*==============================================================================
define class FileExit as ProjectExplorerBar of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption          = [E\<xit]
	cKey              = []
	cKeyText          = []
	cStatusBarText    = [Exits Project Explorer]
	cOnClickCommand   = []
	cActiveFormMethod = [Release]
	cSkipFor          = []
	cPictureResource  = [_mfi_quit]
	cPictureFile      = []
	cSystemBar        = []
enddefine

*==============================================================================
define class EditPad as ProjectExplorerPad of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption       = [\<Edit]
	cKey           = [ALT+E]
	cStatusBarText = [Edits text or current selection]
	cPopupName     = [EditPad]

	procedure AddBars
		with This
			.AddBar('EditUndo', 'menu.prg', 'EditUndo')
			.AddBar('EditRedo', 'menu.prg', 'EditRedo')
			.AddSeparatorBar()
			.AddBar('EditCut', 'menu.prg', 'EditCut')
			.AddBar('EditCopy', 'menu.prg', 'EditCopy')
			.AddBar('EditPaste', 'menu.prg', 'EditPaste')
			.AddBar('EditClear', 'menu.prg', 'EditClear')
			.AddSeparatorBar()
			.AddBar('EditSelectAll', 'menu.prg', 'EditSelectAll')
		endwith
	endproc
enddefine

*==============================================================================
define class EditUndo as ProjectExplorerBar of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption         = [\<Undo]
	cKey             = [CTRL+Z]
	cKeyText         = [Ctrl+Z]
	cStatusBarText   = [Undoes the last command or action]
	cOnClickCommand  = []
	cSkipFor         = []
	cPictureResource = []
	cPictureFile     = [UndoXPSmall.bmp]
	cSystemBar       = [_med_undo]
enddefine

*==============================================================================
define class EditRedo as ProjectExplorerBar of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption         = [Re\<do]
	cKey             = [CTRL+R]
	cKeyText         = [Ctrl+R]
	cStatusBarText   = [Repeats the last command or action]
	cOnClickCommand  = []
	cSkipFor         = []
	cPictureResource = []
	cPictureFile     = [RedoXPSmall.bmp]
	cSystemBar       = [_med_redo]
enddefine

*==============================================================================
define class EditCut as ProjectExplorerBar of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption         = [Cu\<t]
	cKey             = [CTRL+X]
	cKeyText         = [Ctrl+X]
	cStatusBarText   = [Removes the selection and places it onto the Clipboard]
	cOnClickCommand  = []
	cSkipFor         = []
	cPictureResource = []
	cPictureFile     = [cutxpsmall.bmp]
	cSystemBar       = [_med_cut]
enddefine

*==============================================================================
define class EditCopy as ProjectExplorerBar of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption         = [\<Copy]
	cKey             = [CTRL+C]
	cKeyText         = [Ctrl+C]
	cStatusBarText   = [Copies the selection onto the Clipboard]
	cOnClickCommand  = []
	cSkipFor         = []
	cPictureResource = []
	cPictureFile     = [copyxpsmall.bmp]
	cSystemBar       = [_med_copy]
enddefine

*==============================================================================
define class EditPaste as ProjectExplorerBar of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption         = [\<Paste]
	cKey             = [CTRL+V]
	cKeyText         = [Ctrl+V]
	cStatusBarText   = [Pastes the contents of the Clipboard]
	cOnClickCommand  = []
	cSkipFor         = []
	cPictureResource = []
	cPictureFile     = [pastexpsmall.bmp]
	cSystemBar       = [_med_paste]
enddefine

*==============================================================================
define class EditClear as ProjectExplorerBar of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption         = [Cle\<ar]
	cKey             = []
	cKeyText         = []
	cStatusBarText   = [Removes the selection and does not place it onto the Clipboard]
	cOnClickCommand  = []
	cSkipFor         = []
	cPictureResource = [_med_clear]
	cPictureFile     = []
	cSystemBar       = [_med_clear]
enddefine

*==============================================================================
define class EditSelectAll as ProjectExplorerBar of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption         = [Se\<lect All]
	cKey             = [CTRL+A]
	cKeyText         = [Ctrl+A]
	cStatusBarText   = [Selects all text or items in the current window]
	cOnClickCommand  = []
	cSkipFor         = []
	cPictureResource = [_med_slcta]
	cPictureFile     = []
	cSystemBar       = [_med_slcta]
enddefine

*==============================================================================
define class HelpPad as ProjectExplorerPad of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption       = [\<Help]
	cKey           = [ALT+H]
	cStatusBarText = [Displays Help]
	cPopupName     = [HelpPopup]

	procedure AddBars
		with This
*** TODO: have help file?
			.AddBar('ProjectExplorerHelpTopicsBar', 'ProjectExplorerMenu.vcx', ;
				'HelpHelp')
			.AddBar('HelpAboutProjectExplorer', 'menu.prg', 'HelpAboutProjectExplorer')
		endwith
	endproc
enddefine

*==============================================================================
define class HelpAboutProjectExplorer as ProjectExplorerBar of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption         = [\<About Project Explorer...]
	cKey             = []
	cKeyText         = []
	cStatusBarText   = [Displays information about Project Explorer]
*** TODO: create this form
	cOnClickCommand  = [do form About]
	cSkipFor         = []
	cPictureResource = [_mst_about]
	cPictureFile     = []
	cSystemBar       = []
enddefine
