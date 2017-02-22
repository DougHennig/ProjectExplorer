*=================================================================================
define class ProjectExplorerFormMenu as ProjectExplorerMenu of ProjectExplorerMenu.vcx
*=================================================================================
	procedure DefineMenu
		with This
			.AddPad('FilePad', 'menu.prg', 'FilePad')
			.AddPad('EditPad', 'menu.prg', 'EditPad')
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
			.AddBar('FileAddProject',      'menu.prg', 'FileAddProject')
			.AddBar('FileRemoveProject',   'menu.prg', 'FileRemoveProject')
			.AddSeparatorBar()
			.AddBar('FileBuildProject',    'menu.prg', 'FileBuildProject')
			.AddBar('FileBuildSolution',   'menu.prg', 'FileBuildSolution')
			.AddSeparatorBar()
			.AddBar('FileRebuildProject',  'menu.prg', 'FileRebuildProject')
			.AddBar('FileRebuildSolution', 'menu.prg', 'FileRebuildSolution')
			.AddSeparatorBar()
			.AddBar('FileExit',            'menu.prg', 'FileExit')
		endwith
	endproc
enddefine

*==============================================================================
define class FileAddProject as ProjectExplorerBar of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption         = [\<Add Project to Solution]
	cKey             = []
	cKeyText         = []
	cStatusBarText   = [Adds a project to the solution]
	cOnClickCommand  = [_screen.ActiveForm.AddProjectToSolution()]
	cSkipFor         = []
*** TODO: image
	cPictureResource = []
	cPictureFile     = []
	cSystemBar       = []
enddefine

*==============================================================================
define class FileRemoveProject as ProjectExplorerBar of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption         = [\<Remove Project from Solution]
	cKey             = []
	cKeyText         = []
	cStatusBarText   = [Removes a project from the solution]
	cOnClickCommand  = [_screen.ActiveForm.RemoveProjectFromSolution()]
	cSkipFor         = [_screen.ActiveForm.oProjectEngines.Count < 2 or vartype(_screen.ActiveForm.oItem) = 'O']
		&& skip if there's only one project or a project isn't selected
*** TODO: image
	cPictureResource = []
	cPictureFile     = []
	cSystemBar       = []
enddefine

*==============================================================================
define class FileBuildProject as ProjectExplorerBar of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption         = [\<Build Project]
	cKey             = []
	cKeyText         = []
	cStatusBarText   = [Builds the current project]
	cOnClickCommand  = [_screen.ActiveForm.BuildProjectFromDefaults()]
	cSkipFor         = [not _screen.ActiveForm.CanBuildProject()]
	cPictureResource = []
	cPictureFile     = [BuildSolution.bmp]
	cSystemBar       = []
enddefine

*==============================================================================
define class FileBuildSolution as ProjectExplorerBar of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption         = [Build \<Solution]
	cKey             = []
	cKeyText         = []
	cStatusBarText   = [Builds all projects in the solution]
	cOnClickCommand  = [_screen.ActiveForm.BuildSolutionFromDefaults()]
	cSkipFor         = [not _screen.ActiveForm.CanBuildProject()]
	cPictureResource = []
	cPictureFile     = [BuildSolution.bmp]
	cSystemBar       = []
enddefine

*==============================================================================
define class FileRebuildProject as ProjectExplorerBar of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption         = [\<Rebuild Project]
	cKey             = []
	cKeyText         = []
	cStatusBarText   = [Rebuilds the current project]
	cOnClickCommand  = [_screen.ActiveForm.BuildProjectFromDefaults(.T.)]
	cSkipFor         = [not _screen.ActiveForm.CanBuildProject()]
	cPictureResource = []
	cPictureFile     = [BuildSolution.bmp]
	cSystemBar       = []
enddefine

*==============================================================================
define class FileRebuildSolution as ProjectExplorerBar of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption         = [Reb\<uild Solution]
	cKey             = []
	cKeyText         = []
	cStatusBarText   = [Rebuilds all projects in the solution]
	cOnClickCommand  = [_screen.ActiveForm.BuildSolutionFromDefaults(.T.)]
	cSkipFor         = [not _screen.ActiveForm.CanBuildProject()]
	cPictureResource = []
	cPictureFile     = [BuildSolution.bmp]
	cSystemBar       = []
enddefine

*==============================================================================
define class FileExit as ProjectExplorerBar of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption         = [E\<xit]
	cKey             = []
	cKeyText         = []
	cStatusBarText   = [Exits Project Explorer]
	cOnClickCommand  = [_screen.ActiveForm.Release()]
	cSkipFor         = []
	cPictureResource = [_mfi_quit]
	cPictureFile     = []
	cSystemBar       = []
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
	cOnClickCommand  = [do form About]
	cSkipFor         = []
	cPictureResource = [_mst_about]
	cPictureFile     = []
	cSystemBar       = []
enddefine
