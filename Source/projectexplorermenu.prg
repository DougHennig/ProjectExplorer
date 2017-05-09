*==============================================================================
define class ProjectExplorerFormMenu as ProjectExplorerMenu ;
	of ProjectExplorerMenu.vcx
*==============================================================================
	procedure DefineMenu
		This.AddPad('ProjectExplorerMenuPad', 'ProjectExplorerMenu.prg', ;
			'ProjectExplorerPad')
	endproc
enddefine

*==============================================================================
define class ProjectExplorerMenuPad as ProjectExplorerPad ;
	of ProjectExplorerMenu.vcx
*==============================================================================
	procedure Show
		with This
		
* Set the pad settings depending on whether we're running in a top-level form
* or not, since it may be in the VFP system menu.

			if .oParent.lAddToSystemMenu
				.cCaption       = [Pro\<ject Explorer]
				.cKey           = [ALT+J]
				.cStatusBarText = [Project Explorer operations]
			else
				.cCaption       = [\<File]
				.cKey           = [ALT+F]
				.cStatusBarText = [File operations]
			endif .oParent.lAddToSystemMenu
		endwith
		dodefault()
	endproc

	procedure AddBars
		with This
			.AddBar('ProjectExplorerAddProject', ;
				'ProjectExplorerMenu.prg', 'ProjectExplorerAddProject')
			.AddBar('ProjectExplorerRemoveProject', ;
				'ProjectExplorerMenu.prg', 'ProjectExplorerRemoveProject')
			.AddSeparatorBar()
			.AddBar('ProjectExplorerCleanupSolution', ;
				'ProjectExplorerMenu.prg', 'ProjectExplorerCleanupSolution')
			.AddBar('ProjectExplorerSolutionProperties', ;
				'ProjectExplorerMenu.prg', 'ProjectExplorerSolutionProperties')
			.AddSeparatorBar()
			.AddBar('ProjectExplorerSortFilter', ;
				'ProjectExplorerMenu.prg', 'ProjectExplorerSortFilter')
			.AddSeparatorBar()
			.AddBar('ProjectExplorerTagEditor', ;
				'ProjectExplorerMenu.prg', 'ProjectExplorerTagEditor')
			.AddBar('ProjectExplorerCategoryEditor', ;
				'ProjectExplorerMenu.prg', 'ProjectExplorerCategoryEditor')
			.AddBar('ProjectExplorerOptions', ;
				'ProjectExplorerMenu.prg', 'ProjectExplorerOptions')
			.AddSeparatorBar()
			.AddBar('ProjectExplorerAbout', ;
				'ProjectExplorerMenu.prg', 'ProjectExplorerAbout')
			.AddSeparatorBar()
			.AddBar('ProjectExplorerExit', ;
				'ProjectExplorerMenu.prg', 'ProjectExplorerExit')
		endwith
	endproc
enddefine

*==============================================================================
define class ProjectExplorerAddProject as ProjectExplorerBar ;
	of ProjectExplorerMenu.vcx
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
define class ProjectExplorerRemoveProject as ProjectExplorerBar ;
	of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption          = [\<Remove Project from Solution]
	cKey              = []
	cKeyText          = []
	cStatusBarText    = [Removes a project from the solution]
	cOnClickCommand   = []
	cActiveFormMethod = [RemoveProjectFromSolution]
	cSkipFor          = [_screen.ActiveForm.oSolution.oProjects.Count < 2 ] + ;
		[or vartype(_screen.ActiveForm.oItem) = 'O']
		&& skip if there's only one project or a project isn't selected
	cPictureResource  = []
	cPictureFile      = [remove.bmp]
	cSystemBar        = []
enddefine

*==============================================================================
define class ProjectExplorerCleanupSolution as ProjectExplorerBar ;
	of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption          = [\<Cleanup Solution]
	cKey              = []
	cKeyText          = []
	cStatusBarText    = [Cleans up all projects in the solution]
	cOnClickCommand   = []
	cActiveFormMethod = [CleanupSolution]
	cSkipFor          = []
	cPictureResource  = []
	cPictureFile      = [Cleanup.bmp]
	cSystemBar        = []
enddefine

*==============================================================================
define class ProjectExplorerSolutionProperties as ProjectExplorerBar ;
	of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption          = [\<Version Control Properties...]
	cKey              = []
	cKeyText          = []
	cStatusBarText    = [Maintains version control properties for the solution]
	cOnClickCommand   = []
	cActiveFormMethod = [EditSolutionProperties]
	cSkipFor          = []
	cPictureResource  = []
	cPictureFile      = [ProjectExplorer.ico]
	cSystemBar        = []
enddefine

*==============================================================================
define class ProjectExplorerSortFilter as ProjectExplorerBar ;
	of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption          = [\<Sort and Filter...]
	cKey              = []
	cKeyText          = []
	cStatusBarText    = [Allows you to specify how to sort and filter ] + ;
		[the TreeView]
	cOnClickCommand   = []
	cActiveFormMethod = [SortFilter]
	cSkipFor          = []
	cPictureResource  = []
	cPictureFile      = [Filter.ico]
	cSystemBar        = []
enddefine

*==============================================================================
define class ProjectExplorerTagEditor as ProjectExplorerBar ;
	of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption          = [\<Tag Editor...]
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
define class ProjectExplorerCategoryEditor as ProjectExplorerBar ;
	of ProjectExplorerMenu.vcx
*==============================================================================
	cCaption          = [\<Category Editor...]
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
define class ProjectExplorerOptions as ProjectExplorerBar ;
	of ProjectExplorerMenu.vcx
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
define class ProjectExplorerAbout as ProjectExplorerBar ;
	of ProjectExplorerMenu.vcx
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

*==============================================================================
define class ProjectExplorerExit as ProjectExplorerBar ;
	of ProjectExplorerMenu.vcx
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
